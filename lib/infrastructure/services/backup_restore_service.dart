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

  const BackupResult({
    required this.success,
    required this.message,
    this.file,
    this.fileSizeFormatted,
    this.totalRecords = 0,
    this.timestamp,
  });
}

class BackupValidationResult {
  final bool isValid;
  final String message;
  final String? createdAtFormatted;
  final Map<String, dynamic>? backupPayload;
  final Map<String, int> summaryCounts;
  final File? selectedFile;

  const BackupValidationResult({
    required this.isValid,
    required this.message,
    this.createdAtFormatted,
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

  static const List<String> _targetBoxes = [
    HiveService.boxBusiness,
    HiveService.boxSubscription,
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
  ];

  /// Retrieves stored backup directory path or fallback default (Internal Storage / Xenobiz / db / backup).
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

  /// Creates a complete `.xenobiz` backup file of all local business data.
  Future<BackupResult> createBackup() async {
    try {
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

      final now = DateTime.now();
      final backupPayload = {
        'app': 'XenoBiz POS',
        'version': '1.0.0',
        'schemaVersion': 1,
        'createdAt': now.toIso8601String(),
        'totalRecords': totalRecords,
        'summaryCounts': summaryCounts,
        'boxes': boxesData,
      };

      final jsonString = jsonEncode(backupPayload);
      final bytes = utf8.encode(jsonString);

      final tempDir = Directory.systemTemp;
      final fileName = 'XenoBiz_Backup_${DateFormat('yyyy-MM-dd_HH-mm-ss').format(now)}.xenobiz';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      String sizeFormatted;
      if (bytes.length >= 1024 * 1024) {
        sizeFormatted = '${(bytes.length / (1024 * 1024)).toStringAsFixed(1)} MB';
      } else {
        sizeFormatted = '${(bytes.length / 1024).toStringAsFixed(1)} KB';
      }

      final bizBox = hiveService.getBox(HiveService.boxBusiness);
      await bizBox.put('last_backup_info', {
        'timestamp': now.toIso8601String(),
        'sizeFormatted': sizeFormatted,
        'totalRecords': totalRecords,
        'fileName': fileName,
        'tempPath': file.path,
      });

      return BackupResult(
        success: true,
        message: 'Backup created successfully ($sizeFormatted, $totalRecords records)',
        file: file,
        fileSizeFormatted: sizeFormatted,
        totalRecords: totalRecords,
        timestamp: now,
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Failed to create backup: ${e.toString()}',
      );
    }
  }

  /// Saves a generated backup file directly to target/configured device storage folder.
  Future<File?> saveBackupToDevice({File? backupFile, String? targetDirectoryPath}) async {
    try {
      File fileToSave;
      if (backupFile != null && backupFile.existsSync()) {
        fileToSave = backupFile;
      } else {
        final createRes = await createBackup();
        if (!createRes.success || createRes.file == null) {
          return null;
        }
        fileToSave = createRes.file!;
      }

      final targetPath = targetDirectoryPath ?? await getBackupLocationPath();
      final targetDir = Directory(targetPath);
      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }

      final fileName = fileToSave.path.split('/').last.split('\\').last;
      final destinationFile = File('${targetDir.path}/$fileName');
      await destinationFile.writeAsBytes(await fileToSave.readAsBytes());

      final bytes = await destinationFile.length();
      String sizeFormatted;
      if (bytes >= 1024 * 1024) {
        sizeFormatted = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      } else {
        sizeFormatted = '${(bytes / 1024).toStringAsFixed(1)} KB';
      }

      final now = DateTime.now();
      final bizBox = hiveService.getBox(HiveService.boxBusiness);
      await bizBox.put('last_backup_info', {
        'timestamp': now.toIso8601String(),
        'sizeFormatted': sizeFormatted,
        'fileName': fileName,
        'path': destinationFile.path,
        'savedLocation': targetDir.path,
      });

      return destinationFile;
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

  /// Picks a `.xenobiz` or `.json` file from device storage and validates it.
  Future<BackupValidationResult?> pickBackupFileAndValidate() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xenobiz', 'json'],
      );

      if (result != null && result.files.isNotEmpty && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final validation = validateBackupPayload(jsonString);
        return BackupValidationResult(
          isValid: validation.isValid,
          message: validation.message,
          createdAtFormatted: validation.createdAtFormatted,
          backupPayload: validation.backupPayload,
          summaryCounts: validation.summaryCounts,
          selectedFile: file,
        );
      }
    } catch (e) {
      return BackupValidationResult(
        isValid: false,
        message: 'Could not read backup file: ${e.toString()}',
      );
    }
    return null;
  }

  /// Validates string content or JSON payload of a backup file.
  BackupValidationResult validateBackupPayload(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return const BackupValidationResult(
          isValid: false,
          message: 'Invalid file format: Backup payload must be a JSON object.',
        );
      }

      if (decoded['app'] != 'XenoBiz POS' && decoded['app'] != 'XenoBiz') {
        return const BackupValidationResult(
          isValid: false,
          message: 'Unrecognized backup file. Signature does not match XenoBiz POS.',
        );
      }

      if (decoded['boxes'] is! Map) {
        return const BackupValidationResult(
          isValid: false,
          message: 'Corrupted backup file: Missing database boxes data.',
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

      return BackupValidationResult(
        isValid: true,
        message: 'Valid backup ($totalCount records from $dateStr)',
        createdAtFormatted: dateStr,
        backupPayload: Map<String, dynamic>.from(decoded),
        summaryCounts: counts,
      );
    } catch (e) {
      return BackupValidationResult(
        isValid: false,
        message: 'Failed to parse backup file: ${e.toString()}',
      );
    }
  }

  /// Restores local Hive boxes from validated backup payload.
  Future<RestoreResult> restoreFromPayload(Map<String, dynamic> payload) async {
    try {
      final Map boxesMap = payload['boxes'] as Map;
      int restoredRecords = 0;

      for (var boxName in _targetBoxes) {
        if (boxesMap.containsKey(boxName) && boxesMap[boxName] is Map) {
          final box = hiveService.getBox(boxName);
          await box.clear();

          final Map boxData = boxesMap[boxName] as Map;
          for (var entry in boxData.entries) {
            await box.put(entry.key, entry.value);
            restoredRecords++;
          }
        }
      }

      return RestoreResult(
        success: true,
        message: 'Data restored successfully! ($restoredRecords records updated)',
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
      if (!backupRes.success || backupRes.file == null) {
        return backupRes;
      }

      final savedFile = await saveBackupToDevice(backupFile: backupRes.file);
      if (savedFile != null) {
        return BackupResult(
          success: true,
          message: 'Backup saved successfully to ${savedFile.path}',
          file: savedFile,
          fileSizeFormatted: backupRes.fileSizeFormatted,
          totalRecords: backupRes.totalRecords,
          timestamp: backupRes.timestamp,
        );
      } else {
        return const BackupResult(
          success: false,
          message: 'Could not save backup to target storage location.',
        );
      }
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
