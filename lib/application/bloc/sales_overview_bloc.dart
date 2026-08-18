import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/invoice_repository.dart';

class DailySalesExpenseData extends Equatable {
  final String dayName; // 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  final double sales;
  final double expenses;
  final DateTime date;

  const DailySalesExpenseData({
    required this.dayName,
    required this.sales,
    required this.expenses,
    required this.date,
  });

  @override
  List<Object?> get props => [dayName, sales, expenses, date];
}

// Events
abstract class SalesOverviewEvent extends Equatable {
  const SalesOverviewEvent();

  @override
  List<Object?> get props => [];
}

class FetchSalesOverviewDataEvent extends SalesOverviewEvent {}

class SearchSalesOverviewEvent extends SalesOverviewEvent {
  final String query;
  const SearchSalesOverviewEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterSalesOverviewEvent extends SalesOverviewEvent {
  final String primaryFilter;
  const FilterSalesOverviewEvent(this.primaryFilter);

  @override
  List<Object?> get props => [primaryFilter];
}

class ApplyAdvancedFilterEvent extends SalesOverviewEvent {
  final String status;
  final String paymentMethod;
  final String dateRange;

  const ApplyAdvancedFilterEvent({
    required this.status,
    required this.paymentMethod,
    required this.dateRange,
  });

  @override
  List<Object?> get props => [status, paymentMethod, dateRange];
}

class ClearSalesOverviewFiltersEvent extends SalesOverviewEvent {}

// States
abstract class SalesOverviewState extends Equatable {
  const SalesOverviewState();

  @override
  List<Object?> get props => [];
}

class SalesOverviewInitialState extends SalesOverviewState {}

class SalesOverviewLoadingState extends SalesOverviewState {}

class SalesOverviewLoadedState extends SalesOverviewState {
  final double todaySales;
  final double todayExpenses;
  final double todayNet;

  final int todayInvoiceCount;
  final int todayPaidCount;
  final int todayDueCount;
  final double totalOutstandingAmount;

  final double weeklySales;
  final double weeklyExpenses;
  final double weeklyNet;
  final List<DailySalesExpenseData> weeklyDailyBreakdown;

  final List<InvoiceEntity> allInvoices;
  final List<InvoiceEntity> filteredInvoices;
  final List<InvoiceEntity> recentInvoices;

  final List<ExpenseEntity> allExpenses;
  final List<ExpenseEntity> filteredExpenses;
  final List<ExpenseEntity> recentExpenses;

  final String searchQuery;
  final String selectedPrimaryFilter;
  final String statusFilter;
  final String paymentMethodFilter;
  final String dateRangeFilter;

  const SalesOverviewLoadedState({
    required this.todaySales,
    required this.todayExpenses,
    required this.todayNet,
    required this.todayInvoiceCount,
    required this.todayPaidCount,
    required this.todayDueCount,
    required this.totalOutstandingAmount,
    required this.weeklySales,
    required this.weeklyExpenses,
    required this.weeklyNet,
    required this.weeklyDailyBreakdown,
    required this.allInvoices,
    required this.filteredInvoices,
    required this.recentInvoices,
    required this.allExpenses,
    required this.filteredExpenses,
    required this.recentExpenses,
    this.searchQuery = '',
    this.selectedPrimaryFilter = 'All',
    this.statusFilter = 'All',
    this.paymentMethodFilter = 'All',
    this.dateRangeFilter = 'All',
  });

  bool get isFiltered =>
      searchQuery.isNotEmpty ||
      selectedPrimaryFilter != 'All' ||
      statusFilter != 'All' ||
      paymentMethodFilter != 'All' ||
      dateRangeFilter != 'All';

