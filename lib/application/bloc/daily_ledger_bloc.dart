import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/income_entity.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/income_repository.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../infrastructure/database/app_database.dart';

// Events
abstract class DailyLedgerEvent extends Equatable {
  const DailyLedgerEvent();

  @override
  List<Object?> get props => [];
}

class FetchDailyLedgerDataEvent extends DailyLedgerEvent {
  final DateTime selectedDate;

  const FetchDailyLedgerDataEvent(this.selectedDate);

  @override
  List<Object?> get props => [selectedDate];
}

class UpdateOpeningBalanceEvent extends DailyLedgerEvent {
  final DateTime selectedDate;
  final double newOpeningBalance;

  const UpdateOpeningBalanceEvent({
    required this.selectedDate,
    required this.newOpeningBalance,
  });

  @override
  List<Object?> get props => [selectedDate, newOpeningBalance];
}

class AddExpenseSubmittedEvent extends DailyLedgerEvent {
  final ExpenseEntity expense;
  final DateTime selectedDate;

  const AddExpenseSubmittedEvent({
    required this.expense,
    required this.selectedDate,
  });

  @override
  List<Object?> get props => [expense, selectedDate];
}

class ChangeLedgerDateEvent extends DailyLedgerEvent {
  final DateTime newDate;

  const ChangeLedgerDateEvent(this.newDate);

  @override
  List<Object?> get props => [newDate];
}

// States
abstract class DailyLedgerState extends Equatable {
  const DailyLedgerState();

  @override
  List<Object?> get props => [];
}

class DailyLedgerInitialState extends DailyLedgerState {}

class DailyLedgerLoadingState extends DailyLedgerState {}

class DailyLedgerLoadedState extends DailyLedgerState {
  final DateTime selectedDate;
  final double openingBalance;
  final List<InvoiceEntity> salesInvoices;
  final List<ExpenseEntity> expenses;
  final List<IncomeEntity> incomes;

  final double totalSalesCash;
  final double totalSalesOnline;
  final double totalSalesCredit;
  final double totalSalesTotal;

  final double totalExpensesCash;
  final double totalExpensesOnline;
  final double totalExpensesTotal;

  final double totalIncomesCash;
  final double totalIncomesOnline;
  final double totalIncomesTotal;

  final double totalReceivedCash;
  final double totalReceivedOnline;
  final double totalPaidCash;
  final double totalPaidOnline;

  final double closingCashInHand;
  final double closingBankOnlineBalance;
  final double netCashFlow;

  const DailyLedgerLoadedState({
    required this.selectedDate,
    required this.openingBalance,
    required this.salesInvoices,
    required this.expenses,
    required this.incomes,
    required this.totalSalesCash,
    required this.totalSalesOnline,
    required this.totalSalesCredit,
    required this.totalSalesTotal,
    required this.totalExpensesCash,
    required this.totalExpensesOnline,
    required this.totalExpensesTotal,
    required this.totalIncomesCash,
    required this.totalIncomesOnline,
    required this.totalIncomesTotal,
    required this.totalReceivedCash,
    required this.totalReceivedOnline,
    required this.totalPaidCash,
    required this.totalPaidOnline,
    required this.closingCashInHand,
    required this.closingBankOnlineBalance,
    required this.netCashFlow,
  });

  double get cashIn => totalReceivedCash + totalReceivedOnline;
  double get cashOut => totalPaidCash + totalPaidOnline;
  double get closingBalance => closingCashInHand + closingBankOnlineBalance;
  double get totalSales => totalSalesTotal;
  double get cashSales => totalSalesCash;
  double get upiCardSales => totalSalesOnline;
  double get totalExpenses => totalExpensesTotal;
  double get cashExpenses => totalExpensesCash;
  double get accountExpenses => totalExpensesOnline;
  double get otherIncomeTotal => totalIncomesTotal;
  List<InvoiceEntity> get salesTransactions => salesInvoices;
  List<ExpenseEntity> get expenseTransactions => expenses;

  @override
  List<Object?> get props => [
        selectedDate,
        openingBalance,
        salesInvoices,
        expenses,
        incomes,
        totalSalesCash,
        totalSalesOnline,
        totalSalesCredit,
        totalSalesTotal,
        totalExpensesCash,
        totalExpensesOnline,
        totalExpensesTotal,
        totalIncomesCash,
        totalIncomesOnline,
        totalIncomesTotal,
        totalReceivedCash,
        totalReceivedOnline,
        totalPaidCash,
        totalPaidOnline,
        closingCashInHand,
        closingBankOnlineBalance,
        netCashFlow,
      ];
}

class DailyLedgerErrorState extends DailyLedgerState {
  final String message;

