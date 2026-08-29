import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/create_invoice_provider.dart';
import '../services/transaction_route_observer.dart';
import '../bloc/accounts_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/invoice_entity.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../presentation/authentication/pages/login_page.dart';
import '../../presentation/authentication/pages/plans_and_pricing_page.dart';
import '../../presentation/authentication/pages/register_page.dart';
import '../../presentation/authentication/pages/registration_success_page.dart';
import '../../presentation/authentication/pages/splash_page.dart';
import '../../presentation/authentication/pages/trial_welcome_page.dart';
import '../../presentation/customers/pages/accounts_page.dart';
import '../../presentation/customers/pages/customer_details_page.dart';
import '../../presentation/customers/pages/customer_timeline_page.dart';
import '../../presentation/customers/pages/expense_account_details_page.dart';

import '../../presentation/dashboard/pages/dashboard_page.dart';
import '../../presentation/dashboard/pages/global_search_page.dart';
import '../../presentation/invoices/pages/add_products_page.dart';
import '../../presentation/invoices/pages/create_invoice_page.dart';
import '../../presentation/invoices/pages/daily_ledger_page.dart';
import '../../presentation/invoices/pages/invoice_details_page.dart';
import '../../presentation/invoices/pages/return_voucher_screen.dart';
import '../../presentation/invoices/pages/returns_list_page.dart';
import '../../presentation/invoices/pages/transaction_screen.dart';

import '../../presentation/invoices/pages/quotations_page.dart';
import '../../presentation/invoices/pages/delivery_challans_page.dart';
import '../../presentation/invoices/pages/delivery_challan_details_page.dart';
import '../../presentation/invoices/pages/create_delivery_challan_page.dart';
import '../../presentation/invoices/pages/credit_debit_notes_page.dart';
import '../../domain/entities/delivery_challan_entity.dart';
import '../../domain/entities/accounting_entities.dart';
import '../../presentation/invoices/pages/invoice_list_page.dart';
import '../../presentation/invoices/pages/invoice_result_page.dart';
import '../../presentation/invoices/pages/payment_page.dart';
import '../../presentation/settings/pages/voucher_prefix_settings_page.dart';
import '../../presentation/invoices/pages/sales_overview_page.dart';

import '../../presentation/main/pages/main_shell_page.dart';
import '../../presentation/main/pages/create_master_page.dart';
import '../../presentation/products/pages/product_details_page.dart';
import '../../presentation/products/pages/product_list_page.dart';
import '../../presentation/products/pages/stock_management_page.dart';
import '../../presentation/services/pages/services_list_page.dart';
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
import '../../presentation/sync/pages/offline_sync_center_page.dart';
import '../../presentation/whatsapp/pages/automated_reminders_page.dart';
import '../../presentation/whatsapp/pages/edit_rule_page.dart';
import '../../presentation/whatsapp/pages/new_template_page.dart';
import '../../presentation/whatsapp/pages/whatsapp_templates_page.dart';
import '../../presentation/accounting/pages/journal_page.dart';
import '../../presentation/accounting/pages/new_journal_entry_page.dart';
import '../../presentation/accounting/pages/contra_page.dart';
import '../../presentation/accounting/pages/new_contra_entry_page.dart';
import '../../presentation/accounting/pages/daily_book_page.dart';
import '../../presentation/accounting/pages/ledger_page.dart';
import '../../presentation/accounting/pages/cash_bank_page.dart';
import '../../presentation/accounting/pages/receivables_payables_pages.dart';
import '../../presentation/accounting/pages/trial_balance_page.dart';
import '../../presentation/gst/pages/gst_taxation_page.dart';
import '../../presentation/gst/pages/gstr1_report_page.dart';
import '../../presentation/gst/pages/gstr3b_return_page.dart';
import '../../presentation/gst/pages/tax_summary_page.dart';
import '../../presentation/gst/pages/hsn_sac_summary_page.dart';
import '../../presentation/reports/pages/sales_report_page.dart';
import '../../presentation/reports/pages/purchase_report_page.dart';
import '../../presentation/reports/pages/inventory_report_page.dart';
import '../../presentation/reports/pages/account_report_page.dart';
import '../../presentation/tools/pages/business_tools_subpages.dart';
import 'route_names.dart';

