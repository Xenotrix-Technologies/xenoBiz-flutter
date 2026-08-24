import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../infrastructure/storage/hive_service.dart';

// Events
abstract class GlobalSearchEvent extends Equatable {
  const GlobalSearchEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecentSearchesEvent extends GlobalSearchEvent {}

class PerformGlobalSearchEvent extends GlobalSearchEvent {
  final String query;
  final String categoryFilter;

  const PerformGlobalSearchEvent({
    required this.query,
    this.categoryFilter = 'All',
  });

  @override
  List<Object?> get props => [query, categoryFilter];
}

class ChangeSearchCategoryFilterEvent extends GlobalSearchEvent {
  final String categoryFilter;

  const ChangeSearchCategoryFilterEvent(this.categoryFilter);

  @override
  List<Object?> get props => [categoryFilter];
}

class AddRecentSearchQueryEvent extends GlobalSearchEvent {
  final String query;
  const AddRecentSearchQueryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearRecentSearchesEvent extends GlobalSearchEvent {}

class ClearGlobalSearchEvent extends GlobalSearchEvent {}

// States
abstract class GlobalSearchState extends Equatable {
  const GlobalSearchState();

  @override
  List<Object?> get props => [];
}

class GlobalSearchInitialState extends GlobalSearchState {
  final List<String> recentSearches;

  const GlobalSearchInitialState({this.recentSearches = const []});

  @override
  List<Object?> get props => [recentSearches];
}

class GlobalSearchLoadingState extends GlobalSearchState {
  final String query;
  final String categoryFilter;

  const GlobalSearchLoadingState({
    required this.query,
    required this.categoryFilter,
  });

  @override
  List<Object?> get props => [query, categoryFilter];
}

class GlobalSearchLoadedState extends GlobalSearchState {
  final String query;
  final String categoryFilter;
  final List<CustomerEntity> customers;
  final List<InvoiceEntity> invoices;
  final List<ProductEntity> products;
  final List<ExpenseEntity> expenses;
  final List<PurchaseEntity> purchases;
  final List<String> recentSearches;

  const GlobalSearchLoadedState({
    required this.query,
    required this.categoryFilter,
    required this.customers,
    required this.invoices,
    required this.products,
    required this.expenses,
    required this.purchases,
    required this.recentSearches,
  });

  int get totalResultsCount =>
      customers.length +
      invoices.length +
      products.length +
      expenses.length +
      purchases.length;

  bool get isEmpty => totalResultsCount == 0;

  @override
  List<Object?> get props => [
        query,
        categoryFilter,
        customers,
        invoices,
        products,
        expenses,
        purchases,
        recentSearches,
      ];
}

class GlobalSearchErrorState extends GlobalSearchState {
  final String message;

  const GlobalSearchErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class GlobalSearchBloc extends Bloc<GlobalSearchEvent, GlobalSearchState> {
  final CustomerRepository customerRepository;
  final InvoiceRepository invoiceRepository;
  final ProductRepository productRepository;
  final ExpenseRepository expenseRepository;
  final PurchaseRepository purchaseRepository;
  final HiveService hiveService;

  GlobalSearchBloc({
    required this.customerRepository,
    required this.invoiceRepository,
    required this.productRepository,
    required this.expenseRepository,
    required this.purchaseRepository,
    required this.hiveService,
  }) : super(const GlobalSearchInitialState()) {
    on<LoadRecentSearchesEvent>(_onLoadRecentSearches);
    on<PerformGlobalSearchEvent>(_onPerformGlobalSearch);
    on<ChangeSearchCategoryFilterEvent>(_onChangeCategoryFilter);
    on<AddRecentSearchQueryEvent>(_onAddRecentSearchQuery);
    on<ClearRecentSearchesEvent>(_onClearRecentSearches);
    on<ClearGlobalSearchEvent>(_onClearGlobalSearch);
  }

  List<String> _getRecentSearchesFromHive() {
    try {
      final box = hiveService.getBox(HiveService.boxBusiness);
      final raw = box.get('recent_global_searches');
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _saveRecentSearchesToHive(List<String> list) async {
    try {
      final box = hiveService.getBox(HiveService.boxBusiness);
      await box.put('recent_global_searches', list);
    } catch (_) {}
  }

  void _onLoadRecentSearches(
      LoadRecentSearchesEvent event, Emitter<GlobalSearchState> emit) {
    final recent = _getRecentSearchesFromHive();
    emit(GlobalSearchInitialState(recentSearches: recent));
  }

  Future<void> _onPerformGlobalSearch(
      PerformGlobalSearchEvent event, Emitter<GlobalSearchState> emit) async {
    final q = event.query.trim().toLowerCase();
    if (q.isEmpty) {
      final recent = _getRecentSearchesFromHive();
      emit(GlobalSearchInitialState(recentSearches: recent));
      return;
    }

    emit(GlobalSearchLoadingState(
      query: event.query,
      categoryFilter: event.categoryFilter,
    ));

    try {
      final recent = _getRecentSearchesFromHive();

      // Query across all repositories in parallel
      final results = await Future.wait([
        customerRepository.getCustomers(),
        invoiceRepository.getInvoices(),
        productRepository.getProducts(),
        expenseRepository.getExpenses(),
        purchaseRepository.getPurchaseOrders(),
      ]);

      final allCustomers = results[0] as List<CustomerEntity>;
      final allInvoices = results[1] as List<InvoiceEntity>;
      final allProducts = results[2] as List<ProductEntity>;
      final allExpenses = results[3] as List<ExpenseEntity>;
      final allPurchases = results[4] as List<PurchaseEntity>;

      // Filter Customers
      final matchedCustomers = allCustomers.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.phone.toLowerCase().contains(q) ||
            c.email.toLowerCase().contains(q) ||
            c.address.toLowerCase().contains(q);
      }).toList();

      // Filter Invoices
      final matchedInvoices = allInvoices.where((inv) {
        return inv.invoiceNumber.toLowerCase().contains(q) ||
            inv.customerName.toLowerCase().contains(q) ||
            inv.customerPhone.toLowerCase().contains(q) ||
            inv.notes.toLowerCase().contains(q) ||
            inv.grandTotal.toString().contains(q);
      }).toList();

      // Filter Products
      final matchedProducts = allProducts.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q);
      }).toList();

