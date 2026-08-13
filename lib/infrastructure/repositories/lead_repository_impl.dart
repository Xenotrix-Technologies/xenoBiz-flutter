import 'package:uuid/uuid.dart';
import '../../domain/entities/lead_entity.dart';
import '../../domain/entities/sync_item_entity.dart';
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

  LeadRepositoryImpl({
    required this.dioClient,
    required this.hiveService,
    required this.networkChecker,
    required this.syncRepository,
  });

  LeadStage _parseStage(String? stageStr) {
    if (stageStr == 'won' || stageStr == 'Won' || stageStr == 'LeadStage.won') return LeadStage.won;
    if (stageStr == 'lost' || stageStr == 'Lost' || stageStr == 'LeadStage.lost') return LeadStage.lost;
    if (stageStr == 'Proposal' || stageStr == 'proposal' || stageStr == 'LeadStage.proposalSent') {
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

  Map<String, dynamic> _leadToMap(LeadEntity lead, {String syncStatus = 'synced'}) {
    return {
      'id': lead.id,
      'title': lead.title,
      'contactName': lead.contactName,
      'phone': lead.phone,
      'email': lead.email,
      'estimatedValue': lead.estimatedValue,
      'stage': lead.stage.name,
      'notes': lead.notes,
      'createdAt': lead.createdAt.toIso8601String(),
      'nextFollowUpDate': lead.nextFollowUpDate?.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }

  LeadEntity _mapToLead(Map<dynamic, dynamic> map) {
    return LeadEntity(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Lead',
      contactName: map['contactName']?.toString() ?? map['contact_name']?.toString() ?? 'Contact',
      phone: map['phone']?.toString() ?? map['contact_phone']?.toString() ?? '',
      email: map['email']?.toString() ?? map['contact_email']?.toString() ?? '',
      estimatedValue: (map['estimatedValue'] as num?)?.toDouble() ??
          (map['lead_value'] as num?)?.toDouble() ?? 0.0,
      stage: _parseStage(map['stage']?.toString() ?? map['stage_name']?.toString() ?? map['status']?.toString()),
      notes: map['notes']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? map['created_at']?.toString() ?? '') ?? DateTime.now(),
      nextFollowUpDate: DateTime.tryParse(map['nextFollowUpDate']?.toString() ?? ''),
    );
  }

  @override
  Future<List<LeadEntity>> getLeads({LeadStage? stage}) async {
    final box = hiveService.getBox(HiveService.boxLeads);
    final List<LeadEntity> list = [];

    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        final lead = _mapToLead(val);
        if (stage == null || lead.stage == stage) {
          list.add(lead);
        }
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<LeadEntity> createLead(LeadEntity lead) async {
    final box = hiveService.getBox(HiveService.boxLeads);
    final String leadId = lead.id.isNotEmpty ? lead.id : const Uuid().v4();
    final localLead = lead.copyWith(id: leadId);

    // 1. Save to Hive
    await box.put(leadId, _leadToMap(localLead, syncStatus: 'pendingCreate'));

    // 2. Try online sync
    if (await networkChecker.isConnected) {
      try {
        final response = await dioClient.dio.post(
          '/crm/leads',
          data: {
            'title': localLead.title,
            'contactName': localLead.contactName,
            'contactPhone': localLead.phone,
            'contactEmail': localLead.email,
            'leadValue': localLead.estimatedValue,
            'notes': localLead.notes,
          },
        );

        if (response.data != null && response.data['success'] == true) {
          final item = response.data['data'];
          final serverId = item['id']?.toString() ?? leadId;
          final synced = localLead.copyWith(id: serverId);
          if (serverId != leadId) {
            await box.delete(leadId);
          }
          await box.put(serverId, _leadToMap(synced, syncStatus: 'synced'));
          return synced;
        }
      } catch (_) {}
    }

    // 3. Enqueue
    await syncRepository.enqueueSyncItem(
      SyncItemEntity(
        id: const Uuid().v4(),
        entityType: 'LEAD',
        action: SyncAction.create,
        payload: {
          'localId': leadId,
          'title': localLead.title,
          'contactName': localLead.contactName,
          'contactPhone': localLead.phone,
          'contactEmail': localLead.email,
          'leadValue': localLead.estimatedValue,
          'notes': localLead.notes,
        },
        createdAt: DateTime.now(),
      ),
    );

    return localLead;
  }

  @override
  Future<LeadEntity> updateLeadStage(String leadId, LeadStage stage) async {
    final box = hiveService.getBox(HiveService.boxLeads);
    final val = box.get(leadId);

    if (val is Map) {
      final lead = _mapToLead(val);
      final updated = lead.copyWith(stage: stage);
      await box.put(leadId, _leadToMap(updated, syncStatus: 'pendingUpdate'));

      if (await networkChecker.isConnected) {
        try {
          await dioClient.dio.put(
            '/crm/leads/$leadId',
            data: {
              'stage': stage.name,
            },
          );
          await box.put(leadId, _leadToMap(updated, syncStatus: 'synced'));
          return updated;
        } catch (_) {}
      }

      await syncRepository.enqueueSyncItem(
        SyncItemEntity(
          id: const Uuid().v4(),
          entityType: 'LEAD',
          action: SyncAction.update,
          payload: {
            'id': leadId,
            'stage': stage.name,
          },
          createdAt: DateTime.now(),
        ),
      );

      return updated;
    }
    throw Exception('Lead not found');
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
