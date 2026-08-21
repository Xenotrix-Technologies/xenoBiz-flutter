import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../../application/bloc/lead_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/lead_entity.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

class LeadDetailsPage extends StatefulWidget {
  final LeadEntity? lead;

  const LeadDetailsPage({super.key, this.lead});

  @override
  State<LeadDetailsPage> createState() => _LeadDetailsPageState();
}

class _LeadDetailsPageState extends State<LeadDetailsPage> {
  late String _leadId;

  @override
  void initState() {
    super.initState();
    _leadId = widget.lead?.id ?? 'lead_101';
    _loadDetails();
  }

  void _loadDetails() {
    context.read<LeadBloc>().add(FetchLeadDetailsEvent(_leadId));
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) return;
    final Uri uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch phone dialer for $phoneNumber')),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String whatsappNumber) async {
    final cleanPhone = whatsappNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.isEmpty) return;
    final Uri uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open WhatsApp for $whatsappNumber')),
        );
      }
    }
  }

  Color _getStageColor(LeadStage stage) {
    switch (stage) {
      case LeadStage.newLead:
        return const Color(0xFF2563EB);
      case LeadStage.contacted:
        return const Color(0xFF0284C7);
      case LeadStage.qualified:
        return const Color(0xFF0D9488);
      case LeadStage.proposalSent:
        return const Color(0xFF8B5CF6);
      case LeadStage.negotiating:
        return const Color(0xFFD97706);
      case LeadStage.won:
        return const Color(0xFF10B981);
      case LeadStage.lost:
        return const Color(0xFFEF4444);
    }
  }

  String _getStageName(LeadStage stage) {
    switch (stage) {
      case LeadStage.newLead:
        return 'New';
      case LeadStage.contacted:
        return 'Contacted';
      case LeadStage.qualified:
        return 'Qualified';
      case LeadStage.proposalSent:
        return 'Proposal';
      case LeadStage.negotiating:
        return 'Negotiation';
      case LeadStage.won:
        return 'Won 🎉';
      case LeadStage.lost:
        return 'Lost';
    }
  }

  Color _getPriorityColor(LeadPriority priority) {
    switch (priority) {
      case LeadPriority.high:
        return const Color(0xFFEF4444);
      case LeadPriority.medium:
        return const Color(0xFFF59E0B);
      case LeadPriority.low:
        return const Color(0xFF10B981);
    }
  }

  void _onStageSelected(LeadStage stage, LeadEntity currentLead) {
    if (stage == currentLead.stage) return;

    if (stage == LeadStage.lost) {
      _showLostReasonDialog(currentLead);
    } else {
      context.read<LeadBloc>().add(UpdateLeadStageEvent(
            leadId: currentLead.id,
            stage: stage,
          ));

      if (stage == LeadStage.won) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Lead marked as WON! Automatically converted to CRM Customer.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showLostReasonDialog(LeadEntity currentLead) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mark Lead as Lost', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Optionally provide a reason why this lead was lost:', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. Price too high, chose competitor',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LeadBloc>().add(UpdateLeadStageEvent(
                    leadId: currentLead.id,
                    stage: LeadStage.lost,
                    lostReason: reasonCtrl.text.trim(),
                  ));
            },
            child: const Text('Confirm Lost', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddFollowUpDialog(LeadEntity currentLead) {
    final typeCtrl = ValueNotifier<String>('Call');
    final dateVal = ValueNotifier<DateTime>(DateTime.now().add(const Duration(days: 1)));
    final timeVal = ValueNotifier<TimeOfDay>(const TimeOfDay(hour: 10, minute: 0));
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Schedule Follow-up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.darkBlueText)),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Follow-up Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondaryText)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: typeCtrl.value,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: ['Call', 'WhatsApp', 'Meeting', 'Visit', 'Payment', 'General'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => typeCtrl.value = val);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final p = await showDatePicker(context: context, initialDate: dateVal.value, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                          if (p != null) setModalState(() => dateVal.value = p);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [const Icon(Icons.event, size: 16, color: AppColors.primaryBlue), const SizedBox(width: 6), Text('${dateVal.value.day}/${dateVal.value.month}/${dateVal.value.year}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final t = await showTimePicker(context: context, initialTime: timeVal.value);
                          if (t != null) setModalState(() => timeVal.value = t);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [const Icon(Icons.access_time, size: 16, color: AppColors.primaryBlue), const SizedBox(width: 6), Text(timeVal.value.format(context), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))]),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Follow-up Agenda / Notes', hintText: 'e.g. Discuss proposal discounts', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: 'Save Follow-up',
                  icon: Icons.check,
                  onPressed: () {
                    final hourStr = timeVal.value.hourOfPeriod == 0 ? 12 : timeVal.value.hourOfPeriod;
                    final periodStr = timeVal.value.period == DayPeriod.am ? 'AM' : 'PM';
                    final minStr = timeVal.value.minute.toString().padLeft(2, '0');

                    final fup = LeadFollowUpEntity(
                      id: 'fup_${const Uuid().v4()}',
                      leadId: currentLead.id,
                      leadTitle: currentLead.title,
                      contactName: currentLead.contactName,
                      type: typeCtrl.value.toUpperCase(),
                      dueDate: dateVal.value,
                      dueTime: '$hourStr:$minStr $periodStr',
                      notes: notesCtrl.text.trim(),
                      assignedStaff: currentLead.assignedStaff,
                      createdAt: DateTime.now(),
                    );

                    context.read<LeadBloc>().add(AddLeadFollowUpEvent(fup));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Follow-up scheduled successfully!'), backgroundColor: AppColors.success),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddNoteDialog(LeadEntity currentLead) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Lead Note', style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: noteCtrl,
          decoration: const InputDecoration(
            hintText: 'Enter note content or call remarks...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () {
              if (noteCtrl.text.trim().isNotEmpty) {
                context.read<LeadBloc>().add(AddLeadNoteEvent(
                      leadId: currentLead.id,
                      content: noteCtrl.text.trim(),
                    ));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save Note', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteLeadDialog(LeadEntity currentLead) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Lead', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
          'Are you sure you want to delete "${currentLead.contactName}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LeadBloc>().add(DeleteLeadEvent(currentLead.id));
              if (mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lead deleted successfully'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loadedState = context.watch<LeadBloc>().state is LeadsLoadedState
        ? context.watch<LeadBloc>().state as LeadsLoadedState
        : null;
    final currentLead = loadedState?.selectedLead ?? widget.lead;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lead Details', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkBlueText,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (currentLead != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              tooltip: 'Delete Lead',
              onPressed: () => _showDeleteLeadDialog(currentLead),
            ),
        ],
      ),
      body: BlocBuilder<LeadBloc, LeadState>(
        builder: (context, state) {
          if (state is LeadLoadingState) {
            return const LeadDetailsSkeleton();
          }

          final loadedState = state is LeadsLoadedState ? state : null;
          final lead = loadedState?.selectedLead ?? widget.lead;

          if (lead == null) {
            return const Center(child: Text('Lead details not found.'));
          }

          final activities = loadedState?.activities ?? [];
          final notes = loadedState?.notes ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. LEAD NAME & QUICK CONTACT ACTION HEADER (#8)
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lead.contactName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.darkBlueText,
                                  ),
                                ),
                                if (lead.companyName.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    lead.companyName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStageColor(lead.stage).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getStageColor(lead.stage)),
                            ),
                            child: Text(
                              _getStageName(lead.stage),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _getStageColor(lead.stage),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      // PROMINENT QUICK ACTIONS: CALL, WHATSAPP, EDIT (#8)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.call_rounded, size: 18),
                              label: const Text('Call', style: TextStyle(fontWeight: FontWeight.w800)),
                              onPressed: () => _makePhoneCall(lead.phone),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                              label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.w800)),
                              onPressed: () => _openWhatsApp(lead.whatsapp.isNotEmpty ? lead.whatsapp : lead.phone),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryBlue,
                                side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.edit_rounded, size: 18),
                              label: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w800)),
                              onPressed: () {
                                context.push(RouteNames.addLead, extra: lead);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. LEAD STAGE MANAGEMENT PIPELINE (#13)
                _buildSectionTitle('LEAD STAGE PIPELINE'),
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: LeadStage.values.map((st) {
                        final isSelected = lead.stage == st;
                        final color = _getStageColor(st);
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(_getStageName(st)),
                            selected: isSelected,
                            selectedColor: color,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : color,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 12,
                            ),
                            backgroundColor: color.withValues(alpha: 0.1),
                            onSelected: (_) => _onStageSelected(st, lead),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 3. OVERVIEW SUMMARY CARD (#9)
                _buildSectionTitle('OVERVIEW'),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.phone_rounded, 'Phone', lead.phone),
                      if (lead.whatsapp.isNotEmpty) _buildDetailRow(Icons.chat_rounded, 'WhatsApp', lead.whatsapp),
                      if (lead.email.isNotEmpty) _buildDetailRow(Icons.email_rounded, 'Email', lead.email),
                      if (lead.address.isNotEmpty) _buildDetailRow(Icons.location_on_rounded, 'Address', lead.address),
                      _buildDetailRow(Icons.campaign_rounded, 'Lead Source', lead.source),
                      _buildDetailRow(Icons.flag_rounded, 'Priority', lead.priority.name.toUpperCase(), valueColor: _getPriorityColor(lead.priority)),
                      if (lead.expectedClosingDate != null)
                        _buildDetailRow(Icons.event_available_rounded, 'Expected Closing', '${lead.expectedClosingDate!.day}/${lead.expectedClosingDate!.month}/${lead.expectedClosingDate!.year}'),
                      _buildDetailRow(Icons.person_outline_rounded, 'Assigned Staff', lead.assignedStaff),
                      _buildDetailRow(Icons.calendar_month_rounded, 'Created Date', '${lead.createdAt.day}/${lead.createdAt.month}/${lead.createdAt.year}'),
                      if (lead.lostReason != null && lead.lostReason!.isNotEmpty)
                        _buildDetailRow(Icons.cancel_outlined, 'Lost Reason', lead.lostReason!, valueColor: const Color(0xFFEF4444)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. NEXT FOLLOW-UP CARD (#11)
                _buildSectionTitle('NEXT FOLLOW-UP'),
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.event_note_rounded, color: AppColors.primaryBlue, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.nextFollowUpDate != null
                                  ? '${lead.nextFollowUpDate!.day}/${lead.nextFollowUpDate!.month}/${lead.nextFollowUpDate!.year} ${lead.nextFollowUpTime ?? ""}'
                                  : 'No upcoming follow-up',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkBlueText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lead.nextFollowUpNotes?.isNotEmpty == true ? lead.nextFollowUpNotes! : 'Tap "+ Add Follow-up" to schedule',
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Follow-up', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                        onPressed: () => _showAddFollowUpDialog(lead),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 5. ACTIVITIES TIMELINE SECTION (#10)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('ACTIVITIES TIMELINE'),
                    TextButton.icon(
                      icon: const Icon(Icons.add_alarm_rounded, size: 16),
                      label: const Text('+ Follow-up', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                      onPressed: () => _showAddFollowUpDialog(lead),
                    ),
                  ],
                ),
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: activities.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: Text('No activities recorded yet.', style: TextStyle(fontSize: 13, color: AppColors.secondaryText))),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activities.length,
                          separatorBuilder: (_, __) => const Divider(height: 16),
                          itemBuilder: (ctx, idx) {
                            final act = activities[idx];
                            return _buildActivityItem(act);
                          },
                        ),
                ),

                const SizedBox(height: 16),

                // 6. NOTES SECTION (#12)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('LEAD NOTES'),
                    TextButton.icon(
                      icon: const Icon(Icons.note_add_rounded, size: 16),
                      label: const Text('+ Note', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                      onPressed: () => _showAddNoteDialog(lead),
                    ),
                  ],
                ),
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: notes.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: Text('No notes added for this lead yet.', style: TextStyle(fontSize: 13, color: AppColors.secondaryText))),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: notes.length,
                          separatorBuilder: (_, __) => const Divider(height: 16),
                          itemBuilder: (ctx, idx) {
                            final note = notes[idx];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      note.createdBy,
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primaryBlue),
                                    ),
                                    Text(
                                      '${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  note.content,
                                  style: const TextStyle(fontSize: 13, color: AppColors.darkBlueText, fontWeight: FontWeight.w500),
                                ),
                              ],
                            );
                          },
                        ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.secondaryText,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.secondaryText),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.secondaryText, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.darkBlueText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(LeadActivityEntity act) {
    IconData icon;
    Color color;

    switch (act.eventType) {
      case 'CREATED':
        icon = Icons.add_circle_outline_rounded;
        color = AppColors.primaryBlue;
        break;
      case 'STAGE_CHANGED':
        icon = Icons.alt_route_rounded;
        color = const Color(0xFF8B5CF6);
        break;
      case 'NOTE_ADDED':
        icon = Icons.note_alt_outlined;
        color = const Color(0xFF0D9488);
        break;
      case 'FOLLOWUP_SCHEDULED':
      case 'FOLLOWUP_COMPLETED':
        icon = Icons.event_available_rounded;
        color = const Color(0xFFF59E0B);
        break;
      default:
        icon = Icons.history_toggle_off_rounded;
        color = AppColors.deepNavy;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                act.title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
              ),
              const SizedBox(height: 2),
              Text(
                act.description,
                style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
        Text(
          '${act.timestamp.day}/${act.timestamp.month} ${act.timestamp.hour}:${act.timestamp.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 10, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
