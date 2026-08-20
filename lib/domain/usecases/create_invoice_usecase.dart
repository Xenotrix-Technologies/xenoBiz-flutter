import '../entities/customer_entity.dart';
import '../entities/invoice_entity.dart';
import '../repositories/customer_repository.dart';
import '../repositories/invoice_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/purchase_repository.dart';
import '../repositories/sync_repository.dart';

class CreateInvoiceUseCase {
  final InvoiceRepository invoiceRepository;
  final CustomerRepository customerRepository;
  final ProductRepository productRepository;
  final PurchaseRepository purchaseRepository;
  final SyncRepository syncRepository;

  CreateInvoiceUseCase({
    required this.invoiceRepository,
    required this.customerRepository,
    required this.productRepository,
    required this.purchaseRepository,
    required this.syncRepository,
  });

  Future<InvoiceEntity> execute(InvoiceEntity invoice) async {
    // 1. Create Invoice
    final createdInvoice = await invoiceRepository.createInvoice(invoice);

    // 2. Adjust Stock for each item (Sale = -qty, Purchase = +qty)
    for (final item in invoice.items) {
      final delta = invoice.isPurchase ? item.quantity : -item.quantity;
      final label = invoice.isPurchase
          ? 'Purchase Invoice #${invoice.invoiceNumber}'
          : 'Sale Invoice #${invoice.invoiceNumber}';

      await productRepository.adjustStock(
        item.productId,
        delta,
        label,
      );
    }

    // 3. Update Account Outstanding / Payable & Timeline
    if (invoice.isSale) {
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
      } catch (_) {}
    } else {
      try {
        final suppliers = await purchaseRepository.getSuppliers();
        final matches = suppliers.where((s) => s.id == invoice.customerId || s.name == invoice.customerName);
        if (matches.isNotEmpty) {
          final sup = matches.first;
          final updatedSup = sup.copyWith(
            payableBalance: sup.payableBalance + invoice.dueAmount,
          );
          await purchaseRepository.updateSupplier(updatedSup);
        }
      } catch (_) {}
    }

    return createdInvoice;
  }
}

