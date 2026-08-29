import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../domain/entities/accounting_entities.dart';
import '../../../infrastructure/repositories/accounting_repository.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  late List<JournalEntryEntity> _journals;
  bool _isLoading = true;

  // Filter & Sort State
  String _selectedFilter = 'all'; // 'all', 'this_month', 'this_year'
  String _selectedDateRange = 'All'; // 'All', 'Today', 'This Week', 'This Month', 'This Quarter', 'This Year'
  String _selectedSort = 'created_newest';

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _loadEntries() {
    setState(() => _isLoading = true);
    final repo = getIt<AccountingRepository>();
    final list = repo.getJournalEntries();
    setState(() {
      _journals = list;
      _isLoading = false;
    });
  }

  String _formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return formatter.format(amount);
  }

  void _confirmDelete(BuildContext context, JournalEntryEntity entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Journal Entry?'),
        content: Text(
            'Are you sure you want to delete Journal Entry #${entry.referenceNumber}? This action cannot be undone.'),
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
              await getIt<AccountingRepository>().deleteJournalEntry(entry.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Journal Entry #${entry.referenceNumber} deleted.'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
              _loadEntries();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    String tempDateRange = _selectedDateRange;
    String tempSort = _selectedSort;

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
                          'Filter & Sort Journal Entries',
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
                      children: [
                        'All',
                        'Today',
                        'This Week',
                        'This Month',
                        'This Quarter',
                        'This Year'
                      ].map((d) {
                        final isSel = tempDateRange == d;
                        return ChoiceChip(
                          label: Text(d),
                          selected: isSel,
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: AppColors.surfaceContainerLow,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSel ? Colors.white : AppColors.darkBlueText,
                          ),
                          onSelected: (val) {
                            if (val) setSheetState(() => tempDateRange = d);
                          },
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
                        _buildSortChip(
                            'created_newest', 'Created Date — Newest', tempSort,
                            (s) => setSheetState(() => tempSort = s)),
                        _buildSortChip(
                            'created_oldest', 'Created Date — Oldest', tempSort,
                            (s) => setSheetState(() => tempSort = s)),
                        _buildSortChip(
                            'journal_newest', 'Journal Date — Newest', tempSort,
                            (s) => setSheetState(() => tempSort = s)),
                        _buildSortChip(
                            'journal_oldest', 'Journal Date — Oldest', tempSort,
                            (s) => setSheetState(() => tempSort = s)),
                        _buildSortChip(
                            'amount_high', 'Amount — Highest', tempSort,
                            (s) => setSheetState(() => tempSort = s)),
                        _buildSortChip(
                            'amount_low', 'Amount — Lowest', tempSort,
                            (s) => setSheetState(() => tempSort = s)),
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
                                _selectedDateRange = 'All';
                                _selectedSort = 'created_newest';
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
                                _selectedDateRange = tempDateRange;
                                _selectedSort = tempSort;
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

  Widget _buildSortChip(String value, String label, String currentSort,
      ValueChanged<String> onSelect) {
    final isSelected = currentSort == value;
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
      onSelected: (val) {
        if (val) onSelect(value);
      },
    );
  }

  void _showViewModal(BuildContext context, JournalEntryEntity entry) {
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
                    const Text(
                      'Journal Entry',
                      style: TextStyle(
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
                          color: AppColors.primaryBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_note_outlined,
                          size: 26,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.referenceNumber,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkBlueText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Date: ${dateFormatter.format(entry.date)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '✓ Balanced',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (entry.narration.isNotEmpty)
                  _buildDetailRow('Narration', entry.narration),
                const SizedBox(height: 14),
                const Text(
                  'ACCOUNTING ENTRIES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlueText,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Table of Accounting Entries
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.pageBackground,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(11)),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text('Account',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.secondaryText)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Debit',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.secondaryText),
                                  textAlign: TextAlign.right),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Credit',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.secondaryText),
                                  textAlign: TextAlign.right),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ...entry.items.map((itm) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: AppColors.border, width: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  itm.accountName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkBlueText,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  itm.debit > 0
                                      ? _formatCurrency(itm.debit)
                                      : '—',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkBlueText,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  itm.credit > 0
                                      ? _formatCurrency(itm.credit)
                                      : '—',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkBlueText,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Totals
                _buildDetailRow('Total Debit', _formatCurrency(entry.totalDebit)),
                _buildDetailRow('Total Credit', _formatCurrency(entry.totalCredit)),
                _buildDetailRow('Difference', '₹0.00'),

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
                            RouteNames.newJournalEntry,
                            extra: entry,
                          );
                          _loadEntries();
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit Entry',
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
                          _confirmDelete(context, entry);
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
      padding: const EdgeInsets.only(bottom: 6.0),
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

    // Filter entries
    List<JournalEntryEntity> filtered = _journals.where((j) {
      if (_selectedFilter == 'this_month') {
        final startOfMonth = DateTime(now.year, now.month, 1);
        if (j.date.isBefore(startOfMonth)) return false;
      } else if (_selectedFilter == 'this_year') {
        final startOfYear = DateTime(now.year, 1, 1);
        if (j.date.isBefore(startOfYear)) return false;
      }

      if (_selectedDateRange == 'Today') {
        final d = DateTime(j.date.year, j.date.month, j.date.day);
        if (d != today) return false;
      } else if (_selectedDateRange == 'This Week') {
        final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
        if (j.date.isBefore(startOfWeek)) return false;
      } else if (_selectedDateRange == 'This Month') {
        final startOfMonth = DateTime(now.year, now.month, 1);
        if (j.date.isBefore(startOfMonth)) return false;
      } else if (_selectedDateRange == 'This Quarter') {
        final currentQuarter = ((now.month - 1) ~/ 3) + 1;
        final startOfQuarter = DateTime(now.year, (currentQuarter - 1) * 3 + 1, 1);
        if (j.date.isBefore(startOfQuarter)) return false;
      } else if (_selectedDateRange == 'This Year') {
        final startOfYear = DateTime(now.year, 1, 1);
        if (j.date.isBefore(startOfYear)) return false;
      }

      if (query.isEmpty) return true;
      return j.referenceNumber.toLowerCase().contains(query) ||
          j.narration.toLowerCase().contains(query) ||
          j.items.any((item) => item.accountName.toLowerCase().contains(query));
    }).toList();

    // Sorting entries
    switch (_selectedSort) {
      case 'created_oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'journal_newest':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'journal_oldest':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'amount_high':
        filtered.sort((a, b) => b.totalDebit.compareTo(a.totalDebit));
        break;
      case 'amount_low':
        filtered.sort((a, b) => a.totalDebit.compareTo(b.totalDebit));
        break;
      case 'created_newest':
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Journal'),
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
                            hintText:
                                'Search voucher number, account or narration...',
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
                                  _selectedSort != 'created_newest' ||
                                  _selectedDateRange != 'All')
                              ? AppColors.primaryBlue.withValues(alpha: 0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (_selectedFilter != 'all' ||
                                    _selectedSort != 'created_newest' ||
                                    _selectedDateRange != 'All')
                                ? AppColors.primaryBlue
                                : AppColors.border,
                          ),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: (_selectedFilter != 'all' ||
                                  _selectedSort != 'created_newest' ||
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

                // Horizontally Scrollable Custom Chips Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('all', 'All'),
                      const SizedBox(width: 8),
                      _filterChip('this_month', 'This Month'),
                      const SizedBox(width: 8),
                      _filterChip('this_year', 'This Year'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Journal List
          Expanded(
            child: _isLoading
                ? const ReturnsListSkeleton()
                : filtered.isEmpty
                    ? EmptyState(
                        title: 'No Journal Entries',
                        message: query.isNotEmpty || _selectedFilter != 'all'
                            ? 'No journal entries match your search or filter.'
                            : 'Journal transactions you create will appear here.',
                        icon: Icons.edit_note_outlined,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, idx) {
                          final item = filtered[idx];
                          return _buildJournalCard(context, item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildJournalCard(BuildContext context, JournalEntryEntity entry) {
    final dateFormatter = DateFormat('dd MMM yyyy');

    final debitItem = entry.items.firstWhere((i) => i.debit > 0,
        orElse: () =>
            entry.items.isNotEmpty ? entry.items.first : const JournalLineItem(accountName: 'General Account', accountType: 'Expense'));
    final creditItem = entry.items.firstWhere((i) => i.credit > 0,
        orElse: () =>
            entry.items.isNotEmpty ? entry.items.last : const JournalLineItem(accountName: 'General Account', accountType: 'Asset'));

    return AppCard(
      onTap: () => _showViewModal(context, entry),
      child: Row(
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: const Icon(
              Icons.edit_note_outlined,
              color: AppColors.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.referenceNumber,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlueText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${debitItem.accountName} → ${creditItem.accountName}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlueText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.narration.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.narration,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Amount & Date + 3-Dot Menu
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(entry.totalDebit),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dateFormatter.format(entry.date),
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
                        _showViewModal(context, entry);
                      } else if (val == 'edit') {
                        await context.push(
                          RouteNames.newJournalEntry,
                          extra: entry,
                        );
                        _loadEntries();
                      } else if (val == 'delete') {
                        _confirmDelete(context, entry);
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
                            Text('Edit Entry'),
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
}
