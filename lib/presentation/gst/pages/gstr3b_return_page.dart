import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/invoice_bloc.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../widgets/app_card.dart';

// ============================================================================
// DEDICATED GSTR-3B RETURN COMPLIANCE PAGE
// ============================================================================

class Gstr3bReturnPage extends StatefulWidget {
  const Gstr3bReturnPage({super.key});

  @override
  State<Gstr3bReturnPage> createState() => _Gstr3bReturnPageState();
}

class _Gstr3bReturnPageState extends State<Gstr3bReturnPage> {
  String _activeTaxPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
    });
  }

  String _formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'GSTR-3B Summary Return',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exported GSTR-3B Filing Summary!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<InvoiceBloc, InvoiceState>(
        builder: (context, invoiceState) {
          List<InvoiceEntity> allInvoices = [];
          if (invoiceState is InvoicesLoadedState) {
            allInvoices = invoiceState.invoices;
          }

          final salesInvoices = allInvoices.where((i) => i.isSale).toList();
          final purchaseInvoices = allInvoices.where((i) => i.isPurchase).toList();

          final outwardTaxable = salesInvoices.fold(0.0, (s, i) => s + i.subtotal);
          final outwardTax = salesInvoices.fold(0.0, (s, i) => s + i.taxTotal);
          final itcTax = purchaseInvoices.fold(0.0, (s, i) => s + i.taxTotal);
          final netTaxPayable = (outwardTax - itcTax).clamp(0.0, double.infinity);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaxPeriodChips(),
                const SizedBox(height: 16),

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
                      const Text('NET GST TAX PAYABLE (SET OFF)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(_formatCurrency(netTaxPayable),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _buildRow('3.1 Outward Taxable Supplies', outwardTaxable,
                          outwardTax),
                      const Divider(height: 20),
                      _buildRow('4. Eligible Input Tax Credit (ITC)', 0.0, itcTax),
                      const Divider(height: 20, thickness: 2),
                      _buildRow('6.1 Net Tax Payable After ITC', 0.0, netTaxPayable,
                          isHighlight: true),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaxPeriodChips() {
    final periods = ['This Month', 'Last Month', 'This Quarter'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map((p) {
          final isSelected = _activeTaxPeriod == p;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(p, style: const TextStyle(fontSize: 11)),
              selected: isSelected,
              selectedColor: AppColors.primaryBlue,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkBlueText,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              onSelected: (val) {
                if (val) setState(() => _activeTaxPeriod = p);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRow(String title, double taxable, double tax,
      {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isHighlight
                    ? AppColors.primaryBlue
                    : AppColors.darkBlueText)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (taxable > 0)
              Text('Taxable: ${_formatCurrency(taxable)}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.secondaryText)),
            Text('GST: ${_formatCurrency(tax)}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isHighlight ? AppColors.success : AppColors.darkBlueText)),
          ],
        ),
      ],
    );
  }
}
