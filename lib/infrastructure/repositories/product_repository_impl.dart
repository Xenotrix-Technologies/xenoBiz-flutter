import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../storage/hive_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final HiveService hiveService;
  final List<ProductEntity> _products = [];
  final List<InventoryMovement> _movements = [];

  ProductRepositoryImpl({required this.hiveService});

  @override
  Future<List<ProductEntity>> getProducts({String? query, String? category}) async {
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
    _products.insert(0, product);
    return product;
  }

  @override
  Future<ProductEntity> updateProduct(ProductEntity product) async {
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
    return _movements.where((m) => m.productId == productId || productId.isEmpty).toList();
  }
}
