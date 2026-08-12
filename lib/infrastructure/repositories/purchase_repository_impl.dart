import '../../domain/entities/purchase_entity.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../storage/hive_service.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final HiveService hiveService;
  final List<SupplierEntity> _suppliers = [];
  final List<PurchaseEntity> _purchases = [];

  PurchaseRepositoryImpl({required this.hiveService});

  @override
  Future<List<SupplierEntity>> getSuppliers() async {
    return List.unmodifiable(_suppliers);
  }

  @override
  Future<SupplierEntity> createSupplier(SupplierEntity supplier) async {
    _suppliers.insert(0, supplier);
    return supplier;
  }

  @override
  Future<List<PurchaseEntity>> getPurchaseOrders() async {
    return List.unmodifiable(_purchases);
  }

  @override
  Future<PurchaseEntity> createPurchaseOrder(PurchaseEntity purchase) async {
    _purchases.insert(0, purchase);
    return purchase;
  }
}
