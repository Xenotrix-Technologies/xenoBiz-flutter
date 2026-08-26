import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/billing_customer_entity.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/billing_customer_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../database/app_database.dart';
import '../network/dio_client.dart';
import '../network/network_checker.dart';

class BillingCustomerRepositoryImpl implements BillingCustomerRepository {
  final DioClient dioClient;
  final AppDatabase db;
  final NetworkChecker networkChecker;
  final SyncRepository syncRepository;

  BillingCustomerRepositoryImpl({
    required this.dioClient,
    required this.db,
    required this.networkChecker,
    required this.syncRepository,
  });

  BillingCustomerEntity _rowToCustomer(Customer row) {
    return BillingCustomerEntity(
      id: row.id,
      name: row.name,
      phone: row.phone,
      email: row.email,
      address: row.address,
      state: row.state,
      outstandingBalance: row.outstandingBalance,
      totalPurchases: row.totalPurchases,
      createdAt: row.createdAt,
    );
  }

  CustomersCompanion _customerToCompanion(BillingCustomerEntity c, {String syncStatus = 'synced'}) {
    return CustomersCompanion(
      id: Value(c.id),
      name: Value(c.name),
      phone: Value(c.phone),
      email: Value(c.email),
      address: Value(c.address),
      state: Value(c.state),
      outstandingBalance: Value(c.outstandingBalance),
      totalPurchases: Value(c.totalPurchases),
      createdAt: Value(c.createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  @override
  Future<List<BillingCustomerEntity>> getBillingCustomers({String? query}) async {
    final q = db.select(db.customers)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final rows = await q.get();

    final localCustomers = rows.map(_rowToCustomer).toList();

    if (query == null || query.isEmpty) {
      return localCustomers;
    }

    final lowerQ = query.toLowerCase();
    return localCustomers.where((c) {
      return c.name.toLowerCase().contains(lowerQ) ||
          c.phone.toLowerCase().contains(lowerQ) ||
          c.email.toLowerCase().contains(lowerQ);
    }).toList();
  }

  @override
  Future<BillingCustomerEntity> getBillingCustomer(String id) async {
    final q = db.select(db.customers)..where((t) => t.id.equals(id));
    final row = await q.getSingleOrNull();
    if (row != null) {
      return _rowToCustomer(row);
    }
    return BillingCustomerEntity(
      id: id,
      name: 'Unknown Customer',
      phone: '',
      email: '',
      address: '',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<BillingCustomerEntity> createBillingCustomer(BillingCustomerEntity customer) async {
    final String customerId = customer.id.isNotEmpty ? customer.id : const Uuid().v4();
    final localCustomer = customer.copyWith(id: customerId);

    await db.into(db.customers).insertOnConflictUpdate(_customerToCompanion(localCustomer));
    return localCustomer;
  }

  @override
  Future<BillingCustomerEntity> updateBillingCustomer(BillingCustomerEntity customer) async {
    await db.into(db.customers).insertOnConflictUpdate(_customerToCompanion(customer));
    return customer;
  }

  @override
  Future<void> deleteBillingCustomer(String id) async {
    await (db.delete(db.customers)..where((t) => t.id.equals(id))).go();
  }

  // Alias methods for backward compatibility
  @override
  Future<List<BillingCustomerEntity>> getCustomers({String? query}) => getBillingCustomers(query: query);

  @override
  Future<BillingCustomerEntity> getCustomer(String id) => getBillingCustomer(id);

  @override
  Future<BillingCustomerEntity> createCustomer(BillingCustomerEntity customer) => createBillingCustomer(customer);

  @override
  Future<BillingCustomerEntity> updateCustomer(BillingCustomerEntity customer) => updateBillingCustomer(customer);

  @override
  Future<void> deleteCustomer(String id) => deleteBillingCustomer(id);

  @override
  Future<List<CustomerTimelineEvent>> getCustomerTimeline(String customerId) async {
    return [];
  }

  @override
  Future<void> addTimelineEvent(CustomerTimelineEvent event) async {}
}
