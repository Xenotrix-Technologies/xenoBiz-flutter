import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../application/bloc/purchase_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class PurchaseManagementPage extends StatelessWidget {
  const PurchaseManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Purchase Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.contacts),
            tooltip: 'Suppliers Directory',
            onPressed: () {
              context.push(RouteNames.supplierDirectory);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: AppColors.primary,
        onPressed: () {
          context.push(RouteNames.createPurchaseOrder);
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New PO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
            final purchases = state.purchases;

            if (purchases.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.outline),
                    const SizedBox(height: 12),
                    const Text('No purchase orders yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    const Text('Tap + New PO to create your first purchase order', style: TextStyle(color: AppColors.outline)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: purchases.length,
              itemBuilder: (context, index) {
                final po = purchases[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AppCard(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(po.poNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Supplier: ${po.supplierName}', style: const TextStyle(color: AppColors.outline, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(DateFormat('dd MMM yyyy').format(po.orderDate), style: const TextStyle(color: AppColors.outline, fontSize: 12)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormatter.format(po.totalAmount),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                po.status,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                              ),
                            ),
                          ],
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
