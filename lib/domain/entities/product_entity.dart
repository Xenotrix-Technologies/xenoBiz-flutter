import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String sku;
  final String barcode;
  final String category;
  final double sellingPrice;
  final double purchasePrice;
  final int stockQuantity;
  final int reorderLevel;
  final String unit; // Pcs, Kg, Box, etc.
  final double? taxPercentage; // Configured GST rate for product if set
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.sku,
    this.barcode = '',
    required this.category,
    required this.sellingPrice,
    required this.purchasePrice,
    required this.stockQuantity,
    this.reorderLevel = 5,
    this.unit = 'Pcs',
    this.taxPercentage,
    this.description = '',
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isOutOfStock => stockQuantity <= 0;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= reorderLevel;
  bool get isHealthy => stockQuantity > reorderLevel;

  ProductEntity copyWith({
    String? id,
    String? name,
    String? sku,
    String? barcode,
    String? category,
    double? sellingPrice,
    double? purchasePrice,
    int? stockQuantity,
    int? reorderLevel,
    String? unit,
    double? taxPercentage,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      unit: unit ?? this.unit,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        sku,
        barcode,
        category,
        sellingPrice,
        purchasePrice,
        stockQuantity,
        reorderLevel,
        unit,
        taxPercentage,
        description,
        isActive,
        createdAt,
        updatedAt,
      ];
}

class InventoryMovement extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String type; // IN, OUT, ADJUSTMENT
  final int quantityChange;
  final int previousQuantity;
  final int newQuantity;
  final String reason;
  final DateTime timestamp;

  const InventoryMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantityChange,
    this.previousQuantity = 0,
    this.newQuantity = 0,
    required this.reason,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        type,
        quantityChange,
        previousQuantity,
        newQuantity,
        reason,
        timestamp,
      ];
}
