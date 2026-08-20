import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

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

  const BackupValidationResult({
    required this.isValid,
    required this.message,
    this.createdAtFormatted,
    this.backupPayload,
    this.summaryCounts = const {},
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
  ];

  /// Creates a complete JSON backup file of all local business data.
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
      final fileName = 'XenoBiz_Backup_${DateFormat('yyyyMMdd_HHmmss').format(now)}.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      final fileSizeKb = (bytes.length / 1024).toStringAsFixed(1);
      final sizeFormatted = '$fileSizeKb KB';

      // Save last backup metadata in business box
      final bizBox = hiveService.getBox(HiveService.boxBusiness);
      await bizBox.put('last_backup_info', {
        'timestamp': now.toIso8601String(),
        'sizeFormatted': sizeFormatted,
        'totalRecords': totalRecords,
        'fileName': fileName,
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

  /// Saves an automatic backup to system/app internal storage under XenoBiz/database
  Future<File?> saveExitBackupToStorage() async {
    try {
      final Map<String, dynamic> boxesData = {};
      int totalRecords = 0;

      for (var boxName in _targetBoxes) {
        final box = hiveService.getBox(boxName);
        final Map<String, dynamic> boxContent = {};

        for (var key in box.keys) {
          final val = box.get(key);
          boxContent[key.toString()] = _toEncodable(val);
        }
        boxesData[boxName] = boxContent;
        totalRecords += boxContent.length;
      }

      final now = DateTime.now();
      final backupPayload = {
        'app': 'XenoBiz POS',
        'version': '1.0.0',
        'schemaVersion': 1,
        'createdAt': now.toIso8601String(),
        'totalRecords': totalRecords,
        'boxes': boxesData,
      };

      final jsonString = jsonEncode(backupPayload);
      final bytes = utf8.encode(jsonString);

      // Save inside XenoBiz/database folder in storage
      final tempDir = Directory.systemTemp;
      final targetDir = Directory('${tempDir.path}/XenoBiz/database');
      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }

      final fileName = 'XenoBiz_Backup_${DateFormat('yyyyMMdd_HHmmss').format(now)}.json';
      final file = File('${targetDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      final fileSizeKb = (bytes.length / 1024).toStringAsFixed(1);
      final sizeFormatted = '$fileSizeKb KB';

      final bizBox = hiveService.getBox(HiveService.boxBusiness);
      await bizBox.put('last_backup_info', {
        'timestamp': now.toIso8601String(),
        'sizeFormatted': sizeFormatted,
        'totalRecords': totalRecords,
        'fileName': fileName,
        'path': file.path,
      });

      return file;
    } catch (_) {
      return null;
    }
  }

  /// Returns last successful backup info if recorded.
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
