import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings & Configuration',
          style: TextStyle(color: AppColors.darkBlueText),
        ),
        foregroundColor: AppColors.darkBlueText,
        forceMaterialTransparency: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business & Account Settings Group
            _SettingsGroupCard(
              tiles: [
                _SettingsTile(
                  title: 'Business profile',
                  onTap: () => context.push(RouteNames.businessProfile),
                ),
                _SettingsTile(
                  title: 'Tax / GST settings',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tax & GST settings')),
                    );
                  },
                ),
                _SettingsTile(
                  title: 'Invoice settings',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invoice settings')),
                    );
                  },
                ),
                _SettingsTile(
                  title: 'User roles & permissions',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User roles & permissions')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // App Configuration & Sync Group
            _SettingsGroupCard(
              tiles: [
                _SettingsTile(
                  title: 'Notifications',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification settings')),
                    );
                  },
                ),
                _SettingsTile(
                  title: 'Offline & sync',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.successTint,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.circle,
                                color: AppColors.success, size: 8),
                            SizedBox(width: 6),
                            Text(
                              'Synced',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.secondaryText,
                        size: 20,
                      ),
                    ],
                  ),
                  onTap: () => context.push(RouteNames.offlineSync),
                ),
                _SettingsTile(
                  title: 'Language',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'English',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.secondaryText,
                        size: 20,
                      ),
                    ],
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Language settings')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile {
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.title,
    this.trailing,
    this.onTap,
  });
}

class _SettingsGroupCard extends StatelessWidget {
  final List<_SettingsTile> tiles;

  const _SettingsGroupCard({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(tiles.length, (index) {
          final isLast = index == tiles.length - 1;
          final isFirst = index == 0;
          final tile = tiles[index];

          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: tile.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: isFirst ? const Radius.circular(16) : Radius.zero,
                    bottom: isLast ? const Radius.circular(16) : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            tile.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkBlueText,
                            ),
                          ),
                        ),
                        if (tile.trailing != null) ...[
                          tile.trailing!,
                        ] else ...[
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.secondaryText,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),
            ],
          );
        }),
      ),
    );
  }
}
