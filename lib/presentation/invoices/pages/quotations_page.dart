import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../application/bloc/quotations_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

class QuotationsPage extends StatefulWidget {
  const QuotationsPage({super.key});

  @override
  State<QuotationsPage> createState() => _QuotationsPageState();
}

class _QuotationsPageState extends State<QuotationsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  InvoiceStatus? _selectedStatus;
  String _selectedSort = 'newest';

  @override
  void initState() {
    super.initState();
    context.read<QuotationsBloc>().add(const FetchQuotationsEvent());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<QuotationsBloc>().add(FetchQuotationsEvent(
          query: query,
          statusFilter: _selectedStatus,
          sortOption: _selectedSort,
        ));
  }

  void _onStatusFilterSelected(InvoiceStatus? status) {
    setState(() {
      _selectedStatus = status;
    });
    context.read<QuotationsBloc>().add(FetchQuotationsEvent(
          query: _searchCtrl.text.trim(),
          statusFilter: status,
          sortOption: _selectedSort,
        ));
  }

  void _onSortOptionSelected(String sortOption) {
    setState(() {
      _selectedSort = sortOption;
    });
    context.read<QuotationsBloc>().add(FetchQuotationsEvent(
          query: _searchCtrl.text.trim(),
          statusFilter: _selectedStatus,
          sortOption: sortOption,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quotations'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        // Requirement 2 & 4: Completely remove Report/Analytics button from top-right.
      ),
      body: BlocListener<QuotationsBloc, QuotationsState>(
        listener: (context, state) {
          if (state is QuotationsOperationSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is QuotationsErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Column(
          children: [
            // Search & Filter Header Section
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surfaceCard,
              child: Column(
                children: [
                  // Requirement 3: Quotation-specific search field
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.pageBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search quotations by number or account name...',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                          overflow: TextOverflow.ellipsis,
                        ),
                        prefixIcon: const Icon(Icons.search,
                            size: 20, color: AppColors.secondaryText),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter & Sort Control Bar
                  Row(
                    children: [
                      // Filter Button Modal trigger
                      InkWell(
                        onTap: () => _showFilterBottomSheet(context),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedStatus != null
                                ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                : AppColors.pageBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedStatus != null
                                  ? AppColors.primaryBlue
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_list_rounded,
                                size: 16,
                                color: _selectedStatus != null
                                    ? AppColors.primaryBlue
                                    : AppColors.darkBlueText,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _selectedStatus == null
                                    ? 'Filter'
                                    : 'Status: ${_selectedStatus!.label}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedStatus != null
                                      ? AppColors.primaryBlue
                                      : AppColors.darkBlueText,
                                ),
                              ),
                              if (_selectedStatus != null) ...[
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => _onStatusFilterSelected(null),
                                  child: const Icon(Icons.close,
                                      size: 14, color: AppColors.primaryBlue),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Sort Dropdown Menu
                      PopupMenuButton<String>(
                        initialValue: _selectedSort,
                        onSelected: _onSortOptionSelected,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.pageBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.sort_rounded,
                                  size: 16, color: AppColors.secondaryText),
                              const SizedBox(width: 6),
                              Text(
                                _getSortLabel(_selectedSort),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkBlueText,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down_rounded,
                                  size: 16, color: AppColors.secondaryText),
                            ],
                          ),
                        ),
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'newest',
                            child: Text('Created Date — Newest'),
                          ),
                          const PopupMenuItem(
                            value: 'oldest',
                            child: Text('Created Date — Oldest'),
                          ),
                          const PopupMenuItem(
                            value: 'date_newest',
                            child: Text('Valid Until — Newest'),
                          ),
                          const PopupMenuItem(
                            value: 'date_oldest',
                            child: Text('Valid Until — Oldest'),
                          ),
                          const PopupMenuItem(
                            value: 'amount_high',
                            child: Text('Amount — Highest'),
                          ),
                          const PopupMenuItem(
                            value: 'amount_low',
                            child: Text('Amount — Lowest'),
                          ),
                          const PopupMenuItem(
                            value: 'number_asc',
                            child: Text('Quotation Number — A to Z'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Quotation List
            Expanded(
              child: BlocBuilder<QuotationsBloc, QuotationsState>(
                builder: (context, state) {
                  if (state is QuotationsLoadingState) {
                    return const InvoiceListSkeleton();
                  }
                  if (state is QuotationsLoadedState) {
                    final list = state.filteredQuotations;

                    // Requirement 16: Empty State
                    if (list.isEmpty) {
                      return const EmptyState(
                        title: 'No quotations yet',
                        message: 'Create a quotation to get started.',
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, idx) {
                        final q = list[idx];
                        return _buildQuotationTile(context, q);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSortLabel(String sort) {
    switch (sort) {
      case 'oldest':
        return 'Sort: Oldest';
      case 'date_newest':
        return 'Sort: Valid Newest';
      case 'date_oldest':
        return 'Sort: Valid Oldest';
      case 'amount_high':
        return 'Sort: High Amount';
      case 'amount_low':
        return 'Sort: Low Amount';
      case 'number_asc':
        return 'Sort: Number';
      case 'newest':
      default:
        return 'Sort: Newest';
    }
  }

  // Requirement 5 & 7: Quotation Card Tile
  Widget _buildQuotationTile(BuildContext context, InvoiceEntity q) {
    return AppCard(
      onTap: () async {
        final bloc = context.read<QuotationsBloc>();
        await context.push(
          RouteNames.invoiceDetails,
          extra: q,
        );
        if (context.mounted) {
          bloc.add(FetchQuotationsEvent(
            query: _searchCtrl.text.trim(),
            statusFilter: _selectedStatus,
            sortOption: _selectedSort,
          ));
        }
      },
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: const Icon(
              Icons.request_quote_rounded,
              color: Color(0xFF0284C7),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Quotation Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        q.invoiceNumber,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlueText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'QUOTATION',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  q.customerName.isNotEmpty ? q.customerName : 'General Customer',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM yyyy').format(q.issueDate),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Amount & Status Chip + More Menu
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${q.grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildQuotationStatusChip(q.status),
                  const SizedBox(width: 4),
                  // Requirement 14: 3-Dot More Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        size: 20, color: AppColors.secondaryText),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onSelected: (val) async {
                      final bloc = context.read<QuotationsBloc>();
                      if (val == 'view') {
                        await context.push(
                          RouteNames.invoiceDetails,
                          extra: q,
                        );
                        if (context.mounted) {
                          bloc.add(FetchQuotationsEvent(
                            query: _searchCtrl.text.trim(),
                            statusFilter: _selectedStatus,
                            sortOption: _selectedSort,
                          ));
                        }
                      } else if (val == 'edit') {
                        await context.push(
                          RouteNames.createInvoice,
                          extra: {
                            'invoiceType': q.type,
                            'invoiceToEdit': q,
                            'isQuotation': true,
                          },
                        );
                        if (context.mounted) {
                          bloc.add(FetchQuotationsEvent(
                            query: _searchCtrl.text.trim(),
                            statusFilter: _selectedStatus,
                            sortOption: _selectedSort,
                          ));
                        }
                      } else if (val == 'duplicate') {
                        bloc.add(DuplicateQuotationEvent(q));
                      } else if (val == 'convert') {
                        await context.push(
                          RouteNames.createInvoice,
                          extra: {
                            'invoiceType': InvoiceType.sale,
                            'fromQuotation': q,
                          },
                        );
                        if (context.mounted) {
                          bloc.add(FetchQuotationsEvent(
                            query: _searchCtrl.text.trim(),
                            statusFilter: _selectedStatus,
                            sortOption: _selectedSort,
                          ));
                        }
                      } else if (val == 'delete') {
                        _confirmDelete(context, q);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility_outlined,
                                size: 18, color: AppColors.primaryBlue),
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
                                size: 18, color: AppColors.primaryBlue),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy_rounded,
                                size: 18, color: AppColors.primaryBlue),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      if (q.status != InvoiceStatus.converted)
                        const PopupMenuItem(
                          value: 'convert',
                          child: Row(
                            children: [
                              Icon(Icons.swap_horiz_rounded,
                                  size: 18, color: AppColors.success),
                              SizedBox(width: 8),
                              Text('Convert to Sale',
                                  style: TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600)),
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
                                style: TextStyle(color: AppColors.danger)),
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
    );
  }

  // Requirement 6: Quotation-specific status chips
  Widget _buildQuotationStatusChip(InvoiceStatus status) {
    Color bg;
    Color text;

    switch (status) {
      case InvoiceStatus.converted:
        bg = AppColors.success.withValues(alpha: 0.15);
        text = AppColors.success;
        break;
      case InvoiceStatus.accepted:
        bg = AppColors.primaryBlue.withValues(alpha: 0.15);
        text = AppColors.primaryBlue;
        break;
      case InvoiceStatus.sent:
        bg = Colors.indigo.withValues(alpha: 0.15);
        text = Colors.indigo;
        break;
      case InvoiceStatus.rejected:
      case InvoiceStatus.expired:
        bg = AppColors.danger.withValues(alpha: 0.15);
        text = AppColors.danger;
        break;
      case InvoiceStatus.draft:
      default:
        bg = Colors.orange.withValues(alpha: 0.15);
        text = Colors.orange.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: text,
        ),
      ),
    );
  }

  // Filter Bottom Sheet Modal
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Quotations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlueText,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _onStatusFilterSelected(null);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset All'),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _statusFilterOption(ctx, null, 'All'),
                      _statusFilterOption(ctx, InvoiceStatus.draft, 'Draft'),
                      _statusFilterOption(ctx, InvoiceStatus.sent, 'Sent'),
                      _statusFilterOption(ctx, InvoiceStatus.accepted, 'Accepted'),
                      _statusFilterOption(ctx, InvoiceStatus.rejected, 'Rejected'),
                      _statusFilterOption(ctx, InvoiceStatus.expired, 'Expired'),
                      _statusFilterOption(ctx, InvoiceStatus.converted, 'Converted'),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _statusFilterOption(
      BuildContext ctx, InvoiceStatus? status, String label) {
    final selected = _selectedStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primaryBlue,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.darkBlueText,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      backgroundColor: AppColors.pageBackground,
      onSelected: (val) {
        if (val) {
          _onStatusFilterSelected(status);
          Navigator.pop(ctx);
        }
      },
    );
  }

  void _confirmDelete(BuildContext context, InvoiceEntity q) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Quotation?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
            'Are you sure you want to delete quotation #${q.invoiceNumber}? This action cannot be undone.'),
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
                  .read<QuotationsBloc>()
                  .add(DeleteQuotationEvent(q.id));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
