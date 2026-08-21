import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/crm_customer_entity.dart';
import '../../../domain/repositories/crm_customer_repository.dart';
import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

Future<CrmCustomerEntity?> showAddCrmCustomerDialog(BuildContext context) async {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final companyController = TextEditingController();
  final notesController = TextEditingController();

  String selectedSource = 'Walk-in';
  String selectedStatus = 'Active';
  bool isSaving = false;

  final sources = ['Walk-in', 'Referral', 'Website', 'Cold Call', 'Social Media', 'Other'];
  final statuses = ['Active', 'Lead', 'Contacted', 'Inactive'];

  final formKey = GlobalKey<FormState>();

  return showDialog<CrmCustomerEntity>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add CRM Customer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlueText,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: nameController,
                      label: 'Customer Name *',
                      hint: 'e.g. Rahul Sharma',
                      validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: phoneController,
                      label: 'Phone Number *',
                      hint: 'e.g. 9876543210',
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Phone is required' : null,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: emailController,
                      label: 'Email',
                      hint: 'e.g. rahul@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: companyController,
                      label: 'Company Name',
                      hint: 'e.g. Acme Solutions',
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSource,
                      decoration: const InputDecoration(
                        labelText: 'Lead Source',
                        border: OutlineInputBorder(),
                      ),
                      items: sources.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedSource = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Customer Status',
                        border: OutlineInputBorder(),
                      ),
                      items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedStatus = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: notesController,
                      label: 'Notes / Remarks',
                      hint: 'Optional notes about interaction...',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Cancel',
                            variant: AppButtonVariant.outline,
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            text: isSaving ? 'Saving...' : 'Save Customer',
                            onPressed: isSaving
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate()) return;
                                    setState(() => isSaving = true);
                                    try {
                                      final newCrmCustomer = CrmCustomerEntity(
                                        id: 'CRM-${const Uuid().v4().substring(0, 8)}',
                                        name: nameController.text.trim(),
                                        phone: phoneController.text.trim(),
                                        email: emailController.text.trim(),
                                        companyName: companyController.text.trim(),
                                        source: selectedSource,
                                        status: selectedStatus,
                                        notes: notesController.text.trim(),
                                        createdAt: DateTime.now(),
                                      );

                                      final created = await getIt<CrmCustomerRepository>()
                                          .createCrmCustomer(newCrmCustomer);

                                      if (ctx.mounted) {
                                        Navigator.pop(ctx, created);
                                      }
                                    } catch (e) {
                                      setState(() => isSaving = false);
                                      if (ctx.mounted) {
                                        ScaffoldMessenger.of(ctx).showSnackBar(
                                          SnackBar(content: Text('Failed to save CRM customer: $e')),
                                        );
                                      }
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
