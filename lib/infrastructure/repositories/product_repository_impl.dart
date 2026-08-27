import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../database/app_database.dart';
import '../network/dio_client.dart';
import '../network/network_checker.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DioClient dioClient;
  final AppDatabase db;
  final NetworkChecker networkChecker;
  final SyncRepository syncRepository;

  ProductRepositoryImpl({
    required this.dioClient,
    required this.db,
    required this.networkChecker,
    required this.syncRepository,
  });

  ProductEntity _rowToProduct(Product row) {
    return ProductEntity(
      id: row.id,
      name: row.name,
      sku: row.sku,
      barcode: row.barcode,
      category: row.category,
      sellingPrice: row.sellingPrice,
      purchasePrice: row.purchasePrice,
      stockQuantity: row.stockQuantity,
      reorderLevel: row.reorderLevel,
      unit: row.unit,
      taxPercentage: row.taxPercentage,
      hsnCode: row.hsnCode,
      description: row.description,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  ProductsCompanion _productToCompanion(ProductEntity p, {String syncStatus = 'synced'}) {
    return ProductsCompanion(
      id: Value(p.id),
      name: Value(p.name),
      sku: Value(p.sku),
      barcode: Value(p.barcode),
      category: Value(p.category.isNotEmpty ? p.category : 'General'),
      sellingPrice: Value(p.sellingPrice),
      purchasePrice: Value(p.purchasePrice),
      stockQuantity: Value(p.stockQuantity),
      reorderLevel: Value(p.reorderLevel),
      unit: Value(p.unit),
      taxPercentage: Value(p.taxPercentage),
      hsnCode: Value(p.hsnCode),
      description: Value(p.description),
      isActive: Value(p.isActive),
      createdAt: Value(p.createdAt),
      updatedAt: Value(p.updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  InventoryMovement _rowToMovement(StockMovement row) {
    return InventoryMovement(
      id: row.id,
      productId: row.productId,
      productName: row.productName,
      type: row.type,
      quantityChange: row.quantityChange,
      previousQuantity: row.previousQuantity,
      newQuantity: row.newQuantity,
      reason: row.reason,
      timestamp: row.timestamp,
    );
  }

  StockMovementsCompanion _movementToCompanion(InventoryMovement m) {
    return StockMovementsCompanion(
      id: Value(m.id),
      productId: Value(m.productId),
      productName: Value(m.productName),
      type: Value(m.type),
      quantityChange: Value(m.quantityChange),
      previousQuantity: Value(m.previousQuantity),
      newQuantity: Value(m.newQuantity),
      reason: Value(m.reason),
      timestamp: Value(m.timestamp),
    );
  }

  @override
  Future<List<ProductEntity>> getProducts({String? query, String? category}) async {
    final q = db.select(db.products)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final rows = await q.get();

    final localProducts = rows.map(_rowToProduct).toList();

    List<ProductEntity> filtered = localProducts;
    if (category != null && category.isNotEmpty && category != 'All') {
      filtered = filtered.where((p) => p.category == category).toList();
    }
    if (query != null && query.isNotEmpty) {
      final lowerQ = query.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(lowerQ) ||
            p.sku.toLowerCase().contains(lowerQ) ||
            p.barcode.toLowerCase().contains(lowerQ) ||
            p.category.toLowerCase().contains(lowerQ);
      }).toList();
    }
    return filtered;
  }

  @override
  Future<ProductEntity> getProduct(String id) async {
    final q = db.select(db.products)..where((t) => t.id.equals(id));
    final row = await q.getSingleOrNull();
    if (row != null) {
      return _rowToProduct(row);
    }
    return ProductEntity(
      id: id,
      name: 'Unknown Product',
      sku: 'SKU-000',
      category: 'General',
      sellingPrice: 0.0,
      purchasePrice: 0.0,
      stockQuantity: 0,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<ProductEntity> createProduct(ProductEntity product) async {
    final String productId = product.id.isNotEmpty ? product.id : const Uuid().v4();
    final localProduct = product.copyWith(id: productId, updatedAt: DateTime.now());

    await db.transaction(() async {
      await db.into(db.products).insertOnConflictUpdate(_productToCompanion(localProduct));

      if (localProduct.stockQuantity > 0) {
        final movement = InventoryMovement(
          id: const Uuid().v4(),
          productId: productId,
          productName: localProduct.name,
          type: 'IN',
          quantityChange: localProduct.stockQuantity,
          previousQuantity: 0,
          newQuantity: localProduct.stockQuantity,
          reason: 'Opening Stock',
          timestamp: DateTime.now(),
        );
        await db.into(db.stockMovements).insertOnConflictUpdate(_movementToCompanion(movement));
      }
    });

    return localProduct;
  }

  @override
  Future<ProductEntity> updateProduct(ProductEntity product) async {
    final updated = product.copyWith(updatedAt: DateTime.now());
    await db.into(db.products).insertOnConflictUpdate(_productToCompanion(updated));
    return updated;
  }

  @override
  Future<void> adjustStock(String productId, int change, String reason) async {
    await db.transaction(() async {
      final q = db.select(db.products)..where((t) => t.id.equals(productId));
      final row = await q.getSingleOrNull();

      if (row != null) {
        final prod = _rowToProduct(row);
        final prevQty = prod.stockQuantity;
        final newQty = (prevQty + change).clamp(0, 999999);
        final updated = prod.copyWith(stockQuantity: newQty, updatedAt: DateTime.now());
        await db.into(db.products).insertOnConflictUpdate(_productToCompanion(updated));

        final movement = InventoryMovement(
          id: const Uuid().v4(),
          productId: productId,
          productName: prod.name,
          type: change >= 0 ? 'IN' : 'OUT',
          quantityChange: change,
          previousQuantity: prevQty,
          newQuantity: newQty,
          reason: reason.isNotEmpty ? reason : (change >= 0 ? 'Stock Addition' : 'Stock Reduction'),
          timestamp: DateTime.now(),
        );
        await db.into(db.stockMovements).insertOnConflictUpdate(_movementToCompanion(movement));
      }
    });
  }

  @override
  Future<void> deleteProduct(String id, {bool permanent = false}) async {
    if (permanent) {
      await (db.delete(db.products)..where((t) => t.id.equals(id))).go();
    } else {
      final prod = await getProduct(id);
      final updated = prod.copyWith(isActive: false, updatedAt: DateTime.now());
      await db.into(db.products).insertOnConflictUpdate(_productToCompanion(updated));
    }
  }

  @override
  Future<List<InventoryMovement>> getStockMovements(String productId) async {
    final q = db.select(db.stockMovements)
      ..where((t) => t.productId.equals(productId))
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]);
    final rows = await q.get();
    return rows.map(_rowToMovement).toList();
  }
}
