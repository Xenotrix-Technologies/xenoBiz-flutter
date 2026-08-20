import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../const/colors.dart';
import 'bloc/blocs.dart';
import 'di/injection.dart';
import 'routing/app_router.dart';

class XenoBizApp extends StatelessWidget {
  const XenoBizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(authRepository: getIt()),
          ),
          BlocProvider<SubscriptionBloc>(
            create: (_) => SubscriptionBloc(subscriptionRepository: getIt()),
          ),
          BlocProvider<DashboardBloc>(
            create: (_) => DashboardBloc(
              invoiceRepository: getIt(),
              customerRepository: getIt(),
              productRepository: getIt(),
              expenseRepository: getIt(),
            ),
          ),
          BlocProvider<CustomerBloc>(
            create: (_) => CustomerBloc(customerRepository: getIt()),
          ),
          BlocProvider<ProductBloc>(
            create: (_) => ProductBloc(productRepository: getIt()),
          ),
          BlocProvider<InvoiceBloc>(
            create: (_) => InvoiceBloc(
              invoiceRepository: getIt(),
              createInvoiceUseCase: getIt(),
              updateInvoiceUseCase: getIt(),
              recordPaymentUseCase: getIt(),
            ),
          ),
          BlocProvider<LeadBloc>(
            create: (_) => LeadBloc(leadRepository: getIt()),
          ),
          BlocProvider<SyncBloc>(
            create: (_) => SyncBloc(
              syncRepository: getIt(),
              networkChecker: getIt(),
            ),
          ),
          BlocProvider<TaxSettingsBloc>(
            create: (_) => TaxSettingsBloc(repository: getIt())..add(const FetchTaxSettingsEvent()),
          ),
          BlocProvider<PurchaseBloc>(
            create: (_) => PurchaseBloc(purchaseRepository: getIt())..add(const FetchPurchasesEvent()),
          ),
          BlocProvider<ExpenseBloc>(
            create: (_) => ExpenseBloc(expenseRepository: getIt())..add(const FetchExpensesEvent()),
          ),
          BlocProvider<SalesOverviewBloc>(
            create: (_) => SalesOverviewBloc(
              invoiceRepository: getIt(),
              expenseRepository: getIt(),
              customerRepository: getIt(),
            )..add(FetchSalesOverviewDataEvent()),
          ),
          BlocProvider<DailyLedgerBloc>(
            create: (_) => DailyLedgerBloc(
              invoiceRepository: getIt(),
              expenseRepository: getIt(),
              customerRepository: getIt(),
              hiveService: getIt(),
            )..add(FetchDailyLedgerDataEvent(DateTime.now())),
          ),
          BlocProvider<AccountsBloc>(
            create: (_) => AccountsBloc(
              customerRepository: getIt(),
              expenseRepository: getIt(),
              invoiceRepository: getIt(),
              hiveService: getIt(),
            )..add(const FetchAccountsEvent()),
          ),
          BlocProvider<CrmBloc>(
            create: (_) => CrmBloc(
              crmService: getIt(),
            )..add(const FetchCrmDataEvent()),
          ),
        ],



      child: MaterialApp.router(
        title: 'XenoBiz Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          fontFamily: 'PlusJakartaSans',
          primaryColor: AppColors.primaryBlue,
          scaffoldBackgroundColor: AppColors.pageBackground,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryBlue,
            primary: AppColors.primaryBlue,
            secondary: AppColors.deepNavy,
            surface: AppColors.cardSurface,
            error: AppColors.danger,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.deepNavy,
            foregroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        routerConfig: AppRouter.router,
      ),
    ),
    );
  }
}
