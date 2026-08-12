import '../../domain/entities/lead_entity.dart';
import '../../domain/repositories/lead_repository.dart';
import '../storage/hive_service.dart';

class LeadRepositoryImpl implements LeadRepository {
  final HiveService hiveService;
  final List<LeadEntity> _leads = [];
  final List<FollowUpTaskEntity> _tasks = [];

  LeadRepositoryImpl({required this.hiveService});

  @override
  Future<List<LeadEntity>> getLeads({LeadStage? stage}) async {
    if (stage != null) {
      return _leads.where((l) => l.stage == stage).toList();
    }
    return List.unmodifiable(_leads);
  }

  @override
  Future<LeadEntity> createLead(LeadEntity lead) async {
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
