import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String invoiceId;
  final String customerId;
  final String customerName;
  final double amount;
  final String paymentMode; // CASH, UPI, BANK_TRANSFER, CARD, CHEQUE
  final String referenceNumber;
  final DateTime paymentDate;
  final String notes;

  const PaymentEntity({
    required this.id,
    required this.invoiceId,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.paymentMode,
    this.referenceNumber = '',
    required this.paymentDate,
    this.notes = '',
  });

  @override
  List<Object?> get props => [
        id,
        invoiceId,
        customerId,
        customerName,
        amount,
        paymentMode,
        referenceNumber,
        paymentDate,
        notes,
      ];
}
