import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String? state;
  final double outstandingBalance;
  final double totalPurchases;
  final DateTime createdAt;

  const CustomerEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.state,
    this.outstandingBalance = 0.0,
    this.totalPurchases = 0.0,
    required this.createdAt,
  });

  CustomerEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? state,
    double? outstandingBalance,
    double? totalPurchases,
    DateTime? createdAt,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      state: state ?? this.state,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, email, address, state, outstandingBalance, totalPurchases, createdAt];
}

class CustomerTimelineEvent extends Equatable {
  final String id;
  final String customerId;
  final String title;
  final String description;
  final String eventType; // INVOICE, PAYMENT, FOLLOW_UP, NOTE
  final double? amount;
  final DateTime timestamp;

  const CustomerTimelineEvent({
    required this.id,
    required this.customerId,
    required this.title,
    required this.description,
    required this.eventType,
    this.amount,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, customerId, title, description, eventType, amount, timestamp];
}
