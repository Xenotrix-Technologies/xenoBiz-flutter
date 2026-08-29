import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../infrastructure/database/app_database.dart';

enum BusinessHubViewMode { list, grid }

class MoreMenuPage extends StatefulWidget {
  const MoreMenuPage({super.key});

  @override
  State<MoreMenuPage> createState() => _MoreMenuPageState();
}

class _SubReportItem {
  final String title;
  final IconData icon;
  final String route;
  final Object? extra;

  const _SubReportItem({
    required this.title,
    required this.icon,
    required this.route,
    this.extra,
  });
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String description;
  final String? route;
  final Color color;
  final Object? extra;
  final bool isComplianceTool;
  final bool isReportTool;
  final List<_SubReportItem>? subReports;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.description,
    this.route,
    required this.color,
    this.extra,
    this.isComplianceTool = false,
    this.isReportTool = false,
    this.subReports,
  });
}

class _MenuCategory {
  final String categoryTitle;
  final String categorySubtitle;
  final List<_MenuItem> items;

  const _MenuCategory({
    required this.categoryTitle,
    required this.categorySubtitle,
    required this.items,
  });
}

class _MoreMenuPageState extends State<MoreMenuPage> {
  static const List<_MenuCategory> _categories = [
    _MenuCategory(
      categoryTitle: 'General',
      categorySubtitle: 'Core business operations & account management',
      items: [
        _MenuItem(
          icon: Icons.people_alt_outlined,
          title: 'Customers & Suppliers',
          description: 'Manage customers, suppliers accounts',
          route: RouteNames.moreCustomers,
          color: Color(0xFF0066CC),
        ),
        _MenuItem(
          icon: Icons.category_outlined,
          title: 'Income & Expense Accounts',
          description: 'Manage income & expense categories',
          route: RouteNames.categories,
          color: Colors.purple,
        ),
        _MenuItem(
          icon: Icons.analytics_outlined,
          title: 'Sales Analytics',
          description: 'Track sales performance',
          route: RouteNames.salesAnalytics,
          color: Colors.teal,
        ),
        _MenuItem(
          icon: Icons.request_quote_outlined,
          title: 'Quotations',
          description: 'Create and manage quotations',
          route: RouteNames.quotations,
          color: Color(0xFF0066CC),
        ),
        _MenuItem(
          icon: Icons.local_shipping_outlined,
          title: 'Delivery Challans',
          description: 'Manage goods dispatch documents',
          route: RouteNames.deliveryChallans,
          color: Color(0xFF0066CC),
        ),
        _MenuItem(
          icon: Icons.design_services_outlined,
          title: 'Services',
          description: 'Manage service items',
          route: RouteNames.services,
          color: Colors.indigo,
        ),
        _MenuItem(
          icon: Icons.note_alt_outlined,
          title: 'Credit & Debit Notes',
          description: 'Create and manage credit & debit notes',
          route: RouteNames.creditNotes,
          color: AppColors.primary,
        ),
        _MenuItem(
          icon: Icons.local_shipping_outlined,
          title: 'E-Way Bill',
          description: 'E-Way Bill generation',
          route: RouteNames.eWayBill,
          color: Color(0xFF0066CC),
          isComplianceTool: true,
          subReports: [],
        ),
      ],
    ),
    _MenuCategory(
      categoryTitle: 'Finance & Accounting',
      categorySubtitle: 'Double-entry bookkeeping & statement ledgers',
      items: [
        _MenuItem(
          icon: Icons.edit_note_outlined,
          title: 'Journal',
          description: 'Record adjustment entries',
          route: RouteNames.journal,
          color: Colors.purple,
        ),
        _MenuItem(
          icon: Icons.swap_horizontal_circle_outlined,
          title: 'Contra',
          description: 'Manage cash and bank transfers',
          route: RouteNames.contra,
          color: Colors.teal,
        ),
        _MenuItem(
          icon: Icons.auto_stories_outlined,
          title: 'Daily Book',
          description: 'View daily account transactions',
          route: RouteNames.dailyBook,
          color: Color(0xFF0066CC),
        ),
        _MenuItem(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Ledger',
          description: 'View account-wise transactions',
          route: RouteNames.ledger,
          color: Color(0xFF0066CC),
        ),
        _MenuItem(
          icon: Icons.call_received_outlined,
          title: 'Receivables',
          description: 'Track money to receive',
          route: RouteNames.receivables,
          color: AppColors.success,
        ),
        _MenuItem(
          icon: Icons.call_made_outlined,
          title: 'Payables',
          description: 'Track money to pay',
          route: RouteNames.payables,
          color: AppColors.danger,
        ),
      ],
    ),
    _MenuCategory(
      categoryTitle: 'Report Hub',
      categorySubtitle: 'Business performance analytics & insights',
      items: [
        _MenuItem(
          icon: Icons.bar_chart_outlined,
          title: 'Sales Report',
          description: 'View detailed sales performance',
          route: RouteNames.salesAnalytics,
          color: Color(0xFF0066CC),
          isReportTool: true,
          subReports: [
            _SubReportItem(
                title: 'Sales Summary',
                icon: Icons.insights,
                route: RouteNames.salesAnalytics,
                extra: 0),
            _SubReportItem(
                title: 'Sales by Customer',
                icon: Icons.people_outline,
                route: RouteNames.salesAnalytics,
                extra: 1),
            _SubReportItem(
                title: 'Sales by Product',
                icon: Icons.category_outlined,
                route: RouteNames.salesAnalytics,
                extra: 2),
            _SubReportItem(
                title: 'Sales by Date',
                icon: Icons.date_range_outlined,
                route: RouteNames.salesAnalytics,
                extra: 3),
            _SubReportItem(
                title: 'Sales Returns',
                icon: Icons.assignment_return_outlined,
                route: RouteNames.salesReturns),
          ],
        ),
        _MenuItem(
          icon: Icons.shopping_bag_outlined,
          title: 'Purchase Report',
          description: 'Analyze purchase transactions',
          route: RouteNames.supplierDirectory,
          color: Color(0xFF0066CC),
          isReportTool: true,
          subReports: [
            _SubReportItem(
                title: 'Purchase Summary',
                icon: Icons.store_outlined,
                route: RouteNames.supplierDirectory),
            _SubReportItem(
                title: 'Purchase by Supplier',
                icon: Icons.people_outline,
                route: RouteNames.supplierDirectory),
            _SubReportItem(
                title: 'Purchase Returns',
                icon: Icons.settings_backup_restore_outlined,
                route: RouteNames.purchaseReturns),
            _SubReportItem(
                title: 'Outstanding Payables',
                icon: Icons.call_made,
                route: RouteNames.payables),
          ],
        ),
        _MenuItem(
          icon: Icons.inventory_outlined,
          title: 'Inventory Report',
          description: 'Stock and inventory insights',
          route: RouteNames.inventoryAnalytics,
          color: Colors.orange,
          isReportTool: true,
          subReports: [
            _SubReportItem(
                title: 'Stock Summary',
                icon: Icons.inventory,
                route: RouteNames.inventoryAnalytics,
                extra: 0),
            _SubReportItem(
                title: 'Low Stock Report',
                icon: Icons.warning_amber_outlined,
                route: RouteNames.inventoryAnalytics,
                extra: 1),
            _SubReportItem(
                title: 'Product Stock Ledger',
                icon: Icons.format_list_bulleted,
                route: RouteNames.inventoryAnalytics,
                extra: 2),
          ],
        ),
        _MenuItem(
          icon: Icons.analytics_outlined,
          title: 'Account Report',
          description: 'Financial account reports',
          route: RouteNames.ledger,
          color: Colors.teal,
          isReportTool: true,
          subReports: [
            _SubReportItem(
                title: 'Account Ledger',
                icon: Icons.account_balance_wallet_outlined,
                route: RouteNames.ledger),
            _SubReportItem(
                title: 'Day Book',
                icon: Icons.auto_stories_outlined,
                route: RouteNames.dailyBook),
            _SubReportItem(
                title: 'Trial Balance',
                icon: Icons.balance_outlined,
                route: RouteNames.trialBalance),
            _SubReportItem(
                title: 'Profit & Loss',
                icon: Icons.analytics_outlined,
                route: RouteNames.financialAnalytics,
                extra: 0),
            _SubReportItem(
                title: 'Balance Sheet',
                icon: Icons.account_balance_outlined,
                route: RouteNames.financialAnalytics,
                extra: 1),
            _SubReportItem(
                title: 'Outstanding Receivables',
                icon: Icons.call_received,
                route: RouteNames.receivables),
          ],
        ),
        _MenuItem(
          icon: Icons.receipt_long_outlined,
          title: 'GST Report',
          description: 'GST transaction and filing reports',
          route: RouteNames.gstTaxation,
          color: Colors.indigo,
          isComplianceTool: true,
          subReports: [
            _SubReportItem(
                title: 'GST Summary',
                icon: Icons.summarize_outlined,
                route: RouteNames.gstTaxation,
                extra: 0),
            _SubReportItem(
                title: 'Outward Supplies',
                icon: Icons.outbox_outlined,
                route: RouteNames.gstTaxation,
                extra: 1),
            _SubReportItem(
                title: 'GSTR-1 Report',
                icon: Icons.file_present_outlined,
                route: RouteNames.gstTaxation,
                extra: 2),
            _SubReportItem(
                title: 'GSTR-3B Return',
                icon: Icons.assignment_outlined,
                route: RouteNames.gstTaxation,
                extra: 3),
          ],
        ),
        _MenuItem(
          icon: Icons.summarize_outlined,
          title: 'GST Summary',
          description: 'Overview of GST collected and paid',
          route: RouteNames.gstTaxation,
          color: Colors.indigo,
          subReports: [
            _SubReportItem(
                title: 'GST Collected (Output)',
                icon: Icons.arrow_downward,
                route: RouteNames.gstTaxation,
                extra: 0),
            _SubReportItem(
                title: 'Input Tax Credit (ITC)',
                icon: Icons.credit_score,
                route: RouteNames.gstTaxation,
                extra: 1),
            _SubReportItem(
                title: 'Net Tax Liability',
                icon: Icons.account_balance_outlined,
                route: RouteNames.gstTaxation,
                extra: 2),
          ],
        ),
        _MenuItem(
          icon: Icons.percent_outlined,
          title: 'Tax Summary',
          description: 'Tax collection and liability summary',
          route: RouteNames.taxGstSettings,
          color: Colors.purple,
          subReports: [
            _SubReportItem(
                title: 'Sales Tax Summary',
                icon: Icons.monetization_on_outlined,
                route: RouteNames.taxGstSettings),
            _SubReportItem(
                title: 'Purchase Tax Summary',
                icon: Icons.shopping_cart_outlined,
                route: RouteNames.taxGstSettings),
            _SubReportItem(
                title: 'Tax Rate Breakdown',
                icon: Icons.pie_chart_outline,
                route: RouteNames.taxGstSettings),
          ],
        ),
        _MenuItem(
          icon: Icons.grid_view_outlined,
          title: 'HSN/SAC Summary',
          description: 'HSN and SAC-wise tax summary',
          route: RouteNames.gstTaxation,
          color: Colors.teal,
          subReports: [
            _SubReportItem(
                title: 'Goods HSN Summary',
                icon: Icons.inventory_2_outlined,
                route: RouteNames.gstTaxation),
            _SubReportItem(
                title: 'Services SAC Summary',
                icon: Icons.design_services_outlined,
                route: RouteNames.gstTaxation),
          ],
        ),
      ],
    ),
    _MenuCategory(
      categoryTitle: 'Business Tools',
      categorySubtitle: 'Utilities, data management & settings',
      items: [
        _MenuItem(
          icon: Icons.notifications_active_outlined,
          title: 'Payment Reminder',
          description: 'Remind parties about pending payments',
          route: RouteNames.automatedReminders,
          color: Color(0xFF0066CC),
        ),
        _MenuItem(
          icon: Icons.file_upload_outlined,
          title: 'Import Data',
          description: 'Import business data',
          route: RouteNames.importData,
          color: Color(0xFF0066CC),
        ),
        _MenuItem(
          icon: Icons.file_download_outlined,
          title: 'Export Data',
          description: 'Export your business data',
          route: RouteNames.exportData,
          color: Color(0xFF0066CC),
        ),
        _MenuItem(
          icon: Icons.people_outline,
          title: 'Staff & Users',
          description: 'Manage staff access and permissions',
          route: RouteNames.staffUsers,
          color: Color(0xFF0066CC),
        ),
        _MenuItem(
          icon: Icons.numbers_outlined,
          title: 'Voucher Prefix',
          description: 'Configure document numbering',
          route: RouteNames.voucherPrefixSettings,
          color: Color(0xFF0066CC),
        ),
        _MenuItem(
          icon: Icons.settings_outlined,
          title: 'Settings',
          description: 'Business, invoice, tax and app settings',
          route: RouteNames.settings,
          color: AppColors.secondaryText,
        ),
      ],
    ),
  ];

