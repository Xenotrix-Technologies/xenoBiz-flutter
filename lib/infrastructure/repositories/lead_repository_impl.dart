import '../../domain/entities/lead_entity.dart';
import '../../domain/repositories/lead_repository.dart';
import '../network/dio_client.dart';
import '../storage/hive_service.dart';

class LeadRepositoryImpl implements LeadRepository {
  final DioClient dioClient;
  final HiveService hiveService;
  final List<LeadEntity> _leads = [];
  final List<FollowUpTaskEntity> _tasks = [];

  LeadRepositoryImpl({
    required this.dioClient,
    required this.hiveService,
  });

  LeadStage _parseStage(String? stageStr) {
    if (stageStr == 'won' || stageStr == 'Won') return LeadStage.won;
    if (stageStr == 'lost' || stageStr == 'Lost') return LeadStage.lost;
    if (stageStr == 'Proposal' || stageStr == 'proposal') return LeadStage.proposalSent;
    if (stageStr == 'Negotiation' || stageStr == 'negotiating') return LeadStage.negotiating;
    if (stageStr == 'Contacted' || stageStr == 'contacted') return LeadStage.contacted;
    return LeadStage.newLead;
  }

  @override
  Future<List<LeadEntity>> getLeads({LeadStage? stage}) async {
    try {
      final response = await dioClient.dio.get('/crm/leads');
      if (response.data != null && response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        final fetched = list.map((item) {
          return LeadEntity(
            id: item['id'],
            title: item['title'] ?? 'Deal',
            contactName: item['contact_name'] ?? 'Contact',
            phone: item['contact_phone'] ?? '',
            email: item['contact_email'] ?? '',
            estimatedValue: (item['lead_value'] as num?)?.toDouble() ?? 0.0,
            stage: _parseStage(item['stage_name'] ?? item['status']),
            notes: item['notes'] ?? '',
            createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
          );
        }).toList();

        _leads.clear();
        _leads.addAll(fetched);

        if (stage != null) {
          return fetched.where((l) => l.stage == stage).toList();
        }
        return fetched;
      }
    } catch (_) {}

    if (stage != null) {
      return _leads.where((l) => l.stage == stage).toList();
    }
    return List.unmodifiable(_leads);
  }

  @override
  Future<LeadEntity> createLead(LeadEntity lead) async {
    try {
      final response = await dioClient.dio.post(
        '/crm/leads',
        data: {
          'title': lead.title,
          'contactName': lead.contactName,
          'contactPhone': lead.phone,
          'contactEmail': lead.email,
          'leadValue': lead.estimatedValue,
          'notes': lead.notes,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final item = response.data['data'];
        final created = lead.copyWith(id: item['id']);
        _leads.insert(0, created);
        return created;
      }
    } catch (_) {}

    _leads.insert(0, lead);
    return lead;
  }

  @override
  Future<LeadEntity> updateLeadStage(String leadId, LeadStage stage) async {
    final index = _leads.indexWhere((l) => l.id == leadId);
    if (index != -1) {
      _leads[index] = _leads[index].copyWith(stage: stage);
      return _leads[index];
    }
    throw Exception('Lead not found');
  }

  @override
  Future<List<FollowUpTaskEntity>> getFollowUpTasks({bool? completedOnly}) async {
    if (completedOnly != null) {
      return _tasks.where((t) => t.isCompleted == completedOnly).toList();
    }
    return List.unmodifiable(_tasks);
  }

  @override
  Future<FollowUpTaskEntity> createFollowUpTask(FollowUpTaskEntity task) async {
    _tasks.insert(0, task);
    return task;
  }

  @override
  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final old = _tasks[index];
      _tasks[index] = FollowUpTaskEntity(
        id: old.id,
        leadId: old.leadId,
        title: old.title,
        type: old.type,
        dueDate: old.dueDate,
        isCompleted: !old.isCompleted,
        notes: old.notes,
      );
    }
  }
}

