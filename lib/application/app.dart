import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../const/colors.dart';
import 'bloc/blocs.dart';
import 'di/injection.dart';
import 'routing/app_router.dart';

class XenoBizApp extends StatelessWidget {
  const XenoBizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
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
      ],
      child: MaterialApp.router(
        title: 'XenoBiz Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          textTheme: GoogleFonts.manropeTextTheme(
            ThemeData.light().textTheme,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            error: AppColors.error,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
