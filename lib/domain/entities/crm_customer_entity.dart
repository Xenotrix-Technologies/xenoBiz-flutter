import 'package:equatable/equatable.dart';

class CrmCustomerEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String companyName;
  final String source;
  final String status; // Active, Lead, Contacted, Inactive
  final String notes;
  final List<String> tags;
  final String assignedStaff;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CrmCustomerEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    this.companyName = '',
    this.source = 'Direct',
    this.status = 'Active',
    this.notes = '',
    this.tags = const [],
    this.assignedStaff = 'Admin',
    required this.createdAt,
    this.updatedAt,
  });

  CrmCustomerEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? companyName,
    String? source,
    String? status,
    String? notes,
    List<String>? tags,
    String? assignedStaff,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CrmCustomerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      companyName: companyName ?? this.companyName,
      source: source ?? this.source,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      assignedStaff: assignedStaff ?? this.assignedStaff,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'companyName': companyName,
      'source': source,
      'status': status,
      'notes': notes,
      'tags': tags,
      'assignedStaff': assignedStaff,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory CrmCustomerEntity.fromMap(Map<dynamic, dynamic> map) {
    return CrmCustomerEntity(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unnamed CRM Customer',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      companyName: map['companyName']?.toString() ?? '',
      source: map['source']?.toString() ?? 'Direct',
      status: map['status']?.toString() ?? 'Active',
      notes: map['notes']?.toString() ?? '',
      tags: map['tags'] != null ? List<String>.from(map['tags']) : const [],
      assignedStaff: map['assignedStaff']?.toString() ?? 'Admin',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        address,
        companyName,
        source,
        status,
        notes,
        tags,
        assignedStaff,
        createdAt,
        updatedAt,
      ];
}
