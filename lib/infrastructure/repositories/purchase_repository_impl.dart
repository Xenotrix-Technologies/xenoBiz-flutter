import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../database/app_database.dart';
import '../network/dio_client.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final DioClient dioClient;
  final AppDatabase db;

  PurchaseRepositoryImpl({
    required this.dioClient,
    required this.db,
  });

  SupplierEntity _rowToSupplier(Supplier row) {
    return SupplierEntity(
      id: row.id,
      name: row.name,
      companyName: row.companyName,
      phone: row.phone,
      email: row.email,
      address: row.address,
      payableBalance: row.payableBalance,
      createdAt: row.createdAt,
    );
  }

  SuppliersCompanion _supplierToCompanion(SupplierEntity s) {
    return SuppliersCompanion(
      id: Value(s.id),
      name: Value(s.name),
      companyName: Value(s.companyName),
      phone: Value(s.phone),
      email: Value(s.email),
      address: Value(s.address),
      payableBalance: Value(s.payableBalance),
      createdAt: Value(s.createdAt),
    );
  }

  PurchaseEntity _rowToPurchase(Purchase row) {
    return PurchaseEntity(
      id: row.id,
      poNumber: row.poNumber,
      supplierId: row.supplierId,
      supplierName: row.supplierName,
      totalAmount: row.totalAmount,
      status: row.status,
      orderDate: row.orderDate,
      notes: row.notes,
    );
  }

  PurchasesCompanion _purchaseToCompanion(PurchaseEntity p) {
    return PurchasesCompanion(
      id: Value(p.id),
      poNumber: Value(p.poNumber),
      supplierId: Value(p.supplierId),
      supplierName: Value(p.supplierName),
      totalAmount: Value(p.totalAmount),
      status: Value(p.status),
      orderDate: Value(p.orderDate),
      notes: Value(p.notes),
    );
  }

  @override
  Future<List<SupplierEntity>> getSuppliers() async {
    final rows = await db.select(db.suppliers).get();
    return rows.map(_rowToSupplier).toList();
  }

  @override
  Future<SupplierEntity> createSupplier(SupplierEntity supplier) async {
    final String id = supplier.id.isNotEmpty ? supplier.id : const Uuid().v4();
    final local = SupplierEntity(
      id: id,
      name: supplier.name,
      companyName: supplier.companyName,
      phone: supplier.phone,
      email: supplier.email,
      address: supplier.address,
      payableBalance: supplier.payableBalance,
      createdAt: supplier.createdAt,
    );

    await db.into(db.suppliers).insertOnConflictUpdate(_supplierToCompanion(local));
    return local;
  }

  @override
  Future<SupplierEntity> updateSupplier(SupplierEntity supplier) async {
    await db.into(db.suppliers).insertOnConflictUpdate(_supplierToCompanion(supplier));
    return supplier;
  }

  @override
  Future<List<PurchaseEntity>> getPurchaseOrders() async {
    final q = db.select(db.purchases)..orderBy([(t) => OrderingTerm.desc(t.orderDate)]);
    final rows = await q.get();
    return rows.map(_rowToPurchase).toList();
  }

  @override
  Future<PurchaseEntity> createPurchaseOrder(PurchaseEntity purchase) async {
    final String id = purchase.id.isNotEmpty ? purchase.id : const Uuid().v4();
    final local = PurchaseEntity(
      id: id,
      poNumber: purchase.poNumber,
      supplierId: purchase.supplierId,
      supplierName: purchase.supplierName,
      totalAmount: purchase.totalAmount,
      status: purchase.status,
      orderDate: purchase.orderDate,
      notes: purchase.notes,
    );

    await db.transaction(() async {
      await db.into(db.purchases).insertOnConflictUpdate(_purchaseToCompanion(local));

      final supKey = local.supplierId.isNotEmpty ? local.supplierId : 'sup_${local.supplierName.toLowerCase().replaceAll(' ', '_')}';
      final existingSupRow = await (db.select(db.suppliers)..where((t) => t.id.equals(supKey))).getSingleOrNull();

      if (existingSupRow != null) {
        final currentPayable = existingSupRow.payableBalance;
        final updatedPayable = currentPayable + local.totalAmount;
        await (db.update(db.suppliers)..where((t) => t.id.equals(supKey)))
            .write(SuppliersCompanion(payableBalance: Value(updatedPayable)));
      } else {
        await db.into(db.suppliers).insertOnConflictUpdate(
          SuppliersCompanion(
            id: Value(supKey),
            name: Value(local.supplierName),
            companyName: Value(local.supplierName),
            phone: const Value(''),
            email: const Value(''),
            address: const Value(''),
            payableBalance: Value(local.totalAmount),
            createdAt: Value(DateTime.now()),
          ),
        );
      }
    });

    return local;
  }
}
