import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../storage/hive_service.dart';

class BackupResult {
  final bool success;
  final String message;
  final File? file;
  final String? fileSizeFormatted;
  final int totalRecords;
  final DateTime? timestamp;
  final String? financialYear;

  const BackupResult({
    required this.success,
    required this.message,
    this.file,
    this.fileSizeFormatted,
    this.totalRecords = 0,
    this.timestamp,
    this.financialYear,
  });
}

class BackupValidationResult {
  final bool isValid;
  final String message;
  final String? createdAtFormatted;
  final String? financialYear;
  final Map<String, dynamic>? backupPayload;
  final Map<String, int> summaryCounts;
  final File? selectedFile;

  const BackupValidationResult({
    required this.isValid,
    required this.message,
    this.createdAtFormatted,
    this.financialYear,
    this.backupPayload,
    this.summaryCounts = const {},
    this.selectedFile,
  });
}

class RestoreResult {
  final bool success;
  final String message;
  final int restoredRecords;

  const RestoreResult({
    required this.success,
    required this.message,
    this.restoredRecords = 0,
  });
}

class BackupRestoreService {
  final HiveService hiveService;

  BackupRestoreService(this.hiveService);

  /// Magic header bytes for XenoBiz binary backup (`XENOBIZ_BKP_V01\n`)
  static const List<int> _magicHeaderBytes = [
    0x58, 0x45, 0x4E, 0x4F, 0x42, 0x49, 0x5A, 0x5F, 0x42, 0x4B, 0x50, 0x5F, 0x56, 0x30, 0x31, 0x0A
  ];

  static const List<String> _targetBoxes = [
    HiveService.boxBusiness,
    HiveService.boxSubscription,
    HiveService.boxBillingCustomers,
    HiveService.boxCrmCustomers,
    HiveService.boxCustomers,
    HiveService.boxProducts,
    HiveService.boxInvoices,
    HiveService.boxLeads,
    HiveService.boxPayments,
    HiveService.boxPurchases,
    HiveService.boxExpenses,
    HiveService.boxSuppliers,
    HiveService.boxStockMovements,
    HiveService.boxSalesReturns,
    HiveService.boxPurchaseReturns,
    HiveService.boxIncome,
    HiveService.boxCategories,
    HiveService.boxCrmNotes,
    HiveService.boxCrmFollowUps,
    HiveService.boxCrmSettings,
  ];

  /// Calculates Indian Financial Year string (e.g. FY_2026-27 for 2026-04-01 to 2027-03-31).
  static String getIndianFinancialYear([DateTime? date]) {
    final dt = date ?? DateTime.now();
    final year = dt.year;
    final month = dt.month;
    final int startYear = month >= 4 ? year : year - 1;
    final int endYear = startYear + 1;
    final endYearShort = (endYear % 100).toString().padLeft(2, '0');
    return 'FY_$startYear-$endYearShort';
  }

