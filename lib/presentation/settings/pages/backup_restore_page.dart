import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/accounts_bloc.dart';
import '../../../application/bloc/customer_bloc.dart';
import '../../../application/bloc/invoice_bloc.dart';
import '../../../application/bloc/product_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../infrastructure/services/backup_restore_service.dart';
import '../../../infrastructure/storage/hive_service.dart';
import '../../widgets/app_card.dart';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  late final BackupRestoreService _backupService;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  Map<String, dynamic>? _lastBackupInfo;
  String _currentBackupLocation = '';

  @override
  void initState() {
    super.initState();
    _backupService = BackupRestoreService(getIt<HiveService>());
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final location = await _backupService.getBackupLocationPath();
    final info = _backupService.getLastBackupInfo();
    if (mounted) {
      setState(() {
        _currentBackupLocation = location;
        _lastBackupInfo = info;
      });
    }
  }

  Future<void> _handleChangeLocation() async {
    final selected = await _backupService.pickBackupDirectory();
    if (selected != null && mounted) {
      setState(() {
        _currentBackupLocation = selected;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup location updated: $selected'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _handleCreateBackup() async {
    setState(() => _isBackingUp = true);

    try {
      final result = await _backupService.createBackup();
      setState(() => _isBackingUp = false);

      if (!mounted) return;

      if (result.success && result.file != null) {
        _loadInitialData();
        _showBackupCreatedDialog(result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      setState(() => _isBackingUp = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup error: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _showBackupCreatedDialog(BackupResult result) {
    final fileName = result.file!.path.split('/').last.split('\\').last;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            SizedBox(width: 10),
            Text('Backup Created', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your business data has been prepared successfully.',
              style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.blueTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('File: $fileName', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                  const SizedBox(height: 4),
                  Text('Backup size: ${result.fileSizeFormatted}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkBlueText)),
                  const SizedBox(height: 2),
                  Text('Total Records: ${result.totalRecords}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Close'),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              if (result.file != null) {
                await _backupService.shareBackupFile(result.file!);
              }
            },
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text('Share Backup'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final saved = await _backupService.saveBackupToDevice(backupFile: result.file);
              if (!mounted) return;
              if (saved != null) {
                _loadInitialData();
                _showBackupSavedSnackBar(saved.path);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to save backup to storage location.'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            icon: const Icon(Icons.sd_storage_rounded, size: 18),
            label: const Text('Save to Device'),
          ),
        ],
      ),
    );
  }

  void _showBackupSavedSnackBar(String savedPath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Backup saved successfully', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 2),
            Text(savedPath, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _handleChooseBackupFile() async {
    final validation = await _backupService.pickBackupFileAndValidate();
    if (validation == null) return;

    if (!validation.isValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validation.message),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (confirmCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28),
            SizedBox(width: 10),
            Text('Confirm Restore', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ Restoring this backup will replace your current local data with records from the selected file.',
              style: TextStyle(fontSize: 13, color: AppColors.darkBlueText, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (validation.selectedFile != null)
                    Text('File: ${validation.selectedFile!.path.split('/').last.split('\\').last}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Backup Date: ${validation.createdAtFormatted}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  ...validation.summaryCounts.entries.take(5).map((e) {
                    final cleanName = e.key.replaceAll('_box', '').toUpperCase();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text('• $cleanName: ${e.value} items', style: const TextStyle(fontSize: 11, color: AppColors.darkBlueText)),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(confirmCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(confirmCtx);
              if (validation.backupPayload != null) {
                _executeRestore(validation.backupPayload!);
              }
            },
            child: const Text('Confirm & Restore'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeRestore(Map<String, dynamic> payload) async {
    setState(() => _isRestoring = true);

    try {
      final result = await _backupService.restoreFromPayload(payload);
      setState(() => _isRestoring = false);

      if (!mounted) return;

      if (result.success) {
        context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
        context.read<ProductBloc>().add(const FetchProductsEvent());
        context.read<CustomerBloc>().add(const FetchCustomersEvent());
        context.read<AccountsBloc>().add(const FetchAccountsEvent());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      setState(() => _isRestoring = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore error: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  String _formatLastBackupTime(String? isoString) {
    if (isoString == null) return 'No backup created yet';
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastTime = _lastBackupTimeText();
    final lastSize = _lastBackupInfo?['sizeFormatted'] ?? '';
    final lastRecords = _lastBackupInfo?['totalRecords'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Backup & Restore',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. BANNER CARD
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_sync_outlined, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Protect Your Business Data',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Create offline backups of products, customers, invoices, and settings. Restore easily whenever needed.',
                              style: TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. BACKUP LOCATION CARD
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.deepNavy.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.folder_open_rounded, color: AppColors.deepNavy, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Backup Location',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Configured storage folder for automatic backups.',
                                  style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.folder_special_rounded, size: 18, color: AppColors.primaryBlue),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _currentBackupLocation.isEmpty ? 'Loading location...' : _currentBackupLocation,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkBlueText),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                            side: const BorderSide(color: AppColors.primaryBlue, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _handleChangeLocation,
                          icon: const Icon(Icons.edit_location_alt_outlined, size: 16),
                          label: const Text('Change Location', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. BACKUP DATA CARD
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.cloud_upload_rounded, color: AppColors.primaryBlue, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Backup Data',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Create a backup of your local business records.',
                                  style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Last Backup Metadata
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.blueTint,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.history_rounded, size: 18, color: AppColors.primaryBlue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Last Backup:', style: TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(
                                    lastTime,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                                  ),
                                  if (lastSize.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text('$lastSize • $lastRecords total records', style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue, fontWeight: FontWeight.w700)),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _isBackingUp ? null : _handleCreateBackup,
                          icon: const Icon(Icons.backup_outlined, size: 20),
                          label: const Text('Create Backup', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4. RESTORE CARD
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.settings_backup_restore_rounded, color: AppColors.success, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Restore Data',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Restore your business data from a previous backup file.',
                                  style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                            side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _isRestoring ? null : _handleChooseBackupFile,
                          icon: const Icon(Icons.file_open_outlined, size: 20),
                          label: const Text('Choose Backup File', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 5. DATA INCLUDED SUMMARY
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Included in Backup',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _DataChip('Products & Stock'),
                          _DataChip('Customers'),
                          _DataChip('Invoices & Sales'),
                          _DataChip('Expenses'),
                          _DataChip('Payments'),
                          _DataChip('Suppliers'),
                          _DataChip('Leads'),
                          _DataChip('Categories'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          if (_isBackingUp || _isRestoring)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primaryBlue),
                    const SizedBox(height: 16),
                    Text(
                      _isBackingUp ? 'Creating backup file...' : 'Restoring business data...',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _lastBackupTimeText() {
    if (_lastBackupInfo == null) return 'No backup created yet';
    return _formatLastBackupTime(_lastBackupInfo!['timestamp']?.toString());
  }
}

class _DataChip extends StatelessWidget {
  final String label;
  const _DataChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkBlueText)),
        ],
      ),
    );
  }
}
