import 'package:equatable/equatable.dart';

enum DeliveryChallanStatus { draft, issued, delivered, cancelled }

extension DeliveryChallanStatusExt on DeliveryChallanStatus {
  String get label {
    switch (this) {
      case DeliveryChallanStatus.draft:
        return 'Draft';
      case DeliveryChallanStatus.issued:
        return 'Issued';
      case DeliveryChallanStatus.delivered:
        return 'Delivered';
      case DeliveryChallanStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class DeliveryChallanItemEntity extends Equatable {
  final String productId;
  final String productName;
  final String sku;
  final String hsnSac;
  final int quantity;
  final String unit;
  final double unitPrice;
  final double taxPercentage;

  const DeliveryChallanItemEntity({
    required this.productId,
    required this.productName,
    this.sku = '',
    this.hsnSac = '',
    required this.quantity,
    this.unit = 'Pcs',
    this.unitPrice = 0.0,
    this.taxPercentage = 0.0,
  });

  double get subtotal => quantity * unitPrice;
  double get taxAmount => subtotal * (taxPercentage / 100);
  double get total => subtotal + taxAmount;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'sku': sku,
      'hsnSac': hsnSac,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'taxPercentage': taxPercentage,
    };
  }

  factory DeliveryChallanItemEntity.fromJson(Map<String, dynamic> json) {
    return DeliveryChallanItemEntity(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      sku: json['sku'] ?? '',
      hsnSac: json['hsnSac'] ?? '',
      quantity: json['quantity'] is int ? json['quantity'] : (json['quantity'] as num?)?.toInt() ?? 1,
      unit: json['unit'] ?? 'Pcs',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      taxPercentage: (json['taxPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        productName,
        sku,
        hsnSac,
        quantity,
        unit,
        unitPrice,
        taxPercentage,
      ];
}

class DeliveryChallanEntity extends Equatable {
  final String id;
  final String challanNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String customerGstin;
  final List<DeliveryChallanItemEntity> items;
  final DateTime issueDate;
  final DateTime? deliveryDate;
  final String placeOfSupply;
  final String transporterName;
  final String vehicleNumber;
  final String referenceNumber;
  final String notes;
  final DeliveryChallanStatus status;

  const DeliveryChallanEntity({
    required this.id,
    required this.challanNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.customerAddress = '',
    this.customerGstin = '',
    required this.items,
    required this.issueDate,
    this.deliveryDate,
    this.placeOfSupply = '',
    this.transporterName = '',
    this.vehicleNumber = '',
    this.referenceNumber = '',
    this.notes = '',
    this.status = DeliveryChallanStatus.issued,
  });

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  double get grandTotal => items.fold(0.0, (sum, item) => sum + item.total);

  DeliveryChallanEntity copyWith({
    String? id,
    String? challanNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    String? customerGstin,
    List<DeliveryChallanItemEntity>? items,
    DateTime? issueDate,
    DateTime? deliveryDate,
    String? placeOfSupply,
    String? transporterName,
    String? vehicleNumber,
    String? referenceNumber,
    String? notes,
    DeliveryChallanStatus? status,
  }) {
    return DeliveryChallanEntity(
      id: id ?? this.id,
      challanNumber: challanNumber ?? this.challanNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      customerGstin: customerGstin ?? this.customerGstin,
      items: items ?? this.items,
      issueDate: issueDate ?? this.issueDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      transporterName: transporterName ?? this.transporterName,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challanNumber': challanNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'customerGstin': customerGstin,
      'items': items.map((i) => i.toJson()).toList(),
      'issueDate': issueDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'placeOfSupply': placeOfSupply,
      'transporterName': transporterName,
      'vehicleNumber': vehicleNumber,
      'referenceNumber': referenceNumber,
      'notes': notes,
      'status': status.name,
    };
  }

  factory DeliveryChallanEntity.fromJson(Map<String, dynamic> json) {
    return DeliveryChallanEntity(
      id: json['id'] ?? '',
      challanNumber: json['challanNumber'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      customerGstin: json['customerGstin'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => DeliveryChallanItemEntity.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      issueDate: json['issueDate'] != null ? DateTime.parse(json['issueDate']) : DateTime.now(),
      deliveryDate: json['deliveryDate'] != null ? DateTime.parse(json['deliveryDate']) : null,
      placeOfSupply: json['placeOfSupply'] ?? '',
      transporterName: json['transporterName'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      referenceNumber: json['referenceNumber'] ?? '',
      notes: json['notes'] ?? '',
      status: DeliveryChallanStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => DeliveryChallanStatus.issued,
      ),
    );
  }

  @override
  List<Object?> get props => [
        id,
        challanNumber,
        customerId,
        customerName,
        customerPhone,
        customerAddress,
        customerGstin,
        items,
        issueDate,
        deliveryDate,
        placeOfSupply,
        transporterName,
        vehicleNumber,
        referenceNumber,
        notes,
        status,
      ];
}
