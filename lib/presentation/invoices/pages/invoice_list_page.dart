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
  final InvoiceType? initialType;

  const InvoiceListPage({super.key, this.initialType});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  final _searchController = TextEditingController();
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    if (widget.initialType == InvoiceType.purchase) {
      _selectedFilter = 'PURCHASE';
    } else if (widget.initialType == InvoiceType.sale) {
      _selectedFilter = 'SALE';
    } else {
      _selectedFilter = 'ALL';
    }
    context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_selectedFilter == 'PURCHASE' ? 'Purchase Invoices' : AppStrings.invoiceTitle),
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
        onPressed: () async {
          final type = _selectedFilter == 'PURCHASE' ? InvoiceType.purchase : InvoiceType.sale;
          final bloc = context.read<InvoiceBloc>();
          await context.push(RouteNames.createInvoice, extra: {'invoiceType': type});
          if (!mounted) return;
          bloc.add(const FetchInvoicesEvent());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceCard,
            child: Column(
              children: [
                AppTextField(
                  label: 'Search Invoices',
                  hint: 'Search by invoice number or party name...',
                  controller: _searchController,
                  prefixIcon: Icons.search,
                  onChanged: (q) {
                    context.read<InvoiceBloc>().add(FetchInvoicesEvent(query: q));
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _filterChip('ALL', 'All Invoices'),
                    const SizedBox(width: 8),
                    _filterChip('SALE', 'Sales'),
                    const SizedBox(width: 8),
                    _filterChip('PURCHASE', 'Purchases'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<InvoiceBloc, InvoiceState>(
              builder: (context, state) {
                if (state is InvoiceLoadingState) {
                  return const LoadingState(message: 'Loading invoices...');
                }
                if (state is InvoicesLoadedState) {
                  var filtered = state.invoices;
                  if (_selectedFilter == 'SALE') {
                    filtered = filtered.where((i) => i.isSale).toList();
                  } else if (_selectedFilter == 'PURCHASE') {
                    filtered = filtered.where((i) => i.isPurchase).toList();
                  }

                  if (filtered.isEmpty) {
                    return const EmptyState(
                      title: 'No Invoices Found',
                      message: 'No invoices match your selected filter.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final inv = filtered[idx];
                      return AppCard(
                        onTap: () async {
                          final bloc = context.read<InvoiceBloc>();
                          await context.push(
                            RouteNames.createInvoice,
                            extra: {
                              'invoiceType': inv.type,
                              'invoiceToEdit': inv,
                            },
                          );
                          if (!mounted) return;
                          bloc.add(const FetchInvoicesEvent());
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: inv.isPurchase
                                    ? AppColors.warning.withValues(alpha: 0.1)
                                    : AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                              child: Icon(
                                inv.isPurchase ? Icons.shopping_bag_outlined : Icons.description,
                                color: inv.isPurchase ? AppColors.warning : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        inv.invoiceNumber,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: inv.isPurchase ? AppColors.warning.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          inv.isPurchase ? 'PURCHASE' : 'SALE',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: inv.isPurchase ? AppColors.warning : AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    inv.status == InvoiceStatus.paid
                                        ? StatusChip.paid()
                                        : inv.status == InvoiceStatus.partiallyPaid
                                            ? StatusChip.partiallyPaid()
                                            : StatusChip.unpaid(),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                      onPressed: () async {
                                        final bloc = context.read<InvoiceBloc>();
                                        await context.push(
                                          RouteNames.createInvoice,
                                          extra: {
                                            'invoiceType': inv.type,
                                            'invoiceToEdit': inv,
                                          },
                                        );
                                        if (!mounted) return;
                                        bloc.add(const FetchInvoicesEvent());
                                      },
                                    ),
                                  ],
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

  Widget _filterChip(String code, String label) {
    final selected = _selectedFilter == code;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.darkBlueText,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
        ),
      ),
      selected: selected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      onSelected: (val) {
        if (val) {
          setState(() {
            _selectedFilter = code;
          });
        }
      },
    );
  }
}
