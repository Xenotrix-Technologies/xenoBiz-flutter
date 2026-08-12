import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/repositories/product_repository.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class FetchDashboardDataEvent extends DashboardEvent {}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitialState extends DashboardState {}

class DashboardLoadingState extends DashboardState {}

class DashboardLoadedState extends DashboardState {
  final double todaySales;
  final double weeklySales;
  final double monthlySales;
  final double totalReceivables;
  final double totalPayables;
  final double todayExpenses;
  final double netProfit;
  final List<InvoiceEntity> recentInvoices;
  final List<ProductEntity> lowStockProducts;
  final List<CustomerEntity> topCustomers;

  const DashboardLoadedState({
    required this.todaySales,
    required this.weeklySales,
    required this.monthlySales,
    required this.totalReceivables,
    required this.totalPayables,
    required this.todayExpenses,
    required this.netProfit,
    required this.recentInvoices,
    required this.lowStockProducts,
    required this.topCustomers,
  });

  @override
  List<Object?> get props => [
        todaySales,
        weeklySales,
        monthlySales,
        totalReceivables,
        totalPayables,
        todayExpenses,
        netProfit,
        recentInvoices,
        lowStockProducts,
        topCustomers,
      ];
}

class DashboardErrorState extends DashboardState {
  final String message;

  const DashboardErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final InvoiceRepository invoiceRepository;
  final CustomerRepository customerRepository;
  final ProductRepository productRepository;
  final ExpenseRepository expenseRepository;

  DashboardBloc({
    required this.invoiceRepository,
    required this.customerRepository,
    required this.productRepository,
    required this.expenseRepository,
  }) : super(DashboardInitialState()) {
    on<FetchDashboardDataEvent>(_onFetchDashboardData);
  }

  Future<void> _onFetchDashboardData(
      FetchDashboardDataEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoadingState());
    try {
      final invoices = await invoiceRepository.getInvoices();
      final customers = await customerRepository.getCustomers();
      final products = await productRepository.getProducts();
      final expenses = await expenseRepository.getExpenses();

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);

      double today = invoices
          .where((i) => i.issueDate.isAfter(todayStart))
          .fold(0.0, (sum, i) => sum + i.grandTotal);

      double weekly = invoices
          .where((i) => i.issueDate.isAfter(weekStart))
          .fold(0.0, (sum, i) => sum + i.grandTotal);

      double monthly = invoices
          .where((i) => i.issueDate.isAfter(monthStart))
          .fold(0.0, (sum, i) => sum + i.grandTotal);

      double receivables = customers.fold(0.0, (sum, c) => sum + c.outstandingBalance);
      double payables = 0.0;
      double todayExp = expenses
          .where((e) => e.expenseDate.isAfter(todayStart))
          .fold(0.0, (sum, e) => sum + e.amount);

      double totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
      double profit = monthly - totalExpenses;

      final lowStock = products.where((p) => p.isLowStock).toList();

      emit(
        DashboardLoadedState(
          todaySales: today,
          weeklySales: weekly,
          monthlySales: monthly,
          totalReceivables: receivables,
          totalPayables: payables,
          todayExpenses: todayExp,
          netProfit: profit,
          recentInvoices: invoices,
          lowStockProducts: lowStock,
          topCustomers: customers,
        ),
      );
    } catch (e) {
      emit(DashboardErrorState(e.toString()));
    }
  }
}
