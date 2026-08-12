import 'package:get_it/get_it.dart';

import '../../domain/repositories/repositories.dart';
import '../../domain/usecases/create_invoice_usecase.dart';
import '../../domain/usecases/record_payment_usecase.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/network/network_checker.dart';
import '../../infrastructure/repositories/auth_repository_impl.dart';
import '../../infrastructure/repositories/customer_repository_impl.dart';
import '../../infrastructure/repositories/expense_repository_impl.dart';
import '../../infrastructure/repositories/invoice_repository_impl.dart';
import '../../infrastructure/repositories/lead_repository_impl.dart';
import '../../infrastructure/repositories/product_repository_impl.dart';
import '../../infrastructure/repositories/purchase_repository_impl.dart';
import '../../infrastructure/repositories/subscription_repository_impl.dart';
import '../../infrastructure/repositories/sync_repository_impl.dart';
import '../../infrastructure/storage/hive_service.dart';
import '../../infrastructure/storage/secure_storage_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // 1. Core Services & Storage
  final hiveService = HiveService();
  await hiveService.init();
  getIt.registerSingleton<HiveService>(hiveService);

  final secureStorage = SecureStorageService();
  getIt.registerSingleton<SecureStorageService>(secureStorage);

  final dioClient = DioClient(secureStorage: secureStorage);
  getIt.registerSingleton<DioClient>(dioClient);

  final networkChecker = NetworkChecker();
  getIt.registerSingleton<NetworkChecker>(networkChecker);

  // 2. Repositories
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

  getIt.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(dioClient: getIt(), hiveService: getIt()),
  );

  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(dioClient: getIt(), hiveService: getIt()),
  );

  getIt.registerLazySingleton<InvoiceRepository>(
    () => InvoiceRepositoryImpl(dioClient: getIt(), hiveService: getIt()),
  );

  getIt.registerLazySingleton<LeadRepository>(
    () => LeadRepositoryImpl(dioClient: getIt(), hiveService: getIt()),
  );

  getIt.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(hiveService: getIt()),
  );

  getIt.registerLazySingleton<PurchaseRepository>(
    () => PurchaseRepositoryImpl(dioClient: getIt(), hiveService: getIt()),
  );

  getIt.registerLazySingleton<SyncRepository>(
    () => SyncRepositoryImpl(hiveService: getIt()),
  );

  // 3. Use Cases
  getIt.registerLazySingleton<CreateInvoiceUseCase>(
    () => CreateInvoiceUseCase(
      invoiceRepository: getIt(),
      customerRepository: getIt(),
      productRepository: getIt(),
      syncRepository: getIt(),
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
