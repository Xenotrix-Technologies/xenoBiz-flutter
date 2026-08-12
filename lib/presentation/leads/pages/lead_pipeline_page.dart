import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/lead_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

class LeadPipelinePage extends StatefulWidget {
  const LeadPipelinePage({super.key});

  @override
  State<LeadPipelinePage> createState() => _LeadPipelinePageState();
}

class _LeadPipelinePageState extends State<LeadPipelinePage> {
  @override
  void initState() {
    super.initState();
    context.read<LeadBloc>().add(const FetchLeadsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lead Pipeline (CRM)'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.task_alt),
            onPressed: () {
              context.push(RouteNames.followUps);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          context.push(RouteNames.addLead);
        },
        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
      ),
      body: BlocBuilder<LeadBloc, LeadState>(
        builder: (context, state) {
          if (state is LeadLoadingState) return const LoadingState(message: 'Loading leads...');
          if (state is LeadsLoadedState) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.leads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, idx) {
                final lead = state.leads[idx];
                return AppCard(
                  onTap: () {
                    context.push(RouteNames.leadDetails);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              lead.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              lead.stage.name.toUpperCase(),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSecondaryContainer),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Contact: ${lead.contactName} (${lead.phone})', style: const TextStyle(fontSize: 13, color: AppColors.outline)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Est. Value: ₹${lead.estimatedValue.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.success)),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.outline),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
