import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/invoice_return_entity.dart';
import '../../../domain/repositories/returns_repository.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';
import 'return_voucher_screen.dart';

class CreditDebitNotesPage extends StatefulWidget {
  final InvoiceType? initialType;

  const CreditDebitNotesPage({super.key, this.initialType});

  @override
  State<CreditDebitNotesPage> createState() => _CreditDebitNotesPageState();
}

class _CreditDebitNotesPageState extends State<CreditDebitNotesPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isLoading = true;
  List<InvoiceReturnEntity> _allReturns = [];

  // Filter & Sort State
  String _selectedFilter = 'all'; // 'all', 'credit', 'debit'
  String _selectedSort = 'newest'; // 'newest', 'oldest', 'amount_high', 'amount_low'
  String _selectedDateRange = 'All'; // 'All', 'Today', 'This Week', 'This Month'

  @override
  void initState() {
    super.initState();
    if (widget.initialType == InvoiceType.sale) {
      _selectedFilter = 'credit';
    } else if (widget.initialType == InvoiceType.purchase) {
      _selectedFilter = 'debit';
    }
    _fetchReturns();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchReturns() async {
    setState(() => _isLoading = true);
    try {
      final list = await getIt<ReturnsRepository>().getAllReturns();
      if (mounted) {
        setState(() {
          _allReturns = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return formatter.format(amount);
  }

  void _confirmDelete(BuildContext context, InvoiceReturnEntity item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          item.isSale ? 'Delete Credit Note?' : 'Delete Debit Note?',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
            'Are you sure you want to delete ${item.isSale ? 'Credit Note' : 'Debit Note'} #${item.returnNumber}? Stock adjustments made by this note will be safely restored.'),
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
            onPressed: () async {
              Navigator.pop(ctx);
              await getIt<ReturnsRepository>().deleteReturn(item.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${item.isSale ? 'Credit Note' : 'Debit Note'} #${item.returnNumber} deleted.'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
              _fetchReturns();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    String tempFilter = _selectedFilter;
    String tempSort = _selectedSort;
    String tempDateRange = _selectedDateRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter & Sort Notes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlueText,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Note Type Filter
                    const Text(
                      'Note Type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildModalChip('all', 'All Notes', tempFilter == 'all',
                            (val) => setSheetState(() => tempFilter = 'all')),
                        _buildModalChip('credit', 'Credit Notes',
                            tempFilter == 'credit',
                            (val) => setSheetState(() => tempFilter = 'credit')),
                        _buildModalChip('debit', 'Debit Notes',
                            tempFilter == 'debit',
                            (val) => setSheetState(() => tempFilter = 'debit')),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Date Range
                    const Text(
                      'Date Range',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['All', 'Today', 'This Week', 'This Month'].map((d) {
                        return _buildModalChip(
                          d,
                          d,
                          tempDateRange == d,
                          (val) => setSheetState(() => tempDateRange = d),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // Sort By
                    const Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildModalChip('newest', 'Newest First',
                            tempSort == 'newest',
                            (val) => setSheetState(() => tempSort = 'newest')),
                        _buildModalChip('oldest', 'Oldest First',
                            tempSort == 'oldest',
                            (val) => setSheetState(() => tempSort = 'oldest')),
                        _buildModalChip('amount_high', 'Amount: High to Low',
                            tempSort == 'amount_high',
                            (val) => setSheetState(() => tempSort = 'amount_high')),
                        _buildModalChip('amount_low', 'Amount: Low to High',
                            tempSort == 'amount_low',
                            (val) => setSheetState(() => tempSort = 'amount_low')),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedFilter = 'all';
                                _selectedSort = 'newest';
                                _selectedDateRange = 'All';
                              });
                              Navigator.pop(sheetCtx);
                            },
                            child: const Text('Reset All',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedFilter = tempFilter;
                                _selectedSort = tempSort;
                                _selectedDateRange = tempDateRange;
                              });
                              Navigator.pop(sheetCtx);
                            },
                            child: const Text('Apply Filters',
                                style: TextStyle(fontWeight: FontWeight.w800)),
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
      },
    );
  }

  Widget _buildModalChip(
      String key, String label, bool isSelected, ValueChanged<bool> onSelect) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryBlue,
      backgroundColor: AppColors.surfaceContainerLow,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: isSelected ? Colors.white : AppColors.darkBlueText,
      ),
      onSelected: onSelect,
    );
  }

  void _showDetailsModal(BuildContext context, InvoiceReturnEntity item) {
    final dateFormatter = DateFormat('dd MMM yyyy');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.isSale ? 'Credit Note Details' : 'Debit Note Details',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlueText,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (item.isSale
                                  ? AppColors.danger
                                  : AppColors.warning)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.isSale
                              ? Icons.note_alt_outlined
                              : Icons.note_add_outlined,
                          size: 26,
                          color: item.isSale
                              ? AppColors.danger
                              : AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.returnNumber,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkBlueText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Original Invoice: #${item.invoiceNumber}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatCurrency(item.totalAmount),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: item.isSale
                              ? AppColors.danger
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _buildDetailRow('Party Name', item.partyName),
                _buildDetailRow(
                    'Note Date', dateFormatter.format(item.returnDate)),
                _buildDetailRow(
                    'Note Type', item.isSale ? 'Credit Note' : 'Debit Note'),
                if (item.notes.isNotEmpty)
                  _buildDetailRow('Remarks / Notes', item.notes),
                const SizedBox(height: 14),
                const Text(
                  'RETURNED ITEMS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlueText,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: item.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (c, idx) {
                    final itm = item.items[idx];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(itm.productName,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.darkBlueText)),
                              Text(
                                  '${itm.returnedQuantity} x ${_formatCurrency(itm.unitPrice)}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.secondaryText)),
                            ],
                          ),
                        ),
                        Text(_formatCurrency(itm.totalAmount),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkBlueText)),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await context.push(
                            RouteNames.createReturn,
                            extra: {
                              'returnType': item.isSale
                                  ? ReturnType.salesReturn
                                  : ReturnType.purchaseReturn,
                              'existingReturn': item,
                            },
                          );
                          _fetchReturns();
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit Note',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _confirmDelete(context, item);
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete',
                            style: TextStyle(fontWeight: FontWeight.w800)),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText)),
          Flexible(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlueText),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filter returns
    List<InvoiceReturnEntity> filtered = _allReturns.where((r) {
      if (_selectedFilter == 'credit' && !r.isSale) return false;
      if (_selectedFilter == 'debit' && r.isSale) return false;

      if (_selectedDateRange == 'Today') {
        final d = DateTime(r.returnDate.year, r.returnDate.month, r.returnDate.day);
        if (d != today) return false;
      } else if (_selectedDateRange == 'This Week') {
        final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
        if (r.returnDate.isBefore(startOfWeek)) return false;
      } else if (_selectedDateRange == 'This Month') {
        final startOfMonth = DateTime(now.year, now.month, 1);
        if (r.returnDate.isBefore(startOfMonth)) return false;
      }

      if (query.isEmpty) return true;
      return r.returnNumber.toLowerCase().contains(query) ||
          r.invoiceNumber.toLowerCase().contains(query) ||
          r.partyName.toLowerCase().contains(query);
    }).toList();

    // Sorting
    switch (_selectedSort) {
      case 'oldest':
        filtered.sort((a, b) => a.returnDate.compareTo(b.returnDate));
        break;
      case 'amount_high':
        filtered.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
      case 'amount_low':
        filtered.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;
      case 'newest':
      default:
        filtered.sort((a, b) => b.returnDate.compareTo(a.returnDate));
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Credit & Debit Notes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar + Filter Icon Row & Horizontal Chips Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceCard,
            child: Column(
              children: [
                // Search Bar + Filter Button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.pageBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search party, transaction or number...',
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
                                      setState(() {});
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _showFilterBottomSheet(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: (_selectedFilter != 'all' ||
                                  _selectedSort != 'newest' ||
                                  _selectedDateRange != 'All')
                              ? AppColors.primaryBlue.withValues(alpha: 0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (_selectedFilter != 'all' ||
                                    _selectedSort != 'newest' ||
                                    _selectedDateRange != 'All')
                                ? AppColors.primaryBlue
                                : AppColors.border,
                          ),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: (_selectedFilter != 'all' ||
                                  _selectedSort != 'newest' ||
                                  _selectedDateRange != 'All')
                              ? AppColors.primaryBlue
                              : AppColors.darkBlueText,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Horizontally Scrollable Custom Chips Bar (matching reference image)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('all', 'All'),
                      const SizedBox(width: 8),
                      _filterChip('credit', 'Credit Notes'),
                      const SizedBox(width: 8),
                      _filterChip('debit', 'Debit Notes'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Notes List
          Expanded(
            child: _isLoading
                ? const ReturnsListSkeleton()
                : filtered.isEmpty
                    ? EmptyState(
                        title: 'No Notes Found',
                        message: query.isNotEmpty || _selectedFilter != 'all'
                            ? 'No credit or debit notes match your search or filter.'
                            : 'Credit & Debit Notes created for sales and purchase returns will appear here.',
                        icon: Icons.note_alt_outlined,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, idx) {
                          final item = filtered[idx];
                          return _buildNoteCard(context, item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // Custom Chip Widget matching the user's reference screenshot (Vibrant Blue, Check Icon when selected)
  Widget _filterChip(String value, String label) {
    final selected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.border,
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? Colors.white : AppColors.darkBlueText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, InvoiceReturnEntity item) {
    final dateFormatter = DateFormat('dd MMM yyyy');

    return AppCard(
      onTap: () => _showDetailsModal(context, item),
      child: Row(
        children: [
          // Icon Badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (item.isSale ? AppColors.danger : AppColors.warning)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: Icon(
              item.isSale ? Icons.note_alt_outlined : Icons.note_add_outlined,
              color: item.isSale ? AppColors.danger : AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Note & Party Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.returnNumber,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlueText,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildNoteTypeChip(item.isSale),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Invoice: #${item.invoiceNumber}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.partyName.isNotEmpty ? item.partyName : 'General Party',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Amount & Date + 3-Dot Menu
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(item.totalAmount),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: item.isSale ? AppColors.danger : AppColors.success,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dateFormatter.format(item.returnDate),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        size: 20, color: AppColors.secondaryText),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onSelected: (val) async {
                      if (val == 'view') {
                        _showDetailsModal(context, item);
                      } else if (val == 'edit') {
                        await context.push(
                          RouteNames.createReturn,
                          extra: {
                            'returnType': item.isSale
                                ? ReturnType.salesReturn
                                : ReturnType.purchaseReturn,
                            'existingReturn': item,
                          },
                        );
                        _fetchReturns();
                      } else if (val == 'delete') {
                        _confirmDelete(context, item);
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
                            Text('Edit Note'),
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

  Widget _buildNoteTypeChip(bool isSale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isSale ? AppColors.danger : AppColors.warning)
            .withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isSale ? 'CREDIT NOTE' : 'DEBIT NOTE',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: isSale ? AppColors.danger : Colors.orange.shade800,
        ),
      ),
    );
  }
}
