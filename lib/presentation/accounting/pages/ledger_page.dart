import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../infrastructure/repositories/accounting_repository.dart';

class LedgerPage extends StatefulWidget {
  final String? initialAccount;
  const LedgerPage({super.key, this.initialAccount});

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  late String _selectedAccount;
  String _selectedDateRange = 'This Month';
  String _selectedFinancialYear = 'FY 2026-27';
  String _searchQuery = '';

  final List<String> _accountOptions = [
    'Rahul Sharma (Customer)',
    'Metro Wholesalers (Supplier)',
    'Cash Account',
    'HDFC Bank Main A/c',
    'Shop Rent Expense',
    'Sales Revenue Account',
    'Capital Account',
    'Discount Allowed Account',
  ];

  final List<String> _dateRanges = ['This Month', 'Last Month', 'This Quarter', 'Custom Range'];
  final List<String> _financialYears = ['FY 2026-27', 'FY 2025-26', 'FY 2024-25'];

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.initialAccount ?? _accountOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormatter = DateFormat('dd MMM yyyy');

    final repo = getIt<AccountingRepository>();
    final transactions = repo.getLedgerTransactions(_selectedAccount);

    final filtered = transactions.where((tx) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return tx.particulars.toLowerCase().contains(q) ||
          tx.referenceNumber.toLowerCase().contains(q) ||
          tx.voucherType.toLowerCase().contains(q);
    }).toList();

    double openingBal = 10000.0;
    double totalDebit = filtered.fold(0.0, (sum, tx) => sum + tx.debit);
    double totalCredit = filtered.fold(0.0, (sum, tx) => sum + tx.credit);
    double closingBal = openingBal + totalDebit - totalCredit;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account Ledger'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ledger PDF statement generated.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Account Selector Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Account Selector Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _accountOptions.contains(_selectedAccount) ? _selectedAccount : _accountOptions.first,
                  decoration: InputDecoration(
                    labelText: 'Select Account Ledger',
                    prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryBlue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _accountOptions.map((acc) {
                    return DropdownMenuItem(
                      value: acc,
                      child: Text(acc, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedAccount = val);
                  },
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedDateRange,
                        decoration: InputDecoration(
                          labelText: 'Period',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: _dateRanges.map((r) {
                          return DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 12)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDateRange = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedFinancialYear,
                        decoration: InputDecoration(
                          labelText: 'Financial Year',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: _financialYears.map((fy) {
                          return DropdownMenuItem(value: fy, child: Text(fy, style: const TextStyle(fontSize: 12)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedFinancialYear = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search particulars, ref no...',
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.secondaryText),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),

          // Summary Banner Card (Section 12 requirement: Opening Balance | Total Debit | Total Credit | Closing Balance)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.deepNavy,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryColumn('Opening Bal', currencyFormatter.format(openingBal), Colors.white70),
                    _buildSummaryColumn('Total Debit', currencyFormatter.format(totalDebit), Colors.greenAccent),
                    _buildSummaryColumn('Total Credit', currencyFormatter.format(totalCredit), Colors.orangeAccent),
                    _buildSummaryColumn('Closing Bal', currencyFormatter.format(closingBal), Colors.white),
                  ],
                ),
              ],
            ),
          ),

          // Mobile-friendly Ledger List / Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: Colors.grey.shade200,
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('DATE / VOUCHER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.darkBlueText))),
                Expanded(flex: 2, child: Text('DEBIT (Dr.)', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.success))),
                Expanded(flex: 2, child: Text('CREDIT (Cr.)', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.danger))),
                Expanded(flex: 2, child: Text('BALANCE', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.darkBlueText))),
              ],
            ),
          ),

          // Ledger Table Rows
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filtered.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final tx = filtered[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateFormatter.format(tx.date),
                              style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tx.particulars,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              tx.referenceNumber,
                              style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          tx.debit > 0 ? currencyFormatter.format(tx.debit) : '-',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: tx.debit > 0 ? AppColors.success : AppColors.secondaryText,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          tx.credit > 0 ? currencyFormatter.format(tx.credit) : '-',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: tx.credit > 0 ? AppColors.danger : AppColors.secondaryText,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          currencyFormatter.format(tx.runningBalance),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlueText,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: valueColor),
        ),
      ],
    );
  }
}
