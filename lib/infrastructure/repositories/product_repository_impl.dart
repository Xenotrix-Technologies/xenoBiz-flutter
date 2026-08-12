import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import '../storage/hive_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DioClient dioClient;
  final HiveService hiveService;
  final List<ProductEntity> _products = [];
  final List<InventoryMovement> _movements = [];

  ProductRepositoryImpl({
    required this.dioClient,
    required this.hiveService,
  });

  @override
  Future<List<ProductEntity>> getProducts({String? query, String? category}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (query != null && query.isNotEmpty) queryParams['search'] = query;
      if (category != null && category.isNotEmpty && category != 'All') queryParams['category'] = category;

      final response = await dioClient.dio.get(
        ApiEndpoints.products,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data != null && response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        final fetched = list.map((item) {
          return ProductEntity(
            id: item['id'],
            name: item['name'] ?? 'Unnamed',
            sku: item['sku'] ?? 'SKU-000',
            category: item['category'] ?? 'General',
            sellingPrice: (item['selling_price'] as num?)?.toDouble() ?? 0.0,
            purchasePrice: (item['purchase_price'] as num?)?.toDouble() ?? 0.0,
            stockQuantity: (item['current_stock'] as num?)?.toInt() ?? 0,
            reorderLevel: (item['min_stock_level'] as num?)?.toInt() ?? 5,
            unit: item['unit'] ?? 'Pcs',
            createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
          );
        }).toList();

        _products.clear();
        _products.addAll(fetched);
        return fetched;
      }
    } catch (_) {}

    List<ProductEntity> result = List.from(_products);
    if (category != null && category.isNotEmpty && category != 'All') {
      result = result.where((p) => p.category == category).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q);
      }).toList();
    }
    return result;
  }

  @override
  Future<ProductEntity> getProduct(String id) async {
    try {
      final response = await dioClient.dio.get('${ApiEndpoints.products}/$id');
      if (response.data != null && response.data['success'] == true) {
        final item = response.data['data'];
        return ProductEntity(
          id: item['id'],
          name: item['name'] ?? 'Unknown Product',
          sku: item['sku'] ?? 'SKU-000',
          category: item['category'] ?? 'General',
          sellingPrice: (item['selling_price'] as num?)?.toDouble() ?? 0.0,
          purchasePrice: (item['purchase_price'] as num?)?.toDouble() ?? 0.0,
          stockQuantity: (item['current_stock'] as num?)?.toInt() ?? 0,
          reorderLevel: (item['min_stock_level'] as num?)?.toInt() ?? 5,
          unit: item['unit'] ?? 'Pcs',
          createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
        );
      }
    } catch (_) {}

    return _products.firstWhere(
      (p) => p.id == id,
      orElse: () => ProductEntity(
        id: id,
        name: 'Unknown Product',
        sku: 'SKU-000',
        category: 'General',
        sellingPrice: 0.0,
        purchasePrice: 0.0,
        stockQuantity: 0,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<ProductEntity> createProduct(ProductEntity product) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.products,
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
        final item = response.data['data'];
        final created = ProductEntity(
          id: item['id'],
          name: item['name'],
          sku: item['sku'] ?? product.sku,
          category: item['category'] ?? product.category,
          sellingPrice: (item['selling_price'] as num?)?.toDouble() ?? product.sellingPrice,
          purchasePrice: (item['purchase_price'] as num?)?.toDouble() ?? product.purchasePrice,
          stockQuantity: (item['current_stock'] as num?)?.toInt() ?? product.stockQuantity,
          reorderLevel: (item['min_stock_level'] as num?)?.toInt() ?? product.reorderLevel,
          unit: item['unit'] ?? product.unit,
          createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
        );
        _products.insert(0, created);
        return created;
      }
    } catch (_) {}

    _products.insert(0, product);
    return product;
  }

  @override
  Future<ProductEntity> updateProduct(ProductEntity product) async {
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
        final item = response.data['data'];
        final updated = ProductEntity(
          id: item['id'],
          name: item['name'],
          sku: item['sku'] ?? product.sku,
          category: item['category'] ?? product.category,
          sellingPrice: (item['selling_price'] as num?)?.toDouble() ?? product.sellingPrice,
          purchasePrice: (item['purchase_price'] as num?)?.toDouble() ?? product.purchasePrice,
          stockQuantity: (item['current_stock'] as num?)?.toInt() ?? product.stockQuantity,
          reorderLevel: (item['min_stock_level'] as num?)?.toInt() ?? product.reorderLevel,
          unit: item['unit'] ?? product.unit,
          createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
        );
        final idx = _products.indexWhere((p) => p.id == product.id);
        if (idx != -1) _products[idx] = updated;
        return updated;
      }
    } catch (_) {}

    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    } else {
      _products.add(product);
    }
    return product;
  }

  @override
  Future<void> adjustStock(String productId, int change, String reason) async {
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
    } catch (_) {}

    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final oldProd = _products[index];
      final newQty = (oldProd.stockQuantity + change).clamp(0, 999999);
      _products[index] = oldProd.copyWith(stockQuantity: newQty);

      _movements.insert(
        0,
        InventoryMovement(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          productId: productId,
          productName: oldProd.name,
          type: change >= 0 ? 'IN' : 'OUT',
          quantityChange: change,
          reason: reason,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<List<InventoryMovement>> getStockMovements(String productId) async {
    try {
      final response = await dioClient.dio.get(
        '/inventory/movements',
        queryParameters: productId.isNotEmpty ? {'productId': productId} : null,
      );
      if (response.data != null && response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        return list.map((item) {
          final qty = (item['quantity'] as num?)?.toInt() ?? 0;
          return InventoryMovement(
            id: item['id'],
            productId: item['product_id'],
            productName: item['product_name'] ?? 'Product',
            type: qty >= 0 ? 'IN' : 'OUT',
            quantityChange: qty,
            reason: item['reason'] ?? item['movement_type'] ?? 'Stock movement',
            timestamp: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
          );
        }).toList();
      }
    } catch (_) {}

    return _movements.where((m) => m.productId == productId || productId.isEmpty).toList();
  }
}

