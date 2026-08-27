import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class ReceivablesPage extends StatelessWidget {
  const ReceivablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    final debtors = [
      _PartyModel(name: 'Rahul Sharma', amount: 15400.0, dueDays: 12, invoiceNo: 'INV-2026-089', phone: '+91 98765 43210'),
      _PartyModel(name: 'Ankit Traders', amount: 28900.0, dueDays: 45, invoiceNo: 'INV-2026-042', phone: '+91 98123 45678'),
      _PartyModel(name: 'Priya Enterprise', amount: 8200.0, dueDays: 5, invoiceNo: 'INV-2026-105', phone: '+91 97000 11223'),
    ];

    final totalReceivable = debtors.fold(0.0, (sum, d) => sum + d.amount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Outstanding Receivables'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.call_received, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Money to Receive', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(totalReceivable),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.success),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Customer Aging & Dues', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
            const SizedBox(height: 12),

            ...debtors.map((d) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(d.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.darkBlueText)),
                          Text(currencyFormatter.format(d.amount), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.success)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${d.invoiceNo} • Overdue by ${d.dueDays} days', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                          TextButton.icon(
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Payment reminder sent to ${d.name}')),
                              );
                            },
                            icon: const Icon(Icons.send_rounded, size: 14, color: AppColors.primaryBlue),
                            label: const Text('Send Reminder', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                          ),
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

class PayablesPage extends StatelessWidget {
  const PayablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    final creditors = [
      _PartyModel(name: 'Metro Wholesalers', amount: 42500.0, dueDays: 10, invoiceNo: 'PUR-2026-088', phone: '+91 99887 76655'),
      _PartyModel(name: 'Apex Distributors', amount: 19800.0, dueDays: 22, invoiceNo: 'PUR-2026-061', phone: '+91 98888 55443'),
    ];

    final totalPayable = creditors.fold(0.0, (sum, c) => sum + c.amount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Outstanding Payables'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.call_made, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Money to Pay', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(totalPayable),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.danger),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Supplier Bills & Dues', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
            const SizedBox(height: 12),

            ...creditors.map((c) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.darkBlueText)),
                          Text(currencyFormatter.format(c.amount), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.danger)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${c.invoiceNo} • Due in ${c.dueDays} days', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Payment process started for ${c.name}')),
                              );
                            },
                            child: const Text('Pay Bill', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
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

class _PartyModel {
  final String name;
  final double amount;
  final int dueDays;
  final String invoiceNo;
  final String phone;

  _PartyModel({
    required this.name,
    required this.amount,
    required this.dueDays,
    required this.invoiceNo,
    required this.phone,
  });
}
