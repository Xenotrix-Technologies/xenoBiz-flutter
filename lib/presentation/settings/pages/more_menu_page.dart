import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../application/bloc/auth_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/business_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../infrastructure/database/app_database.dart';
import '../../widgets/app_card.dart';

class MoreMenuPage extends StatefulWidget {
  const MoreMenuPage({super.key});

  @override
  State<MoreMenuPage> createState() => _MoreMenuPageState();
}

class _MoreMenuPageState extends State<MoreMenuPage> {
  static const List<_MenuCategory> _allSections = [
    _MenuCategory(
      categoryTitle: 'Sales & Invoicing',
      items: [
        _MenuItem(icon: Icons.receipt_long_outlined, title: 'All Invoices', route: RouteNames.invoices, color: AppColors.primaryBlue),
        _MenuItem(icon: Icons.people_alt_outlined, title: 'Customers', route: RouteNames.customers, color: AppColors.primaryBlue),
        _MenuItem(icon: Icons.assignment_return_outlined, title: 'Sales Returns', route: RouteNames.salesReturns, color: AppColors.danger),
        _MenuItem(icon: Icons.analytics_outlined, title: 'Sales Analytics', route: RouteNames.salesAnalytics, color: AppColors.success),
        _MenuItem(icon: Icons.repeat_outlined, title: 'Recurring Invoices', route: RouteNames.recurringInvoices, color: AppColors.primaryBlue, subtitle: 'Auto-recurring billing'),
        _MenuItem(icon: Icons.request_quote_outlined, title: 'Quotations', route: RouteNames.quotations, color: AppColors.primaryBlue, subtitle: 'Price estimates & quotes'),
        _MenuItem(icon: Icons.description_outlined, title: 'Proforma Invoices', route: RouteNames.proformaInvoices, color: AppColors.primaryBlue, subtitle: 'Preliminary invoices'),
        _MenuItem(icon: Icons.local_shipping_outlined, title: 'Delivery Challans', route: RouteNames.deliveryChallans, color: AppColors.primaryBlue, subtitle: 'Goods dispatch notes'),
        _MenuItem(icon: Icons.design_services_outlined, title: 'Services', route: RouteNames.services, color: AppColors.primaryBlue, subtitle: 'Service catalog & pricing'),
        _MenuItem(icon: Icons.note_alt_outlined, title: 'Credit Notes', route: RouteNames.creditNotes, color: AppColors.danger, subtitle: 'Return credit vouchers'),
        _MenuItem(icon: Icons.note_add_outlined, title: 'Debit Notes', route: RouteNames.debitNotes, color: AppColors.warning, subtitle: 'Vendor debit vouchers'),
      ],
    ),
    _MenuCategory(
      categoryTitle: 'Inventory & Purchasing',
      items: [
        _MenuItem(icon: Icons.inventory_2_outlined, title: 'Product Catalog', route: RouteNames.products, color: AppColors.deepNavy, subtitle: 'SKU inventory list'),
        _MenuItem(icon: Icons.shopping_cart_outlined, title: 'Purchases', route: RouteNames.invoices, extra: {'initialType': InvoiceType.purchase}, color: AppColors.primaryBlue, subtitle: 'Vendor purchase bills'),
        _MenuItem(icon: Icons.store_outlined, title: 'Suppliers', route: RouteNames.supplierDirectory, color: AppColors.primaryBlue, subtitle: 'Supplier directory'),
        _MenuItem(icon: Icons.settings_backup_restore_outlined, title: 'Purchase Returns', route: RouteNames.purchaseReturns, color: AppColors.danger, subtitle: 'Goods returned to vendor'),
        _MenuItem(icon: Icons.swap_horiz_outlined, title: 'Stock Transfer', route: RouteNames.stockTransfer, color: AppColors.deepNavy, subtitle: 'Inter-warehouse transfer'),
        _MenuItem(icon: Icons.assessment_outlined, title: 'Stock Valuation', route: RouteNames.stockValuation, color: AppColors.warning, subtitle: 'Inventory valuation report'),
        _MenuItem(icon: Icons.warning_amber_outlined, title: 'Low Stock Report', route: RouteNames.lowStockReport, color: AppColors.danger, subtitle: 'Reorder point alerts'),
        _MenuItem(icon: Icons.compare_arrows_outlined, title: 'Stock Movement', route: RouteNames.stockMovement, color: AppColors.primaryBlue, subtitle: 'Inward & outward log'),
      ],
    ),
    _MenuCategory(
      categoryTitle: 'Finance & Accounting',
      items: [
        _MenuItem(icon: Icons.edit_note_outlined, title: 'Journal', route: RouteNames.journal, color: Colors.purple, subtitle: 'Manual accounting entries'),
        _MenuItem(icon: Icons.swap_horizontal_circle_outlined, title: 'Contra', route: RouteNames.contra, color: Colors.teal, subtitle: 'Cash & bank transfers'),
        _MenuItem(icon: Icons.auto_stories_outlined, title: 'Daily Book', route: RouteNames.dailyBook, color: AppColors.primaryBlue, subtitle: 'Daily financial transactions'),
        _MenuItem(icon: Icons.account_balance_wallet_outlined, title: 'Ledger', route: RouteNames.ledger, color: AppColors.primaryBlue, subtitle: 'Account-wise history'),
        _MenuItem(icon: Icons.account_balance_outlined, title: 'Cash & Bank', route: RouteNames.cashBank, color: AppColors.success, subtitle: 'Balances & accounts'),
        _MenuItem(icon: Icons.call_received_outlined, title: 'Receivables', route: RouteNames.receivables, color: AppColors.success, subtitle: 'Outstanding customer money'),
        _MenuItem(icon: Icons.call_made_outlined, title: 'Payables', route: RouteNames.payables, color: AppColors.danger, subtitle: 'Outstanding supplier bills'),
        _MenuItem(icon: Icons.balance_outlined, title: 'Trial Balance', route: RouteNames.trialBalance, color: AppColors.primaryBlue, subtitle: 'Debit & credit balances'),
      ],
    ),
    _MenuCategory(
      categoryTitle: 'Reports',
      items: [
        _MenuItem(icon: Icons.point_of_sale_outlined, title: 'Reports Hub', route: RouteNames.reports, color: AppColors.warning, subtitle: 'Business & accounting reports'),
        _MenuItem(icon: Icons.bar_chart_outlined, title: 'Sales Reports', route: RouteNames.reports, extra: 0, color: AppColors.primaryBlue, subtitle: 'Revenue & customer reports'),
        _MenuItem(icon: Icons.shopping_bag_outlined, title: 'Purchase Reports', route: RouteNames.reports, extra: 1, color: AppColors.primaryBlue, subtitle: 'Supplier & purchase analytics'),
        _MenuItem(icon: Icons.inventory_outlined, title: 'Inventory Reports', route: RouteNames.reports, extra: 2, color: AppColors.warning, subtitle: 'Stock movement & valuation'),
        _MenuItem(icon: Icons.analytics_outlined, title: 'Accounting Reports', route: RouteNames.reports, extra: 3, color: AppColors.success, subtitle: 'P&L, Balance Sheet & Ledger'),
        _MenuItem(icon: Icons.receipt_long_outlined, title: 'GST & Tax Reports', route: RouteNames.reports, extra: 4, color: Colors.indigo, subtitle: 'Tax summary & returns'),
      ],
    ),
    _MenuCategory(
      categoryTitle: 'GST & Taxation',
      items: [
        _MenuItem(icon: Icons.receipt_long_outlined, title: 'GST Reports', route: RouteNames.gstTaxation, color: AppColors.primaryBlue, subtitle: 'Tax filings & GSTR returns'),
        _MenuItem(icon: Icons.summarize_outlined, title: 'GST Summary', route: RouteNames.gstTaxation, color: AppColors.success, subtitle: 'Output vs Input tax summary'),
        _MenuItem(icon: Icons.percent_outlined, title: 'Tax Summary', route: RouteNames.taxGstSettings, color: Colors.purple, subtitle: 'Tax rate breakdown'),
        _MenuItem(icon: Icons.grid_view_outlined, title: 'HSN/SAC Summary', route: RouteNames.gstTaxation, color: Colors.teal, subtitle: 'HSN code summary report'),
        _MenuItem(icon: Icons.qr_code_2_outlined, title: 'E-Invoice', route: RouteNames.eInvoice, color: Colors.deepOrange, subtitle: 'Generate IRN e-invoices'),
        _MenuItem(icon: Icons.local_shipping_outlined, title: 'E-Way Bill', route: RouteNames.eWayBill, color: AppColors.primaryBlue, subtitle: 'Goods transport bills'),
        _MenuItem(icon: Icons.credit_score_outlined, title: 'Input Tax Credit', route: RouteNames.inputTaxCredit, color: Colors.indigo, subtitle: 'Eligible & claimed ITC'),
        _MenuItem(icon: Icons.settings_applications_outlined, title: 'Tax Settings', route: RouteNames.taxGstSettings, color: AppColors.secondaryText, subtitle: 'GSTIN & tax rates'),
      ],
    ),
    _MenuCategory(
      categoryTitle: 'Business Tools',
      items: [
        _MenuItem(icon: Icons.repeat_outlined, title: 'Recurring Invoices', route: RouteNames.recurringInvoices, color: AppColors.primaryBlue, subtitle: 'Auto-billing schedules'),
        _MenuItem(icon: Icons.notifications_active_outlined, title: 'Payment Reminders', route: RouteNames.automatedReminders, color: AppColors.primaryBlue, subtitle: 'Customer SMS/WhatsApp reminders'),
        _MenuItem(icon: Icons.file_upload_outlined, title: 'Import Data', route: RouteNames.importData, color: AppColors.primaryBlue, subtitle: 'Bulk Excel/CSV data import'),
        _MenuItem(icon: Icons.file_download_outlined, title: 'Export Data', route: RouteNames.exportData, color: AppColors.primaryBlue, subtitle: 'Backup & report export'),
        _MenuItem(icon: Icons.cloud_upload_outlined, title: 'Data Backup', route: RouteNames.backupRestore, color: AppColors.primaryBlue, subtitle: 'Cloud & offline backup'),
        _MenuItem(icon: Icons.sync_outlined, title: 'Offline Sync', route: RouteNames.offlineSync, color: AppColors.primaryBlue, subtitle: 'Local database sync status'),
        _MenuItem(icon: Icons.article_outlined, title: 'Document Templates', route: RouteNames.documentTemplates, color: AppColors.primaryBlue, subtitle: 'Invoice & print designs'),
      ],
    ),
    _MenuCategory(
      categoryTitle: 'System & Settings',
      items: [
        _MenuItem(icon: Icons.cloud_upload_outlined, title: 'Backup & Restore', route: RouteNames.backupRestore, color: AppColors.primaryBlue),
        _MenuItem(icon: Icons.sync_outlined, title: 'Offline Sync', route: RouteNames.offlineSync, color: AppColors.primaryBlue),
        _MenuItem(icon: Icons.people_outline, title: 'Staff & Users', route: RouteNames.staffUsers, color: AppColors.primaryBlue, subtitle: 'Employee roles & access'),
        _MenuItem(icon: Icons.business_outlined, title: 'Business Settings', route: RouteNames.businessProfile, color: AppColors.primaryBlue, subtitle: 'Store profile & address'),
        _MenuItem(icon: Icons.receipt_outlined, title: 'Invoice Settings', route: RouteNames.invoiceSettings, color: AppColors.primaryBlue, subtitle: 'Prefix, Terms & Signatures'),
        _MenuItem(icon: Icons.percent_outlined, title: 'Tax Settings', route: RouteNames.taxGstSettings, color: AppColors.primaryBlue, subtitle: 'GST & tax configuration'),
        _MenuItem(icon: Icons.print_outlined, title: 'Printer Settings', route: RouteNames.printerSettings, color: AppColors.primaryBlue, subtitle: 'Thermal & A4 printer setup'),
        _MenuItem(icon: Icons.notifications_none_outlined, title: 'Notification Settings', route: RouteNames.notificationSettings, color: AppColors.primaryBlue),
        _MenuItem(icon: Icons.settings_outlined, title: 'Settings', route: RouteNames.settings, color: AppColors.secondaryText),
      ],
    ),
  ];

