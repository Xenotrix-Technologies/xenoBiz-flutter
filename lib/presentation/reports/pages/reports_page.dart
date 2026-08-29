import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';

// ============================================================================
// REPORT HUB DIRECTORY PAGE
// ============================================================================

class ReportsPage extends StatefulWidget {
  final int initialCategoryIndex;
  const ReportsPage({super.key, this.initialCategoryIndex = 0});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String? _expandedCategoryTitle;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Report Hub'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search reports (e.g. Sales, GST, Stock, Ledger)...',
                  hintStyle: const TextStyle(
                    fontSize: 12.5,
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // SECTION 1: GST & TAXATION (MOVED TO TOP AS REQUESTED)
            _buildSectionHeader(
              title: 'GST & Taxation',
              subtitle: 'Tax summaries, HSN codes & compliance tools',
            ),
            const SizedBox(height: 10),
            ..._gstTaxationCategories.map((cat) => _buildExpandableReportTile(
                  context: context,
                  category: cat,
                  query: query,
                )),

            const SizedBox(height: 24),

            // SECTION 2: GENERAL REPORT HUB
            _buildSectionHeader(
              title: 'Report Hub',
              subtitle: 'Business performance analytics & insights',
            ),
            const SizedBox(height: 10),
            ..._generalReportCategories.map((cat) => _buildExpandableReportTile(
                  context: context,
                  category: cat,
                  query: query,
                )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.darkBlueText,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableReportTile({
    required BuildContext context,
    required _MainReportCategory category,
    required String query,
  }) {
    // Check if query matches main title, subtitle, or any sub-report title
    final bool mainMatches = query.isEmpty ||
        category.title.toLowerCase().contains(query) ||
        category.description.toLowerCase().contains(query);

    final matchingSubReports = category.subReports.where((sub) {
      if (query.isEmpty) return true;
      return sub.title.toLowerCase().contains(query);
    }).toList();

    if (!mainMatches && matchingSubReports.isEmpty) {
      return const SizedBox.shrink();
    }

    // Auto-expand when searching and a sub-report matches
    final bool isSearchAutoExpanded = query.isNotEmpty && matchingSubReports.isNotEmpty;
    final bool isExpanded = isSearchAutoExpanded || (_expandedCategoryTitle == category.title);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: category.isCompliance
              ? AppColors.primaryBlue.withValues(alpha: 0.3)
              : AppColors.border,
          width: category.isCompliance ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Tile Header
          InkWell(
            onTap: () {
              setState(() {
                if (_expandedCategoryTitle == category.title) {
                  _expandedCategoryTitle = null;
                } else {
                  _expandedCategoryTitle = category.title;
                }
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(category.icon, color: category.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              category.title,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkBlueText,
                              ),
                            ),
                            if (category.isCompliance)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6F2FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'GOV',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0066CC),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          category.description,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: AppColors.secondaryText.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Animated Sub-report Rows
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            child: isExpanded
                ? Column(
                    children: [
                      const Divider(height: 1, thickness: 1, color: AppColors.border),
                      Container(
                        color: const Color(0xFFF9FAFC),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: matchingSubReports.map((sub) {
                            return InkWell(
                              onTap: () {
                                context.push(sub.route, extra: sub.extra);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 11),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: category.color
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(sub.icon,
                                          size: 15, color: category.color),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        sub.title,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkBlueText,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded,
                                        size: 18,
                                        color: AppColors.secondaryText),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CATEGORIES & SUB-REPORTS DATA
  // ==========================================================================

  static final List<_MainReportCategory> _gstTaxationCategories = [
    _MainReportCategory(
      title: 'GST Report',
      description: 'GST transaction and filing reports',
      icon: Icons.receipt_long_outlined,
      color: Colors.indigo,
      isCompliance: true,
      subReports: const [
        _ReportSubItem(
            title: 'GST Summary',
            icon: Icons.summarize_outlined,
            route: RouteNames.gstTaxation,
            extra: 0),
        _ReportSubItem(
            title: 'Outward Supplies',
            icon: Icons.outbox_outlined,
            route: RouteNames.gstTaxation,
            extra: 1),
        _ReportSubItem(
            title: 'GSTR-1 Report',
            icon: Icons.file_present_outlined,
            route: RouteNames.gstTaxation,
            extra: 2),
        _ReportSubItem(
            title: 'GSTR-3B Return',
            icon: Icons.assignment_outlined,
            route: RouteNames.gstTaxation,
            extra: 3),
      ],
    ),
    _MainReportCategory(
      title: 'GST Summary',
      description: 'Overview of GST collected and paid',
      icon: Icons.summarize_outlined,
      color: Colors.indigo,
      subReports: const [
        _ReportSubItem(
            title: 'GST Collected (Output)',
            icon: Icons.arrow_downward,
            route: RouteNames.gstTaxation,
            extra: 0),
        _ReportSubItem(
            title: 'Input Tax Credit (ITC)',
            icon: Icons.credit_score,
            route: RouteNames.gstTaxation,
            extra: 1),
        _ReportSubItem(
            title: 'Net Tax Liability',
            icon: Icons.account_balance_outlined,
            route: RouteNames.gstTaxation,
            extra: 2),
      ],
    ),
    _MainReportCategory(
      title: 'Tax Summary',
      description: 'Tax collection and liability summary',
      icon: Icons.percent_outlined,
      color: Colors.purple,
      subReports: const [
        _ReportSubItem(
            title: 'Sales Tax Summary',
            icon: Icons.monetization_on_outlined,
            route: RouteNames.taxGstSettings),
        _ReportSubItem(
            title: 'Purchase Tax Summary',
            icon: Icons.shopping_cart_outlined,
            route: RouteNames.taxGstSettings),
        _ReportSubItem(
            title: 'Tax Rate Breakdown',
            icon: Icons.pie_chart_outline,
            route: RouteNames.taxGstSettings),
      ],
    ),
    _MainReportCategory(
      title: 'HSN/SAC Summary',
      description: 'HSN and SAC-wise tax summary',
      icon: Icons.grid_view_outlined,
      color: Colors.teal,
      subReports: const [
        _ReportSubItem(
            title: 'Goods HSN Summary',
            icon: Icons.inventory_2_outlined,
            route: RouteNames.gstTaxation),
        _ReportSubItem(
            title: 'Services SAC Summary',
            icon: Icons.design_services_outlined,
            route: RouteNames.gstTaxation),
      ],
    ),
    _MainReportCategory(
      title: 'E-Way Bill',
      description: 'E-Way Bill generation and reports',
      icon: Icons.local_shipping_outlined,
      color: const Color(0xFF0066CC),
      isCompliance: true,
      subReports: const [
        _ReportSubItem(
            title: 'Generated E-Way Bills',
            icon: Icons.check_circle_outline,
            route: RouteNames.eWayBill),
        _ReportSubItem(
            title: 'Cancelled E-Way Bills',
            icon: Icons.cancel_outlined,
            route: RouteNames.eWayBill),
      ],
    ),
  ];

  static final List<_MainReportCategory> _generalReportCategories = [
    _MainReportCategory(
      title: 'Sales Report',
      description: 'View detailed sales performance',
      icon: Icons.bar_chart_outlined,
      color: const Color(0xFF0066CC),
      subReports: const [
        _ReportSubItem(
            title: 'Sales Summary',
            icon: Icons.insights,
            route: RouteNames.salesAnalytics,
            extra: 0),
        _ReportSubItem(
            title: 'Sales by Customer',
            icon: Icons.people_outline,
            route: RouteNames.salesAnalytics,
            extra: 1),
        _ReportSubItem(
            title: 'Sales by Product',
            icon: Icons.category_outlined,
            route: RouteNames.salesAnalytics,
            extra: 2),
        _ReportSubItem(
            title: 'Sales by Date',
            icon: Icons.date_range_outlined,
            route: RouteNames.salesAnalytics,
            extra: 3),
        _ReportSubItem(
            title: 'Sales Returns',
            icon: Icons.assignment_return_outlined,
            route: RouteNames.salesReturns),
      ],
    ),
    _MainReportCategory(
      title: 'Purchase Report',
      description: 'Analyze purchase transactions',
      icon: Icons.shopping_bag_outlined,
      color: const Color(0xFF0066CC),
      subReports: const [
        _ReportSubItem(
            title: 'Purchase Summary',
            icon: Icons.store_outlined,
            route: RouteNames.supplierDirectory),
        _ReportSubItem(
            title: 'Purchase by Supplier',
            icon: Icons.people_outline,
            route: RouteNames.supplierDirectory),
        _ReportSubItem(
            title: 'Purchase Returns',
            icon: Icons.settings_backup_restore_outlined,
            route: RouteNames.purchaseReturns),
        _ReportSubItem(
            title: 'Outstanding Payables',
            icon: Icons.call_made,
            route: RouteNames.payables),
      ],
    ),
    _MainReportCategory(
      title: 'Inventory Report',
      description: 'Stock and inventory insights',
      icon: Icons.inventory_outlined,
      color: Colors.orange,
      subReports: const [
        _ReportSubItem(
            title: 'Stock Summary',
            icon: Icons.inventory,
            route: RouteNames.inventoryAnalytics,
            extra: 0),
        _ReportSubItem(
            title: 'Low Stock Report',
            icon: Icons.warning_amber_outlined,
            route: RouteNames.inventoryAnalytics,
            extra: 1),
        _ReportSubItem(
            title: 'Product Stock Ledger',
            icon: Icons.format_list_bulleted,
            route: RouteNames.inventoryAnalytics,
            extra: 2),
      ],
    ),
    _MainReportCategory(
      title: 'Account Report',
      description: 'Financial account reports',
      icon: Icons.analytics_outlined,
      color: Colors.teal,
      subReports: const [
        _ReportSubItem(
            title: 'Account Ledger',
            icon: Icons.account_balance_wallet_outlined,
            route: RouteNames.ledger),
        _ReportSubItem(
            title: 'Day Book',
            icon: Icons.auto_stories_outlined,
            route: RouteNames.dailyBook),
        _ReportSubItem(
            title: 'Trial Balance',
            icon: Icons.balance_outlined,
            route: RouteNames.trialBalance),
        _ReportSubItem(
            title: 'Profit & Loss',
            icon: Icons.analytics_outlined,
            route: RouteNames.financialAnalytics,
            extra: 0),
        _ReportSubItem(
            title: 'Balance Sheet',
            icon: Icons.account_balance_outlined,
            route: RouteNames.financialAnalytics,
            extra: 1),
        _ReportSubItem(
            title: 'Outstanding Receivables',
            icon: Icons.call_received,
            route: RouteNames.receivables),
      ],
    ),
  ];
}

class _MainReportCategory {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isCompliance;
  final List<_ReportSubItem> subReports;

  _MainReportCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isCompliance = false,
    required this.subReports,
  });
}

class _ReportSubItem {
  final String title;
  final IconData icon;
  final String route;
  final Object? extra;

  const _ReportSubItem({
    required this.title,
    required this.icon,
    required this.route,
    this.extra,
  });
}
