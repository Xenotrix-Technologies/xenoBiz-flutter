import 'package:get_it/get_it.dart';

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
import '../../infrastructure/repositories/product_repository_impl.dart';
import '../../infrastructure/repositories/purchase_repository_impl.dart';
import '../../infrastructure/repositories/returns_repository_impl.dart';
import '../../infrastructure/repositories/subscription_repository_impl.dart';
import '../../infrastructure/repositories/sync_repository_impl.dart';
import '../../infrastructure/repositories/accounting_repository.dart';
import '../../infrastructure/repositories/tax_settings_repository_impl.dart';

import '../../domain/repositories/billing_customer_repository.dart';
import '../../domain/repositories/delivery_challan_repository.dart';
import '../../infrastructure/repositories/billing_customer_repository_impl.dart';
import '../../infrastructure/repositories/delivery_challan_repository_impl.dart';

import '../../infrastructure/database/app_database.dart';
import '../../infrastructure/services/voucher_sequence_service.dart';
import '../../infrastructure/storage/secure_storage_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // 1. Core Database & Services
  final db = AppDatabase();
  getIt.registerSingleton<AppDatabase>(db);

  final secureStorage = SecureStorageService();
  getIt.registerSingleton<SecureStorageService>(secureStorage);

  final dioClient = DioClient(secureStorage: secureStorage);
  getIt.registerSingleton<DioClient>(dioClient);

  final networkChecker = NetworkChecker();
  getIt.registerSingleton<NetworkChecker>(networkChecker);

  getIt.registerLazySingleton<VoucherSequenceService>(
    () => VoucherSequenceService(db),
  );

  // 2. Sync Repository
  getIt.registerLazySingleton<SyncRepository>(
    () => SyncRepositoryImpl(
      db: getIt(),
      dioClient: getIt(),
      networkChecker: getIt(),
    ),
  );

  // 3. Domain Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      dioClient: getIt(),
      db: getIt(),
      secureStorage: getIt(),
    ),
  );

  getIt.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(db: getIt()),
  );

  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<BillingCustomerRepository>(
    () => BillingCustomerRepositoryImpl(
      dioClient: getIt(),
      db: getIt(),
      networkChecker: getIt(),
      syncRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      dioClient: getIt(),
      db: getIt(),
      networkChecker: getIt(),
      syncRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton<InvoiceRepository>(
    () => InvoiceRepositoryImpl(
      dioClient: getIt(),
      db: getIt(),
      networkChecker: getIt(),
      syncRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(db: getIt()),
  );

  getIt.registerLazySingleton<IncomeRepository>(
    () => IncomeRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<PurchaseRepository>(
    () => PurchaseRepositoryImpl(dioClient: getIt(), db: getIt()),
  );

  getIt.registerLazySingleton<TaxSettingsRepository>(
    () => TaxSettingsRepositoryImpl(db: getIt()),
  );

  getIt.registerLazySingleton<ReturnsRepository>(
    () => ReturnsRepositoryImpl(
      db: getIt(),
      productRepository: getIt(),
      customerRepository: getIt(),
      purchaseRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton<AccountingRepository>(
    () => AccountingRepository(getIt()),
  );

  getIt.registerLazySingleton<DeliveryChallanRepository>(
    () => DeliveryChallanRepositoryImpl(db: getIt()),
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
