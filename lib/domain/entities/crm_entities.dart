import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'customer_entity.dart';
import 'invoice_entity.dart';

class CrmNoteEntity extends Equatable {
  final String id;
  final String customerId;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CrmNoteEntity({
    required this.id,
    required this.customerId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  CrmNoteEntity copyWith({
    String? id,
    String? customerId,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CrmNoteEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CrmNoteEntity.fromMap(Map<String, dynamic> map) {
    return CrmNoteEntity(
      id: map['id']?.toString() ?? '',
      customerId: map['customerId']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, customerId, text, createdAt, updatedAt];
}

class CrmFollowUpEntity extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final String title;
  final String notes;
  final DateTime dueDate;
  final String dueTime; // e.g. '10:30 AM'
  final String status; // 'pending', 'completed', 'cancelled'

  const CrmFollowUpEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.title,
    this.notes = '',
    required this.dueDate,
    required this.dueTime,
    this.status = 'pending',
  });

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isOverdue {
    if (isCompleted || status.toLowerCase() == 'cancelled') return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.isBefore(today);
  }

  bool get isToday {
    if (isCompleted || status.toLowerCase() == 'cancelled') return false;
    final now = DateTime.now();
    return dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day;
  }

  CrmFollowUpEntity copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? title,
    String? notes,
    DateTime? dueDate,
    String? dueTime,
    String? status,
  }) {
    return CrmFollowUpEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'title': title,
      'notes': notes,
      'dueDate': dueDate.toIso8601String(),
      'dueTime': dueTime,
      'status': status,
    };
  }

  factory CrmFollowUpEntity.fromMap(Map<String, dynamic> map) {
    return CrmFollowUpEntity(
      id: map['id']?.toString() ?? '',
      customerId: map['customerId']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
      dueDate: DateTime.tryParse(map['dueDate']?.toString() ?? '') ?? DateTime.now(),
      dueTime: map['dueTime']?.toString() ?? '10:00 AM',
      status: map['status']?.toString() ?? 'pending',
    );
  }

  @override
  List<Object?> get props => [id, customerId, customerName, title, notes, dueDate, dueTime, status];
}

enum CustomerSegment { all, outstanding, highValue, regular, newCustomer, inactive }

class CustomerSegmentation {
  static CustomerSegment calculateSegment(CustomerEntity customer, List<InvoiceEntity> invoices) {
    if (customer.outstandingBalance > 0) {
      return CustomerSegment.outstanding;
    }

    final totalSpent = customer.totalPurchases > 0
        ? customer.totalPurchases
        : invoices.fold(0.0, (sum, i) => sum + i.grandTotal);

    if (totalSpent >= 50000) {
      return CustomerSegment.highValue;
    }

    final createdDaysAgo = DateTime.now().difference(customer.createdAt).inDays;
    if (createdDaysAgo <= 30) {
      return CustomerSegment.newCustomer;
    }

    if (invoices.length >= 3 || totalSpent >= 10000) {
      return CustomerSegment.regular;
    }

    return CustomerSegment.inactive;
  }

  static String getLabel(CustomerSegment segment) {
    switch (segment) {
      case CustomerSegment.all:
        return 'All Customers';
      case CustomerSegment.outstanding:
        return 'Outstanding';
      case CustomerSegment.highValue:
        return 'High Value';
      case CustomerSegment.regular:
        return 'Regular';
      case CustomerSegment.newCustomer:
        return 'New Customer';
      case CustomerSegment.inactive:
        return 'Inactive';
    }
  }

  static Color getColor(CustomerSegment segment) {
    switch (segment) {
      case CustomerSegment.all:
        return const Color(0xFF2563EB);
      case CustomerSegment.outstanding:
        return const Color(0xFFEF4444);
      case CustomerSegment.highValue:
        return const Color(0xFF8B5CF6);
      case CustomerSegment.regular:
        return const Color(0xFF10B981);
      case CustomerSegment.newCustomer:
        return const Color(0xFF0284C7);
      case CustomerSegment.inactive:
        return const Color(0xFF6B7280);
    }
  }

  static Color getBgColor(CustomerSegment segment) {
    return getColor(segment).withValues(alpha: 0.12);
  }
}
