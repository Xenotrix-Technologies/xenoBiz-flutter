import 'package:uuid/uuid.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../network/dio_client.dart';
import '../network/network_checker.dart';
import '../storage/hive_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DioClient dioClient;
  final HiveService hiveService;
  final NetworkChecker networkChecker;
  final SyncRepository syncRepository;

  ProductRepositoryImpl({
    required this.dioClient,
    required this.hiveService,
    required this.networkChecker,
    required this.syncRepository,
  });

  Map<String, dynamic> _productToMap(ProductEntity p, {String syncStatus = 'synced'}) {
    return {
      'id': p.id,
      'name': p.name,
      'sku': p.sku,
      'barcode': p.barcode,
      'category': p.category,
      'sellingPrice': p.sellingPrice,
      'purchasePrice': p.purchasePrice,
      'stockQuantity': p.stockQuantity,
      'reorderLevel': p.reorderLevel,
      'unit': p.unit,
      'taxPercentage': p.taxPercentage,
      'description': p.description,
      'isActive': p.isActive,
      'createdAt': p.createdAt.toIso8601String(),
      'updatedAt': p.updatedAt?.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }

  ProductEntity _mapToProduct(Map<dynamic, dynamic> map) {
    return ProductEntity(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unnamed Product',
      sku: map['sku']?.toString() ?? 'SKU-000',
      barcode: map['barcode']?.toString() ?? '',
      category: map['category']?.toString() ?? 'General',
      sellingPrice: (map['sellingPrice'] as num?)?.toDouble() ??
          (map['selling_price'] as num?)?.toDouble() ?? 0.0,
      purchasePrice: (map['purchasePrice'] as num?)?.toDouble() ??
          (map['purchase_price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: (map['stockQuantity'] as num?)?.toInt() ??
          (map['current_stock'] as num?)?.toInt() ?? 0,
      reorderLevel: (map['reorderLevel'] as num?)?.toInt() ??
          (map['min_stock_level'] as num?)?.toInt() ?? 5,
      unit: map['unit']?.toString() ?? 'Pcs',
      taxPercentage: (map['taxPercentage'] as num?)?.toDouble(),
      description: map['description']?.toString() ?? '',
      isActive: (map['isActive'] as bool?) ?? true,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? ''),
    );
  }

  InventoryMovement _mapToMovement(Map<dynamic, dynamic> map) {
    return InventoryMovement(
      id: map['id']?.toString() ?? '',
      productId: map['productId']?.toString() ?? '',
      productName: map['productName']?.toString() ?? 'Product',
      type: map['type']?.toString() ?? 'ADJUSTMENT',
      quantityChange: (map['quantityChange'] as num?)?.toInt() ?? 0,
      previousQuantity: (map['previousQuantity'] as num?)?.toInt() ?? 0,
      newQuantity: (map['newQuantity'] as num?)?.toInt() ?? 0,
      reason: map['reason']?.toString() ?? 'Stock Adjustment',
      timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _movementToMap(InventoryMovement m) {
    return {
      'id': m.id,
      'productId': m.productId,
      'productName': m.productName,
      'type': m.type,
      'quantityChange': m.quantityChange,
      'previousQuantity': m.previousQuantity,
      'newQuantity': m.newQuantity,
      'reason': m.reason,
      'timestamp': m.timestamp.toIso8601String(),
    };
  }

  @override
  Future<List<ProductEntity>> getProducts({String? query, String? category}) async {
    final box = hiveService.getBox(HiveService.boxProducts);

    final List<ProductEntity> localProducts = [];
    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        localProducts.add(_mapToProduct(val));
      }
    }

    localProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    List<ProductEntity> filtered = localProducts;
    if (category != null && category.isNotEmpty && category != 'All') {
      filtered = filtered.where((p) => p.category == category).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            p.barcode.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q);
      }).toList();
    }
    return filtered;
  }

  @override
  Future<ProductEntity> getProduct(String id) async {
    final box = hiveService.getBox(HiveService.boxProducts);
    final val = box.get(id);
    if (val is Map) {
      return _mapToProduct(val);
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
    final box = hiveService.getBox(HiveService.boxProducts);
    final String productId = product.id.isNotEmpty ? product.id : const Uuid().v4();
    final localProduct = product.copyWith(id: productId, updatedAt: DateTime.now());

    await box.put(productId, _productToMap(localProduct, syncStatus: 'synced'));

    if (localProduct.stockQuantity > 0) {
      final movementBox = hiveService.getBox(HiveService.boxStockMovements);
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
      await movementBox.put(movement.id, _movementToMap(movement));
    }

    return localProduct;
  }

  @override
  Future<ProductEntity> updateProduct(ProductEntity product) async {
    final box = hiveService.getBox(HiveService.boxProducts);
    final updated = product.copyWith(updatedAt: DateTime.now());
    await box.put(product.id, _productToMap(updated, syncStatus: 'synced'));
    return updated;
  }

  @override
  Future<void> adjustStock(String productId, int change, String reason) async {
    final box = hiveService.getBox(HiveService.boxProducts);
    final val = box.get(productId);

    if (val is Map) {
      final prod = _mapToProduct(val);
      final prevQty = prod.stockQuantity;
      final newQty = (prevQty + change).clamp(0, 999999);
      final updated = prod.copyWith(stockQuantity: newQty, updatedAt: DateTime.now());
      await box.put(productId, _productToMap(updated, syncStatus: 'synced'));

      final movementBox = hiveService.getBox(HiveService.boxStockMovements);
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
      await movementBox.put(movement.id, _movementToMap(movement));
    }
  }

  @override
  Future<void> deleteProduct(String id, {bool permanent = false}) async {
    final box = hiveService.getBox(HiveService.boxProducts);
    if (permanent) {
      await box.delete(id);
    } else {
      final val = box.get(id);
      if (val is Map) {
        final prod = _mapToProduct(val).copyWith(isActive: false, updatedAt: DateTime.now());
        await box.put(id, _productToMap(prod));
      }
    }
  }

  @override
  Future<List<InventoryMovement>> getStockMovements(String productId) async {
    final movementBox = hiveService.getBox(HiveService.boxStockMovements);
    final List<InventoryMovement> movements = [];

    for (var key in movementBox.keys) {
      final val = movementBox.get(key);
      if (val is Map && val['productId'] == productId) {
        movements.add(_mapToMovement(val));
      }
    }

    movements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return movements;
  }
}
