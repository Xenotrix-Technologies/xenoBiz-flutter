import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../database/app_database.dart';
import '../network/dio_client.dart';
import '../network/network_checker.dart';
import '../services/voucher_sequence_service.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final DioClient dioClient;
  final AppDatabase db;
  final NetworkChecker networkChecker;
  final SyncRepository syncRepository;

  InvoiceRepositoryImpl({
    required this.dioClient,
    required this.db,
    required this.networkChecker,
    required this.syncRepository,
  });

  InvoiceStatus _parseStatus(String statusStr) {
    if (statusStr == 'paid' || statusStr == 'InvoiceStatus.paid') return InvoiceStatus.paid;
    if (statusStr == 'partiallyPaid' || statusStr == 'partially_paid' || statusStr == 'InvoiceStatus.partiallyPaid') {
      return InvoiceStatus.partiallyPaid;
    }
    if (statusStr == 'cancelled' || statusStr == 'InvoiceStatus.cancelled') return InvoiceStatus.cancelled;
    if (statusStr == 'draft' || statusStr == 'InvoiceStatus.draft') return InvoiceStatus.draft;
    return InvoiceStatus.unpaid;
  }

  InvoiceEntity _rowToInvoice(Invoice row, List<InvoiceItem> itemRows) {
    final type = row.type == 'purchase' || row.type == 'InvoiceType.purchase'
        ? InvoiceType.purchase
        : InvoiceType.sale;

    final items = itemRows.map((i) => InvoiceItemEntity(
      productId: i.productId,
      productName: i.productName,
      sku: i.sku,
      quantity: i.quantity,
      unitPrice: i.unitPrice,
      taxPercentage: i.taxPercentage,
    )).toList();

    return InvoiceEntity(
      id: row.id,
      invoiceNumber: row.invoiceNumber,
      type: type,
      customerId: row.customerId,
      customerName: row.customerName,
      customerPhone: row.customerPhone,
      items: items,
      subtotal: row.subtotal,
      taxTotal: row.taxTotal,
      discountTotal: row.discountTotal,
      grandTotal: row.grandTotal,
      paidAmount: row.paidAmount,
      status: _parseStatus(row.status),
      issueDate: row.issueDate,
      dueDate: row.dueDate,
      notes: row.notes,
    );
  }

  InvoicesCompanion _invoiceToCompanion(InvoiceEntity inv, {String syncStatus = 'synced'}) {
    return InvoicesCompanion(
      id: Value(inv.id),
      invoiceNumber: Value(inv.invoiceNumber),
      type: Value(inv.type.name),
      customerId: Value(inv.customerId),
      customerName: Value(inv.customerName),
      customerPhone: Value(inv.customerPhone),
      subtotal: Value(inv.subtotal),
      taxTotal: Value(inv.taxTotal),
      discountTotal: Value(inv.discountTotal),
      grandTotal: Value(inv.grandTotal),
      paidAmount: Value(inv.paidAmount),
      status: Value(inv.status.name),
      issueDate: Value(inv.issueDate),
      dueDate: Value(inv.dueDate),
      notes: Value(inv.notes),
      syncStatus: Value(syncStatus),
    );
  }

  PaymentEntity _rowToPayment(Payment row) {
    return PaymentEntity(
      id: row.id,
      invoiceId: row.invoiceId,
      customerId: row.customerId,
      customerName: row.customerName,
      amount: row.amount,
      paymentMode: row.paymentMode,
      paymentDate: row.paymentDate,
      notes: row.notes,
    );
  }

  PaymentsCompanion _paymentToCompanion(PaymentEntity p, {String syncStatus = 'synced'}) {
    return PaymentsCompanion(
      id: Value(p.id),
      invoiceId: Value(p.invoiceId),
      customerId: Value(p.customerId),
      customerName: Value(p.customerName),
      amount: Value(p.amount),
      paymentMode: Value(p.paymentMode),
      paymentDate: Value(p.paymentDate),
      notes: Value(p.notes),
      syncStatus: Value(syncStatus),
    );
  }

  @override
  Future<List<InvoiceEntity>> getInvoices({InvoiceStatus? status, String? query}) async {
    final q = db.select(db.invoices)..orderBy([(t) => OrderingTerm.desc(t.issueDate)]);
    final rows = await q.get();

    final List<InvoiceEntity> list = [];
    for (var row in rows) {
      final itemRows = await (db.select(db.invoiceItems)..where((t) => t.invoiceId.equals(row.id))).get();
      list.add(_rowToInvoice(row, itemRows));
    }

    List<InvoiceEntity> filtered = list;
    if (status != null) {
      filtered = filtered.where((i) => i.status == status).toList();
    }
    if (query != null && query.isNotEmpty) {
      final lowerQ = query.toLowerCase();
      filtered = filtered.where((i) {
        return i.invoiceNumber.toLowerCase().contains(lowerQ) ||
            i.customerName.toLowerCase().contains(lowerQ);
      }).toList();
    }
    return filtered;
  }

  @override
  Future<InvoiceEntity> getInvoice(String id) async {
    final row = await (db.select(db.invoices)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row != null) {
      final itemRows = await (db.select(db.invoiceItems)..where((t) => t.invoiceId.equals(id))).get();
      return _rowToInvoice(row, itemRows);
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
    final String invId = invoice.id.isNotEmpty ? invoice.id : const Uuid().v4();
    final String invNum = invoice.invoiceNumber.isNotEmpty && invoice.invoiceNumber != 'INV-000'
        ? invoice.invoiceNumber
        : 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final localInvoice = invoice.copyWith(id: invId, invoiceNumber: invNum);

    await db.transaction(() async {
      await db.into(db.invoices).insertOnConflictUpdate(_invoiceToCompanion(localInvoice));
      await (db.delete(db.invoiceItems)..where((t) => t.invoiceId.equals(invId))).go();

      for (var item in localInvoice.items) {
        await db.into(db.invoiceItems).insert(
          InvoiceItemsCompanion.insert(
            invoiceId: invId,
            productId: item.productId,
            productName: item.productName,
            sku: Value(item.sku),
            quantity: Value(item.quantity),
            unitPrice: Value(item.unitPrice),
            taxPercentage: Value(item.taxPercentage),
          ),
        );
      }
    });

    final vType = localInvoice.isPurchase ? VoucherType.purchase : VoucherType.sale;
    await VoucherSequenceService.instance.incrementSequence(vType);

    return localInvoice;
  }

  @override
  Future<InvoiceEntity> updateInvoice(InvoiceEntity invoice) async {
    await db.transaction(() async {
      await db.into(db.invoices).insertOnConflictUpdate(_invoiceToCompanion(invoice));
      await (db.delete(db.invoiceItems)..where((t) => t.invoiceId.equals(invoice.id))).go();

      for (var item in invoice.items) {
        await db.into(db.invoiceItems).insert(
          InvoiceItemsCompanion.insert(
            invoiceId: invoice.id,
            productId: item.productId,
            productName: item.productName,
            sku: Value(item.sku),
            quantity: Value(item.quantity),
            unitPrice: Value(item.unitPrice),
            taxPercentage: Value(item.taxPercentage),
          ),
        );
      }
    });
    return invoice;
  }

  @override
  Future<PaymentEntity> recordPayment(PaymentEntity payment) async {
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

    await db.into(db.payments).insertOnConflictUpdate(_paymentToCompanion(localPayment));
    return localPayment;
  }

  @override
  Future<List<PaymentEntity>> getInvoicePayments(String invoiceId) async {
    final q = db.select(db.payments)..orderBy([(t) => OrderingTerm.desc(t.paymentDate)]);
    if (invoiceId.isNotEmpty) {
      q.where((t) => t.invoiceId.equals(invoiceId));
    }
    final rows = await q.get();
    return rows.map(_rowToPayment).toList();
  }
}
