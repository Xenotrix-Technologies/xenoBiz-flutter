import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double sellingPrice;
  final double purchasePrice;
  final int stockQuantity;
  final int reorderLevel;
  final String unit; // Pcs, Kg, Box, etc.
  final DateTime createdAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.sellingPrice,
    required this.purchasePrice,
    required this.stockQuantity,
    this.reorderLevel = 5,
    this.unit = 'Pcs',
    required this.createdAt,
  });

  bool get isLowStock => stockQuantity <= reorderLevel;

  ProductEntity copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    double? sellingPrice,
    double? purchasePrice,
    int? stockQuantity,
    int? reorderLevel,
    String? unit,
    DateTime? createdAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        sku,
        category,
        sellingPrice,
        purchasePrice,
        stockQuantity,
        reorderLevel,
        unit,
        createdAt,
      ];
}

class InventoryMovement extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String type; // IN, OUT, ADJUSTMENT
  final int quantityChange;
  final String reason;
  final DateTime timestamp;

  const InventoryMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantityChange,
    required this.reason,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, productId, productName, type, quantityChange, reason, timestamp];
}
