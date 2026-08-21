import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/crm_customer_entity.dart';
import '../../domain/repositories/crm_customer_repository.dart';

// Events
abstract class CrmCustomerEvent extends Equatable {
  const CrmCustomerEvent();
  @override
  List<Object?> get props => [];
}

class FetchCrmCustomersEvent extends CrmCustomerEvent {
  final String? query;
  const FetchCrmCustomersEvent({this.query});

  @override
  List<Object?> get props => [query];
}


class UpdateCrmCustomerEvent extends CrmCustomerEvent {
  final CrmCustomerEntity customer;
  const UpdateCrmCustomerEvent(this.customer);

  @override
  List<Object?> get props => [customer];
}

class DeleteCrmCustomerEvent extends CrmCustomerEvent {
  final String id;
  const DeleteCrmCustomerEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class _OnCrmBoxChangedEvent extends CrmCustomerEvent {
  const _OnCrmBoxChangedEvent();
}

// States
abstract class CrmCustomerState extends Equatable {
  const CrmCustomerState();
  @override
  List<Object?> get props => [];
}

class CrmCustomerInitialState extends CrmCustomerState {}

class CrmCustomerLoadingState extends CrmCustomerState {}

class CrmCustomersLoadedState extends CrmCustomerState {
  final List<CrmCustomerEntity> customers;
  final String query;

  const CrmCustomersLoadedState(
    this.customers, {
    this.query = '',
  });

  @override
  List<Object?> get props => [customers, query];
}

class CrmCustomerErrorState extends CrmCustomerState {
  final String message;
  const CrmCustomerErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class CrmCustomerBloc extends Bloc<CrmCustomerEvent, CrmCustomerState> {
  final CrmCustomerRepository repository;
  StreamSubscription<List<CrmCustomerEntity>>? _boxSubscription;
  String _activeQuery = '';

  CrmCustomerBloc({required this.repository}) : super(CrmCustomerInitialState()) {
    on<FetchCrmCustomersEvent>(_onFetchCrmCustomers);
    on<UpdateCrmCustomerEvent>(_onUpdateCrmCustomer);
    on<DeleteCrmCustomerEvent>(_onDeleteCrmCustomer);
    on<_OnCrmBoxChangedEvent>(_onBoxChanged);

    // Watch Hive box for reactive updates (e.g., when a Lead is converted to Customer)
    _boxSubscription = repository.watchCrmCustomers().listen((_) {
      add(const _OnCrmBoxChangedEvent());
    });
  }

  @override
  Future<void> close() {
    _boxSubscription?.cancel();
    return super.close();
  }

  Future<void> _onFetchCrmCustomers(
      FetchCrmCustomersEvent event, Emitter<CrmCustomerState> emit) async {
    _activeQuery = event.query ?? _activeQuery;
    if (state is! CrmCustomersLoadedState) {
      emit(CrmCustomerLoadingState());
    }
    try {
      final customers = await repository.getCrmCustomers(query: _activeQuery);
      emit(CrmCustomersLoadedState(customers, query: _activeQuery));
    } catch (e) {
      emit(CrmCustomerErrorState(e.toString()));
    }
  }

  Future<void> _onBoxChanged(
      _OnCrmBoxChangedEvent event, Emitter<CrmCustomerState> emit) async {
    try {
      final customers = await repository.getCrmCustomers(query: _activeQuery);
      emit(CrmCustomersLoadedState(customers, query: _activeQuery));
    } catch (e) {
      emit(CrmCustomerErrorState(e.toString()));
    }
  }


  Future<void> _onUpdateCrmCustomer(
      UpdateCrmCustomerEvent event, Emitter<CrmCustomerState> emit) async {
    try {
      await repository.updateCrmCustomer(event.customer);
      final customers = await repository.getCrmCustomers(query: _activeQuery);
      emit(CrmCustomersLoadedState(customers, query: _activeQuery));
    } catch (e) {
      emit(CrmCustomerErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteCrmCustomer(
      DeleteCrmCustomerEvent event, Emitter<CrmCustomerState> emit) async {
    try {
      await repository.deleteCrmCustomer(event.id);
      final customers = await repository.getCrmCustomers(query: _activeQuery);
      emit(CrmCustomersLoadedState(customers, query: _activeQuery));
    } catch (e) {
      emit(CrmCustomerErrorState(e.toString()));
    }
  }
}

