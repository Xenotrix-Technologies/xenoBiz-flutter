import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../const/colors.dart';

class TrialBalancePage extends StatefulWidget {
  const TrialBalancePage({super.key});

  @override
  State<TrialBalancePage> createState() => _TrialBalancePageState();
}

class _TrialBalancePageState extends State<TrialBalancePage> {
  final String _financialYear = 'FY 2026-27';

  final List<_TrialBalanceRow> _accounts = const [
    _TrialBalanceRow(accountName: 'Cash Account', category: 'Assets', debit: 24500.0, credit: 0.0),
    _TrialBalanceRow(accountName: 'HDFC Bank Main A/c', category: 'Assets', debit: 142800.0, credit: 0.0),
    _TrialBalanceRow(accountName: 'Sundry Debtors (Customers)', category: 'Assets', debit: 52500.0, credit: 0.0),
    _TrialBalanceRow(accountName: 'Product Stock Inventory', category: 'Assets', debit: 185000.0, credit: 0.0),
    _TrialBalanceRow(accountName: 'Furniture & Fixtures', category: 'Assets', debit: 45000.0, credit: 0.0),
    _TrialBalanceRow(accountName: 'Sundry Creditors (Suppliers)', category: 'Liabilities', debit: 0.0, credit: 62300.0),
    _TrialBalanceRow(accountName: 'GST Payable A/c', category: 'Liabilities', debit: 0.0, credit: 14500.0),
    _TrialBalanceRow(accountName: 'Capital Account', category: 'Equity', debit: 0.0, credit: 300000.0),
    _TrialBalanceRow(accountName: 'Sales Revenue', category: 'Income', debit: 0.0, credit: 184000.0),
    _TrialBalanceRow(accountName: 'Cost of Goods Sold', category: 'Expense', debit: 92000.0, credit: 0.0),
    _TrialBalanceRow(accountName: 'Shop Rent Expense', category: 'Expense', debit: 15000.0, credit: 0.0),
    _TrialBalanceRow(accountName: 'Salaries Expense', category: 'Expense', debit: 40000.0, credit: 0.0),
    _TrialBalanceRow(accountName: 'Depreciation Expense', category: 'Expense', debit: 4000.0, credit: 0.0),
  ];

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    final totalDebit = _accounts.fold(0.0, (sum, r) => sum + r.debit);
    final totalCredit = _accounts.fold(0.0, (sum, r) => sum + r.credit);
    final isBalanced = (totalDebit - totalCredit).abs() < 0.01;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trial Balance'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trial Balance PDF export complete.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Trial Balance Sheet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.darkBlueText)),
                    const SizedBox(height: 2),
                    Text('As of ${DateFormat('dd MMM yyyy').format(DateTime.now())} • $_financialYear', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isBalanced ? AppColors.success.withValues(alpha: 0.12) : AppColors.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(isBalanced ? Icons.check_circle : Icons.error, color: isBalanced ? AppColors.success : AppColors.danger, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        isBalanced ? 'Balanced' : 'Unbalanced',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: isBalanced ? AppColors.success : AppColors.danger),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.grey.shade200,
            child: const Row(
              children: [
                Expanded(flex: 4, child: Text('LEDGER ACCOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.darkBlueText))),
                Expanded(flex: 3, child: Text('DEBIT (₹)', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.success))),
                Expanded(flex: 3, child: Text('CREDIT (₹)', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.danger))),
              ],
            ),
          ),

          // Rows
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _accounts.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final row = _accounts[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.accountName,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.darkBlueText),
                            ),
                            Text(
                              row.category,
                              style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          row.debit > 0 ? currencyFormatter.format(row.debit) : '-',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: row.debit > 0 ? AppColors.darkBlueText : AppColors.secondaryText,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          row.credit > 0 ? currencyFormatter.format(row.credit) : '-',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: row.credit > 0 ? AppColors.darkBlueText : AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Total Footer Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: AppColors.deepNavy,
            child: Row(
              children: [
                const Expanded(
                  flex: 4,
                  child: Text(
                    'TOTAL BALANCE',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    currencyFormatter.format(totalDebit),
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    currencyFormatter.format(totalCredit),
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrialBalanceRow {
  final String accountName;
  final String category;
  final double debit;
  final double credit;

  const _TrialBalanceRow({
    required this.accountName,
    required this.category,
    required this.debit,
    required this.credit,
  });
}
