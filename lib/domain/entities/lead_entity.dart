import 'package:equatable/equatable.dart';

enum LeadStage { newLead, contacted, qualified, proposalSent, negotiating, won, lost }

enum LeadPriority { low, medium, high }

enum LeadSortOption {
  dateNewest,
  dateOldest,
  recentlyUpdated,
  valueHighest,
  valueLowest,
  nameAZ,
  nameZA,
  followUpSoonest,
}

class LeadEntity extends Equatable {
  final String id;
  final String title;
  final String contactName;
  final String companyName;
  final String phone;
  final String whatsapp;
  final String email;
  final String address;
  final String source;
  final LeadStage stage;
  final LeadPriority priority;
  final double estimatedValue;
  final DateTime? expectedClosingDate;
  final String assignedStaff;
  final String createdBy;
  final String notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? nextFollowUpDate;
  final String? nextFollowUpTime;
  final String? nextFollowUpNotes;
  final String? lostReason;

  const LeadEntity({
    required this.id,
    required this.title,
    required this.contactName,
    this.companyName = '',
    required this.phone,
    this.whatsapp = '',
    this.email = '',
    this.address = '',
    this.source = 'Walk-in',
    required this.stage,
    this.priority = LeadPriority.medium,
    required this.estimatedValue,
    this.expectedClosingDate,
    this.assignedStaff = 'Self',
    this.createdBy = 'Admin',
    this.notes = '',
    required this.createdAt,
    this.updatedAt,
    this.nextFollowUpDate,
    this.nextFollowUpTime,
    this.nextFollowUpNotes,
    this.lostReason,
  });

  LeadEntity copyWith({
    String? id,
    String? title,
    String? contactName,
    String? companyName,
    String? phone,
    String? whatsapp,
    String? email,
    String? address,
    String? source,
    LeadStage? stage,
    LeadPriority? priority,
    double? estimatedValue,
    DateTime? expectedClosingDate,
    String? assignedStaff,
    String? createdBy,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? nextFollowUpDate,
    String? nextFollowUpTime,
    String? nextFollowUpNotes,
    String? lostReason,
  }) {
    return LeadEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      contactName: contactName ?? this.contactName,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      address: address ?? this.address,
      source: source ?? this.source,
      stage: stage ?? this.stage,
      priority: priority ?? this.priority,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      expectedClosingDate: expectedClosingDate ?? this.expectedClosingDate,
      assignedStaff: assignedStaff ?? this.assignedStaff,
      createdBy: createdBy ?? this.createdBy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
      nextFollowUpTime: nextFollowUpTime ?? this.nextFollowUpTime,
      nextFollowUpNotes: nextFollowUpNotes ?? this.nextFollowUpNotes,
      lostReason: lostReason ?? this.lostReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        contactName,
        companyName,
        phone,
        whatsapp,
        email,
        address,
        source,
        stage,
        priority,
        estimatedValue,
        expectedClosingDate,
        assignedStaff,
        createdBy,
        notes,
        createdAt,
        updatedAt,
        nextFollowUpDate,
        nextFollowUpTime,
        nextFollowUpNotes,
        lostReason,
      ];
}

class LeadActivityEntity extends Equatable {
  final String id;
  final String leadId;
  final String title;
  final String description;
  final String eventType; // CREATED, STAGE_CHANGED, NOTE_ADDED, FOLLOWUP_SCHEDULED, FOLLOWUP_COMPLETED, CALL, WHATSAPP, EMAIL
  final DateTime timestamp;
  final String user;

  const LeadActivityEntity({
    required this.id,
    required this.leadId,
    required this.title,
    required this.description,
    required this.eventType,
    required this.timestamp,
    this.user = 'Admin',
  });

  @override
  List<Object?> get props => [id, leadId, title, description, eventType, timestamp, user];
}

class LeadNoteEntity extends Equatable {
  final String id;
  final String leadId;
  final String content;
  final String createdBy;
  final DateTime createdAt;