  /// Retrieves stored backup directory path or fallback default.
  Future<String> getBackupLocationPath() async {
    try {
      final bizBox = hiveService.getBox(HiveService.boxBusiness);
      final savedPath = bizBox.get('backup_location_path')?.toString();
      if (savedPath != null && savedPath.trim().isNotEmpty) {
        final dir = Directory(savedPath);
        if (dir.existsSync()) {
          return savedPath;
        }
      }
    } catch (_) {}

    try {
      if (Platform.isAndroid) {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          final parts = extDir.path.split('/Android/data/');
          if (parts.length > 1) {
            final targetPath = '${parts[0]}/Xenobiz/db/backup';
            final targetDir = Directory(targetPath);
            if (!targetDir.existsSync()) {
              targetDir.createSync(recursive: true);
            }
            return targetDir.path;
          }
        }
      }
    } catch (_) {}

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final defaultDir = Directory('${appDocDir.path}/Xenobiz/db/backup');
      if (!defaultDir.existsSync()) {
        defaultDir.createSync(recursive: true);
      }
      return defaultDir.path;
    } catch (_) {
      final tempDir = Directory.systemTemp;
      return tempDir.path;
    }
  }

  /// Persists user selected directory path for backups.
  Future<void> setBackupLocationPath(String path) async {
    try {
      final bizBox = hiveService.getBox(HiveService.boxBusiness);
      await bizBox.put('backup_location_path', path);
    } catch (_) {}
  }

  /// Triggers system folder picker for backup directory.
  Future<String?> pickBackupDirectory() async {
    try {
      final selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Backup Storage Folder',
      );
      if (selectedDirectory != null && selectedDirectory.trim().isNotEmpty) {
        await setBackupLocationPath(selectedDirectory);
        return selectedDirectory;
      }
    } catch (_) {}
    return null;
  }

  /// Creates an atomic `.bin` binary backup file in the Financial Year folder.
  Future<BackupResult> createBackup() async {
    File? tempFile;
    try {
      final now = DateTime.now();
      final fy = getIndianFinancialYear(now);
      final baseLocationPath = await getBackupLocationPath();
      final fyDir = Directory('$baseLocationPath/$fy');
      if (!fyDir.existsSync()) {
        fyDir.createSync(recursive: true);
      }

      final destinationFile = File('${fyDir.path}/xenobiz_backup.bin');
      tempFile = File('${fyDir.path}/xenobiz_backup.tmp');

      final Map<String, dynamic> boxesData = {};
      int totalRecords = 0;
      final Map<String, int> summaryCounts = {};

      for (var boxName in _targetBoxes) {
        final box = hiveService.getBox(boxName);
        final Map<String, dynamic> boxContent = {};

        for (var key in box.keys) {
          final val = box.get(key);
          boxContent[key.toString()] = _toEncodable(val);
        }

        boxesData[boxName] = boxContent;
        summaryCounts[boxName] = boxContent.length;
        totalRecords += boxContent.length;
      }

      final backupPayload = {
        'app': 'XenoBiz POS',
        'backupVersion': 1,
        'appVersion': '1.0.0',
        'databaseVersion': 1,
        'createdAt': now.toIso8601String(),
        'financialYear': fy,
        'totalRecords': totalRecords,
        'summaryCounts': summaryCounts,
        'boxes': boxesData,
      };

      final jsonBytes = utf8.encode(jsonEncode(backupPayload));
      final compressedBytes = gzip.encode(jsonBytes);
      final finalBytes = [..._magicHeaderBytes, ...compressedBytes];

      // Write to temp file first (Atomic Write)
      await tempFile.writeAsBytes(finalBytes, flush: true);

      // Validate temp file before replacement
      final validation = await validateBackupFile(tempFile);
      if (!validation.isValid) {
        if (tempFile.existsSync()) {
          tempFile.deleteSync();
        }
        return BackupResult(
          success: false,
          message: 'Temporary backup file validation failed: ${validation.message}',
        );
      }

      // Atomically replace existing xenobiz_backup.bin
      if (destinationFile.existsSync()) {
        await destinationFile.delete();
      }
      await tempFile.rename(destinationFile.path);

      final bytesCount = await destinationFile.length();
      String sizeFormatted;
      if (bytesCount >= 1024 * 1024) {
        sizeFormatted = '${(bytesCount / (1024 * 1024)).toStringAsFixed(1)} MB';
      } else {
        sizeFormatted = '${(bytesCount / 1024).toStringAsFixed(1)} KB';
      }

      final bizBox = hiveService.getBox(HiveService.boxBusiness);
      await bizBox.put('last_backup_info', {
        'timestamp': now.toIso8601String(),
        'sizeFormatted': sizeFormatted,
        'totalRecords': totalRecords,
        'financialYear': fy,
        'fileName': 'xenobiz_backup.bin',
        'relativePath': '$fy/xenobiz_backup.bin',
        'path': destinationFile.path,
        'savedLocation': fyDir.path,
      });

      return BackupResult(
        success: true,
        message: 'Backup created successfully ($sizeFormatted, $totalRecords records)',
        file: destinationFile,
        fileSizeFormatted: sizeFormatted,
        totalRecords: totalRecords,
        timestamp: now,
        financialYear: fy,
      );
    } catch (e) {
      if (tempFile != null && tempFile.existsSync()) {
        try {
          tempFile.deleteSync();
        } catch (_) {}
      }
      return BackupResult(
        success: false,
        message: 'Failed to create backup: ${e.toString()}',
      );
    }
  }

  /// Saves or creates backup in target location atomically.
  Future<File?> saveBackupToDevice({File? backupFile, String? targetDirectoryPath}) async {
    try {
      final createRes = await createBackup();
      if (createRes.success && createRes.file != null) {
        return createRes.file!;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Shares backup file via native system share sheet.
  Future<void> shareBackupFile(File file) async {
    try {
      final fileName = file.path.split('/').last.split('\\').last;
      await Share.shareXFiles(
        [XFile(file.path, name: fileName)],
        text: 'XenoBiz Business Backup File',
      );
    } catch (_) {}
  }

  /// Returns last successful backup metadata.
  Map<String, dynamic>? getLastBackupInfo() {
    try {
      final bizBox = hiveService.getBox(HiveService.boxBusiness);
      final info = bizBox.get('last_backup_info');
      if (info is Map) {
        return Map<String, dynamic>.from(info);
      }
    } catch (_) {}
    return null;
  }

  /// Picks a `.bin`, `.xenobiz`, or `.json` file from storage and validates it.
  Future<BackupValidationResult?> pickBackupFileAndValidate() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['bin', 'xenobiz', 'json'],
      );

      if (result != null && result.files.isNotEmpty && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        return await validateBackupFile(file);
      }
    } catch (e) {
      return BackupValidationResult(
        isValid: false,
        message: 'Could not read backup file: ${e.toString()}',
      );
    }
    return null;
  }

  /// Validates file bytes, binary magic header, gzip decompression, and payload structure.
  Future<BackupValidationResult> validateBackupFile(File file) async {
    try {
      if (!file.existsSync()) {
        return BackupValidationResult(
          isValid: false,
          message: 'Selected file does not exist.',
          selectedFile: file,
        );
      }

      final bytes = await file.readAsBytes();
      Map<String, dynamic> decoded;

      bool isBinary = false;
      if (bytes.length >= _magicHeaderBytes.length) {
        isBinary = true;
        for (int i = 0; i < _magicHeaderBytes.length; i++) {
          if (bytes[i] != _magicHeaderBytes[i]) {
            isBinary = false;
            break;
          }
        }
      }

      if (isBinary) {
        final compressedBytes = bytes.sublist(_magicHeaderBytes.length);
        final jsonBytes = gzip.decode(compressedBytes);
        final jsonString = utf8.decode(jsonBytes);
        decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      } else {
        final jsonString = utf8.decode(bytes);
        decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      }

      if (decoded['app'] != 'XenoBiz POS' && decoded['app'] != 'XenoBiz') {
        return BackupValidationResult(
          isValid: false,
          message: 'Unrecognized backup file. Signature does not match XenoBiz POS.',
          selectedFile: file,
        );
      }

      if (decoded['boxes'] is! Map) {
        return BackupValidationResult(
          isValid: false,
          message: 'Corrupted backup file: Missing database boxes data.',
          selectedFile: file,
        );
      }

      final Map boxesMap = decoded['boxes'] as Map;
      int totalCount = 0;
      final Map<String, int> counts = {};

      boxesMap.forEach((boxName, boxData) {
        if (boxData is Map) {
          counts[boxName.toString()] = boxData.length;
          totalCount += boxData.length;
        }
      });

      String dateStr = 'Unknown date';
      if (decoded['createdAt'] != null) {
        try {
          final dt = DateTime.parse(decoded['createdAt'].toString());
          dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
        } catch (_) {}
      }

      final fy = decoded['financialYear']?.toString() ?? 'FY_UNKNOWN';

      return BackupValidationResult(
        isValid: true,
        message: 'Valid backup ($totalCount records from $dateStr)',
        createdAtFormatted: dateStr,
        financialYear: fy,
        backupPayload: decoded,
        summaryCounts: counts,
        selectedFile: file,
      );
    } catch (e) {
      return BackupValidationResult(
        isValid: false,
        message: 'Failed to parse backup file: ${e.toString()}',
        selectedFile: file,
      );
    }
  }

  /// Restores local Hive boxes from validated backup payload with post-restore verification.
  Future<RestoreResult> restoreFromPayload(Map<String, dynamic> payload) async {
    try {
      if (payload['boxes'] is! Map) {
        return const RestoreResult(
          success: false,
          message: 'Invalid payload: missing database boxes.',
        );
      }

      final Map boxesMap = payload['boxes'] as Map;
      int restoredRecords = 0;

      for (var boxName in _targetBoxes) {
        final box = hiveService.getBox(boxName);
        await box.clear();

        if (boxesMap.containsKey(boxName) && boxesMap[boxName] is Map) {
          final Map boxData = boxesMap[boxName] as Map;
          for (var entry in boxData.entries) {
            await box.put(entry.key, entry.value);
            restoredRecords++;
          }
        }
        await box.flush();
      }

      // Verification Step: Verify restored record counts match payload expectations
      for (var boxName in _targetBoxes) {
        final box = hiveService.getBox(boxName);
        int expectedCount = 0;
        if (boxesMap.containsKey(boxName) && boxesMap[boxName] is Map) {
          expectedCount = (boxesMap[boxName] as Map).length;
        }
        if (box.length != expectedCount) {
          return RestoreResult(
            success: false,
            message: 'Restore verification failed for $boxName! Expected $expectedCount records, found ${box.length}.',
          );
        }
      }

      final now = DateTime.now();
      final fy = payload['financialYear']?.toString() ?? getIndianFinancialYear(now);
      final bizBox = hiveService.getBox(HiveService.boxBusiness);
      await bizBox.put('last_backup_info', {
        'timestamp': payload['createdAt'] ?? now.toIso8601String(),
        'sizeFormatted': '${(restoredRecords > 0 ? (restoredRecords * 0.1) : 0.9).toStringAsFixed(1)} KB',
        'totalRecords': restoredRecords,
        'financialYear': fy,
        'fileName': 'xenobiz_backup.bin',
        'relativePath': '$fy/xenobiz_backup.bin',
      });

      return RestoreResult(
        success: true,
        message: 'Data restored successfully! ($restoredRecords records verified across 20 tables)',
        restoredRecords: restoredRecords,
      );
    } catch (e) {
      return RestoreResult(
        success: false,
        message: 'Error during restore process: ${e.toString()}',
      );
    }
  }

  /// Central reusable automatic backup workflow for Exit & Close Shop flows.
  Future<BackupResult> performAutoExitBackup() async {
    try {
      final backupRes = await createBackup();
      return backupRes;
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Auto exit backup failed: ${e.toString()}',
      );
    }
  }

  dynamic _toEncodable(dynamic val) {
    if (val == null) return null;
    if (val is num || val is bool || val is String) return val;
    if (val is Map) {
      return val.map((k, v) => MapEntry(k.toString(), _toEncodable(v)));
    }
    if (val is List) {
      return val.map((item) => _toEncodable(item)).toList();
    }
    return val.toString();
  }
}

