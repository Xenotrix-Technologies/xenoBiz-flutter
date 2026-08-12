import '../entities/customer_entity.dart';

abstract class CustomerRepository {
  Future<List<CustomerEntity>> getCustomers({String? query});
  Future<CustomerEntity> getCustomer(String id);
  Future<CustomerEntity> createCustomer(CustomerEntity customer);
  Future<CustomerEntity> updateCustomer(CustomerEntity customer);
  Future<List<CustomerTimelineEvent>> getCustomerTimeline(String customerId);
  Future<void> addTimelineEvent(CustomerTimelineEvent event);
}
