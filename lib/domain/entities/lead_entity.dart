import 'package:equatable/equatable.dart';

enum LeadStage { newLead, contacted, proposalSent, negotiating, won, lost }

class LeadEntity extends Equatable {
  final String id;
  final String title;
  final String contactName;
  final String phone;
  final String email;
  final double estimatedValue;
  final LeadStage stage;
  final String notes;
  final DateTime createdAt;
  final DateTime? nextFollowUpDate;

  const LeadEntity({
    required this.id,
    required this.title,
    required this.contactName,
    required this.phone,
    required this.email,
    required this.estimatedValue,
    required this.stage,
    this.notes = '',
    required this.createdAt,
    this.nextFollowUpDate,
  });

  LeadEntity copyWith({
    String? id,
    String? title,
    String? contactName,
    String? phone,
    String? email,
    double? estimatedValue,
    LeadStage? stage,
    String? notes,
    DateTime? createdAt,
    DateTime? nextFollowUpDate,
  }) {
    return LeadEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      stage: stage ?? this.stage,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        contactName,
        phone,
        email,
        estimatedValue,
        stage,
        notes,
        createdAt,
        nextFollowUpDate,
      ];
}

class FollowUpTaskEntity extends Equatable {
  final String id;
  final String leadId;
  final String title;
  final String type; // CALL, MEETING, EMAIL, WHATSAPP
  final DateTime dueDate;
  final bool isCompleted;
  final String notes;

  const FollowUpTaskEntity({
    required this.id,
    required this.leadId,
    required this.title,
    required this.type,
    required this.dueDate,
    this.isCompleted = false,
    this.notes = '',
  });

  @override
  List<Object?> get props => [id, leadId, title, type, dueDate, isCompleted, notes];
}