  String _searchQuery = '';
  List<_MenuItem> _recentlyUsed = [];

  @override
  void initState() {
    super.initState();
    _loadRecentlyUsed();
  }

  Future<void> _loadRecentlyUsed() async {
    try {
      final db = getIt<AppDatabase>();
      final raw = await db.getKeyValue('recently_used_tools');
      if (raw != null) {
        final List list = jsonDecode(raw.toString());
        final allItems = _allSections.expand((cat) => cat.items).toList();
        final loaded = <_MenuItem>[];
        for (var title in list) {
          for (var item in allItems) {
            if (item.title == title.toString()) {
              loaded.add(item);
              break;
            }
          }
        }
        setState(() {
          _recentlyUsed = loaded;
        });
      }
    } catch (_) {}
  }

  Future<void> _trackToolTap(_MenuItem item) async {
    setState(() {
      _recentlyUsed.removeWhere((i) => i.title == item.title);
      _recentlyUsed.insert(0, item);
      if (_recentlyUsed.length > 6) {
        _recentlyUsed = _recentlyUsed.sublist(0, 6);
      }
    });

    try {
      final db = getIt<AppDatabase>();
      final titles = _recentlyUsed.map((i) => i.title).toList();
      await db.putKeyValue('recently_used_tools', jsonEncode(titles));
    } catch (_) {}

    if (mounted) {
      context.push(item.route, extra: item.extra);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allSections = _allSections;
    final isSearching = _searchQuery.trim().isNotEmpty;
    final searchResults = <_MenuItem>[];

    if (isSearching) {
      final q = _searchQuery.toLowerCase();
      for (var cat in allSections) {
        for (var item in cat.items) {
          if (item.title.toLowerCase().contains(q) ||
              (item.subtitle != null && item.subtitle!.toLowerCase().contains(q)) ||
              cat.categoryTitle.toLowerCase().contains(q)) {
            searchResults.add(item);
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'More Options & Business Hub',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User & Store Profile Header Card
            const _UserProfileHeaderCard(),
            const SizedBox(height: 16),

            // 2. Live Search Field (Section 14)
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search tools, reports, accounting...',
                prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.secondaryText),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
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
            const SizedBox(height: 14),

            // 3. Recently Used Quick Access Chips (Section 14)
            if (!isSearching && _recentlyUsed.isNotEmpty) ...[
              const Row(
                children: [
                  Icon(Icons.history, size: 16, color: AppColors.secondaryText),
                  SizedBox(width: 6),
                  Text(
                    'Recently Used',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondaryText,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _recentlyUsed.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () => _trackToolTap(item),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.icon, size: 14, color: item.color),
                              const SizedBox(width: 6),
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkBlueText,
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
              const SizedBox(height: 16),
            ],

            // Search Results Mode vs Full Categorized Hub
            if (isSearching) ...[
              Text(
                'Search Results (${searchResults.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
              const SizedBox(height: 10),
              searchResults.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No matching tools or reports found.',
                          style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                        ),
                      ),
                    )
                  : _MenuGrid(
                      items: searchResults,
                      onTapItem: _trackToolTap,
                    ),
            ] else ...[
              // Full Categorized Categories in exact strict order (Section 9)
              ...allSections.map((sec) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sec.categoryTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlueText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _MenuGrid(
                      items: sec.items,
                      onTapItem: _trackToolTap,
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }),
            ],

            // 9. Sign Out of Account (Section 8 & 9)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                  context.go(RouteNames.login);
                },
                icon: const Icon(Icons.logout, color: AppColors.danger, size: 20),
                label: const Text(
                  'Sign Out of Account',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MenuCategory {
  final String categoryTitle;
  final List<_MenuItem> items;

  const _MenuCategory({
    required this.categoryTitle,
    required this.items,
  });
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String route;
  final Color color;
  final String? subtitle;
  final Object? extra;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.color,
    this.subtitle,
    this.extra,
  });
}

class _MenuGrid extends StatelessWidget {
  final List<_MenuItem> items;
  final Function(_MenuItem) onTapItem;

  const _MenuGrid({
    required this.items,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, idx) {
        final item = items[idx];
        return AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          onTap: () => onTapItem(item),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBlueText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserProfileHeaderCard extends StatefulWidget {
  const _UserProfileHeaderCard();

  @override
  State<_UserProfileHeaderCard> createState() => _UserProfileHeaderCardState();
}

class _UserProfileHeaderCardState extends State<_UserProfileHeaderCard> {
  BusinessEntity? _serverBusiness;

  @override
  void initState() {
    super.initState();
    _fetchProfileFromServer();
  }

  Future<void> _fetchProfileFromServer() async {
    try {
      final authRepo = getIt<AuthRepository>();
      final business = await authRepo.getBusinessProfile();
      if (mounted) {
        setState(() {
          _serverBusiness = business;
        });
      }
    } catch (_) {}
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'CN';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'CN';
  }

  Widget _buildLogoWidget(String? logoUrl, String businessName) {
    final defaultLogo = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        _getInitials(businessName),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
    );

    if (logoUrl == null || logoUrl.trim().isEmpty) {
      return defaultLogo;
    }

    final url = logoUrl.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => defaultLogo,
        ),
      );
    } else if (url.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          url,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => defaultLogo,
        ),
      );
    }

    return defaultLogo;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String? fetchedName;
        String? fetchedCategory;
        String? fetchedLogo;

        if (_serverBusiness != null) {
          if (_serverBusiness!.name.trim().isNotEmpty) {
            fetchedName = _serverBusiness!.name.trim();
          }
          if (_serverBusiness!.category.trim().isNotEmpty) {
            fetchedCategory = _serverBusiness!.category.trim();
          }
          if (_serverBusiness!.logoUrl != null &&
              _serverBusiness!.logoUrl!.trim().isNotEmpty) {
            fetchedLogo = _serverBusiness!.logoUrl!.trim();
          }
        } else if (state is AuthenticatedState && state.business != null) {
          if (state.business!.name.trim().isNotEmpty) {
            fetchedName = state.business!.name.trim();
          }
          if (state.business!.category.trim().isNotEmpty) {
            fetchedCategory = state.business!.category.trim();
          }
          if (state.business!.logoUrl != null &&
              state.business!.logoUrl!.trim().isNotEmpty) {
            fetchedLogo = state.business!.logoUrl!.trim();
          }
        }

        final displayBusinessName =
            (fetchedName != null && fetchedName.isNotEmpty)
                ? fetchedName
                : 'Company Name';
        final displayCategory =
            (fetchedCategory != null && fetchedCategory.isNotEmpty)
                ? fetchedCategory
                : 'Company Category';

        return AppCard(
          onTap: () => context.push(RouteNames.businessProfile),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              _buildLogoWidget(fetchedLogo, displayBusinessName),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayBusinessName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.darkBlueText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayCategory,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.secondaryText),
            ],
          ),
        );
      },
    );
  }
}
