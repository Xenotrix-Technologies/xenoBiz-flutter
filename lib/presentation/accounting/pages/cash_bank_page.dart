import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class CashBankPage extends StatelessWidget {
  const CashBankPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    final accounts = [
      _AccountModel(name: 'Cash in Hand', type: 'Cash', balance: 24500.0, icon: Icons.payments_outlined, color: AppColors.success),
      _AccountModel(name: 'Petty Cash Account', type: 'Cash', balance: 3200.0, icon: Icons.account_balance_wallet_outlined, color: Colors.teal),
      _AccountModel(name: 'HDFC Bank Main A/c', type: 'Bank', accountNumber: 'XXXX 4812', balance: 142800.0, icon: Icons.account_balance_outlined, color: AppColors.primaryBlue),
      _AccountModel(name: 'SBI Current A/c', type: 'Bank', accountNumber: 'XXXX 9031', balance: 58400.0, icon: Icons.account_balance_outlined, color: Colors.indigo),
    ];

    final totalBalance = accounts.fold(0.0, (sum, a) => sum + a.balance);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cash & Bank'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Balance Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.deepNavy, Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Cash & Bank Balance', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    currencyFormatter.format(totalBalance),
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.deepNavy,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => context.push(RouteNames.newContraEntry),
                        icon: const Icon(Icons.swap_horiz, size: 18),
                        label: const Text('Transfer (Contra)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Accounts Overview',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
            ),
            const SizedBox(height: 12),

            ...accounts.map((acc) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  onTap: () => context.push(RouteNames.ledger, extra: acc.name),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: acc.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(acc.icon, color: acc.color, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              acc.name,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.darkBlueText),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              acc.accountNumber != null ? '${acc.type} • ${acc.accountNumber}' : acc.type,
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormatter.format(acc.balance),
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: acc.color),
                          ),
                          const SizedBox(height: 2),
                          const Text('View Ledger →', style: TextStyle(fontSize: 11, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _AccountModel {
  final String name;
  final String type;
  final String? accountNumber;
  final double balance;
  final IconData icon;
  final Color color;

  _AccountModel({
    required this.name,
    required this.type,
    this.accountNumber,
    required this.balance,
    required this.icon,
    required this.color,
  });
}
