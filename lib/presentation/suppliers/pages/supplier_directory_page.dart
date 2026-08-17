import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../application/bloc/purchase_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/purchase_entity.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';

class SupplierDirectoryPage extends StatelessWidget {
  const SupplierDirectoryPage({super.key});

  void _showAddSupplierDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Add New Supplier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Contact Name',
                hint: 'e.g. Rahul Sharma',
                controller: nameCtrl,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Company Name',
                hint: 'e.g. TechHardware Distributors',
                controller: companyCtrl,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Phone Number',
                hint: 'e.g. +91 98950 12345',
                controller: phoneCtrl,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Address / City',
                hint: 'e.g. Kochi, Kerala',
                controller: addressCtrl,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty || companyCtrl.text.trim().isNotEmpty) {
                final supplier = SupplierEntity(
                  id: '',
                  name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : 'Supplier',
                  companyName: companyCtrl.text.trim().isNotEmpty ? companyCtrl.text.trim() : 'Company',
                  phone: phoneCtrl.text.trim(),
                  email: '',
                  address: addressCtrl.text.trim(),
                  payableBalance: 0.0,
                  createdAt: DateTime.now(),
                );

                context.read<PurchaseBloc>().add(CreateSupplierSubmittedEvent(supplier));
                Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Save Supplier'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Supplier Directory'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddSupplierDialog(context),
        child: const Icon(Icons.person_add_outlined, color: Colors.white),
      ),
      body: BlocBuilder<PurchaseBloc, PurchaseState>(
        builder: (context, state) {
          if (state is PurchaseLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PurchaseErrorState) {
            return Center(
              child: Text(state.message, style: const TextStyle(color: AppColors.error)),
            );
          }

          if (state is PurchaseLoadedState) {
            final suppliers = state.suppliers;

            if (suppliers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.contacts_outlined, size: 64, color: AppColors.outline),
                    const SizedBox(height: 12),
                    const Text('No suppliers listed yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    const Text('Tap + to add your first supplier', style: TextStyle(color: AppColors.outline)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                final supplier = suppliers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AppCard(
                    onTap: () => context.push(RouteNames.supplierDetails),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(supplier.companyName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('${supplier.name} • ${supplier.phone}', style: const TextStyle(color: AppColors.outline, fontSize: 13)),
                            if (supplier.address.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(supplier.address, style: const TextStyle(color: AppColors.outline, fontSize: 12)),
                            ],
                          ],
                        ),
                        Text(
                          '${currencyFormatter.format(supplier.payableBalance)} Due',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: supplier.payableBalance > 0 ? AppColors.error : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
