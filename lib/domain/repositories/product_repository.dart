import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({String? query, String? category});
  Future<ProductEntity> getProduct(String id);
  Future<ProductEntity> createProduct(ProductEntity product);
  Future<ProductEntity> updateProduct(ProductEntity product);
  Future<void> adjustStock(String productId, int change, String reason);
  Future<List<InventoryMovement>> getStockMovements(String productId);
}
