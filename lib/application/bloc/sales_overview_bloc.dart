import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/daily_sales_expense_data.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/sales_transaction_wrapper.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/income_repository.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/repositories/returns_repository.dart';
import '../../infrastructure/database/app_database.dart';

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
  final String primaryFilter; // Type chip: All, Invoices, Returns, Payments
  const FilterSalesOverviewEvent(this.primaryFilter);

  @override
  List<Object?> get props => [primaryFilter];
}

class ApplyAdvancedFilterEvent extends SalesOverviewEvent {
  final String transactionType; // All, Invoices, Returns, Payments
  final String status; // All, Paid, Partially Paid, Unpaid, Overdue
  final String invoiceStatus; // All, Draft, Issued, Cancelled, Returned
  final String dateRange; // All, Today, Yesterday, This week, This month, Custom
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String customer;
  final String sortOption; // newest, oldest, amount_high, amount_low, name_asc, name_desc

  const ApplyAdvancedFilterEvent({
    this.transactionType = 'All',
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
        transactionType,
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

  final List<SalesTransactionWrapper> allTransactions;
  final List<SalesTransactionWrapper> filteredTransactions;

  final String searchQuery;
  final String selectedTypeFilter; // All, Invoices, Returns, Payments
  final String statusFilter; // Payment Status: All, Paid, Partially Paid, Unpaid, Overdue
  final String invoiceStatusFilter; // Invoice Status: All, Draft, Issued, Cancelled, Returned
  final String dateRangeFilter; // All, Today, Yesterday, This week, This month, Custom
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
    required this.allTransactions,
    required this.filteredTransactions,
    this.searchQuery = '',
    this.selectedTypeFilter = 'All',
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
      selectedTypeFilter != 'All' ||
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
    List<SalesTransactionWrapper>? allTransactions,
    List<SalesTransactionWrapper>? filteredTransactions,
    String? searchQuery,
    String? selectedTypeFilter,
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
      allTransactions: allTransactions ?? this.allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTypeFilter: selectedTypeFilter ?? this.selectedTypeFilter,
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
        allTransactions,
        filteredTransactions,
        searchQuery,
        selectedTypeFilter,
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
  final ReturnsRepository returnsRepository;
  final IncomeRepository incomeRepository;
  final AppDatabase db;

  SalesOverviewBloc({
    required this.invoiceRepository,
    required this.expenseRepository,
    required this.customerRepository,
    required this.returnsRepository,
    required this.incomeRepository,
    required this.db,
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
      final incomes = await incomeRepository.getIncomes();
      final customers = await customerRepository.getCustomers();
      final salesReturns = await returnsRepository.getReturns(InvoiceType.sale);
      final purchaseReturns = await returnsRepository.getReturns(InvoiceType.purchase);

      final paymentRows = await db.select(db.payments).get();
      final List<PaymentEntity> paymentsList = paymentRows.map((val) => PaymentEntity(
        id: val.id,
        invoiceId: val.invoiceId,
        customerId: val.customerId,
        customerName: val.customerName,
        amount: val.amount,
        paymentMode: val.paymentMode,
        referenceNumber: val.referenceNumber,
        paymentDate: val.paymentDate,
        notes: val.notes,
      )).toList();

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final todayInvoices = invoices.where((i) {
        return i.isSale &&
            !i.isQuotation &&
            i.issueDate.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
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

      double totalOutstanding = customers.fold(0.0, (sum, c) => sum + c.outstandingBalance);
      if (totalOutstanding == 0.0) {
        totalOutstanding = invoices
            .where((i) => i.isSale && !i.isQuotation && (i.status == InvoiceStatus.unpaid || i.status == InvoiceStatus.partiallyPaid))
            .fold(0.0, (sum, i) => sum + i.dueAmount);
      }

      final monday = todayStart.subtract(Duration(days: now.weekday - 1));
      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final List<DailySalesExpenseData> weeklyBreakdown = [];

      for (int i = 0; i < 7; i++) {
        final dayDate = monday.add(Duration(days: i));
        final dayStart = DateTime(dayDate.year, dayDate.month, dayDate.day);
        final dayEnd = DateTime(dayDate.year, dayDate.month, dayDate.day, 23, 59, 59);

        final daySales = invoices.where((inv) {
          return inv.isSale &&
              !inv.isQuotation &&
              inv.issueDate.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
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

      final List<SalesTransactionWrapper> transactionsList = [];
      final invoiceIdsSet = invoices.map((i) => i.id).toSet();

      // 1. Invoices (Sale & Purchase only - QUOTATIONS ARE STRICTLY EXCLUDED)
      for (var inv in invoices) {
        if (inv.isQuotation || inv.type == InvoiceType.quotation) continue;
        final isPurch = inv.isPurchase || inv.type == InvoiceType.purchase;
        transactionsList.add(SalesTransactionWrapper(
          id: inv.id,
          type: isPurch ? SalesTransactionType.purchase : SalesTransactionType.sale,
          transactionNumber: inv.invoiceNumber,
          customerName: inv.customerName.isNotEmpty
              ? inv.customerName
              : (isPurch ? 'General Supplier' : 'General Customer'),
          customerPhone: inv.customerPhone,
          totalAmount: inv.grandTotal,
          paidAmount: inv.paidAmount,
          dueAmount: inv.dueAmount,
          statusText: inv.status == InvoiceStatus.paid
              ? 'Paid'
              : inv.status == InvoiceStatus.partiallyPaid
                  ? 'Partially Paid'
                  : inv.status == InvoiceStatus.cancelled
                      ? 'Cancelled'
                      : 'Unpaid',
          date: inv.issueDate,
          originalEntity: inv,
        ));
      }

      // 2. Sales Returns
      for (var ret in salesReturns) {
        transactionsList.add(SalesTransactionWrapper(
          id: ret.id,
          type: SalesTransactionType.salesReturn,
          transactionNumber: ret.returnNumber,
          customerName: ret.partyName.isNotEmpty ? ret.partyName : 'General Customer',
          totalAmount: ret.totalAmount,
          paidAmount: 0.0,
          dueAmount: 0.0,
          statusText: 'Returned',
          date: ret.returnDate,
          originalEntity: ret,
        ));
      }

      // 3. Purchase Returns
      for (var ret in purchaseReturns) {
        transactionsList.add(SalesTransactionWrapper(
          id: ret.id,
          type: SalesTransactionType.purchaseReturn,
          transactionNumber: ret.returnNumber,
          customerName: ret.partyName.isNotEmpty ? ret.partyName : 'General Supplier',
          totalAmount: ret.totalAmount,
          paidAmount: 0.0,
          dueAmount: 0.0,
          statusText: 'Returned',
          date: ret.returnDate,
          originalEntity: ret,
        ));
      }

      // 4. Standalone Payments from db.payments (Do NOT duplicate invoice payments)
      for (var pay in paymentsList) {
        if (pay.invoiceId.isNotEmpty && invoiceIdsSet.contains(pay.invoiceId)) {
          continue; // Already represented by the Invoice card!
        }

        final isMoneyOut = pay.notes.toLowerCase().contains('payment') ||
            pay.notes.toLowerCase().contains('vendor') ||
            pay.notes.toLowerCase().contains('supplier') ||
            pay.id.toLowerCase().startsWith('pay_exp_');

        final txType = isMoneyOut
            ? SalesTransactionType.payment
            : SalesTransactionType.receipt;

        final refNum = pay.referenceNumber.isNotEmpty
            ? pay.referenceNumber
            : (isMoneyOut
                ? 'PAY-${pay.id.length > 6 ? pay.id.substring(0, 6) : pay.id}'
                : 'REC-${pay.id.length > 6 ? pay.id.substring(0, 6) : pay.id}');

        transactionsList.add(SalesTransactionWrapper(
          id: pay.id,
          type: txType,
          transactionNumber: refNum,
          customerName: pay.customerName.isNotEmpty ? pay.customerName : 'General Account',
          totalAmount: pay.amount,
          paidAmount: pay.amount,
          dueAmount: 0.0,
          statusText: isMoneyOut ? 'Paid' : 'Received',
          date: pay.paymentDate,
          originalEntity: pay,
        ));
      }

      // 5. Standalone Income (Receipts - Money IN)
      for (var inc in incomes) {
        final txNum = inc.title.startsWith('REC-')
            ? inc.title
            : 'REC-${inc.id.replaceAll(RegExp(r'[^0-9]'), '')}';
        transactionsList.add(SalesTransactionWrapper(
          id: inc.id,
          type: SalesTransactionType.receipt,
          transactionNumber: txNum.length > 16 ? txNum.substring(0, 16) : txNum,
          customerName: inc.partyName?.isNotEmpty == true
              ? inc.partyName!
              : (inc.category.isNotEmpty ? inc.category : 'General Customer'),
          totalAmount: inc.amount,
          paidAmount: inc.amount,
          dueAmount: 0.0,
          statusText: 'Received',
          date: inc.incomeDate,
          originalEntity: inc,
        ));
      }

      // 6. Standalone Expenses (Payments - Money OUT)
      for (var exp in expenses) {
        if (exp.id.startsWith('exp_ret_amt_') ||
            exp.id.startsWith('exp_sr_') ||
            exp.id.startsWith('exp_pur_')) {
          continue; // Skip auto-generated return/purchase expenses to avoid duplicates
        }

        final txNum = exp.title.startsWith('PAY-')
            ? exp.title
            : 'PAY-${exp.id.replaceAll(RegExp(r'[^0-9]'), '')}';

        transactionsList.add(SalesTransactionWrapper(
          id: exp.id,
          type: SalesTransactionType.payment,
          transactionNumber: txNum.length > 16 ? txNum.substring(0, 16) : txNum,
          customerName: exp.partyName?.isNotEmpty == true
              ? exp.partyName!
              : (exp.category.isNotEmpty ? exp.category : 'Vendor / Account'),
          totalAmount: exp.amount,
          paidAmount: exp.amount,
          dueAmount: 0.0,
          statusText: 'Paid',
          date: exp.expenseDate,
          originalEntity: exp,
        ));
      }

      transactionsList.sort((a, b) => b.date.compareTo(a.date));

      final initialFiltered = _filterTransactions(
        allTransactions: transactionsList,
        query: '',
        typeFilter: 'All',
        statusFilter: 'All',
        invoiceStatusFilter: 'All',
        dateRangeFilter: 'All',
        customStartDate: null,
        customEndDate: null,
        customer: 'All',
        sortOption: 'newest',
      );

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
          allTransactions: transactionsList,
          filteredTransactions: initialFiltered,
          dateRangeFilter: 'All',
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
      final filteredList = _filterTransactions(
        allTransactions: current.allTransactions,
        query: query,
        typeFilter: current.selectedTypeFilter,
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
        filteredTransactions: filteredList,
      ));
    }
  }

  void _onFilterSalesOverview(
      FilterSalesOverviewEvent event, Emitter<SalesOverviewState> emit) {
    if (state is SalesOverviewLoadedState) {
      final current = state as SalesOverviewLoadedState;
      final typeFilter = event.primaryFilter;
      final filteredList = _filterTransactions(
        allTransactions: current.allTransactions,
        query: current.searchQuery,
        typeFilter: typeFilter,
        statusFilter: current.statusFilter,
        invoiceStatusFilter: current.invoiceStatusFilter,
        dateRangeFilter: current.dateRangeFilter,
        customStartDate: current.customStartDate,
        customEndDate: current.customEndDate,
        customer: current.selectedCustomer,
        sortOption: current.sortOption,
      );

      emit(current.copyWith(
        selectedTypeFilter: typeFilter,
        filteredTransactions: filteredList,
      ));
    }
  }

  void _onApplyAdvancedFilter(
      ApplyAdvancedFilterEvent event, Emitter<SalesOverviewState> emit) {
    if (state is SalesOverviewLoadedState) {
      final current = state as SalesOverviewLoadedState;
      final filteredList = _filterTransactions(
        allTransactions: current.allTransactions,
        query: current.searchQuery,
        typeFilter: event.transactionType != 'All' ? event.transactionType : current.selectedTypeFilter,
        statusFilter: event.status,
        invoiceStatusFilter: event.invoiceStatus,
        dateRangeFilter: event.dateRange,
        customStartDate: event.customStartDate,
        customEndDate: event.customEndDate,
        customer: event.customer,
        sortOption: event.sortOption,
      );

      emit(current.copyWith(
        selectedTypeFilter: event.transactionType != 'All' ? event.transactionType : current.selectedTypeFilter,
        statusFilter: event.status,
        invoiceStatusFilter: event.invoiceStatus,
        dateRangeFilter: event.dateRange,
        customStartDate: event.customStartDate,
        customEndDate: event.customEndDate,
        selectedCustomer: event.customer,
        sortOption: event.sortOption,
        filteredTransactions: filteredList,
      ));
    }
  }

  void _onClearSalesOverviewFilters(
      ClearSalesOverviewFiltersEvent event, Emitter<SalesOverviewState> emit) {
    if (state is SalesOverviewLoadedState) {
      final current = state as SalesOverviewLoadedState;
      final resetList = _filterTransactions(
        allTransactions: current.allTransactions,
        query: '',
        typeFilter: 'All',
        statusFilter: 'All',
        invoiceStatusFilter: 'All',
        dateRangeFilter: 'All',
        customStartDate: null,
        customEndDate: null,
        customer: 'All',
        sortOption: 'newest',
      );

      emit(current.copyWith(
        searchQuery: '',
        selectedTypeFilter: 'All',
        statusFilter: 'All',
        invoiceStatusFilter: 'All',
        dateRangeFilter: 'All',
        customStartDate: null,
        customEndDate: null,
        selectedCustomer: 'All',
        sortOption: 'newest',
        filteredTransactions: resetList,
      ));
    }
  }

  List<SalesTransactionWrapper> _filterTransactions({
    required List<SalesTransactionWrapper> allTransactions,
    required String query,
    required String typeFilter,
    required String statusFilter,
    required String invoiceStatusFilter,
    required String dateRangeFilter,
    required DateTime? customStartDate,
    required DateTime? customEndDate,
    required String customer,
    required String sortOption,
  }) {
    List<SalesTransactionWrapper> result = List.from(allTransactions);

    // 1. Filter by Active Tab / Type Filter
    if (typeFilter != 'All') {
      if (typeFilter == 'Invoices' || typeFilter == 'Invoice') {
        result = result.where((item) => item.isInvoice).toList();
      } else if (typeFilter == 'Returns' || typeFilter == 'Return') {
        result = result.where((item) => item.isReturn).toList();
      } else if (typeFilter == 'Payments' || typeFilter == 'Payment') {
        result = result.where((item) => item.isPayment || item.isReceipt).toList();
      }
    }

    // 2. Filter by Payment Status
    if (statusFilter != 'All') {
      final now = DateTime.now();
      if (statusFilter == 'Paid') {
        result = result.where((item) => item.statusText == 'Paid').toList();
      } else if (statusFilter == 'Received') {
        result = result.where((item) => item.statusText == 'Received').toList();
      } else if (statusFilter == 'Unpaid') {
        result = result.where((item) => item.statusText == 'Unpaid').toList();
      } else if (statusFilter == 'Partially Paid') {
        result = result.where((item) => item.statusText == 'Partially Paid').toList();
      } else if (statusFilter == 'Overdue') {
        result = result.where((item) {
          if (item.isInvoice && item.asInvoice != null) {
            final inv = item.asInvoice!;
            final isUnpaid = inv.status == InvoiceStatus.unpaid || inv.status == InvoiceStatus.partiallyPaid;
            return isUnpaid && inv.dueDate.isBefore(now);
          }
          return false;
        }).toList();
      }
    }

    // 3. Filter by Invoice Status
    if (invoiceStatusFilter != 'All') {
      if (invoiceStatusFilter == 'Draft') {
        result = result.where((item) => item.isInvoice && item.asInvoice?.status == InvoiceStatus.draft).toList();
      } else if (invoiceStatusFilter == 'Issued') {
        result = result.where((item) => item.isInvoice && item.asInvoice?.status != InvoiceStatus.draft && item.asInvoice?.status != InvoiceStatus.cancelled).toList();
      } else if (invoiceStatusFilter == 'Cancelled') {
        result = result.where((item) => item.statusText == 'Cancelled' || (item.isInvoice && item.asInvoice?.status == InvoiceStatus.cancelled)).toList();
      } else if (invoiceStatusFilter == 'Returned') {
        result = result.where((item) => item.isReturn || item.statusText == 'Returned').toList();
      }
    }

    // 4. Filter by Customer / Party
    if (customer != 'All' && customer.trim().isNotEmpty) {
      final cust = customer.toLowerCase().trim();
      result = result.where((item) => item.customerName.toLowerCase().contains(cust)).toList();
    }

    // 5. Filter by Date Range
    if (dateRangeFilter != 'All') {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      if (dateRangeFilter == 'Today') {
        result = result.where((item) => item.date.isAfter(todayStart.subtract(const Duration(seconds: 1))) && item.date.isBefore(todayEnd.add(const Duration(seconds: 1)))).toList();
      } else if (dateRangeFilter == 'Yesterday') {
        final yestStart = todayStart.subtract(const Duration(days: 1));
        final yestEnd = todayStart.subtract(const Duration(seconds: 1));
        result = result.where((item) => item.date.isAfter(yestStart) && item.date.isBefore(yestEnd)).toList();
      } else if (dateRangeFilter == 'This week') {
        final monday = todayStart.subtract(Duration(days: now.weekday - 1));
        result = result.where((item) => item.date.isAfter(monday.subtract(const Duration(seconds: 1)))).toList();
      } else if (dateRangeFilter == 'This month') {
        final monthStart = DateTime(now.year, now.month, 1);
        result = result.where((item) => item.date.isAfter(monthStart.subtract(const Duration(seconds: 1)))).toList();
      } else if (dateRangeFilter == 'Custom' && customStartDate != null) {
        final start = DateTime(customStartDate.year, customStartDate.month, customStartDate.day);
        final end = customEndDate != null
            ? DateTime(customEndDate.year, customEndDate.month, customEndDate.day, 23, 59, 59)
            : DateTime(customStartDate.year, customStartDate.month, customStartDate.day, 23, 59, 59);
        result = result.where((item) => item.date.isAfter(start.subtract(const Duration(seconds: 1))) && item.date.isBefore(end.add(const Duration(seconds: 1)))).toList();
      }
    }

    // 6. Filter by Search Query (Applies on top of active filters)
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      result = result.where((item) {
        return item.transactionNumber.toLowerCase().contains(q) ||
            item.customerName.toLowerCase().contains(q) ||
            item.customerPhone.toLowerCase().contains(q) ||
            item.typeLabel.toLowerCase().contains(q) ||
            item.statusText.toLowerCase().contains(q) ||
            item.totalAmount.toString().contains(q);
      }).toList();
    }

    // 7. Sort
    switch (sortOption) {
      case 'oldest':
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'amount_high':
        result.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
      case 'amount_low':
        result.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;
      case 'name_asc':
        result.sort((a, b) => a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase()));
        break;
      case 'name_desc':
        result.sort((a, b) => b.customerName.toLowerCase().compareTo(a.customerName.toLowerCase()));
        break;
      case 'newest':
      default:
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
    }

    return result;
  }
}
