import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class CrmSettingsPage extends StatefulWidget {
  const CrmSettingsPage({super.key});

  @override
  State<CrmSettingsPage> createState() => _CrmSettingsPageState();
}

class _CrmSettingsPageState extends State<CrmSettingsPage> {
  bool _followUpReminders = true;
  bool _crmNotifications = true;
  bool _autoPaymentReminders = true;
  String _defaultLeadPriority = 'Medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'CRM Settings',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: CRM Configuration
            const Text(
              'CRM SETTINGS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBlue,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _followUpReminders,
                    onChanged: (val) => setState(() => _followUpReminders = val),
                    title: const Text(
                      'Follow-up Reminders',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Receive push notifications for scheduled follow-ups',
                      style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    ),
                    activeTrackColor: AppColors.primaryBlue,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Default Lead Priority', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: Text('Default priority assigned to new leads ($_defaultLeadPriority)', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    trailing: DropdownButton<String>(
                      value: _defaultLeadPriority,
                      underline: const SizedBox.shrink(),
                      items: ['High', 'Medium', 'Low']
                          .map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _defaultLeadPriority = val);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: _autoPaymentReminders,
                    onChanged: (val) => setState(() => _autoPaymentReminders = val),
                    title: const Text(
                      'Payment Reminder Automation',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Automatically draft payment reminders for overdue invoices',
                      style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    ),
                    activeTrackColor: AppColors.primaryBlue,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: _crmNotifications,
                    onChanged: (val) => setState(() => _crmNotifications = val),
                    title: const Text(
                      'CRM Digest Notifications',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Daily summary of pending tasks & new customer leads',
                      style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    ),
                    activeTrackColor: AppColors.primaryBlue,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.tune_rounded, color: AppColors.primaryBlue),
                    title: const Text('Automated Reminder Rules', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: const Text('Configure WhatsApp & SMS templates', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(RouteNames.automatedReminders),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Data Management
            const Text(
              'DATA & SYNC',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBlue,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.cloud_upload_outlined, color: AppColors.primaryBlue),
                    title: const Text('Backup & Restore', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: const Text('Create offline backup or restore CRM records', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(RouteNames.backupRestore),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.sync_outlined, color: AppColors.primaryBlue),
                    title: const Text('Offline Sync Center', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: const Text('View pending offline changes and sync status', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(RouteNames.offlineSync),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.file_download_outlined, color: AppColors.success),
                    title: const Text('Export CRM Data', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: const Text('Export customers, leads, and follow-ups as CSV/PDF', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exporting CRM dataset to Downloads...')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: Application Settings
            const Text(
              'APPLICATION & GENERAL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBlue,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.storefront_outlined, color: AppColors.deepNavy),
                    title: const Text('Business Profile', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: const Text('Update company name, logo, contact & tax details', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(RouteNames.businessProfile),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: AppColors.deepNavy),
                    title: const Text('General App Settings', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: const Text('Currency, regional formats & system preferences', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(RouteNames.settings),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded, color: AppColors.deepNavy),
                    title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: const Text('Contact Xenobiz support or view CRM guide', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'XenoBiz CRM Module',
                        applicationVersion: 'v1.0.0',
                        applicationLegalese: '© 2026 XenoBiz Technologies',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
