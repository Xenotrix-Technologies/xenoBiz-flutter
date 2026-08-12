import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';

// Events
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();
  @override
  List<Object?> get props => [];
}

class CheckEntitlementEvent extends SubscriptionEvent {
  final String businessId;

  const CheckEntitlementEvent(this.businessId);

  @override
  List<Object?> get props => [businessId];
}

class PurchasePlanEvent extends SubscriptionEvent {
  final String businessId;
  final String planId;

  const PurchasePlanEvent({required this.businessId, required this.planId});

  @override
  List<Object?> get props => [businessId, planId];
}

class RestorePurchaseEvent extends SubscriptionEvent {
  final String businessId;

  const RestorePurchaseEvent(this.businessId);

  @override
  List<Object?> get props => [businessId];
}

// States
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();
  @override
  List<Object?> get props => [];
}

class SubscriptionInitialState extends SubscriptionState {}

class SubscriptionLoadingState extends SubscriptionState {}

class SubscriptionLoadedState extends SubscriptionState {
  final SubscriptionEntity subscription;

  const SubscriptionLoadedState(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionErrorState extends SubscriptionState {
  final String message;

  const SubscriptionErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository subscriptionRepository;

  SubscriptionBloc({required this.subscriptionRepository})
      : super(SubscriptionInitialState()) {
    on<CheckEntitlementEvent>(_onCheckEntitlement);
    on<PurchasePlanEvent>(_onPurchasePlan);
    on<RestorePurchaseEvent>(_onRestorePurchase);
  }

  Future<void> _onCheckEntitlement(
      CheckEntitlementEvent event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoadingState());
    try {
      final sub = await subscriptionRepository.checkEntitlement(event.businessId);
      emit(SubscriptionLoadedState(sub));
    } catch (e) {
      emit(SubscriptionErrorState(e.toString()));
    }
  }

  Future<void> _onPurchasePlan(
      PurchasePlanEvent event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoadingState());
    try {
      final sub = await subscriptionRepository.purchasePlan(event.businessId, event.planId);
      emit(SubscriptionLoadedState(sub));
    } catch (e) {
      emit(SubscriptionErrorState(e.toString()));
    }
  }

  Future<void> _onRestorePurchase(
      RestorePurchaseEvent event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoadingState());
    try {
      final sub = await subscriptionRepository.restorePurchase(event.businessId);
      emit(SubscriptionLoadedState(sub));
    } catch (e) {
      emit(SubscriptionErrorState(e.toString()));
    }
  }
}
