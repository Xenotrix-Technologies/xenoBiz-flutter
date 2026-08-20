import 'package:equatable/equatable.dart';

class SupplierEntity extends Equatable {
  final String id;
  final String name;
  final String companyName;
  final String phone;
  final String email;
  final String address;
  final double payableBalance;
  final DateTime createdAt;

  const SupplierEntity({
    required this.id,
    required this.name,
    required this.companyName,
    required this.phone,
    required this.email,
    required this.address,
    this.payableBalance = 0.0,
    required this.createdAt,
  });

  SupplierEntity copyWith({
    String? id,
    String? name,
    String? companyName,
    String? phone,
    String? email,
    String? address,
    double? payableBalance,
    DateTime? createdAt,
  }) {
    return SupplierEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      payableBalance: payableBalance ?? this.payableBalance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, companyName, phone, email, address, payableBalance, createdAt];
}


class PurchaseEntity extends Equatable {
  final String id;
  final String poNumber;
  final String supplierId;
  final String supplierName;
  final double totalAmount;
  final String status; // PENDING, RECEIVED, CANCELLED
  final DateTime orderDate;
  final String notes;

  const PurchaseEntity({
    required this.id,
    required this.poNumber,
    required this.supplierId,
    required this.supplierName,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.notes = '',
  });

  @override
  List<Object?> get props => [id, poNumber, supplierId, supplierName, totalAmount, status, orderDate, notes];
}
