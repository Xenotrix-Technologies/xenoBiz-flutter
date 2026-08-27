import 'package:equatable/equatable.dart';

import 'invoice_entity.dart';
import 'invoice_return_entity.dart';
import 'payment_entity.dart';

enum SalesTransactionType {
  sale,
  salesReturn,
  purchase,
  purchaseReturn,
  payment,
  receipt,
}

class SalesTransactionWrapper extends Equatable {
  final String id;
  final SalesTransactionType type;
  final String transactionNumber;
  final String customerName;
  final String customerPhone;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String statusText;
  final DateTime date;
  final Object originalEntity;

  const SalesTransactionWrapper({
    required this.id,
    required this.type,
    required this.transactionNumber,
    required this.customerName,
    this.customerPhone = '',
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.dueAmount = 0.0,
    required this.statusText,
    required this.date,
    required this.originalEntity,
  });

  bool get isSale => type == SalesTransactionType.sale;
  bool get isPurchase => type == SalesTransactionType.purchase;
  bool get isInvoice => isSale || isPurchase;

  bool get isSalesReturn => type == SalesTransactionType.salesReturn;
  bool get isPurchaseReturn => type == SalesTransactionType.purchaseReturn;
  bool get isReturn => isSalesReturn || isPurchaseReturn;

  bool get isPayment => type == SalesTransactionType.payment;
  bool get isReceipt => type == SalesTransactionType.receipt;

  InvoiceEntity? get asInvoice =>
      originalEntity is InvoiceEntity ? (originalEntity as InvoiceEntity) : null;
  InvoiceReturnEntity? get asReturn =>
      originalEntity is InvoiceReturnEntity
          ? (originalEntity as InvoiceReturnEntity)
          : null;
  PaymentEntity? get asPayment =>
      originalEntity is PaymentEntity ? (originalEntity as PaymentEntity) : null;

  String get typeLabel {
    switch (type) {
      case SalesTransactionType.sale:
        return 'INVOICE';
      case SalesTransactionType.salesReturn:
        return 'SALES RETURN';
      case SalesTransactionType.purchase:
        return 'PURCHASE';
      case SalesTransactionType.purchaseReturn:
        return 'PURCHASE RETURN';
      case SalesTransactionType.payment:
        return 'PAYMENT';
      case SalesTransactionType.receipt:
        return 'RECEIPT';
    }
  }

  @override
  List<Object?> get props => [
        id,
        type,
        transactionNumber,
        customerName,
        customerPhone,
        totalAmount,
        paidAmount,
        dueAmount,
        statusText,
        date,
      ];
}
