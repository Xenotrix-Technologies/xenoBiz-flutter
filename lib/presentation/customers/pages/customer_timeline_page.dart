import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/bloc/customer_bloc.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

class CustomerTimelinePage extends StatefulWidget {
  const CustomerTimelinePage({super.key});

  @override
  State<CustomerTimelinePage> createState() => _CustomerTimelinePageState();
}

class _CustomerTimelinePageState extends State<CustomerTimelinePage> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const FetchCustomerTimelineEvent('cust_101'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Activity Timeline'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoadingState) {
            return const FollowupsPageSkeleton();
          }
          if (state is CustomerTimelineLoadedState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.customer.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Outstanding: ₹${state.customer.outstandingBalance.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Chronological Feed',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.timeline.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, idx) {
                      final item = state.timeline[idx];
                      IconData icon = Icons.info_outline;
                      Color iconColor = AppColors.primary;
                      if (item.eventType == 'INVOICE') {
                        icon = Icons.receipt_long;
                        iconColor = AppColors.secondary;
                      } else if (item.eventType == 'PAYMENT') {
                        icon = Icons.payments;
                        iconColor = AppColors.success;
                      } else if (item.eventType == 'FOLLOW_UP') {
                        icon = Icons.chat_bubble;
                        iconColor = AppColors.warning;
                      }

                      return AppCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: iconColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, size: 20, color: iconColor),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.timestamp.toString().substring(0, 16),
                                    style: const TextStyle(fontSize: 11, color: AppColors.outline),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
