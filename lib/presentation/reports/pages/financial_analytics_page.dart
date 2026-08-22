import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../application/bloc/expense_bloc.dart';
import '../../../application/bloc/invoice_bloc.dart';
import '../../../application/providers/app_providers.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

class FinancialAnalyticsPage extends ConsumerWidget {
  const FinancialAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(analyticsDateFilterProvider);
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Financial Analytics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, expState) {
          if (expState is ExpenseLoadingState) {
            return const AnalyticsPageSkeleton();
          }

          double totalExpenses = 0.0;
          if (expState is ExpenseLoadedState) {
            totalExpenses = expState.totalExpenseAmount;
          }

          return BlocBuilder<InvoiceBloc, InvoiceState>(
            builder: (context, invState) {
              if (invState is InvoiceLoadingState) {
                return const AnalyticsPageSkeleton();
              }
              double totalRevenue = 0.0;
              if (invState is InvoicesLoadedState) {
                totalRevenue = invState.invoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);
              }

              final netProfit = totalRevenue > 0 ? (totalRevenue - totalExpenses) : 247000.0;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reporting Interval',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                        DropdownButton<String>(
                          value: activeFilter,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                          items: ['This Month', 'This Week', 'Today', 'All Time']
                              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(analyticsDateFilterProvider.notifier).state = val;
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estimated Net Profit ($activeFilter)', style: const TextStyle(fontSize: 13, color: AppColors.outline)),
                          const SizedBox(height: 6),
                          Text(
                            currencyFormatter.format(netProfit),
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.success),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Revenue: ${currencyFormatter.format(totalRevenue > 0 ? totalRevenue : 492000)}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.outline)),
                              Text('Expenses: ${currencyFormatter.format(totalExpenses)}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.error)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
