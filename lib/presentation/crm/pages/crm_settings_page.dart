import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../domain/repositories/lead_repository.dart';
import '../../../infrastructure/storage/hive_service.dart';
import '../../leads/widgets/export_leads_modal.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';

class CrmSettingsPage extends StatefulWidget {
  const CrmSettingsPage({super.key});

  @override
  State<CrmSettingsPage> createState() => _CrmSettingsPageState();
}

class _CrmSettingsPageState extends State<CrmSettingsPage> {
  late Box _settingsBox;

  String _defaultLeadPriority = 'Medium';
  List<String> _leadSources = [
    'Website',
    'WhatsApp',
    'Phone Inquiry',
    'Referral',
    'Social Media',
    'Walk-in',
    'Other',
  ];

  List<Map<String, dynamic>> _leadStages = [
    {'name': 'New Lead', 'color': 0xFF2563EB, 'desc': 'Initial contact or newly captured lead'},
    {'name': 'Contacted', 'color': 0xFF8B5CF6, 'desc': 'First conversation or response logged'},
    {'name': 'Qualified', 'color': 0xFF6366F1, 'desc': 'Lead meets customer & requirement criteria'},
    {'name': 'Proposal Sent', 'color': 0xFFF59E0B, 'desc': 'Quote or proposal shared with client'},
    {'name': 'Negotiation', 'color': 0xFFD97706, 'desc': 'Discussing terms, pricing, or contract'},
    {'name': 'Won', 'color': 0xFF10B981, 'desc': 'Deal finalized — converted to CRM Customer'},
    {'name': 'Lost', 'color': 0xFFEF4444, 'desc': 'Lead closed without sale'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _settingsBox = Hive.box(HiveService.boxCrmSettings);
    setState(() {
      _defaultLeadPriority = _settingsBox.get('defaultLeadPriority', defaultValue: 'Medium');
      
      final savedSources = _settingsBox.get('leadSources');
      if (savedSources != null && savedSources is List) {
        _leadSources = List<String>.from(savedSources);
      }

      final savedStages = _settingsBox.get('customLeadStages');
      if (savedStages != null && savedStages is List) {
        _leadStages = List<Map<String, dynamic>>.from(
          savedStages.map((item) => Map<String, dynamic>.from(item as Map)),
        );
      }
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  void _showEditStageDialog(int index, VoidCallback onUpdated) {
    final stage = _leadStages[index];
    final nameCtrl = TextEditingController(text: stage['name'] as String);
    final descCtrl = TextEditingController(text: stage['desc'] as String);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit ${stage['name']}', style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Stage Name',
              controller: nameCtrl,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Stage Description',
              controller: descCtrl,
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () {
              final newName = nameCtrl.text.trim();
              final newDesc = descCtrl.text.trim();
              if (newName.isNotEmpty) {
                setState(() {
                  _leadStages[index]['name'] = newName;
                  _leadStages[index]['desc'] = newDesc;
                });
                _saveSetting('customLeadStages', _leadStages);
                onUpdated();
                Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showLeadStagesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CRM Lead Pipeline Stages',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(sheetCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap edit icon to customize stage names and descriptions.',
                    style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _leadStages.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, index) {
                        final stage = _leadStages[index];
                        final color = Color(stage['color'] as int);

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: color.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              'Stage ${index + 1}',
                              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
                            ),
                          ),
                          title: Text(
                            stage['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.darkBlueText),
                          ),
                          subtitle: Text(
                            stage['desc'] as String,
                            style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryBlue, size: 20),
                            tooltip: 'Edit Stage',
                            onPressed: () {
                              _showEditStageDialog(index, () {
                                setSheetState(() {});
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLeadSourcesSheet() {
    final newSourceCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void addSource() {
              final text = newSourceCtrl.text.trim();
              if (text.isNotEmpty && !_leadSources.contains(text)) {
                setState(() {
                  _leadSources.add(text);
                });
                setSheetState(() {});
                _saveSetting('leadSources', _leadSources);
                newSourceCtrl.clear();
              }
            }

            void removeSource(String src) {
              if (_leadSources.length > 1) {
                setState(() {
                  _leadSources.remove(src);
                });
                setSheetState(() {});
                _saveSetting('leadSources', _leadSources);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lead Sources',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Text(
                    'Configure acquisition channels for incoming lead inquiries.',
                    style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'New Lead Source',
                          hint: 'e.g. Exhibition, Cold Call',
                          controller: newSourceCtrl,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onPressed: addSource,
                        child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _leadSources.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, index) {
                        final src = _leadSources[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.label_outline_rounded, color: AppColors.primaryBlue, size: 20),
                          title: Text(
                            src,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.darkBlueText),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red, size: 20),
                            onPressed: () => removeSource(src),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
            // SECTION 1: LEAD MANAGEMENT
            const Text(
              'LEAD MANAGEMENT',
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
                    leading: const Icon(Icons.view_kanban_outlined, color: AppColors.primaryBlue),
                    title: const Text('Lead Stages', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: const Text('View & edit pipeline stages (New -> Won / Lost)', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showLeadStagesSheet,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.alt_route_rounded, color: AppColors.primaryBlue),
                    title: const Text('Lead Sources', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: Text('Manage lead channels (${_leadSources.length} active sources)', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showLeadSourcesSheet,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.flag_outlined, color: AppColors.primaryBlue),
                    title: const Text('Default Lead Priority', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: Text('Priority assigned to new leads ($_defaultLeadPriority)', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    trailing: DropdownButton<String>(
                      value: _defaultLeadPriority,
                      underline: const SizedBox.shrink(),
                      items: ['High', 'Medium', 'Low']
                          .map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _defaultLeadPriority = val);
                          _saveSetting('defaultLeadPriority', val);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SECTION 2: DATA
            const Text(
              'DATA',
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
                    leading: const Icon(Icons.file_download_outlined, color: AppColors.success),
                    title: const Text('Export Leads', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: const Text('Export CRM leads as Excel spreadsheet or PDF document', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final allLeads = await getIt<LeadRepository>().getLeads();
                      if (context.mounted) {
                        ExportLeadsModal.show(
                          context: context,
                          allLeads: allLeads,
                          filteredLeads: allLeads,
                          filterSummary: 'All Leads',
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cloud_download_outlined, color: AppColors.primaryBlue),
                    title: const Text('Export CRM Data', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: const Text('Export full CRM records (Customers, Leads, Notes & Activities)', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final allLeads = await getIt<LeadRepository>().getLeads();
                      if (context.mounted) {
                        ExportLeadsModal.show(
                          context: context,
                          allLeads: allLeads,
                          filteredLeads: allLeads,
                          filterSummary: 'Full CRM Data Backup',
                        );
                      }
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
