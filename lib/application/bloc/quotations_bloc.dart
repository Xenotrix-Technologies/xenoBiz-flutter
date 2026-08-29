import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../infrastructure/services/voucher_sequence_service.dart';

// Events
abstract class QuotationsEvent extends Equatable {
  const QuotationsEvent();
  @override
  List<Object?> get props => [];
}

class FetchQuotationsEvent extends QuotationsEvent {
  final String? query;
  final InvoiceStatus? statusFilter;
  final String sortOption;

  const FetchQuotationsEvent({
    this.query,
    this.statusFilter,
    this.sortOption = 'newest',
  });

  @override
  List<Object?> get props => [query, statusFilter, sortOption];
}

class DuplicateQuotationEvent extends QuotationsEvent {
  final InvoiceEntity quotation;
  const DuplicateQuotationEvent(this.quotation);

  @override
  List<Object?> get props => [quotation];
}

class DeleteQuotationEvent extends QuotationsEvent {
  final String quotationId;
  const DeleteQuotationEvent(this.quotationId);

  @override
  List<Object?> get props => [quotationId];
}

// States
abstract class QuotationsState extends Equatable {
  const QuotationsState();
  @override
  List<Object?> get props => [];
}

class QuotationsInitialState extends QuotationsState {}

class QuotationsLoadingState extends QuotationsState {}

class QuotationsLoadedState extends QuotationsState {
  final List<InvoiceEntity> allQuotations;
  final List<InvoiceEntity> filteredQuotations;
  final String searchQuery;
  final InvoiceStatus? selectedStatus;
  final String sortOption;
  final double totalEstimateValue;

  const QuotationsLoadedState({
    required this.allQuotations,
    required this.filteredQuotations,
    this.searchQuery = '',
    this.selectedStatus,
    this.sortOption = 'newest',
    required this.totalEstimateValue,
  });

  @override
  List<Object?> get props => [
        allQuotations,
        filteredQuotations,
        searchQuery,
        selectedStatus,
        sortOption,
        totalEstimateValue,
      ];
}

class QuotationsOperationSuccessState extends QuotationsState {
  final String message;
  const QuotationsOperationSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

class QuotationsErrorState extends QuotationsState {
  final String message;
  const QuotationsErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class QuotationsBloc extends Bloc<QuotationsEvent, QuotationsState> {
  final InvoiceRepository invoiceRepository;

  QuotationsBloc({required this.invoiceRepository})
      : super(QuotationsInitialState()) {
    on<FetchQuotationsEvent>(_onFetchQuotations);
    on<DuplicateQuotationEvent>(_onDuplicateQuotation);
    on<DeleteQuotationEvent>(_onDeleteQuotation);
  }

  Future<void> _onFetchQuotations(
      FetchQuotationsEvent event, Emitter<QuotationsState> emit) async {
    emit(QuotationsLoadingState());
    try {
      final all = await invoiceRepository.getInvoices(type: InvoiceType.quotation);
      var filtered = List<InvoiceEntity>.from(all);

      if (event.query != null && event.query!.isNotEmpty) {
        final q = event.query!.toLowerCase();
        filtered = filtered.where((item) {
          return item.invoiceNumber.toLowerCase().contains(q) ||
              item.customerName.toLowerCase().contains(q) ||
              item.customerPhone.toLowerCase().contains(q);
        }).toList();
      }

      if (event.statusFilter != null) {
        filtered = filtered.where((item) => item.status == event.statusFilter).toList();
      }

      // Sorting
      switch (event.sortOption) {
        case 'oldest':
          filtered.sort((a, b) => a.issueDate.compareTo(b.issueDate));
          break;
        case 'date_newest':
          filtered.sort((a, b) => b.dueDate.compareTo(a.dueDate));
          break;
        case 'date_oldest':
          filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
          break;
        case 'amount_high':
          filtered.sort((a, b) => b.grandTotal.compareTo(a.grandTotal));
          break;
        case 'amount_low':
          filtered.sort((a, b) => a.grandTotal.compareTo(b.grandTotal));
          break;
        case 'number_asc':
          filtered.sort((a, b) => a.invoiceNumber.compareTo(b.invoiceNumber));
          break;
        case 'newest':
        default:
          filtered.sort((a, b) => b.issueDate.compareTo(a.issueDate));
          break;
      }

      final totalEstimate = filtered.fold(0.0, (sum, item) => sum + item.grandTotal);

      emit(QuotationsLoadedState(
        allQuotations: all,
        filteredQuotations: filtered,
        searchQuery: event.query ?? '',
        selectedStatus: event.statusFilter,
        sortOption: event.sortOption,
        totalEstimateValue: totalEstimate,
      ));
    } catch (e) {
      emit(QuotationsErrorState(e.toString()));
    }
  }

  Future<void> _onDuplicateQuotation(
      DuplicateQuotationEvent event, Emitter<QuotationsState> emit) async {
    try {
      final nextVoucherId = await VoucherSequenceService.instance
          .generateNextVoucherId(VoucherType.quotation);
      final newId = 'qt_${DateTime.now().millisecondsSinceEpoch}';
      final duplicate = event.quotation.copyWith(
        id: newId,
        invoiceNumber: nextVoucherId,
        status: InvoiceStatus.draft,
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
      );
      await invoiceRepository.createInvoice(duplicate);
      emit(QuotationsOperationSuccessState(
          'Quotation #${duplicate.invoiceNumber} duplicated successfully!'));
      add(const FetchQuotationsEvent());
    } catch (e) {
      emit(QuotationsErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteQuotation(
      DeleteQuotationEvent event, Emitter<QuotationsState> emit) async {
    try {
      await invoiceRepository.deleteInvoice(event.quotationId);
      emit(const QuotationsOperationSuccessState('Quotation deleted successfully!'));
      add(const FetchQuotationsEvent());
    } catch (e) {
      emit(QuotationsErrorState(e.toString()));
    }
  }
}
