import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../application/bloc/invoice_bloc.dart';
import '../../../application/bloc/sales_overview_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/payment_entity.dart';
import '../../../domain/entities/sales_transaction_wrapper.dart';
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

  String _formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    return formatter.format(amount);
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('d MMM yyyy · h:mm a').format(dt);
  }

  String _formatShortTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dtDate = DateTime(dt.year, dt.month, dt.day);
    final timeStr = DateFormat('h:mm a').format(dt);

    if (dtDate == today) {
      return timeStr;
    } else if (dtDate == yesterday) {
      return 'Yesterday, $timeStr';
    } else if (dt.year == now.year) {
      return '${DateFormat('d MMM').format(dt)}, $timeStr';
    } else {
      return '${DateFormat('d MMM yyyy').format(dt)}, $timeStr';
    }
  }

  void _openFilterAndSortBottomSheet(
      BuildContext context, SalesOverviewLoadedState state) {
    String selectedType = state.selectedTypeFilter;
    String selectedPaymentStatus = state.statusFilter;
    String selectedInvoiceStatus = state.invoiceStatusFilter;
    String selectedDateRange = state.dateRangeFilter;
    DateTime? customStart = state.customStartDate;
    DateTime? customEnd = state.customEndDate;
    String selectedSort = state.sortOption;
    final TextEditingController customerTextCtrl = TextEditingController(
        text: state.selectedCustomer == 'All' ? '' : state.selectedCustomer);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom:
                    MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter & Sort Sales',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlueText,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(bottomSheetContext),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Transaction Type
                    const Text(
                      'Transaction Type',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlueText),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['All', 'Invoices', 'Returns', 'Payments']
                          .map((type) {
                        final isSelected = selectedType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.darkBlueText,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => selectedType = type);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Sort By
                    const Text(
                      'Sort By',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlueText),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        {'label': 'Newest first', 'val': 'newest'},
                        {'label': 'Oldest first', 'val': 'oldest'},
                        {'label': 'Highest amount', 'val': 'amount_high'},
                        {'label': 'Lowest amount', 'val': 'amount_low'},
                        {'label': 'Customer A–Z', 'val': 'name_asc'},
                        {'label': 'Customer Z–A', 'val': 'name_desc'},
                      ].map((item) {
                        final isSelected = selectedSort == item['val'];
                        return ChoiceChip(
                          label: Text(item['label']!),
                          selected: isSelected,
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.darkBlueText,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => selectedSort = item['val']!);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Date Range
                    const Text(
                      'Date Range',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlueText),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'All',
                        'Today',
                        'Yesterday',
                        'This week',
                        'This month',
                        'Custom'
                      ].map((range) {
                        final isSelected = selectedDateRange == range;
                        return ChoiceChip(
                          label: Text(range),
                          selected: isSelected,
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.darkBlueText,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          onSelected: (val) async {
                            if (val) {
                              if (range == 'Custom') {
                                final picked = await showDateRangePicker(
                                  context: bottomSheetContext,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365)),
                                  initialDateRange:
                                      customStart != null && customEnd != null
                                          ? DateTimeRange(
                                              start: customStart!,
                                              end: customEnd!)
                                          : null,
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    selectedDateRange = 'Custom';
                                    customStart = picked.start;
                                    customEnd = picked.end;
                                  });
                                }
                              } else {
                                setModalState(() {
                                  selectedDateRange = range;
                                  customStart = null;
                                  customEnd = null;
                                });
                              }
                            }
                          },
                        );
                      }).toList(),
                    ),
                    if (selectedDateRange == 'Custom' &&
                        customStart != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Selected: ${DateFormat('dd MMM yyyy').format(customStart!)} - ${DateFormat('dd MMM yyyy').format(customEnd ?? customStart!)}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Payment Status Filter
                    const Text(
                      'Payment Status',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlueText),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'All',
                        'Paid',
                        'Partially Paid',
                        'Unpaid',
                        'Overdue'
                      ].map((status) {
                        final isSelected = selectedPaymentStatus == status;
                        return ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.darkBlueText,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setModalState(
                                  () => selectedPaymentStatus = status);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Invoice Status Filter
                    const Text(
                      'Invoice Status',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlueText),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'All',
                        'Draft',
                        'Issued',
                        'Cancelled',
                        'Returned'
                      ].map((invStatus) {
                        final isSelected = selectedInvoiceStatus == invStatus;
                        return ChoiceChip(
                          label: Text(invStatus),
                          selected: isSelected,
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.darkBlueText,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setModalState(
                                  () => selectedInvoiceStatus = invStatus);
                            }
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              context
                                  .read<SalesOverviewBloc>()
                                  .add(ClearSalesOverviewFiltersEvent());
                              _searchController.clear();
                              Navigator.pop(bottomSheetContext);
                            },
                            child: const Text('Reset All',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              final custInput = customerTextCtrl.text.trim();
                              context.read<SalesOverviewBloc>().add(
                                    ApplyAdvancedFilterEvent(
                                      transactionType: selectedType,
                                      status: selectedPaymentStatus,
                                      invoiceStatus: selectedInvoiceStatus,
                                      dateRange: selectedDateRange,
                                      customStartDate: customStart,
                                      customEndDate: customEnd,
                                      customer:
                                          custInput.isEmpty ? 'All' : custInput,
                                      sortOption: selectedSort,
                                    ),
                                  );
                              Navigator.pop(bottomSheetContext);
                            },
                            child: const Text('Apply Filters',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Sales',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
      body: BlocBuilder<SalesOverviewBloc, SalesOverviewState>(
        builder: (context, state) {
          if (state is SalesOverviewLoadingState ||
              state is SalesOverviewInitialState) {
            return const InvoiceListSkeleton();
          }

          if (state is SalesOverviewErrorState) {
            return ErrorState(
              message: state.message,
              onRetry: () => context
                  .read<SalesOverviewBloc>()
                  .add(FetchSalesOverviewDataEvent()),
            );
          }

          if (state is SalesOverviewLoadedState) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<SalesOverviewBloc>()
                    .add(FetchSalesOverviewDataEvent());
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar & Filter Button
                    _buildSearchAndFilterRow(context, state),
                    const SizedBox(height: 12),

                    // Quick Transaction Type Filter Chips (All, Invoices, Returns, Payments)
                    _buildQuickTypeChipsRow(context, state),
                    const SizedBox(height: 10),

                    // Active Removable Filter Chips
                    if (state.isFiltered) ...[
                      _buildActiveFilterChipsRow(context, state),
                      const SizedBox(height: 10),
                    ],

                    // Transactions Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlueText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Vertical Timeline Financial Activity Feed
                    Expanded(
                      child: state.filteredTransactions.isEmpty
                          ? _buildEmptyState(state)
                          : _buildVerticalTimelineFeed(
                              context, state.filteredTransactions),
                    ),
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

  // SEARCH FIELD & FILTER BUTTON
  Widget _buildSearchAndFilterRow(
      BuildContext context, SalesOverviewLoadedState state) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                context
                    .read<SalesOverviewBloc>()
                    .add(SearchSalesOverviewEvent(val));
              },
              decoration: InputDecoration(
                hintText: 'Search invoice, customer or transaction...',
                hintStyle: const TextStyle(
                    fontSize: 13, color: AppColors.secondaryText),
                prefixIcon: const Icon(Icons.search,
                    size: 20, color: AppColors.secondaryText),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () => _openFilterAndSortBottomSheet(context, state),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: state.isFiltered ? AppColors.primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    state.isFiltered ? AppColors.primaryBlue : AppColors.border,
              ),
            ),
            child: Icon(
              Icons.filter_list_rounded,
              color: state.isFiltered ? Colors.white : AppColors.darkBlueText,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // QUICK TYPE CHIPS ROW (All, Invoices, Returns, Payments)
  Widget _buildQuickTypeChipsRow(
      BuildContext context, SalesOverviewLoadedState state) {
    final chips = ['All', 'Invoices', 'Returns', 'Payments'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((chipLabel) {
          final isSelected = state.selectedTypeFilter == chipLabel;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(chipLabel),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  context
                      .read<SalesOverviewBloc>()
                      .add(FilterSalesOverviewEvent(chipLabel));
                }
              },
              selectedColor: AppColors.primaryBlue,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? AppColors.primaryBlue : AppColors.border,
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkBlueText,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 12,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ACTIVE FILTERS REMOVABLE CHIPS
  Widget _buildActiveFilterChipsRow(
      BuildContext context, SalesOverviewLoadedState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (state.searchQuery.isNotEmpty)
            _buildRemovableChip('Search: "${state.searchQuery}"', () {
              _searchController.clear();
              context
                  .read<SalesOverviewBloc>()
                  .add(const SearchSalesOverviewEvent(''));
            }),
          if (state.selectedTypeFilter != 'All')
            _buildRemovableChip('Type: ${state.selectedTypeFilter}', () {
              context
                  .read<SalesOverviewBloc>()
                  .add(const FilterSalesOverviewEvent('All'));
            }),
          if (state.statusFilter != 'All')
            _buildRemovableChip('Status: ${state.statusFilter}', () {
              context.read<SalesOverviewBloc>().add(
                    ApplyAdvancedFilterEvent(
                      transactionType: state.selectedTypeFilter,
                      status: 'All',
                      invoiceStatus: state.invoiceStatusFilter,
                      dateRange: state.dateRangeFilter,
                      customStartDate: state.customStartDate,
                      customEndDate: state.customEndDate,
                      customer: state.selectedCustomer,
                      sortOption: state.sortOption,
                    ),
                  );
            }),
          if (state.dateRangeFilter != 'All')
            _buildRemovableChip('Date: ${state.dateRangeFilter}', () {
              context.read<SalesOverviewBloc>().add(
                    ApplyAdvancedFilterEvent(
                      transactionType: state.selectedTypeFilter,
                      status: state.statusFilter,
                      invoiceStatus: state.invoiceStatusFilter,
                      dateRange: 'All',
                      customStartDate: null,
                      customEndDate: null,
                      customer: state.selectedCustomer,
                      sortOption: state.sortOption,
                    ),
                  );
            }),
          if (state.selectedCustomer != 'All')
            _buildRemovableChip('Customer: ${state.selectedCustomer}', () {
              context.read<SalesOverviewBloc>().add(
                    ApplyAdvancedFilterEvent(
                      transactionType: state.selectedTypeFilter,
                      status: state.statusFilter,
                      invoiceStatus: state.invoiceStatusFilter,
                      dateRange: state.dateRangeFilter,
                      customStartDate: state.customStartDate,
                      customEndDate: state.customEndDate,
                      customer: 'All',
                      sortOption: state.sortOption,
                    ),
                  );
            }),
          InkWell(
            onTap: () {
              _searchController.clear();
              context
                  .read<SalesOverviewBloc>()
                  .add(ClearSalesOverviewFiltersEvent());
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                'Reset All',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemovableChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: Chip(
        label: Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onRemove,
        side: BorderSide.none,
        padding: const EdgeInsets.all(4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // VERTICAL TIMELINE FEED
  Widget _buildVerticalTimelineFeed(
      BuildContext context, List<SalesTransactionWrapper> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<SalesTransactionWrapper>> grouped = {};

    for (var tx in transactions) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      String label;
      if (txDate == today) {
        label = 'TODAY';
      } else if (txDate == yesterday) {
        label = 'YESTERDAY';
      } else if (tx.date.year == now.year) {
        label = DateFormat('d MMM yyyy').format(tx.date).toUpperCase();
      } else {
        label = DateFormat('d MMM yyyy').format(tx.date).toUpperCase();
      }

      grouped.putIfAbsent(label, () => []).add(tx);
    }

    final sections = grouped.entries.toList();

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sections.length,
      itemBuilder: (ctx, sectionIdx) {
        final group = sections[sectionIdx];
        final dateLabel = group.key;
        final groupItems = group.value;
        return _buildTimelineGroup(context, dateLabel, groupItems);
      },
    );
  }

  // DAY GROUPED TRANSACTIONS CONTAINER
  Widget _buildTimelineGroup(BuildContext context, String dateLabel,
      List<SalesTransactionWrapper> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0, top: 8.0, left: 4.0),
          child: Text(
            dateLabel,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.secondaryText,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate(items.length, (idx) {
              final tx = items[idx];
              final isLast = idx == items.length - 1;
              return _buildTimelineTransactionTile(context, tx, isLast);
            }),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // DENSE WIDE TRANSACTION TILE WITH MORE BUTTON (⋮)
  Widget _buildTimelineTransactionTile(
      BuildContext context, SalesTransactionWrapper tx, bool isLast) {
    IconData icon;
    Color iconBgColor;
    Color iconColor;
    Color amountColor;

    if (tx.isReturn) {
      icon = Icons.u_turn_left_rounded;
      iconBgColor = Colors.purple.withValues(alpha: 0.1);
      iconColor = Colors.purple.shade700;
      amountColor = AppColors.danger;
    } else if (tx.isPayment) {
      icon = Icons.arrow_downward_rounded;
      iconBgColor = AppColors.success.withValues(alpha: 0.1);
      iconColor = AppColors.success;
      amountColor = AppColors.success;
    } else {
      icon = Icons.receipt_long_rounded;
      iconBgColor = AppColors.primaryBlue.withValues(alpha: 0.1);
      iconColor = AppColors.primaryBlue;
      amountColor = AppColors.darkBlueText;
    }

    // Dot Status indicator
    Color statusDotColor;
    String statusText;
    if (tx.isReturn) {
      statusDotColor = Colors.purple.shade700;
      statusText = 'Completed';
    } else if (tx.isPayment) {
      statusDotColor = AppColors.success;
      statusText = 'Received';
    } else {
      final inv = tx.asInvoice;
      final now = DateTime.now();
      final isOverdue = inv != null &&
          (inv.status == InvoiceStatus.unpaid ||
              inv.status == InvoiceStatus.partiallyPaid) &&
          inv.dueDate.isBefore(now);

      if (inv?.status == InvoiceStatus.cancelled) {
        statusDotColor = AppColors.danger;
        statusText = 'Cancelled';
      } else if (inv?.status == InvoiceStatus.paid) {
        statusDotColor = AppColors.success;
        statusText = 'Paid';
      } else if (isOverdue) {
        statusDotColor = AppColors.danger;
        statusText = 'Overdue';
      } else if (inv?.status == InvoiceStatus.partiallyPaid) {
        statusDotColor = AppColors.warning;
        statusText = 'Partially Paid';
      } else {
        statusDotColor = AppColors.warning;
        statusText = 'Unpaid';
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
          child: Row(
            children: [
              // Icon Box
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),

              // Left Section: Type • ID, Customer & Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tx.typeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: iconColor,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${tx.transactionNumber}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlueText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${tx.customerName} · ${_formatShortTime(tx.date)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Right Section: Amount, Status Dot, More Button (⋮)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        tx.isReturn
                            ? '-${_formatCurrency(tx.totalAmount)}'
                            : _formatCurrency(tx.totalAmount),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: amountColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusDotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusDotColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: Colors.white,
                    elevation: 4,
                    onSelected: (value) {
                      if (value == 'view') {
                        _handleViewTransaction(context, tx);
                      } else if (value == 'edit') {
                        _handleEditTransaction(context, tx);
                      } else if (value == 'delete') {
                        _handleDeleteTransaction(context, tx);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem<String>(
                        value: 'view',
                        height: 38,
                        child: Row(
                          children: [
                            Icon(Icons.visibility_outlined,
                                size: 18, color: AppColors.primaryBlue),
                            SizedBox(width: 10),
                            Text('View',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkBlueText)),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'edit',
                        height: 38,
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 18, color: AppColors.primaryBlue),
                            SizedBox(width: 10),
                            Text('Edit',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkBlueText)),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        height: 38,
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 18, color: AppColors.danger),
                            SizedBox(width: 10),
                            Text('Delete',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.danger)),
                          ],
                        ),
                      ),
                    ],
                    child: const Padding(
                      padding: EdgeInsets.only(
                          left: 2.0, right: 0.0, top: 4.0, bottom: 4.0),
                      child: Icon(Icons.more_vert,
                          size: 20, color: AppColors.secondaryText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 60,
            endIndent: 14,
            color: AppColors.border,
          ),
      ],
    );
  }

  void _handleViewTransaction(
      BuildContext context, SalesTransactionWrapper tx) {
    if (tx.isInvoice && tx.asInvoice != null) {
      context.push(RouteNames.invoiceDetails, extra: tx.asInvoice);
    } else if (tx.isReturn) {
      context.push(RouteNames.salesReturns);
    } else if (tx.isPayment) {
      _showPaymentDetailsModal(context, tx.asPayment ?? tx);
    }
  }

  void _handleEditTransaction(
      BuildContext context, SalesTransactionWrapper tx) {
    if (tx.isInvoice && tx.asInvoice != null) {
      context.push(RouteNames.createInvoice, extra: tx.asInvoice);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Editing ${tx.typeLabel} is not supported directly.')),
      );
    }
  }

  void _handleDeleteTransaction(
      BuildContext context, SalesTransactionWrapper tx) {
    if (tx.isInvoice && tx.asInvoice != null) {
      _showCancelInvoiceDialog(context, tx.asInvoice!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${tx.typeLabel} ${tx.transactionNumber} deleted.')),
      );
    }
  }

  void _showCancelInvoiceDialog(BuildContext context, InvoiceEntity inv) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Cancel Invoice',
              style: TextStyle(fontWeight: FontWeight.w800)),
          content: Text(
              'Are you sure you want to cancel ${inv.invoiceNumber}? This action cannot be undone.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('No, Keep')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white),
              onPressed: () {
                final cancelledInvoice =
                    inv.copyWith(status: InvoiceStatus.cancelled);
                context
                    .read<InvoiceBloc>()
                    .add(UpdateInvoiceSubmittedEvent(cancelledInvoice));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Invoice ${inv.invoiceNumber} cancelled.')),
                );
              },
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  // PAYMENT DETAILS MODAL
  void _showPaymentDetailsModal(BuildContext context, Object paymentObj) {
    PaymentEntity? pay;
    if (paymentObj is PaymentEntity) {
      pay = paymentObj;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.payment, color: AppColors.primaryBlue),
              SizedBox(width: 10),
              Text('Payment Receipt',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${pay?.customerName ?? "General Customer"}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 6),
              Text('Amount Received: ${_formatCurrency(pay?.amount ?? 0.0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.success)),
              const SizedBox(height: 6),
              Text('Payment Mode: ${pay?.paymentMode ?? "CASH"}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.secondaryText)),
              if (pay?.referenceNumber.isNotEmpty ?? false) ...[
                const SizedBox(height: 4),
                Text('Ref #: ${pay!.referenceNumber}',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.secondaryText)),
              ],
              const SizedBox(height: 6),
              Text(
                  'Date: ${pay != null ? _formatDateTime(pay.paymentDate) : ""}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.secondaryText)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // CONTEXTUAL EMPTY STATE
  Widget _buildEmptyState(SalesOverviewLoadedState state) {
    String title = 'No sales transactions';
    String message =
        'Your invoices, sales returns, and payments will appear here.';
    IconData icon = Icons.receipt_long_outlined;

    if (state.searchQuery.isNotEmpty) {
      title = 'No matching transactions';
      message = 'No records found matching "${state.searchQuery}".';
      icon = Icons.search_off_rounded;
    } else if (state.selectedTypeFilter == 'Invoices') {
      title = 'No sales invoices';
      message = 'No sales invoices found matching selected filters.';
    } else if (state.selectedTypeFilter == 'Returns') {
      title = 'No sales returns';
      message = 'There are no sales return vouchers recorded.';
      icon = Icons.assignment_return_outlined;
    } else if (state.selectedTypeFilter == 'Payments') {
      title = 'No payments recorded';
      message = 'No payment receipts recorded yet.';
      icon = Icons.payments_outlined;
    } else if (state.isFiltered) {
      title = 'No transactions found';
      message = 'Try adjusting your search or filter settings.';
      icon = Icons.filter_alt_off_outlined;
    }

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              if (state.isFiltered) ...[
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    context
                        .read<SalesOverviewBloc>()
                        .add(ClearSalesOverviewFiltersEvent());
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reset Filters'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
