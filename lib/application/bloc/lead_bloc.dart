import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/lead_entity.dart';
import '../../domain/repositories/lead_repository.dart';

// ==================== EVENTS ====================
abstract class LeadEvent extends Equatable {
  const LeadEvent();
  @override
  List<Object?> get props => [];
}

class FetchLeadsEvent extends LeadEvent {
  final LeadFilter? filter;
  final LeadSortOption? sort;
  final String? query;

  const FetchLeadsEvent({this.filter, this.sort, this.query});

  @override
  List<Object?> get props => [filter, sort, query];
}

class CreateLeadEvent extends LeadEvent {
  final LeadEntity lead;
  final LeadFollowUpEntity? initialFollowUp;

  const CreateLeadEvent(this.lead, {this.initialFollowUp});

  @override
  List<Object?> get props => [lead, initialFollowUp];
}

class UpdateLeadEvent extends LeadEvent {
  final LeadEntity lead;

  const UpdateLeadEvent(this.lead);

  @override
  List<Object?> get props => [lead];
}

class UpdateLeadStageEvent extends LeadEvent {
  final String leadId;
  final LeadStage stage;
  final String? lostReason;

  const UpdateLeadStageEvent({
    required this.leadId,
    required this.stage,
    this.lostReason,
  });

  @override
  List<Object?> get props => [leadId, stage, lostReason];
}

class FetchLeadDetailsEvent extends LeadEvent {
  final String leadId;

  const FetchLeadDetailsEvent(this.leadId);

  @override
  List<Object?> get props => [leadId];
}

class AddLeadNoteEvent extends LeadEvent {
  final String leadId;
  final String content;
  final String createdBy;

  const AddLeadNoteEvent({
    required this.leadId,
    required this.content,
    this.createdBy = 'Admin',
  });

  @override
  List<Object?> get props => [leadId, content, createdBy];
}

class DeleteLeadNoteEvent extends LeadEvent {
  final String leadId;
  final String noteId;

  const DeleteLeadNoteEvent({required this.leadId, required this.noteId});

  @override
  List<Object?> get props => [leadId, noteId];
}

class AddLeadFollowUpEvent extends LeadEvent {
  final LeadFollowUpEntity followUp;

  const AddLeadFollowUpEvent(this.followUp);

  @override
  List<Object?> get props => [followUp];
}

class ToggleLeadFollowUpEvent extends LeadEvent {
  final String leadId;
  final String followUpId;

  const ToggleLeadFollowUpEvent({required this.leadId, required this.followUpId});

  @override
  List<Object?> get props => [leadId, followUpId];
}

// ==================== STATES ====================
abstract class LeadState extends Equatable {
  const LeadState();
  @override
  List<Object?> get props => [];
}

class LeadInitialState extends LeadState {}

class LeadLoadingState extends LeadState {}

class LeadsLoadedState extends LeadState {
  final List<LeadEntity> leads;
  final LeadFilter filter;
  final LeadSortOption sort;
  final String searchQuery;
  final LeadEntity? selectedLead;
  final List<LeadActivityEntity> activities;
  final List<LeadNoteEntity> notes;
  final List<LeadFollowUpEntity> followUps;

  const LeadsLoadedState({
    required this.leads,
    this.filter = const LeadFilter(),
    this.sort = LeadSortOption.dateNewest,
    this.searchQuery = '',
    this.selectedLead,
    this.activities = const [],
    this.notes = const [],
    this.followUps = const [],
  });

  LeadsLoadedState copyWith({
    List<LeadEntity>? leads,
    LeadFilter? filter,
    LeadSortOption? sort,
    String? searchQuery,
    LeadEntity? selectedLead,
    List<LeadActivityEntity>? activities,
    List<LeadNoteEntity>? notes,
    List<LeadFollowUpEntity>? followUps,
  }) {
    return LeadsLoadedState(
      leads: leads ?? this.leads,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedLead: selectedLead ?? this.selectedLead,
      activities: activities ?? this.activities,
      notes: notes ?? this.notes,
      followUps: followUps ?? this.followUps,
    );
  }

  @override
  List<Object?> get props => [
        leads,
        filter,
        sort,
        searchQuery,
        selectedLead,
        activities,
        notes,
        followUps,
      ];
}

class LeadErrorState extends LeadState {
  final String message;
  const LeadErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================
class LeadBloc extends Bloc<LeadEvent, LeadState> {
  final LeadRepository leadRepository;

