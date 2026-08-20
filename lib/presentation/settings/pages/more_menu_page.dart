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
import '../../../infrastructure/storage/hive_service.dart';
import '../../widgets/app_card.dart';

class MoreMenuPage extends StatelessWidget {
  const MoreMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('More Options & Business Hub'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User & Store Profile Header Card
            const _UserProfileHeaderCard(),
            const SizedBox(height: 20),

            const Text(
              'Sales & Invoicing',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText),
            ),
            const SizedBox(height: 10),
            _MenuGrid(
              items: [
                const _MenuItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'All Invoices',
                  route: RouteNames.invoices,
                  color: AppColors.primaryBlue,
                ),
                const _MenuItem(
                  icon: Icons.add_circle_outline,
                  title: 'New Sale Invoice',
                  route: RouteNames.createInvoice,
                  extra: {'invoiceType': InvoiceType.sale},
                  color: AppColors.primaryBlue,
                ),
                const _MenuItem(
                  icon: Icons.assignment_return_outlined,
                  title: 'Sales Returns',
                  route: RouteNames.salesReturns,
                  color: AppColors.primaryBlue,
                ),
                const _MenuItem(
                  icon: Icons.analytics_outlined,
                  title: 'Sales Analytics',
                  route: RouteNames.salesAnalytics,
                  color: AppColors.success,
                ),
                const _MenuItem(
                  icon: Icons.point_of_sale_outlined,
                  title: 'Reports Hub',
                  route: RouteNames.reports,
                  color: AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Inventory & Purchasing',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText),
            ),
            const SizedBox(height: 10),
            _MenuGrid(
              items: [
                const _MenuItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Product Catalog',
                  route: RouteNames.products,
                  color: AppColors.deepNavy,
                ),
                const _MenuItem(
                  icon: Icons.tune_outlined,
                  title: 'Stock Adjustment',
                  route: RouteNames.stockAdjustment,
                  color: AppColors.deepNavy,
                ),
                const _MenuItem(
                  icon: Icons.local_shipping_outlined,
                  title: 'Purchases',
                  route: RouteNames.invoices,
                  extra: {'initialType': InvoiceType.purchase},
                  color: AppColors.primaryBlue,
                ),
                const _MenuItem(
                  icon: Icons.store_outlined,
                  title: 'Suppliers',
                  route: RouteNames.supplierDirectory,
                  color: AppColors.primaryBlue,
                ),
                const _MenuItem(
                  icon: Icons.settings_backup_restore_outlined,
                  title: 'Purchase Returns',
                  route: RouteNames.purchaseReturns,
                  color: AppColors.deepNavy,
                ),
                const _MenuItem(
                  icon: Icons.add_shopping_cart_outlined,
                  title: 'New Purchase Invoice',
                  route: RouteNames.createInvoice,
                  extra: {'invoiceType': InvoiceType.purchase},
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
            const Text(
              'Finance & Accounting',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText),
            ),
            const SizedBox(height: 10),
            _MenuGrid(
              items: [
                const _MenuItem(
                  icon: Icons.arrow_downward_rounded,
                  title: 'Income',
                  route: RouteNames.income,
                  color: AppColors.success,
                ),
                const _MenuItem(
                  icon: Icons.arrow_upward_rounded,
                  title: 'Expenses',
                  route: RouteNames.expense,
                  color: AppColors.danger,
                ),
                const _MenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Daily Ledger',
                  route: RouteNames.dailyLedger,
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'CRM & Communication',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText),
            ),
            const SizedBox(height: 10),
            _MenuGrid(
              items: [
                const _MenuItem(
                  icon: Icons.dashboard_customize_outlined,
                  title: 'CRM Dashboard',
                  route: RouteNames.crmDashboard,
                  color: AppColors.primaryBlue,
                ),
                const _MenuItem(
                  icon: Icons.leaderboard_outlined,
                  title: 'Lead Pipeline',
                  route: RouteNames.leadPipeline,
                  color: AppColors.success,
                ),
                const _MenuItem(
                  icon: Icons.notifications_active_outlined,
                  title: 'Follow-ups',
                  route: RouteNames.followUps,
                  color: AppColors.warning,
                ),
                const _MenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Outstanding',
                  route: RouteNames.crmOutstanding,
                  color: AppColors.danger,
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'System & Settings',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText),
            ),
            const SizedBox(height: 10),
            _MenuGrid(
              items: [
                const _MenuItem(
                  icon: Icons.cloud_upload_outlined,
                  title: 'Backup & Restore',
                  route: RouteNames.backupRestore,
                  color: AppColors.primaryBlue,
                ),
                const _MenuItem(
                  icon: Icons.sync_outlined,
                  title: 'Offline Sync',
                  route: RouteNames.offlineSync,
                  color: AppColors.primaryBlue,
                ),
                const _MenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  route: RouteNames.settings,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sign out button
            Center(
              child: TextButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                  context.go(RouteNames.login);
                },
                icon:
                    const Icon(Icons.logout, color: AppColors.danger, size: 20),
                label: const Text(
                  'Sign Out of Account',
                  style: TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
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

class _MenuItem {
  final IconData icon;
  final String title;
  final String route;
  final Color color;
  final Object? extra;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.color,
    this.extra,
  });
}

class _MenuGrid extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, idx) {
        final item = items[idx];
        return AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          onTap: () => context.push(item.route, extra: item.extra),
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
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlueText,
                  ),
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
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        _getInitials(businessName),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
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
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          url,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => defaultLogo,
        ),
      );
    } else if (url.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          url,
          width: 50,
          height: 50,
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
        } else {
          try {
            final hive = getIt<HiveService>();
            final bizBox = hive.getBox(HiveService.boxBusiness);
            final cachedBiz = bizBox.get('name')?.toString();
            final cachedCat = bizBox.get('category')?.toString();
            final cachedLogo = bizBox.get('logoUrl')?.toString();

            if (cachedBiz != null && cachedBiz.trim().isNotEmpty) {
              fetchedName = cachedBiz.trim();
            }
            if (cachedCat != null && cachedCat.trim().isNotEmpty) {
              fetchedCategory = cachedCat.trim();
            }
            if (cachedLogo != null && cachedLogo.trim().isNotEmpty) {
              fetchedLogo = cachedLogo.trim();
            }
          } catch (_) {}
        }

        // Apply defaults if backend data is not available
        final displayBusinessName =
            (fetchedName != null && fetchedName.isNotEmpty)
                ? fetchedName
                : 'Company Name';
        final displayCategory =
            (fetchedCategory != null && fetchedCategory.isNotEmpty)
                ? fetchedCategory
                : 'Company Category';

        return AppCard(
          onTap: () => context.push(RouteNames.settings),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    const SizedBox(height: 3),
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
            ],
          ),
        );
      },
    );
  }
}
