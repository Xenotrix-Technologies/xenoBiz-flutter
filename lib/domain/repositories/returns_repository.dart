import '../entities/invoice_entity.dart';
import '../entities/invoice_return_entity.dart';

abstract class ReturnsRepository {
  Future<List<InvoiceReturnEntity>> getReturns(InvoiceType type);
  Future<InvoiceReturnEntity> createReturn(InvoiceReturnEntity returnEntity);
  Future<Map<String, int>> getReturnedQuantitiesForInvoice(String invoiceId);
}
