import 'package:flutter/material.dart';
import '../../const/colors.dart';
import '../../const/sizes.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
  });

  factory StatusChip.paid({String label = 'Paid'}) {
    return StatusChip(
      label: label,
      color: AppColors.success,
      backgroundColor: AppColors.successContainer,
    );
  }

  factory StatusChip.unpaid({String label = 'Unpaid'}) {
    return StatusChip(
      label: label,
      color: AppColors.error,
      backgroundColor: AppColors.errorContainer,
    );
  }

  factory StatusChip.partiallyPaid({String label = 'Partial'}) {
    return StatusChip(
      label: label,
      color: AppColors.warning,
      backgroundColor: AppColors.warningContainer,
    );
  }

  factory StatusChip.trial({String label = '7-Day Trial'}) {
    return StatusChip(
      label: label,
      color: AppColors.onSecondaryContainer,
      backgroundColor: AppColors.secondaryContainer,
    );
  }

  factory StatusChip.inStock({String label = 'IN STOCK'}) {
    return StatusChip(
      label: label,
      color: AppColors.success,
      backgroundColor: AppColors.successContainer,
    );
  }

  factory StatusChip.lowStock({String label = 'LOW STOCK'}) {
    return StatusChip(
      label: label,
      color: AppColors.warning,
      backgroundColor: AppColors.warningContainer,
    );
  }

  factory StatusChip.outOfStock({String label = 'OUT OF STOCK'}) {
    return StatusChip(
      label: label,
      color: AppColors.error,
      backgroundColor: AppColors.errorContainer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