  LeadBloc({required this.leadRepository}) : super(LeadInitialState()) {
    on<FetchLeadsEvent>(_onFetchLeads);
    on<CreateLeadEvent>(_onCreateLead);
    on<UpdateLeadEvent>(_onUpdateLead);
    on<UpdateLeadStageEvent>(_onUpdateLeadStage);
    on<FetchLeadDetailsEvent>(_onFetchLeadDetails);
    on<AddLeadNoteEvent>(_onAddLeadNote);
    on<DeleteLeadNoteEvent>(_onDeleteLeadNote);
    on<AddLeadFollowUpEvent>(_onAddLeadFollowUp);
    on<ToggleLeadFollowUpEvent>(_onToggleLeadFollowUp);
  }

  Future<void> _onFetchLeads(FetchLeadsEvent event, Emitter<LeadState> emit) async {
    final curState = state;
    LeadFilter activeFilter = event.filter ?? (curState is LeadsLoadedState ? curState.filter : const LeadFilter());
    LeadSortOption activeSort = event.sort ?? (curState is LeadsLoadedState ? curState.sort : LeadSortOption.dateNewest);
    String activeQuery = event.query ?? (curState is LeadsLoadedState ? curState.searchQuery : '');

    emit(LeadLoadingState());
    try {
      final leads = await leadRepository.getLeads(
        filter: activeFilter,
        sort: activeSort,
        query: activeQuery,
      );
      emit(LeadsLoadedState(
        leads: leads,
        filter: activeFilter,
        sort: activeSort,
        searchQuery: activeQuery,
      ));
    } catch (e) {
      emit(LeadErrorState(e.toString()));
    }
  }

  Future<void> _onCreateLead(CreateLeadEvent event, Emitter<LeadState> emit) async {
    try {
      await leadRepository.createLead(event.lead, initialFollowUp: event.initialFollowUp);
      add(const FetchLeadsEvent());
    } catch (e) {
      emit(LeadErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateLead(UpdateLeadEvent event, Emitter<LeadState> emit) async {
    try {
      final updated = await leadRepository.updateLead(event.lead);
      add(FetchLeadDetailsEvent(updated.id));
      add(const FetchLeadsEvent());
    } catch (e) {
      emit(LeadErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateLeadStage(UpdateLeadStageEvent event, Emitter<LeadState> emit) async {
    try {
      final updated = await leadRepository.updateLeadStage(
        event.leadId,
        event.stage,
        lostReason: event.lostReason,
      );
      add(FetchLeadDetailsEvent(updated.id));
      add(const FetchLeadsEvent());
    } catch (e) {
      emit(LeadErrorState(e.toString()));
    }
  }

  Future<void> _onFetchLeadDetails(FetchLeadDetailsEvent event, Emitter<LeadState> emit) async {
    try {
      final lead = await leadRepository.getLeadById(event.leadId);
      if (lead != null) {
        final activities = await leadRepository.getLeadActivities(event.leadId);
        final notes = await leadRepository.getLeadNotes(event.leadId);
        final followUps = await leadRepository.getLeadFollowUps(event.leadId);

        if (state is LeadsLoadedState) {
          final cur = state as LeadsLoadedState;
          emit(cur.copyWith(
            selectedLead: lead,
            activities: activities,
            notes: notes,
            followUps: followUps,
          ));
        } else {
          final leads = await leadRepository.getLeads();
          emit(LeadsLoadedState(
            leads: leads,
            selectedLead: lead,
            activities: activities,
            notes: notes,
            followUps: followUps,
          ));
        }
      }
    } catch (e) {
      emit(LeadErrorState(e.toString()));
    }
  }

  Future<void> _onAddLeadNote(AddLeadNoteEvent event, Emitter<LeadState> emit) async {
    try {
      await leadRepository.addLeadNote(LeadNoteEntity(
        id: '',
        leadId: event.leadId,
        content: event.content,
        createdBy: event.createdBy,
        createdAt: DateTime.now(),
      ));
      add(FetchLeadDetailsEvent(event.leadId));
    } catch (e) {
      emit(LeadErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteLeadNote(DeleteLeadNoteEvent event, Emitter<LeadState> emit) async {
    try {
      await leadRepository.deleteLeadNote(event.noteId);
      add(FetchLeadDetailsEvent(event.leadId));
    } catch (e) {
      emit(LeadErrorState(e.toString()));
    }
  }

  Future<void> _onAddLeadFollowUp(AddLeadFollowUpEvent event, Emitter<LeadState> emit) async {
    try {
      await leadRepository.addLeadFollowUp(event.followUp);
      add(FetchLeadDetailsEvent(event.followUp.leadId));
    } catch (e) {
      emit(LeadErrorState(e.toString()));
    }
  }

  Future<void> _onToggleLeadFollowUp(ToggleLeadFollowUpEvent event, Emitter<LeadState> emit) async {
    try {
      await leadRepository.toggleFollowUpCompletion(event.followUpId);
      add(FetchLeadDetailsEvent(event.leadId));
    } catch (e) {
      emit(LeadErrorState(e.toString()));
    }
  }
}
