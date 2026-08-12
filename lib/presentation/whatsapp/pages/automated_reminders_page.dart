import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class AutomatedRemindersPage extends StatefulWidget {
  const AutomatedRemindersPage({super.key});

  @override
  State<AutomatedRemindersPage> createState() => _AutomatedRemindersPageState();
}

class _AutomatedRemindersPageState extends State<AutomatedRemindersPage> {
  bool _rule1 = true;
  bool _rule2 = true;

  @override
  Widget build(BuildContext context) {
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
                    value: _rule1,
                    onChanged: (val) => setState(() => _rule1 = val),
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
                    value: _rule2,
                    onChanged: (val) => setState(() => _rule2 = val),
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
