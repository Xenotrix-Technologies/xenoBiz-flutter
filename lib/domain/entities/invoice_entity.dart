import 'package:equatable/equatable.dart';

enum InvoiceStatus { draft, unpaid, partiallyPaid, paid, cancelled }

class InvoiceItemEntity extends Equatable {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double taxPercentage;

  const InvoiceItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.taxPercentage = 0.0,
  });

  double get subtotal => quantity * unitPrice;
  double get taxAmount => subtotal * (taxPercentage / 100);
  double get total => subtotal + taxAmount;

  @override
  List<Object?> get props => [productId, productName, quantity, unitPrice, taxPercentage];
}

class InvoiceEntity extends Equatable {
  final String id;
  final String invoiceNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final List<InvoiceItemEntity> items;
  final double subtotal;
  final double taxTotal;
  final double discountTotal;
  final double grandTotal;
  final double paidAmount;
  final InvoiceStatus status;
  final DateTime issueDate;
  final DateTime dueDate;
  final String notes;

  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.taxTotal,
    this.discountTotal = 0.0,
    required this.grandTotal,
    this.paidAmount = 0.0,
    required this.status,
    required this.issueDate,
    required this.dueDate,
    this.notes = '',
  });

  double get dueAmount => grandTotal - paidAmount;

  InvoiceEntity copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    List<InvoiceItemEntity>? items,
    double? subtotal,
    double? taxTotal,
    double? discountTotal,
    double? grandTotal,
    double? paidAmount,
    InvoiceStatus? status,
    DateTime? issueDate,
    DateTime? dueDate,
    String? notes,
  }) {
    return InvoiceEntity(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxTotal: taxTotal ?? this.taxTotal,
      discountTotal: discountTotal ?? this.discountTotal,
      grandTotal: grandTotal ?? this.grandTotal,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        customerId,
        customerName,
        customerPhone,
        items,
        subtotal,
        taxTotal,
        discountTotal,
        grandTotal,
        paidAmount,
        status,
        issueDate,
        dueDate,
        notes,
      ];
}
