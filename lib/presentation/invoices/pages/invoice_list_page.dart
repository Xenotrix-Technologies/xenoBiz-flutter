import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/invoice_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../const/strings.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/ui_state_widgets.dart';

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.invoiceTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              context.push(RouteNames.salesOverview);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: AppColors.primary,
        onPressed: () {
          context.push(RouteNames.createInvoice);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceCard,
            child: AppTextField(
              label: 'Search Invoices',
              hint: 'Search by invoice number or customer name...',
              controller: _searchController,
              prefixIcon: Icons.search,
              onChanged: (q) {
                context.read<InvoiceBloc>().add(FetchInvoicesEvent(query: q));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<InvoiceBloc, InvoiceState>(
              builder: (context, state) {
                if (state is InvoiceLoadingState) {
                  return const LoadingState(message: 'Loading invoices...');
                }
                if (state is InvoicesLoadedState) {
                  if (state.invoices.isEmpty) {
                    return const EmptyState(
                      title: 'No Invoices Found',
                      message: 'Create your first GST invoice to record sales & track payments.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.invoices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final inv = state.invoices[idx];
                      return AppCard(
                        onTap: () {
                          context.push(RouteNames.invoiceDetails);
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                              child: const Icon(Icons.description, color: AppColors.primary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    inv.invoiceNumber,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    inv.customerName,
                                    style: const TextStyle(fontSize: 13, color: AppColors.outline),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${inv.grandTotal.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                inv.status == InvoiceStatus.paid
                                    ? StatusChip.paid()
                                    : inv.status == InvoiceStatus.partiallyPaid
                                        ? StatusChip.partiallyPaid()
                                        : StatusChip.unpaid(),
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
