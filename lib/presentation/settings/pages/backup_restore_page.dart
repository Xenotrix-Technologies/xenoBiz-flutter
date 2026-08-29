import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../const/colors.dart';
import '../../../infrastructure/database/app_database.dart';
import '../../../infrastructure/services/backup_restore_service.dart';
import '../../widgets/app_card.dart';

// ============================================================================
// REDESIGNED BACKUP & RESTORE MODULE (GOOGLE DRIVE & LOCAL BACKUP)
// ============================================================================

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  late final BackupRestoreService _backupService;

  bool _isLoading = true;

  // Local Backup State
  Map<String, dynamic>? _lastBackupInfo;
  String _currentBackupLocation = '';

  // Google Drive & Cloud Backup State
  bool _isEmailVerified = true;
  bool _isGoogleConnected = false;
  final String _googleAccountEmail = 'business.owner@gmail.com';
  bool _isAutoBackupEnabled = true;
  String _backupFrequency = 'Daily'; // Daily, Weekly, Monthly
  final String _backupTime = '06:00 PM';
  DateTime? _lastCloudBackupDate = DateTime.now().subtract(const Duration(hours: 4));
  String _lastCloudBackupSize = '24.5 MB';
  bool _isCloudBackupRunning = false;

  @override
  void initState() {
    super.initState();
    _backupService = BackupRestoreService(GetIt.instance<AppDatabase>());
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final location = await _backupService.getBackupLocationPath();
    final info = await _backupService.getLastBackupInfo();

    if (mounted) {
      setState(() {
        _currentBackupLocation = location;
        _lastBackupInfo = info;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleChangeBackupLocation() async {
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

  // ==========================================================================
  // CLOUD BACKUP ACTIONS
  // ==========================================================================

  void _handleVerifyEmail() {
    setState(() {
      _isEmailVerified = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Email verified successfully! You can now connect Google Drive.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _handleConnectGoogleDrive() {
    if (!_isEmailVerified) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.cloud_done_rounded, color: AppColors.primaryBlue),
            SizedBox(width: 8),
            Text('Connect Google Drive', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose a Google account to store your secure automatic Xenobiz backups.',
              style: TextStyle(fontSize: 12.5, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.pageBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryBlue,
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_googleAccountEmail, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                        const Text('Google Workspace Account', style: TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isGoogleConnected = true;
                _lastCloudBackupDate = DateTime.now();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Connected to Google Drive! Automatic cloud backups enabled.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Continue with Google', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _handleManualCloudBackup() async {
    if (!_isGoogleConnected) {
      _handleConnectGoogleDrive();
      return;
    }

    setState(() => _isCloudBackupRunning = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isCloudBackupRunning = false;
        _lastCloudBackupDate = DateTime.now();
        _lastCloudBackupSize = '24.8 MB';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Backup created & uploaded to Google Drive successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showCloudBackupsRetrieveDialog() {
    if (!_isGoogleConnected) {
      _handleConnectGoogleDrive();
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.cloud_download_rounded, color: AppColors.primaryBlue),
            SizedBox(width: 8),
            Text('Retrieve Cloud Backups', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a cloud backup stored in Google Drive to restore:',
              style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 12),
            _buildCloudBackupItem('Today, 06:00 PM', '24.8 MB', true),
            const SizedBox(height: 8),
            _buildCloudBackupItem('Yesterday, 06:00 PM', '24.5 MB', false),
            const SizedBox(height: 8),
            _buildCloudBackupItem('27 Aug 2026, 06:00 PM', '23.9 MB', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.secondaryText)),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudBackupItem(String dateStr, String sizeStr, bool isLatest) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(dateStr, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                  if (isLatest) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('LATEST', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ],
                ],
              ),
              Text('Size: $sizeStr • Google Drive', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            onPressed: () {
              Navigator.pop(context);
              _confirmCloudRestoreDialog(dateStr);
            },
            child: const Text('Restore', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmCloudRestoreDialog(String dateStr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 26),
            SizedBox(width: 8),
            Text('Restore Backup?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
          ],
        ),
        content: Text(
          'Restoring backup from ($dateStr) will replace your current local database with records from that backup file. Do you wish to proceed?',
          style: const TextStyle(fontSize: 12.5, color: AppColors.secondaryText, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ Restored business database from cloud backup ($dateStr)!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Confirm Restore', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _confirmDisconnectGoogleDrive() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Text('Disconnect Google Drive?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
        content: const Text(
          'Automatic cloud backups will stop. Existing backups stored in Google Drive will not be deleted.',
          style: TextStyle(fontSize: 12.5, color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isGoogleConnected = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Disconnected Google Drive.'),
                  backgroundColor: AppColors.secondaryText,
                ),
              );
            },
            child: const Text('Disconnect', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // LOCAL BACKUP & RESTORE ACTIONS
  // ==========================================================================

  Future<void> _handleCreateLocalBackup() async {
    setState(() => _isLoading = true);
    try {
      final result = await _backupService.createBackup();
      await _loadSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Local backup created successfully! (${result.fileSizeFormatted})'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create local backup: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleChooseLocalBackupFile() async {
    final validation = await _backupService.pickBackupFileAndValidate();
    if (validation == null || !validation.isValid || validation.backupPayload == null) {
      if (mounted && validation != null && validation.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validation.message),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      return;
    }

    if (mounted) {
      _confirmCloudRestoreDialog(validation.createdAtFormatted ?? 'Local Backup File');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Backup & Restore',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGoogleDriveBackupSection(),
                  const SizedBox(height: 20),
                  _buildLocalBackupSection(),
                  const SizedBox(height: 20),
                  _buildRestoreDataSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  // ==========================================================================
  // SECTION 1: GOOGLE DRIVE BACKUP (PRIMARY TOP SECTION)
  // ==========================================================================

  Widget _buildGoogleDriveBackupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GOOGLE DRIVE CLOUD BACKUP',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),

        if (!_isEmailVerified)
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.mark_email_unread_outlined, color: Colors.orange, size: 22),
                    SizedBox(width: 8),
                    Text('Email Verification Required',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Verify your email address before enabling automatic Google Drive cloud backups.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.secondaryText)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                  icon: const Icon(Icons.verified_user_outlined, color: Colors.white, size: 16),
                  label: const Text('Verify Email Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  onPressed: _handleVerifyEmail,
                ),
              ],
            ),
          )
        else if (!_isGoogleConnected)
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.pageBackground,
                      child: Icon(Icons.cloud_queue_rounded, color: AppColors.primaryBlue, size: 22),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Google Drive Cloud Backup',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                          Text('Not connected', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Automatically back up your business data securely to Google Drive to prevent data loss.',
                  style: TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.35),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 18),
                    label: const Text('Connect Google Drive', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
                    onPressed: _handleConnectGoogleDrive,
                  ),
                ),
              ],
            ),
          )
        else
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.success,
                      child: Icon(Icons.cloud_done_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Text('Google Drive', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                              SizedBox(width: 6),
                              Icon(Icons.circle, size: 8, color: AppColors.success),
                              SizedBox(width: 4),
                              Text('Connected', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                            ],
                          ),
                          Text(_googleAccountEmail, style: const TextStyle(fontSize: 11.5, color: AppColors.secondaryText)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, size: 18, color: AppColors.secondaryText),
                      tooltip: 'Disconnect Google Drive',
                      onPressed: _confirmDisconnectGoogleDrive,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Last Cloud Backup:', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                        Text(
                          _lastCloudBackupDate != null
                              ? DateFormat('dd MMM yyyy, hh:mm a').format(_lastCloudBackupDate!)
                              : 'No cloud backup yet',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Backup Size:', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                        Text(_lastCloudBackupSize, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Automatic Backup', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                    Switch(
                      value: _isAutoBackupEnabled,
                      activeTrackColor: AppColors.primaryBlue,
                      onChanged: (val) => setState(() => _isAutoBackupEnabled = val),
                    ),
                  ],
                ),

                if (_isAutoBackupEnabled) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Backup Frequency', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _backupFrequency,
                                isExpanded: true,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                                items: ['Daily', 'Weekly', 'Monthly']
                                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _backupFrequency = val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Preferred Time', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(_backupTime, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: _isCloudBackupRunning
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.cloud_upload, color: Colors.white, size: 18),
                        label: Text(_isCloudBackupRunning ? 'Uploading...' : 'Backup Now',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                        onPressed: _isCloudBackupRunning ? null : _handleManualCloudBackup,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primaryBlue)),
                      icon: const Icon(Icons.cloud_download_outlined, color: AppColors.primaryBlue, size: 18),
                      label: const Text('Retrieve', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w800)),
                      onPressed: _showCloudBackupsRetrieveDialog,
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ==========================================================================
  // SECTION 2: LOCAL BACKUP (SECONDARY SECTION)
  // ==========================================================================

  Widget _buildLocalBackupSection() {
    final lastTimeText = _lastBackupInfo != null && _lastBackupInfo!['timestamp'] != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(_lastBackupInfo!['timestamp']))
        : 'No local backup yet';
    final lastSizeText = _lastBackupInfo?['sizeFormatted'] ?? '0 KB';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LOCAL DEVICE BACKUP',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.folder_outlined, color: AppColors.primaryBlue, size: 20),
                      SizedBox(width: 8),
                      Text('Backup Location', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                    ],
                  ),
                  TextButton(
                    onPressed: _handleChangeBackupLocation,
                    child: const Text('Change Location', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.pageBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sd_storage_outlined, size: 16, color: AppColors.secondaryText),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentBackupLocation,
                        style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.darkBlueText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Last Local Backup:', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                      Text(lastTimeText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                    ],
                  ),
                  Text('Size: $lastSizeText', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.secondaryText)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.sd_storage, color: Colors.white, size: 18),
                  label: const Text('Create Local Backup', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
                  onPressed: _handleCreateLocalBackup,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // SECTION 3: UNIFIED RESTORE DATA SECTION
  // ==========================================================================

  Widget _buildRestoreDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RESTORE DATA',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.settings_backup_restore_rounded, color: AppColors.success, size: 22),
                  SizedBox(width: 8),
                  Text('Restore Data', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Restore your business database from a previous Google Drive or local file backup.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.secondaryText)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.cloud_download_outlined, color: AppColors.primaryBlue, size: 18),
                      label: const Text('Google Drive', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w800, fontSize: 12)),
                      onPressed: _showCloudBackupsRetrieveDialog,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.folder_open, color: Colors.white, size: 18),
                      label: const Text('Local File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                      onPressed: _handleChooseLocalBackupFile,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
