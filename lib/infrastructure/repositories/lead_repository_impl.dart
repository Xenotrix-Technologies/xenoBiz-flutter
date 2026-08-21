import 'package:uuid/uuid.dart';
import '../../domain/entities/crm_customer_entity.dart';
import '../../domain/entities/lead_entity.dart';
import '../../domain/repositories/crm_customer_repository.dart';
import '../../domain/repositories/lead_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../network/dio_client.dart';
import '../network/network_checker.dart';
import '../storage/hive_service.dart';

class LeadRepositoryImpl implements LeadRepository {
  final DioClient dioClient;
  final HiveService hiveService;
  final NetworkChecker networkChecker;
  final SyncRepository syncRepository;
  final CrmCustomerRepository? crmCustomerRepository;

  LeadRepositoryImpl({
    required this.dioClient,
    required this.hiveService,
    required this.networkChecker,
    required this.syncRepository,
    this.crmCustomerRepository,
  });

  LeadStage _parseStage(String? stageStr) {
    if (stageStr == 'won' || stageStr == 'Won' || stageStr == 'LeadStage.won') return LeadStage.won;
    if (stageStr == 'lost' || stageStr == 'Lost' || stageStr == 'LeadStage.lost') return LeadStage.lost;
    if (stageStr == 'qualified' || stageStr == 'Qualified' || stageStr == 'LeadStage.qualified') return LeadStage.qualified;
    if (stageStr == 'Proposal' || stageStr == 'proposal' || stageStr == 'proposalSent' || stageStr == 'LeadStage.proposalSent') {
      return LeadStage.proposalSent;
    }
    if (stageStr == 'Negotiation' || stageStr == 'negotiating' || stageStr == 'LeadStage.negotiating') {
      return LeadStage.negotiating;
    }
    if (stageStr == 'Contacted' || stageStr == 'contacted' || stageStr == 'LeadStage.contacted') {
      return LeadStage.contacted;
    }
    return LeadStage.newLead;
  }

  LeadPriority _parsePriority(String? prioStr) {
    if (prioStr == 'high' || prioStr == 'High' || prioStr == 'LeadPriority.high') return LeadPriority.high;
    if (prioStr == 'low' || prioStr == 'Low' || prioStr == 'LeadPriority.low') return LeadPriority.low;
    return LeadPriority.medium;
  }

  Map<String, dynamic> _leadToMap(LeadEntity lead, {String syncStatus = 'synced'}) {
    return {
      'id': lead.id,
      'title': lead.title,
      'contactName': lead.contactName,
      'companyName': lead.companyName,
      'phone': lead.phone,
      'whatsapp': lead.whatsapp,
      'email': lead.email,
      'address': lead.address,
      'source': lead.source,
      'stage': lead.stage.name,
      'priority': lead.priority.name,
      'estimatedValue': lead.estimatedValue,
      'expectedClosingDate': lead.expectedClosingDate?.toIso8601String(),
      'assignedStaff': lead.assignedStaff,
      'createdBy': lead.createdBy,
      'notes': lead.notes,
      'createdAt': lead.createdAt.toIso8601String(),
      'updatedAt': lead.updatedAt?.toIso8601String(),
      'nextFollowUpDate': lead.nextFollowUpDate?.toIso8601String(),
      'nextFollowUpTime': lead.nextFollowUpTime,
      'nextFollowUpNotes': lead.nextFollowUpNotes,
      'lostReason': lead.lostReason,
      'syncStatus': syncStatus,
    };
  }

