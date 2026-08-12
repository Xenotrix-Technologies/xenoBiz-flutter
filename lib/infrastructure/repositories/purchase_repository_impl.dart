import '../../domain/entities/purchase_entity.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import '../storage/hive_service.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final DioClient dioClient;
  final HiveService hiveService;
  final List<SupplierEntity> _suppliers = [];
  final List<PurchaseEntity> _purchases = [];

  PurchaseRepositoryImpl({
    required this.dioClient,
    required this.hiveService,
  });

  @override
  Future<List<SupplierEntity>> getSuppliers() async {
    try {
      final response = await dioClient.dio.get(ApiEndpoints.suppliers);
      if (response.data != null && response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        final fetched = list.map((item) {
          return SupplierEntity(
            id: item['id'],
            name: item['name'] ?? 'Supplier',
            companyName: item['company'] ?? item['name'] ?? 'Company',
            phone: item['phone'] ?? '',
            email: item['email'] ?? '',
            address: item['address'] ?? '',
            payableBalance: (item['outstanding_payable'] as num?)?.toDouble() ?? 0.0,
            createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
          );
        }).toList();

        _suppliers.clear();
        _suppliers.addAll(fetched);
        return fetched;
      }
    } catch (_) {}

    return List.unmodifiable(_suppliers);
  }

  @override
  Future<SupplierEntity> createSupplier(SupplierEntity supplier) async {
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
        final created = SupplierEntity(
          id: item['id'],
          name: item['name'],
          companyName: item['company'] ?? supplier.companyName,
          phone: item['phone'] ?? '',
          email: item['email'] ?? '',
          address: item['address'] ?? '',
          payableBalance: (item['outstanding_payable'] as num?)?.toDouble() ?? 0.0,
          createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
        );
        _suppliers.insert(0, created);
        return created;
      }
    } catch (_) {}

    _suppliers.insert(0, supplier);
    return supplier;
  }

  @override
  Future<List<PurchaseEntity>> getPurchaseOrders() async {
    try {
      final response = await dioClient.dio.get(ApiEndpoints.purchases);
      if (response.data != null && response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        final fetched = list.map((item) {
          return PurchaseEntity(
            id: item['id'],
            poNumber: item['invoice_number'] ?? 'PO-000',
            supplierId: item['supplier_id'] ?? '',
            supplierName: item['supplier_name'] ?? 'Supplier',
            totalAmount: (item['grand_total'] as num?)?.toDouble() ?? 0.0,
            status: (item['payment_status'] ?? 'COMPLETED').toString().toUpperCase(),
            orderDate: DateTime.tryParse(item['purchase_date'] ?? '') ?? DateTime.now(),
            notes: item['notes'] ?? '',
          );
        }).toList();

        _purchases.clear();
        _purchases.addAll(fetched);
        return fetched;
      }
    } catch (_) {}

    return List.unmodifiable(_purchases);
  }

  @override
  Future<PurchaseEntity> createPurchaseOrder(PurchaseEntity purchase) async {
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
        final created = PurchaseEntity(
          id: item['id'],
          poNumber: item['invoice_number'] ?? purchase.poNumber,
          supplierId: purchase.supplierId,
          supplierName: purchase.supplierName,
          totalAmount: purchase.totalAmount,
          status: 'COMPLETED',
          orderDate: DateTime.now(),
          notes: purchase.notes,
        );
        _purchases.insert(0, created);
        return created;
      }
    } catch (_) {}

    _purchases.insert(0, purchase);
    return purchase;
  }
}

