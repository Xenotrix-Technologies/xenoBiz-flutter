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
import '../../infrastructure/storage/hive_service.dart';

class LedgerSalesTransaction extends Equatable {
  final String id;
  final String title; // Customer Name or 'Cash Sale' or 'Other Income'
  final String subTitle; // 'Sales Income' or 'Other Income'
  final double amount;
  final String paymentMethod; // 'Cash', 'GPay/UPI', 'Card', 'Other'
  final DateTime time;
  final InvoiceEntity? invoice;
  final bool isIncome;

  const LedgerSalesTransaction({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.amount,
    required this.paymentMethod,
    required this.time,
    this.invoice,
    this.isIncome = false,
  });

  @override
  List<Object?> get props => [id, title, subTitle, amount, paymentMethod, time, invoice, isIncome];
}

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
  final double cashIn;
  final double cashOut;
  final double closingBalance;

  final double totalSales;
  final double cashSales;
  final double upiCardSales;
  final double otherIncomeTotal;

  final double totalExpenses;
  final double cashExpenses;
  final double accountExpenses;

  final List<LedgerSalesTransaction> salesTransactions;
  final List<ExpenseEntity> expenseTransactions;
  final List<IncomeEntity> incomeTransactions;

  const DailyLedgerLoadedState({
    required this.selectedDate,
    required this.openingBalance,
    required this.cashIn,
    required this.cashOut,
    required this.closingBalance,
    required this.totalSales,
    required this.cashSales,
    required this.upiCardSales,
    this.otherIncomeTotal = 0.0,
    required this.totalExpenses,
    required this.cashExpenses,
    required this.accountExpenses,
    required this.salesTransactions,
    required this.expenseTransactions,
    this.incomeTransactions = const [],
  });

  @override
  List<Object?> get props => [
        selectedDate,
        openingBalance,
        cashIn,
        cashOut,
        closingBalance,
        totalSales,
        cashSales,
        upiCardSales,
        otherIncomeTotal,
        totalExpenses,
        cashExpenses,
        accountExpenses,
        salesTransactions,
        expenseTransactions,
        incomeTransactions,
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
  final HiveService hiveService;

  DailyLedgerBloc({
    required this.invoiceRepository,
    required this.expenseRepository,
    required this.customerRepository,
    this.incomeRepository,
    required this.hiveService,
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
      final bizBox = hiveService.getBox(HiveService.boxBusiness);
      final key = 'opening_balance_${_getDateKey(event.selectedDate)}';
      await bizBox.put(key, event.newOpeningBalance);

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

      // Read Opening Balance for selected date
      final bizBox = hiveService.getBox(HiveService.boxBusiness);
      final openingKey = 'opening_balance_${_getDateKey(selectedDate)}';
      final double openingBalance = (bizBox.get(openingKey) as num?)?.toDouble() ?? 0.0;

      // Filter Sales Invoices ONLY for selected date (Returns are EXCLUDED from ledger financial entries)
      final dayInvoices = invoices.where((inv) {
        return inv.type == InvoiceType.sale &&
            inv.issueDate.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
            inv.issueDate.isBefore(dayEnd.add(const Duration(seconds: 1)));
      }).toList();

      dayInvoices.sort((a, b) => b.issueDate.compareTo(a.issueDate));

      // Filter Expenses for selected date
      final dayExpenses = expenses.where((exp) {
        return exp.expenseDate.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
            exp.expenseDate.isBefore(dayEnd.add(const Duration(seconds: 1)));
      }).toList();

      dayExpenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

      // Filter Incomes for selected date
      final dayIncomes = incomes.where((inc) {
        return inc.incomeDate.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
            inc.incomeDate.isBefore(dayEnd.add(const Duration(seconds: 1)));
      }).toList();

      dayIncomes.sort((a, b) => b.incomeDate.compareTo(a.incomeDate));

      // 1. Process CASH IN Transactions (Sales Income + Other Income)
      double totalSales = 0.0;
      double cashSales = 0.0;
      double upiCardSales = 0.0;
      double otherIncomeTotal = 0.0;

      final List<LedgerSalesTransaction> salesTxs = [];

      for (var inv in dayInvoices) {
        totalSales += inv.grandTotal;

        final isCash = inv.notes.toLowerCase().contains('cash') ||
            inv.status == InvoiceStatus.paid ||
            inv.customerName.toLowerCase().contains('cash');

        final payMode = isCash ? 'Cash' : 'GPay/UPI';

        if (isCash) {
          cashSales += inv.grandTotal;
        } else {
          upiCardSales += inv.grandTotal;
        }

        final isGuest = inv.customerName.isEmpty ||
            inv.customerName == 'Guest Customer' ||
            inv.customerName.toLowerCase().contains('guest');

        salesTxs.add(
          LedgerSalesTransaction(
            id: inv.id,
            title: isGuest ? 'Cash Sale' : inv.customerName,
            subTitle: 'Sales Income • #${inv.invoiceNumber}',
            amount: inv.grandTotal,
            paymentMethod: payMode,
            time: inv.issueDate,
            invoice: inv,
          ),
        );
      }

      for (var inc in dayIncomes) {
        otherIncomeTotal += inc.amount;
        salesTxs.add(
          LedgerSalesTransaction(
            id: inc.id,
            title: inc.title,
            subTitle: (inc.partyName != null && inc.partyName!.isNotEmpty)
                ? 'Other Income • ${inc.category} • ${inc.partyName}'
                : 'Other Income • ${inc.category}',
            amount: inc.amount,
            paymentMethod: inc.paymentMode,
            time: inc.incomeDate,
            isIncome: true,
          ),
        );
      }

      // 2. Process CASH OUT Breakdown (Purchase Expense + Other Expense)
      double totalExp = 0.0;
      double cashExp = 0.0;
      double accountExp = 0.0;

      for (var exp in dayExpenses) {
        totalExp += exp.amount;
        if (exp.paymentMode == 'Cash') {
          cashExp += exp.amount;
        } else {
          accountExp += exp.amount;
        }
      }

      // Physical Cash Balance Calculations
      final double cashIn = cashSales + otherIncomeTotal;
      final double cashOut = cashExp;
      final double closingBalance = openingBalance + cashIn - cashOut;

      emit(
        DailyLedgerLoadedState(
          selectedDate: selectedDate,
          openingBalance: openingBalance,
          cashIn: cashIn,
          cashOut: cashOut,
          closingBalance: closingBalance,
          totalSales: totalSales,
          cashSales: cashSales,
          upiCardSales: upiCardSales,
          otherIncomeTotal: otherIncomeTotal,
          totalExpenses: totalExp,
          cashExpenses: cashExp,
          accountExpenses: accountExp,
          salesTransactions: salesTxs,
          expenseTransactions: dayExpenses,
          incomeTransactions: dayIncomes,
        ),
      );
    } catch (e) {
      emit(DailyLedgerErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
