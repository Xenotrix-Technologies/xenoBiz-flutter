import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/bloc/lead_bloc.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/lead_entity.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';

class AddLeadPage extends StatefulWidget {
  final LeadEntity? lead;

  const AddLeadPage({super.key, this.lead});

  @override
  State<AddLeadPage> createState() => _AddLeadPageState();
}

class _AddLeadPageState extends State<AddLeadPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _contactNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _companyNameCtrl;
  late TextEditingController _estimatedValueCtrl;
  late TextEditingController _notesCtrl;

  late String _selectedSource;
  late LeadStage _selectedStage;
  late LeadPriority _selectedPriority;
  bool _showMoreDetails = false;

  final List<String> _sources = [
    'Walk-in',
    'Referral',
    'Website',
    'WhatsApp',
    'Phone',
    'Social Media',
    'Existing Customer',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final l = widget.lead;
    _contactNameCtrl = TextEditingController(text: l?.contactName ?? '');
    _phoneCtrl = TextEditingController(text: l?.phone ?? '');
    _companyNameCtrl = TextEditingController(text: l?.companyName ?? '');
    _estimatedValueCtrl = TextEditingController(text: l != null && l.estimatedValue > 0 ? l.estimatedValue.toStringAsFixed(0) : '');
    _notesCtrl = TextEditingController(text: l?.notes ?? '');

    _selectedSource = l?.source ?? 'Walk-in';
    _selectedStage = l?.stage ?? LeadStage.newLead;
    _selectedPriority = l?.priority ?? LeadPriority.medium;
    _showMoreDetails = widget.lead != null;
  }

  @override
  void dispose() {
    _contactNameCtrl.dispose();
    _phoneCtrl.dispose();
    _companyNameCtrl.dispose();
    _estimatedValueCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _stageLabel(LeadStage s) {
    switch (s) {
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
        return 'Won';
      case LeadStage.lost:
        return 'Lost';
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.lead != null;
    final leadId = widget.lead?.id ?? 'lead_${DateTime.now().millisecondsSinceEpoch}';

    final companyStr = _companyNameCtrl.text.trim();
    final contactStr = _contactNameCtrl.text.trim();
    final titleStr = companyStr.isNotEmpty ? '$companyStr Deal' : '$contactStr Inquiry';

    final leadObj = LeadEntity(
      id: leadId,
      title: widget.lead?.title ?? titleStr,
      contactName: contactStr,
      companyName: companyStr,
      phone: _phoneCtrl.text.trim(),
      whatsapp: _phoneCtrl.text.trim(),
      email: widget.lead?.email ?? '',
      address: widget.lead?.address ?? '',
      source: _selectedSource,
      stage: _selectedStage,
      priority: _selectedPriority,
      estimatedValue: double.tryParse(_estimatedValueCtrl.text) ?? 0.0,
      assignedStaff: widget.lead?.assignedStaff ?? 'Self',
      createdBy: widget.lead?.createdBy ?? 'Admin',
      notes: _notesCtrl.text.trim(),
      createdAt: widget.lead?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (isEdit) {
      context.read<LeadBloc>().add(UpdateLeadEvent(leadObj));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead updated successfully!'), backgroundColor: AppColors.success),
      );
    } else {
      context.read<LeadBloc>().add(CreateLeadEvent(leadObj));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New lead added to CRM pipeline!'), backgroundColor: AppColors.success),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.lead != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Lead' : 'Add New Lead', style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkBlueText,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ESSENTIAL LEAD INFO (3-4 INFO CARDS)
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'QUICK LEAD INFO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondaryText,
                    letterSpacing: 0.6,
                  ),
                ),
              ),

              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 1. Contact Name
                    AppTextField(
                      label: 'Lead Contact Name *',
                      controller: _contactNameCtrl,
                      hint: 'e.g. Rahul Varma',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter contact name' : null,
                    ),
                    const SizedBox(height: 14),

                    // 2. Phone Number
                    AppTextField(
                      label: 'Phone Number *',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      hint: '+91 98471 22334',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter phone number' : null,
                    ),
                    const SizedBox(height: 14),

                    // 3. Company Name
                    AppTextField(
                      label: 'Company / Business Name',
                      controller: _companyNameCtrl,
                      hint: 'e.g. Pinnacle Supermarket',
                    ),
                    const SizedBox(height: 14),

                    // 4. Estimated Deal Value
                    AppTextField(
                      label: 'Estimated Deal Value (₹)',
                      controller: _estimatedValueCtrl,
                      keyboardType: TextInputType.number,
                      hint: '50000',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // OPTIONAL ADDITIONAL DETAILS TOGGLE
              GestureDetector(
                onTap: () => setState(() => _showMoreDetails = !_showMoreDetails),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        _showMoreDetails ? Icons.indeterminate_check_box_outlined : Icons.add_box_outlined,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _showMoreDetails ? 'Hide Additional Details' : 'Add More Details (Stage, Source, Notes)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_showMoreDetails) ...[
                const SizedBox(height: 8),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lead Stage
                      const Text('Lead Stage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondaryText)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<LeadStage>(
                        initialValue: _selectedStage,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                        ),
                        items: LeadStage.values.map((st) => DropdownMenuItem(value: st, child: Text(_stageLabel(st)))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedStage = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      // Lead Source
                      const Text('Lead Source', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondaryText)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSource,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                        ),
                        items: _sources.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSource = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      // Notes
                      AppTextField(
                        label: 'Initial Notes / Customer Remarks',
                        controller: _notesCtrl,
                        hint: 'Add initial requirements or customer remarks...',
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              AppButton(
                text: isEdit ? 'Save Lead Changes' : 'Save Lead to Pipeline',
                icon: Icons.check_circle_rounded,
                onPressed: _onSave,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
