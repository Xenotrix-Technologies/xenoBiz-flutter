import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../bloc/accounts_bloc.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/lead_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../presentation/authentication/pages/login_page.dart';
import '../../presentation/authentication/pages/splash_page.dart';
import '../../presentation/customers/pages/accounts_page.dart';
import '../../presentation/customers/pages/customer_details_page.dart';
import '../../presentation/customers/pages/customer_timeline_page.dart';
import '../../presentation/customers/pages/expense_account_details_page.dart';

import '../../presentation/dashboard/pages/dashboard_page.dart';
import '../../presentation/invoices/pages/add_products_page.dart';
import '../../presentation/invoices/pages/create_invoice_page.dart';
import '../../presentation/invoices/pages/daily_ledger_page.dart';
import '../../presentation/invoices/pages/invoice_details_page.dart';
import '../../presentation/invoices/pages/return_voucher_screen.dart';
import '../../presentation/invoices/pages/returns_list_page.dart';
import '../../presentation/invoices/pages/transaction_screen.dart';

import '../../presentation/invoices/pages/invoice_list_page.dart';
import '../../presentation/invoices/pages/invoice_result_page.dart';
import '../../presentation/invoices/pages/payment_page.dart';
import '../../presentation/invoices/pages/sales_overview_page.dart';
import '../../presentation/leads/pages/add_lead_page.dart';
import '../../presentation/crm/pages/crm_dashboard_page.dart';
import '../../presentation/crm/pages/crm_shell_page.dart';
import '../../presentation/crm/pages/crm_settings_page.dart';
import '../../presentation/crm/pages/outstanding_customers_page.dart';
import '../../presentation/leads/pages/followups_page.dart';
import '../../presentation/leads/pages/lead_details_page.dart';
import '../../presentation/leads/pages/lead_pipeline_page.dart';
import '../../presentation/main/pages/main_shell_page.dart';
import '../../presentation/main/pages/create_master_page.dart';
import '../../presentation/onboarding/pages/business_onboarding_page.dart';
import '../../presentation/products/pages/product_details_page.dart';
import '../../presentation/products/pages/product_list_page.dart';
import '../../presentation/products/pages/stock_adjustment_page.dart';
import '../../presentation/products/pages/stock_management_page.dart';
import '../../presentation/purchases/pages/create_purchase_order_page.dart';
import '../../presentation/purchases/pages/purchase_management_page.dart';
import '../../presentation/reports/pages/financial_analytics_page.dart';
import '../../presentation/reports/pages/inventory_analytics_page.dart';
import '../../presentation/reports/pages/reports_page.dart';
import '../../presentation/reports/pages/sales_analytics_page.dart';
import '../../presentation/settings/pages/backup_restore_page.dart';
import '../../presentation/settings/pages/business_profile_page.dart';
import '../../presentation/settings/pages/category_management_page.dart';
import '../../presentation/settings/pages/invoice_settings_page.dart';
import '../../presentation/settings/pages/more_menu_page.dart';
import '../../presentation/settings/pages/settings_page.dart';
import '../../presentation/settings/pages/tax_gst_settings_page.dart';

import '../../presentation/subscription/pages/subscription_paywall_page.dart';
import '../../presentation/suppliers/pages/supplier_details_page.dart';
import '../../presentation/suppliers/pages/supplier_directory_page.dart';
import '../../presentation/sync/pages/offline_sync_center_page.dart';
import '../../presentation/whatsapp/pages/automated_reminders_page.dart';
import '../../presentation/whatsapp/pages/edit_rule_page.dart';
import '../../presentation/whatsapp/pages/new_template_page.dart';
import '../../presentation/whatsapp/pages/whatsapp_templates_page.dart';
import 'route_names.dart';

