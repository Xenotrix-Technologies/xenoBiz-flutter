import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/customer_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/strings.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/ui_state_widgets.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const FetchCustomersEvent());
  }

  void _showAddCustomerDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.addCustomer),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(label: 'Full Name', controller: nameCtrl),
            const SizedBox(height: 12),
            AppTextField(label: 'Phone Number', controller: phoneCtrl, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            AppTextField(label: 'Email', controller: emailCtrl, keyboardType: TextInputType.emailAddress),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                final newCust = CustomerEntity(
                  id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text,
                  phone: phoneCtrl.text,
                  email: emailCtrl.text,
                  address: 'Kochi, Kerala',
                  createdAt: DateTime.now(),
                );
                context.read<CustomerBloc>().add(CreateCustomerEvent(newCust));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save Customer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.customerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: AppColors.primary,
        onPressed: _showAddCustomerDialog,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceCard,
            child: AppTextField(
              label: 'Search Customers',
              hint: 'Search by name, phone, or email...',
              controller: _searchController,
              prefixIcon: Icons.search,
              onChanged: (q) {
                context.read<CustomerBloc>().add(FetchCustomersEvent(query: q));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoadingState) {
                  return const LoadingState(message: 'Searching customers...');
                }
                if (state is CustomersLoadedState) {
                  if (state.customers.isEmpty) {
                    return const EmptyState(
                      title: 'No Customers Found',
                      message: 'Add your first customer to start tracking balances and activity history.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.customers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final c = state.customers[idx];
                      return AppCard(
                        onTap: () {
                          context.push(RouteNames.customerDetails);
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.primaryContainer,
                              child: Text(
                                c.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${c.phone} • ${c.email}',
                                    style: const TextStyle(fontSize: 13, color: AppColors.outline),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Due Balance', style: TextStyle(fontSize: 11, color: AppColors.outline)),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${c.outstandingBalance.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: c.outstandingBalance > 0 ? AppColors.error : AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
