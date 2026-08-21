import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/lead_entity.dart';
import '../../domain/repositories/lead_repository.dart';

class RawImportRow {
  final int rowIndex; // 1-indexed for display
  final Map<String, String> rawData;
  final LeadEntity? parsedLead;
  final bool isValid;
  final List<String> errors;
  final bool isDuplicate;
  final String? duplicateReason;

  const RawImportRow({
    required this.rowIndex,
    required this.rawData,
    this.parsedLead,
    required this.isValid,
    this.errors = const [],
    this.isDuplicate = false,
    this.duplicateReason,
  });

  RawImportRow copyWith({
    bool? isValid,
    List<String>? errors,
    bool? isDuplicate,
    String? duplicateReason,
    LeadEntity? parsedLead,
  }) {
    return RawImportRow(
      rowIndex: rowIndex,
      rawData: rawData,
      parsedLead: parsedLead ?? this.parsedLead,
      isValid: isValid ?? this.isValid,
      errors: errors ?? this.errors,
      isDuplicate: isDuplicate ?? this.isDuplicate,
      duplicateReason: duplicateReason ?? this.duplicateReason,
    );
  }
}

class ParsedImportData {
  final List<String> fileHeaders;
  final List<RawImportRow> rows;
  final int totalRows;
  final int validCount;
  final int invalidCount;
  final int duplicateCount;

  const ParsedImportData({
    required this.fileHeaders,
    required this.rows,
    required this.totalRows,
    required this.validCount,
    required this.invalidCount,
    required this.duplicateCount,
  });
}

class LeadImportService {
  final LeadRepository leadRepository;

  LeadImportService({required this.leadRepository});

  static const Map<String, String> crmFields = {
    'contactName': 'Lead Name (Required)',
    'phone': 'Phone Number',
    'email': 'Email',
    'companyName': 'Company Name',
    'source': 'Lead Source',
    'stage': 'Stage / Status',
    'priority': 'Priority',
    'estimatedValue': 'Expected Value',
    'expectedClosingDate': 'Expected Closing Date',
    'assignedStaff': 'Assigned Staff',
    'nextFollowUpDate': 'Follow-up Date',
    'notes': 'Notes',
    'address': 'Address',
  };

  /// Generate & share standard CRM Lead template (.xlsx)
  Future<File> generateTemplate() async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Lead Import Template'];
    excel.delete('Sheet1');

    final headers = [
      'Lead Name',
      'Phone Number',
      'Email',
      'Company Name',
      'Lead Source',
      'Stage',
      'Priority',
      'Expected Value',
      'Expected Closing Date',
      'Assigned Staff',
      'Notes',
      'Address',
      'Follow-up Date',
    ];

    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Sample data rows
    sheet.appendRow([
      TextCellValue('Rajesh Kumar'),
      TextCellValue('9876543210'),
      TextCellValue('rajesh@example.com'),
      TextCellValue('Apex Solutions'),
      TextCellValue('Referral'),
      TextCellValue('Negotiation'),
      TextCellValue('High'),
      DoubleCellValue(50000.0),
      TextCellValue('25/09/2026'),
      TextCellValue('Self'),
      TextCellValue('Interested in enterprise subscription.'),
      TextCellValue('MG Road, Bengaluru'),
      TextCellValue('28/08/2026'),
    ]);

