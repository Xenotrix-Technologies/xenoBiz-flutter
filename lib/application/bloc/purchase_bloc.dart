import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../domain/repositories/purchase_repository.dart';

// --- Events ---
abstract class PurchaseEvent extends Equatable {
  const PurchaseEvent();
  @override
  List<Object?> get props => [];
}

class FetchPurchasesEvent extends PurchaseEvent {
  const FetchPurchasesEvent();
}

class FetchSuppliersEvent extends PurchaseEvent {
  const FetchSuppliersEvent();
}

class CreatePurchaseOrderSubmittedEvent extends PurchaseEvent {
  final PurchaseEntity purchase;
  const CreatePurchaseOrderSubmittedEvent(this.purchase);
  @override
  List<Object?> get props => [purchase];
}

class CreateSupplierSubmittedEvent extends PurchaseEvent {
  final SupplierEntity supplier;
  const CreateSupplierSubmittedEvent(this.supplier);
  @override
  List<Object?> get props => [supplier];
}

class UpdateSupplierSubmittedEvent extends PurchaseEvent {
  final SupplierEntity supplier;
  const UpdateSupplierSubmittedEvent(this.supplier);
  @override
  List<Object?> get props => [supplier];
}

// --- States ---
abstract class PurchaseState extends Equatable {
  const PurchaseState();
  @override
  List<Object?> get props => [];
}

class PurchaseInitialState extends PurchaseState {}

class PurchaseLoadingState extends PurchaseState {}

class PurchaseLoadedState extends PurchaseState {
  final List<PurchaseEntity> purchases;
  final List<SupplierEntity> suppliers;

  const PurchaseLoadedState({
    required this.purchases,
    required this.suppliers,
  });

  @override
  List<Object?> get props => [purchases, suppliers];
}

class PurchaseErrorState extends PurchaseState {
  final String message;
  const PurchaseErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final PurchaseRepository purchaseRepository;

  PurchaseBloc({required this.purchaseRepository}) : super(PurchaseInitialState()) {
    on<FetchPurchasesEvent>(_onFetchPurchases);
    on<FetchSuppliersEvent>(_onFetchSuppliers);
    on<CreatePurchaseOrderSubmittedEvent>(_onCreatePurchaseOrder);
    on<CreateSupplierSubmittedEvent>(_onCreateSupplier);
    on<UpdateSupplierSubmittedEvent>(_onUpdateSupplier);
  }

  Future<void> _onFetchPurchases(
      FetchPurchasesEvent event, Emitter<PurchaseState> emit) async {
    emit(PurchaseLoadingState());
    try {
      final purchases = await purchaseRepository.getPurchaseOrders();
      final suppliers = await purchaseRepository.getSuppliers();
      emit(PurchaseLoadedState(purchases: purchases, suppliers: suppliers));
    } catch (e) {
      emit(PurchaseErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFetchSuppliers(
      FetchSuppliersEvent event, Emitter<PurchaseState> emit) async {
    emit(PurchaseLoadingState());
    try {
      final suppliers = await purchaseRepository.getSuppliers();
      final purchases = await purchaseRepository.getPurchaseOrders();
      emit(PurchaseLoadedState(purchases: purchases, suppliers: suppliers));
    } catch (e) {
      emit(PurchaseErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreatePurchaseOrder(
      CreatePurchaseOrderSubmittedEvent event, Emitter<PurchaseState> emit) async {
    emit(PurchaseLoadingState());
    try {
      await purchaseRepository.createPurchaseOrder(event.purchase);
      final purchases = await purchaseRepository.getPurchaseOrders();
      final suppliers = await purchaseRepository.getSuppliers();
      emit(PurchaseLoadedState(purchases: purchases, suppliers: suppliers));
    } catch (e) {
      emit(PurchaseErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateSupplier(
      CreateSupplierSubmittedEvent event, Emitter<PurchaseState> emit) async {
    emit(PurchaseLoadingState());
    try {
      await purchaseRepository.createSupplier(event.supplier);
      final suppliers = await purchaseRepository.getSuppliers();
      final purchases = await purchaseRepository.getPurchaseOrders();
      emit(PurchaseLoadedState(purchases: purchases, suppliers: suppliers));
    } catch (e) {
      emit(PurchaseErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateSupplier(
      UpdateSupplierSubmittedEvent event, Emitter<PurchaseState> emit) async {
    emit(PurchaseLoadingState());
    try {
      await purchaseRepository.updateSupplier(event.supplier);
      final suppliers = await purchaseRepository.getSuppliers();
      final purchases = await purchaseRepository.getPurchaseOrders();
      emit(PurchaseLoadedState(purchases: purchases, suppliers: suppliers));
    } catch (e) {
      emit(PurchaseErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

