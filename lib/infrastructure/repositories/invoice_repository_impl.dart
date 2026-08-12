import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../storage/hive_service.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final HiveService hiveService;
  final List<InvoiceEntity> _invoices = [];
  final List<PaymentEntity> _payments = [];

  InvoiceRepositoryImpl({required this.hiveService});

  @override
  Future<List<InvoiceEntity>> getInvoices({InvoiceStatus? status, String? query}) async {
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
    _payments.insert(0, payment);
    return payment;
  }

  @override
  Future<List<PaymentEntity>> getInvoicePayments(String invoiceId) async {
    return _payments.where((p) => p.invoiceId == invoiceId || invoiceId.isEmpty).toList();
  }
}