Widget _buildCreateMasterPage(GoRouterState state) {
  int tab = 0;
  ProductEntity? product;
  CustomerEntity? customer;
  SupplierEntity? supplier;
  ExpenseAccountSummary? expense;
  CategoryEntity? category;
  bool isService = false;

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
  } else if (extra is CategoryEntity) {
    tab = 1;
    category = extra;
  } else if (extra is Map<String, dynamic>) {
    tab = (extra['tab'] as int?) ?? 0;
    product = extra['product'] as ProductEntity?;
    customer = extra['customer'] as CustomerEntity?;
    supplier = extra['supplier'] as SupplierEntity?;
    expense = extra['expense'] as ExpenseAccountSummary?;
    category = extra['category'] as CategoryEntity?;
    isService = (extra['isService'] as bool?) ?? false;
  }

  return CreateMasterPage(
    initialTabIndex: tab,
    productToEdit: product,
    customerToEdit: customer,
    supplierToEdit: supplier,
    expenseToEdit: expense,
    categoryToEdit: category,
    initialIsService: isService,
  );
}

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'rootNavKey');
  static final GlobalKey<NavigatorState> shellHomeNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellHomeNavKey');
  static final GlobalKey<NavigatorState> shellSalesNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellSalesNavKey');
  static final GlobalKey<NavigatorState> shellAccountsNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellAccountsNavKey');
  static final GlobalKey<NavigatorState> shellStockNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellStockNavKey');
  static final GlobalKey<NavigatorState> shellMoreNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellMoreNavKey');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splash,
    observers: [TransactionRouteObserver.instance],
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
        path: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.registrationSuccess,
        builder: (context, state) => const RegistrationSuccessPage(),
      ),
      GoRoute(
        path: RouteNames.trialWelcome,
        builder: (context, state) => const TrialWelcomePage(),
      ),
      GoRoute(
        path: RouteNames.plansAndPricing,
        builder: (context, state) => const PlansAndPricingPage(),
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
              GoRoute(
                path: RouteNames.moreCustomers,
                builder: (context, state) {
                  int tab = 0;
                  if (state.extra is int) {
                    tab = state.extra as int;
                  } else if (state.extra is Map && (state.extra as Map).containsKey('tab')) {
                    tab = (state.extra as Map)['tab'] as int;
                  }
                  return AccountsPage(initialTab: tab);
                },
              ),
              GoRoute(
                path: RouteNames.supplierDirectory,
                builder: (context, state) => const AccountsPage(initialTab: 1),
              ),
              GoRoute(
                path: RouteNames.supplierDetails,
                builder: (context, state) {
                  final sup = state.extra as SupplierEntity?;
                  return SupplierDetailsPage(supplier: sup);
                },
              ),
              GoRoute(
                path: RouteNames.salesAnalytics,
                builder: (context, state) => const SalesAnalyticsPage(),
              ),
              GoRoute(
                path: RouteNames.salesReport,
                builder: (context, state) => SalesReportPage(initialPreset: state.extra),
              ),
              GoRoute(
                path: RouteNames.purchaseReport,
                builder: (context, state) => PurchaseReportPage(initialPreset: state.extra),
              ),
              GoRoute(
                path: RouteNames.inventoryReport,
                builder: (context, state) => InventoryReportPage(initialPreset: state.extra),
              ),
              GoRoute(
                path: RouteNames.accountReport,
                builder: (context, state) => AccountReportPage(initialPreset: state.extra),
              ),
              GoRoute(
                path: RouteNames.gstr1Report,
                builder: (context, state) => const Gstr1ReportPage(),
              ),
              GoRoute(
                path: RouteNames.gstr3bReturn,
                builder: (context, state) => const Gstr3bReturnPage(),
              ),
              GoRoute(
                path: RouteNames.taxSummary,
                builder: (context, state) => const TaxSummaryPage(),
              ),
              GoRoute(
                path: RouteNames.hsnSacSummary,
                builder: (context, state) => const HsnSacSummaryPage(),
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
                path: RouteNames.quotations,
                builder: (context, state) => const QuotationsPage(),
              ),
              GoRoute(
                path: RouteNames.proformaInvoices,
                builder: (context, state) => const SecondaryModulePage(
                  title: 'Proforma Invoices',
                  icon: Icons.description,
                  description: 'Issue proforma invoices prior to final billing.',
                ),
              ),
              GoRoute(
                path: RouteNames.deliveryChallans,
                builder: (context, state) => const DeliveryChallansPage(),
              ),
              GoRoute(
                path: RouteNames.services,
                builder: (context, state) => const ServicesListPage(),
              ),
              GoRoute(
                path: RouteNames.creditNotes,
                builder: (context, state) => const CreditDebitNotesPage(initialType: InvoiceType.sale),
              ),
              GoRoute(
                path: RouteNames.debitNotes,
                builder: (context, state) => const CreditDebitNotesPage(initialType: InvoiceType.purchase),
              ),
              GoRoute(
                path: RouteNames.journal,
                builder: (context, state) => const JournalPage(),
              ),
              GoRoute(
                path: RouteNames.newJournalEntry,
                builder: (context, state) {
                  final edit = state.extra is JournalEntryEntity ? state.extra as JournalEntryEntity : null;
                  return NewJournalEntryPage(entryToEdit: edit);
                },
              ),
              GoRoute(
                path: RouteNames.contra,
                builder: (context, state) => const ContraPage(),
              ),
              GoRoute(
                path: RouteNames.newContraEntry,
                builder: (context, state) {
                  final edit = state.extra is ContraEntryEntity ? state.extra as ContraEntryEntity : null;
                  return NewContraEntryPage(entryToEdit: edit);
                },
              ),
              GoRoute(
                path: RouteNames.dailyBook,
                builder: (context, state) => const DailyBookPage(),
              ),
              GoRoute(
                path: RouteNames.ledger,
                builder: (context, state) {
                  final accName = state.extra as String?;
                  return LedgerPage(initialAccount: accName);
                },
              ),
              GoRoute(
                path: RouteNames.cashBank,
                builder: (context, state) => const CashBankPage(),
              ),
              GoRoute(
                path: RouteNames.receivables,
                builder: (context, state) => const ReceivablesPage(),
              ),
              GoRoute(
                path: RouteNames.payables,
                builder: (context, state) => const PayablesPage(),
              ),
              GoRoute(
                path: RouteNames.trialBalance,
                builder: (context, state) => const TrialBalancePage(),
              ),
              GoRoute(
                path: RouteNames.reports,
                builder: (context, state) {
                  final catIdx = (state.extra as int?) ?? 0;
                  return ReportsPage(initialCategoryIndex: catIdx);
                },
              ),
              GoRoute(
                path: RouteNames.gstTaxation,
                builder: (context, state) => const GstTaxationPage(),
              ),
              GoRoute(
                path: RouteNames.taxGstSettings,
                builder: (context, state) => const TaxGstSettingsPage(),
              ),
              GoRoute(
                path: RouteNames.eWayBill,
                builder: (context, state) => const SecondaryModulePage(
                  title: 'E-Way Bill',
                  icon: Icons.local_shipping,
                  description: 'Generate & track e-way bills for transport of goods.',
                ),
              ),
              GoRoute(
                path: RouteNames.eInvoice,
                builder: (context, state) => const SecondaryModulePage(
                  title: 'E-Invoice Portal',
                  icon: Icons.qr_code_2,
                  description: 'Generate IRN e-invoices with B2B QR code & JSON payload.',
                ),
              ),
              GoRoute(
                path: RouteNames.inputTaxCredit,
                builder: (context, state) => const SecondaryModulePage(
                  title: 'Input Tax Credit',
                  icon: Icons.credit_score,
                  description: 'Track GSTR-2B ITC eligibility & claimed tax credit.',
                ),
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
                path: RouteNames.importData,
                builder: (context, state) => const SecondaryModulePage(
                  title: 'Import Data',
                  icon: Icons.file_upload,
                  description: 'Bulk import products, customers & invoices from Excel/CSV.',
                ),
              ),
              GoRoute(
                path: RouteNames.exportData,
                builder: (context, state) => const SecondaryModulePage(
                  title: 'Export Data',
                  icon: Icons.file_download,
                  description: 'Export sales, inventory & accounting data to Excel/PDF.',
                ),
              ),
              GoRoute(
                path: RouteNames.staffUsers,
                builder: (context, state) => const SecondaryModulePage(
                  title: 'Staff & Users',
                  icon: Icons.people_outline,
                  description: 'Manage staff access, cashier permissions & user roles.',
                ),
              ),
              GoRoute(
                path: RouteNames.voucherPrefixSettings,
                builder: (context, state) => const VoucherPrefixSettingsPage(),
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
                path: RouteNames.invoiceSettings,
                builder: (context, state) => const InvoiceSettingsPage(),
              ),
              GoRoute(
                path: RouteNames.notificationSettings,
                builder: (context, state) => const SecondaryModulePage(
                  title: 'Notification Settings',
                  icon: Icons.notifications_none,
                  description: 'Configure automated SMS, WhatsApp & app alert settings.',
                ),
              ),
              GoRoute(
                path: RouteNames.categories,
                builder: (context, state) => const CategoryManagementPage(),
              ),
              GoRoute(
                path: RouteNames.backupRestore,
                builder: (context, state) => const BackupRestorePage(),
              ),
              GoRoute(
                path: RouteNames.offlineSync,
                builder: (context, state) => const OfflineSyncCenterPage(),
              ),
              GoRoute(
                path: RouteNames.customerDetails,
                builder: (context, state) {
                  final cust = state.extra as CustomerEntity?;
                  return CustomerDetailsPage(customer: cust);
                },
              ),
              GoRoute(
                path: RouteNames.customerTimeline,
                builder: (context, state) => const CustomerTimelinePage(),
              ),
              GoRoute(
                path: RouteNames.expenseAccountDetails,
                builder: (context, state) {
                  final acc = state.extra as ExpenseAccountSummary?;
                  return ExpenseAccountDetailsPage(account: acc);
                },
              ),
            ],
          ),
        ],
      ),

      // Standalone / Pushed Detail Sub-Routes
      GoRoute(
        path: RouteNames.globalSearch,
        builder: (context, state) => const GlobalSearchPage(),
      ),
      GoRoute(
        path: RouteNames.subscription,
        builder: (context, state) => const SubscriptionPaywallPage(),
      ),
      GoRoute(
        path: RouteNames.voucherPrefixSettings,
        builder: (context, state) => const VoucherPrefixSettingsPage(),
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
        path: RouteNames.services,
        builder: (context, state) => const ServicesListPage(),
      ),
      GoRoute(
        path: RouteNames.productDetails,
        builder: (context, state) {
          final prod = state.extra as ProductEntity?;
          return ProductDetailsPage(product: prod);
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
          bool isQuotation = false;
          InvoiceEntity? fromQuotation;

          if (state.extra is Map<String, dynamic>) {
            final map = state.extra as Map<String, dynamic>;
            if (map['invoiceType'] is InvoiceType) {
              invoiceType = map['invoiceType'] as InvoiceType;
            }
            if (map['invoiceToEdit'] is InvoiceEntity) {
              invoiceToEdit = map['invoiceToEdit'] as InvoiceEntity;
            }
            if (map['isQuotation'] == true || invoiceType == InvoiceType.quotation) {
              isQuotation = true;
            }
            if (map['fromQuotation'] is InvoiceEntity) {
              fromQuotation = map['fromQuotation'] as InvoiceEntity;
            }
          } else if (state.extra is InvoiceEntity) {
            invoiceToEdit = state.extra as InvoiceEntity;
            invoiceType = invoiceToEdit.type;
            if (invoiceType == InvoiceType.quotation) {
              isQuotation = true;
            }
          }
          return ProviderScope(
            overrides: [
              createInvoiceFormProvider.overrideWith((ref) => CreateInvoiceFormNotifier()),
            ],
            child: CreateInvoicePage(
              invoiceType: invoiceType,
              invoiceToEdit: invoiceToEdit,
              isQuotation: isQuotation,
              fromQuotation: fromQuotation,
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.invoiceDetails,
        builder: (context, state) {
          final inv = state.extra as InvoiceEntity?;
          return InvoiceDetailsPage(invoice: inv);
        },
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
              rType = (map['type'] as InvoiceType) == InvoiceType.purchase
                  ? ReturnType.purchaseReturn
                  : ReturnType.salesReturn;
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
            existing =
                (state.extra as Map<String, dynamic>)['existingTransaction'];
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
            existing =
                (state.extra as Map<String, dynamic>)['existingTransaction'];
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
          InvoiceEntity invoice;
          CustomerEntity? customer;
          String paymentMethod = 'Cash';
          double amountPaid = 0.0;
          double previousBalance = 0.0;
          bool isNewlyCreated = false;

          if (state.extra is Map<String, dynamic>) {
            final args = state.extra as Map<String, dynamic>;
            invoice = args['invoice'] as InvoiceEntity;
            customer = args['customer'] as CustomerEntity?;
            paymentMethod = (args['paymentMethod'] as String?) ?? 'Cash';
            amountPaid = (args['amountPaid'] as double?) ?? 0.0;
            previousBalance = (args['previousBalance'] as double?) ?? 0.0;
            isNewlyCreated = (args['isNewlyCreated'] as bool?) ?? false;
          } else if (state.extra is InvoiceEntity) {
            invoice = state.extra as InvoiceEntity;
            amountPaid = invoice.paidAmount;
            isNewlyCreated = false;
          } else {
            throw Exception('Invoice argument required for invoiceResult');
          }

          return InvoiceResultPage(
            invoice: invoice,
            customer: customer,
            paymentMethod: paymentMethod,
            amountPaid: amountPaid,
            previousBalance: previousBalance,
            isNewlyCreated: isNewlyCreated,
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

      GoRoute(
        path: RouteNames.reports,
        builder: (context, state) {
          final catIdx = (state.extra as int?) ?? 0;
          return ReportsPage(initialCategoryIndex: catIdx);
        },
      ),
      GoRoute(
        path: RouteNames.journal,
        builder: (context, state) => const JournalPage(),
      ),
      GoRoute(
        path: RouteNames.newJournalEntry,
        builder: (context, state) {
          final edit = state.extra is JournalEntryEntity ? state.extra as JournalEntryEntity : null;
          return NewJournalEntryPage(entryToEdit: edit);
        },
      ),
      GoRoute(
        path: RouteNames.contra,
        builder: (context, state) => const ContraPage(),
      ),
      GoRoute(
        path: RouteNames.newContraEntry,
        builder: (context, state) {
          final edit = state.extra is ContraEntryEntity ? state.extra as ContraEntryEntity : null;
          return NewContraEntryPage(entryToEdit: edit);
        },
      ),
      GoRoute(
        path: RouteNames.dailyBook,
        builder: (context, state) => const DailyBookPage(),
      ),
      GoRoute(
        path: RouteNames.ledger,
        builder: (context, state) {
          final accName = state.extra as String?;
          return LedgerPage(initialAccount: accName);
        },
      ),
      GoRoute(
        path: RouteNames.cashBank,
        builder: (context, state) => const CashBankPage(),
      ),
      GoRoute(
        path: RouteNames.receivables,
        builder: (context, state) => const ReceivablesPage(),
      ),
      GoRoute(
        path: RouteNames.payables,
        builder: (context, state) => const PayablesPage(),
      ),
      GoRoute(
        path: RouteNames.trialBalance,
        builder: (context, state) => const TrialBalancePage(),
      ),
      GoRoute(
        path: RouteNames.gstTaxation,
        builder: (context, state) => const GstTaxationPage(),
      ),
      GoRoute(
        path: RouteNames.eInvoice,
        builder: (context, state) => const SecondaryModulePage(
          title: 'E-Invoice Portal',
          icon: Icons.qr_code_2,
          description: 'Generate IRN e-invoices with B2B QR code & JSON payload.',
        ),
      ),
      GoRoute(
        path: RouteNames.eWayBill,
        builder: (context, state) => const SecondaryModulePage(
          title: 'E-Way Bill',
          icon: Icons.local_shipping,
          description: 'Generate & track e-way bills for transport of goods.',
        ),
      ),
      GoRoute(
        path: RouteNames.inputTaxCredit,
        builder: (context, state) => const SecondaryModulePage(
          title: 'Input Tax Credit',
          icon: Icons.credit_score,
          description: 'Track GSTR-2B ITC eligibility & claimed tax credit.',
        ),
      ),
      GoRoute(
        path: RouteNames.quotations,
        builder: (context, state) => const QuotationsPage(),
      ),
      GoRoute(
        path: RouteNames.proformaInvoices,
        builder: (context, state) => const SecondaryModulePage(
          title: 'Proforma Invoices',
          icon: Icons.description,
          description: 'Issue proforma invoices prior to final billing.',
        ),
      ),
      GoRoute(
        path: RouteNames.deliveryChallans,
        builder: (context, state) => const DeliveryChallansPage(),
      ),
      GoRoute(
        path: RouteNames.deliveryChallanDetails,
        builder: (context, state) {
          final challan = state.extra as DeliveryChallanEntity;
          return DeliveryChallanDetailsPage(challan: challan);
        },
      ),
      GoRoute(
        path: RouteNames.createDeliveryChallan,
        builder: (context, state) {
          final edit = state.extra as DeliveryChallanEntity?;
          return CreateDeliveryChallanPage(challanToEdit: edit);
        },
      ),
      GoRoute(
        path: RouteNames.creditNotes,
        builder: (context, state) => const CreditDebitNotesPage(initialType: InvoiceType.sale),
      ),
      GoRoute(
        path: RouteNames.debitNotes,
        builder: (context, state) => const CreditDebitNotesPage(initialType: InvoiceType.purchase),
      ),
      GoRoute(
        path: RouteNames.stockTransfer,
        builder: (context, state) => const SecondaryModulePage(
          title: 'Stock Transfer',
          icon: Icons.swap_horiz,
          description: 'Transfer inventory items between warehouses & store branches.',
        ),
      ),
      GoRoute(
        path: RouteNames.stockValuation,
        builder: (context, state) => const SecondaryModulePage(
          title: 'Stock Valuation',
          icon: Icons.assessment,
          description: 'FIFO & average cost product inventory valuation.',
        ),
      ),
      GoRoute(
        path: RouteNames.lowStockReport,
        builder: (context, state) => const SecondaryModulePage(
          title: 'Low Stock Report',
          icon: Icons.warning_amber,
          description: 'Items below reorder point threshold.',
        ),
      ),
      GoRoute(
        path: RouteNames.stockMovement,
        builder: (context, state) => const SecondaryModulePage(
          title: 'Stock Movement',
          icon: Icons.compare_arrows,
          description: 'Inward, outward & stock adjustment log.',
        ),
      ),
      GoRoute(
        path: RouteNames.recurringInvoices,
        builder: (context, state) => const SecondaryModulePage(
          title: 'Recurring Invoices',
          icon: Icons.repeat,
          description: 'Automated subscription & recurring invoice schedules.',
        ),
      ),
      GoRoute(
        path: RouteNames.importData,
        builder: (context, state) => const SecondaryModulePage(
          title: 'Import Data',
          icon: Icons.file_upload,
          description: 'Bulk import products, customers & invoices from Excel/CSV.',
        ),
      ),
      GoRoute(
        path: RouteNames.exportData,
        builder: (context, state) => const SecondaryModulePage(
          title: 'Export Data',
          icon: Icons.file_download,
          description: 'Export sales, inventory & accounting data to Excel/PDF.',
        ),
      ),
      GoRoute(
        path: RouteNames.documentTemplates,
        builder: (context, state) => const SecondaryModulePage(
          title: 'Document Templates',
          icon: Icons.article,
          description: 'Customize thermal, A4 invoice themes & print headers.',
        ),
      ),
      GoRoute(
        path: RouteNames.staffUsers,
        builder: (context, state) => const SecondaryModulePage(
          title: 'Staff & Users',
          icon: Icons.people_outline,
          description: 'Manage staff access, cashier permissions & user roles.',
        ),
      ),
      GoRoute(
        path: RouteNames.printerSettings,
        builder: (context, state) => const SecondaryModulePage(
          title: 'Printer Settings',
          icon: Icons.print,
          description: 'Configure Bluetooth thermal printers & paper width.',
        ),
      ),
      GoRoute(
        path: RouteNames.notificationSettings,
        builder: (context, state) => const SecondaryModulePage(
          title: 'Notification Settings',
          icon: Icons.notifications_none,
          description: 'Configure automated SMS, WhatsApp & app alert settings.',
        ),
      ),
      GoRoute(
        path: RouteNames.salesAnalytics,
        builder: (context, state) => const SalesAnalyticsPage(),
      ),
      GoRoute(
        path: RouteNames.salesReport,
        builder: (context, state) => SalesReportPage(initialPreset: state.extra),
      ),
      GoRoute(
        path: RouteNames.purchaseReport,
        builder: (context, state) => PurchaseReportPage(initialPreset: state.extra),
      ),
      GoRoute(
        path: RouteNames.inventoryReport,
        builder: (context, state) => InventoryReportPage(initialPreset: state.extra),
      ),
      GoRoute(
        path: RouteNames.accountReport,
        builder: (context, state) => AccountReportPage(initialPreset: state.extra),
      ),
      GoRoute(
        path: RouteNames.gstr1Report,
        builder: (context, state) => const Gstr1ReportPage(),
      ),
      GoRoute(
        path: RouteNames.gstr3bReturn,
        builder: (context, state) => const Gstr3bReturnPage(),
      ),
      GoRoute(
        path: RouteNames.taxSummary,
        builder: (context, state) => const TaxSummaryPage(),
      ),
      GoRoute(
        path: RouteNames.hsnSacSummary,
        builder: (context, state) => const HsnSacSummaryPage(),
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
        builder: (context, state) => const AccountsPage(initialTab: 1),
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
