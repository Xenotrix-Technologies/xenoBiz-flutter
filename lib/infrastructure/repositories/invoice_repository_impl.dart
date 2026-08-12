import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import '../storage/hive_service.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final DioClient dioClient;
  final HiveService hiveService;
  final List<InvoiceEntity> _invoices = [];
  final List<PaymentEntity> _payments = [];

  InvoiceRepositoryImpl({
    required this.dioClient,
    required this.hiveService,
  });

  InvoiceStatus _parseStatus(String? statusStr) {
    if (statusStr == 'paid') return InvoiceStatus.paid;
    if (statusStr == 'partially_paid') return InvoiceStatus.partiallyPaid;
    if (statusStr == 'cancelled') return InvoiceStatus.cancelled;
    if (statusStr == 'draft') return InvoiceStatus.draft;
    return InvoiceStatus.unpaid;
  }

  @override
  Future<List<InvoiceEntity>> getInvoices({InvoiceStatus? status, String? query}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (query != null && query.isNotEmpty) queryParams['search'] = query;

      final response = await dioClient.dio.get(
        ApiEndpoints.invoices,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data != null && response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        final fetched = list.map((item) {
          final List rawItems = item['items'] ?? [];
          final invoiceItems = rawItems.map((itm) {
            return InvoiceItemEntity(
              productId: itm['product_id'] ?? '',
              productName: itm['product_name'] ?? 'Item',
              quantity: (itm['quantity'] as num?)?.toInt() ?? 1,
              unitPrice: (itm['unit_price'] as num?)?.toDouble() ?? 0.0,
              taxPercentage: (itm['tax_percentage'] as num?)?.toDouble() ?? 0.0,
            );
          }).toList();

          return InvoiceEntity(
            id: item['id'],
            invoiceNumber: item['invoice_number'] ?? 'INV-000',
            customerId: item['customer_id'] ?? '',
            customerName: item['customer_name'] ?? 'Guest Customer',
            customerPhone: item['customer_phone'] ?? '',
            items: invoiceItems,
            subtotal: (item['subtotal'] as num?)?.toDouble() ?? 0.0,
            taxTotal: (item['tax_total'] as num?)?.toDouble() ?? 0.0,
            discountTotal: (item['discount_total'] as num?)?.toDouble() ?? 0.0,
            grandTotal: (item['grand_total'] as num?)?.toDouble() ?? 0.0,
            paidAmount: (item['paid_amount'] as num?)?.toDouble() ?? 0.0,
            status: _parseStatus(item['payment_status'] ?? item['status']),
            issueDate: DateTime.tryParse(item['issue_date'] ?? '') ?? DateTime.now(),
            dueDate: DateTime.tryParse(item['due_date'] ?? '') ?? DateTime.now(),
            notes: item['notes'] ?? '',
          );
        }).toList();

        _invoices.clear();
        _invoices.addAll(fetched);

        List<InvoiceEntity> filtered = List.from(fetched);
        if (status != null) {
          filtered = filtered.where((i) => i.status == status).toList();
        }
        return filtered;
      }
    } catch (_) {}

    List<InvoiceEntity> list = List.from(_invoices);
    if (status != null) {
      list = list.where((i) => i.status == status).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((i) {
        return i.invoiceNumber.toLowerCase().contains(q) ||
            i.customerName.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  @override
  Future<InvoiceEntity> getInvoice(String id) async {
    try {
      final response = await dioClient.dio.get('${ApiEndpoints.invoices}/$id');
      if (response.data != null && response.data['success'] == true) {
        final item = response.data['data'];
        final List rawItems = item['items'] ?? [];
        final invoiceItems = rawItems.map((itm) {
          return InvoiceItemEntity(
            productId: itm['product_id'] ?? '',
            productName: itm['product_name'] ?? 'Item',
            quantity: (itm['quantity'] as num?)?.toInt() ?? 1,
            unitPrice: (itm['unit_price'] as num?)?.toDouble() ?? 0.0,
            taxPercentage: (itm['tax_percentage'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();

        return InvoiceEntity(
          id: item['id'],
          invoiceNumber: item['invoice_number'] ?? 'INV-000',
          customerId: item['customer_id'] ?? '',
          customerName: item['customer_name'] ?? 'Guest Customer',
          customerPhone: item['customer_phone'] ?? '',
          items: invoiceItems,
          subtotal: (item['subtotal'] as num?)?.toDouble() ?? 0.0,
          taxTotal: (item['tax_total'] as num?)?.toDouble() ?? 0.0,
          discountTotal: (item['discount_total'] as num?)?.toDouble() ?? 0.0,
          grandTotal: (item['grand_total'] as num?)?.toDouble() ?? 0.0,
          paidAmount: (item['paid_amount'] as num?)?.toDouble() ?? 0.0,
          status: _parseStatus(item['payment_status'] ?? item['status']),
          issueDate: DateTime.tryParse(item['issue_date'] ?? '') ?? DateTime.now(),
          dueDate: DateTime.tryParse(item['due_date'] ?? '') ?? DateTime.now(),
          notes: item['notes'] ?? '',
        );
      }
    } catch (_) {}

    return _invoices.firstWhere(
      (i) => i.id == id,
      orElse: () => InvoiceEntity(
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
      ),
    );
  }

  @override
  Future<InvoiceEntity> createInvoice(InvoiceEntity invoice) async {
    try {
      final itemsPayload = invoice.items.map((itm) {
        return {
          'productId': itm.productId,
          'productName': itm.productName,
          'quantity': itm.quantity,
          'unitPrice': itm.unitPrice,
          'taxPercentage': itm.taxPercentage,
        };
      }).toList();

      final response = await dioClient.dio.post(
        ApiEndpoints.invoices,
        data: {
          'customerId': invoice.customerId,
          'customerName': invoice.customerName,
          'customerPhone': invoice.customerPhone,
          'items': itemsPayload,
          'subtotal': invoice.subtotal,
          'taxTotal': invoice.taxTotal,
          'discountTotal': invoice.discountTotal,
          'grandTotal': invoice.grandTotal,
          'paidAmount': invoice.paidAmount,
          'paymentMethod': invoice.paidAmount > 0 ? 'Cash' : null,
          'dueDate': invoice.dueDate.toIso8601String(),
          'notes': invoice.notes,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final item = response.data['data'];
        final created = invoice.copyWith(id: item['id'], invoiceNumber: item['invoice_number']);
        _invoices.insert(0, created);
        return created;
      }
    } catch (_) {}

    _invoices.insert(0, invoice);
    return invoice;
  }

  @override
  Future<InvoiceEntity> updateInvoice(InvoiceEntity invoice) async {
    final index = _invoices.indexWhere((i) => i.id == invoice.id);
    if (index != -1) {
      _invoices[index] = invoice;
    } else {
      _invoices.add(invoice);
    }
    return invoice;
  }

  @override
  Future<PaymentEntity> recordPayment(PaymentEntity payment) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.payments,
        data: {
          'invoiceId': payment.invoiceId,
          'customerId': payment.customerId,
          'amount': payment.amount,
          'paymentMethod': payment.paymentMode,
          'paymentType': 'IN',
          'notes': payment.notes,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final item = response.data['data'];
        final created = PaymentEntity(
          id: item['id'],
          invoiceId: payment.invoiceId,
          customerId: payment.customerId,
          customerName: payment.customerName,
          amount: (item['amount'] as num?)?.toDouble() ?? payment.amount,
          paymentMode: payment.paymentMode,
          paymentDate: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
          notes: payment.notes,
        );
        _payments.insert(0, created);
        return created;
      }
    } catch (_) {}

    _payments.insert(0, payment);
    return payment;
  }

  @override
  Future<List<PaymentEntity>> getInvoicePayments(String invoiceId) async {
    try {
      final response = await dioClient.dio.get(
        ApiEndpoints.payments,
        queryParameters: invoiceId.isNotEmpty ? {'invoiceId': invoiceId} : null,
      );
      if (response.data != null && response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        return list.map((item) {
          return PaymentEntity(
            id: item['id'],
            invoiceId: item['invoice_id'] ?? '',
            customerId: item['customer_id'] ?? '',
            customerName: item['customer_name'] ?? 'Customer',
            amount: (item['amount'] as num?)?.toDouble() ?? 0.0,
            paymentMode: item['payment_method'] ?? 'CASH',
            paymentDate: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
            notes: item['notes'] ?? '',
          );
        }).toList();
      }
    } catch (_) {}

    return _payments.where((p) => p.invoiceId == invoiceId || invoiceId.isEmpty).toList();
  }
}

