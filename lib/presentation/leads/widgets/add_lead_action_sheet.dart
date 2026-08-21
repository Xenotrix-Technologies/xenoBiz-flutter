import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';

class AddLeadActionSheet extends StatelessWidget {
  const AddLeadActionSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const AddLeadActionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add Lead',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.darkBlueText,
              ),
            ),
            const SizedBox(height: 16),

            // Option 1: Add Lead Manually
            Material(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primaryBlue),
                  ),
                  title: const Text(
                    'Add Lead Manually',
                    style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                  ),
                  subtitle: const Text(
                    'Create a single lead by filling in details manually.',
                    style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RouteNames.addLead);
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Option 2: Import from Excel / CSV
            Material(
              color: AppColors.primaryBlue.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.description_rounded, color: AppColors.success),
                  ),
                  title: const Text(
                    'Import from Excel / CSV',
                    style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                  ),
                  subtitle: const Text(
                    'Bulk import multiple leads from .xlsx or .csv files.',
                    style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.primaryBlue),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RouteNames.importLeads);
                  },
                ),
              ),
            ),


            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
