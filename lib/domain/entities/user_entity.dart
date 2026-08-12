import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? businessId;
  final String role;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.businessId,
    this.role = 'OWNER',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, phone, businessId, role, createdAt];
}
