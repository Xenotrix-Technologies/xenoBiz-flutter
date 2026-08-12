import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/lead_entity.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../../application/bloc/lead_bloc.dart';

class LeadDetailsPage extends StatelessWidget {
  const LeadDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lead Overview'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('POS Hardware Deployment 10 Outlets',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  const SizedBox(height: 6),
                  const Text('Contact: Rahul Varma (Pinnacle Supermarket)', style: TextStyle(fontSize: 14, color: AppColors.outline)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Deal Value', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text('₹1,20,000', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.success)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Move Stage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Contacted'),
                  selected: true,
                  onSelected: (_) {
                    context.read<LeadBloc>().add(
                          const UpdateLeadStageEvent(leadId: 'lead_101', stage: LeadStage.contacted),
                        );
                  },
                ),
                ChoiceChip(
                  label: const Text('Proposal Sent'),
                  selected: false,
                  onSelected: (_) {
                    context.read<LeadBloc>().add(
                          const UpdateLeadStageEvent(leadId: 'lead_101', stage: LeadStage.proposalSent),
                        );
                  },
                ),
                ChoiceChip(
                  label: const Text('Won 🎉'),
                  selected: false,
                  onSelected: (_) {
                    context.read<LeadBloc>().add(
                          const UpdateLeadStageEvent(leadId: 'lead_101', stage: LeadStage.won),
                        );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Schedule Follow-up Task',
              icon: Icons.calendar_month,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
