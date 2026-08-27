import 'dart:convert';
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
import '../../infrastructure/database/app_database.dart';

// Events
abstract class GlobalSearchEvent extends Equatable {
  const GlobalSearchEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecentSearchesEvent extends GlobalSearchEvent {}

class PerformGlobalSearchEvent extends GlobalSearchEvent {
  final String query;
  final String categoryFilter; // All, Customers, Invoices, Products, Expenses, Purchases

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
      customers.length + invoices.length + products.length + expenses.length + purchases.length;

  GlobalSearchLoadedState copyWith({
    String? query,
    String? categoryFilter,
    List<CustomerEntity>? customers,
    List<InvoiceEntity>? invoices,
    List<ProductEntity>? products,
    List<ExpenseEntity>? expenses,
    List<PurchaseEntity>? purchases,
    List<String>? recentSearches,
  }) {
    return GlobalSearchLoadedState(
      query: query ?? this.query,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      customers: customers ?? this.customers,
      invoices: invoices ?? this.invoices,
      products: products ?? this.products,
      expenses: expenses ?? this.expenses,
      purchases: purchases ?? this.purchases,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }

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
  final AppDatabase db;

  GlobalSearchBloc({
    required this.customerRepository,
    required this.invoiceRepository,
    required this.productRepository,
    required this.expenseRepository,
    required this.purchaseRepository,
    required this.db,
  }) : super(const GlobalSearchInitialState()) {
    on<LoadRecentSearchesEvent>(_onLoadRecentSearches);
    on<PerformGlobalSearchEvent>(_onPerformGlobalSearch);
    on<ChangeSearchCategoryFilterEvent>(_onChangeCategoryFilter);
    on<AddRecentSearchQueryEvent>(_onAddRecentSearchQuery);
    on<ClearRecentSearchesEvent>(_onClearRecentSearches);
    on<ClearGlobalSearchEvent>(_onClearGlobalSearch);
  }

  Future<List<String>> _getRecentSearchesFromDb() async {
    try {
      final raw = await db.getKeyValue('recent_global_searches');
      if (raw != null) {
        final List list = jsonDecode(raw);
        return list.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _saveRecentSearchesToDb(List<String> list) async {
    try {
      await db.putKeyValue('recent_global_searches', jsonEncode(list));
    } catch (_) {}
  }

  Future<void> _onLoadRecentSearches(
      LoadRecentSearchesEvent event, Emitter<GlobalSearchState> emit) async {
    final recent = await _getRecentSearchesFromDb();
    emit(GlobalSearchInitialState(recentSearches: recent));
  }

  Future<void> _onPerformGlobalSearch(
      PerformGlobalSearchEvent event, Emitter<GlobalSearchState> emit) async {
    final q = event.query.trim().toLowerCase();
    if (q.isEmpty) {
      final recent = await _getRecentSearchesFromDb();
      emit(GlobalSearchInitialState(recentSearches: recent));
      return;
    }

    emit(GlobalSearchLoadingState(
      query: event.query,
      categoryFilter: event.categoryFilter,
    ));

    try {
      final allCustomers = await customerRepository.getCustomers();
      final allInvoices = await invoiceRepository.getInvoices();
      final allProducts = await productRepository.getProducts();
      final allExpenses = await expenseRepository.getExpenses();
      final allPurchases = await purchaseRepository.getPurchaseOrders();
      final recent = await _getRecentSearchesFromDb();

      List<CustomerEntity> matchedCustomers = [];
      List<InvoiceEntity> matchedInvoices = [];
      List<ProductEntity> matchedProducts = [];
      List<ExpenseEntity> matchedExpenses = [];
      List<PurchaseEntity> matchedPurchases = [];

      final cat = event.categoryFilter;

      if (cat == 'All' || cat == 'Customers') {
        matchedCustomers = allCustomers.where((c) {
          return c.name.toLowerCase().contains(q) ||
              c.phone.toLowerCase().contains(q) ||
              c.email.toLowerCase().contains(q) ||
              c.address.toLowerCase().contains(q);
        }).toList();
      }

      if (cat == 'All' || cat == 'Invoices') {
        matchedInvoices = allInvoices.where((i) {
          return i.invoiceNumber.toLowerCase().contains(q) ||
              i.customerName.toLowerCase().contains(q) ||
              i.customerPhone.toLowerCase().contains(q) ||
              i.grandTotal.toString().contains(q) ||
              i.notes.toLowerCase().contains(q);
        }).toList();
      }

      if (cat == 'All' || cat == 'Products') {
        matchedProducts = allProducts.where((p) {
          return p.name.toLowerCase().contains(q) ||
              p.sku.toLowerCase().contains(q) ||
              p.barcode.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q);
        }).toList();
      }

      if (cat == 'All' || cat == 'Expenses') {
        matchedExpenses = allExpenses.where((e) {
          return e.title.toLowerCase().contains(q) ||
              e.category.toLowerCase().contains(q) ||
              e.amount.toString().contains(q) ||
              e.notes.toLowerCase().contains(q);
        }).toList();
      }

      if (cat == 'All' || cat == 'Purchases') {
        matchedPurchases = allPurchases.where((p) {
          return p.poNumber.toLowerCase().contains(q) ||
              p.supplierName.toLowerCase().contains(q) ||
              p.totalAmount.toString().contains(q) ||
              p.notes.toLowerCase().contains(q);
        }).toList();
      }

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

  Future<void> _onChangeCategoryFilter(
      ChangeSearchCategoryFilterEvent event, Emitter<GlobalSearchState> emit) async {
    if (state is GlobalSearchLoadedState) {
      final current = state as GlobalSearchLoadedState;
      add(PerformGlobalSearchEvent(
        query: current.query,
        categoryFilter: event.categoryFilter,
      ));
    }
  }

  Future<void> _onAddRecentSearchQuery(
      AddRecentSearchQueryEvent event, Emitter<GlobalSearchState> emit) async {
    final query = event.query.trim();
    if (query.isEmpty) return;

    final current = await _getRecentSearchesFromDb();
    final updated = List<String>.from(current);
    updated.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    updated.insert(0, query);
    if (updated.length > 5) {
      updated.removeLast();
    }

    await _saveRecentSearchesToDb(updated);

    if (state is GlobalSearchInitialState) {
      emit(GlobalSearchInitialState(recentSearches: updated));
    } else if (state is GlobalSearchLoadedState) {
      final curLoaded = state as GlobalSearchLoadedState;
      emit(curLoaded.copyWith(recentSearches: updated));
    }
  }

  Future<void> _onClearRecentSearches(
      ClearRecentSearchesEvent event, Emitter<GlobalSearchState> emit) async {
    await _saveRecentSearchesToDb([]);
    if (state is GlobalSearchInitialState) {
      emit(const GlobalSearchInitialState(recentSearches: []));
    } else if (state is GlobalSearchLoadedState) {
      final curLoaded = state as GlobalSearchLoadedState;
      emit(curLoaded.copyWith(recentSearches: []));
    }
  }

  Future<void> _onClearGlobalSearch(
      ClearGlobalSearchEvent event, Emitter<GlobalSearchState> emit) async {
    final recent = await _getRecentSearchesFromDb();
    emit(GlobalSearchInitialState(recentSearches: recent));
  }
}
