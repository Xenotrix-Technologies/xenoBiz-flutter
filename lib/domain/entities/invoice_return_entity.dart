import 'package:equatable/equatable.dart';
import 'invoice_entity.dart';

class InvoiceReturnItemEntity extends Equatable {
  final String productId;
  final String productName;
  final String sku;
  final int originalQuantity;
  final int returnedQuantity;
  final double unitPrice;

  const InvoiceReturnItemEntity({
    required this.productId,
    required this.productName,
    this.sku = '',
    required this.originalQuantity,
    required this.returnedQuantity,
    required this.unitPrice,
  });

  double get totalAmount => returnedQuantity * unitPrice;

  @override
  List<Object?> get props => [
        productId,
        productName,
        sku,
        originalQuantity,
        returnedQuantity,
        unitPrice,
      ];
}

class InvoiceReturnEntity extends Equatable {
  final String id;
  final String returnNumber;
  final String invoiceId;
  final String invoiceNumber;
  final String partyId;
  final String partyName;
  final InvoiceType type;
  final List<InvoiceReturnItemEntity> items;
  final double totalAmount;
  final DateTime returnDate;
  final String notes;

  const InvoiceReturnEntity({
    required this.id,
    required this.returnNumber,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.partyId,
    required this.partyName,
    required this.type,
    required this.items,
    required this.totalAmount,
    required this.returnDate,
    this.notes = '',
  });

  bool get isSale => type == InvoiceType.sale;
  bool get isPurchase => type == InvoiceType.purchase;

  @override
  List<Object?> get props => [
        id,
        returnNumber,
        invoiceId,
        invoiceNumber,
        partyId,
        partyName,
        type,
        items,
        totalAmount,
        returnDate,
        notes,
      ];
}
