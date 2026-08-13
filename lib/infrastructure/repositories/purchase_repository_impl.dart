import 'package:uuid/uuid.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import '../storage/hive_service.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final DioClient dioClient;
  final HiveService hiveService;

  PurchaseRepositoryImpl({
    required this.dioClient,
    required this.hiveService,
  });

  SupplierEntity _mapToSupplier(Map<dynamic, dynamic> map) {
    return SupplierEntity(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Supplier',
      companyName: map['companyName']?.toString() ?? map['company']?.toString() ?? 'Company',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      payableBalance: (map['payableBalance'] as num?)?.toDouble() ??
          (map['outstanding_payable'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  PurchaseEntity _mapToPurchase(Map<dynamic, dynamic> map) {
    return PurchaseEntity(
      id: map['id']?.toString() ?? '',
      poNumber: map['poNumber']?.toString() ?? map['invoice_number']?.toString() ?? 'PO-000',
      supplierId: map['supplierId']?.toString() ?? map['supplier_id']?.toString() ?? '',
      supplierName: map['supplierName']?.toString() ?? map['supplier_name']?.toString() ?? 'Supplier',
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? (map['grand_total'] as num?)?.toDouble() ?? 0.0,
      status: map['status']?.toString() ?? 'RECEIVED',
      orderDate: DateTime.tryParse(map['orderDate']?.toString() ?? map['order_date']?.toString() ?? map['purchase_date']?.toString() ?? '') ?? DateTime.now(),
      notes: map['notes']?.toString() ?? '',
    );
  }

  @override
  Future<List<SupplierEntity>> getSuppliers() async {
    final box = hiveService.getBox(HiveService.boxSuppliers);
    final List<SupplierEntity> list = [];
    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        list.add(_mapToSupplier(val));
      }
    }
    return list;
  }

  @override
  Future<SupplierEntity> createSupplier(SupplierEntity supplier) async {
    final box = hiveService.getBox(HiveService.boxSuppliers);
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

    await box.put(id, {
      'id': local.id,
      'name': local.name,
      'companyName': local.companyName,
      'phone': local.phone,
      'email': local.email,
      'address': local.address,
      'payableBalance': local.payableBalance,
      'createdAt': local.createdAt.toIso8601String(),
    });

    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.suppliers,
        data: {
          'name': supplier.name,
          'company': supplier.companyName,
          'phone': supplier.phone,
          'email': supplier.email,
          'address': supplier.address,
        },
      );
      if (response.data != null && response.data['success'] == true) {
        final item = response.data['data'];
        final serverId = item['id']?.toString() ?? id;
        final synced = SupplierEntity(
          id: serverId,
          name: local.name,
          companyName: local.companyName,
          phone: local.phone,
          email: local.email,
          address: local.address,
          payableBalance: local.payableBalance,
          createdAt: local.createdAt,
        );
        if (serverId != id) await box.delete(id);
        await box.put(serverId, {
          'id': synced.id,
          'name': synced.name,
          'companyName': synced.companyName,
          'phone': synced.phone,
          'email': synced.email,
          'address': synced.address,
          'payableBalance': synced.payableBalance,
          'createdAt': synced.createdAt.toIso8601String(),
        });
        return synced;
      }
    } catch (_) {}

    return local;
  }

  @override
  Future<List<PurchaseEntity>> getPurchaseOrders() async {
    final box = hiveService.getBox(HiveService.boxPurchases);
    final List<PurchaseEntity> list = [];
    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        list.add(_mapToPurchase(val));
      }
    }
    list.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return list;
  }

  @override
  Future<PurchaseEntity> createPurchaseOrder(PurchaseEntity purchase) async {
    final box = hiveService.getBox(HiveService.boxPurchases);
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

    await box.put(id, {
      'id': local.id,
      'poNumber': local.poNumber,
      'supplierId': local.supplierId,
      'supplierName': local.supplierName,
      'totalAmount': local.totalAmount,
      'status': local.status,
      'orderDate': local.orderDate.toIso8601String(),
      'notes': local.notes,
    });

    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.purchases,
        data: {
          'supplierId': purchase.supplierId,
          'invoiceNumber': purchase.poNumber,
          'subtotal': purchase.totalAmount,
          'grandTotal': purchase.totalAmount,
          'paidAmount': purchase.totalAmount,
          'paymentMethod': 'Bank Transfer',
          'notes': purchase.notes,
        },
      );
      if (response.data != null && response.data['success'] == true) {
        final item = response.data['data'];
        final serverId = item['id']?.toString() ?? id;
        final synced = PurchaseEntity(
          id: serverId,
          poNumber: item['invoice_number']?.toString() ?? local.poNumber,
          supplierId: local.supplierId,
          supplierName: local.supplierName,
          totalAmount: local.totalAmount,
          status: local.status,
          orderDate: local.orderDate,
          notes: local.notes,
        );
        if (serverId != id) await box.delete(id);
        await box.put(serverId, {
          'id': synced.id,
          'poNumber': synced.poNumber,
          'supplierId': synced.supplierId,
          'supplierName': synced.supplierName,
          'totalAmount': synced.totalAmount,
          'status': synced.status,
          'orderDate': synced.orderDate.toIso8601String(),
          'notes': synced.notes,
        });
        return synced;
      }
    } catch (_) {}

    return local;
  }
}