  SalesOverviewLoadedState copyWith({
    double? todaySales,
    double? todayExpenses,
    double? todayNet,
    int? todayInvoiceCount,
    int? todayPaidCount,
    int? todayDueCount,
    double? totalOutstandingAmount,
    double? weeklySales,
    double? weeklyExpenses,
    double? weeklyNet,
    List<DailySalesExpenseData>? weeklyDailyBreakdown,
    List<InvoiceEntity>? allInvoices,
    List<InvoiceEntity>? filteredInvoices,
    List<InvoiceEntity>? recentInvoices,
    List<ExpenseEntity>? allExpenses,
    List<ExpenseEntity>? filteredExpenses,
    List<ExpenseEntity>? recentExpenses,
    String? searchQuery,
    String? selectedPrimaryFilter,
    String? statusFilter,
    String? paymentMethodFilter,
    String? dateRangeFilter,
  }) {
    return SalesOverviewLoadedState(
      todaySales: todaySales ?? this.todaySales,
      todayExpenses: todayExpenses ?? this.todayExpenses,
      todayNet: todayNet ?? this.todayNet,
      todayInvoiceCount: todayInvoiceCount ?? this.todayInvoiceCount,
      todayPaidCount: todayPaidCount ?? this.todayPaidCount,
      todayDueCount: todayDueCount ?? this.todayDueCount,
      totalOutstandingAmount: totalOutstandingAmount ?? this.totalOutstandingAmount,
      weeklySales: weeklySales ?? this.weeklySales,
      weeklyExpenses: weeklyExpenses ?? this.weeklyExpenses,
      weeklyNet: weeklyNet ?? this.weeklyNet,
      weeklyDailyBreakdown: weeklyDailyBreakdown ?? this.weeklyDailyBreakdown,
      allInvoices: allInvoices ?? this.allInvoices,
      filteredInvoices: filteredInvoices ?? this.filteredInvoices,
      recentInvoices: recentInvoices ?? this.recentInvoices,
      allExpenses: allExpenses ?? this.allExpenses,
      filteredExpenses: filteredExpenses ?? this.filteredExpenses,
      recentExpenses: recentExpenses ?? this.recentExpenses,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedPrimaryFilter: selectedPrimaryFilter ?? this.selectedPrimaryFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      paymentMethodFilter: paymentMethodFilter ?? this.paymentMethodFilter,
      dateRangeFilter: dateRangeFilter ?? this.dateRangeFilter,
    );
  }

  @override
  List<Object?> get props => [
        todaySales,
        todayExpenses,
        todayNet,
        todayInvoiceCount,
        todayPaidCount,
        todayDueCount,
        totalOutstandingAmount,
        weeklySales,
        weeklyExpenses,
        weeklyNet,
        weeklyDailyBreakdown,
        allInvoices,
        filteredInvoices,
        recentInvoices,
        allExpenses,
        filteredExpenses,
        recentExpenses,
        searchQuery,
        selectedPrimaryFilter,
        statusFilter,
        paymentMethodFilter,
        dateRangeFilter,
      ];
}

class SalesOverviewErrorState extends SalesOverviewState {
  final String message;

