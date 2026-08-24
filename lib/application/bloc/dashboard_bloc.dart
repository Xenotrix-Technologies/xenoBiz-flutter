import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/daily_sales_expense_data.dart';
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

  final double monthlySales;
  final double totalReceivables;
  final double totalPayables;
  final double netProfit;
  final List<InvoiceEntity> recentInvoices;
  final List<ProductEntity> lowStockProducts;
  final List<CustomerEntity> topCustomers;

  const DashboardLoadedState({
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
    required this.monthlySales,
    required this.totalReceivables,
    required this.totalPayables,
    required this.netProfit,
    required this.recentInvoices,
    required this.lowStockProducts,
    required this.topCustomers,
  });

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
        monthlySales,
        totalReceivables,
        totalPayables,
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
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final monthStart = DateTime(now.year, now.month, 1);

      // Today calculations
      final todayInvoices = invoices.where((i) {
        return i.issueDate.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
            i.issueDate.isBefore(todayEnd.add(const Duration(seconds: 1)));
      }).toList();

      final double todaySales = todayInvoices.fold(0.0, (sum, i) => sum + i.grandTotal);
      final double todayExp = expenses.where((e) {
        return e.expenseDate.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
            e.expenseDate.isBefore(todayEnd.add(const Duration(seconds: 1)));
      }).fold(0.0, (sum, e) => sum + e.amount);

      final double todayNet = todaySales - todayExp;
      final int todayInvoiceCount = todayInvoices.length;
      final int todayPaidCount = todayInvoices.where((i) => i.status == InvoiceStatus.paid).length;
      final int todayDueCount = todayInvoices
          .where((i) => i.status == InvoiceStatus.unpaid || i.status == InvoiceStatus.partiallyPaid)
          .length;

      // Receivables & Total Outstanding
      double receivables = customers.fold(0.0, (sum, c) => sum + c.outstandingBalance);
      if (receivables == 0.0) {
        receivables = invoices
            .where((i) => i.status == InvoiceStatus.unpaid || i.status == InvoiceStatus.partiallyPaid)
            .fold(0.0, (sum, i) => sum + i.dueAmount);
      }
      final double totalOutstanding = receivables;

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

      final double weeklySales = weeklyBreakdown.fold(0.0, (sum, d) => sum + d.sales);
      final double weeklyExpenses = weeklyBreakdown.fold(0.0, (sum, d) => sum + d.expenses);
      final double weeklyNet = weeklySales - weeklyExpenses;

      double monthlySales = invoices
          .where((i) => i.issueDate.isAfter(monthStart))
          .fold(0.0, (sum, i) => sum + i.grandTotal);

      double totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
      double profit = monthlySales - totalExpenses;

      final lowStock = products.where((p) => p.isLowStock).toList();

      final sortedInvoices = List<InvoiceEntity>.from(invoices)
        ..sort((a, b) => b.issueDate.compareTo(a.issueDate));

      emit(
        DashboardLoadedState(
          todaySales: todaySales,
          todayExpenses: todayExp,
          todayNet: todayNet,
          todayInvoiceCount: todayInvoiceCount,
          todayPaidCount: todayPaidCount,
          todayDueCount: todayDueCount,
          totalOutstandingAmount: totalOutstanding,
          weeklySales: weeklySales,
          weeklyExpenses: weeklyExpenses,
          weeklyNet: weeklyNet,
          weeklyDailyBreakdown: weeklyBreakdown,
          monthlySales: monthlySales,
          totalReceivables: receivables,
          totalPayables: 0.0,
          netProfit: profit,
          recentInvoices: sortedInvoices.take(5).toList(),
          lowStockProducts: lowStock,
          topCustomers: customers,
        ),
      );
    } catch (e) {
      emit(DashboardErrorState(e.toString()));
    }
  }
}