Widget _buildCreateMasterPage(GoRouterState state) {
  int tab = 0;
  ProductEntity? product;
  CustomerEntity? customer;
  SupplierEntity? supplier;
  ExpenseAccountSummary? expense;

  final extra = state.extra;
  if (extra is int) {
    tab = extra;
  } else if (extra is ProductEntity) {
    tab = 0;
    product = extra;
  } else if (extra is CustomerEntity) {
    tab = 1;
    customer = extra;
  } else if (extra is SupplierEntity) {
    tab = 2;
    supplier = extra;
  } else if (extra is ExpenseAccountSummary) {
    tab = 3;
    expense = extra;
  } else if (extra is Map<String, dynamic>) {
    tab = (extra['tab'] as int?) ?? 0;
    product = extra['product'] as ProductEntity?;
    customer = extra['customer'] as CustomerEntity?;
    supplier = extra['supplier'] as SupplierEntity?;
    expense = extra['expense'] as ExpenseAccountSummary?;
  }

  return CreateMasterPage(
    initialTabIndex: tab,
    productToEdit: product,
    customerToEdit: customer,
    supplierToEdit: supplier,
    expenseToEdit: expense,
  );
}

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNavKey');
  static final GlobalKey<NavigatorState> shellHomeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shellHomeNavKey');
  static final GlobalKey<NavigatorState> shellSalesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shellSalesNavKey');
  static final GlobalKey<NavigatorState> shellAccountsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shellAccountsNavKey');
  static final GlobalKey<NavigatorState> shellStockNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shellStockNavKey');
  static final GlobalKey<NavigatorState> shellMoreNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shellMoreNavKey');
  static final GlobalKey<NavigatorState> shellCrmDashboardNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shellCrmDashboardNavKey');
  static final GlobalKey<NavigatorState> shellCrmLeadsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shellCrmLeadsNavKey');
  static final GlobalKey<NavigatorState> shellCrmOutstandingNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shellCrmOutstandingNavKey');
  static final GlobalKey<NavigatorState> shellCrmSettingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shellCrmSettingsNavKey');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const BusinessOnboardingPage(),
      ),

      // Persistent Shell Navigation for the 5 Main Tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellPage(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home (Dashboard)
          StatefulShellBranch(
            navigatorKey: shellHomeNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.dashboard,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          // Branch 1: Sales
          StatefulShellBranch(
            navigatorKey: shellSalesNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.salesOverview,
                builder: (context, state) => const SalesOverviewPage(),
              ),
            ],
          ),
          // Branch 2: Accounts
          StatefulShellBranch(
            navigatorKey: shellAccountsNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.customers,
                builder: (context, state) => const AccountsPage(),
              ),
            ],
          ),
          // Branch 3: Stock
          StatefulShellBranch(
            navigatorKey: shellStockNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.stockManagement,
                builder: (context, state) => const StockManagementPage(),
              ),
            ],
          ),
          // Branch 4: More
          StatefulShellBranch(
            navigatorKey: shellMoreNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.more,
                builder: (context, state) => const MoreMenuPage(),
              ),
            ],
          ),
        ],
      ),

      // Standalone / Pushed Detail Sub-Routes
      GoRoute(
        path: RouteNames.subscription,
        builder: (context, state) => const SubscriptionPaywallPage(),
      ),
      GoRoute(
        path: RouteNames.customerDetails,
        builder: (context, state) {
          final cust = state.extra as CustomerEntity?;
          return CustomerDetailsPage(customer: cust);
        },
      ),
      GoRoute(
        path: RouteNames.expenseAccountDetails,
        builder: (context, state) {
          final acc = state.extra as ExpenseAccountSummary?;
          return ExpenseAccountDetailsPage(account: acc);
        },
      ),
      GoRoute(
        path: RouteNames.customerTimeline,
        builder: (context, state) => const CustomerTimelinePage(),
      ),

      GoRoute(
        path: RouteNames.products,
        builder: (context, state) => const ProductListPage(),
      ),
      GoRoute(
        path: RouteNames.productDetails,
        builder: (context, state) {
          final prod = state.extra as ProductEntity?;
          return ProductDetailsPage(product: prod);
        },
      ),
      GoRoute(
        path: RouteNames.stockAdjustment,
        builder: (context, state) {
          if (state.extra is ProductEntity) {
            return StockAdjustmentPage(product: state.extra as ProductEntity);
          } else if (state.extra is Map<String, dynamic>) {
            final args = state.extra as Map<String, dynamic>;
            final prod = args['product'] as ProductEntity?;
            final initialAddition = (args['initialAddition'] as bool?) ?? true;
            return StockAdjustmentPage(
                product: prod, initialAddition: initialAddition);
          }
          return const StockAdjustmentPage();
        },
      ),

      GoRoute(
        path: RouteNames.invoices,
        builder: (context, state) {
          InvoiceType? initialType;
          if (state.extra is InvoiceType) {
            initialType = state.extra as InvoiceType;
          } else if (state.extra is Map<String, dynamic>) {
            initialType = (state.extra as Map<String, dynamic>)['initialType']
                as InvoiceType?;
          }
          return InvoiceListPage(initialType: initialType);
        },
      ),
      GoRoute(
        path: RouteNames.dailyLedger,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final initialTab = (args?['initialTab'] as int?) ?? 0;
          final initialDate = args?['initialDate'] as DateTime?;
          return DailyLedgerPage(
            initialTab: initialTab,
            initialDate: initialDate,
          );
        },
      ),
      GoRoute(
        path: RouteNames.createInvoice,
        builder: (context, state) {
          InvoiceType invoiceType = InvoiceType.sale;
          InvoiceEntity? invoiceToEdit;
          if (state.extra is Map<String, dynamic>) {
            final map = state.extra as Map<String, dynamic>;
            if (map['invoiceType'] is InvoiceType) {
              invoiceType = map['invoiceType'] as InvoiceType;
            }
            if (map['invoiceToEdit'] is InvoiceEntity) {
              invoiceToEdit = map['invoiceToEdit'] as InvoiceEntity;
            }
          } else if (state.extra is InvoiceEntity) {
            invoiceToEdit = state.extra as InvoiceEntity;
            invoiceType = invoiceToEdit.type;
          }
          return CreateInvoicePage(
            invoiceType: invoiceType,
            invoiceToEdit: invoiceToEdit,
          );
        },
      ),
      GoRoute(
        path: RouteNames.invoiceDetails,
        builder: (context, state) => const InvoiceDetailsPage(),
      ),
      GoRoute(
        path: RouteNames.salesReturns,
        builder: (context, state) =>
            const ReturnsListPage(type: InvoiceType.sale),
      ),
      GoRoute(
        path: RouteNames.purchaseReturns,
        builder: (context, state) =>
            const ReturnsListPage(type: InvoiceType.purchase),
      ),
      GoRoute(
        path: RouteNames.createReturn,
        builder: (context, state) {
          ReturnType rType = ReturnType.salesReturn;
          dynamic existingReturn;
          if (state.extra is Map<String, dynamic>) {
            final map = state.extra as Map<String, dynamic>;
            if (map['returnType'] is ReturnType) {
              rType = map['returnType'] as ReturnType;
            } else if (map['type'] is InvoiceType) {
              rType = (map['type'] as InvoiceType) == InvoiceType.purchase ? ReturnType.purchaseReturn : ReturnType.salesReturn;
            }
            existingReturn = map['existingReturn'];
          } else if (state.extra is ReturnType) {
            rType = state.extra as ReturnType;
          }
          return ReturnVoucherScreen(
            returnType: rType,
            existingReturn: existingReturn,
          );
        },
      ),
      GoRoute(
        path: RouteNames.income,
        builder: (context, state) {
          dynamic existing;
          if (state.extra is Map<String, dynamic>) {
            existing = (state.extra as Map<String, dynamic>)['existingTransaction'];
          } else {
            existing = state.extra;
          }
          return TransactionScreen(
            transactionType: TransactionType.income,
            existingTransaction: existing,
          );
        },
      ),
      GoRoute(
        path: RouteNames.expense,
        builder: (context, state) {
          dynamic existing;
          if (state.extra is Map<String, dynamic>) {
            existing = (state.extra as Map<String, dynamic>)['existingTransaction'];
          } else {
            existing = state.extra;
          }
          return TransactionScreen(
            transactionType: TransactionType.expense,
            existingTransaction: existing,
          );
        },
      ),
      GoRoute(
        path: RouteNames.categories,
        builder: (context, state) => const CategoryManagementPage(),
      ),
      GoRoute(
        path: RouteNames.invoiceResult,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final invoice = args?['invoice'] as InvoiceEntity;
          final customer = args?['customer'] as CustomerEntity?;
          final paymentMethod = (args?['paymentMethod'] as String?) ?? 'Cash';
          final amountPaid = (args?['amountPaid'] as double?) ?? 0.0;
          final previousBalance = (args?['previousBalance'] as double?) ?? 0.0;
          return InvoiceResultPage(
            invoice: invoice,
            customer: customer,
            paymentMethod: paymentMethod,
            amountPaid: amountPaid,
            previousBalance: previousBalance,
          );
        },
      ),
      GoRoute(
        path: RouteNames.invoiceSettings,
        builder: (context, state) => const InvoiceSettingsPage(),
      ),
      GoRoute(
        path: RouteNames.payment,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final invoice = args?['invoice'] as InvoiceEntity;
          final customer = args?['customer'] as CustomerEntity?;
          return PaymentPage(
            invoice: invoice,
            customer: customer,
          );
        },
      ),
      GoRoute(
        path: RouteNames.addProducts,
        builder: (context, state) {
          final initialItems = (state.extra as List<InvoiceItemEntity>?) ?? [];
          return AddProductsPage(initialItems: initialItems);
        },
      ),
      // Dedicated Shell Route for CRM Module Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return CrmShellPage(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Dashboard
          StatefulShellBranch(
            navigatorKey: shellCrmDashboardNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.crmDashboard,
                builder: (context, state) => const CrmDashboardPage(),
              ),
            ],
          ),
          // Branch 1: Leads & Pipeline
          StatefulShellBranch(
            navigatorKey: shellCrmLeadsNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.leadPipeline,
                builder: (context, state) => const LeadPipelinePage(),
              ),
            ],
          ),
          // Branch 2: Outstanding
          StatefulShellBranch(
            navigatorKey: shellCrmOutstandingNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.crmOutstanding,
                builder: (context, state) => const OutstandingCustomersPage(),
              ),
            ],
          ),
          // Branch 3: Settings
          StatefulShellBranch(
            navigatorKey: shellCrmSettingsNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.crmSettings,
                builder: (context, state) => const CrmSettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.addLead,
        builder: (context, state) {
          final lead = state.extra as LeadEntity?;
          return AddLeadPage(lead: lead);
        },
      ),
      GoRoute(
        path: RouteNames.leadDetails,
        builder: (context, state) {
          final lead = state.extra as LeadEntity?;
          return LeadDetailsPage(lead: lead);
        },
      ),
      GoRoute(
        path: RouteNames.followUps,
        builder: (context, state) => const FollowUpsPage(),
      ),
      GoRoute(
        path: RouteNames.reports,
        builder: (context, state) => const ReportsPage(),
      ),
      GoRoute(
        path: RouteNames.salesAnalytics,
        builder: (context, state) => const SalesAnalyticsPage(),
      ),
      GoRoute(
        path: RouteNames.financialAnalytics,
        builder: (context, state) => const FinancialAnalyticsPage(),
      ),
      GoRoute(
        path: RouteNames.inventoryAnalytics,
        builder: (context, state) => const InventoryAnalyticsPage(),
      ),
      GoRoute(
        path: RouteNames.purchaseManagement,
        builder: (context, state) => const PurchaseManagementPage(),
      ),
      GoRoute(
        path: RouteNames.createPurchaseOrder,
        builder: (context, state) => const CreatePurchaseOrderPage(),
      ),
      GoRoute(
        path: RouteNames.supplierDirectory,
        builder: (context, state) => const SupplierDirectoryPage(),
      ),
      GoRoute(
        path: RouteNames.supplierDetails,
        builder: (context, state) {
          final sup = state.extra as SupplierEntity?;
          return SupplierDetailsPage(supplier: sup);
        },
      ),
      GoRoute(
        path: RouteNames.automatedReminders,
        builder: (context, state) => const AutomatedRemindersPage(),
      ),
      GoRoute(
        path: RouteNames.editRule,
        builder: (context, state) => const EditRulePage(),
      ),
      GoRoute(
        path: RouteNames.whatsappTemplates,
        builder: (context, state) => const WhatsAppTemplatesPage(),
      ),
      GoRoute(
        path: RouteNames.newTemplate,
        builder: (context, state) => const NewTemplatePage(),
      ),
      GoRoute(
        path: RouteNames.offlineSync,
        builder: (context, state) => const OfflineSyncCenterPage(),
      ),
      GoRoute(
        path: RouteNames.backupRestore,
        builder: (context, state) => const BackupRestorePage(),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: RouteNames.businessProfile,
        builder: (context, state) => const BusinessProfilePage(),
      ),
      GoRoute(
        path: RouteNames.taxGstSettings,
        builder: (context, state) => const TaxGstSettingsPage(),
      ),
      GoRoute(
        path: RouteNames.addMaster,
        builder: (context, state) => _buildCreateMasterPage(state),
      ),
      GoRoute(
        path: RouteNames.createMaster,
        builder: (context, state) => _buildCreateMasterPage(state),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('No route defined for ${state.uri}')),
    ),
  );
}
