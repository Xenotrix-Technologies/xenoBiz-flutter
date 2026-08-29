import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/invoice_bloc.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../widgets/app_card.dart';
import '../widgets/report_export_sheet.dart';

// ============================================================================
// DEDICATED ACCOUNT REPORT PAGE (FORMAL FINANCIAL STATEMENT)
// ============================================================================

class AccountReportPage extends StatefulWidget {
  final Object? initialPreset;
  const AccountReportPage({super.key, this.initialPreset});

  @override
  State<AccountReportPage> createState() => _AccountReportPageState();
}

class _AccountReportPageState extends State<AccountReportPage> {
  // Presets: 0: Account Summary, 1: Trial Balance, 2: Profit & Loss, 3: Balance Sheet
  int _activePresetIndex = 0;

  @override
  void initState() {
    super.initState();
    _parseInitialPreset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
    });
  }

  void _parseInitialPreset() {
    if (widget.initialPreset is int) {
      _activePresetIndex = widget.initialPreset as int;
    } else if (widget.initialPreset is Map &&
        (widget.initialPreset as Map).containsKey('preset')) {
      _activePresetIndex = (widget.initialPreset as Map)['preset'] as int;
    } else if (widget.initialPreset is String) {
      final p = (widget.initialPreset as String).toLowerCase();
      if (p.contains('trial')) {
        _activePresetIndex = 1;
      } else if (p.contains('profit') || p.contains('loss')) {
        _activePresetIndex = 2;
      } else if (p.contains('balance')) {
        _activePresetIndex = 3;
      } else {
        _activePresetIndex = 0;
      }
    }
  }

  String _formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return formatter.format(amount);
  }

  void _exportReportPdf(BuildContext context) {
    final presetNames = [
      'Account Summary Statement',
      'Trial Balance Statement',
      'Profit & Loss Statement',
      'Balance Sheet Statement',
    ];
    final currentTitle = presetNames[_activePresetIndex];
    showReportPdfExportModal(
      context,
      reportTitle: currentTitle,
      period: 'Financial Accounting Period',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Account Report',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Export Report',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _exportReportPdf(context),
          ),
        ],
      ),
      body: BlocBuilder<InvoiceBloc, InvoiceState>(
        builder: (context, invoiceState) {
          List<InvoiceEntity> allInvoices = [];
          if (invoiceState is InvoicesLoadedState) {
            allInvoices = invoiceState.invoices;
          }

          final salesInvoices =
              allInvoices.where((i) => i.isSale).toList();
          final purchaseInvoices =
              allInvoices.where((i) => i.isPurchase).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPresetChips(),
                const SizedBox(height: 16),

                if (_activePresetIndex == 0)
                  _buildAccountSummaryView(salesInvoices, purchaseInvoices)
                else if (_activePresetIndex == 1)
                  _buildTrialBalanceView(salesInvoices, purchaseInvoices)
                else if (_activePresetIndex == 2)
                  _buildProfitLossView(salesInvoices, purchaseInvoices)
                else if (_activePresetIndex == 3)
                  _buildBalanceSheetView(salesInvoices, purchaseInvoices),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresetChips() {
    final presets = [
      'Account Summary',
      'Trial Balance',
      'Profit & Loss',
      'Balance Sheet',
    ];

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

  Widget _buildAccountSummaryView(
      List<InvoiceEntity> sales, List<InvoiceEntity> purchases) {
    final totalSales = sales.fold(0.0, (sum, s) => sum + s.grandTotal);
    final totalPurchases = purchases.fold(0.0, (sum, p) => sum + p.grandTotal);
    final netFlow = totalSales - totalPurchases;

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
              const Text('FINANCIAL ACCOUNT SUMMARY STATEMENT',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Revenue',
                          style: TextStyle(fontSize: 11, color: Colors.white70)),
                      Text(_formatCurrency(totalSales),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.success)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Expenses',
                          style: TextStyle(fontSize: 11, color: Colors.white70)),
                      Text(_formatCurrency(totalPurchases),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.danger)),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Net Surplus / Balance',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  Text(_formatCurrency(netFlow),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: netFlow >= 0
                              ? AppColors.success
                              : AppColors.danger)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrialBalanceView(
      List<InvoiceEntity> sales, List<InvoiceEntity> purchases) {
    final totalSales = sales.fold(0.0, (sum, s) => sum + s.grandTotal);
    final totalPurchases = purchases.fold(0.0, (sum, p) => sum + p.grandTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trial Balance Statement',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText)),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _buildBalanceRow('Sales / Income Ledger (Credit)', totalSales,
                  isDebit: false),
              const Divider(),
              _buildBalanceRow('Purchase / Expense Ledger (Debit)',
                  totalPurchases,
                  isDebit: true),
              const Divider(thickness: 2),
              _buildBalanceRow('Trial Balance Difference',
                  (totalSales - totalPurchases).abs(),
                  isDebit: totalPurchases > totalSales),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceRow(String title, double amount,
      {required bool isDebit}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBlueText)),
        Text(
          '${_formatCurrency(amount)} ${isDebit ? 'DR' : 'CR'}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isDebit ? AppColors.danger : AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildProfitLossView(
      List<InvoiceEntity> sales, List<InvoiceEntity> purchases) {
    final totalSales = sales.fold(0.0, (sum, s) => sum + s.grandTotal);
    final totalPurchases = purchases.fold(0.0, (sum, p) => sum + p.grandTotal);
    final netProfit = totalSales - totalPurchases;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Profit & Loss Financial Statement',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText)),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _buildBalanceRow('Operating Gross Sales Revenue', totalSales,
                  isDebit: false),
              const SizedBox(height: 6),
              _buildBalanceRow('Cost of Goods & Procurement', totalPurchases,
                  isDebit: true),
              const Divider(thickness: 2, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(netProfit >= 0 ? 'Net Operating Profit' : 'Net Loss',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkBlueText)),
                  Text(_formatCurrency(netProfit),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: netProfit >= 0
                              ? AppColors.success
                              : AppColors.danger)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceSheetView(
      List<InvoiceEntity> sales, List<InvoiceEntity> purchases) {
    final totalReceivables = sales
        .where((s) => s.status != InvoiceStatus.paid)
        .fold(0.0, (sum, s) => sum + (s.grandTotal - s.paidAmount));
    final totalPayables = purchases
        .where((p) => p.status != InvoiceStatus.paid)
        .fold(0.0, (sum, p) => sum + (p.grandTotal - p.paidAmount));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Balance Sheet Statement',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText)),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CURRENT ASSETS',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlue)),
              const SizedBox(height: 4),
              _buildBalanceRow('Trade Receivables (Customer Due)',
                  totalReceivables,
                  isDebit: true),
              const SizedBox(height: 12),
              const Text('CURRENT LIABILITIES',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.danger)),
              const SizedBox(height: 4),
              _buildBalanceRow('Trade Payables (Supplier Due)', totalPayables,
                  isDebit: false),
            ],
          ),
        ),
      ],
    );
  }
}
