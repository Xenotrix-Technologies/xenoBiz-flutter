import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../application/bloc/accounts_bloc.dart';

class AccountImportValidationRow {
  final int rowIndex;
  final String accountType; // Sale Account, Purchase Account, Expense Account
  final String accountName;
  final String companyName;
  final String phone;
  final String email;
  final String address;
  final String category;
  final double openingBalance;
  final String notes;
  final bool isValid;
  final bool isDuplicate;
  final String? existingAccountId;
  final String? errorMessage;

  const AccountImportValidationRow({
    required this.rowIndex,
    required this.accountType,
    required this.accountName,
    required this.companyName,
    required this.phone,
    required this.email,
    required this.address,
    required this.category,
    required this.openingBalance,
    required this.notes,
    required this.isValid,
    required this.isDuplicate,
    this.existingAccountId,
    this.errorMessage,
  });
}

class AccountImportAnalysis {
  final int totalRows;
  final int validRows;
  final int invalidRows;
  final int duplicateRows;
  final List<AccountImportValidationRow> rows;
  final List<String> errorSummary;

  const AccountImportAnalysis({
    required this.totalRows,
    required this.validRows,
    required this.invalidRows,
    required this.duplicateRows,
    required this.rows,
    required this.errorSummary,
  });
}

enum DuplicateAccountStrategy {
  addBalance,     // Default: Add opening balance to existing account balance
  updateExisting, // Overwrite existing account details & balance
  skip,           // Skip duplicate accounts
}

class AccountImportService {
  /// Generate sample CSV template content for download/copying
  static String generateSampleCsvTemplate() {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('Account Type,Account Name,Company Name,Phone,Email,Address,Category,Opening Balance,Notes');
    buffer.writeln('Sale Account,John Mathew,,9876543210,john@example.com,123 MG Road,,2500.00,Regular retail customer');
    buffer.writeln('Purchase Account,ABC Distributors,ABC Pvt Ltd,9812345678,contact@abc.com,Industrial Estate,,10000.00,Primary beverage supplier');
    buffer.writeln('Expense Account,Shop Rent,,,landlord@rent.com,Main Market,Rent,0.00,Monthly store rent payment');
    buffer.writeln('Expense Account,Electricity Bill,,,power@utility.com,Power House,Utilities,1200.00,Monthly store power bill');
    return buffer.toString();
  }

  /// Parse and validate CSV text against existing accounts
  static AccountImportAnalysis parseAndValidateCsv({
    required String csvContent,
    required List<CustomerEntity> existingCustomers,
    required List<SupplierEntity> existingSuppliers,
    required List<ExpenseAccountSummary> existingExpenses,
  }) {
    final lines = csvContent
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const AccountImportAnalysis(
        totalRows: 0,
        validRows: 0,
        invalidRows: 0,
        duplicateRows: 0,
        rows: [],
        errorSummary: ['File is empty or contains no valid rows.'],
      );
    }

    // Check header line
    final firstLine = lines.first.toLowerCase();
    final bool hasHeader = firstLine.contains('account type') || firstLine.contains('account name') || firstLine.contains('phone');
    final dataLines = hasHeader ? lines.sublist(1) : lines;

    final List<AccountImportValidationRow> rowResults = [];
    final List<String> errors = [];
    int validCount = 0;
    int invalidCount = 0;
    int duplicateCount = 0;

    // Index existing accounts by name/phone for fast duplicate checking
    final Map<String, String> customerMap = {};
    for (var c in existingCustomers) {
      customerMap[c.name.trim().toLowerCase()] = c.id;
      if (c.phone.trim().isNotEmpty) customerMap[c.phone.trim()] = c.id;
    }

    final Map<String, String> supplierMap = {};
    for (var s in existingSuppliers) {
      supplierMap[s.name.trim().toLowerCase()] = s.id;
      if (s.phone.trim().isNotEmpty) supplierMap[s.phone.trim()] = s.id;
    }

    final Map<String, String> expenseMap = {};
    for (var e in existingExpenses) {
      expenseMap[e.title.trim().toLowerCase()] = e.title;
    }

