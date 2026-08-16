import 'package:uuid/uuid.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../network/dio_client.dart';
import '../network/network_checker.dart';
import '../storage/hive_service.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final DioClient dioClient;
  final HiveService hiveService;
  final NetworkChecker networkChecker;
  final SyncRepository syncRepository;

  InvoiceRepositoryImpl({
    required this.dioClient,
    required this.hiveService,
    required this.networkChecker,
    required this.syncRepository,
  });

  InvoiceStatus _parseStatus(String? statusStr) {
    if (statusStr == 'paid' || statusStr == 'InvoiceStatus.paid') return InvoiceStatus.paid;
    if (statusStr == 'partiallyPaid' || statusStr == 'partially_paid' || statusStr == 'InvoiceStatus.partiallyPaid') {
      return InvoiceStatus.partiallyPaid;
    }
    if (statusStr == 'cancelled' || statusStr == 'InvoiceStatus.cancelled') return InvoiceStatus.cancelled;
    if (statusStr == 'draft' || statusStr == 'InvoiceStatus.draft') return InvoiceStatus.draft;
    return InvoiceStatus.unpaid;
  }

  Map<String, dynamic> _invoiceToMap(InvoiceEntity inv, {String syncStatus = 'synced'}) {
    return {
      'id': inv.id,
      'invoiceNumber': inv.invoiceNumber,
      'customerId': inv.customerId,
      'customerName': inv.customerName,
      'customerPhone': inv.customerPhone,
      'items': inv.items.map((i) => {
        'productId': i.productId,
        'productName': i.productName,
        'quantity': i.quantity,
        'unitPrice': i.unitPrice,
        'taxPercentage': i.taxPercentage,
      }).toList(),
      'subtotal': inv.subtotal,
      'taxTotal': inv.taxTotal,
      'discountTotal': inv.discountTotal,
      'grandTotal': inv.grandTotal,
      'paidAmount': inv.paidAmount,
      'status': inv.status.name,
      'issueDate': inv.issueDate.toIso8601String(),
      'dueDate': inv.dueDate.toIso8601String(),
      'notes': inv.notes,
      'syncStatus': syncStatus,
    };
  }

  InvoiceEntity _mapToInvoice(Map<dynamic, dynamic> map) {
    final List rawItems = map['items'] is List ? map['items'] : [];
    final items = rawItems.map((itm) {
      if (itm is Map) {
        return InvoiceItemEntity(
          productId: itm['productId']?.toString() ?? itm['product_id']?.toString() ?? '',
          productName: itm['productName']?.toString() ?? itm['product_name']?.toString() ?? 'Item',
          quantity: (itm['quantity'] as num?)?.toInt() ?? 1,
          unitPrice: (itm['unitPrice'] as num?)?.toDouble() ??
              (itm['unit_price'] as num?)?.toDouble() ?? 0.0,
          taxPercentage: (itm['taxPercentage'] as num?)?.toDouble() ??
              (itm['tax_percentage'] as num?)?.toDouble() ?? 0.0,
        );
      }
      return const InvoiceItemEntity(productId: '', productName: '', quantity: 1, unitPrice: 0.0);
    }).toList();

    return InvoiceEntity(
      id: map['id']?.toString() ?? '',
      invoiceNumber: map['invoiceNumber']?.toString() ?? map['invoice_number']?.toString() ?? 'INV-000',
      customerId: map['customerId']?.toString() ?? map['customer_id']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? map['customer_name']?.toString() ?? 'Guest Customer',
      customerPhone: map['customerPhone']?.toString() ?? map['customer_phone']?.toString() ?? '',
      items: items,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxTotal: (map['taxTotal'] as num?)?.toDouble() ?? (map['tax_total'] as num?)?.toDouble() ?? 0.0,
      discountTotal: (map['discountTotal'] as num?)?.toDouble() ?? (map['discount_total'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (map['grandTotal'] as num?)?.toDouble() ?? (map['grand_total'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (map['paidAmount'] as num?)?.toDouble() ?? (map['paid_amount'] as num?)?.toDouble() ?? 0.0,
      status: _parseStatus(map['status']?.toString() ?? map['payment_status']?.toString()),
      issueDate: DateTime.tryParse(map['issueDate']?.toString() ?? map['issue_date']?.toString() ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(map['dueDate']?.toString() ?? map['due_date']?.toString() ?? '') ?? DateTime.now(),
      notes: map['notes']?.toString() ?? '',
    );
  }

  PaymentEntity _mapToPayment(Map<dynamic, dynamic> map) {
    return PaymentEntity(
      id: map['id']?.toString() ?? '',
      invoiceId: map['invoiceId']?.toString() ?? map['invoice_id']?.toString() ?? '',
      customerId: map['customerId']?.toString() ?? map['customer_id']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? map['customer_name']?.toString() ?? 'Customer',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMode: map['paymentMode']?.toString() ?? map['payment_method']?.toString() ?? 'Cash',
      paymentDate: DateTime.tryParse(map['paymentDate']?.toString() ?? map['payment_date']?.toString() ?? map['created_at']?.toString() ?? '') ?? DateTime.now(),
      notes: map['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> _paymentToMap(PaymentEntity p, {String syncStatus = 'synced'}) {
    return {
      'id': p.id,
      'invoiceId': p.invoiceId,
      'customerId': p.customerId,
      'customerName': p.customerName,
      'amount': p.amount,
      'paymentMode': p.paymentMode,
      'paymentDate': p.paymentDate.toIso8601String(),
      'notes': p.notes,
      'syncStatus': syncStatus,
    };
  }

  @override
  Future<List<InvoiceEntity>> getInvoices({InvoiceStatus? status, String? query}) async {
    final box = hiveService.getBox(HiveService.boxInvoices);
    final List<InvoiceEntity> localInvoices = [];

    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        localInvoices.add(_mapToInvoice(val));
      }
    }

    localInvoices.sort((a, b) => b.issueDate.compareTo(a.issueDate));

    List<InvoiceEntity> filtered = localInvoices;
    if (status != null) {
      filtered = filtered.where((i) => i.status == status).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered.where((i) {
        return i.invoiceNumber.toLowerCase().contains(q) ||
            i.customerName.toLowerCase().contains(q);
      }).toList();
    }
    return filtered;
  }

  @override
  Future<InvoiceEntity> getInvoice(String id) async {
    final box = hiveService.getBox(HiveService.boxInvoices);
    final val = box.get(id);
    if (val is Map) {
      return _mapToInvoice(val);
    }
    return InvoiceEntity(
      id: id,
      invoiceNumber: 'INV-000',
      customerId: '',
      customerName: 'Unknown',
      customerPhone: '',
      items: const [],
      subtotal: 0.0,
      taxTotal: 0.0,
      grandTotal: 0.0,
      paidAmount: 0.0,
      status: InvoiceStatus.unpaid,
      issueDate: DateTime.now(),
      dueDate: DateTime.now(),
    );
  }

  @override
  Future<InvoiceEntity> createInvoice(InvoiceEntity invoice) async {
    final box = hiveService.getBox(HiveService.boxInvoices);
    final String invId = invoice.id.isNotEmpty ? invoice.id : const Uuid().v4();
    final String invNum = invoice.invoiceNumber.isNotEmpty && invoice.invoiceNumber != 'INV-000'
        ? invoice.invoiceNumber
        : 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final localInvoice = invoice.copyWith(id: invId, invoiceNumber: invNum);

    // Save directly to Hive local storage (single source of truth)
    await box.put(invId, _invoiceToMap(localInvoice, syncStatus: 'synced'));
    return localInvoice;
  }

  @override
  Future<InvoiceEntity> updateInvoice(InvoiceEntity invoice) async {
    final box = hiveService.getBox(HiveService.boxInvoices);
    await box.put(invoice.id, _invoiceToMap(invoice, syncStatus: 'synced'));
    return invoice;
  }

  @override
  Future<PaymentEntity> recordPayment(PaymentEntity payment) async {
    final box = hiveService.getBox(HiveService.boxPayments);
    final String payId = payment.id.isNotEmpty ? payment.id : const Uuid().v4();
    final localPayment = PaymentEntity(
      id: payId,
      invoiceId: payment.invoiceId,
      customerId: payment.customerId,
      customerName: payment.customerName,
      amount: payment.amount,
      paymentMode: payment.paymentMode,
      paymentDate: payment.paymentDate,
      notes: payment.notes,
    );

    // Save directly to Hive local storage (single source of truth)
    await box.put(payId, _paymentToMap(localPayment, syncStatus: 'synced'));
    return localPayment;
  }

  @override
  Future<List<PaymentEntity>> getInvoicePayments(String invoiceId) async {
    final box = hiveService.getBox(HiveService.boxPayments);
    final List<PaymentEntity> list = [];
    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        final p = _mapToPayment(val);
        if (invoiceId.isEmpty || p.invoiceId == invoiceId) {
          list.add(p);
        }
      }
    }
    list.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    return list;
  }
}
