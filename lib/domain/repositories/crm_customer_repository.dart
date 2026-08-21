import '../entities/crm_customer_entity.dart';

abstract class CrmCustomerRepository {
  Future<List<CrmCustomerEntity>> getCrmCustomers({String? query});
  Stream<List<CrmCustomerEntity>> watchCrmCustomers({String? query});
  Future<CrmCustomerEntity> getCrmCustomer(String id);
  Future<CrmCustomerEntity> createCrmCustomer(CrmCustomerEntity customer);
  Future<CrmCustomerEntity> updateCrmCustomer(CrmCustomerEntity customer);
  Future<void> deleteCrmCustomer(String id);
}
