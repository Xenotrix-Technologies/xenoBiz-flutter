import '../entities/invoice_entity.dart';
import '../entities/invoice_return_entity.dart';

abstract class ReturnsRepository {
  Future<List<InvoiceReturnEntity>> getReturns(InvoiceType type);
  Future<List<InvoiceReturnEntity>> getAllReturns();
  Future<InvoiceReturnEntity?> getReturn(String id);
  Future<InvoiceReturnEntity> createReturn(InvoiceReturnEntity returnEntity);
  Future<void> updateReturn(InvoiceReturnEntity returnEntity);
  Future<void> deleteReturn(String id);
  Future<Map<String, int>> getReturnedQuantitiesForInvoice(String invoiceId);
}
