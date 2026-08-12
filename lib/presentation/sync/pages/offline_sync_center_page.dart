import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../const/strings.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';
import '../../../application/bloc/sync_bloc.dart';

class OfflineSyncCenterPage extends StatefulWidget {
  const OfflineSyncCenterPage({super.key});

  @override
  State<OfflineSyncCenterPage> createState() => _OfflineSyncCenterPageState();
}

class _OfflineSyncCenterPageState extends State<OfflineSyncCenterPage> {
  @override
  void initState() {
    super.initState();
    context.read<SyncBloc>().add(FetchSyncQueueEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.offlineSyncCenter),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state is SyncSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
            );
            context.read<SyncBloc>().add(FetchSyncQueueEvent());
          }
        },
        builder: (context, state) {
          if (state is SyncLoadingState) return const LoadingState(message: 'Checking sync queue...');
          if (state is SyncLoadedState) {
            final isConnected = state.isConnected;
            final pending = state.pendingItems;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isConnected ? AppColors.successContainer : AppColors.warningContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isConnected ? Icons.wifi : Icons.wifi_off,
                            color: isConnected ? AppColors.success : AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isConnected ? 'Online Connection Active' : 'Offline Mode Active',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isConnected ? 'API sync ready' : 'Local transactions queued',
                                style: const TextStyle(fontSize: 13, color: AppColors.outline),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${AppStrings.syncPending} (${pending.length})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                      ),
                      if (pending.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            context.read<SyncBloc>().add(TriggerSyncNowEvent());
                          },
                          child: const Text('Process All'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (pending.isEmpty)
                    const EmptyState(
                      title: 'Queue Clear',
                      message: 'All local business transactions have been successfully synchronized with the cloud backend.',
                      icon: Icons.cloud_done_outlined,
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pending.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, idx) {
                        final item = pending[idx];
                        return AppCard(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                ),
                                child: const Icon(Icons.sync_problem, color: AppColors.primary),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.entityType} ${item.action.name.toUpperCase()}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                                    ),
                                    Text(
                                      'Retry count: ${item.retryCount}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.outline),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Sync Queue Now',
                    icon: Icons.sync,
                    onPressed: () {
                      context.read<SyncBloc>().add(TriggerSyncNowEvent());
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
