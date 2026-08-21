import 'package:get_it/get_it.dart';

import '../bloc/crm_bloc.dart';
import '../bloc/crm_customer_bloc.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/usecases/create_invoice_usecase.dart';
import '../../domain/usecases/record_payment_usecase.dart';
import '../../domain/usecases/update_invoice_usecase.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/network/network_checker.dart';
import '../../infrastructure/repositories/auth_repository_impl.dart';
import '../../infrastructure/repositories/category_repository_impl.dart';
import '../../infrastructure/repositories/expense_repository_impl.dart';
import '../../infrastructure/repositories/income_repository_impl.dart';
import '../../infrastructure/repositories/invoice_repository_impl.dart';
import '../../infrastructure/repositories/lead_repository_impl.dart';
import '../../infrastructure/repositories/product_repository_impl.dart';
import '../../infrastructure/repositories/purchase_repository_impl.dart';
import '../../infrastructure/repositories/returns_repository_impl.dart';
import '../../infrastructure/repositories/subscription_repository_impl.dart';
import '../../infrastructure/repositories/sync_repository_impl.dart';
import '../../infrastructure/repositories/tax_settings_repository_impl.dart';
import '../../infrastructure/services/crm_service.dart';
import '../../domain/repositories/billing_customer_repository.dart';
import '../../domain/repositories/crm_customer_repository.dart';
import '../../infrastructure/repositories/billing_customer_repository_impl.dart';
import '../../infrastructure/repositories/crm_customer_repository_impl.dart';
import '../../infrastructure/storage/hive_service.dart';
import '../../infrastructure/storage/secure_storage_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // 1. Core Services & Storage
  final hiveService = HiveService();
  await hiveService.init();
  await hiveService.seedDummyDataIfEmpty();
  getIt.registerSingleton<HiveService>(hiveService);

  final secureStorage = SecureStorageService();
  getIt.registerSingleton<SecureStorageService>(secureStorage);

  final dioClient = DioClient(secureStorage: secureStorage);
  getIt.registerSingleton<DioClient>(dioClient);

  final networkChecker = NetworkChecker();
  getIt.registerSingleton<NetworkChecker>(networkChecker);

  // 2. Sync Repository
  getIt.registerLazySingleton<SyncRepository>(
    () => SyncRepositoryImpl(
      hiveService: getIt(),
      dioClient: getIt(),
      networkChecker: getIt(),
    ),
  );

  // 3. Domain Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      dioClient: getIt(),
      hiveService: getIt(),
      secureStorage: getIt(),
    ),
  );

  getIt.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(hiveService: getIt()),
  );

  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<BillingCustomerRepository>(
    () => BillingCustomerRepositoryImpl(
      dioClient: getIt(),
      hiveService: getIt(),
      networkChecker: getIt(),
      syncRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton<CrmCustomerRepository>(
    () => CrmCustomerRepositoryImpl(
      hiveService: getIt(),
    ),
  );

  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      dioClient: getIt(),
      hiveService: getIt(),
      networkChecker: getIt(),
      syncRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton<InvoiceRepository>(
    () => InvoiceRepositoryImpl(
      dioClient: getIt(),
      hiveService: getIt(),
      networkChecker: getIt(),
      syncRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton<LeadRepository>(
    () => LeadRepositoryImpl(
      dioClient: getIt(),
      hiveService: getIt(),
      networkChecker: getIt(),
      syncRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(hiveService: getIt()),
  );

  getIt.registerLazySingleton<IncomeRepository>(
    () => IncomeRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<PurchaseRepository>(
    () => PurchaseRepositoryImpl(dioClient: getIt(), hiveService: getIt()),
  );

  getIt.registerLazySingleton<TaxSettingsRepository>(
    () => TaxSettingsRepositoryImpl(hiveService: getIt()),
  );

  getIt.registerLazySingleton<ReturnsRepository>(
    () => ReturnsRepositoryImpl(
      hiveService: getIt(),
      productRepository: getIt(),
      customerRepository: getIt(),
      purchaseRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton<CrmService>(
    () => CrmService(
      hiveService: getIt(),
      crmCustomerRepository: getIt(),
      leadRepository: getIt(),
    ),
  );

  getIt.registerFactory<CrmBloc>(
    () => CrmBloc(crmService: getIt()),
  );

  getIt.registerFactory<CrmCustomerBloc>(
    () => CrmCustomerBloc(repository: getIt()),
  );

  // 4. Use Cases
  getIt.registerLazySingleton<CreateInvoiceUseCase>(
    () => CreateInvoiceUseCase(
      invoiceRepository: getIt(),
      customerRepository: getIt(),
      productRepository: getIt(),
      purchaseRepository: getIt(),
      syncRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton<UpdateInvoiceUseCase>(
    () => UpdateInvoiceUseCase(
      invoiceRepository: getIt(),
      customerRepository: getIt(),
      productRepository: getIt(),
      purchaseRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton<RecordPaymentUseCase>(
    () => RecordPaymentUseCase(
      invoiceRepository: getIt(),
      customerRepository: getIt(),
      syncRepository: getIt(),
    ),
  );
}
