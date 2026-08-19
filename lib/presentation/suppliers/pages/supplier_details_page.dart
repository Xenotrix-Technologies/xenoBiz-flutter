import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/purchase_entity.dart';
import '../../widgets/app_card.dart';

class SupplierDetailsPage extends StatelessWidget {
  final SupplierEntity? supplier;

  const SupplierDetailsPage({super.key, this.supplier});

  @override
  Widget build(BuildContext context) {
    final sup = supplier ??
        SupplierEntity(
          id: 'sup_demo',
          name: 'TechHardware Contact',
          companyName: 'TechHardware Distributors Ltd',
          phone: '+91 98950 12345',
          email: 'sales@techhardware.in',
          address: 'Kochi, Kerala',
          payableBalance: 42000.0,
          createdAt: DateTime.now(),
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Supplier Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Supplier',
            onPressed: () {
              context.push(RouteNames.createMaster, extra: sup);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sup.companyName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              Text(
                'Contact Person: ${sup.name}',
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                'Phone: ${sup.phone}${sup.email.isNotEmpty ? ' • ${sup.email}' : ''}',
                style: const TextStyle(color: AppColors.outline),
              ),
              if (sup.address.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Address: ${sup.address}',
                  style: const TextStyle(color: AppColors.outline),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Payable Balance: ₹${sup.payableBalance.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: sup.payableBalance > 0 ? AppColors.error : AppColors.success,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

