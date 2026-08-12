import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../storage/hive_service.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final HiveService hiveService;
  final List<CustomerEntity> _customers = [];
  final List<CustomerTimelineEvent> _timelineEvents = [];

  CustomerRepositoryImpl({required this.hiveService});

  @override
  Future<List<CustomerEntity>> getCustomers({String? query}) async {
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
    _customers.insert(0, customer);
    return customer;
  }

  @override
  Future<CustomerEntity> updateCustomer(CustomerEntity customer) async {
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
