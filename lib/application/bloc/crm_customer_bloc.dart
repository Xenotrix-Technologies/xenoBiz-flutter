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

class CreateCrmCustomerEvent extends CrmCustomerEvent {
  final CrmCustomerEntity customer;
  const CreateCrmCustomerEvent(this.customer);

  @override
  List<Object?> get props => [customer];
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
  const CrmCustomersLoadedState(this.customers);

  @override
  List<Object?> get props => [customers];
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

  CrmCustomerBloc({required this.repository}) : super(CrmCustomerInitialState()) {
    on<FetchCrmCustomersEvent>(_onFetchCrmCustomers);
    on<CreateCrmCustomerEvent>(_onCreateCrmCustomer);
    on<UpdateCrmCustomerEvent>(_onUpdateCrmCustomer);
    on<DeleteCrmCustomerEvent>(_onDeleteCrmCustomer);
  }

  Future<void> _onFetchCrmCustomers(
      FetchCrmCustomersEvent event, Emitter<CrmCustomerState> emit) async {
    emit(CrmCustomerLoadingState());
    try {
      final customers = await repository.getCrmCustomers(query: event.query);
      emit(CrmCustomersLoadedState(customers));
    } catch (e) {
      emit(CrmCustomerErrorState(e.toString()));
    }
  }

  Future<void> _onCreateCrmCustomer(
      CreateCrmCustomerEvent event, Emitter<CrmCustomerState> emit) async {
    emit(CrmCustomerLoadingState());
    try {
      await repository.createCrmCustomer(event.customer);
      final customers = await repository.getCrmCustomers();
      emit(CrmCustomersLoadedState(customers));
    } catch (e) {
      emit(CrmCustomerErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateCrmCustomer(
      UpdateCrmCustomerEvent event, Emitter<CrmCustomerState> emit) async {
    emit(CrmCustomerLoadingState());
    try {
      await repository.updateCrmCustomer(event.customer);
      final customers = await repository.getCrmCustomers();
      emit(CrmCustomersLoadedState(customers));
    } catch (e) {
      emit(CrmCustomerErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteCrmCustomer(
      DeleteCrmCustomerEvent event, Emitter<CrmCustomerState> emit) async {
    emit(CrmCustomerLoadingState());
    try {
      await repository.deleteCrmCustomer(event.id);
      final customers = await repository.getCrmCustomers();
      emit(CrmCustomersLoadedState(customers));
    } catch (e) {
      emit(CrmCustomerErrorState(e.toString()));
    }
  }
}
