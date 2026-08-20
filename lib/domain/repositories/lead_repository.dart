import '../entities/lead_entity.dart';

abstract class LeadRepository {
  Future<List<LeadEntity>> getLeads({
    LeadFilter? filter,
    LeadSortOption? sort,
    String? query,
  });

  Future<LeadEntity?> getLeadById(String id);

  Future<LeadEntity> createLead(
    LeadEntity lead, {
    LeadFollowUpEntity? initialFollowUp,
  });

  Future<LeadEntity> updateLead(LeadEntity lead);

  Future<LeadEntity> updateLeadStage(
    String leadId,
    LeadStage stage, {
    String? lostReason,
    String? updatedBy,
  });

  // Activity timeline
  Future<List<LeadActivityEntity>> getLeadActivities(String leadId);
  Future<void> addLeadActivity(LeadActivityEntity activity);

  // Notes
  Future<List<LeadNoteEntity>> getLeadNotes(String leadId);
  Future<LeadNoteEntity> addLeadNote(LeadNoteEntity note);
  Future<void> deleteLeadNote(String noteId);

  // Follow-ups
  Future<List<LeadFollowUpEntity>> getLeadFollowUps(String leadId);
  Future<LeadFollowUpEntity> addLeadFollowUp(LeadFollowUpEntity followUp);
  Future<void> toggleFollowUpCompletion(String followUpId);

  Future<List<FollowUpTaskEntity>> getFollowUpTasks({bool? completedOnly});
  Future<FollowUpTaskEntity> createFollowUpTask(FollowUpTaskEntity task);
  Future<void> toggleTaskCompletion(String taskId);
}
