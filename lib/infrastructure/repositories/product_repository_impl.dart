import 'package:uuid/uuid.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/sync_item_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../network/api_endpoints.dart';
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
      'category': p.category,
      'sellingPrice': p.sellingPrice,
      'purchasePrice': p.purchasePrice,
      'stockQuantity': p.stockQuantity,
      'reorderLevel': p.reorderLevel,
      'unit': p.unit,
      'createdAt': p.createdAt.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }

  ProductEntity _mapToProduct(Map<dynamic, dynamic> map) {
    return ProductEntity(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unnamed Product',
      sku: map['sku']?.toString() ?? 'SKU-000',
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
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
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
    final localProduct = product.copyWith(id: productId);

    // 1. Write to Hive immediately
    await box.put(productId, _productToMap(localProduct, syncStatus: 'pendingCreate'));

    // 2. Sync if online
    if (await networkChecker.isConnected) {
      try {
        final response = await dioClient.dio.post(
          ApiEndpoints.products,
          data: {
            'name': localProduct.name,
            'sku': localProduct.sku,
            'category': localProduct.category,
            'sellingPrice': localProduct.sellingPrice,
            'purchasePrice': localProduct.purchasePrice,
            'currentStock': localProduct.stockQuantity,
            'minStockLevel': localProduct.reorderLevel,
            'unit': localProduct.unit,
          },
        );

        if (response.data != null && response.data['success'] == true) {
          final item = response.data['data'];
          final serverId = item['id']?.toString() ?? productId;
          final syncedProduct = localProduct.copyWith(id: serverId);

          if (serverId != productId) {
            await box.delete(productId);
          }
          await box.put(serverId, _productToMap(syncedProduct, syncStatus: 'synced'));
          return syncedProduct;
        }
      } catch (_) {}
    }

    // 3. Enqueue if offline or request failed
    await syncRepository.enqueueSyncItem(
      SyncItemEntity(
        id: const Uuid().v4(),
        entityType: 'PRODUCT',
        action: SyncAction.create,
        payload: {
          'localId': productId,
          'name': localProduct.name,
          'sku': localProduct.sku,
          'category': localProduct.category,
          'sellingPrice': localProduct.sellingPrice,
          'purchasePrice': localProduct.purchasePrice,
          'currentStock': localProduct.stockQuantity,
          'minStockLevel': localProduct.reorderLevel,
          'unit': localProduct.unit,
        },
        createdAt: DateTime.now(),
      ),
    );

    return localProduct;
  }

  @override
  Future<ProductEntity> updateProduct(ProductEntity product) async {
    final box = hiveService.getBox(HiveService.boxProducts);

    // 1. Update Hive
    await box.put(product.id, _productToMap(product, syncStatus: 'pendingUpdate'));

    // 2. Sync if online
    if (await networkChecker.isConnected) {
      try {
        final response = await dioClient.dio.put(
          '${ApiEndpoints.products}/${product.id}',
          data: {
            'name': product.name,
            'sku': product.sku,
            'category': product.category,
            'sellingPrice': product.sellingPrice,
            'purchasePrice': product.purchasePrice,
            'currentStock': product.stockQuantity,
            'minStockLevel': product.reorderLevel,
            'unit': product.unit,
          },
        );

        if (response.data != null && response.data['success'] == true) {
          await box.put(product.id, _productToMap(product, syncStatus: 'synced'));
          return product;
        }
      } catch (_) {}
    }

    // 3. Enqueue sync item
    await syncRepository.enqueueSyncItem(
      SyncItemEntity(
        id: const Uuid().v4(),
        entityType: 'PRODUCT',
        action: SyncAction.update,
        payload: {
          'id': product.id,
          'name': product.name,
          'sku': product.sku,
          'category': product.category,
          'sellingPrice': product.sellingPrice,
          'purchasePrice': product.purchasePrice,
          'currentStock': product.stockQuantity,
          'minStockLevel': product.reorderLevel,
          'unit': product.unit,
        },
        createdAt: DateTime.now(),
      ),
    );

    return product;
  }

  @override
  Future<void> adjustStock(String productId, int change, String reason) async {
    final box = hiveService.getBox(HiveService.boxProducts);
    final val = box.get(productId);

    if (val is Map) {
      final prod = _mapToProduct(val);
      final newQty = (prod.stockQuantity + change).clamp(0, 999999);
      final updated = prod.copyWith(stockQuantity: newQty);
      await box.put(productId, _productToMap(updated, syncStatus: 'pendingUpdate'));
    }

    if (await networkChecker.isConnected) {
      try {
        await dioClient.dio.post(
          '/inventory/adjust',
          data: {
            'productId': productId,
            'quantityDelta': change,
            'movementType': change >= 0 ? 'Manual Adjustment' : 'Damaged',
            'reason': reason,
          },
        );
        return;
      } catch (_) {}
    }

    await syncRepository.enqueueSyncItem(
      SyncItemEntity(
        id: const Uuid().v4(),
        entityType: 'INVENTORY_ADJUST',
        action: SyncAction.update,
        payload: {
          'productId': productId,
          'quantityDelta': change,
          'reason': reason,
        },
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<InventoryMovement>> getStockMovements(String productId) async {
    return [];
  }
}
