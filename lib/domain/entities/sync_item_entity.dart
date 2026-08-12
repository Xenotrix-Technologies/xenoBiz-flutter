import 'package:equatable/equatable.dart';

enum SyncAction { create, update, delete }

class SyncItemEntity extends Equatable {
  final String id;
  final String entityType; // INVOICE, CUSTOMER, PRODUCT, PAYMENT, EXPENSE
  final SyncAction action;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final String status; // PENDING, SYNCING, FAILED, COMPLETED

  const SyncItemEntity({
    required this.id,
    required this.entityType,
    required this.action,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.status = 'PENDING',
  });

  @override
  List<Object?> get props => [id, entityType, action, payload, createdAt, retryCount, status];
}