    sheet.appendRow([
      TextCellValue('Anita Sharma'),
      TextCellValue('9123456789'),
      TextCellValue('anita@techcorp.in'),
      TextCellValue('Tech Corp'),
      TextCellValue('Website'),
      TextCellValue('New'),
      TextCellValue('Medium'),
      DoubleCellValue(25000.0),
      TextCellValue('15/10/2026'),
      TextCellValue('Sales Manager'),
      TextCellValue('Requested product demo.'),
      TextCellValue('Cyber City, Gurugram'),
      TextCellValue('30/08/2026'),
    ]);

    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to build template Excel');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/CRM_Lead_Import_Template.xlsx');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'CRM Lead Import Template (.xlsx)',
    );

    return file;
  }

  /// Parse uploaded file (.xlsx or .csv) into headers & raw string rows
  Future<Map<String, dynamic>> parseFile(PlatformFile pickedFile) async {
    final fileName = pickedFile.name.toLowerCase();
    List<String> headers = [];
    List<List<String>> dataRows = [];

    if (fileName.endsWith('.xlsx')) {
      List<int> bytes;
      if (pickedFile.bytes != null) {
        bytes = pickedFile.bytes!;
      } else if (pickedFile.path != null) {
        bytes = await File(pickedFile.path!).readAsBytes();
      } else {
        throw Exception('Cannot read file content');
      }

      var excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) throw Exception('Excel file contains no sheets');

      final table = excel.tables.values.first;
      if (table.rows.isEmpty) throw Exception('Excel file is empty');

      headers = table.rows.first
          .map((cell) => cell?.value?.toString().trim() ?? '')
          .toList();

      for (int i = 1; i < table.rows.length; i++) {
        final row = table.rows[i];
        if (row.isEmpty || row.every((c) => c == null || c.value.toString().trim().isEmpty)) {
          continue; // Skip empty rows
        }
        final rowValues = row.map((cell) => cell?.value?.toString().trim() ?? '').toList();
        dataRows.add(rowValues);
      }
    } else if (fileName.endsWith('.csv')) {
      String csvContent;
      if (pickedFile.bytes != null) {
        csvContent = utf8.decode(pickedFile.bytes!);
      } else if (pickedFile.path != null) {
        csvContent = await File(pickedFile.path!).readAsString();
      } else {
        throw Exception('Cannot read CSV file content');
      }

      final csvConverter = const CsvToListConverter(shouldParseNumbers: false);
      final fields = csvConverter.convert(csvContent);

      if (fields.isEmpty) throw Exception('CSV file is empty');

      headers = fields.first.map((e) => e.toString().trim()).toList();

      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.isEmpty || row.every((c) => c.toString().trim().isEmpty)) continue;
        final rowValues = row.map((e) => e.toString().trim()).toList();
        dataRows.add(rowValues);
      }
    } else {
      throw Exception('Unsupported file format. Please upload an .xlsx or .csv file.');
    }

    return {
      'headers': headers,
      'rows': dataRows,
    };
  }

  /// Automatically map Excel columns to CRM field keys using fuzzy string match
  Map<String, String> autoMapColumns(List<String> headers) {
    Map<String, String> mapping = {};

    for (var header in headers) {
      final h = header.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (h.contains('leadname') || h.contains('contactname') || h.contains('customername') || h == 'name' || h.contains('client')) {
        mapping[header] = 'contactName';
      } else if (h.contains('phone') || h.contains('mobile') || h.contains('contact') || h == 'cell' || h == 'tel') {
        mapping[header] = 'phone';
      } else if (h.contains('email') || h.contains('mail')) {
        mapping[header] = 'email';
      } else if (h.contains('company') || h.contains('business') || h.contains('org')) {
        mapping[header] = 'companyName';
      } else if (h.contains('source') || h.contains('channel')) {
        mapping[header] = 'source';
      } else if (h.contains('stage') || h.contains('status')) {
        mapping[header] = 'stage';
      } else if (h.contains('priority') || h.contains('importance')) {
        mapping[header] = 'priority';
      } else if (h.contains('value') || h.contains('amount') || h.contains('budget') || h.contains('deal')) {
        mapping[header] = 'estimatedValue';
      } else if (h.contains('closing') || h.contains('targetdate')) {
        mapping[header] = 'expectedClosingDate';
      } else if (h.contains('assigned') || h.contains('staff') || h.contains('owner') || h.contains('agent')) {
        mapping[header] = 'assignedStaff';
      } else if (h.contains('followup') || h.contains('nextfollow')) {
        mapping[header] = 'nextFollowUpDate';
      } else if (h.contains('note') || h.contains('remark') || h.contains('comment') || h.contains('description')) {
        mapping[header] = 'notes';
      } else if (h.contains('address') || h.contains('location') || h.contains('city')) {
        mapping[header] = 'address';
      } else {
        mapping[header] = 'SKIP';
      }
    }

    return mapping;
  }

  /// Parse & validate raw rows against mapping configuration
  Future<ParsedImportData> validateAndParseRows({
    required List<String> fileHeaders,
    required List<List<String>> dataRows,
    required Map<String, String> columnMapping, // Excel Header -> CRM Field Key
  }) async {
    final existingLeads = await leadRepository.getLeads();

    List<RawImportRow> resultRows = [];
    int validCount = 0;
    int invalidCount = 0;
    int duplicateCount = 0;

    for (int i = 0; i < dataRows.length; i++) {
      final rawRowValues = dataRows[i];
      Map<String, String> rawData = {};
      Map<String, String> mappedFields = {};

      for (int c = 0; c < fileHeaders.length; c++) {
        final header = fileHeaders[c];
        final val = c < rawRowValues.length ? rawRowValues[c].trim() : '';
        rawData[header] = val;

        final mappedCrmKey = columnMapping[header];
        if (mappedCrmKey != null && mappedCrmKey != 'SKIP') {
          mappedFields[mappedCrmKey] = val;
        }
      }

      List<String> errors = [];

      // 1. Validate Lead Name (Required)
      final name = mappedFields['contactName'] ?? '';
      if (name.isEmpty) {
        errors.add('Missing Lead Name');
      }

      // 2. Validate Phone if present
      final phone = mappedFields['phone'] ?? '';
      if (phone.isNotEmpty && phone.replaceAll(RegExp(r'[^0-9+]'), '').length < 6) {
        errors.add('Invalid phone number format');
      }

      // 3. Validate Email if present
      final email = mappedFields['email'] ?? '';
      if (email.isNotEmpty && !email.contains('@')) {
        errors.add('Invalid email format');
      }

      // 4. Validate Numeric Estimated Value
      final valStr = mappedFields['estimatedValue'] ?? '0';
      final cleanValStr = valStr.replaceAll(RegExp(r'[^0-9.]'), '');
      double estimatedVal = 0.0;
      if (valStr.isNotEmpty && cleanValStr.isEmpty) {
        errors.add('Invalid expected value');
      } else {
        estimatedVal = double.tryParse(cleanValStr) ?? 0.0;
      }

      // 5. Parse Dates
      DateTime? closingDate = _parseDate(mappedFields['expectedClosingDate']);
      if ((mappedFields['expectedClosingDate'] ?? '').isNotEmpty && closingDate == null) {
        errors.add('Invalid expected closing date');
      }

      DateTime? followUpDate = _parseDate(mappedFields['nextFollowUpDate']);
      if ((mappedFields['nextFollowUpDate'] ?? '').isNotEmpty && followUpDate == null) {
        errors.add('Invalid follow-up date');
      }

      // 6. Parse Stage
      final stage = _parseStage(mappedFields['stage']);

      // 7. Parse Priority
      final priority = _parsePriority(mappedFields['priority']);

      final isValid = errors.isEmpty;

      // 8. Check Duplicates against database
      bool isDuplicate = false;
      String? dupReason;

      if (isValid) {
        for (var existing in existingLeads) {
          if (phone.isNotEmpty && existing.phone.isNotEmpty && phone == existing.phone) {
            isDuplicate = true;
            dupReason = 'Phone number "$phone" already exists (${existing.contactName})';
            break;
          }
          if (email.isNotEmpty && existing.email.isNotEmpty && email.toLowerCase() == existing.email.toLowerCase()) {
            isDuplicate = true;
            dupReason = 'Email "$email" already exists (${existing.contactName})';
            break;
          }
        }
      }

      if (isValid) {
        validCount++;
        if (isDuplicate) duplicateCount++;
      } else {
        invalidCount++;
      }

      LeadEntity? parsedLead;
      if (isValid) {
        parsedLead = LeadEntity(
          id: 'lead_${DateTime.now().millisecondsSinceEpoch}_$i',
          title: name,
          contactName: name,
          companyName: mappedFields['companyName'] ?? '',
          phone: phone,
          email: email,
          address: mappedFields['address'] ?? '',
          source: mappedFields['source']?.isNotEmpty == true ? mappedFields['source']! : 'Walk-in',
          stage: stage,
          priority: priority,
          estimatedValue: estimatedVal,
          expectedClosingDate: closingDate,
          assignedStaff: mappedFields['assignedStaff']?.isNotEmpty == true ? mappedFields['assignedStaff']! : 'Self',
          createdBy: 'Bulk Import',
          notes: mappedFields['notes'] ?? '',
          createdAt: DateTime.now(),
          nextFollowUpDate: followUpDate,
        );
      }

      resultRows.add(RawImportRow(
        rowIndex: i + 1,
        rawData: rawData,
        parsedLead: parsedLead,
        isValid: isValid,
        errors: errors,
        isDuplicate: isDuplicate,
        duplicateReason: dupReason,
      ));
    }

    return ParsedImportData(
      fileHeaders: fileHeaders,
      rows: resultRows,
      totalRows: dataRows.length,
      validCount: validCount,
      invalidCount: invalidCount,
      duplicateCount: duplicateCount,
    );
  }

  /// Executes final bulk import to LeadRepository
  Future<Map<String, int>> executeBulkImport({
    required List<RawImportRow> rows,
    required String duplicateOption, // 'skip', 'import_anyway'
  }) async {
    int total = rows.length;
    int success = 0;
    int skipped = 0;
    int failed = 0;

    for (var row in rows) {
      if (!row.isValid || row.parsedLead == null) {
        failed++;
        continue;
      }

      if (row.isDuplicate && duplicateOption == 'skip') {
        skipped++;
        continue;
      }

      try {
        await leadRepository.createLead(row.parsedLead!);
        success++;
      } catch (e) {
        failed++;
      }
    }

    return {
      'total': total,
      'success': success,
      'skipped': skipped,
      'failed': failed,
    };
  }

  static DateTime? _parseDate(String? str) {
    if (str == null || str.trim().isEmpty) return null;
    final s = str.trim();

    final tryIso = DateTime.tryParse(s);
    if (tryIso != null) return tryIso;

    final formats = [
      'dd/MM/yyyy',
      'd/M/yyyy',
      'dd-MM-yyyy',
      'yyyy-MM-dd',
      'MM/dd/yyyy',
      'dd MMM yyyy',
    ];

    for (var fmt in formats) {
      try {
        return DateFormat(fmt).parse(s);
      } catch (_) {}
    }
    return null;
  }

  static LeadStage _parseStage(String? str) {
    if (str == null || str.trim().isEmpty) return LeadStage.newLead;
    final s = str.trim().toLowerCase();
    if (s.contains('won')) return LeadStage.won;
    if (s.contains('lost')) return LeadStage.lost;
    if (s.contains('qualif')) return LeadStage.qualified;
    if (s.contains('propos')) return LeadStage.proposalSent;
    if (s.contains('negoti')) return LeadStage.negotiating;
    if (s.contains('contact')) return LeadStage.contacted;
    return LeadStage.newLead;
  }

  static LeadPriority _parsePriority(String? str) {
    if (str == null || str.trim().isEmpty) return LeadPriority.medium;
    final s = str.trim().toLowerCase();
    if (s.contains('high')) return LeadPriority.high;
    if (s.contains('low')) return LeadPriority.low;
    return LeadPriority.medium;
  }
}
