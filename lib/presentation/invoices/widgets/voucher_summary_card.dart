import 'package:flutter/material.dart';
import '../../../const/colors.dart';

class VoucherSummaryCard extends StatelessWidget {
  final double subtotal;
  final double totalTax;
  final double discountAmount;
  final double extraCharges;
  final double grandTotal;

  const VoucherSummaryCard({
    super.key,
    required this.subtotal,
    required this.totalTax,
    this.discountAmount = 0.0,
    this.extraCharges = 0.0,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    final netDiscountOrCharges = extraCharges - discountAmount;
    final String discountChargesText = netDiscountOrCharges < 0
        ? '- ₹${discountAmount.toStringAsFixed(2)}'
        : (netDiscountOrCharges > 0
            ? '₹${extraCharges.toStringAsFixed(2)}'
            : '- ₹0.00');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerHigh, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow(
            label: 'Subtotal',
            value: '₹${subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Total Tax',
            value: '₹${totalTax.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Discount / Extra Charges',
            value: discountChargesText,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              color: AppColors.border,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
              Text(
                '₹${grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlueText,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlueText,
          ),
        ),
      ],
    );
  }
}
