import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../infrastructure/storage/hive_service.dart';

class ExpenseAccountSummary extends Equatable {
  final String id;
  final String title;
  final String category;
  final int transactionCount;
  final double currentMonthTotal;
  final double outstandingBalance;
  final DateTime? lastTransactionDate;

  const ExpenseAccountSummary({
    required this.id,
    required this.title,
    required this.category,
    required this.transactionCount,
    required this.currentMonthTotal,
    required this.outstandingBalance,
    this.lastTransactionDate,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        transactionCount,
        currentMonthTotal,
        outstandingBalance,
        lastTransactionDate,
      ];
}

// Events
abstract class AccountsEvent extends Equatable {
  const AccountsEvent();

  @override
  List<Object?> get props => [];
}

class FetchAccountsEvent extends AccountsEvent {
  final String query;
  final String filterStatus;
  final String sortBy;

  const FetchAccountsEvent({
    this.query = '',
    this.filterStatus = 'All',
    this.sortBy = 'Name',
  });

  @override
  List<Object?> get props => [query, filterStatus, sortBy];
}

class CreateCustomerAccountEvent extends AccountsEvent {
  final CustomerEntity customer;

  const CreateCustomerAccountEvent(this.customer);

  @override
  List<Object?> get props => [customer];
}

class UpdateCustomerAccountEvent extends AccountsEvent {
  final CustomerEntity customer;

  const UpdateCustomerAccountEvent(this.customer);

  @override
  List<Object?> get props => [customer];
}

class DeleteCustomerAccountEvent extends AccountsEvent {
  final String customerId;

  const DeleteCustomerAccountEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class CreateExpenseAccountEvent extends AccountsEvent {
  final String title;
  final String category;
  final double openingBalance;

  const CreateExpenseAccountEvent({
    required this.title,
    required this.category,
    this.openingBalance = 0.0,
  });

  @override
  List<Object?> get props => [title, category, openingBalance];
}

class UpdateExpenseAccountEvent extends AccountsEvent {
  final String oldCategory;
  final String newTitle;
  final String newCategory;

  const UpdateExpenseAccountEvent({
    required this.oldCategory,
    required this.newTitle,
    required this.newCategory,
  });

  @override
  List<Object?> get props => [oldCategory, newTitle, newCategory];
}

class DeleteExpenseAccountEvent extends AccountsEvent {
  final String category;

  const DeleteExpenseAccountEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class RecordCustomerPaymentEvent extends AccountsEvent {
  final String customerId;
  final double amount;
  final String paymentMethod;
  final String note;
  final DateTime date;

  const RecordCustomerPaymentEvent({
    required this.customerId,
    required this.amount,
    required this.paymentMethod,
    required this.note,
    required this.date,
  });

  @override
  List<Object?> get props => [customerId, amount, paymentMethod, note, date];
}

class RecordExpensePaymentEvent extends AccountsEvent {
  final String category;
  final double amount;
  final String paymentMethod;
  final String note;
  final DateTime date;

  const RecordExpensePaymentEvent({
    required this.category,
    required this.amount,
    required this.paymentMethod,
    required this.note,
    required this.date,
  });

  @override
  List<Object?> get props => [category, amount, paymentMethod, note, date];
}

// States
abstract class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object?> get props => [];
}

class AccountsInitialState extends AccountsState {}

class AccountsLoadingState extends AccountsState {}

class AccountsLoadedState extends AccountsState {
  final double customerDueTotal;
  final double expenseDueTotal;
  final int customerCount;
  final int expenseAccountCount;

  final List<CustomerEntity> allCustomers;
  final List<CustomerEntity> filteredCustomers;

  final List<ExpenseAccountSummary> expenseAccounts;
  final List<ExpenseAccountSummary> filteredExpenseAccounts;

  final String searchQuery;
  final String selectedFilterStatus;
  final String sortBy;

  const AccountsLoadedState({
    required this.customerDueTotal,
    required this.expenseDueTotal,
    required this.customerCount,
    required this.expenseAccountCount,
    required this.allCustomers,
    required this.filteredCustomers,
    required this.expenseAccounts,
    required this.filteredExpenseAccounts,
    this.searchQuery = '',
    this.selectedFilterStatus = 'All',
    this.sortBy = 'Name',
  });

