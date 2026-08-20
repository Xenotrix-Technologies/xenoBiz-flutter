import 'package:equatable/equatable.dart';

enum InvoiceStatus { draft, unpaid, partiallyPaid, paid, cancelled }
enum InvoiceType { sale, purchase }

class InvoiceItemEntity extends Equatable {
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double taxPercentage;

  const InvoiceItemEntity({
    required this.productId,
    required this.productName,
    this.sku = '',
    required this.quantity,
    required this.unitPrice,
    this.taxPercentage = 0.0,
  });

  double get subtotal => quantity * unitPrice;
  double get taxAmount => subtotal * (taxPercentage / 100);
  double get total => subtotal + taxAmount;

  InvoiceItemEntity copyWith({
    String? productId,
    String? productName,
    String? sku,
    int? quantity,
    double? unitPrice,
    double? taxPercentage,
  }) {
    return InvoiceItemEntity(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      taxPercentage: taxPercentage ?? this.taxPercentage,
    );
  }

  @override
  List<Object?> get props => [productId, productName, sku, quantity, unitPrice, taxPercentage];
}

class InvoiceEntity extends Equatable {
  final String id;
  final String invoiceNumber;
  final InvoiceType type;
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

  // New Invoice Options
  final bool gstEnabled;
  final double discountAmount;
  final bool discountIsPercentage;
  final double extraExpenseAmount;
  final String extraExpenseDescription;

  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    this.type = InvoiceType.sale,
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
    this.gstEnabled = true,
    this.discountAmount = 0.0,
    this.discountIsPercentage = false,
    this.extraExpenseAmount = 0.0,
    this.extraExpenseDescription = '',
  });

  bool get isPurchase => type == InvoiceType.purchase;
  bool get isSale => type == InvoiceType.sale;

  double get dueAmount => grandTotal - paidAmount;

  InvoiceEntity copyWith({
    String? id,
    String? invoiceNumber,
    InvoiceType? type,
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
    bool? gstEnabled,
    double? discountAmount,
    bool? discountIsPercentage,
    double? extraExpenseAmount,
    String? extraExpenseDescription,
  }) {
    return InvoiceEntity(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      type: type ?? this.type,
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
      gstEnabled: gstEnabled ?? this.gstEnabled,
      discountAmount: discountAmount ?? this.discountAmount,
      discountIsPercentage: discountIsPercentage ?? this.discountIsPercentage,
      extraExpenseAmount: extraExpenseAmount ?? this.extraExpenseAmount,
      extraExpenseDescription: extraExpenseDescription ?? this.extraExpenseDescription,
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        type,
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
        gstEnabled,
        discountAmount,
        discountIsPercentage,
        extraExpenseAmount,
        extraExpenseDescription,
      ];
}
