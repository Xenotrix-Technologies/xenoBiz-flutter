import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/bloc/lead_bloc.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/lead_entity.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

Future<void> showQuickAddLeadDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (ctx) => const QuickAddLeadDialog(),
  );
}

class QuickAddLeadDialog extends StatefulWidget {
  const QuickAddLeadDialog({super.key});

  @override
  State<QuickAddLeadDialog> createState() => _QuickAddLeadDialogState();
}

class _QuickAddLeadDialogState extends State<QuickAddLeadDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _companyCtrl = TextEditingController();
  final TextEditingController _valueCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _companyCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final company = _companyCtrl.text.trim();
    final value = double.tryParse(_valueCtrl.text.trim()) ?? 0.0;

    final leadId = 'lead_${DateTime.now().millisecondsSinceEpoch}';
    final title = company.isNotEmpty ? '$company Deal' : '$name Inquiry';

    final lead = LeadEntity(
      id: leadId,
      title: title,
      contactName: name,
      companyName: company,
      phone: phone,
      whatsapp: phone,
      source: 'Quick Action',
      stage: LeadStage.newLead,
      priority: LeadPriority.medium,
      estimatedValue: value,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<LeadBloc>().add(CreateLeadEvent(lead));

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quick lead "$name" added to CRM!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.blueTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.flash_on_rounded,
              color: AppColors.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Add Lead',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlueText,
                  ),
                ),
                Text(
                  'Quickly capture lead details',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Contact Name *',
                controller: _nameCtrl,
                hint: 'e.g. Rahul Varma',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter contact name' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Phone Number *',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                hint: 'e.g. +91 98471 22334',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Company Name (Optional)',
                controller: _companyCtrl,
                hint: 'e.g. Pinnacle Ltd',
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Estimated Deal Value (₹)',
                controller: _valueCtrl,
                keyboardType: TextInputType.number,
                hint: 'e.g. 50000',
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                text: 'Save Lead',
                onPressed: _onSave,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