  const SalesOverviewErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class SalesOverviewBloc extends Bloc<SalesOverviewEvent, SalesOverviewState> {
  final InvoiceRepository invoiceRepository;
  final ExpenseRepository expenseRepository;
  final CustomerRepository customerRepository;

  SalesOverviewBloc({
    required this.invoiceRepository,
    required this.expenseRepository,
    required this.customerRepository,
  }) : super(SalesOverviewInitialState()) {
    on<FetchSalesOverviewDataEvent>(_onFetchSalesOverviewData);
    on<SearchSalesOverviewEvent>(_onSearchSalesOverview);
    on<FilterSalesOverviewEvent>(_onFilterSalesOverview);
    on<ApplyAdvancedFilterEvent>(_onApplyAdvancedFilter);
    on<ClearSalesOverviewFiltersEvent>(_onClearSalesOverviewFilters);
  }

  Future<void> _onFetchSalesOverviewData(
      FetchSalesOverviewDataEvent event, Emitter<SalesOverviewState> emit) async {
    emit(SalesOverviewLoadingState());
    try {
      final invoices = await invoiceRepository.getInvoices();
      final expenses = await expenseRepository.getExpenses();
      final customers = await customerRepository.getCustomers();

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Today Calculations
      final todayInvoices = invoices.where((i) {
        return i.issueDate.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
            i.issueDate.isBefore(todayEnd.add(const Duration(seconds: 1)));
      }).toList();

      final todaySales = todayInvoices.fold(0.0, (sum, i) => sum + i.grandTotal);

      final todayExpenses = expenses.where((e) {
        return e.expenseDate.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
            e.expenseDate.isBefore(todayEnd.add(const Duration(seconds: 1)));
      }).fold(0.0, (sum, e) => sum + e.amount);

      final todayNet = todaySales - todayExpenses;
      final todayInvoiceCount = todayInvoices.length;
      final todayPaidCount = todayInvoices.where((i) => i.status == InvoiceStatus.paid).length;
      final todayDueCount = todayInvoices
          .where((i) => i.status == InvoiceStatus.unpaid || i.status == InvoiceStatus.partiallyPaid)
          .length;

      // Outstanding calculation: sum of customer balances or unpaid invoice due amounts
      double totalOutstanding = customers.fold(0.0, (sum, c) => sum + c.outstandingBalance);
      if (totalOutstanding == 0.0) {
        totalOutstanding = invoices
            .where((i) => i.status == InvoiceStatus.unpaid || i.status == InvoiceStatus.partiallyPaid)
            .fold(0.0, (sum, i) => sum + i.dueAmount);
      }

      // Weekly Breakdown (Mon -> Sun)
      final monday = todayStart.subtract(Duration(days: now.weekday - 1));
      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final List<DailySalesExpenseData> weeklyBreakdown = [];

      for (int i = 0; i < 7; i++) {
        final dayDate = monday.add(Duration(days: i));
        final dayStart = DateTime(dayDate.year, dayDate.month, dayDate.day);
        final dayEnd = DateTime(dayDate.year, dayDate.month, dayDate.day, 23, 59, 59);

        final daySales = invoices.where((inv) {
          return inv.issueDate.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
              inv.issueDate.isBefore(dayEnd.add(const Duration(seconds: 1)));
        }).fold(0.0, (sum, inv) => sum + inv.grandTotal);

        final dayExp = expenses.where((exp) {
          return exp.expenseDate.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
              exp.expenseDate.isBefore(dayEnd.add(const Duration(seconds: 1)));
        }).fold(0.0, (sum, exp) => sum + exp.amount);

        weeklyBreakdown.add(
          DailySalesExpenseData(
            dayName: dayNames[i],
            sales: daySales,
            expenses: dayExp,
            date: dayDate,
          ),
        );
      }

      final weeklySales = weeklyBreakdown.fold(0.0, (sum, d) => sum + d.sales);
      final weeklyExpenses = weeklyBreakdown.fold(0.0, (sum, d) => sum + d.expenses);
      final weeklyNet = weeklySales - weeklyExpenses;

      // Sorted recent invoices
      final sortedInvoices = List<InvoiceEntity>.from(invoices)
        ..sort((a, b) => b.issueDate.compareTo(a.issueDate));
      final recentInvoices = sortedInvoices.take(5).toList();

      // Sorted recent expenses
      final sortedExpenses = List<ExpenseEntity>.from(expenses)
        ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
      final recentExpenses = sortedExpenses.take(5).toList();

      emit(
        SalesOverviewLoadedState(
          todaySales: todaySales,
          todayExpenses: todayExpenses,
          todayNet: todayNet,
          todayInvoiceCount: todayInvoiceCount,
          todayPaidCount: todayPaidCount,
          todayDueCount: todayDueCount,
          totalOutstandingAmount: totalOutstanding,
          weeklySales: weeklySales,
          weeklyExpenses: weeklyExpenses,
          weeklyNet: weeklyNet,
          weeklyDailyBreakdown: weeklyBreakdown,
          allInvoices: sortedInvoices,
          filteredInvoices: sortedInvoices,
          recentInvoices: recentInvoices,
          allExpenses: sortedExpenses,
          filteredExpenses: sortedExpenses,
          recentExpenses: recentExpenses,
        ),
      );
    } catch (e) {
      emit(SalesOverviewErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onSearchSalesOverview(
      SearchSalesOverviewEvent event, Emitter<SalesOverviewState> emit) {
    if (state is SalesOverviewLoadedState) {
      final current = state as SalesOverviewLoadedState;
      final query = event.query;
      final filteredInv = _filterInvoices(
        allInvoices: current.allInvoices,
        query: query,
        primaryFilter: current.selectedPrimaryFilter,
        statusFilter: current.statusFilter,
        paymentMethodFilter: current.paymentMethodFilter,
        dateRangeFilter: current.dateRangeFilter,
      );
      final filteredExp = _filterExpenses(
        allExpenses: current.allExpenses,
        query: query,
      );

      emit(current.copyWith(
        searchQuery: query,
        filteredInvoices: filteredInv,
        filteredExpenses: filteredExp,
      ));
    }
  }

  void _onFilterSalesOverview(
      FilterSalesOverviewEvent event, Emitter<SalesOverviewState> emit) {
    if (state is SalesOverviewLoadedState) {
      final current = state as SalesOverviewLoadedState;
      final primary = event.primaryFilter;
      final filteredInv = _filterInvoices(
        allInvoices: current.allInvoices,
        query: current.searchQuery,
        primaryFilter: primary,
        statusFilter: current.statusFilter,
        paymentMethodFilter: current.paymentMethodFilter,
        dateRangeFilter: current.dateRangeFilter,
      );
      final filteredExp = _filterExpenses(
        allExpenses: current.allExpenses,
        query: current.searchQuery,
      );

      emit(current.copyWith(
        selectedPrimaryFilter: primary,
        filteredInvoices: filteredInv,
        filteredExpenses: filteredExp,
      ));
    }
  }

  void _onApplyAdvancedFilter(
      ApplyAdvancedFilterEvent event, Emitter<SalesOverviewState> emit) {
    if (state is SalesOverviewLoadedState) {
      final current = state as SalesOverviewLoadedState;
      final filteredInv = _filterInvoices(
        allInvoices: current.allInvoices,
        query: current.searchQuery,
        primaryFilter: current.selectedPrimaryFilter,
        statusFilter: event.status,
        paymentMethodFilter: event.paymentMethod,
        dateRangeFilter: event.dateRange,
      );
      final filteredExp = _filterExpenses(
        allExpenses: current.allExpenses,
        query: current.searchQuery,
      );

      emit(current.copyWith(
        statusFilter: event.status,
        paymentMethodFilter: event.paymentMethod,
        dateRangeFilter: event.dateRange,
        filteredInvoices: filteredInv,
        filteredExpenses: filteredExp,
      ));
    }
  }

  void _onClearSalesOverviewFilters(
      ClearSalesOverviewFiltersEvent event, Emitter<SalesOverviewState> emit) {
    if (state is SalesOverviewLoadedState) {
      final current = state as SalesOverviewLoadedState;
      emit(current.copyWith(
        searchQuery: '',
        selectedPrimaryFilter: 'All',
        statusFilter: 'All',
        paymentMethodFilter: 'All',
        dateRangeFilter: 'All',
        filteredInvoices: current.allInvoices,
        filteredExpenses: current.allExpenses,
      ));
    }
  }

  List<InvoiceEntity> _filterInvoices({
    required List<InvoiceEntity> allInvoices,
    required String query,
    required String primaryFilter,
    required String statusFilter,
    required String paymentMethodFilter,
    required String dateRangeFilter,
  }) {
    List<InvoiceEntity> result = List.from(allInvoices);

    // Search Query
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      result = result.where((inv) {
        return inv.invoiceNumber.toLowerCase().contains(q) ||
            inv.customerName.toLowerCase().contains(q) ||
            inv.customerPhone.toLowerCase().contains(q) ||
            inv.grandTotal.toString().contains(q);
      }).toList();
    }

    // Primary Chip Filter
    if (primaryFilter != 'All') {
      if (primaryFilter == 'Paid') {
        result = result.where((inv) => inv.status == InvoiceStatus.paid).toList();
      } else if (primaryFilter == 'Unpaid') {
        result = result.where((inv) => inv.status == InvoiceStatus.unpaid).toList();
      } else if (primaryFilter == 'Partial') {
        result = result.where((inv) => inv.status == InvoiceStatus.partiallyPaid).toList();
      } else if (primaryFilter == 'Cash Sale') {
        result = result
            .where((inv) =>
                inv.notes.toLowerCase().contains('cash') || inv.status == InvoiceStatus.paid)
            .toList();
      }
    }

    // Advanced Status Filter
    if (statusFilter != 'All') {
      if (statusFilter == 'Paid') {
        result = result.where((inv) => inv.status == InvoiceStatus.paid).toList();
      } else if (statusFilter == 'Unpaid') {
        result = result.where((inv) => inv.status == InvoiceStatus.unpaid).toList();
      } else if (statusFilter == 'Partially Paid') {
        result = result.where((inv) => inv.status == InvoiceStatus.partiallyPaid).toList();
      }
    }

    // Advanced Date Filter
    if (dateRangeFilter != 'All') {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      if (dateRangeFilter == 'Today') {
        result = result.where((inv) => inv.issueDate.isAfter(todayStart)).toList();
      } else if (dateRangeFilter == 'This Week') {
        final monday = todayStart.subtract(Duration(days: now.weekday - 1));
        result = result.where((inv) => inv.issueDate.isAfter(monday)).toList();
      } else if (dateRangeFilter == 'This Month') {
        final monthStart = DateTime(now.year, now.month, 1);
        result = result.where((inv) => inv.issueDate.isAfter(monthStart)).toList();
      }
    }

    return result;
  }

  List<ExpenseEntity> _filterExpenses({
    required List<ExpenseEntity> allExpenses,
    required String query,
  }) {
    if (query.trim().isEmpty) return allExpenses;
    final q = query.toLowerCase().trim();
    return allExpenses.where((exp) {
      return exp.title.toLowerCase().contains(q) ||
          exp.category.toLowerCase().contains(q) ||
          exp.notes.toLowerCase().contains(q) ||
          exp.amount.toString().contains(q);
    }).toList();
  }
}
