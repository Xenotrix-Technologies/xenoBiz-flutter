import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/invoice_return_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../domain/repositories/returns_repository.dart';
import '../database/app_database.dart';

class ReturnsRepositoryImpl implements ReturnsRepository {
  final AppDatabase db;
  final ProductRepository productRepository;
  final CustomerRepository customerRepository;
  final PurchaseRepository purchaseRepository;

  ReturnsRepositoryImpl({
    required this.db,
    required this.productRepository,
    required this.customerRepository,
    required this.purchaseRepository,
  });

  InvoiceReturnEntity _rowToReturn(InvoiceReturn row, List<InvoiceReturnItem> itemRows) {
    final type = row.type == 'purchase' ? InvoiceType.purchase : InvoiceType.sale;

    final items = itemRows.map((i) => InvoiceReturnItemEntity(
      productId: i.productId,
      productName: i.productName,
      sku: i.sku,
      originalQuantity: i.originalQuantity,
      returnedQuantity: i.returnedQuantity,
      unitPrice: i.unitPrice,
    )).toList();

    return InvoiceReturnEntity(
      id: row.id,
      returnNumber: row.returnNumber,
      invoiceId: row.invoiceId,
      invoiceNumber: row.invoiceNumber,
      partyId: row.partyId,
      partyName: row.partyName,
      type: type,
      items: items,
      totalAmount: row.totalAmount,
      returnDate: row.returnDate,
      notes: row.notes,
    );
  }

  InvoiceReturnsCompanion _returnToCompanion(InvoiceReturnEntity r) {
    return InvoiceReturnsCompanion(
      id: Value(r.id),
      returnNumber: Value(r.returnNumber),
      invoiceId: Value(r.invoiceId),
      invoiceNumber: Value(r.invoiceNumber),
      partyId: Value(r.partyId),
      partyName: Value(r.partyName),
      type: Value(r.type.name),
      totalAmount: Value(r.totalAmount),
      returnDate: Value(r.returnDate),
      notes: Value(r.notes),
    );
  }

  @override
  Future<List<InvoiceReturnEntity>> getReturns(InvoiceType type) async {
    final typeStr = type.name;
    final q = db.select(db.invoiceReturns)
      ..where((t) => t.type.equals(typeStr))
      ..orderBy([(t) => OrderingTerm.desc(t.returnDate)]);

    final rows = await q.get();

    final List<InvoiceReturnEntity> list = [];
    for (var row in rows) {
      final itemRows = await (db.select(db.invoiceReturnItems)..where((t) => t.returnId.equals(row.id))).get();
      list.add(_rowToReturn(row, itemRows));
    }
    return list;
  }

  @override
  Future<InvoiceReturnEntity?> getReturn(String id) async {
    final row = await (db.select(db.invoiceReturns)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row != null) {
      final itemRows = await (db.select(db.invoiceReturnItems)..where((t) => t.returnId.equals(id))).get();
      return _rowToReturn(row, itemRows);
    }
    return null;
  }

  @override
  Future<Map<String, int>> getReturnedQuantitiesForInvoice(String invoiceId) async {
    final Map<String, int> returnedCounts = {};
    final q = db.select(db.invoiceReturns)..where((t) => t.invoiceId.equals(invoiceId));
    final rows = await q.get();

    for (var row in rows) {
      final itemRows = await (db.select(db.invoiceReturnItems)..where((t) => t.returnId.equals(row.id))).get();
      for (var item in itemRows) {
        returnedCounts[item.productId] = (returnedCounts[item.productId] ?? 0) + item.returnedQuantity;
      }
    }
    return returnedCounts;
  }

  @override
  Future<InvoiceReturnEntity> createReturn(InvoiceReturnEntity returnEntity) async {
    final String id = returnEntity.id.isNotEmpty ? returnEntity.id : const Uuid().v4();
    final String retNum = returnEntity.returnNumber.isNotEmpty && returnEntity.returnNumber != 'RET-000'
        ? returnEntity.returnNumber
        : 'RET-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final localReturn = InvoiceReturnEntity(
      id: id,
      returnNumber: retNum,
      invoiceId: returnEntity.invoiceId,
      invoiceNumber: returnEntity.invoiceNumber,
      partyId: returnEntity.partyId,
      partyName: returnEntity.partyName,
      type: returnEntity.type,
      items: returnEntity.items,
      totalAmount: returnEntity.totalAmount,
      returnDate: returnEntity.returnDate,
      notes: returnEntity.notes,
    );

    await db.transaction(() async {
      await db.into(db.invoiceReturns).insertOnConflictUpdate(_returnToCompanion(localReturn));
      await (db.delete(db.invoiceReturnItems)..where((t) => t.returnId.equals(id))).go();

      for (var item in localReturn.items) {
        await db.into(db.invoiceReturnItems).insert(
          InvoiceReturnItemsCompanion.insert(
            returnId: id,
            productId: item.productId,
            productName: item.productName,
            sku: Value(item.sku),
            originalQuantity: Value(item.originalQuantity),
            returnedQuantity: Value(item.returnedQuantity),
            unitPrice: Value(item.unitPrice),
          ),
        );
      }
    });

    for (var item in localReturn.items) {
      if (item.returnedQuantity > 0) {
        final stockDelta = returnEntity.isSale
            ? item.returnedQuantity
            : -item.returnedQuantity;

        await productRepository.adjustStock(
          item.productId,
          stockDelta,
          'Return #${localReturn.returnNumber} (${localReturn.invoiceNumber})',
        );
      }
    }

    return localReturn;
  }

  @override
  Future<void> updateReturn(InvoiceReturnEntity returnEntity) async {
    final old = await getReturn(returnEntity.id);
    final oldQtyMap = <String, int>{};
    if (old != null) {
      for (var item in old.items) {
        oldQtyMap[item.productId] = item.returnedQuantity;
      }
    }

    await db.transaction(() async {
      await db.into(db.invoiceReturns).insertOnConflictUpdate(_returnToCompanion(returnEntity));
      await (db.delete(db.invoiceReturnItems)..where((t) => t.returnId.equals(returnEntity.id))).go();

      for (var item in returnEntity.items) {
        await db.into(db.invoiceReturnItems).insert(
          InvoiceReturnItemsCompanion.insert(
            returnId: returnEntity.id,
            productId: item.productId,
            productName: item.productName,
            sku: Value(item.sku),
            originalQuantity: Value(item.originalQuantity),
            returnedQuantity: Value(item.returnedQuantity),
            unitPrice: Value(item.unitPrice),
          ),
        );
      }
    });

    for (var item in returnEntity.items) {
      final oldQty = oldQtyMap[item.productId] ?? 0;
      final qtyDiff = item.returnedQuantity - oldQty;
      if (qtyDiff != 0) {
        final stockDelta = returnEntity.isSale ? qtyDiff : -qtyDiff;
        await productRepository.adjustStock(
          item.productId,
          stockDelta,
          'Update Return #${returnEntity.returnNumber}',
        );
      }
    }
  }
}
