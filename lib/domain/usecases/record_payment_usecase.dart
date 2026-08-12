import '../entities/customer_entity.dart';
import '../entities/invoice_entity.dart';
import '../entities/payment_entity.dart';
import '../entities/sync_item_entity.dart';
import '../repositories/customer_repository.dart';
import '../repositories/invoice_repository.dart';
import '../repositories/sync_repository.dart';

class RecordPaymentUseCase {
  final InvoiceRepository invoiceRepository;
  final CustomerRepository customerRepository;
  final SyncRepository syncRepository;

  RecordPaymentUseCase({
    required this.invoiceRepository,
    required this.customerRepository,
    required this.syncRepository,
  });

  Future<PaymentEntity> execute(PaymentEntity payment) async {
    // 1. Record Payment
    final recordedPayment = await invoiceRepository.recordPayment(payment);

    // 2. Update Invoice Balance & Status
    try {
      final invoice = await invoiceRepository.getInvoice(payment.invoiceId);
      final newPaidAmount = invoice.paidAmount + payment.amount;
      InvoiceStatus newStatus = invoice.status;
      if (newPaidAmount >= invoice.grandTotal) {
        newStatus = InvoiceStatus.paid;
      } else if (newPaidAmount > 0) {
        newStatus = InvoiceStatus.partiallyPaid;
      }
      final updatedInvoice = invoice.copyWith(
        paidAmount: newPaidAmount,
        status: newStatus,
      );
      await invoiceRepository.updateInvoice(updatedInvoice);
    } catch (_) {}

    // 3. Update Customer Outstanding Balance & Timeline
    try {
      final customer = await customerRepository.getCustomer(payment.customerId);
      final updatedCustomer = customer.copyWith(
        outstandingBalance: (customer.outstandingBalance - payment.amount).clamp(0.0, double.infinity),
      );
      await customerRepository.updateCustomer(updatedCustomer);

      await customerRepository.addTimelineEvent(
        CustomerTimelineEvent(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          customerId: payment.customerId,
          title: 'Payment Received',
          description: 'Amount: ₹${payment.amount.toStringAsFixed(2)} via ${payment.paymentMode}',
          eventType: 'PAYMENT',
          amount: payment.amount,
          timestamp: DateTime.now(),
        ),
      );
    } catch (_) {}

    // 4. Enqueue Sync
    await syncRepository.enqueueSyncItem(
      SyncItemEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityType: 'PAYMENT',
        action: SyncAction.create,
        payload: {
          'paymentId': recordedPayment.id,
          'amount': recordedPayment.amount,
        },
        createdAt: DateTime.now(),
      ),
    );

    return recordedPayment;
  }
}
