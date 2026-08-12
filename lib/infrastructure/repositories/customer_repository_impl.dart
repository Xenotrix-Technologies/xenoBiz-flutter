import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import '../storage/hive_service.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final DioClient dioClient;
  final HiveService hiveService;
  final List<CustomerEntity> _customers = [];
  final List<CustomerTimelineEvent> _timelineEvents = [];

  CustomerRepositoryImpl({
    required this.dioClient,
    required this.hiveService,
  });

  @override
  Future<List<CustomerEntity>> getCustomers({String? query}) async {
    try {
      final response = await dioClient.dio.get(
        ApiEndpoints.customers,
        queryParameters: query != null && query.isNotEmpty ? {'search': query} : null,
      );

      if (response.data != null && response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        final fetched = list.map((item) {
          return CustomerEntity(
            id: item['id'],
            name: item['name'] ?? 'Unnamed',
            phone: item['phone'] ?? '',
            email: item['email'] ?? '',
            address: item['address'] ?? '',
            outstandingBalance: (item['outstanding_balance'] as num?)?.toDouble() ?? 0.0,
            totalPurchases: (item['total_purchases'] as num?)?.toDouble() ?? 0.0,
            createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
          );
        }).toList();

        _customers.clear();
        _customers.addAll(fetched);
        return fetched;
      }
    } catch (_) {}

    // Fallback filter on local list
    if (query == null || query.isEmpty) {
      return List.unmodifiable(_customers);
    }
    final q = query.toLowerCase();
    return _customers.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<CustomerEntity> getCustomer(String id) async {
    try {
      final response = await dioClient.dio.get('${ApiEndpoints.customers}/$id');
      if (response.data != null && response.data['success'] == true) {
        final item = response.data['data'];
        return CustomerEntity(
          id: item['id'],
          name: item['name'] ?? 'Unknown Customer',
          phone: item['phone'] ?? '',
          email: item['email'] ?? '',
          address: item['address'] ?? '',
          outstandingBalance: (item['outstanding_balance'] as num?)?.toDouble() ?? 0.0,
          totalPurchases: (item['total_purchases'] as num?)?.toDouble() ?? 0.0,
          createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
        );
      }
    } catch (_) {}

    return _customers.firstWhere(
      (c) => c.id == id,
      orElse: () => CustomerEntity(
        id: id,
        name: 'Unknown Customer',
        phone: '',
        email: '',
        address: '',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<CustomerEntity> createCustomer(CustomerEntity customer) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.customers,
        data: {
          'name': customer.name,
          'phone': customer.phone,
          'email': customer.email,
          'address': customer.address,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final item = response.data['data'];
        final created = CustomerEntity(
          id: item['id'],
          name: item['name'],
          phone: item['phone'] ?? '',
          email: item['email'] ?? '',
          address: item['address'] ?? '',
          outstandingBalance: (item['outstanding_balance'] as num?)?.toDouble() ?? 0.0,
          totalPurchases: (item['total_purchases'] as num?)?.toDouble() ?? 0.0,
          createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
        );
        _customers.insert(0, created);
        return created;
      }
    } catch (_) {}

    _customers.insert(0, customer);
    return customer;
  }

  @override
  Future<CustomerEntity> updateCustomer(CustomerEntity customer) async {
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
        final item = response.data['data'];
        final updated = CustomerEntity(
          id: item['id'],
          name: item['name'],
          phone: item['phone'] ?? '',
          email: item['email'] ?? '',
          address: item['address'] ?? '',
          outstandingBalance: (item['outstanding_balance'] as num?)?.toDouble() ?? 0.0,
          totalPurchases: (item['total_purchases'] as num?)?.toDouble() ?? 0.0,
          createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
        );
        final idx = _customers.indexWhere((c) => c.id == customer.id);
        if (idx != -1) _customers[idx] = updated;
        return updated;
      }
    } catch (_) {}

    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
    } else {
      _customers.add(customer);
    }
    return customer;
  }

  @override
  Future<List<CustomerTimelineEvent>> getCustomerTimeline(String customerId) async {
    return _timelineEvents.where((e) => e.customerId == customerId || customerId.isEmpty).toList();
  }

  @override
  Future<void> addTimelineEvent(CustomerTimelineEvent event) async {
    _timelineEvents.insert(0, event);
  }
}

