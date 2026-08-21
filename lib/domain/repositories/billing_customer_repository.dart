import '../entities/billing_customer_entity.dart';
import '../entities/customer_entity.dart';

abstract class BillingCustomerRepository {
  Future<List<BillingCustomerEntity>> getBillingCustomers({String? query});
  Future<BillingCustomerEntity> getBillingCustomer(String id);
  Future<BillingCustomerEntity> createBillingCustomer(BillingCustomerEntity customer);
  Future<BillingCustomerEntity> updateBillingCustomer(BillingCustomerEntity customer);
  Future<void> deleteBillingCustomer(String id);

  // Backward compatibility alias methods
  Future<List<BillingCustomerEntity>> getCustomers({String? query});
  Future<BillingCustomerEntity> getCustomer(String id);
  Future<BillingCustomerEntity> createCustomer(BillingCustomerEntity customer);
  Future<BillingCustomerEntity> updateCustomer(BillingCustomerEntity customer);
  Future<void> deleteCustomer(String id);

  Future<List<CustomerTimelineEvent>> getCustomerTimeline(String customerId);
  Future<void> addTimelineEvent(CustomerTimelineEvent event);
}
