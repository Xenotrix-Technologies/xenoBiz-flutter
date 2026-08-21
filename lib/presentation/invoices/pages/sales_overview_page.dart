import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/invoice_bloc.dart';
import '../../../application/bloc/sales_overview_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/ui_state_widgets.dart';

class SalesOverviewPage extends StatefulWidget {
  const SalesOverviewPage({super.key});

  @override
  State<SalesOverviewPage> createState() => _SalesOverviewPageState();
}

class _SalesOverviewPageState extends State<SalesOverviewPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAdvancedFilterBottomSheet(BuildContext context, SalesOverviewLoadedState state) {
    String selectedStatus = state.statusFilter;
    String selectedMethod = state.paymentMethodFilter;
    String selectedDateRange = state.dateRangeFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (bottomSheetContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlueText,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(bottomSheetContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Payment Status Filter
                  const Text(
                    'Payment Status',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['All', 'Paid', 'Unpaid', 'Partially Paid'].map((status) {
                      final isSelected = selectedStatus == status;
                      return ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        selectedColor: AppColors.primaryBlue,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.darkBlueText,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (val) {
                          if (val) setModalState(() => selectedStatus = status);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Payment Method Filter
                  const Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['All', 'Cash', 'GPay/UPI', 'Card', 'Other'].map((method) {
                      final isSelected = selectedMethod == method;
                      return ChoiceChip(
                        label: Text(method),
                        selected: isSelected,
                        selectedColor: AppColors.primaryBlue,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.darkBlueText,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (val) {
                          if (val) setModalState(() => selectedMethod = method);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Date Range Filter
                  const Text(
                    'Date Range',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['All', 'Today', 'This Week', 'This Month'].map((range) {
                      final isSelected = selectedDateRange == range;
                      return ChoiceChip(
                        label: Text(range),
                        selected: isSelected,
                        selectedColor: AppColors.primaryBlue,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.darkBlueText,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (val) {
                          if (val) setModalState(() => selectedDateRange = range);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Bottom Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            context
                                .read<SalesOverviewBloc>()
                                .add(ClearSalesOverviewFiltersEvent());
                            Navigator.pop(bottomSheetContext);
                          },
                          child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            context.read<SalesOverviewBloc>().add(
                                  ApplyAdvancedFilterEvent(
                                    status: selectedStatus,
                                    paymentMethod: selectedMethod,
                                    dateRange: selectedDateRange,
                                  ),
                                );
                            Navigator.pop(bottomSheetContext);
                          },
                          child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return DateFormat('h:mm a').format(date);
    } else if (checkDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sales Overview'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<SalesOverviewBloc, SalesOverviewState>(
        builder: (context, state) {
          if (state is SalesOverviewLoadingState || state is SalesOverviewInitialState) {
            return const SalesOverviewSkeleton();
          }

          if (state is SalesOverviewErrorState) {
            return ErrorState(
              message: state.message,
              onRetry: () => context.read<SalesOverviewBloc>().add(FetchSalesOverviewDataEvent()),
            );
          }

          if (state is SalesOverviewLoadedState) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SalesOverviewBloc>().add(FetchSalesOverviewDataEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Today Summary
                    _buildTodaySummarySection(state),
                    const SizedBox(height: 16),

                    // Section 2: Today's Invoice Statistics & Outstanding
                    _buildInvoiceStatsAndOutstanding(context, state),
                    const SizedBox(height: 24),

                    // Section 3: Weekly Sales vs Expenses Chart
                    _buildWeeklyChartSection(state),
                    const SizedBox(height: 16),

                    // Section 4: Weekly Summary
                    _buildWeeklySummarySection(state),
                    const SizedBox(height: 24),

                    // Section 5: Search Field & Advanced Filter Trigger
                    _buildSearchFieldAndFilterButton(context, state),
                    const SizedBox(height: 12),

                    // Section 6: Horizontally Scrollable Filter Chips
                    _buildFilterChipsRow(context, state),
                    const SizedBox(height: 20),

                    // Section 7: Recent Invoices & Expenses List
                    _buildRecentTransactionsSection(context, state),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // TODAY SUMMARY CARDS
  Widget _buildTodaySummarySection(SalesOverviewLoadedState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.darkBlueText,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 420;
            if (isNarrow) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: 'Sales',
                          amount: _formatCurrency(state.todaySales),
                          amountColor: AppColors.primaryBlue,
                          onTap: () {
                            context.push(
                              RouteNames.dailyLedger,
                              extra: {'initialTab': 0, 'initialDate': DateTime.now()},
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricCard(
                          title: 'Expenses',
                          amount: _formatCurrency(state.todayExpenses),
                          amountColor: AppColors.warning,
                          onTap: () {
                            context.push(
                              RouteNames.dailyLedger,
                              extra: {'initialTab': 1, 'initialDate': DateTime.now()},
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: _MetricCard(
                      title: 'Net',
                      amount: _formatCurrency(state.todayNet),
                      amountColor: state.todayNet >= 0 ? AppColors.success : AppColors.danger,
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Sales',
                    amount: _formatCurrency(state.todaySales),
                    amountColor: AppColors.primaryBlue,
                    onTap: () {
                      context.push(
                        RouteNames.dailyLedger,
                        extra: {'initialTab': 0, 'initialDate': DateTime.now()},
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    title: 'Expenses',
                    amount: _formatCurrency(state.todayExpenses),
                    amountColor: AppColors.warning,
                    onTap: () {
                      context.push(
                        RouteNames.dailyLedger,
                        extra: {'initialTab': 1, 'initialDate': DateTime.now()},
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    title: 'Net',
                    amount: _formatCurrency(state.todayNet),
                    amountColor: state.todayNet >= 0 ? AppColors.success : AppColors.danger,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // INVOICE STATS & OUTSTANDING CARD
  Widget _buildInvoiceStatsAndOutstanding(BuildContext context, SalesOverviewLoadedState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${state.todayInvoiceCount} invoices',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlueText,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('•', style: TextStyle(color: AppColors.secondaryText)),
              ),
              Text(
                '${state.todayPaidCount} paid',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('•', style: TextStyle(color: AppColors.secondaryText)),
              ),
              Text(
                '${state.todayDueCount} due',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        AppCard(
          onTap: () {
            context.push(RouteNames.invoices);
          },
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Outstanding',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(state.totalOutstandingAmount),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
              Row(
                children: const [
                  Text(
                    'View Unpaid',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: AppColors.primaryBlue, size: 20),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // WEEKLY DUAL BAR CHART (SALES VS EXPENSES)
  Widget _buildWeeklyChartSection(SalesOverviewLoadedState state) {
    double maxVal = 0.0;
    for (var day in state.weeklyDailyBreakdown) {
      if (day.sales > maxVal) maxVal = day.sales;
      if (day.expenses > maxVal) maxVal = day.expenses;
    }
    if (maxVal == 0.0) maxVal = 1.0;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('Sales', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('Expenses', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 140,
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: state.weeklyDailyBreakdown.map((dayData) {
                    final salesPct = (dayData.sales / maxVal).clamp(0.05, 1.0);
                    final expPct = (dayData.expenses / maxVal).clamp(0.05, 1.0);

                    final salesBarHeight = dayData.sales > 0 ? (100 * salesPct) : 4.0;
                    final expBarHeight = dayData.expenses > 0 ? (100 * expPct) : 4.0;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Tooltip(
                              message: 'Sales: ${_formatCurrency(dayData.sales)}',
                              child: Container(
                                width: 10,
                                height: salesBarHeight,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Tooltip(
                              message: 'Expenses: ${_formatCurrency(dayData.expenses)}',
                              child: Container(
                                width: 10,
                                height: expBarHeight,
                                decoration: BoxDecoration(
                                  color: AppColors.warning,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dayData.dayName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // WEEKLY SUMMARY CARD
  Widget _buildWeeklySummarySection(SalesOverviewLoadedState state) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This week',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlueText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sales', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
              Text(
                _formatCurrency(state.weeklySales),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Expenses', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
              Text(
                _formatCurrency(state.weeklyExpenses),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.warning),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Net', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              Text(
                _formatCurrency(state.weeklyNet),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: state.weeklyNet >= 0 ? AppColors.success : AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // SEARCH FIELD & ADVANCED FILTER TRIGGER
  Widget _buildSearchFieldAndFilterButton(BuildContext context, SalesOverviewLoadedState state) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                context.read<SalesOverviewBloc>().add(SearchSalesOverviewEvent(val));
              },
              decoration: InputDecoration(
                hintText: 'Search invoice or customer',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          context
                              .read<SalesOverviewBloc>()
                              .add(const SearchSalesOverviewEvent(''));
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _openAdvancedFilterBottomSheet(context, state),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: state.statusFilter != 'All' ||
                      state.paymentMethodFilter != 'All' ||
                      state.dateRangeFilter != 'All'
                  ? AppColors.primaryBlue
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: state.statusFilter != 'All' ||
                      state.paymentMethodFilter != 'All' ||
                      state.dateRangeFilter != 'All'
                  ? Colors.white
                  : AppColors.darkBlueText,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  // HORIZONTALLY SCROLLABLE FILTER CHIPS
  Widget _buildFilterChipsRow(BuildContext context, SalesOverviewLoadedState state) {
    final chips = ['All', 'Expenses', 'Paid', 'Unpaid', 'Partial', 'Cash Sale'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((chipLabel) {
          final isSelected = state.selectedPrimaryFilter == chipLabel;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(chipLabel),
              selected: isSelected,
              selectedColor: AppColors.primaryBlue,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? AppColors.primaryBlue : AppColors.border,
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkBlueText,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
              ),
              onSelected: (val) {
                if (val) {
                  context
                      .read<SalesOverviewBloc>()
                      .add(FilterSalesOverviewEvent(chipLabel));
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // RECENT INVOICES & EXPENSES TRANSACTIONS SECTION
  Widget _buildRecentTransactionsSection(BuildContext context, SalesOverviewLoadedState state) {
    final showExpensesOnly = state.selectedPrimaryFilter == 'Expenses';

    final invoicesToDisplay = state.isFiltered ? state.filteredInvoices : state.recentInvoices;
    final expensesToDisplay = state.isFiltered ? state.filteredExpenses : state.recentExpenses;

    final hasNoInvoices = state.allInvoices.isEmpty;
    final hasNoExpenses = state.allExpenses.isEmpty;
    final hasNoTransactions = hasNoInvoices && hasNoExpenses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              showExpensesOnly ? 'Recent Expenses' : 'Recent Transactions',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText,
              ),
            ),
            TextButton(
              onPressed: () {
                if (showExpensesOnly) {
                  context.push(RouteNames.dailyLedger, extra: {'initialTab': 1});
                } else {
                  context.push(RouteNames.invoices);
                }
              },
              child: const Text(
                'See all',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Show Expenses Only Tab
        if (showExpensesOnly) ...[
          if (expensesToDisplay.isEmpty)
            const EmptyState(
              title: 'No expenses recorded',
              message: 'Your recorded expenses will appear here.',
              icon: Icons.money_off_outlined,
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expensesToDisplay.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final exp = expensesToDisplay[idx];
                return _ExpenseItemCard(
                  expense: exp,
                  formattedDate: _formatDate(exp.expenseDate),
                  formattedAmount: _formatCurrency(exp.amount),
                );
              },
            ),
        ]
        // Show Invoices & Expenses Combo
        else ...[
          if (hasNoTransactions)
            const EmptyState(
              title: 'No transactions yet',
              message: 'Your invoices and expenses will appear here as activity occurs.',
              icon: Icons.receipt_long_outlined,
            )
          else if (invoicesToDisplay.isEmpty && expensesToDisplay.isEmpty)
            const EmptyState(
              title: 'No matching transactions',
              message: 'Try changing your search or filters.',
              icon: Icons.search_off_rounded,
            )
          else ...[
            // Invoices List
            if (invoicesToDisplay.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: invoicesToDisplay.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, idx) {
                  final inv = invoicesToDisplay[idx];
                  return _InvoiceItemCard(
                    invoice: inv,
                    formattedDate: _formatDate(inv.issueDate),
                    formattedAmount: _formatCurrency(inv.grandTotal),
                    onTap: () async {
                      final bloc = context.read<InvoiceBloc>();
                      await context.push(
                        RouteNames.createInvoice,
                        extra: {
                          'invoiceType': inv.type,
                          'invoiceToEdit': inv,
                        },
                      );
                      if (!mounted) return;
                      bloc.add(const FetchInvoicesEvent());
                    },
                  );
                },
              ),

            // Expenses List section below invoices if expenses exist
            if (expensesToDisplay.isNotEmpty) ...[
              if (invoicesToDisplay.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Recent Expenses',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expensesToDisplay.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, idx) {
                  final exp = expensesToDisplay[idx];
                  return _ExpenseItemCard(
                    expense: exp,
                    formattedDate: _formatDate(exp.expenseDate),
                    formattedAmount: _formatCurrency(exp.amount),
                  );
                },
              ),
            ],
          ],
        ],
      ],
    );
  }
}

// METRIC CARD WIDGET
class _MetricCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color amountColor;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.title,
    required this.amount,
    required this.amountColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: amountColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// INVOICE ITEM CARD WIDGET
class _InvoiceItemCard extends StatelessWidget {
  final InvoiceEntity invoice;
  final String formattedDate;
  final String formattedAmount;
  final VoidCallback onTap;

  const _InvoiceItemCard({
    required this.invoice,
    required this.formattedDate,
    required this.formattedAmount,
    required this.onTap,
  });

  Widget _buildStatusChip() {
    if (invoice.status == InvoiceStatus.paid) {
      return StatusChip.paid();
    } else if (invoice.status == InvoiceStatus.partiallyPaid) {
      return StatusChip.partiallyPaid();
    } else {
      return StatusChip.unpaid();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.darkBlueText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      invoice.customerName,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedAmount,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.darkBlueText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusChip(),
                ],
              ),
            ],
          ),
          if (invoice.status == InvoiceStatus.partiallyPaid) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warningContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${invoice.paidAmount.toInt()} paid',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success),
                  ),
                  Text(
                    '₹${invoice.dueAmount.toInt()} due',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.danger),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// EXPENSE ITEM CARD WIDGET
class _ExpenseItemCard extends StatelessWidget {
  final ExpenseEntity expense;
  final String formattedDate;
  final String formattedAmount;

  const _ExpenseItemCard({
    required this.expense,
    required this.formattedDate,
    required this.formattedAmount,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title.isNotEmpty ? expense.title : expense.category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.darkBlueText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Category: ${expense.category}',
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '- $formattedAmount',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warningContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      expense.paymentMode,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
