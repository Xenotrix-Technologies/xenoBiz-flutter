import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/authentication/pages/login_page.dart';
import '../../presentation/authentication/pages/splash_page.dart';
import '../../presentation/customers/pages/customer_details_page.dart';
import '../../presentation/customers/pages/customer_list_page.dart';
import '../../presentation/customers/pages/customer_timeline_page.dart';
import '../../presentation/dashboard/pages/dashboard_page.dart';
import '../../presentation/invoices/pages/create_invoice_page.dart';
import '../../presentation/invoices/pages/invoice_details_page.dart';
import '../../presentation/invoices/pages/invoice_list_page.dart';
import '../../presentation/invoices/pages/sales_overview_page.dart';
import '../../presentation/leads/pages/add_lead_page.dart';
import '../../presentation/leads/pages/followups_page.dart';
import '../../presentation/leads/pages/lead_details_page.dart';
import '../../presentation/leads/pages/lead_pipeline_page.dart';
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
import '../../presentation/settings/pages/settings_page.dart';
import '../../presentation/subscription/pages/subscription_paywall_page.dart';
import '../../presentation/suppliers/pages/supplier_details_page.dart';
import '../../presentation/suppliers/pages/supplier_directory_page.dart';
import '../../presentation/sync/pages/offline_sync_center_page.dart';
import '../../presentation/whatsapp/pages/automated_reminders_page.dart';
import '../../presentation/whatsapp/pages/edit_rule_page.dart';
import '../../presentation/whatsapp/pages/new_template_page.dart';
import '../../presentation/whatsapp/pages/whatsapp_templates_page.dart';
import 'route_names.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
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
      GoRoute(
        path: RouteNames.subscription,
        builder: (context, state) => const SubscriptionPaywallPage(),
      ),
      GoRoute(
        path: RouteNames.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),

      // Customers
      GoRoute(
        path: RouteNames.customers,
        builder: (context, state) => const CustomerListPage(),
      ),
      GoRoute(
        path: RouteNames.customerDetails,
        builder: (context, state) => const CustomerDetailsPage(),
      ),
      GoRoute(
        path: RouteNames.customerTimeline,
        builder: (context, state) => const CustomerTimelinePage(),
      ),

      // Products & Inventory
      GoRoute(
        path: RouteNames.products,
        builder: (context, state) => const ProductListPage(),
      ),
      GoRoute(
        path: RouteNames.productDetails,
        builder: (context, state) => const ProductDetailsPage(),
      ),
      GoRoute(
        path: RouteNames.stockManagement,
        builder: (context, state) => const StockManagementPage(),
      ),
      GoRoute(
        path: RouteNames.stockAdjustment,
        builder: (context, state) => const StockAdjustmentPage(),
      ),

      // Invoices & Sales
      GoRoute(
        path: RouteNames.invoices,
        builder: (context, state) => const InvoiceListPage(),
      ),
      GoRoute(
        path: RouteNames.createInvoice,
        builder: (context, state) => const CreateInvoicePage(),
      ),
      GoRoute(
        path: RouteNames.invoiceDetails,
        builder: (context, state) => const InvoiceDetailsPage(),
      ),
      GoRoute(
        path: RouteNames.salesOverview,
        builder: (context, state) => const SalesOverviewPage(),
      ),

      // CRM
      GoRoute(
        path: RouteNames.leadPipeline,
        builder: (context, state) => const LeadPipelinePage(),
      ),
      GoRoute(
        path: RouteNames.addLead,
        builder: (context, state) => const AddLeadPage(),
      ),
      GoRoute(
        path: RouteNames.leadDetails,
        builder: (context, state) => const LeadDetailsPage(),
      ),
      GoRoute(
        path: RouteNames.followUps,
        builder: (context, state) => const FollowUpsPage(),
      ),

      // Reports
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

      // Purchases & Suppliers
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
        builder: (context, state) => const SupplierDetailsPage(),
      ),

      // WhatsApp & Reminders
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

      // Sync & Settings
      GoRoute(
        path: RouteNames.offlineSync,
        builder: (context, state) => const OfflineSyncCenterPage(),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('No route defined for ${state.uri}')),
    ),
  );
}
