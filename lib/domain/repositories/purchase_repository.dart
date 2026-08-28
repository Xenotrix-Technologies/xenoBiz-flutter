import '../entities/purchase_entity.dart';

abstract class PurchaseRepository {
  Future<List<SupplierEntity>> getSuppliers();
  Future<SupplierEntity> createSupplier(SupplierEntity supplier);
  Future<SupplierEntity> updateSupplier(SupplierEntity supplier);
  Future<void> deleteSupplier(String supplierId);
  Future<List<PurchaseEntity>> getPurchaseOrders();
  Future<PurchaseEntity> createPurchaseOrder(PurchaseEntity purchase);
}

