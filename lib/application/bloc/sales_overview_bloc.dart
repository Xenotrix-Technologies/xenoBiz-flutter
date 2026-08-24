import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/daily_sales_expense_data.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/invoice_repository.dart';

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
  final String status; // Payment Status: All, Paid, Partially Paid, Unpaid, Overdue
  final String invoiceStatus; // Invoice Status: All, Draft, Issued, Cancelled, Returned
  final String dateRange; // Date Range: All, Today, Yesterday, This week, This month, Custom
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String customer;
  final String sortOption; // newest, oldest, amount_high, amount_low, name_asc, name_desc

  const ApplyAdvancedFilterEvent({
    this.status = 'All',
    this.invoiceStatus = 'All',
    this.dateRange = 'All',
    this.customStartDate,
    this.customEndDate,
    this.customer = 'All',
    this.sortOption = 'newest',
  });

  @override
  List<Object?> get props => [
        status,
        invoiceStatus,
        dateRange,
        customStartDate,
        customEndDate,
        customer,
        sortOption,
      ];
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

  final String searchQuery;
  final String selectedPrimaryFilter; // Quick chip: All, Paid, Partially Paid, Unpaid, Overdue, Cancelled
  final String statusFilter; // Payment Status
  final String invoiceStatusFilter; // Invoice Status
  final String dateRangeFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String selectedCustomer;
  final String sortOption;

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
    this.searchQuery = '',
    this.selectedPrimaryFilter = 'All',
    this.statusFilter = 'All',
    this.invoiceStatusFilter = 'All',
    this.dateRangeFilter = 'All',
    this.customStartDate,
    this.customEndDate,
    this.selectedCustomer = 'All',
    this.sortOption = 'newest',
  });

  bool get isFiltered =>
      searchQuery.isNotEmpty ||
      selectedPrimaryFilter != 'All' ||
      statusFilter != 'All' ||
      invoiceStatusFilter != 'All' ||
      dateRangeFilter != 'All' ||
      selectedCustomer != 'All' ||
      sortOption != 'newest';

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
    String? searchQuery,
    String? selectedPrimaryFilter,
    String? statusFilter,
    String? invoiceStatusFilter,
    String? dateRangeFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
    String? selectedCustomer,
    String? sortOption,
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
      searchQuery: searchQuery ?? this.searchQuery,
      selectedPrimaryFilter: selectedPrimaryFilter ?? this.selectedPrimaryFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      invoiceStatusFilter: invoiceStatusFilter ?? this.invoiceStatusFilter,
      dateRangeFilter: dateRangeFilter ?? this.dateRangeFilter,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      sortOption: sortOption ?? this.sortOption,
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
        searchQuery,
        selectedPrimaryFilter,
        statusFilter,
        invoiceStatusFilter,
        dateRangeFilter,
        customStartDate,
        customEndDate,
        selectedCustomer,
        sortOption,
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

      // Outstanding calculation
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

      final sortedInvoices = List<InvoiceEntity>.from(invoices)
        ..sort((a, b) => b.issueDate.compareTo(a.issueDate));

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
        invoiceStatusFilter: current.invoiceStatusFilter,
        dateRangeFilter: current.dateRangeFilter,
        customStartDate: current.customStartDate,
        customEndDate: current.customEndDate,
        customer: current.selectedCustomer,
        sortOption: current.sortOption,
      );

      emit(current.copyWith(
        searchQuery: query,
        filteredInvoices: filteredInv,
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
        invoiceStatusFilter: current.invoiceStatusFilter,
        dateRangeFilter: current.dateRangeFilter,
        customStartDate: current.customStartDate,
        customEndDate: current.customEndDate,
        customer: current.selectedCustomer,
        sortOption: current.sortOption,
      );

      emit(current.copyWith(
        selectedPrimaryFilter: primary,
        filteredInvoices: filteredInv,
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
        invoiceStatusFilter: event.invoiceStatus,
        dateRangeFilter: event.dateRange,
        customStartDate: event.customStartDate,
        customEndDate: event.customEndDate,
        customer: event.customer,
        sortOption: event.sortOption,
      );

      emit(current.copyWith(
        statusFilter: event.status,
        invoiceStatusFilter: event.invoiceStatus,
        dateRangeFilter: event.dateRange,
        customStartDate: event.customStartDate,
        customEndDate: event.customEndDate,
        selectedCustomer: event.customer,
        sortOption: event.sortOption,
        filteredInvoices: filteredInv,
      ));
    }
  }

  void _onClearSalesOverviewFilters(
      ClearSalesOverviewFiltersEvent event, Emitter<SalesOverviewState> emit) {
    if (state is SalesOverviewLoadedState) {
      final current = state as SalesOverviewLoadedState;
      final resetList = List<InvoiceEntity>.from(current.allInvoices)
        ..sort((a, b) => b.issueDate.compareTo(a.issueDate));

      emit(current.copyWith(
        searchQuery: '',
        selectedPrimaryFilter: 'All',
        statusFilter: 'All',
        invoiceStatusFilter: 'All',
        dateRangeFilter: 'All',
        customStartDate: null,
        customEndDate: null,
        selectedCustomer: 'All',
        sortOption: 'newest',
        filteredInvoices: resetList,
      ));
    }
  }

  List<InvoiceEntity> _filterInvoices({
    required List<InvoiceEntity> allInvoices,
    required String query,
    required String primaryFilter,
    required String statusFilter,
    required String invoiceStatusFilter,
    required String dateRangeFilter,
    required DateTime? customStartDate,
    required DateTime? customEndDate,
    required String customer,
    required String sortOption,
  }) {
    List<InvoiceEntity> result = List.from(allInvoices);

    // Search Query (Invoice #, Customer Name, Customer Phone)
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      result = result.where((inv) {
        return inv.invoiceNumber.toLowerCase().contains(q) ||
            inv.customerName.toLowerCase().contains(q) ||
            inv.customerPhone.toLowerCase().contains(q) ||
            inv.grandTotal.toString().contains(q);
      }).toList();
    }

    // Quick Status Filter Chips (All, Paid, Partially Paid, Unpaid, Overdue, Cancelled)
    if (primaryFilter != 'All') {
      final now = DateTime.now();
      if (primaryFilter == 'Paid') {
        result = result.where((inv) => inv.status == InvoiceStatus.paid).toList();
      } else if (primaryFilter == 'Unpaid') {
        result = result.where((inv) => inv.status == InvoiceStatus.unpaid).toList();
      } else if (primaryFilter == 'Partially Paid') {
        result = result.where((inv) => inv.status == InvoiceStatus.partiallyPaid).toList();
      } else if (primaryFilter == 'Overdue') {
        result = result.where((inv) {
          final isUnpaidOrPartial = inv.status == InvoiceStatus.unpaid || inv.status == InvoiceStatus.partiallyPaid;
          return isUnpaidOrPartial && inv.dueDate.isBefore(now);
        }).toList();
      } else if (primaryFilter == 'Cancelled') {
        result = result.where((inv) => inv.status == InvoiceStatus.cancelled).toList();
      }
    }

    // Advanced Payment Status Filter
    if (statusFilter != 'All') {
      final now = DateTime.now();
      if (statusFilter == 'Paid') {
        result = result.where((inv) => inv.status == InvoiceStatus.paid).toList();
      } else if (statusFilter == 'Unpaid') {
        result = result.where((inv) => inv.status == InvoiceStatus.unpaid).toList();
      } else if (statusFilter == 'Partially Paid') {
        result = result.where((inv) => inv.status == InvoiceStatus.partiallyPaid).toList();
      } else if (statusFilter == 'Overdue') {
        result = result.where((inv) {
          final isUnpaidOrPartial = inv.status == InvoiceStatus.unpaid || inv.status == InvoiceStatus.partiallyPaid;
          return isUnpaidOrPartial && inv.dueDate.isBefore(now);
        }).toList();
      }
    }

    // Advanced Invoice Status Filter (Draft, Issued, Cancelled, Returned)
    if (invoiceStatusFilter != 'All') {
      if (invoiceStatusFilter == 'Draft') {
        result = result.where((inv) => inv.status == InvoiceStatus.draft).toList();
      } else if (invoiceStatusFilter == 'Issued') {
        result = result.where((inv) => inv.status != InvoiceStatus.draft && inv.status != InvoiceStatus.cancelled).toList();
      } else if (invoiceStatusFilter == 'Cancelled') {
        result = result.where((inv) => inv.status == InvoiceStatus.cancelled).toList();
      } else if (invoiceStatusFilter == 'Returned') {
        result = result.where((inv) => inv.notes.toLowerCase().contains('return') || inv.invoiceNumber.toLowerCase().contains('ret')).toList();
      }
    }

    // Advanced Customer Filter
    if (customer != 'All' && customer.trim().isNotEmpty) {
      final cust = customer.toLowerCase().trim();
      result = result.where((inv) => inv.customerName.toLowerCase().contains(cust) || inv.customerId == customer).toList();
    }

    // Advanced Date Filter
    if (dateRangeFilter != 'All') {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      if (dateRangeFilter == 'Today') {
        result = result.where((inv) => inv.issueDate.isAfter(todayStart.subtract(const Duration(seconds: 1))) && inv.issueDate.isBefore(todayEnd.add(const Duration(seconds: 1)))).toList();
      } else if (dateRangeFilter == 'Yesterday') {
        final yestStart = todayStart.subtract(const Duration(days: 1));
        final yestEnd = todayStart.subtract(const Duration(seconds: 1));
        result = result.where((inv) => inv.issueDate.isAfter(yestStart) && inv.issueDate.isBefore(yestEnd)).toList();
      } else if (dateRangeFilter == 'This week') {
        final monday = todayStart.subtract(Duration(days: now.weekday - 1));
        result = result.where((inv) => inv.issueDate.isAfter(monday.subtract(const Duration(seconds: 1)))).toList();
      } else if (dateRangeFilter == 'This month') {
        final monthStart = DateTime(now.year, now.month, 1);
        result = result.where((inv) => inv.issueDate.isAfter(monthStart.subtract(const Duration(seconds: 1)))).toList();
      } else if (dateRangeFilter == 'Custom' && customStartDate != null) {
        final start = DateTime(customStartDate.year, customStartDate.month, customStartDate.day);
        final end = customEndDate != null
            ? DateTime(customEndDate.year, customEndDate.month, customEndDate.day, 23, 59, 59)
            : DateTime(customStartDate.year, customStartDate.month, customStartDate.day, 23, 59, 59);
        result = result.where((inv) => inv.issueDate.isAfter(start.subtract(const Duration(seconds: 1))) && inv.issueDate.isBefore(end.add(const Duration(seconds: 1)))).toList();
      }
    }

    // Sorting
    switch (sortOption) {
      case 'oldest':
        result.sort((a, b) => a.issueDate.compareTo(b.issueDate));
        break;
      case 'amount_high':
        result.sort((a, b) => b.grandTotal.compareTo(a.grandTotal));
        break;
      case 'amount_low':
        result.sort((a, b) => a.grandTotal.compareTo(b.grandTotal));
        break;
      case 'name_asc':
        result.sort((a, b) => a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase()));
        break;
      case 'name_desc':
        result.sort((a, b) => b.customerName.toLowerCase().compareTo(a.customerName.toLowerCase()));
        break;
      case 'newest':
      default:
        result.sort((a, b) => b.issueDate.compareTo(a.issueDate));
        break;
    }

    return result;
  }
}
