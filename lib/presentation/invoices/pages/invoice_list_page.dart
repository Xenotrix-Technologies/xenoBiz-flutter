import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    } else if (widget.initialType == InvoiceType.quotation) {
      _selectedFilter = 'QUOTATION';
    } else if (widget.initialType == InvoiceType.sale) {
      _selectedFilter = 'SALE';
    } else {
      _selectedFilter = 'ALL';
    }
    context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
  }

  bool get _isQuotationView => _selectedFilter == 'QUOTATION';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_selectedFilter == 'PURCHASE'
            ? 'Purchase Invoices'
            : (_selectedFilter == 'QUOTATION' ? 'Quotations' : AppStrings.invoiceTitle)),
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
      floatingActionButton: _isQuotationView
          ? null
          : FloatingActionButton(
              heroTag: null,
              backgroundColor: AppColors.primary,
              onPressed: () async {
                final isPurch = _selectedFilter == 'PURCHASE';
                final type = isPurch ? InvoiceType.purchase : InvoiceType.sale;
                final bloc = context.read<InvoiceBloc>();
                await context.push(
                  RouteNames.createInvoice,
                  extra: {
                    'invoiceType': type,
                  },
                );
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
                  label: 'Search Invoices / Quotations',
                  hint: 'Search by number or party name...',
                  controller: _searchController,
                  prefixIcon: Icons.search,
                  onChanged: (q) {
                    context
                        .read<InvoiceBloc>()
                        .add(FetchInvoicesEvent(query: q));
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
            child: BlocListener<InvoiceBloc, InvoiceState>(
              listener: (context, invoiceState) {
                if (invoiceState is InvoiceOperationSuccessState) {
                  context.read<InvoiceBloc>().add(FetchInvoicesEvent(
                        query: _searchController.text.trim().isEmpty
                            ? null
                            : _searchController.text.trim(),
                      ));
                }
              },
              child: BlocBuilder<InvoiceBloc, InvoiceState>(
                builder: (context, state) {
                  if (state is InvoiceLoadingState) {
                    return const InvoiceListSkeleton();
                  }
                  if (state is InvoicesLoadedState) {
                    var filtered = state.invoices.where((i) => !i.isQuotation).toList();
                    if (_selectedFilter == 'SALE') {
                      filtered = filtered.where((i) => i.isSale).toList();
                    } else if (_selectedFilter == 'PURCHASE') {
                      filtered = filtered.where((i) => i.isPurchase).toList();
                    }

                    if (filtered.isEmpty) {
                      return Column(
                        children: [
                          if (_isQuotationView) _buildQuotationsSummaryHeader([]),
                          const Expanded(
                            child: EmptyState(
                              title: 'No Documents Found',
                              message: 'No documents match your selected filter.',
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: filtered.length + (_isQuotationView ? 1 : 0),
                      itemBuilder: (ctx, idx) {
                        if (_isQuotationView && idx == 0) {
                          return _buildQuotationsSummaryHeader(filtered);
                        }
                        final inv = filtered[_isQuotationView ? idx - 1 : idx];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppCard(
                            onTap: () async {
                              final bloc = context.read<InvoiceBloc>();
                              await context.push(
                                RouteNames.invoiceDetails,
                                extra: inv,
                              );
                              if (!mounted) return;
                              bloc.add(const FetchInvoicesEvent());
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: inv.isQuotation
                                        ? const Color(0xFF0284C7).withValues(alpha: 0.1)
                                        : (inv.isPurchase
                                            ? AppColors.warning.withValues(alpha: 0.1)
                                            : AppColors.surfaceContainerLow),
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMedium),
                                  ),
                                  child: Icon(
                                    inv.isQuotation
                                        ? Icons.request_quote_rounded
                                        : (inv.isPurchase
                                            ? Icons.shopping_bag_outlined
                                            : Icons.description),
                                    color: inv.isQuotation
                                        ? const Color(0xFF0284C7)
                                        : (inv.isPurchase
                                            ? AppColors.warning
                                            : AppColors.primary),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              inv.invoiceNumber,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: inv.isQuotation
                                                  ? const Color(0xFF0284C7)
                                                      .withValues(alpha: 0.15)
                                                  : (inv.isPurchase
                                                      ? AppColors.warning
                                                          .withValues(alpha: 0.15)
                                                      : AppColors.primary
                                                          .withValues(alpha: 0.15)),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              inv.isQuotation
                                                  ? 'QUOTATION'
                                                  : (inv.isPurchase ? 'PURCHASE' : 'SALE'),
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: inv.isQuotation
                                                    ? const Color(0xFF0284C7)
                                                    : (inv.isPurchase
                                                        ? AppColors.warning
                                                        : AppColors.primary),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline,
                                              size: 13, color: AppColors.outline),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              inv.customerName,
                                              style: const TextStyle(
                                                  fontSize: 12, color: AppColors.outline),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        DateFormat('dd MMM yyyy').format(inv.issueDate),
                                        style: const TextStyle(
                                            fontSize: 11, color: AppColors.secondaryText),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                                        if (!inv.isQuotation)
                                          inv.status == InvoiceStatus.paid
                                              ? StatusChip.paid()
                                              : inv.status ==
                                                      InvoiceStatus.partiallyPaid
                                                  ? StatusChip.partiallyPaid()
                                                  : StatusChip.unpaid()
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryBlue
                                                  .withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'ESTIMATE',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primaryBlue,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 4),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert,
                                              size: 20,
                                              color: AppColors.secondaryText),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onSelected: (val) async {
                                            final bloc = context.read<InvoiceBloc>();
                                            if (val == 'view') {
                                              await context.push(
                                                RouteNames.invoiceDetails,
                                                extra: inv,
                                              );
                                              if (!mounted) return;
                                              bloc.add(const FetchInvoicesEvent());
                                            } else if (val == 'edit') {
                                              await context.push(
                                                RouteNames.createInvoice,
                                                extra: {
                                                  'invoiceType': inv.type,
                                                  'invoiceToEdit': inv,
                                                },
                                              );
                                              if (!mounted) return;
                                              bloc.add(const FetchInvoicesEvent());
                                            } else if (val == 'convert') {
                                              await context.push(
                                                RouteNames.createInvoice,
                                                extra: {
                                                  'invoiceType': InvoiceType.sale,
                                                  'fromQuotation': inv,
                                                },
                                              );
                                              if (!mounted) return;
                                              bloc.add(const FetchInvoicesEvent());
                                            } else if (val == 'delete') {
                                              _confirmDelete(context, inv);
                                            }
                                          },
                                          itemBuilder: (ctx) => [
                                            const PopupMenuItem(
                                              value: 'view',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.visibility_outlined,
                                                      size: 18,
                                                      color: AppColors.primaryBlue),
                                                  SizedBox(width: 8),
                                                  Text('View'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit_outlined,
                                                      size: 18,
                                                      color: AppColors.primaryBlue),
                                                  SizedBox(width: 8),
                                                  Text('Edit'),
                                                ],
                                              ),
                                            ),
                                            if (inv.isQuotation)
                                              const PopupMenuItem(
                                                value: 'convert',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.swap_horiz_rounded,
                                                        size: 18,
                                                        color: AppColors.success),
                                                    SizedBox(width: 8),
                                                    Text('Convert to Sale',
                                                        style: TextStyle(
                                                            color: AppColors.success,
                                                            fontWeight:
                                                                FontWeight.w600)),
                                                  ],
                                                ),
                                              ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete_outline,
                                                      size: 18, color: AppColors.danger),
                                                  SizedBox(width: 8),
                                                  Text('Delete',
                                                      style: TextStyle(
                                                          color: AppColors.danger)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotationsSummaryHeader(List<InvoiceEntity> quotations) {
    final totalVal = quotations.fold(0.0, (sum, q) => sum + q.grandTotal);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.request_quote_rounded, color: Color(0xFF38BDF8), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'QUOTATIONS OVERVIEW',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${quotations.length} total',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF38BDF8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${totalVal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Total Estimate Value',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, InvoiceEntity inv) {
    final isQuot = inv.isQuotation;
    final docTypeLabel = isQuot ? 'Quotation' : (inv.isPurchase ? 'Purchase' : 'Invoice');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete $docTypeLabel?',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
            'Are you sure you want to delete $docTypeLabel #${inv.invoiceNumber}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<InvoiceBloc>()
                  .add(DeleteInvoiceSubmittedEvent(inv.id));
            },
            child: const Text('Delete'),
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