      // Filter Expenses
      final matchedExpenses = allExpenses.where((e) {
        return e.title.toLowerCase().contains(q) ||
            e.category.toLowerCase().contains(q) ||
            e.notes.toLowerCase().contains(q) ||
            e.amount.toString().contains(q);
      }).toList();

      // Filter Purchases
      final matchedPurchases = allPurchases.where((pur) {
        return pur.poNumber.toLowerCase().contains(q) ||
            pur.supplierName.toLowerCase().contains(q) ||
            pur.notes.toLowerCase().contains(q) ||
            pur.totalAmount.toString().contains(q);
      }).toList();

      emit(GlobalSearchLoadedState(
        query: event.query,
        categoryFilter: event.categoryFilter,
        customers: matchedCustomers,
        invoices: matchedInvoices,
        products: matchedProducts,
        expenses: matchedExpenses,
        purchases: matchedPurchases,
        recentSearches: recent,
      ));
    } catch (e) {
      emit(GlobalSearchErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onChangeCategoryFilter(
      ChangeSearchCategoryFilterEvent event, Emitter<GlobalSearchState> emit) {
    if (state is GlobalSearchLoadedState) {
      final current = state as GlobalSearchLoadedState;
      emit(GlobalSearchLoadedState(
        query: current.query,
        categoryFilter: event.categoryFilter,
        customers: current.customers,
        invoices: current.invoices,
        products: current.products,
        expenses: current.expenses,
        purchases: current.purchases,
        recentSearches: current.recentSearches,
      ));
    }
  }

  Future<void> _onAddRecentSearchQuery(
      AddRecentSearchQueryEvent event, Emitter<GlobalSearchState> emit) async {
    final q = event.query.trim();
    if (q.isEmpty) return;

    final recent = _getRecentSearchesFromHive();
    recent.removeWhere((item) => item.toLowerCase() == q.toLowerCase());
    recent.insert(0, q);
    if (recent.length > 10) {
      recent.removeRange(10, recent.length);
    }
    await _saveRecentSearchesToHive(recent);

    if (state is GlobalSearchInitialState) {
      emit(GlobalSearchInitialState(recentSearches: recent));
    }
  }

  Future<void> _onClearRecentSearches(
      ClearRecentSearchesEvent event, Emitter<GlobalSearchState> emit) async {
    await _saveRecentSearchesToHive([]);
    if (state is GlobalSearchInitialState) {
      emit(const GlobalSearchInitialState(recentSearches: []));
    } else if (state is GlobalSearchLoadedState) {
      final current = state as GlobalSearchLoadedState;
      emit(GlobalSearchLoadedState(
        query: current.query,
        categoryFilter: current.categoryFilter,
        customers: current.customers,
        invoices: current.invoices,
        products: current.products,
        expenses: current.expenses,
        purchases: current.purchases,
        recentSearches: const [],
      ));
    }
  }

  void _onClearGlobalSearch(
      ClearGlobalSearchEvent event, Emitter<GlobalSearchState> emit) {
    final recent = _getRecentSearchesFromHive();
    emit(GlobalSearchInitialState(recentSearches: recent));
  }
}
