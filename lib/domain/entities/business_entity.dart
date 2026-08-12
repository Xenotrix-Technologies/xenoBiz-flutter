import 'package:equatable/equatable.dart';

class BusinessEntity extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? gstin;
  final String category;
  final String currency;
  final String phone;
  final String address;
  final String? logoUrl;
  final DateTime createdAt;

  const BusinessEntity({
    required this.id,
    required this.name,
    this.email,
    this.gstin,
    required this.category,
    this.currency = '₹',
    required this.phone,
    required this.address,
    this.logoUrl,
    required this.createdAt,
  });

  BusinessEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? gstin,
    String? category,
    String? currency,
    String? phone,
    String? address,
    String? logoUrl,
    DateTime? createdAt,
  }) {
    return BusinessEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      gstin: gstin ?? this.gstin,
      category: category ?? this.category,
      currency: currency ?? this.currency,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, email, gstin, category, currency, phone, address, logoUrl, createdAt];
}
