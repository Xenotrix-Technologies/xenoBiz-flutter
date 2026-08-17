import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';

// --- Events ---
abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();
  @override
  List<Object?> get props => [];
}

class FetchExpensesEvent extends ExpenseEvent {
  final String? category;
  const FetchExpensesEvent({this.category});
  @override
  List<Object?> get props => [category];
}

class CreateExpenseSubmittedEvent extends ExpenseEvent {
  final ExpenseEntity expense;
  const CreateExpenseSubmittedEvent(this.expense);
  @override
  List<Object?> get props => [expense];
}

// --- States ---
abstract class ExpenseState extends Equatable {
  const ExpenseState();
  @override
  List<Object?> get props => [];
}

class ExpenseInitialState extends ExpenseState {}

class ExpenseLoadingState extends ExpenseState {}

class ExpenseLoadedState extends ExpenseState {
  final List<ExpenseEntity> expenses;
  final double totalExpenseAmount;

  const ExpenseLoadedState({
    required this.expenses,
    required this.totalExpenseAmount,
  });

  @override
  List<Object?> get props => [expenses, totalExpenseAmount];
}

class ExpenseErrorState extends ExpenseState {
  final String message;
  const ExpenseErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository expenseRepository;

  ExpenseBloc({required this.expenseRepository}) : super(ExpenseInitialState()) {
    on<FetchExpensesEvent>(_onFetchExpenses);
    on<CreateExpenseSubmittedEvent>(_onCreateExpense);
  }

  Future<void> _onFetchExpenses(
      FetchExpensesEvent event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoadingState());
    try {
      final expenses = await expenseRepository.getExpenses(category: event.category);
      final total = expenses.fold(0.0, (sum, item) => sum + item.amount);
      emit(ExpenseLoadedState(expenses: expenses, totalExpenseAmount: total));
    } catch (e) {
      emit(ExpenseErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateExpense(
      CreateExpenseSubmittedEvent event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoadingState());
    try {
      await expenseRepository.createExpense(event.expense);
      final expenses = await expenseRepository.getExpenses();
      final total = expenses.fold(0.0, (sum, item) => sum + item.amount);
      emit(ExpenseLoadedState(expenses: expenses, totalExpenseAmount: total));
    } catch (e) {
      emit(ExpenseErrorState(e.toString().replaceAll('Expense: ', '')));
    }
  }
}
