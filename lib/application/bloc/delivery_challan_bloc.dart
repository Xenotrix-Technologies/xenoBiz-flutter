import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/delivery_challan_entity.dart';
import '../../domain/repositories/delivery_challan_repository.dart';
import '../../infrastructure/services/voucher_sequence_service.dart';

// Events
abstract class DeliveryChallanEvent extends Equatable {
  const DeliveryChallanEvent();
  @override
  List<Object?> get props => [];
}

class FetchDeliveryChallansEvent extends DeliveryChallanEvent {
  final String? query;
  final DeliveryChallanStatus? statusFilter;
  final String sortOption;

  const FetchDeliveryChallansEvent({
    this.query,
    this.statusFilter,
    this.sortOption = 'newest',
  });

  @override
  List<Object?> get props => [query, statusFilter, sortOption];
}

class CreateDeliveryChallanSubmittedEvent extends DeliveryChallanEvent {
  final DeliveryChallanEntity challan;
  const CreateDeliveryChallanSubmittedEvent(this.challan);

  @override
  List<Object?> get props => [challan];
}

class UpdateDeliveryChallanSubmittedEvent extends DeliveryChallanEvent {
  final DeliveryChallanEntity challan;
  const UpdateDeliveryChallanSubmittedEvent(this.challan);

  @override
  List<Object?> get props => [challan];
}

class DeleteDeliveryChallanSubmittedEvent extends DeliveryChallanEvent {
  final String challanId;
  const DeleteDeliveryChallanSubmittedEvent(this.challanId);

  @override
  List<Object?> get props => [challanId];
}

// States
abstract class DeliveryChallanState extends Equatable {
  const DeliveryChallanState();
  @override
  List<Object?> get props => [];
}

class DeliveryChallansInitialState extends DeliveryChallanState {}

class DeliveryChallansLoadingState extends DeliveryChallanState {}

class DeliveryChallansLoadedState extends DeliveryChallanState {
  final List<DeliveryChallanEntity> allChallans;
  final List<DeliveryChallanEntity> filteredChallans;
  final String searchQuery;
  final DeliveryChallanStatus? selectedStatus;
  final String sortOption;

  const DeliveryChallansLoadedState({
    required this.allChallans,
    required this.filteredChallans,
    this.searchQuery = '',
    this.selectedStatus,
    this.sortOption = 'newest',
  });

  @override
  List<Object?> get props => [
        allChallans,
        filteredChallans,
        searchQuery,
        selectedStatus,
        sortOption,
      ];
}

class DeliveryChallanOperationSuccessState extends DeliveryChallanState {
  final String message;
  const DeliveryChallanOperationSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

class DeliveryChallanErrorState extends DeliveryChallanState {
  final String message;
  const DeliveryChallanErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class DeliveryChallanBloc extends Bloc<DeliveryChallanEvent, DeliveryChallanState> {
  final DeliveryChallanRepository repository;

  DeliveryChallanBloc({required this.repository})
      : super(DeliveryChallansInitialState()) {
    on<FetchDeliveryChallansEvent>(_onFetchDeliveryChallans);
    on<CreateDeliveryChallanSubmittedEvent>(_onCreateDeliveryChallan);
    on<UpdateDeliveryChallanSubmittedEvent>(_onUpdateDeliveryChallan);
    on<DeleteDeliveryChallanSubmittedEvent>(_onDeleteDeliveryChallan);
  }

  Future<void> _onFetchDeliveryChallans(
      FetchDeliveryChallansEvent event, Emitter<DeliveryChallanState> emit) async {
    emit(DeliveryChallansLoadingState());
    try {
      final all = await repository.getDeliveryChallans();
      var filtered = List<DeliveryChallanEntity>.from(all);

      if (event.query != null && event.query!.isNotEmpty) {
        final q = event.query!.toLowerCase();
        filtered = filtered.where((c) {
          return c.challanNumber.toLowerCase().contains(q) ||
              c.customerName.toLowerCase().contains(q) ||
              c.customerPhone.toLowerCase().contains(q);
        }).toList();
      }

      if (event.statusFilter != null) {
        filtered = filtered.where((c) => c.status == event.statusFilter).toList();
      }

      // Sorting
      switch (event.sortOption) {
        case 'oldest':
          filtered.sort((a, b) => a.issueDate.compareTo(b.issueDate));
          break;
        case 'challan_date_newest':
          filtered.sort((a, b) => (b.deliveryDate ?? b.issueDate).compareTo(a.deliveryDate ?? a.issueDate));
          break;
        case 'challan_date_oldest':
          filtered.sort((a, b) => (a.deliveryDate ?? a.issueDate).compareTo(b.deliveryDate ?? b.issueDate));
          break;
        case 'number_asc':
          filtered.sort((a, b) => a.challanNumber.compareTo(b.challanNumber));
          break;
        case 'party_asc':
          filtered.sort((a, b) => a.customerName.compareTo(b.customerName));
          break;
        case 'newest':
        default:
          filtered.sort((a, b) => b.issueDate.compareTo(a.issueDate));
          break;
      }

      emit(DeliveryChallansLoadedState(
        allChallans: all,
        filteredChallans: filtered,
        searchQuery: event.query ?? '',
        selectedStatus: event.statusFilter,
        sortOption: event.sortOption,
      ));
    } catch (e) {
      emit(DeliveryChallanErrorState(e.toString()));
    }
  }

  Future<void> _onCreateDeliveryChallan(
      CreateDeliveryChallanSubmittedEvent event, Emitter<DeliveryChallanState> emit) async {
    try {
      await repository.createDeliveryChallan(event.challan);
      await VoucherSequenceService.instance
          .incrementSequence(VoucherType.deliveryChallan);
      emit(DeliveryChallanOperationSuccessState(
          'Delivery Challan #${event.challan.challanNumber} created successfully!'));
      add(const FetchDeliveryChallansEvent());
    } catch (e) {
      emit(DeliveryChallanErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateDeliveryChallan(
      UpdateDeliveryChallanSubmittedEvent event, Emitter<DeliveryChallanState> emit) async {
    try {
      await repository.updateDeliveryChallan(event.challan);
      emit(DeliveryChallanOperationSuccessState(
          'Delivery Challan #${event.challan.challanNumber} updated successfully!'));
      add(const FetchDeliveryChallansEvent());
    } catch (e) {
      emit(DeliveryChallanErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteDeliveryChallan(
      DeleteDeliveryChallanSubmittedEvent event, Emitter<DeliveryChallanState> emit) async {
    try {
      await repository.deleteDeliveryChallan(event.challanId);
      emit(const DeliveryChallanOperationSuccessState('Delivery Challan deleted successfully!'));
      add(const FetchDeliveryChallansEvent());
    } catch (e) {
      emit(DeliveryChallanErrorState(e.toString()));
    }
  }
}
