import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/usecases/create_invoice_usecase.dart';
import '../../domain/usecases/record_payment_usecase.dart';
import '../../domain/usecases/update_invoice_usecase.dart';

// Events
abstract class InvoiceEvent extends Equatable {
  const InvoiceEvent();
  @override
  List<Object?> get props => [];
}

class FetchInvoicesEvent extends InvoiceEvent {
  final InvoiceStatus? status;
  final String? query;
  const FetchInvoicesEvent({this.status, this.query});

  @override
  List<Object?> get props => [status, query];
}

class CreateInvoiceSubmittedEvent extends InvoiceEvent {
  final InvoiceEntity invoice;
  const CreateInvoiceSubmittedEvent(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class UpdateInvoiceSubmittedEvent extends InvoiceEvent {
  final InvoiceEntity invoice;
  const UpdateInvoiceSubmittedEvent(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class RecordPaymentSubmittedEvent extends InvoiceEvent {
  final PaymentEntity payment;
  const RecordPaymentSubmittedEvent(this.payment);

  @override
  List<Object?> get props => [payment];
}

// States
abstract class InvoiceState extends Equatable {
  const InvoiceState();
  @override
  List<Object?> get props => [];
}

class InvoiceInitialState extends InvoiceState {}

class InvoiceLoadingState extends InvoiceState {}

class InvoicesLoadedState extends InvoiceState {
  final List<InvoiceEntity> invoices;
  const InvoicesLoadedState(this.invoices);

  @override
  List<Object?> get props => [invoices];
}

class InvoiceOperationSuccessState extends InvoiceState {
  final String message;
  const InvoiceOperationSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

class InvoiceErrorState extends InvoiceState {
  final String message;
  const InvoiceErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoiceRepository invoiceRepository;
  final CreateInvoiceUseCase createInvoiceUseCase;
  final UpdateInvoiceUseCase updateInvoiceUseCase;
  final RecordPaymentUseCase recordPaymentUseCase;

  InvoiceBloc({
    required this.invoiceRepository,
    required this.createInvoiceUseCase,
    required this.updateInvoiceUseCase,
    required this.recordPaymentUseCase,
  }) : super(InvoiceInitialState()) {
    on<FetchInvoicesEvent>(_onFetchInvoices);
    on<CreateInvoiceSubmittedEvent>(_onCreateInvoiceSubmitted);
    on<UpdateInvoiceSubmittedEvent>(_onUpdateInvoiceSubmitted);
    on<RecordPaymentSubmittedEvent>(_onRecordPaymentSubmitted);
  }

  Future<void> _onFetchInvoices(
      FetchInvoicesEvent event, Emitter<InvoiceState> emit) async {
    emit(InvoiceLoadingState());
    try {
      final invoices = await invoiceRepository.getInvoices(
        status: event.status,
        query: event.query,
      );
      emit(InvoicesLoadedState(invoices));
    } catch (e) {
      emit(InvoiceErrorState(e.toString()));
    }
  }

  Future<void> _onCreateInvoiceSubmitted(
      CreateInvoiceSubmittedEvent event, Emitter<InvoiceState> emit) async {
    emit(InvoiceLoadingState());
    try {
      final created = await createInvoiceUseCase.execute(event.invoice);
      final label = created.isPurchase ? 'Purchase' : 'Invoice';
      emit(InvoiceOperationSuccessState('$label #${created.invoiceNumber} created successfully!'));
      add(const FetchInvoicesEvent());
    } catch (e) {
      emit(InvoiceErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateInvoiceSubmitted(
      UpdateInvoiceSubmittedEvent event, Emitter<InvoiceState> emit) async {
    emit(InvoiceLoadingState());
    try {
      final updated = await updateInvoiceUseCase.execute(event.invoice);
      final label = updated.isPurchase ? 'Purchase' : 'Invoice';
      emit(InvoiceOperationSuccessState('$label #${updated.invoiceNumber} updated successfully!'));
      add(const FetchInvoicesEvent());
    } catch (e) {
      emit(InvoiceErrorState(e.toString()));
    }
  }

  Future<void> _onRecordPaymentSubmitted(
      RecordPaymentSubmittedEvent event, Emitter<InvoiceState> emit) async {
    emit(InvoiceLoadingState());
    try {
      await recordPaymentUseCase.execute(event.payment);
      emit(const InvoiceOperationSuccessState('Payment recorded and balances updated!'));
      add(const FetchInvoicesEvent());
    } catch (e) {
      emit(InvoiceErrorState(e.toString()));
    }
  }
}

