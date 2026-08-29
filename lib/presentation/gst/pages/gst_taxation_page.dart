import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/invoice_bloc.dart';
import '../../../application/providers/app_providers.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';
import '../../reports/widgets/report_export_sheet.dart';

// ============================================================================
// DEDICATED GST TAXATION & OUTWARD SUPPLIES REPORT PAGE
// ============================================================================

class GstTaxationPage extends ConsumerStatefulWidget {
  final Object? initialPreset;
  const GstTaxationPage({super.key, this.initialPreset});

  @override
  ConsumerState<GstTaxationPage> createState() => _GstTaxationPageState();
}

class _GstTaxationPageState extends ConsumerState<GstTaxationPage> {
  DateTimeRange? _customDateRange;
  int _activePresetIndex = 0; // 0: GST Summary, 1: Outward Supplies
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _parseInitialPreset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _parseInitialPreset() {
    if (widget.initialPreset is int) {
      _activePresetIndex = widget.initialPreset as int;
    } else if (widget.initialPreset is Map &&
        (widget.initialPreset as Map).containsKey('preset')) {
      _activePresetIndex = (widget.initialPreset as Map)['preset'] as int;
    } else if (widget.initialPreset is String) {
      final p = (widget.initialPreset as String).toLowerCase();
      if (p.contains('outward') || p.contains('supplies')) {
        _activePresetIndex = 1;
      } else {
        _activePresetIndex = 0;
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _activePresetIndex = 0;
      _searchCtrl.clear();
      _customDateRange = null;
    });
    ref.read(analyticsDateFilterProvider.notifier).state = 'This Month';
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.darkBlueText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
      });
      ref.read(analyticsDateFilterProvider.notifier).state = 'Custom Range';
    }
  }

  DateTimeRange _getFilterDateRange(String filter) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (filter) {
      case 'Today':
        return DateTimeRange(start: todayStart, end: todayEnd);
      case 'This Week':
        final monday =
            todayStart.subtract(Duration(days: todayStart.weekday - 1));
        return DateTimeRange(start: monday, end: todayEnd);
      case 'This Month':
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return DateTimeRange(start: monthStart, end: monthEnd);
      case 'This Quarter':
        final currentQuarter = ((now.month - 1) ~/ 3) + 1;
        final quarterStartMonth = (currentQuarter - 1) * 3 + 1;
        final quarterStart = DateTime(now.year, quarterStartMonth, 1);
        final quarterEndMonth = quarterStartMonth + 2;
        final quarterEnd =
            DateTime(now.year, quarterEndMonth + 1, 0, 23, 59, 59);
        return DateTimeRange(start: quarterStart, end: quarterEnd);
      case 'Last Month':
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);
        final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
        return DateTimeRange(start: lastMonthStart, end: lastMonthEnd);
      case 'This Year':
        final yearStart = DateTime(now.year, 1, 1);
        final yearEnd = DateTime(now.year, 12, 31, 23, 59, 59);
        return DateTimeRange(start: yearStart, end: yearEnd);
      case 'Custom Range':
        if (_customDateRange != null) {
          final s = _customDateRange!.start;
          final e = _customDateRange!.end;
          return DateTimeRange(
            start: DateTime(s.year, s.month, s.day),
            end: DateTime(e.year, e.month, e.day, 23, 59, 59),
          );
        }
        final monthStart = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: monthStart, end: todayEnd);
      default:
        final monthStart = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: monthStart, end: todayEnd);
    }
  }

  String _formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return formatter.format(amount);
  }

  void _exportReportPdf(BuildContext context, String activePeriod) {
    final title =
        _activePresetIndex == 0 ? 'GST Summary Report' : 'Outward Supplies Report';
    showReportPdfExportModal(
      context,
      reportTitle: title,
      period: activePeriod,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeFilter = ref.watch(analyticsDateFilterProvider);
    final range = _getFilterDateRange(activeFilter);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _activePresetIndex == 0 ? 'GST Summary' : 'Outward Supplies',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Export Report',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _exportReportPdf(context, activeFilter),
          ),
          IconButton(
            tooltip: 'Reset Filters',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: _clearFilters,
          ),
        ],
      ),
      body: BlocBuilder<InvoiceBloc, InvoiceState>(
        builder: (context, invoiceState) {
          List<InvoiceEntity> allInvoices = [];
          if (invoiceState is InvoicesLoadedState) {
            allInvoices = invoiceState.invoices;
          }

          final salesInvoices = allInvoices.where((i) {
            if (!i.isSale) return false;
            final dateMatch = i.issueDate
                    .isAfter(range.start.subtract(const Duration(seconds: 1))) &&
                i.issueDate.isBefore(range.end.add(const Duration(seconds: 1)));
            if (!dateMatch) return false;

            final query = _searchCtrl.text.trim().toLowerCase();
            if (query.isNotEmpty) {
              final matchesName = i.customerName.toLowerCase().contains(query);
              final matchesNumber = i.invoiceNumber.toLowerCase().contains(query);
              if (!matchesName && !matchesNumber) return false;
            }
            return true;
          }).toList();

          final purchaseInvoices = allInvoices.where((i) {
            if (!i.isPurchase) return false;
            return i.issueDate
                    .isAfter(range.start.subtract(const Duration(seconds: 1))) &&
                i.issueDate.isBefore(range.end.add(const Duration(seconds: 1)));
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPresetChips(),
                  const SizedBox(height: 14),
                  _buildFilterHeader(activeFilter, range),
                  const SizedBox(height: 16),

                  if (_activePresetIndex == 0)
                    _buildGstSummaryView(salesInvoices, purchaseInvoices)
                  else
                    _buildOutwardSuppliesView(salesInvoices),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresetChips() {
    final presets = ['GST Summary', 'Outward Supplies'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: presets.asMap().entries.map((entry) {
          final idx = entry.key;
          final label = entry.value;
          final selected = _activePresetIndex == idx;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: selected,
              selectedColor: AppColors.primaryBlue,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.darkBlueText,
              ),
              onSelected: (val) {
                if (val) setState(() => _activePresetIndex = idx);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterHeader(String activeFilter, DateTimeRange range) {
    final filters = [
      'Today',
      'This Week',
      'This Month',
      'This Quarter',
      'Last Month',
      'This Year',
      'Custom Range'
    ];

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.pageBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search customer, invoice no...',
                hintStyle: TextStyle(
                    fontSize: 12, color: AppColors.secondaryText),
                prefixIcon: Icon(Icons.search,
                    size: 18, color: AppColors.secondaryText),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((f) {
                final isSelected = activeFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(f, style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    selectedColor: AppColors.primaryBlue,
                    backgroundColor: AppColors.pageBackground,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.darkBlueText,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (val) {
                      if (val) {
                        if (f == 'Custom Range') {
                          _selectCustomDateRange(context);
                        } else {
                          ref
                              .read(analyticsDateFilterProvider.notifier)
                              .state = f;
                        }
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // VIEW 0: GST SUMMARY STATEMENT VIEW
  // ==========================================================================

  Widget _buildGstSummaryView(
      List<InvoiceEntity> sales, List<InvoiceEntity> purchases) {
    final outputGst = sales.fold(0.0, (sum, s) => sum + s.taxTotal);
    final inputItc = purchases.fold(0.0, (sum, p) => sum + p.taxTotal);
    final netLiability = (outputGst - inputItc).clamp(0.0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.deepNavy,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('GST LIABILITY & ITC SET-OFF STATEMENT',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                      letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Output GST (Sales)',
                          style:
                              TextStyle(fontSize: 11, color: Colors.white70)),
                      Text(_formatCurrency(outputGst),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Input ITC (Purchases)',
                          style:
                              TextStyle(fontSize: 11, color: Colors.white70)),
                      Text(_formatCurrency(inputItc),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.success)),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Net Payable GST Liability',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  Text(_formatCurrency(netLiability),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('GST Tax Breakdown Summary',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText)),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _buildSummaryRow(
                  'Central GST (CGST 9%)', outputGst / 2, inputItc / 2),
              const Divider(height: 16),
              _buildSummaryRow(
                  'State GST (SGST 9%)', outputGst / 2, inputItc / 2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String title, double out, double inp) {
    final net = (out - inp).clamp(0.0, double.infinity);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlueText)),
            Text(
                'Output: ${_formatCurrency(out)} • ITC: ${_formatCurrency(inp)}',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.secondaryText)),
          ],
        ),
        Text(_formatCurrency(net),
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryBlue)),
      ],
    );
  }

  // ==========================================================================
  // VIEW 1: OUTWARD SUPPLIES REPORT VIEW
  // ==========================================================================

  Widget _buildOutwardSuppliesView(List<InvoiceEntity> salesInvoices) {
    final totalTaxable = salesInvoices.fold(0.0, (sum, i) => sum + i.subtotal);
    final totalGst = salesInvoices.fold(0.0, (sum, i) => sum + i.taxTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Outward Taxable Value',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlueText)),
                  Text(_formatCurrency(totalTaxable),
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryBlue)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Outward Output GST',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlueText)),
                  Text(_formatCurrency(totalGst),
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.success)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Outward Supplies Sales Log',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText)),
        const SizedBox(height: 10),
        if (salesInvoices.isEmpty)
          const EmptyState(
            title: 'No Outward Supplies',
            message: 'No outward taxable sales for selected period.',
            icon: Icons.outbox_outlined,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: salesInvoices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final inv = salesInvoices[idx];
              return AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(inv.invoiceNumber,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryBlue)),
                          Text(
                            inv.customerName.isNotEmpty
                                ? inv.customerName
                                : 'Consumer B2C',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkBlueText),
                          ),
                          Text(
                            'Date: ${DateFormat('dd MMM yyyy').format(inv.issueDate)}',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_formatCurrency(inv.grandTotal),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkBlueText)),
                        Text('GST: ${_formatCurrency(inv.taxTotal)}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
