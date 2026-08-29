import '../entities/invoice_entity.dart';
import '../entities/payment_entity.dart';

abstract class InvoiceRepository {
  Future<List<InvoiceEntity>> getInvoices({InvoiceType? type, InvoiceStatus? status, String? query});
  Future<InvoiceEntity> getInvoice(String id);
  Future<InvoiceEntity> createInvoice(InvoiceEntity invoice);
  Future<InvoiceEntity> updateInvoice(InvoiceEntity invoice);
  Future<void> deleteInvoice(String id);
  Future<PaymentEntity> recordPayment(PaymentEntity payment);
  Future<List<PaymentEntity>> getInvoicePayments(String invoiceId);
}