  String _searchQuery = '';
  List<_MenuItem> _recentlyUsed = [];
  BusinessHubViewMode _viewMode = BusinessHubViewMode.list;

  @override
  void initState() {
    super.initState();
    _loadRecentlyUsed();
    _loadViewMode();
  }

  Future<void> _loadViewMode() async {
    try {
      final db = getIt<AppDatabase>();
      final val = await db.getKeyValue('business_hub_view_mode');
      if (val != null && val.toString() == 'grid') {
        if (mounted) {
          setState(() {
            _viewMode = BusinessHubViewMode.grid;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _toggleViewMode() async {
    final nextMode = _viewMode == BusinessHubViewMode.list
        ? BusinessHubViewMode.grid
        : BusinessHubViewMode.list;
    setState(() {
      _viewMode = nextMode;
    });
    try {
      final db = getIt<AppDatabase>();
      await db.putKeyValue('business_hub_view_mode', nextMode.name);
    } catch (_) {}
  }

  Future<void> _loadRecentlyUsed() async {
    try {
      final db = getIt<AppDatabase>();
      final raw = await db.getKeyValue('recently_used_tools');
      if (raw != null) {
        final List list = jsonDecode(raw.toString());
        final allItems = _categories.expand((cat) => cat.items).toList();
        final loaded = <_MenuItem>[];
        for (var title in list) {
          for (var item in allItems) {
            if (item.title == title.toString() ||
                (item.title == 'Customers & Suppliers' &&
                    (title == 'Customers' || title == 'Suppliers'))) {
              if (!loaded.contains(item)) {
                loaded.add(item);
              }
              break;
            }
          }
        }
        setState(() {
          _recentlyUsed = loaded.take(4).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _trackToolTap(_MenuItem item) async {
    setState(() {
      _recentlyUsed.removeWhere((i) => i.title == item.title);
      _recentlyUsed.insert(0, item);
      if (_recentlyUsed.length > 4) {
        _recentlyUsed = _recentlyUsed.sublist(0, 4);
      }
    });

    try {
      final db = getIt<AppDatabase>();
      final titles = _recentlyUsed.map((i) => i.title).toList();
      await db.putKeyValue('recently_used_tools', jsonEncode(titles));
    } catch (_) {}

    if (!mounted) return;

    if (item.route != null) {
      context.push(item.route!, extra: item.extra);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchQuery.trim().isNotEmpty;
    final searchResults = <_MenuItem>[];

    if (isSearching) {
      final q = _searchQuery.toLowerCase();
      for (var cat in _categories) {
        for (var item in cat.items) {
          if (item.title.toLowerCase().contains(q) ||
              item.description.toLowerCase().contains(q) ||
              cat.categoryTitle.toLowerCase().contains(q)) {
            searchResults.add(item);
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleSpacing: 20,
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Business Hub',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.darkBlueText,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Manage your business, accounting, reports and compliance',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search tools, reports, accounting...',
                      hintStyle: const TextStyle(
                          fontSize: 14, color: AppColors.outline),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFF0066CC), size: 22),
                      suffixIcon: isSearching
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: AppColors.secondaryText),
                              onPressed: () =>
                                  setState(() => _searchQuery = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF4F6F9),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppColors.border, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF0066CC), width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: const Color(0xFFF4F6F9),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: _toggleViewMode,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 1),
                        color: Colors.white,
                      ),
                      child: Tooltip(
                        message: _viewMode == BusinessHubViewMode.list
                            ? 'Switch to Grid View'
                            : 'Switch to List View',
                        child: Icon(
                          _viewMode == BusinessHubViewMode.list
                              ? Icons.grid_view_rounded
                              : Icons.view_list_rounded,
                          color: const Color(0xFF0066CC),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossCount = constraints.maxWidth > 900
                ? 4
                : constraints.maxWidth > 600
                    ? 3
                    : 2;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1050),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeInCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  child: CustomScrollView(
                    key: ValueKey(_viewMode),
                    slivers: [
                      // RECENTLY USED SHORTCUT ROW
                      if (!isSearching && _recentlyUsed.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                            child: Row(
                              children: [
                                const Icon(Icons.history,
                                    size: 15, color: AppColors.secondaryText),
                                const SizedBox(width: 6),
                                const Text(
                                  'Recently Used',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.secondaryText,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: _recentlyUsed.map((item) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: InkWell(
                                            onTap: () => _trackToolTap(item),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                    color: AppColors.border),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(item.icon,
                                                      size: 14,
                                                      color: item.color),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    item.title,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppColors
                                                          .darkBlueText,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // SEARCH RESULTS MODE VS CATEGORIZED HUBS
                      if (isSearching) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                            child: Text(
                              'Search Results (${searchResults.length})',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkBlueText,
                              ),
                            ),
                          ),
                        ),
                        if (searchResults.isEmpty)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Center(
                                child: Text(
                                  'No matching tools, reports, or accounting items found.',
                                  style: TextStyle(
                                      color: AppColors.secondaryText,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                          )
                        else if (_viewMode == BusinessHubViewMode.list)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (ctx, idx) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: _ToolListItem(
                                    item: searchResults[idx],
                                    onTap: () =>
                                        _trackToolTap(searchResults[idx]),
                                  ),
                                ),
                                childCount: searchResults.length,
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (ctx, idx) => _ToolCard(
                                  item: searchResults[idx],
                                  onTap: () =>
                                      _trackToolTap(searchResults[idx]),
                                ),
                                childCount: searchResults.length,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossCount,
                                childAspectRatio: 2.2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                            ),
                          ),
                      ] else ...[
                        // RENDER EACH SECTION
                        ..._categories.expand((sec) {
                          return [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 20, 20, 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sec.categoryTitle,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.darkBlueText,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      sec.categorySubtitle,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondaryText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_viewMode == BusinessHubViewMode.list)
                              SliverPadding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (ctx, idx) {
                                      final item = sec.items[idx];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: _ToolListItem(
                                          item: item,
                                          onTap: () => _trackToolTap(item),
                                        ),
                                      );
                                    },
                                    childCount: sec.items.length,
                                  ),
                                ),
                              )
                            else
                              SliverPadding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                sliver: SliverGrid(
                                  delegate: SliverChildBuilderDelegate(
                                    (ctx, idx) {
                                      final item = sec.items[idx];
                                      return _ToolCard(
                                        item: item,
                                        onTap: () => _trackToolTap(item),
                                      );
                                    },
                                    childCount: sec.items.length,
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossCount,
                                    childAspectRatio: 2.2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                ),
                              ),
                          ];
                        }),
                      ],
                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ToolListItem extends StatefulWidget {
  final _MenuItem item;
  final VoidCallback onTap;

  const _ToolListItem({
    required this.item,
    required this.onTap,
  });

  @override
  State<_ToolListItem> createState() => _ToolListItemState();
}

class _ToolListItemState extends State<_ToolListItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isCompliance = item.isComplianceTool;
    final isReport = item.isReportTool;
    final hasSubReports =
        item.subReports != null && item.subReports!.isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCompliance
                ? const Color(0xFF0066CC).withValues(alpha: 0.3)
                : isReport
                    ? Colors.teal.withValues(alpha: 0.2)
                    : AppColors.border,
            width: isCompliance ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: hasSubReports
                  ? () => setState(() => _isExpanded = !_isExpanded)
                  : widget.onTap,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkBlueText,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isCompliance)
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
                            item.description,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      hasSubReports
                          ? (_isExpanded
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.chevron_right_rounded)
                          : Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.secondaryText.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
            if (hasSubReports && _isExpanded) ...[
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              Container(
                color: const Color(0xFFF9FAFC),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: item.subReports!.map((sub) {
                    return InkWell(
                      onTap: () {
                        context.push(sub.route, extra: sub.extra);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child:
                                  Icon(sub.icon, size: 14, color: item.color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                sub.title,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkBlueText,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                size: 16, color: AppColors.secondaryText),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final _MenuItem item;
  final VoidCallback onTap;

  const _ToolCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompliance = item.isComplianceTool;
    final isReport = item.isReportTool;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCompliance
                  ? const Color(0xFF0066CC).withValues(alpha: 0.3)
                  : isReport
                      ? Colors.teal.withValues(alpha: 0.2)
                      : AppColors.border,
              width: isCompliance ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlueText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCompliance)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
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
                      item.description,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.secondaryText.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
