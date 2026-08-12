import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/lead_entity.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../../application/bloc/lead_bloc.dart';

class AddLeadPage extends StatefulWidget {
  const AddLeadPage({super.key});

  @override
  State<AddLeadPage> createState() => _AddLeadPageState();
}

class _AddLeadPageState extends State<AddLeadPage> {
  final _titleCtrl = TextEditingController(text: 'POS Hardware Deployment 5 Outlets');
  final _nameCtrl = TextEditingController(text: 'Kiran Nair (Royal Supermarket)');
  final _phoneCtrl = TextEditingController(text: '+91 98471 22334');
  final _emailCtrl = TextEditingController(text: 'kiran@royalsuper.com');
  final _valueCtrl = TextEditingController(text: '85000');

  void _onSaveLead() {
    final newLead = LeadEntity(
      id: 'lead_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text,
      contactName: _nameCtrl.text,
      phone: _phoneCtrl.text,
      email: _emailCtrl.text,
      estimatedValue: double.tryParse(_valueCtrl.text) ?? 50000.0,
      stage: LeadStage.newLead,
      createdAt: DateTime.now(),
    );

    context.read<LeadBloc>().add(CreateLeadEvent(newLead));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New lead added to CRM pipeline!'), backgroundColor: AppColors.success),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add New Lead'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(label: 'Lead Title / Deal Name', controller: _titleCtrl),
            const SizedBox(height: 14),
            AppTextField(label: 'Contact Person', controller: _nameCtrl),
            const SizedBox(height: 14),
            AppTextField(label: 'Phone Number', controller: _phoneCtrl, keyboardType: TextInputType.phone),
            const SizedBox(height: 14),
            AppTextField(label: 'Email Address', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            AppTextField(label: 'Estimated Deal Value (₹)', controller: _valueCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 28),
            AppButton(
              text: 'Save Lead to Pipeline',
              onPressed: _onSaveLead,
            ),
          ],
        ),
      ),
    );
  }
}