  LeadEntity _mapToLead(Map<dynamic, dynamic> map) {
    return LeadEntity(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Lead',
      contactName: map['contactName']?.toString() ?? map['contact_name']?.toString() ?? 'Contact',
      companyName: map['companyName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? map['contact_phone']?.toString() ?? '',
      whatsapp: map['whatsapp']?.toString() ?? '',
      email: map['email']?.toString() ?? map['contact_email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      source: map['source']?.toString() ?? 'Walk-in',
      stage: _parseStage(map['stage']?.toString() ?? map['stage_name']?.toString() ?? map['status']?.toString()),
      priority: _parsePriority(map['priority']?.toString()),
      estimatedValue: (map['estimatedValue'] as num?)?.toDouble() ??
          (map['lead_value'] as num?)?.toDouble() ?? 0.0,
      expectedClosingDate: DateTime.tryParse(map['expectedClosingDate']?.toString() ?? ''),
      assignedStaff: map['assignedStaff']?.toString() ?? 'Self',
      createdBy: map['createdBy']?.toString() ?? 'Admin',
      notes: map['notes']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? ''),
      nextFollowUpDate: DateTime.tryParse(map['nextFollowUpDate']?.toString() ?? ''),
      nextFollowUpTime: map['nextFollowUpTime']?.toString(),
      nextFollowUpNotes: map['nextFollowUpNotes']?.toString(),
      lostReason: map['lostReason']?.toString(),
    );
  }

  @override
  Future<List<LeadEntity>> getLeads({
    LeadFilter? filter,
    LeadSortOption? sort,
    String? query,
  }) async {
    final box = hiveService.getBox(HiveService.boxLeads);
    final List<LeadEntity> list = [];

    for (var key in box.keys) {
      if (key.toString().startsWith('act_') || key.toString().startsWith('note_')) continue;
      final val = box.get(key);
      if (val is Map) {
        final lead = _mapToLead(val);

        // Apply Search query
        if (query != null && query.trim().isNotEmpty) {
          final q = query.trim().toLowerCase();
          final matches = lead.title.toLowerCase().contains(q) ||
              lead.contactName.toLowerCase().contains(q) ||
              lead.companyName.toLowerCase().contains(q) ||
              lead.phone.toLowerCase().contains(q) ||
              lead.email.toLowerCase().contains(q);
          if (!matches) continue;
        }

        // Apply Filter
        if (filter != null) {
          if (filter.stages.isNotEmpty && !filter.stages.contains(lead.stage)) continue;
          if (filter.priorities.isNotEmpty && !filter.priorities.contains(lead.priority)) continue;
          if (filter.sources.isNotEmpty && !filter.sources.contains(lead.source)) continue;
          if (filter.assignedStaff != null && filter.assignedStaff != 'All' && lead.assignedStaff != filter.assignedStaff) continue;

          // Value Range filter
          if (filter.valueRange != null && filter.valueRange != 'all') {
            final v = lead.estimatedValue;
            if (filter.valueRange == 'under10k' && v >= 10000) continue;
            if (filter.valueRange == '10kTo50k' && (v < 10000 || v > 50000)) continue;
            if (filter.valueRange == '50kTo100k' && (v < 50000 || v > 100000)) continue;
            if (filter.valueRange == 'above100k' && v <= 100000) continue;
          }

          // Date Range filter
          if (filter.dateRange != null && filter.dateRange != 'all') {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final createdDate = DateTime(lead.createdAt.year, lead.createdAt.month, lead.createdAt.day);

            if (filter.dateRange == 'today' && createdDate != today) continue;
            if (filter.dateRange == 'yesterday' && createdDate != today.subtract(const Duration(days: 1))) continue;
            if (filter.dateRange == 'last7Days' && createdDate.isBefore(today.subtract(const Duration(days: 7)))) continue;
            if (filter.dateRange == 'last30Days' && createdDate.isBefore(today.subtract(const Duration(days: 30)))) continue;
            if (filter.dateRange == 'thisMonth' && (createdDate.year != now.year || createdDate.month != now.month)) continue;
          }

          // Follow-up status filter
          if (filter.followUpStatus != null && filter.followUpStatus != 'all') {
            final fDate = lead.nextFollowUpDate;
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            if (filter.followUpStatus == 'none' && fDate != null) continue;
            if (filter.followUpStatus == 'upcoming' && (fDate == null || fDate.isBefore(now))) continue;
            if (filter.followUpStatus == 'dueToday') {
              if (fDate == null) continue;
              final fdOnly = DateTime(fDate.year, fDate.month, fDate.day);
              if (fdOnly != today) continue;
            }
            if (filter.followUpStatus == 'overdue') {
              if (fDate == null) continue;
              final fdOnly = DateTime(fDate.year, fDate.month, fDate.day);
              if (!fdOnly.isBefore(today)) continue;
            }
          }
        }

        list.add(lead);
      }
    }

    // Apply Sorting (Requirement #5: Default is Date Created — Newest First)
    final sortOpt = sort ?? LeadSortOption.dateNewest;
    switch (sortOpt) {
      case LeadSortOption.dateNewest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case LeadSortOption.dateOldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case LeadSortOption.recentlyUpdated:
        list.sort((a, b) {
          final tA = a.updatedAt ?? a.createdAt;
          final tB = b.updatedAt ?? b.createdAt;
          return tB.compareTo(tA);
        });
        break;
      case LeadSortOption.valueHighest:
        list.sort((a, b) => b.estimatedValue.compareTo(a.estimatedValue));
        break;
      case LeadSortOption.valueLowest:
        list.sort((a, b) => a.estimatedValue.compareTo(b.estimatedValue));
        break;
      case LeadSortOption.nameAZ:
        list.sort((a, b) => a.contactName.toLowerCase().compareTo(b.contactName.toLowerCase()));
        break;
      case LeadSortOption.nameZA:
        list.sort((a, b) => b.contactName.toLowerCase().compareTo(a.contactName.toLowerCase()));
        break;
      case LeadSortOption.followUpSoonest:
        list.sort((a, b) {
          if (a.nextFollowUpDate == null && b.nextFollowUpDate == null) return 0;
          if (a.nextFollowUpDate == null) return 1;
          if (b.nextFollowUpDate == null) return -1;
          return a.nextFollowUpDate!.compareTo(b.nextFollowUpDate!);
        });
        break;
    }

    return list;
  }

  @override
  Future<LeadEntity?> getLeadById(String id) async {
    final box = hiveService.getBox(HiveService.boxLeads);
    final val = box.get(id);
    if (val is Map) {
      return _mapToLead(val);
    }
    return null;
  }

  @override
  Future<LeadEntity> createLead(
    LeadEntity lead, {
    LeadFollowUpEntity? initialFollowUp,
  }) async {
    final box = hiveService.getBox(HiveService.boxLeads);
    final String leadId = lead.id.isNotEmpty ? lead.id : 'lead_${DateTime.now().millisecondsSinceEpoch}';

    DateTime? nextFupDate = lead.nextFollowUpDate;
    String? nextFupTime = lead.nextFollowUpTime;
    String? nextFupNotes = lead.nextFollowUpNotes;

    if (initialFollowUp != null) {
      nextFupDate = initialFollowUp.dueDate;
      nextFupTime = initialFollowUp.dueTime;
      nextFupNotes = initialFollowUp.notes;
    }

    final localLead = lead.copyWith(
      id: leadId,
      createdAt: lead.createdAt,
      updatedAt: DateTime.now(),
      nextFollowUpDate: nextFupDate,
      nextFollowUpTime: nextFupTime,
      nextFollowUpNotes: nextFupNotes,
    );

    await box.put(leadId, _leadToMap(localLead, syncStatus: 'synced'));

    // Record Lead Created Activity
    await addLeadActivity(LeadActivityEntity(
      id: 'act_${const Uuid().v4()}',
      leadId: leadId,
      title: 'Lead Created',
      description: 'Lead profile "${localLead.contactName}" created in ${localLead.source}',
      eventType: 'CREATED',
      timestamp: DateTime.now(),
      user: localLead.createdBy,
    ));

    // Record initial follow up if provided
    if (initialFollowUp != null) {
      final fup = initialFollowUp.copyWith(leadId: leadId, leadTitle: localLead.title, contactName: localLead.contactName);
      await addLeadFollowUp(fup);
    }

    if (localLead.stage == LeadStage.won) {
      await _checkAndConvertWonLead(localLead);
    }

    return localLead;
  }

  @override
  Future<LeadEntity> updateLead(LeadEntity lead) async {
    final box = hiveService.getBox(HiveService.boxLeads);
    final updated = lead.copyWith(updatedAt: DateTime.now());
    await box.put(lead.id, _leadToMap(updated, syncStatus: 'synced'));

    await addLeadActivity(LeadActivityEntity(
      id: 'act_${const Uuid().v4()}',
      leadId: lead.id,
      title: 'Lead Edited',
      description: 'Lead details updated by ${updated.assignedStaff}',
      eventType: 'EDITED',
      timestamp: DateTime.now(),
      user: updated.assignedStaff,
    ));

    if (updated.stage == LeadStage.won) {
      await _checkAndConvertWonLead(updated);
    }

    return updated;
  }

  @override
  Future<LeadEntity> updateLeadStage(
    String leadId,
    LeadStage stage, {
    String? lostReason,
    String? updatedBy,
  }) async {
    final box = hiveService.getBox(HiveService.boxLeads);
    final val = box.get(leadId);

    if (val is Map) {
      final oldLead = _mapToLead(val);
      final updated = oldLead.copyWith(
        stage: stage,
        lostReason: lostReason ?? oldLead.lostReason,
        updatedAt: DateTime.now(),
      );

      await box.put(leadId, _leadToMap(updated, syncStatus: 'synced'));

      // Automatically add stage change activity event
      final oldStageName = _stageDisplayName(oldLead.stage);
      final newStageName = _stageDisplayName(stage);
      final desc = stage == LeadStage.lost && lostReason != null && lostReason.isNotEmpty
          ? 'Stage changed from $oldStageName to $newStageName (Reason: $lostReason)'
          : 'Stage changed from $oldStageName to $newStageName';

      await addLeadActivity(LeadActivityEntity(
        id: 'act_${const Uuid().v4()}',
        leadId: leadId,
        title: 'Stage Changed',
        description: desc,
        eventType: 'STAGE_CHANGED',
        timestamp: DateTime.now(),
        user: updatedBy ?? 'Admin',
      ));

      if (stage == LeadStage.won) {
        await _checkAndConvertWonLead(updated);
      }

      return updated;
    }
    throw Exception('Lead not found');
  }

  @override
  Future<void> deleteLead(String id) async {
    final box = hiveService.getBox(HiveService.boxLeads);
    await box.delete(id);
  }

  @override
  Future<void> deleteLeads(List<String> ids) async {
    final box = hiveService.getBox(HiveService.boxLeads);
    await box.deleteAll(ids);
  }

  Future<void> _checkAndConvertWonLead(LeadEntity lead) async {
    if (lead.stage != LeadStage.won || crmCustomerRepository == null) return;

    try {
      final crmCustomerId = 'crm_lead_${lead.id}';

      // Check if already converted by ID or Phone to avoid duplicate CRM customer
      final existingCustomers = await crmCustomerRepository!.getCrmCustomers();
      final alreadyConverted = existingCustomers.any((c) =>
          c.id == crmCustomerId ||
          (c.phone.isNotEmpty && c.phone == lead.phone));

      if (!alreadyConverted) {
        final crmCust = CrmCustomerEntity(
          id: crmCustomerId,
          name: lead.contactName.isNotEmpty ? lead.contactName : lead.title,
          phone: lead.phone,
          email: lead.email,
          address: lead.address,
          companyName: lead.companyName,
          source: lead.source,
          status: 'Active',
          notes: 'Converted from Lead "${lead.title}". Notes: ${lead.notes}',
          assignedStaff: lead.assignedStaff,
          createdAt: DateTime.now(),
        );

        await crmCustomerRepository!.createCrmCustomer(crmCust);

        await addLeadActivity(LeadActivityEntity(
          id: 'act_${const Uuid().v4()}',
          leadId: lead.id,
          title: 'Converted to CRM Customer',
          description:
              'Lead marked as WON and automatically converted to CRM Customer "${crmCust.name}".',
          eventType: 'CONVERTED',
          timestamp: DateTime.now(),
          user: lead.assignedStaff,
        ));
      }
    } catch (_) {}
  }

  String _stageDisplayName(LeadStage stage) {
    switch (stage) {
      case LeadStage.newLead:
        return 'New';
      case LeadStage.contacted:
        return 'Contacted';
      case LeadStage.qualified:
        return 'Qualified';
      case LeadStage.proposalSent:
        return 'Proposal';
      case LeadStage.negotiating:
        return 'Negotiation';
      case LeadStage.won:
        return 'Won';
      case LeadStage.lost:
        return 'Lost';
    }
  }

  // ==================== ACTIVITY TIMELINE ====================
  @override
  Future<List<LeadActivityEntity>> getLeadActivities(String leadId) async {
    final box = hiveService.getBox(HiveService.boxLeads);
    final List<LeadActivityEntity> list = [];

    for (var key in box.keys) {
      if (key.toString().startsWith('act_${leadId}_')) {
        final val = box.get(key);
        if (val is Map) {
          list.add(LeadActivityEntity(
            id: val['id']?.toString() ?? key.toString(),
            leadId: leadId,
            title: val['title']?.toString() ?? '',
            description: val['description']?.toString() ?? '',
            eventType: val['eventType']?.toString() ?? 'GENERAL',
            timestamp: DateTime.tryParse(val['timestamp']?.toString() ?? '') ?? DateTime.now(),
            user: val['user']?.toString() ?? 'Admin',
          ));
        }
      }
    }
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  @override
  Future<void> addLeadActivity(LeadActivityEntity activity) async {
    final box = hiveService.getBox(HiveService.boxLeads);
    final key = 'act_${activity.leadId}_${activity.timestamp.millisecondsSinceEpoch}';
    await box.put(key, {
      'id': activity.id,
      'leadId': activity.leadId,
      'title': activity.title,
      'description': activity.description,
      'eventType': activity.eventType,
      'timestamp': activity.timestamp.toIso8601String(),
      'user': activity.user,
    });
  }

  // ==================== NOTES ====================
  @override
  Future<List<LeadNoteEntity>> getLeadNotes(String leadId) async {
    final box = hiveService.getBox(HiveService.boxCrmNotes);
    final List<LeadNoteEntity> list = [];

    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map && val['leadId']?.toString() == leadId) {
        list.add(LeadNoteEntity(
          id: val['id']?.toString() ?? key.toString(),
          leadId: leadId,
          content: val['content']?.toString() ?? '',
          createdBy: val['createdBy']?.toString() ?? 'Admin',
          createdAt: DateTime.tryParse(val['createdAt']?.toString() ?? '') ?? DateTime.now(),
        ));
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<LeadNoteEntity> addLeadNote(LeadNoteEntity note) async {
    final box = hiveService.getBox(HiveService.boxCrmNotes);
    final noteId = note.id.isNotEmpty ? note.id : 'note_${const Uuid().v4()}';
    final newNote = LeadNoteEntity(
      id: noteId,
      leadId: note.leadId,
      content: note.content,
      createdBy: note.createdBy,
      createdAt: note.createdAt,
    );

    await box.put(noteId, {
      'id': noteId,
      'leadId': note.leadId,
      'content': note.content,
      'createdBy': note.createdBy,
      'createdAt': note.createdAt.toIso8601String(),
    });

    // Record Note Added Activity
    await addLeadActivity(LeadActivityEntity(
      id: 'act_${const Uuid().v4()}',
      leadId: note.leadId,
      title: 'Note Added',
      description: '"${note.content}"',
      eventType: 'NOTE_ADDED',
      timestamp: DateTime.now(),
      user: note.createdBy,
    ));

    return newNote;
  }

  @override
  Future<void> deleteLeadNote(String noteId) async {
    final box = hiveService.getBox(HiveService.boxCrmNotes);
    await box.delete(noteId);
  }

  // ==================== FOLLOW-UPS ====================
  @override
  Future<List<LeadFollowUpEntity>> getLeadFollowUps(String leadId) async {
    final box = hiveService.getBox(HiveService.boxCrmFollowUps);
    final List<LeadFollowUpEntity> list = [];

    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map && val['leadId']?.toString() == leadId) {
        list.add(LeadFollowUpEntity(
          id: val['id']?.toString() ?? key.toString(),
          leadId: leadId,
          leadTitle: val['leadTitle']?.toString() ?? '',
          contactName: val['contactName']?.toString() ?? '',
          type: val['type']?.toString() ?? 'CALL',
          dueDate: DateTime.tryParse(val['dueDate']?.toString() ?? '') ?? DateTime.now(),
          dueTime: val['dueTime']?.toString() ?? '10:00 AM',
          reminder: val['reminder'] == true,
          notes: val['notes']?.toString() ?? '',
          assignedStaff: val['assignedStaff']?.toString() ?? 'Self',
          isCompleted: val['isCompleted'] == true,
          createdAt: DateTime.tryParse(val['createdAt']?.toString() ?? '') ?? DateTime.now(),
        ));
      }
    }
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  @override
  Future<LeadFollowUpEntity> addLeadFollowUp(LeadFollowUpEntity followUp) async {
    final box = hiveService.getBox(HiveService.boxCrmFollowUps);
    final fupId = followUp.id.isNotEmpty ? followUp.id : 'fup_${const Uuid().v4()}';
    final newFup = followUp.copyWith(id: fupId);

    await box.put(fupId, {
      'id': fupId,
      'leadId': followUp.leadId,
      'leadTitle': followUp.leadTitle,
      'contactName': followUp.contactName,
      'type': followUp.type,
      'dueDate': followUp.dueDate.toIso8601String(),
      'dueTime': followUp.dueTime,
      'reminder': followUp.reminder,
      'notes': followUp.notes,
      'assignedStaff': followUp.assignedStaff,
      'isCompleted': followUp.isCompleted,
      'createdAt': followUp.createdAt.toIso8601String(),
    });

    // Update lead's next follow-up info
    final leadBox = hiveService.getBox(HiveService.boxLeads);
    final val = leadBox.get(followUp.leadId);
    if (val is Map) {
      final oldLead = _mapToLead(val);
      final updated = oldLead.copyWith(
        nextFollowUpDate: followUp.dueDate,
        nextFollowUpTime: followUp.dueTime,
        nextFollowUpNotes: followUp.notes,
        updatedAt: DateTime.now(),
      );
      await leadBox.put(followUp.leadId, _leadToMap(updated, syncStatus: 'synced'));
    }

    // Record Follow-up Scheduled Activity (Requirement #11)
    await addLeadActivity(LeadActivityEntity(
      id: 'act_${const Uuid().v4()}',
      leadId: followUp.leadId,
      title: 'Follow-up Scheduled',
      description: '${followUp.type} follow-up scheduled for ${followUp.dueDate.day}/${followUp.dueDate.month}/${followUp.dueDate.year} at ${followUp.dueTime}',
      eventType: 'FOLLOWUP_SCHEDULED',
      timestamp: DateTime.now(),
      user: followUp.assignedStaff,
    ));

    return newFup;
  }

  @override
  Future<void> toggleFollowUpCompletion(String followUpId) async {
    final box = hiveService.getBox(HiveService.boxCrmFollowUps);
    final val = box.get(followUpId);
    if (val is Map) {
      final isComp = val['isCompleted'] == true;
      val['isCompleted'] = !isComp;
      await box.put(followUpId, val);

      final leadId = val['leadId']?.toString() ?? '';
      if (leadId.isNotEmpty) {
        await addLeadActivity(LeadActivityEntity(
          id: 'act_${const Uuid().v4()}',
          leadId: leadId,
          title: !isComp ? 'Follow-up Completed' : 'Follow-up Reopened',
          description: '${val['type']} follow-up marked as ${!isComp ? "completed" : "pending"}',
          eventType: 'FOLLOWUP_COMPLETED',
          timestamp: DateTime.now(),
          user: val['assignedStaff']?.toString() ?? 'Admin',
        ));
      }
    }
  }

  @override
  Future<List<FollowUpTaskEntity>> getFollowUpTasks({bool? completedOnly}) async {
    return [];
  }

  @override
  Future<FollowUpTaskEntity> createFollowUpTask(FollowUpTaskEntity task) async {
    return task;
  }

  @override
  Future<void> toggleTaskCompletion(String taskId) async {}
}
