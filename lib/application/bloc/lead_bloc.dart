import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/lead_entity.dart';
import '../../domain/repositories/lead_repository.dart';

// Events
abstract class LeadEvent extends Equatable {
  const LeadEvent();
  @override
  List<Object?> get props => [];
}

class FetchLeadsEvent extends LeadEvent {
  final LeadStage? stage;
  const FetchLeadsEvent({this.stage});

  @override
  List<Object?> get props => [stage];
}

class CreateLeadEvent extends LeadEvent {
  final LeadEntity lead;
  const CreateLeadEvent(this.lead);

  @override
  List<Object?> get props => [lead];
}

class UpdateLeadStageEvent extends LeadEvent {
  final String leadId;
  final LeadStage stage;

  const UpdateLeadStageEvent({required this.leadId, required this.stage});

  @override
  List<Object?> get props => [leadId, stage];
}

class FetchFollowUpTasksEvent extends LeadEvent {}

class ToggleTaskCompletionEvent extends LeadEvent {
  final String taskId;
  const ToggleTaskCompletionEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

// States
abstract class LeadState extends Equatable {
  const LeadState();
  @override
  List<Object?> get props => [];
}

class LeadInitialState extends LeadState {}

class LeadLoadingState extends LeadState {}

class LeadsLoadedState extends LeadState {
  final List<LeadEntity> leads;
  final List<FollowUpTaskEntity> tasks;

  const LeadsLoadedState({required this.leads, required this.tasks});

  @override
  List<Object?> get props => [leads, tasks];
}

class LeadErrorState extends LeadState {
  final String message;
  const LeadErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class LeadBloc extends Bloc<LeadEvent, LeadState> {
  final LeadRepository leadRepository;

  LeadBloc({required this.leadRepository}) : super(LeadInitialState()) {
    on<FetchLeadsEvent>(_onFetchLeads);
    on<CreateLeadEvent>(_onCreateLead);
    on<UpdateLeadStageEvent>(_onUpdateLeadStage);
    on<FetchFollowUpTasksEvent>(_onFetchFollowUpTasks);
    on<ToggleTaskCompletionEvent>(_onToggleTaskCompletion);
  }

  Future<void> _onFetchLeads(FetchLeadsEvent event, Emitter<LeadState> emit) async {
    emit(LeadLoadingState());
    try {
      final leads = await leadRepository.getLeads(stage: event.stage);
      final tasks = await leadRepository.getFollowUpTasks();
      emit(LeadsLoadedState(leads: leads, tasks: tasks));
    } catch (e) {
      emit(LeadErrorState(e.toString()));
    }
  }

  Future<void> _onCreateLead(CreateLeadEvent event, Emitter<LeadState> emit) async {
    emit(LeadLoadingState());
    try {
      await leadRepository.createLead(event.lead);
      final leads = await leadRepository.getLeads();
      final tasks = await leadRepository.getFollowUpTasks();
      emit(LeadsLoadedState(leads: leads, tasks: tasks));
    } catch (e) {
      emit(LeadErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateLeadStage(
      UpdateLeadStageEvent event, Emitter<LeadState> emit) async {
    emit(LeadLoadingState());
    try {
      await leadRepository.updateLeadStage(event.leadId, event.stage);
      final leads = await leadRepository.getLeads();
      final tasks = await leadRepository.getFollowUpTasks();
      emit(LeadsLoadedState(leads: leads, tasks: tasks));
    } catch (e) {
      emit(LeadErrorState(e.toString()));
    }
  }

  Future<void> _onFetchFollowUpTasks(
      FetchFollowUpTasksEvent event, Emitter<LeadState> emit) async {
    emit(LeadLoadingState());
    try {
      final leads = await leadRepository.getLeads();
      final tasks = await leadRepository.getFollowUpTasks();
      emit(LeadsLoadedState(leads: leads, tasks: tasks));
    } catch (e) {
      emit(LeadErrorState(e.toString()));
    }
  }

  Future<void> _onToggleTaskCompletion(
      ToggleTaskCompletionEvent event, Emitter<LeadState> emit) async {
    try {
      await leadRepository.toggleTaskCompletion(event.taskId);
      final leads = await leadRepository.getLeads();
      final tasks = await leadRepository.getFollowUpTasks();
      emit(LeadsLoadedState(leads: leads, tasks: tasks));
    } catch (e) {
      emit(LeadErrorState(e.toString()));
    }
  }
}
