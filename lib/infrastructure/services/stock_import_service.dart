import '../../domain/entities/product_entity.dart';

class StockImportValidationRow {
  final int rowIndex;
  final String productName;
  final String sku;
  final String barcode;
  final String category;
  final double sellingPrice;
  final double costPrice;
  final int openingStock;
  final String unit;
  final int reorderLevel;
  final String description;
  final bool isValid;
  final bool isDuplicate;
  final String? existingProductId;
  final String? errorMessage;

  const StockImportValidationRow({
    required this.rowIndex,
    required this.productName,
    required this.sku,
    required this.barcode,
    required this.category,
    required this.sellingPrice,
    required this.costPrice,
    required this.openingStock,
    required this.unit,
    required this.reorderLevel,
    required this.description,
    required this.isValid,
    required this.isDuplicate,
    this.existingProductId,
    this.errorMessage,
  });
}

class StockImportAnalysis {
  final int totalRows;
  final int validRows;
  final int invalidRows;
  final int duplicateRows;
  final List<StockImportValidationRow> rows;
  final List<String> errorSummary;

  const StockImportAnalysis({
    required this.totalRows,
    required this.validRows,
    required this.invalidRows,
    required this.duplicateRows,
    required this.rows,
    required this.errorSummary,
  });
}

enum DuplicateImportStrategy {
  addStock,      // Default & safest: Add imported stock to existing product
  updateExisting,// Overwrite existing product details and stock
  skip,          // Skip duplicate products
}

class StockImportService {
  /// Generate sample CSV template content for download/copying
  static String generateSampleCsvTemplate() {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('Product Name,SKU,Barcode,Category,Selling Price,Cost Price,Opening Stock,Unit,Low Stock Threshold,Description');
    buffer.writeln('Coca Cola 500ml,CC500,8901234567890,Beverages,40.00,30.00,100,Bottles,15,Cold carbonated beverage');
    buffer.writeln('Pepsi 500ml,PP500,8901234567891,Beverages,40.00,28.00,50,Bottles,10,Refreshing cola');
    buffer.writeln('Lays Classic Salted 50g,LAY50,8901234567892,Snacks,20.00,14.00,200,Packets,30,Potato chips packet');
    return buffer.toString();
  }

  /// Parse and validate CSV text against existing products
  static StockImportAnalysis parseAndValidateCsv(
    String csvContent,
    List<ProductEntity> existingProducts,
  ) {
    final lines = csvContent
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const StockImportAnalysis(
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
    final bool hasHeader = firstLine.contains('product name') || firstLine.contains('sku') || firstLine.contains('price');
    final dataLines = hasHeader ? lines.sublist(1) : lines;

    final List<StockImportValidationRow> rowResults = [];
    final List<String> errors = [];
    int validCount = 0;
    int invalidCount = 0;
    int duplicateCount = 0;

    // Index existing products by SKU and Barcode for fast duplicate checking
    final Map<String, ProductEntity> skuMap = {};
    final Map<String, ProductEntity> barcodeMap = {};
    for (var p in existingProducts) {
      if (p.sku.trim().isNotEmpty) skuMap[p.sku.trim().toLowerCase()] = p;
      if (p.barcode.trim().isNotEmpty) barcodeMap[p.barcode.trim().toLowerCase()] = p;
    }

    for (int i = 0; i < dataLines.length; i++) {
      final rowIndex = i + (hasHeader ? 2 : 1);
      final rawLine = dataLines[i];
      final columns = _splitCsvLine(rawLine);

      if (columns.isEmpty || (columns.length == 1 && columns[0].trim().isEmpty)) {
        continue;
      }

      final productName = _getCol(columns, 0).trim();
      final sku = _getCol(columns, 1).trim();
      final barcode = _getCol(columns, 2).trim();
      final category = _getCol(columns, 3).trim().isNotEmpty ? _getCol(columns, 3).trim() : 'General';
      final sellingPriceStr = _getCol(columns, 4).trim();
      final costPriceStr = _getCol(columns, 5).trim();
      final openingStockStr = _getCol(columns, 6).trim();
      final unit = _getCol(columns, 7).trim().isNotEmpty ? _getCol(columns, 7).trim() : 'Pcs';
      final reorderLevelStr = _getCol(columns, 8).trim();
      final description = _getCol(columns, 9).trim();

      // Validation
      final List<String> rowErrors = [];

      if (productName.isEmpty) {
        rowErrors.add('Product Name is missing');
      }

      final sellingPrice = double.tryParse(sellingPriceStr);
      if (sellingPriceStr.isNotEmpty && sellingPrice == null) {
        rowErrors.add('Invalid Selling Price "$sellingPriceStr"');
      }

      final costPrice = double.tryParse(costPriceStr);
      if (costPriceStr.isNotEmpty && costPrice == null) {
        rowErrors.add('Invalid Cost Price "$costPriceStr"');
      }

      final openingStock = int.tryParse(openingStockStr);
      if (openingStockStr.isNotEmpty && openingStock == null) {
        rowErrors.add('Invalid Opening Stock "$openingStockStr"');
      }

      final reorderLevel = int.tryParse(reorderLevelStr);
      if (reorderLevelStr.isNotEmpty && reorderLevel == null) {
        rowErrors.add('Invalid Low Stock Threshold "$reorderLevelStr"');
      }

      // Duplicate detection
      String? matchedExistingId;
      bool isDuplicate = false;
      if (sku.isNotEmpty && skuMap.containsKey(sku.toLowerCase())) {
        isDuplicate = true;
        matchedExistingId = skuMap[sku.toLowerCase()]!.id;
      } else if (barcode.isNotEmpty && barcodeMap.containsKey(barcode.toLowerCase())) {
        isDuplicate = true;
        matchedExistingId = barcodeMap[barcode.toLowerCase()]!.id;
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
        StockImportValidationRow(
          rowIndex: rowIndex,
          productName: productName,
          sku: sku.isNotEmpty ? sku : 'SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}-$i',
          barcode: barcode,
          category: category,
          sellingPrice: sellingPrice ?? 0.0,
          costPrice: costPrice ?? 0.0,
          openingStock: openingStock ?? 0,
          unit: unit,
          reorderLevel: reorderLevel ?? 5,
          description: description,
          isValid: isValid,
          isDuplicate: isDuplicate,
          existingProductId: matchedExistingId,
          errorMessage: rowErrors.isNotEmpty ? rowErrors.join(', ') : null,
        ),
      );
    }

    return StockImportAnalysis(
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
