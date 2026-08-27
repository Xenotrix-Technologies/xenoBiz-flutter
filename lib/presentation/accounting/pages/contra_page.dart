import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/accounting_entities.dart';
import '../../../infrastructure/repositories/accounting_repository.dart';
import '../../widgets/app_card.dart';

class ContraPage extends StatefulWidget {
  const ContraPage({super.key});

  @override
  State<ContraPage> createState() => _ContraPageState();
}

class _ContraPageState extends State<ContraPage> {
  late List<ContraEntryEntity> _contras;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() {
    final repo = getIt<AccountingRepository>();
    setState(() {
      _contras = repo.getContraEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormatter = DateFormat('dd MMM yyyy');

    final filtered = _contras.where((c) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.referenceNumber.toLowerCase().contains(q) ||
          c.fromAccount.toLowerCase().contains(q) ||
          c.toAccount.toLowerCase().contains(q) ||
          c.narration.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Contra Vouchers'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(RouteNames.newContraEntry);
          _loadEntries();
        },
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Contra Entry',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Banner explanation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            child: const Row(
              children: [
                Icon(Icons.swap_horiz_rounded, color: AppColors.primaryBlue, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Contra vouchers record internal money transfers between Cash and Bank accounts (Cash ↔ Bank, Bank ↔ Bank).',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkBlueText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search contra voucher, accounts, mode...',
                prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),

          // Contra vouchers list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.account_balance, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No Contra Vouchers Found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkBlueText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap "+ New Contra Entry" to record Cash/Bank transfers.',
                          style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                    itemBuilder: (ctx, idx) {
                      final item = filtered[idx];
                      return AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.referenceNumber,
                                    style: const TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  dateFormatter.format(item.date),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Transfer visualization
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('FROM ACCOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.secondaryText)),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.fromAccount,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.darkBlueText),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward, color: AppColors.primaryBlue, size: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('TO ACCOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.secondaryText)),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.toAccount,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.darkBlueText),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(item.paymentMode, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.grey.shade100,
                                  visualDensity: VisualDensity.compact,
                                ),
                                Text(
                                  currencyFormatter.format(item.amount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),

                            if (item.narration.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Note: ${item.narration}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
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
}
