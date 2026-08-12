import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';

// Events
abstract class CustomerEvent extends Equatable {
  const CustomerEvent();
  @override
  List<Object?> get props => [];
}

class FetchCustomersEvent extends CustomerEvent {
  final String? query;
  const FetchCustomersEvent({this.query});

  @override
  List<Object?> get props => [query];
}

class CreateCustomerEvent extends CustomerEvent {
  final CustomerEntity customer;
  const CreateCustomerEvent(this.customer);

  @override
  List<Object?> get props => [customer];
}

class FetchCustomerTimelineEvent extends CustomerEvent {
  final String customerId;
  const FetchCustomerTimelineEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

// States
abstract class CustomerState extends Equatable {
  const CustomerState();
  @override
  List<Object?> get props => [];
}

class CustomerInitialState extends CustomerState {}

class CustomerLoadingState extends CustomerState {}

class CustomersLoadedState extends CustomerState {
  final List<CustomerEntity> customers;
  const CustomersLoadedState(this.customers);

  @override
  List<Object?> get props => [customers];
}

class CustomerTimelineLoadedState extends CustomerState {
  final CustomerEntity customer;
  final List<CustomerTimelineEvent> timeline;
  const CustomerTimelineLoadedState({required this.customer, required this.timeline});

  @override
  List<Object?> get props => [customer, timeline];
}

class CustomerErrorState extends CustomerState {
  final String message;
  const CustomerErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository customerRepository;

  CustomerBloc({required this.customerRepository}) : super(CustomerInitialState()) {
    on<FetchCustomersEvent>(_onFetchCustomers);
    on<CreateCustomerEvent>(_onCreateCustomer);
    on<FetchCustomerTimelineEvent>(_onFetchCustomerTimeline);
  }

  Future<void> _onFetchCustomers(
      FetchCustomersEvent event, Emitter<CustomerState> emit) async {
    emit(CustomerLoadingState());
    try {
      final customers = await customerRepository.getCustomers(query: event.query);
      emit(CustomersLoadedState(customers));
    } catch (e) {
      emit(CustomerErrorState(e.toString()));
    }
  }

  Future<void> _onCreateCustomer(
      CreateCustomerEvent event, Emitter<CustomerState> emit) async {
    emit(CustomerLoadingState());
    try {
      await customerRepository.createCustomer(event.customer);
      final customers = await customerRepository.getCustomers();
      emit(CustomersLoadedState(customers));
    } catch (e) {
      emit(CustomerErrorState(e.toString()));
    }
  }

  Future<void> _onFetchCustomerTimeline(
      FetchCustomerTimelineEvent event, Emitter<CustomerState> emit) async {
    emit(CustomerLoadingState());
    try {
      final customer = await customerRepository.getCustomer(event.customerId);
      final timeline = await customerRepository.getCustomerTimeline(event.customerId);
      emit(CustomerTimelineLoadedState(customer: customer, timeline: timeline));
    } catch (e) {
      emit(CustomerErrorState(e.toString()));
    }
  }
}
