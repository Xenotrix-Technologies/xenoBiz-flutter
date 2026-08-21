import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/bloc/crm_customer_bloc.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/crm_customer_entity.dart';
import '../../../infrastructure/services/crm_service.dart';
import '../../widgets/app_card.dart';
import '../widgets/add_crm_customer_dialog.dart';

class CrmCustomerDetailsPage extends StatelessWidget {
  final CrmCustomerEntity customer;

  const CrmCustomerDetailsPage({
    super.key,
    required this.customer,
  });

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'C';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'C';
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete CRM Customer',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
        ),
        content: Text(
          'Are you sure you want to delete "${customer.name}"? This action cannot be undone.',
          style: const TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              context.read<CrmCustomerBloc>().add(DeleteCrmCustomerEvent(customer.id));
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Return to directory list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Customer "${customer.name}" deleted.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(customer.name);
    Color statusColor = AppColors.primaryBlue;
    final st = customer.status.toLowerCase();
    if (st == 'active') statusColor = AppColors.success;
    if (st == 'lead') statusColor = const Color(0xFF8B5CF6);
    if (st == 'contacted') statusColor = const Color(0xFFD97706);
    if (st == 'inactive') statusColor = AppColors.secondaryText;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Customer Details'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Customer',
            onPressed: () async {
              final updated = await showAddCrmCustomerDialog(context);
              if (updated != null && context.mounted) {
                context.read<CrmCustomerBloc>().add(UpdateCrmCustomerEvent(updated));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete Customer',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Profile Card
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: statusColor.withValues(alpha: 0.14),
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    customer.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlueText,
                    ),
                  ),
                  if (customer.companyName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      customer.companyName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      customer.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ),

                  // Contact Action Buttons Bar
                  if (customer.phone.isNotEmpty || customer.email.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (customer.phone.isNotEmpty) ...[
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => CrmService.makePhoneCall(customer.phone),
                              icon: const Icon(Icons.phone_rounded, size: 18),
                              label: const Text(
                                'Call',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF128C7E),
                                side: const BorderSide(color: Color(0xFF25D366)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => CrmService.openWhatsApp(
                                customer.phone,
                                text: 'Hello ${customer.name}, following up from XenoBiz CRM.',
                              ),
                              icon: const Icon(Icons.send_rounded, size: 18),
                              label: const Text(
                                'WhatsApp',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Contact Information Card
            const Text(
              'CONTACT INFORMATION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryText,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone Number',
                    value: customer.phone.isNotEmpty ? customer.phone : 'Not provided',
                  ),
                  const Divider(height: 20),
                  _DetailRow(
                    icon: Icons.email_outlined,
                    label: 'Email Address',
                    value: customer.email.isNotEmpty ? customer.email : 'Not provided',
                  ),
                  const Divider(height: 20),
                  _DetailRow(
                    icon: Icons.business_outlined,
                    label: 'Company Name',
                    value: customer.companyName.isNotEmpty ? customer.companyName : 'Not provided',
                  ),
                  const Divider(height: 20),
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: customer.address.isNotEmpty ? customer.address : 'Not provided',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. CRM Relationship Details
            const Text(
              'RELATIONSHIP DETAILS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryText,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.source_outlined,
                    label: 'Lead Source',
                    value: customer.source.isNotEmpty ? customer.source : 'Direct',
                  ),
                  const Divider(height: 20),
                  _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Assigned Staff',
                    value: customer.assignedStaff.isNotEmpty ? customer.assignedStaff : 'Unassigned',
                  ),
                  const Divider(height: 20),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Created Date',
                    value: '${customer.createdAt.day}/${customer.createdAt.month}/${customer.createdAt.year}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Notes & Remarks Card
            if (customer.notes.isNotEmpty) ...[
              const Text(
                'NOTES & REMARKS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondaryText,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Text(
                  customer.notes,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.darkBlueText,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlueText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