    for (int i = 0; i < dataLines.length; i++) {
      final rowIndex = i + (hasHeader ? 2 : 1);
      final rawLine = dataLines[i];
      final columns = _splitCsvLine(rawLine);

      if (columns.isEmpty || (columns.length == 1 && columns[0].trim().isEmpty)) {
        continue;
      }

      final rawType = _getCol(columns, 0).trim();
      final accountName = _getCol(columns, 1).trim();
      final companyName = _getCol(columns, 2).trim();
      final phone = _getCol(columns, 3).trim();
      final email = _getCol(columns, 4).trim();
      final address = _getCol(columns, 5).trim();
      final category = _getCol(columns, 6).trim().isNotEmpty ? _getCol(columns, 6).trim() : 'Rent';
      final openingBalanceStr = _getCol(columns, 7).trim();
      final notes = _getCol(columns, 8).trim();

      // Normalize Account Type
      String accountType = 'Sale Account';
      final lowerType = rawType.toLowerCase();
      if (lowerType.contains('purchase') || lowerType.contains('supplier') || lowerType.contains('vendor')) {
        accountType = 'Purchase Account';
      } else if (lowerType.contains('expense') || lowerType.contains('cost') || lowerType.contains('utility')) {
        accountType = 'Expense Account';
      } else {
        accountType = 'Sale Account';
      }

      // Validation
      final List<String> rowErrors = [];

      if (accountName.isEmpty) {
        rowErrors.add('Account Name is missing');
      }

      final openingBalance = double.tryParse(openingBalanceStr);
      if (openingBalanceStr.isNotEmpty && openingBalance == null) {
        rowErrors.add('Invalid Opening Balance "$openingBalanceStr"');
      }

      // Duplicate detection
      String? matchedExistingId;
      bool isDuplicate = false;
      final nameKey = accountName.toLowerCase();

      if (accountType == 'Sale Account') {
        if (nameKey.isNotEmpty && customerMap.containsKey(nameKey)) {
          isDuplicate = true;
          matchedExistingId = customerMap[nameKey];
        } else if (phone.isNotEmpty && customerMap.containsKey(phone)) {
          isDuplicate = true;
          matchedExistingId = customerMap[phone];
        }
      } else if (accountType == 'Purchase Account') {
        if (nameKey.isNotEmpty && supplierMap.containsKey(nameKey)) {
          isDuplicate = true;
          matchedExistingId = supplierMap[nameKey];
        } else if (phone.isNotEmpty && supplierMap.containsKey(phone)) {
          isDuplicate = true;
          matchedExistingId = supplierMap[phone];
        }
      } else if (accountType == 'Expense Account') {
        if (nameKey.isNotEmpty && expenseMap.containsKey(nameKey)) {
          isDuplicate = true;
          matchedExistingId = expenseMap[nameKey];
        }
      }

      final isValid = rowErrors.isEmpty;
      if (!isValid) {
        invalidCount++;
        errors.add('Row $rowIndex: ${rowErrors.join(', ')}');
      } else {
        validCount++;
        if (isDuplicate) duplicateCount++;
      }

      rowResults.add(
        AccountImportValidationRow(
          rowIndex: rowIndex,
          accountType: accountType,
          accountName: accountName,
          companyName: companyName,
          phone: phone,
          email: email,
          address: address,
          category: category,
          openingBalance: openingBalance ?? 0.0,
          notes: notes,
          isValid: isValid,
          isDuplicate: isDuplicate,
          existingAccountId: matchedExistingId,
          errorMessage: rowErrors.isNotEmpty ? rowErrors.join(', ') : null,
        ),
      );
    }

    return AccountImportAnalysis(
      totalRows: rowResults.length,
      validRows: validCount,
      invalidRows: invalidCount,
      duplicateRows: duplicateCount,
      rows: rowResults,
      errorSummary: errors,
    );
  }

  static List<String> _splitCsvLine(String line) {
    final List<String> result = [];
    bool insideQuotes = false;
    StringBuffer sb = StringBuffer();

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        insideQuotes = !insideQuotes;
      } else if (char == ',' && !insideQuotes) {
        result.add(sb.toString());
        sb.clear();
      } else {
        sb.write(char);
      }
    }
    result.add(sb.toString());
    return result;
  }

  static String _getCol(List<String> columns, int index) {
    if (index < columns.length) {
      return columns[index].replaceAll('"', '').trim();
    }
    return '';
  }
}
