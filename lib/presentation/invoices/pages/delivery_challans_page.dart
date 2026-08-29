import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/delivery_challan_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../domain/entities/business_entity.dart';
import '../../../domain/entities/delivery_challan_entity.dart';
import '../../../infrastructure/pdf/pdf_delivery_challan_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

class DeliveryChallansPage extends StatefulWidget {
  const DeliveryChallansPage({super.key});

  @override
  State<DeliveryChallansPage> createState() => _DeliveryChallansPageState();
}

class _DeliveryChallansPageState extends State<DeliveryChallansPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  DeliveryChallanStatus? _selectedStatus;
  String _selectedSort = 'newest';

  @override
  void initState() {
    super.initState();
    context.read<DeliveryChallanBloc>().add(const FetchDeliveryChallansEvent());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<DeliveryChallanBloc>().add(FetchDeliveryChallansEvent(
          query: query,
          statusFilter: _selectedStatus,
          sortOption: _selectedSort,
        ));
  }

  void _onStatusFilterSelected(DeliveryChallanStatus? status) {
    setState(() {
      _selectedStatus = status;
    });
    context.read<DeliveryChallanBloc>().add(FetchDeliveryChallansEvent(
          query: _searchCtrl.text.trim(),
          statusFilter: status,
          sortOption: _selectedSort,
        ));
  }

  void _onSortOptionSelected(String sortOption) {
    setState(() {
      _selectedSort = sortOption;
    });
    context.read<DeliveryChallanBloc>().add(FetchDeliveryChallansEvent(
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
        title: const Text('Delivery Challans'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<DeliveryChallanBloc, DeliveryChallanState>(
        listener: (context, state) {
          if (state is DeliveryChallanOperationSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is DeliveryChallanErrorState) {
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
                  // Requirement 4: Search Field
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
                        hintText: 'Search challan number or party name...',
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

                  // Requirement 5 & 6: Filter Chips & Sort Control
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
                            value: 'challan_date_newest',
                            child: Text('Challan Date — Newest'),
                          ),
                          const PopupMenuItem(
                            value: 'challan_date_oldest',
                            child: Text('Challan Date — Oldest'),
                          ),
                          const PopupMenuItem(
                            value: 'number_asc',
                            child: Text('Challan Number'),
                          ),
                          const PopupMenuItem(
                            value: 'party_asc',
                            child: Text('Party Name'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Delivery Challans List
            Expanded(
              child: BlocBuilder<DeliveryChallanBloc, DeliveryChallanState>(
                builder: (context, state) {
                  if (state is DeliveryChallansLoadingState) {
                    return const InvoiceListSkeleton();
                  }
                  if (state is DeliveryChallansLoadedState) {
                    final list = state.filteredChallans;

                    // Requirement 19: Compact Empty State
                    if (list.isEmpty) {
                      return const EmptyState(
                        title: 'No Delivery Challans Yet',
                        message: 'Delivery challans you create will appear here.',
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, idx) {
                        final challan = list[idx];
                        return _buildChallanTile(context, challan);
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
      case 'challan_date_newest':
        return 'Sort: Date Newest';
      case 'challan_date_oldest':
        return 'Sort: Date Oldest';
      case 'number_asc':
        return 'Sort: Number';
      case 'party_asc':
        return 'Sort: Party';
      case 'newest':
      default:
        return 'Sort: Newest';
    }
  }

  // Requirement 7: Delivery Challan Tile Card
  Widget _buildChallanTile(BuildContext context, DeliveryChallanEntity challan) {
    return AppCard(
      onTap: () async {
        final bloc = context.read<DeliveryChallanBloc>();
        await context.push(
          RouteNames.deliveryChallanDetails,
          extra: challan,
        );
        if (context.mounted) {
          bloc.add(FetchDeliveryChallansEvent(
            query: _searchCtrl.text.trim(),
            statusFilter: _selectedStatus,
            sortOption: _selectedSort,
          ));
        }
      },
      child: Row(
        children: [
          // Truck Icon Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: AppColors.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Challan Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challan.challanNumber,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlueText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  challan.customerName.isNotEmpty ? challan.customerName : 'General Customer',
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
                  DateFormat('dd MMM yyyy').format(challan.issueDate),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Items Count & Status Chip + More Menu
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${challan.totalQuantity} ${challan.totalQuantity == 1 ? 'Item' : 'Items'}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlueText,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildChallanStatusChip(challan.status),
                  const SizedBox(width: 4),

                  // Requirement 8: 3-Dot More Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        size: 20, color: AppColors.secondaryText),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onSelected: (val) async {
                      final bloc = context.read<DeliveryChallanBloc>();
                      if (val == 'view') {
                        await context.push(
                          RouteNames.deliveryChallanDetails,
                          extra: challan,
                        );
                        if (context.mounted) {
                          bloc.add(FetchDeliveryChallansEvent(
                            query: _searchCtrl.text.trim(),
                            statusFilter: _selectedStatus,
                            sortOption: _selectedSort,
                          ));
                        }
                      } else if (val == 'edit') {
                        await context.push(
                          RouteNames.createDeliveryChallan,
                          extra: challan,
                        );
                        if (context.mounted) {
                          bloc.add(FetchDeliveryChallansEvent(
                            query: _searchCtrl.text.trim(),
                            statusFilter: _selectedStatus,
                            sortOption: _selectedSort,
                          ));
                        }
                      } else if (val == 'print') {
                        _printChallan(context, challan);
                      } else if (val == 'delete') {
                        _confirmDelete(context, challan);
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
                        value: 'print',
                        child: Row(
                          children: [
                            Icon(Icons.print_outlined,
                                size: 18, color: AppColors.primaryBlue),
                            SizedBox(width: 8),
                            Text('Print A4'),
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

  Widget _buildChallanStatusChip(DeliveryChallanStatus status) {
    Color bg;
    Color text;

    switch (status) {
      case DeliveryChallanStatus.delivered:
        bg = AppColors.success.withValues(alpha: 0.15);
        text = AppColors.success;
        break;
      case DeliveryChallanStatus.issued:
        bg = AppColors.primaryBlue.withValues(alpha: 0.15);
        text = AppColors.primaryBlue;
        break;
      case DeliveryChallanStatus.cancelled:
        bg = AppColors.danger.withValues(alpha: 0.15);
        text = AppColors.danger;
        break;
      case DeliveryChallanStatus.draft:
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
                        'Filter Delivery Challans',
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
                      _statusFilterOption(ctx, DeliveryChallanStatus.draft, 'Draft'),
                      _statusFilterOption(ctx, DeliveryChallanStatus.issued, 'Issued'),
                      _statusFilterOption(ctx, DeliveryChallanStatus.delivered, 'Delivered'),
                      _statusFilterOption(ctx, DeliveryChallanStatus.cancelled, 'Cancelled'),
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
      BuildContext ctx, DeliveryChallanStatus? status, String label) {
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

  Future<void> _printChallan(BuildContext context, DeliveryChallanEntity challan) async {
    final business = BusinessEntity(
      id: 'biz_01',
      name: 'Xenobiz Traders',
      address: 'Industrial Plot 45, Sector 18, Commercial Hub',
      phone: '+91 98765 43210',
      email: 'contact@xenobiz.com',
      gstin: '07AAAAA0000A1Z5',
      category: 'General',
      createdAt: DateTime.now(),
    );
    await PdfDeliveryChallanService.printChallan(
      challan: challan,
      business: business,
    );
  }

  void _confirmDelete(BuildContext context, DeliveryChallanEntity challan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Delivery Challan?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
            'Are you sure you want to delete Delivery Challan #${challan.challanNumber}? This action cannot be undone.'),
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
                  .read<DeliveryChallanBloc>()
                  .add(DeleteDeliveryChallanSubmittedEvent(challan.id));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
