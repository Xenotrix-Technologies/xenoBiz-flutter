import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class ReportsPage extends StatefulWidget {
  final int initialCategoryIndex;
  const ReportsPage({super.key, this.initialCategoryIndex = 0});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialCategoryIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reports Hub'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(text: 'Sales Reports'),
            Tab(text: 'Purchase Reports'),
            Tab(text: 'Inventory Reports'),
            Tab(text: 'Accounting Reports'),
            Tab(text: 'GST & Taxation'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search report name or category...',
                prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReportGrid(context, _salesReports),
                _buildReportGrid(context, _purchaseReports),
                _buildReportGrid(context, _inventoryReports),
                _buildReportGrid(context, _accountingReports),
                _buildReportGrid(context, _gstReports),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportGrid(BuildContext context, List<_ReportCardItem> items) {
    final filtered = items.where((item) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return item.title.toLowerCase().contains(q) || item.subtitle.toLowerCase().contains(q);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assessment_outlined, size: 54, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            const Text('No Matching Reports Found', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (ctx, idx) {
        final item = filtered[idx];
        return AppCard(
          padding: const EdgeInsets.all(12),
          onTap: () {
            if (item.route != null) {
              context.push(item.route!);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening ${item.title}...')),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.darkBlueText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item.subtitle,
                style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  // Categories Data
  static final List<_ReportCardItem> _salesReports = [
    _ReportCardItem(title: 'Sales Summary', subtitle: 'Overall sales revenue & growth', icon: Icons.insights, color: AppColors.primaryBlue, route: RouteNames.salesAnalytics),
    _ReportCardItem(title: 'Sales by Customer', subtitle: 'Customer-wise billing analysis', icon: Icons.people_outline, color: AppColors.primaryBlue, route: RouteNames.salesAnalytics),
    _ReportCardItem(title: 'Sales by Product', subtitle: 'Item sales breakdown & quantities', icon: Icons.category_outlined, color: AppColors.primaryBlue, route: RouteNames.salesAnalytics),
    _ReportCardItem(title: 'Sales by Date', subtitle: 'Daily & monthly revenue trend', icon: Icons.date_range_outlined, color: AppColors.primaryBlue, route: RouteNames.salesAnalytics),
    _ReportCardItem(title: 'Sales Return Report', subtitle: 'Credit notes & return vouchers', icon: Icons.assignment_return_outlined, color: AppColors.danger, route: RouteNames.salesReturns),
    _ReportCardItem(title: 'Outstanding Receivables', subtitle: 'Overdue customer payments', icon: Icons.call_received, color: AppColors.success, route: RouteNames.receivables),
  ];

  static final List<_ReportCardItem> _purchaseReports = [
    _ReportCardItem(title: 'Purchase Summary', subtitle: 'Supplier billing & order totals', icon: Icons.shopping_bag_outlined, color: AppColors.primaryBlue),
    _ReportCardItem(title: 'Purchase by Supplier', subtitle: 'Vendor wise purchase history', icon: Icons.store_outlined, color: AppColors.primaryBlue, route: RouteNames.supplierDirectory),
    _ReportCardItem(title: 'Purchase by Product', subtitle: 'Product cost & stock addition', icon: Icons.inventory_2_outlined, color: AppColors.primaryBlue),
    _ReportCardItem(title: 'Purchase Return Report', subtitle: 'Debit notes & vendor returns', icon: Icons.settings_backup_restore_outlined, color: AppColors.danger, route: RouteNames.purchaseReturns),
    _ReportCardItem(title: 'Outstanding Payables', subtitle: 'Vendor unpaid bills & aging', icon: Icons.call_made, color: AppColors.danger, route: RouteNames.payables),
  ];

  static final List<_ReportCardItem> _inventoryReports = [
    _ReportCardItem(title: 'Stock Summary', subtitle: 'Current stock quantity & value', icon: Icons.inventory, color: AppColors.warning, route: RouteNames.inventoryAnalytics),
    _ReportCardItem(title: 'Stock Movement', subtitle: 'Inward & outward inventory log', icon: Icons.compare_arrows_outlined, color: AppColors.warning),
    _ReportCardItem(title: 'Stock Valuation', subtitle: 'FIFO / Average cost inventory value', icon: Icons.assessment_outlined, color: AppColors.warning),
    _ReportCardItem(title: 'Low Stock Report', subtitle: 'Reorder point & low quantity alerts', icon: Icons.warning_amber_outlined, color: AppColors.danger, route: RouteNames.inventoryAnalytics),
    _ReportCardItem(title: 'Product-wise Stock', subtitle: 'Detailed SKU quantity ledger', icon: Icons.format_list_bulleted, color: AppColors.warning),
  ];

  static final List<_ReportCardItem> _accountingReports = [
    _ReportCardItem(title: 'Day Book', subtitle: 'Daily financial transaction log', icon: Icons.auto_stories_outlined, color: AppColors.primaryBlue, route: RouteNames.dailyBook),
    _ReportCardItem(title: 'Ledger', subtitle: 'Account-wise transaction history', icon: Icons.account_balance_wallet_outlined, color: AppColors.primaryBlue, route: RouteNames.ledger),
    _ReportCardItem(title: 'Trial Balance', subtitle: 'Debit & credit ledger balance sheet', icon: Icons.balance_outlined, color: AppColors.primaryBlue, route: RouteNames.trialBalance),
    _ReportCardItem(title: 'Profit & Loss', subtitle: 'Net income, gross profit & expenses', icon: Icons.analytics_outlined, color: AppColors.success, route: RouteNames.financialAnalytics),
    _ReportCardItem(title: 'Balance Sheet', subtitle: 'Assets, liabilities & equity statement', icon: Icons.account_balance_outlined, color: AppColors.primaryBlue, route: RouteNames.financialAnalytics),
    _ReportCardItem(title: 'Cash Flow', subtitle: 'Operating & financing cash flow', icon: Icons.waves_outlined, color: Colors.teal),
    _ReportCardItem(title: 'Journal Register', subtitle: 'All posted journal vouchers', icon: Icons.edit_note, color: Colors.purple, route: RouteNames.journal),
    _ReportCardItem(title: 'Contra Register', subtitle: 'Cash & bank transfer register', icon: Icons.swap_horiz, color: Colors.teal, route: RouteNames.contra),
  ];

  static final List<_ReportCardItem> _gstReports = [
    _ReportCardItem(title: 'GST Summary', subtitle: 'Tax collected vs Input Tax Credit', icon: Icons.receipt_long_outlined, color: AppColors.primaryBlue, route: RouteNames.gstTaxation),
    _ReportCardItem(title: 'GSTR-1 Report', subtitle: 'Outward sales & tax returns', icon: Icons.file_present_outlined, color: AppColors.primaryBlue, route: RouteNames.gstTaxation),
    _ReportCardItem(title: 'GSTR-3B Report', subtitle: 'Monthly GST summary return', icon: Icons.assignment_outlined, color: AppColors.primaryBlue, route: RouteNames.gstTaxation),
    _ReportCardItem(title: 'Tax Collected (Output)', subtitle: 'Sales tax output ledger', icon: Icons.arrow_downward, color: AppColors.success, route: RouteNames.gstTaxation),
    _ReportCardItem(title: 'Tax Paid (Input)', subtitle: 'Purchase tax input ledger', icon: Icons.arrow_upward, color: AppColors.danger, route: RouteNames.gstTaxation),
    _ReportCardItem(title: 'Input Tax Credit', subtitle: 'Eligible ITC credit register', icon: Icons.credit_score, color: Colors.indigo, route: RouteNames.gstTaxation),
    _ReportCardItem(title: 'HSN / SAC Summary', subtitle: 'HSN code-wise sales & tax report', icon: Icons.grid_view_outlined, color: Colors.teal, route: RouteNames.gstTaxation),
  ];
}

class _ReportCardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? route;

  _ReportCardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.route,
  });
}
