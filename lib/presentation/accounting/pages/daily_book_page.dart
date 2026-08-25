import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/accounting_entities.dart';
import '../../../infrastructure/repositories/accounting_repository.dart';
import '../../widgets/app_card.dart';

class DailyBookPage extends StatefulWidget {
  const DailyBookPage({super.key});

  @override
  State<DailyBookPage> createState() => _DailyBookPageState();
}

class _DailyBookPageState extends State<DailyBookPage> {
  DateTime _selectedDate = DateTime.now();
  String _selectedFinancialYear = 'FY 2026-27';
  AccountingTxType? _selectedTypeFilter;
  String _searchQuery = '';

  final List<String> _financialYears = ['FY 2026-27', 'FY 2025-26', 'FY 2024-25'];

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final timeFormatter = DateFormat('hh:mm a');

    final repo = getIt<AccountingRepository>();
    final transactions = repo.getDailyBookTransactions(
      date: _selectedDate,
      typeFilter: _selectedTypeFilter,
      searchQuery: _searchQuery,
    );

    final totalReceipts = transactions.fold(0.0, (sum, tx) => sum + tx.debit);
    final totalPayments = transactions.fold(0.0, (sum, tx) => sum + tx.credit);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daily Book'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Daily Book PDF report generated.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    // Date Filter
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: AppColors.primaryBlue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  DateFormat('dd MMM yyyy').format(_selectedDate),
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // FY Filter
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedFinancialYear,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: _financialYears.map((fy) {
                          return DropdownMenuItem(
                            value: fy,
                            child: Text(fy, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedFinancialYear = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Search field
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search Party, Ref No, Narration...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.secondaryText),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: const Text('All'),
                          selected: _selectedTypeFilter == null,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedTypeFilter = null);
                          },
                          selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                          checkmarkColor: AppColors.primaryBlue,
                        ),
                      ),
                      ...AccountingTxType.values.map((type) {
                        final isSelected = _selectedTypeFilter == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(type.displayName),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedTypeFilter = selected ? type : null;
                              });
                            },
                            selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                            checkmarkColor: AppColors.primaryBlue,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Day Summary Header Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.deepNavy,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Total Inflows (Dr.)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormatter.format(totalReceipts),
                      style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ],
                ),
                Container(height: 30, width: 1, color: Colors.white24),
                Column(
                  children: [
                    const Text('Total Outflows (Cr.)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormatter.format(totalPayments),
                      style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Transaction list
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_month, size: 54, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        const Text(
                          'No Transactions Recorded',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        const Text('Try selecting a different date or filter.', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: transactions.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final tx = transactions[idx];
                      final isDebit = tx.debit > 0;
                      final txColor = _getBadgeColor(tx.type);

                      return AppCard(
                        onTap: () => _showTransactionDetail(context, tx),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  timeFormatter.format(tx.date),
                                  style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: txColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tx.type.displayName,
                                    style: TextStyle(color: txColor, fontWeight: FontWeight.w800, fontSize: 11),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  tx.referenceNumber,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    tx.partyOrAccount,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.darkBlueText),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  currencyFormatter.format(isDebit ? tx.debit : tx.credit),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: isDebit ? AppColors.success : AppColors.danger,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    tx.narration,
                                    style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, fontStyle: FontStyle.italic),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  'Bal: ${currencyFormatter.format(tx.runningBalance)}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkBlueText),
                                ),
                              ],
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

  Color _getBadgeColor(AccountingTxType type) {
    switch (type) {
      case AccountingTxType.sale:
        return AppColors.success;
      case AccountingTxType.purchase:
        return AppColors.primaryBlue;
      case AccountingTxType.payment:
        return AppColors.danger;
      case AccountingTxType.receipt:
        return AppColors.success;
      case AccountingTxType.journal:
        return Colors.purple;
      case AccountingTxType.contra:
        return Colors.teal;
      case AccountingTxType.salesReturn:
        return Colors.orange;
      case AccountingTxType.purchaseReturn:
        return Colors.deepOrange;
    }
  }

  void _showTransactionDetail(BuildContext context, DailyBookTransactionEntity tx) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormatter = DateFormat('dd MMM yyyy, hh:mm a');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tx.referenceNumber,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.darkBlueText),
                  ),
                  Chip(
                    label: Text(tx.type.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                    backgroundColor: _getBadgeColor(tx.type),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Date: ${dateFormatter.format(tx.date)}', style: const TextStyle(fontSize: 13, color: AppColors.secondaryText)),
              const SizedBox(height: 6),
              Text('Party / Account: ${tx.partyOrAccount}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
              const SizedBox(height: 6),
              Text('Amount: ${currencyFormatter.format(tx.debit > 0 ? tx.debit : tx.credit)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
              const SizedBox(height: 6),
              Text('Running Balance: ${currencyFormatter.format(tx.runningBalance)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              if (tx.narration.isNotEmpty) ...[
                const Divider(height: 20),
                Text('Narration: ${tx.narration}', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
