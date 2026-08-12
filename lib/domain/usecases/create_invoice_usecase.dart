import '../entities/customer_entity.dart';
import '../entities/invoice_entity.dart';
import '../entities/sync_item_entity.dart';
import '../repositories/customer_repository.dart';
import '../repositories/invoice_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/sync_repository.dart';

class CreateInvoiceUseCase {
  final InvoiceRepository invoiceRepository;
  final CustomerRepository customerRepository;
  final ProductRepository productRepository;
  final SyncRepository syncRepository;

  CreateInvoiceUseCase({
    required this.invoiceRepository,
    required this.customerRepository,
    required this.productRepository,
    required this.syncRepository,
  });

  Future<InvoiceEntity> execute(InvoiceEntity invoice) async {
    // 1. Create Invoice
    final createdInvoice = await invoiceRepository.createInvoice(invoice);

    // 2. Reduce Stock for each item
    for (final item in invoice.items) {
      await productRepository.adjustStock(
        item.productId,
        -item.quantity,
        'Invoice #${invoice.invoiceNumber}',
      );
    }

    // 3. Update Customer Outstanding & Timeline
    try {
      final customer = await customerRepository.getCustomer(invoice.customerId);
      final updatedCustomer = customer.copyWith(
        outstandingBalance: customer.outstandingBalance + invoice.dueAmount,
        totalPurchases: customer.totalPurchases + invoice.grandTotal,
      );
      await customerRepository.updateCustomer(updatedCustomer);

      await customerRepository.addTimelineEvent(
        CustomerTimelineEvent(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          customerId: invoice.customerId,
          title: 'Invoice #${invoice.invoiceNumber} Generated',
          description: 'Grand total: ₹${invoice.grandTotal.toStringAsFixed(2)}',
          eventType: 'INVOICE',
          amount: invoice.grandTotal,
          timestamp: DateTime.now(),
        ),
      );
    } catch (_) {
      // Graceful fallback if customer fetch fails locally
    }

    // 4. Enqueue Sync Item
    await syncRepository.enqueueSyncItem(
      SyncItemEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityType: 'INVOICE',
        action: SyncAction.create,
        payload: {
          'invoiceId': createdInvoice.id,
          'invoiceNumber': createdInvoice.invoiceNumber,
          'grandTotal': createdInvoice.grandTotal,
        },
        createdAt: DateTime.now(),
      ),
    );

    return createdInvoice;
  }
}
