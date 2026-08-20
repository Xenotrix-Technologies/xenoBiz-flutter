import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/crm_entities.dart';
import '../../infrastructure/services/crm_service.dart';

// EVENTS
abstract class CrmEvent extends Equatable {
  const CrmEvent();

  @override
  List<Object?> get props => [];
}

class FetchCrmDataEvent extends CrmEvent {
  const FetchCrmDataEvent();
}

class ToggleCrmFollowUpEvent extends CrmEvent {
  final String followUpId;

  const ToggleCrmFollowUpEvent(this.followUpId);

  @override
  List<Object?> get props => [followUpId];
}

class SearchCrmDataEvent extends CrmEvent {
  final String query;

  const SearchCrmDataEvent(this.query);

  @override
  List<Object?> get props => [query];
}

// STATES
abstract class CrmState extends Equatable {
  const CrmState();

  @override
  List<Object?> get props => [];
}

class CrmInitialState extends CrmState {}

class CrmLoadingState extends CrmState {}

class CrmLoadedState extends CrmState {
  final CrmDashboardMetrics metrics;
  final List<CrmFollowUpEntity> followUps;
  final CrmSearchResult? searchResult;
  final bool isSearching;
  final String searchQuery;

  const CrmLoadedState({
    required this.metrics,
    required this.followUps,
    this.searchResult,
    this.isSearching = false,
    this.searchQuery = '',
  });

  CrmLoadedState copyWith({
    CrmDashboardMetrics? metrics,
    List<CrmFollowUpEntity>? followUps,
    CrmSearchResult? searchResult,
    bool? isSearching,
    String? searchQuery,
  }) {
    return CrmLoadedState(
      metrics: metrics ?? this.metrics,
      followUps: followUps ?? this.followUps,
      searchResult: searchResult ?? this.searchResult,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [metrics, followUps, searchResult, isSearching, searchQuery];
}

class CrmErrorState extends CrmState {
  final String message;

  const CrmErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// BLOC
class CrmBloc extends Bloc<CrmEvent, CrmState> {
  final CrmService crmService;

  CrmBloc({required this.crmService}) : super(CrmInitialState()) {
    on<FetchCrmDataEvent>(_onFetchCrmData);
    on<ToggleCrmFollowUpEvent>(_onToggleFollowUp);
    on<SearchCrmDataEvent>(_onSearchCrmData);
  }

  Future<void> _onFetchCrmData(FetchCrmDataEvent event, Emitter<CrmState> emit) async {
    emit(CrmLoadingState());
    try {
      final metrics = await crmService.getCrmDashboardMetrics();
      final followUps = crmService.getFollowUps();
      emit(CrmLoadedState(metrics: metrics, followUps: followUps));
    } catch (e) {
      emit(CrmErrorState(e.toString()));
    }
  }

  Future<void> _onToggleFollowUp(ToggleCrmFollowUpEvent event, Emitter<CrmState> emit) async {
    try {
      await crmService.toggleFollowUpStatus(event.followUpId);
      final metrics = await crmService.getCrmDashboardMetrics();
      final followUps = crmService.getFollowUps();

      if (state is CrmLoadedState) {
        final current = state as CrmLoadedState;
        emit(current.copyWith(metrics: metrics, followUps: followUps));
      } else {
        emit(CrmLoadedState(metrics: metrics, followUps: followUps));
      }
    } catch (e) {
      emit(CrmErrorState(e.toString()));
    }
  }

  Future<void> _onSearchCrmData(SearchCrmDataEvent event, Emitter<CrmState> emit) async {
    if (state is! CrmLoadedState) return;
    final currentState = state as CrmLoadedState;

    final q = event.query.trim();
    if (q.isEmpty) {
      emit(currentState.copyWith(
        searchResult: null,
        isSearching: false,
        searchQuery: '',
      ));
      return;
    }

    emit(currentState.copyWith(isSearching: true, searchQuery: q));
    final res = await crmService.searchCrm(q);
    emit(currentState.copyWith(
      searchResult: res,
      isSearching: false,
      searchQuery: q,
    ));
  }
}
