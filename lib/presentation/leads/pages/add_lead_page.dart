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
  late TextEditingController _emailCtrl;
  late TextEditingController _companyNameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _estimatedValueCtrl;
  late TextEditingController _assignedStaffCtrl;
  late TextEditingController _notesCtrl;

  late String _selectedSource;
  late LeadStage _selectedStage;
  late LeadPriority _selectedPriority;
  DateTime? _expectedClosingDate;
  DateTime? _nextFollowUpDate;
  TimeOfDay? _nextFollowUpTime;

  final List<String> _sources = [
    'Walk-in',
    'Referral',
    'Website',
    'WhatsApp',
    'Phone Inquiry',
    'Social Media',
    'Existing Customer',
    'Other',
  ];

  final List<String> _staffList = [
    'Admin',
    'Self',
    'Sales Rep 1',
    'Sales Rep 2',
    'Field Agent',
  ];

  @override
  void initState() {
    super.initState();
    final l = widget.lead;
    _contactNameCtrl = TextEditingController(text: l?.contactName ?? '');
    _phoneCtrl = TextEditingController(text: l?.phone ?? '');
    _emailCtrl = TextEditingController(text: l?.email ?? '');
    _companyNameCtrl = TextEditingController(text: l?.companyName ?? '');
    _addressCtrl = TextEditingController(text: l?.address ?? '');
    _estimatedValueCtrl = TextEditingController(
        text: l != null && l.estimatedValue > 0
            ? l.estimatedValue.toStringAsFixed(0)
            : '');
    _assignedStaffCtrl =
        TextEditingController(text: l?.assignedStaff ?? 'Self');
    _notesCtrl = TextEditingController(text: l?.notes ?? '');

    _selectedSource = l?.source ?? 'Walk-in';
    _selectedStage = l?.stage ?? LeadStage.newLead;
    _selectedPriority = l?.priority ?? LeadPriority.medium;
    _expectedClosingDate = l?.expectedClosingDate;
    _nextFollowUpDate = l?.nextFollowUpDate;
  }

  @override
  void dispose() {
    _contactNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _companyNameCtrl.dispose();
    _addressCtrl.dispose();
    _estimatedValueCtrl.dispose();
    _assignedStaffCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _stageLabel(LeadStage s) {
    switch (s) {
      case LeadStage.newLead:
        return 'New Lead';
      case LeadStage.contacted:
        return 'Contacted';
      case LeadStage.qualified:
        return 'Qualified';
      case LeadStage.proposalSent:
        return 'Proposal Sent';
      case LeadStage.negotiating:
        return 'Negotiation';
      case LeadStage.won:
        return 'Won';
      case LeadStage.lost:
        return 'Lost';
    }
  }

  Future<void> _pickClosingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expectedClosingDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _expectedClosingDate = picked);
    }
  }

  Future<void> _pickFollowUpDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextFollowUpDate ?? DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _nextFollowUpDate = picked);
    }
  }

  Future<void> _pickFollowUpTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _nextFollowUpTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) {
      setState(() => _nextFollowUpTime = picked);
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
      email: _emailCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      source: _selectedSource,
      stage: _selectedStage,
      priority: _selectedPriority,
      estimatedValue: double.tryParse(_estimatedValueCtrl.text.trim()) ?? 0.0,
      expectedClosingDate: _expectedClosingDate,
      assignedStaff: _assignedStaffCtrl.text.trim().isNotEmpty
          ? _assignedStaffCtrl.text.trim()
          : 'Self',
      createdBy: widget.lead?.createdBy ?? 'Admin',
      notes: _notesCtrl.text.trim(),
      createdAt: widget.lead?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      nextFollowUpDate: _nextFollowUpDate,
      nextFollowUpTime: _nextFollowUpTime?.format(context),
    );

    if (isEdit) {
      context.read<LeadBloc>().add(UpdateLeadEvent(leadObj));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lead updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      context.read<LeadBloc>().add(CreateLeadEvent(leadObj));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_selectedStage == LeadStage.won
              ? 'New lead added & automatically converted to CRM Customer!'
              : 'New lead added to CRM pipeline!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
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
        title: Text(
          isEdit ? 'Edit Lead Details' : 'Add New CRM Lead',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
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
              // SECTION 1: BASIC LEAD INFORMATION
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'BASIC CONTACT DETAILS',
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
                    AppTextField(
                      label: 'Contact Name *',
                      controller: _contactNameCtrl,
                      hint: 'e.g. Rahul Varma',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Please enter contact name' : null,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Company / Business Name',
                      controller: _companyNameCtrl,
                      hint: 'e.g. Pinnacle Supermarket',
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Phone Number *',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      hint: 'e.g. +91 98471 22334',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Please enter phone number' : null,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Email Address',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      hint: 'e.g. rahul@example.com',
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Address / Location',
                      controller: _addressCtrl,
                      hint: 'e.g. MG Road, Kochi',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SECTION 2: LEAD CLASSIFICATION
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'CLASSIFICATION & STAGE',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lead Stage',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryText)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<LeadStage>(
                      initialValue: _selectedStage,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                      items: LeadStage.values
                          .map((st) => DropdownMenuItem(
                              value: st, child: Text(_stageLabel(st))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStage = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    const Text('Lead Source',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryText)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _sources.contains(_selectedSource)
                          ? _selectedSource
                          : _sources.first,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                      items: _sources
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSource = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    const Text('Priority Level',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryText)),
                    const SizedBox(height: 6),
                    SegmentedButton<LeadPriority>(
                      segments: const [
                        ButtonSegment(
                            value: LeadPriority.low, label: Text('Low')),
                        ButtonSegment(
                            value: LeadPriority.medium, label: Text('Medium')),
                        ButtonSegment(
                            value: LeadPriority.high, label: Text('High')),
                      ],
                      selected: {_selectedPriority},
                      onSelectionChanged: (val) {
                        if (val.isNotEmpty) {
                          setState(() => _selectedPriority = val.first);
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SECTION 3: SALES & ESTIMATED DEAL DETAILS
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'SALES OPPORTUNITY',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Estimated Deal Value (₹)',
                      controller: _estimatedValueCtrl,
                      keyboardType: TextInputType.number,
                      hint: 'e.g. 50000',
                    ),
                    const SizedBox(height: 14),

                    const Text('Expected Closing Date',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryText)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickClosingDate,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _expectedClosingDate != null
                                  ? '${_expectedClosingDate!.day}/${_expectedClosingDate!.month}/${_expectedClosingDate!.year}'
                                  : 'Select expected closing date',
                              style: TextStyle(
                                fontSize: 14,
                                color: _expectedClosingDate != null
                                    ? AppColors.darkBlueText
                                    : AppColors.secondaryText,
                              ),
                            ),
                            const Icon(Icons.calendar_month_rounded,
                                size: 20, color: AppColors.primaryBlue),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SECTION 4: CRM MANAGEMENT & FOLLOW-UP
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'CRM & FOLLOW-UP SCHEDULE',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Assigned Sales Representative',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryText)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _staffList.contains(_assignedStaffCtrl.text)
                          ? _assignedStaffCtrl.text
                          : _staffList.first,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                      items: _staffList
                          .map((st) => DropdownMenuItem(value: st, child: Text(st)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _assignedStaffCtrl.text = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Next Follow-up Date',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.secondaryText)),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: _pickFollowUpDate,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _nextFollowUpDate != null
                                            ? '${_nextFollowUpDate!.day}/${_nextFollowUpDate!.month}/${_nextFollowUpDate!.year}'
                                            : 'Set date',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      const Icon(Icons.event,
                                          size: 18, color: AppColors.primaryBlue),
                                    ],
                                  ),
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
                              const Text('Next Follow-up Time',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.secondaryText)),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: _pickFollowUpTime,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _nextFollowUpTime != null
                                            ? _nextFollowUpTime!.format(context)
                                            : 'Set time',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      const Icon(Icons.access_time,
                                          size: 18, color: AppColors.primaryBlue),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    AppTextField(
                      label: 'Initial Notes / Deal Remarks',
                      controller: _notesCtrl,
                      hint: 'Capture customer requirements, preferences or remarks...',
                    ),
                  ],
                ),
              ),

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
