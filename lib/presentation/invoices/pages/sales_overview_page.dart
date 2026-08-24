import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/sales_overview_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
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
  void initState() {
    super.initState();
    // Load fresh data when page initializes
    context.read<SalesOverviewBloc>().add(FetchSalesOverviewDataEvent());
  }

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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (checkDate == yesterday) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('d MMM yyyy').format(date);
    }
  }

  void _openFilterAndSortBottomSheet(
      BuildContext context, SalesOverviewLoadedState state) {
    String selectedPaymentStatus = state.statusFilter;
    String selectedInvoiceStatus = state.invoiceStatusFilter;
    String selectedDateRange = state.dateRangeFilter;
    DateTime? customStart = state.customStartDate;
    DateTime? customEnd = state.customEndDate;
    String selectedCustomer = state.selectedCustomer;
    String selectedSort = state.sortOption;

    final customerTextCtrl = TextEditingController(
      text: selectedCustomer == 'All' ? '' : selectedCustomer,
    );

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
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(bottomSheetContext),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),

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
                            if (val)
                              setModalState(() => selectedSort = item['val']!);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

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
                    const SizedBox(height: 20),

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
                            if (val)
                              setModalState(
                                  () => selectedPaymentStatus = status);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

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
                            if (val)
                              setModalState(
                                  () => selectedInvoiceStatus = invStatus);
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
        title: const Text(
          'Sales',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
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
                    // Section 1: Compact Search Field & Filter Button
                    _buildSearchAndFilterRow(context, state),
                    const SizedBox(height: 12),

                    // Section 2: Horizontally Scrollable Quick Status Chips
                    _buildQuickStatusChipsRow(context, state),
                    const SizedBox(height: 10),

                    // Section 3: Active Filters Removable Chips (if any filter is applied)
                    if (state.isFiltered) ...[
                      _buildActiveFilterChipsRow(context, state),
                      const SizedBox(height: 10),
                    ],

                    // Section 4: Transactions List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlueText,
                          ),
                        ),
                        Text(
                          '${state.filteredInvoices.length} Invoices',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Section 5: Transactions History List (Main Focus)
                    Expanded(
                      child: state.filteredInvoices.isEmpty
                          ? _buildEmptyState(state)
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: state.filteredInvoices.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (ctx, index) {
                                final inv = state.filteredInvoices[index];
                                return _buildTransactionCard(context, inv);
                              },
                            ),
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
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
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
                hintText: 'Search invoice or customer...',
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
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Filter Button
        InkWell(
          onTap: () => _openFilterAndSortBottomSheet(context, state),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: state.isFiltered ? AppColors.primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    state.isFiltered ? AppColors.primaryBlue : AppColors.border,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.tune_rounded,
                  color:
                      state.isFiltered ? Colors.white : AppColors.darkBlueText,
                  size: 22,
                ),
                if (state.isFiltered)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // HORIZONTALLY SCROLLABLE QUICK STATUS FILTER CHIPS
  Widget _buildQuickStatusChipsRow(
      BuildContext context, SalesOverviewLoadedState state) {
    final chips = [
      'All',
      'Paid',
      'Partially Paid',
      'Unpaid',
      'Overdue',
      'Cancelled'
    ];

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
                fontSize: 13,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
          if (state.statusFilter != 'All')
            _buildRemovableChip('Status: ${state.statusFilter}', () {
              context.read<SalesOverviewBloc>().add(
                    ApplyAdvancedFilterEvent(
                      status: 'All',
                      invoiceStatus: state.invoiceStatusFilter,
                      dateRange: state.dateRangeFilter,
                      customer: state.selectedCustomer,
                      sortOption: state.sortOption,
                    ),
                  );
            }),
          if (state.invoiceStatusFilter != 'All')
            _buildRemovableChip('Invoice: ${state.invoiceStatusFilter}', () {
              context.read<SalesOverviewBloc>().add(
                    ApplyAdvancedFilterEvent(
                      status: state.statusFilter,
                      invoiceStatus: 'All',
                      dateRange: state.dateRangeFilter,
                      customer: state.selectedCustomer,
                      sortOption: state.sortOption,
                    ),
                  );
            }),
          if (state.dateRangeFilter != 'All')
            _buildRemovableChip('Date: ${state.dateRangeFilter}', () {
              context.read<SalesOverviewBloc>().add(
                    ApplyAdvancedFilterEvent(
                      status: state.statusFilter,
                      invoiceStatus: state.invoiceStatusFilter,
                      dateRange: 'All',
                      customer: state.selectedCustomer,
                      sortOption: state.sortOption,
                    ),
                  );
            }),
          if (state.selectedCustomer != 'All')
            _buildRemovableChip('Customer: ${state.selectedCustomer}', () {
              context.read<SalesOverviewBloc>().add(
                    ApplyAdvancedFilterEvent(
                      status: state.statusFilter,
                      invoiceStatus: state.invoiceStatusFilter,
                      dateRange: state.dateRangeFilter,
                      customer: 'All',
                      sortOption: state.sortOption,
                    ),
                  );
            }),
          if (state.sortOption != 'newest')
            _buildRemovableChip('Sort: ${state.sortOption}', () {
              context.read<SalesOverviewBloc>().add(
                    ApplyAdvancedFilterEvent(
                      status: state.statusFilter,
                      invoiceStatus: state.invoiceStatusFilter,
                      dateRange: state.dateRangeFilter,
                      customer: state.selectedCustomer,
                      sortOption: 'newest',
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
                'Clear all',
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
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // TRANSACTION CARD ITEM
  Widget _buildTransactionCard(BuildContext context, InvoiceEntity inv) {
    final now = DateTime.now();
    final isOverdue = (inv.status == InvoiceStatus.unpaid ||
            inv.status == InvoiceStatus.partiallyPaid) &&
        inv.dueDate.isBefore(now);

    final isReturned = inv.notes.toLowerCase().contains('return') ||
        inv.invoiceNumber.toLowerCase().contains('ret');

    Widget statusWidget;
    if (inv.status == InvoiceStatus.cancelled) {
      statusWidget = StatusChip.cancelled();
    } else if (isReturned) {
      statusWidget = StatusChip.returned();
    } else if (inv.status == InvoiceStatus.paid) {
      statusWidget = StatusChip.paid();
    } else if (isOverdue) {
      statusWidget = StatusChip.overdue();
    } else if (inv.status == InvoiceStatus.partiallyPaid) {
      statusWidget = StatusChip.partiallyPaid();
    } else {
      statusWidget = StatusChip.unpaid();
    }

    return AppCard(
      onTap: () {
        context.push(
          RouteNames.invoiceDetails,
          extra: inv,
        );
      },
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                inv.invoiceNumber,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
              Text(
                _formatCurrency(inv.grandTotal),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  inv.customerName.isNotEmpty
                      ? inv.customerName
                      : 'General Customer',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlueText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (inv.dueAmount > 0 &&
                  inv.status != InvoiceStatus.paid &&
                  inv.status != InvoiceStatus.cancelled)
                Text(
                  '${_formatCurrency(inv.dueAmount)} Due',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(inv.issueDate),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              statusWidget,
            ],
          ),
        ],
      ),
    );
  }

  // CONTEXTUAL EMPTY STATE
  Widget _buildEmptyState(SalesOverviewLoadedState state) {
    String title = 'No sales yet';
    String message = 'Your invoices and sales transactions will appear here.';
    IconData icon = Icons.receipt_long_outlined;

    if (state.searchQuery.isNotEmpty) {
      title = 'No matching transactions';
      message = 'No invoices found matching "${state.searchQuery}".';
      icon = Icons.search_off_rounded;
    } else if (state.selectedPrimaryFilter == 'Unpaid' ||
        state.statusFilter == 'Unpaid') {
      title = 'No unpaid invoices';
      message = 'All your sales transactions are fully paid!';
      icon = Icons.check_circle_outline_rounded;
    } else if (state.selectedPrimaryFilter == 'Overdue' ||
        state.statusFilter == 'Overdue') {
      title = 'No overdue invoices';
      message = 'No pending invoices are overdue.';
      icon = Icons.verified_outlined;
    } else if (state.selectedPrimaryFilter == 'Cancelled' ||
        state.invoiceStatusFilter == 'Cancelled') {
      title = 'No cancelled invoices';
      message = 'There are no cancelled sales transactions in your records.';
      icon = Icons.cancel_outlined;
    } else if (state.isFiltered) {
      title = 'No transactions found';
      message = 'Try adjusting your search or filter settings.';
      icon = Icons.filter_alt_off_outlined;
    }

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
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
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