  const LeadNoteEntity({
    required this.id,
    required this.leadId,
    required this.content,
    this.createdBy = 'Admin',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, leadId, content, createdBy, createdAt];
}

class LeadFollowUpEntity extends Equatable {
  final String id;
  final String leadId;
  final String leadTitle;
  final String contactName;
  final String type; // CALL, WHATSAPP, MEETING, VISIT, PAYMENT, GENERAL
  final DateTime dueDate;
  final String dueTime;
  final bool reminder;
  final String notes;
  final String assignedStaff;
  final bool isCompleted;
  final DateTime createdAt;

  const LeadFollowUpEntity({
    required this.id,
    required this.leadId,
    required this.leadTitle,
    required this.contactName,
    required this.type,
    required this.dueDate,
    this.dueTime = '10:00 AM',
    this.reminder = true,
    this.notes = '',
    this.assignedStaff = 'Self',
    this.isCompleted = false,
    required this.createdAt,
  });

  LeadFollowUpEntity copyWith({
    String? id,
    String? leadId,
    String? leadTitle,
    String? contactName,
    String? type,
    DateTime? dueDate,
    String? dueTime,
    bool? reminder,
    String? notes,
    String? assignedStaff,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return LeadFollowUpEntity(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      leadTitle: leadTitle ?? this.leadTitle,
      contactName: contactName ?? this.contactName,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      reminder: reminder ?? this.reminder,
      notes: notes ?? this.notes,
      assignedStaff: assignedStaff ?? this.assignedStaff,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        leadId,
        leadTitle,
        contactName,
        type,
        dueDate,
        dueTime,
        reminder,
        notes,
        assignedStaff,
        isCompleted,
        createdAt,
      ];
}

class FollowUpTaskEntity extends Equatable {
  final String id;
  final String leadId;
  final String title;
  final String type;
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

class LeadFilter extends Equatable {
  final Set<LeadStage> stages;
  final Set<LeadPriority> priorities;
  final Set<String> sources;
  final String? assignedStaff;
  final String? valueRange; // 'all', 'under10k', '10kTo50k', '50kTo100k', 'above100k'
  final String? dateRange; // 'all', 'today', 'yesterday', 'last7Days', 'last30Days', 'thisMonth'
  final String? followUpStatus; // 'all', 'none', 'upcoming', 'dueToday', 'overdue', 'completed'

  const LeadFilter({
    this.stages = const {},
    this.priorities = const {},
    this.sources = const {},
    this.assignedStaff,
    this.valueRange = 'all',
    this.dateRange = 'all',
    this.followUpStatus = 'all',
  });

  int get activeFilterCount {
    int count = 0;
    if (stages.isNotEmpty) count++;
    if (priorities.isNotEmpty) count++;
    if (sources.isNotEmpty) count++;
    if (assignedStaff != null && assignedStaff != 'All') count++;
    if (valueRange != null && valueRange != 'all') count++;
    if (dateRange != null && dateRange != 'all') count++;
    if (followUpStatus != null && followUpStatus != 'all') count++;
    return count;
  }

  LeadFilter copyWith({
    Set<LeadStage>? stages,
    Set<LeadPriority>? priorities,
    Set<String>? sources,
    String? assignedStaff,
    String? valueRange,
    String? dateRange,
    String? followUpStatus,
  }) {
    return LeadFilter(
      stages: stages ?? this.stages,
      priorities: priorities ?? this.priorities,
      sources: sources ?? this.sources,
      assignedStaff: assignedStaff ?? this.assignedStaff,
      valueRange: valueRange ?? this.valueRange,
      dateRange: dateRange ?? this.dateRange,
      followUpStatus: followUpStatus ?? this.followUpStatus,
    );
  }

  @override
  List<Object?> get props => [
        stages,
        priorities,
        sources,
        assignedStaff,
        valueRange,
        dateRange,
        followUpStatus,
      ];
}
