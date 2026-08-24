import 'package:equatable/equatable.dart';

import 'invoice_entity.dart';
import 'invoice_return_entity.dart';
import 'payment_entity.dart';

enum SalesTransactionType {
  invoice,
  salesReturn,
  payment,
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

  bool get isInvoice => type == SalesTransactionType.invoice;
  bool get isReturn => type == SalesTransactionType.salesReturn;
  bool get isPayment => type == SalesTransactionType.payment;

  InvoiceEntity? get asInvoice => isInvoice ? (originalEntity as InvoiceEntity) : null;
  InvoiceReturnEntity? get asReturn => isReturn ? (originalEntity as InvoiceReturnEntity) : null;
  PaymentEntity? get asPayment => isPayment ? (originalEntity as PaymentEntity) : null;

  String get typeLabel {
    switch (type) {
      case SalesTransactionType.invoice:
        return 'INVOICE';
      case SalesTransactionType.salesReturn:
        return 'SALES RETURN';
      case SalesTransactionType.payment:
        return 'PAYMENT';
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
