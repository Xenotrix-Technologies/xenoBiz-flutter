import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../const/colors.dart';
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
          if (state is SyncLoadingState) return const SettingsFormSkeleton();
          if (state is SyncLoadedState) {
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
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_off_rounded,
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Local-First Mode (Sync Disabled)',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Business data is stored securely on this device. Cloud synchronization is currently unavailable.',
                                style: TextStyle(fontSize: 13, color: AppColors.outline),
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
                        'Sync Queue (Disabled)',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const EmptyState(
                    title: 'Local Database Active',
                    message: 'All customer, product, invoice, payment, and inventory records are stored locally in Hive as the single source of truth.',
                    icon: Icons.storage_rounded,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Sync Currently Unavailable',
                    icon: Icons.sync_disabled,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Business data is stored securely on this device. Cloud synchronization is currently unavailable.'),
                          backgroundColor: AppColors.outline,
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
