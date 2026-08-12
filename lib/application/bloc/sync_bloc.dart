import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/sync_item_entity.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../infrastructure/network/network_checker.dart';

// Events
abstract class SyncEvent extends Equatable {
  const SyncEvent();
  @override
  List<Object?> get props => [];
}

class FetchSyncQueueEvent extends SyncEvent {}

class TriggerSyncNowEvent extends SyncEvent {}

// States
abstract class SyncState extends Equatable {
  const SyncState();
  @override
  List<Object?> get props => [];
}

class SyncInitialState extends SyncState {}

class SyncLoadingState extends SyncState {}

class SyncLoadedState extends SyncState {
  final bool isConnected;
  final List<SyncItemEntity> pendingItems;

  const SyncLoadedState({required this.isConnected, required this.pendingItems});

  @override
  List<Object?> get props => [isConnected, pendingItems];
}

class SyncSuccessState extends SyncState {
  final String message;
  const SyncSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

class SyncErrorState extends SyncState {
  final String message;
  const SyncErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncRepository syncRepository;
  final NetworkChecker networkChecker;

  SyncBloc({required this.syncRepository, required this.networkChecker})
      : super(SyncInitialState()) {
    on<FetchSyncQueueEvent>(_onFetchSyncQueue);
    on<TriggerSyncNowEvent>(_onTriggerSyncNow);
  }

  Future<void> _onFetchSyncQueue(
      FetchSyncQueueEvent event, Emitter<SyncState> emit) async {
    emit(SyncLoadingState());
    try {
      final connected = await networkChecker.isConnected;
      final pending = await syncRepository.getPendingSyncItems();
      emit(SyncLoadedState(isConnected: connected, pendingItems: pending));
    } catch (e) {
      emit(SyncErrorState(e.toString()));
    }
  }

  Future<void> _onTriggerSyncNow(
      TriggerSyncNowEvent event, Emitter<SyncState> emit) async {
    emit(SyncLoadingState());
    try {
      await syncRepository.processSyncQueue();
      await syncRepository.clearCompletedSyncItems();
      emit(const SyncSuccessState('All pending items successfully synchronized!'));
    } catch (e) {
      emit(SyncErrorState(e.toString()));
    }
  }
}
