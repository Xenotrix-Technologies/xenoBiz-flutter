import '../entities/invoice_entity.dart';
import '../repositories/customer_repository.dart';
import '../repositories/invoice_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/purchase_repository.dart';

class UpdateInvoiceUseCase {
  final InvoiceRepository invoiceRepository;
  final CustomerRepository customerRepository;
  final ProductRepository productRepository;
  final PurchaseRepository purchaseRepository;

  UpdateInvoiceUseCase({
    required this.invoiceRepository,
    required this.customerRepository,
    required this.productRepository,
    required this.purchaseRepository,
  });

  Future<InvoiceEntity> execute(InvoiceEntity updatedInvoice) async {
    // 1. Fetch old invoice to calculate deltas
    final oldInvoice = await invoiceRepository.getInvoice(updatedInvoice.id);

    // Build map of old quantities by productId
    final Map<String, int> oldQuantities = {};
    for (var item in oldInvoice.items) {
      oldQuantities[item.productId] = (oldQuantities[item.productId] ?? 0) + item.quantity;
    }

    // Build map of new quantities by productId
    final Map<String, int> newQuantities = {};
    for (var item in updatedInvoice.items) {
      newQuantities[item.productId] = (newQuantities[item.productId] ?? 0) + item.quantity;
    }

    // All distinct product IDs across old and new
    final allProductIds = {...oldQuantities.keys, ...newQuantities.keys};

    // 2. Adjust stock based on quantity difference
    for (final productId in allProductIds) {
      if (productId.isEmpty) continue;
      final oldQty = oldQuantities[productId] ?? 0;
      final newQty = newQuantities[productId] ?? 0;
      final qtyDifference = newQty - oldQty;

      if (qtyDifference != 0) {
        // For Sale: if newQty > oldQty (+diff), we need to deduct more stock (-qtyDifference).
        // For Purchase: if newQty > oldQty (+diff), we need to add more stock (+qtyDifference).
        final stockDelta = updatedInvoice.isPurchase ? qtyDifference : -qtyDifference;
        final label = updatedInvoice.isPurchase
            ? 'Updated Purchase #${updatedInvoice.invoiceNumber}'
            : 'Updated Sale #${updatedInvoice.invoiceNumber}';

        await productRepository.adjustStock(
          productId,
          stockDelta,
          label,
        );
      }
    }

    // 3. Adjust Account Balance based on due amount difference
    final double oldDue = oldInvoice.dueAmount;
    final double newDue = updatedInvoice.dueAmount;
    final double dueDifference = newDue - oldDue;

    if (dueDifference != 0) {
      if (updatedInvoice.isSale && updatedInvoice.customerId.isNotEmpty) {
        try {
          final customer = await customerRepository.getCustomer(updatedInvoice.customerId);
          final updatedCust = customer.copyWith(
            outstandingBalance: (customer.outstandingBalance + dueDifference).clamp(0, double.infinity),
          );
          await customerRepository.updateCustomer(updatedCust);
        } catch (_) {}
      } else if (updatedInvoice.isPurchase && updatedInvoice.customerId.isNotEmpty) {
        try {
          final suppliers = await purchaseRepository.getSuppliers();
          final matches = suppliers.where((s) => s.id == updatedInvoice.customerId || s.name == updatedInvoice.customerName);
          if (matches.isNotEmpty) {
            final sup = matches.first;
            final updatedSup = sup.copyWith(
              payableBalance: (sup.payableBalance + dueDifference).clamp(0, double.infinity),
            );
            await purchaseRepository.updateSupplier(updatedSup);
          }
        } catch (_) {}
      }
    }

    // 4. Save updated invoice record
    return await invoiceRepository.updateInvoice(updatedInvoice);
  }
}
