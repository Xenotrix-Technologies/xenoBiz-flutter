import '../entities/lead_entity.dart';

abstract class LeadRepository {
  Future<List<LeadEntity>> getLeads({LeadStage? stage});
  Future<LeadEntity> createLead(LeadEntity lead);
  Future<LeadEntity> updateLeadStage(String leadId, LeadStage stage);
  Future<List<FollowUpTaskEntity>> getFollowUpTasks({bool? completedOnly});
  Future<FollowUpTaskEntity> createFollowUpTask(FollowUpTaskEntity task);
  Future<void> toggleTaskCompletion(String taskId);
}
