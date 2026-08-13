import 'package:uuid/uuid.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/sync_item_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import '../network/network_checker.dart';
import '../storage/hive_service.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final DioClient dioClient;
  final HiveService hiveService;
  final NetworkChecker networkChecker;
  final SyncRepository syncRepository;

  CustomerRepositoryImpl({
    required this.dioClient,
    required this.hiveService,
    required this.networkChecker,
    required this.syncRepository,
  });

  Map<String, dynamic> _customerToMap(CustomerEntity c, {String syncStatus = 'synced'}) {
    return {
      'id': c.id,
      'name': c.name,
      'phone': c.phone,
      'email': c.email,
      'address': c.address,
      'outstandingBalance': c.outstandingBalance,
      'totalPurchases': c.totalPurchases,
      'createdAt': c.createdAt.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }

  CustomerEntity _mapToCustomer(Map<dynamic, dynamic> map) {
    return CustomerEntity(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unnamed',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      outstandingBalance: (map['outstandingBalance'] as num?)?.toDouble() ??
          (map['outstanding_balance'] as num?)?.toDouble() ?? 0.0,
      totalPurchases: (map['totalPurchases'] as num?)?.toDouble() ??
          (map['total_purchases'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  @override
  Future<List<CustomerEntity>> getCustomers({String? query}) async {
    final box = hiveService.getBox(HiveService.boxCustomers);
    final List<CustomerEntity> localCustomers = [];

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
  Future<CustomerEntity> getCustomer(String id) async {
    final box = hiveService.getBox(HiveService.boxCustomers);
    final val = box.get(id);
    if (val is Map) {
      return _mapToCustomer(val);
    }
    return CustomerEntity(
      id: id,
      name: 'Unknown Customer',
      phone: '',
      email: '',
      address: '',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<CustomerEntity> createCustomer(CustomerEntity customer) async {
    final box = hiveService.getBox(HiveService.boxCustomers);
    final String customerId = customer.id.isNotEmpty ? customer.id : const Uuid().v4();
    final localCustomer = customer.copyWith(id: customerId);

    // 1. Write to Hive immediately (UI sees customer instantly)
    await box.put(customerId, _customerToMap(localCustomer, syncStatus: 'pendingCreate'));

    // 2. Check Network & Sync with Server
    if (await networkChecker.isConnected) {
      try {
        final response = await dioClient.dio.post(
          ApiEndpoints.customers,
          data: {
            'name': localCustomer.name,
            'phone': localCustomer.phone,
            'email': localCustomer.email,
            'address': localCustomer.address,
          },
        );

        if (response.data != null && response.data['success'] == true) {
          final item = response.data['data'];
          final serverId = item['id']?.toString() ?? customerId;
          final syncedCustomer = localCustomer.copyWith(id: serverId);

          if (serverId != customerId) {
            await box.delete(customerId);
          }
          await box.put(serverId, _customerToMap(syncedCustomer, syncStatus: 'synced'));
          return syncedCustomer;
        }
      } catch (_) {
        // Enqueue sync if remote POST fails
      }
    }

    // 3. If offline or request failed, enqueue in Sync Queue
    await syncRepository.enqueueSyncItem(
      SyncItemEntity(
        id: const Uuid().v4(),
        entityType: 'CUSTOMER',
        action: SyncAction.create,
        payload: {
          'localId': customerId,
          'name': localCustomer.name,
          'phone': localCustomer.phone,
          'email': localCustomer.email,
          'address': localCustomer.address,
        },
        createdAt: DateTime.now(),
      ),
    );

    return localCustomer;
  }

  @override
  Future<CustomerEntity> updateCustomer(CustomerEntity customer) async {
    final box = hiveService.getBox(HiveService.boxCustomers);

    // 1. Update Hive immediately
    await box.put(customer.id, _customerToMap(customer, syncStatus: 'pendingUpdate'));

    // 2. If online, sync immediately
    if (await networkChecker.isConnected) {
      try {
        final response = await dioClient.dio.put(
          '${ApiEndpoints.customers}/${customer.id}',
          data: {
            'name': customer.name,
            'phone': customer.phone,
            'email': customer.email,
            'address': customer.address,
          },
        );

        if (response.data != null && response.data['success'] == true) {
          await box.put(customer.id, _customerToMap(customer, syncStatus: 'synced'));
          return customer;
        }
      } catch (_) {}
    }

    // 3. Enqueue if offline or server update failed
    await syncRepository.enqueueSyncItem(
      SyncItemEntity(
        id: const Uuid().v4(),
        entityType: 'CUSTOMER',
        action: SyncAction.update,
        payload: {
          'id': customer.id,
          'name': customer.name,
          'phone': customer.phone,
          'email': customer.email,
          'address': customer.address,
        },
        createdAt: DateTime.now(),
      ),
    );

    return customer;
  }

  @override
  Future<List<CustomerTimelineEvent>> getCustomerTimeline(String customerId) async {
    return [];
  }

  @override
  Future<void> addTimelineEvent(CustomerTimelineEvent event) async {}
}