  AccountsLoadedState copyWith({
    double? customerDueTotal,
    double? expenseDueTotal,
    int? customerCount,
    int? expenseAccountCount,
    List<CustomerEntity>? allCustomers,
    List<CustomerEntity>? filteredCustomers,
    List<ExpenseAccountSummary>? expenseAccounts,
    List<ExpenseAccountSummary>? filteredExpenseAccounts,
    String? searchQuery,
    String? selectedFilterStatus,
    String? sortBy,
  }) {
    return AccountsLoadedState(
      customerDueTotal: customerDueTotal ?? this.customerDueTotal,
      expenseDueTotal: expenseDueTotal ?? this.expenseDueTotal,
      customerCount: customerCount ?? this.customerCount,
      expenseAccountCount: expenseAccountCount ?? this.expenseAccountCount,
      allCustomers: allCustomers ?? this.allCustomers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      expenseAccounts: expenseAccounts ?? this.expenseAccounts,
      filteredExpenseAccounts: filteredExpenseAccounts ?? this.filteredExpenseAccounts,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilterStatus: selectedFilterStatus ?? this.selectedFilterStatus,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  List<Object?> get props => [
        customerDueTotal,
        expenseDueTotal,
        customerCount,
        expenseAccountCount,
        allCustomers,
        filteredCustomers,
        expenseAccounts,
        filteredExpenseAccounts,
        searchQuery,
        selectedFilterStatus,
        sortBy,
      ];
}

class AccountsErrorState extends AccountsState {
  final String message;

  const AccountsErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  final CustomerRepository customerRepository;
  final ExpenseRepository expenseRepository;
  final InvoiceRepository invoiceRepository;
  final HiveService hiveService;

  static const List<String> defaultExpenseCategories = [
    'Electricity',
    'Rent',
    'Water',
    'Internet',
    'Telephone',
    'Salary',
    'Transport',
    'Fuel',
    'Office Supplies',
    'Maintenance',
    'Marketing',
    'Bank Charges',
    'Other',
  ];

  AccountsBloc({
    required this.customerRepository,
    required this.expenseRepository,
    required this.invoiceRepository,
    required this.hiveService,
  }) : super(AccountsInitialState()) {
    on<FetchAccountsEvent>(_onFetchAccounts);
    on<CreateCustomerAccountEvent>(_onCreateCustomerAccount);
    on<UpdateCustomerAccountEvent>(_onUpdateCustomerAccount);
    on<DeleteCustomerAccountEvent>(_onDeleteCustomerAccount);
    on<CreateExpenseAccountEvent>(_onCreateExpenseAccount);
    on<UpdateExpenseAccountEvent>(_onUpdateExpenseAccount);
    on<DeleteExpenseAccountEvent>(_onDeleteExpenseAccount);
    on<RecordCustomerPaymentEvent>(_onRecordCustomerPayment);
    on<RecordExpensePaymentEvent>(_onRecordExpensePayment);
  }

  Future<void> _onFetchAccounts(
      FetchAccountsEvent event, Emitter<AccountsState> emit) async {
    emit(AccountsLoadingState());
    await _loadAccountsData(
      emit: emit,
      query: event.query,
      filterStatus: event.filterStatus,
      sortBy: event.sortBy,
    );
  }

  Future<void> _onCreateCustomerAccount(
      CreateCustomerAccountEvent event, Emitter<AccountsState> emit) async {
    try {
      await customerRepository.createCustomer(event.customer);
      await _loadAccountsData(emit: emit);
    } catch (e) {
      emit(AccountsErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateCustomerAccount(
      UpdateCustomerAccountEvent event, Emitter<AccountsState> emit) async {
    try {
      await customerRepository.updateCustomer(event.customer);
      await _loadAccountsData(emit: emit);
    } catch (e) {
      emit(AccountsErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteCustomerAccount(
      DeleteCustomerAccountEvent event, Emitter<AccountsState> emit) async {
    try {
      await customerRepository.deleteCustomer(event.customerId);
      await _loadAccountsData(emit: emit);
    } catch (e) {
      emit(AccountsErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateExpenseAccount(
      CreateExpenseAccountEvent event, Emitter<AccountsState> emit) async {
    try {
      final expBox = hiveService.getBox(HiveService.boxExpenses);
      final String id = 'exp_acc_${DateTime.now().millisecondsSinceEpoch}';

      if (event.openingBalance > 0) {
        await expenseRepository.createExpense(
          ExpenseEntity(
            id: id,
            title: '${event.title} Opening Balance',
            category: event.category,
            amount: event.openingBalance,
            paymentMode: 'Account',
            expenseDate: DateTime.now(),
            notes: 'Opening balance',
          ),
        );
      }

      await expBox.put('cat_${event.category}', {
        'id': id,
        'title': event.title,
        'category': event.category,
        'createdAt': DateTime.now().toIso8601String(),
      });

      await _loadAccountsData(emit: emit);
    } catch (e) {
      emit(AccountsErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateExpenseAccount(
      UpdateExpenseAccountEvent event, Emitter<AccountsState> emit) async {
    try {
      final expBox = hiveService.getBox(HiveService.boxExpenses);
      await expBox.put('cat_${event.newCategory}', {
        'id': 'exp_acc_${DateTime.now().millisecondsSinceEpoch}',
        'title': event.newTitle,
        'category': event.newCategory,
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (event.oldCategory != event.newCategory) {
        await expBox.delete('cat_${event.oldCategory}');
      }

      await _loadAccountsData(emit: emit);
    } catch (e) {
      emit(AccountsErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteExpenseAccount(
      DeleteExpenseAccountEvent event, Emitter<AccountsState> emit) async {
    try {
      final expBox = hiveService.getBox(HiveService.boxExpenses);
      await expBox.delete('cat_${event.category}');
      await _loadAccountsData(emit: emit);
    } catch (e) {
      emit(AccountsErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRecordCustomerPayment(
      RecordCustomerPaymentEvent event, Emitter<AccountsState> emit) async {
    try {
      final customers = await customerRepository.getCustomers();
      final customer = customers.firstWhere((c) => c.id == event.customerId);

      final newBalance = (customer.outstandingBalance - event.amount).clamp(0.0, double.infinity);
      await customerRepository.updateCustomer(
        customer.copyWith(outstandingBalance: newBalance),
      );

      // Apply payment to unpaid invoices for this customer
      final invoices = await invoiceRepository.getInvoices();
      final customerInvoices = invoices
          .where((i) => i.customerId == event.customerId && i.dueAmount > 0)
          .toList()
        ..sort((a, b) => a.issueDate.compareTo(b.issueDate));

      double remainingPayment = event.amount;
      for (var inv in customerInvoices) {
        if (remainingPayment <= 0) break;
        final due = inv.dueAmount;
        final payForInv = remainingPayment >= due ? due : remainingPayment;
        remainingPayment -= payForInv;

        final newPaid = inv.paidAmount + payForInv;
        final newStatus = (newPaid >= inv.grandTotal)
            ? InvoiceStatus.paid
            : InvoiceStatus.partiallyPaid;

        await invoiceRepository.updateInvoice(
          inv.copyWith(paidAmount: newPaid, status: newStatus),
        );
      }

      await _loadAccountsData(emit: emit);
    } catch (e) {
      emit(AccountsErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRecordExpensePayment(
      RecordExpensePaymentEvent event, Emitter<AccountsState> emit) async {
    try {
      await expenseRepository.createExpense(
        ExpenseEntity(
          id: '',
          title: '${event.category} Payment',
          category: event.category,
          amount: event.amount,
          paymentMode: event.paymentMethod,
          expenseDate: event.date,
          notes: event.note,
        ),
      );

      await _loadAccountsData(emit: emit);
    } catch (e) {
      emit(AccountsErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _loadAccountsData({
    required Emitter<AccountsState> emit,
    String query = '',
    String filterStatus = 'All',
    String sortBy = 'Name',
  }) async {
    try {
      final customers = await customerRepository.getCustomers();
      final expenses = await expenseRepository.getExpenses();

      // Customer due total
      final double customerDueTotal = customers.fold(0.0, (sum, c) => sum + c.outstandingBalance);

      // Build Expense Account Summaries
      final now = DateTime.now();
      final currentMonthStart = DateTime(now.year, now.month, 1);

      // Categories set (defaults + existing expenses)
      final Set<String> categories = Set.from(defaultExpenseCategories);
      for (var e in expenses) {
        if (e.category.isNotEmpty) categories.add(e.category);
      }

      final List<ExpenseAccountSummary> expSummaries = [];
      double expenseDueTotal = 0.0;

      for (var cat in categories) {
        final catExpenses = expenses.where((e) => e.category == cat).toList();
        final monthTotal = catExpenses
            .where((e) => e.expenseDate.isAfter(currentMonthStart.subtract(const Duration(seconds: 1))))
            .fold(0.0, (sum, e) => sum + e.amount);

        // Account mode expenses count as outstanding liability if pending
        final accountExpTotal = catExpenses
            .where((e) => e.paymentMode == 'Account')
            .fold(0.0, (sum, e) => sum + e.amount);

        expenseDueTotal += accountExpTotal;

        DateTime? lastDate;
        if (catExpenses.isNotEmpty) {
          catExpenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
          lastDate = catExpenses.first.expenseDate;
        }

        expSummaries.add(
          ExpenseAccountSummary(
            id: 'EXP_${cat.toUpperCase().replaceAll(' ', '_')}',
            title: cat,
            category: cat,
            transactionCount: catExpenses.length,
            currentMonthTotal: monthTotal,
            outstandingBalance: accountExpTotal,
            lastTransactionDate: lastDate,
          ),
        );
      }

      // Filter & Sort Customers
      var filteredCust = List<CustomerEntity>.from(customers);
      if (query.trim().isNotEmpty) {
        final q = query.toLowerCase().trim();
        filteredCust = filteredCust.where((c) {
          return c.name.toLowerCase().contains(q) ||
              c.phone.toLowerCase().contains(q) ||
              c.email.toLowerCase().contains(q) ||
              c.id.toLowerCase().contains(q);
        }).toList();
      }

      if (filterStatus == 'With Due' || filterStatus == 'With Outstanding') {
        filteredCust = filteredCust.where((c) => c.outstandingBalance > 0).toList();
      } else if (filterStatus == 'Paid') {
        filteredCust = filteredCust.where((c) => c.outstandingBalance == 0).toList();
      }

      if (sortBy == 'Highest Due') {
        filteredCust.sort((a, b) => b.outstandingBalance.compareTo(a.outstandingBalance));
      } else {
        filteredCust.sort((a, b) => a.name.compareTo(b.name));
      }

      // Filter & Sort Expense Accounts
      var filteredExp = List<ExpenseAccountSummary>.from(expSummaries);
      if (query.trim().isNotEmpty) {
        final q = query.toLowerCase().trim();
        filteredExp = filteredExp.where((e) {
          return e.title.toLowerCase().contains(q) || e.category.toLowerCase().contains(q);
        }).toList();
      }

      if (filterStatus == 'With Due' || filterStatus == 'With Outstanding') {
        filteredExp = filteredExp.where((e) => e.outstandingBalance > 0).toList();
      } else if (filterStatus == 'Paid') {
        filteredExp = filteredExp.where((e) => e.outstandingBalance == 0).toList();
      }

      if (sortBy == 'Highest Due') {
        filteredExp.sort((a, b) => b.outstandingBalance.compareTo(a.outstandingBalance));
      } else {
        filteredExp.sort((a, b) => a.title.compareTo(b.title));
      }

      emit(
        AccountsLoadedState(
          customerDueTotal: customerDueTotal,
          expenseDueTotal: expenseDueTotal,
          customerCount: customers.length,
          expenseAccountCount: expSummaries.length,
          allCustomers: customers,
          filteredCustomers: filteredCust,
          expenseAccounts: expSummaries,
          filteredExpenseAccounts: filteredExp,
          searchQuery: query,
          selectedFilterStatus: filterStatus,
          sortBy: sortBy,
        ),
      );
    } catch (e) {
      emit(AccountsErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
