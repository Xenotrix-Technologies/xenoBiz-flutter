import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/app_providers.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class AutomatedRemindersPage extends ConsumerWidget {
  const AutomatedRemindersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rule1 = ref.watch(reminderRule3DaysBeforeProvider);
    final rule2 = ref.watch(reminderRuleOverdue1DayProvider);
    final rule3 = ref.watch(reminderRuleOverdue7DaysProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Automated Reminders'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              onTap: () => context.push(RouteNames.editRule),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('3 Days Before Due Date', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Friendly payment reminder via WhatsApp', style: TextStyle(color: AppColors.outline, fontSize: 13)),
                      ],
                    ),
                  ),
                  Switch(
                    value: rule1,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => ref.read(reminderRule3DaysBeforeProvider.notifier).state = val,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              onTap: () => context.push(RouteNames.editRule),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Overdue Day 1 Alert', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Urgent overdue balance reminder with UPI link', style: TextStyle(color: AppColors.outline, fontSize: 13)),
                      ],
                    ),
                  ),
                  Switch(
                    value: rule2,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => ref.read(reminderRuleOverdue1DayProvider.notifier).state = val,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              onTap: () => context.push(RouteNames.editRule),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Overdue Day 7 Escalate', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Final settlement notice with legal advisory note', style: TextStyle(color: AppColors.outline, fontSize: 13)),
                      ],
                    ),
                  ),
                  Switch(
                    value: rule3,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => ref.read(reminderRuleOverdue7DaysProvider.notifier).state = val,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
