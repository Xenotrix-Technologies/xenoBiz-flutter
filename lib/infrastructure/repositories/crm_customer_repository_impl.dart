import 'package:uuid/uuid.dart';
import '../../domain/entities/crm_customer_entity.dart';
import '../../domain/repositories/crm_customer_repository.dart';
import '../storage/hive_service.dart';

class CrmCustomerRepositoryImpl implements CrmCustomerRepository {
  final HiveService hiveService;

  CrmCustomerRepositoryImpl({
    required this.hiveService,
  });

  @override
  Future<List<CrmCustomerEntity>> getCrmCustomers({String? query}) async {
    final box = hiveService.getBox(HiveService.boxCrmCustomers);
    final List<CrmCustomerEntity> customers = [];

    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        customers.add(CrmCustomerEntity.fromMap(val));
      }
    }

    customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (query == null || query.trim().isEmpty) {
      return customers;
    }

    final q = query.trim().toLowerCase();
    return customers.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.companyName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Stream<List<CrmCustomerEntity>> watchCrmCustomers({String? query}) {
    final box = hiveService.getBox(HiveService.boxCrmCustomers);
    return box.watch().asyncMap((_) async => await getCrmCustomers(query: query));
  }

  @override
  Future<CrmCustomerEntity> getCrmCustomer(String id) async {
    final box = hiveService.getBox(HiveService.boxCrmCustomers);
    final val = box.get(id);
    if (val is Map) {
      return CrmCustomerEntity.fromMap(val);
    }
    return CrmCustomerEntity(
      id: id,
      name: 'Unknown CRM Customer',
      phone: '',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<CrmCustomerEntity> createCrmCustomer(CrmCustomerEntity customer) async {
    final box = hiveService.getBox(HiveService.boxCrmCustomers);
    final String customerId = customer.id.isNotEmpty ? customer.id : const Uuid().v4();
    final localCustomer = customer.copyWith(id: customerId);

    await box.put(customerId, localCustomer.toMap());
    return localCustomer;
  }

  @override
  Future<CrmCustomerEntity> updateCrmCustomer(CrmCustomerEntity customer) async {
    final box = hiveService.getBox(HiveService.boxCrmCustomers);
    final updated = customer.copyWith(updatedAt: DateTime.now());
    await box.put(customer.id, updated.toMap());
    return updated;
  }

  @override
  Future<void> deleteCrmCustomer(String id) async {
    final box = hiveService.getBox(HiveService.boxCrmCustomers);
    await box.delete(id);
  }
}