  const DailyLedgerErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class DailyLedgerBloc extends Bloc<DailyLedgerEvent, DailyLedgerState> {
  final InvoiceRepository invoiceRepository;
  final ExpenseRepository expenseRepository;
  final CustomerRepository customerRepository;
  final IncomeRepository? incomeRepository;
  final AppDatabase db;

  DailyLedgerBloc({
    required this.invoiceRepository,
    required this.expenseRepository,
    required this.customerRepository,
    this.incomeRepository,
    required this.db,
  }) : super(DailyLedgerInitialState()) {
    on<FetchDailyLedgerDataEvent>(_onFetchDailyLedgerData);
    on<UpdateOpeningBalanceEvent>(_onUpdateOpeningBalance);
    on<AddExpenseSubmittedEvent>(_onAddExpenseSubmitted);
    on<ChangeLedgerDateEvent>(_onChangeLedgerDate);
  }

  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _onFetchDailyLedgerData(
      FetchDailyLedgerDataEvent event, Emitter<DailyLedgerState> emit) async {
    emit(DailyLedgerLoadingState());
    await _loadLedgerForDate(event.selectedDate, emit);
  }

  Future<void> _onChangeLedgerDate(
      ChangeLedgerDateEvent event, Emitter<DailyLedgerState> emit) async {
    emit(DailyLedgerLoadingState());
    await _loadLedgerForDate(event.newDate, emit);
  }

  Future<void> _onUpdateOpeningBalance(
      UpdateOpeningBalanceEvent event, Emitter<DailyLedgerState> emit) async {
    try {
      final key = 'opening_balance_${_getDateKey(event.selectedDate)}';
      await db.putKeyValue(key, event.newOpeningBalance.toString());

      await _loadLedgerForDate(event.selectedDate, emit);
    } catch (e) {
      emit(DailyLedgerErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAddExpenseSubmitted(
      AddExpenseSubmittedEvent event, Emitter<DailyLedgerState> emit) async {
    try {
      await expenseRepository.createExpense(event.expense);
      await _loadLedgerForDate(event.selectedDate, emit);
    } catch (e) {
      emit(DailyLedgerErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _loadLedgerForDate(
      DateTime selectedDate, Emitter<DailyLedgerState> emit) async {
    try {
      final dayStart = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final dayEnd = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

      final invoices = await invoiceRepository.getInvoices();
      final expenses = await expenseRepository.getExpenses();
      final incomes = incomeRepository != null ? await incomeRepository!.getIncomes() : <IncomeEntity>[];

      final openingKey = 'opening_balance_${_getDateKey(selectedDate)}';
      final openingStr = await db.getKeyValue(openingKey);
      final double openingBalance = double.tryParse(openingStr ?? '') ?? 0.0;

      final dayInvoices = invoices.where((inv) {
        return inv.type == InvoiceType.sale &&
            inv.issueDate.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
            inv.issueDate.isBefore(dayEnd.add(const Duration(seconds: 1)));
      }).toList();

      dayInvoices.sort((a, b) => b.issueDate.compareTo(a.issueDate));

      final dayExpenses = expenses.where((exp) {
        return exp.expenseDate.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
            exp.expenseDate.isBefore(dayEnd.add(const Duration(seconds: 1)));
      }).toList();

      dayExpenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

      final dayIncomes = incomes.where((inc) {
        return inc.incomeDate.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
            inc.incomeDate.isBefore(dayEnd.add(const Duration(seconds: 1)));
      }).toList();

      dayIncomes.sort((a, b) => b.incomeDate.compareTo(a.incomeDate));

      double salesCash = 0.0;
      double salesOnline = 0.0;
      double salesCredit = 0.0;

      for (var inv in dayInvoices) {
        final mode = inv.notes.toUpperCase();
        if (inv.status == InvoiceStatus.paid) {
          if (mode.contains('ONLINE') || mode.contains('UPI') || mode.contains('CARD') || mode.contains('BANK')) {
            salesOnline += inv.grandTotal;
          } else {
            salesCash += inv.grandTotal;
          }
        } else if (inv.status == InvoiceStatus.partiallyPaid) {
          salesCash += inv.paidAmount;
          salesCredit += inv.dueAmount;
        } else {
          salesCredit += inv.grandTotal;
        }
      }

      final salesTotal = salesCash + salesOnline + salesCredit;

      double expensesCash = 0.0;
      double expensesOnline = 0.0;

      for (var exp in dayExpenses) {
        final mode = exp.paymentMode.toUpperCase();
        if (mode.contains('ONLINE') || mode.contains('UPI') || mode.contains('CARD') || mode.contains('BANK')) {
          expensesOnline += exp.amount;
        } else {
          expensesCash += exp.amount;
        }
      }
      final expensesTotal = expensesCash + expensesOnline;

      double incomesCash = 0.0;
      double incomesOnline = 0.0;

      for (var inc in dayIncomes) {
        final mode = inc.paymentMode.toUpperCase();
        if (mode.contains('ONLINE') || mode.contains('UPI') || mode.contains('CARD') || mode.contains('BANK')) {
          incomesOnline += inc.amount;
        } else {
          incomesCash += inc.amount;
        }
      }
      final incomesTotal = incomesCash + incomesOnline;

      final totalReceivedCash = salesCash + incomesCash;
      final totalReceivedOnline = salesOnline + incomesOnline;
      final totalPaidCash = expensesCash;
      final totalPaidOnline = expensesOnline;

      final closingCashInHand = openingBalance + totalReceivedCash - totalPaidCash;
      final closingBankOnlineBalance = totalReceivedOnline - totalPaidOnline;
      final netCashFlow = (totalReceivedCash + totalReceivedOnline) - (totalPaidCash + totalPaidOnline);

      emit(
        DailyLedgerLoadedState(
          selectedDate: selectedDate,
          openingBalance: openingBalance,
          salesInvoices: dayInvoices,
          expenses: dayExpenses,
          incomes: dayIncomes,
          totalSalesCash: salesCash,
          totalSalesOnline: salesOnline,
          totalSalesCredit: salesCredit,
          totalSalesTotal: salesTotal,
          totalExpensesCash: expensesCash,
          totalExpensesOnline: expensesOnline,
          totalExpensesTotal: expensesTotal,
          totalIncomesCash: incomesCash,
          totalIncomesOnline: incomesOnline,
          totalIncomesTotal: incomesTotal,
          totalReceivedCash: totalReceivedCash,
          totalReceivedOnline: totalReceivedOnline,
          totalPaidCash: totalPaidCash,
          totalPaidOnline: totalPaidOnline,
          closingCashInHand: closingCashInHand,
          closingBankOnlineBalance: closingBankOnlineBalance,
          netCashFlow: netCashFlow,
        ),
      );
    } catch (e) {
      emit(DailyLedgerErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
