import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.darkBlueText,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        foregroundColor: AppColors.darkBlueText,
        forceMaterialTransparency: true,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BUSINESS GROUP
                _buildGroupHeader('BUSINESS'),
                _buildGroupCard([
                  _SettingsTile(
                    icon: Icons.business_outlined,
                    title: 'Business Settings',
                    subtitle: 'Manage business profile, name, address & logo',
                    onTap: () => context.push(RouteNames.businessProfile),
                  ),
                ]),
                const SizedBox(height: 24),

                // INVOICING GROUP
                _buildGroupHeader('INVOICING'),
                _buildGroupCard([
                  _SettingsTile(
                    icon: Icons.receipt_outlined,
                    title: 'Invoice Settings',
                    subtitle: 'Configure invoice terms, prefixes & print templates',
                    onTap: () => context.push(RouteNames.invoiceSettings),
                  ),
                ]),
                const SizedBox(height: 24),

                // TAXATION GROUP
                _buildGroupHeader('TAXATION'),
                _buildGroupCard([
                  _SettingsTile(
                    icon: Icons.percent_outlined,
                    title: 'Tax Settings',
                    subtitle: 'Configure GSTIN, tax rates & tax rules',
                    onTap: () => context.push(RouteNames.taxGstSettings),
                  ),
                ]),
                const SizedBox(height: 24),

                // APP GROUP
                _buildGroupHeader('APP'),
                _buildGroupCard([
                  _SettingsTile(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notification Settings',
                    subtitle: 'Manage app notifications and reminder alerts',
                    onTap: () => context.push(RouteNames.notificationSettings),
                  ),
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Toggle dark appearance theme',
                    trailing: Switch(
                      value: _isDarkMode,
                      activeColor: const Color(0xFF0066CC),
                      onChanged: (val) {
                        setState(() => _isDarkMode = val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(val ? 'Dark mode enabled' : 'Dark mode disabled'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppColors.secondaryText,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildGroupCard(List<_SettingsTile> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(tiles.length, (index) {
          final isLast = index == tiles.length - 1;
          final tile = tiles[index];

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066CC).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(tile.icon, color: const Color(0xFF0066CC), size: 20),
                ),
                title: Text(
                  tile.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlueText,
                  ),
                ),
                subtitle: Text(
                  tile.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
                trailing: tile.trailing ??
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.secondaryText,
                      size: 20,
                    ),
                onTap: tile.trailing != null ? null : tile.onTap,
              ),
              if (!isLast) const Divider(height: 1, color: AppColors.border),
            ],
          );
        }),
      ),
    );
  }
}

class _SettingsTile {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });
}
