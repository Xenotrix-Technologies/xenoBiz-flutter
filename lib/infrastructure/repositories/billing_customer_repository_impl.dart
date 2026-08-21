import 'package:uuid/uuid.dart';
import '../../domain/entities/billing_customer_entity.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/billing_customer_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../network/dio_client.dart';
import '../network/network_checker.dart';
import '../storage/hive_service.dart';

class BillingCustomerRepositoryImpl implements BillingCustomerRepository {
  final DioClient dioClient;
  final HiveService hiveService;
  final NetworkChecker networkChecker;
  final SyncRepository syncRepository;

  BillingCustomerRepositoryImpl({
    required this.dioClient,
    required this.hiveService,
    required this.networkChecker,
    required this.syncRepository,
  });

  Map<String, dynamic> _customerToMap(BillingCustomerEntity c, {String syncStatus = 'synced'}) {
    return {
      'id': c.id,
      'name': c.name,
      'phone': c.phone,
      'email': c.email,
      'address': c.address,
      'state': c.state,
      'outstandingBalance': c.outstandingBalance,
      'totalPurchases': c.totalPurchases,
      'createdAt': c.createdAt.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }

  BillingCustomerEntity _mapToCustomer(Map<dynamic, dynamic> map) {
    return BillingCustomerEntity(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unnamed Customer',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      state: map['state']?.toString(),
      outstandingBalance: (map['outstandingBalance'] as num?)?.toDouble() ??
          (map['outstanding_balance'] as num?)?.toDouble() ?? 0.0,
      totalPurchases: (map['totalPurchases'] as num?)?.toDouble() ??
          (map['total_purchases'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  @override
  Future<List<BillingCustomerEntity>> getBillingCustomers({String? query}) async {
    final box = hiveService.getBox(HiveService.boxBillingCustomers);
    final List<BillingCustomerEntity> localCustomers = [];

    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        localCustomers.add(_mapToCustomer(val));
      }
    }

    localCustomers.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (query == null || query.isEmpty) {
      return localCustomers;
    }

    final q = query.toLowerCase();
    return localCustomers.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<BillingCustomerEntity> getBillingCustomer(String id) async {
    final box = hiveService.getBox(HiveService.boxBillingCustomers);
    final val = box.get(id);
    if (val is Map) {
      return _mapToCustomer(val);
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
    final box = hiveService.getBox(HiveService.boxBillingCustomers);
    final String customerId = customer.id.isNotEmpty ? customer.id : const Uuid().v4();
    final localCustomer = customer.copyWith(id: customerId);

    await box.put(customerId, _customerToMap(localCustomer, syncStatus: 'synced'));
    return localCustomer;
  }

  @override
  Future<BillingCustomerEntity> updateBillingCustomer(BillingCustomerEntity customer) async {
    final box = hiveService.getBox(HiveService.boxBillingCustomers);
    await box.put(customer.id, _customerToMap(customer, syncStatus: 'synced'));
    return customer;
  }

  @override
  Future<void> deleteBillingCustomer(String id) async {
    final box = hiveService.getBox(HiveService.boxBillingCustomers);
    await box.delete(id);
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
