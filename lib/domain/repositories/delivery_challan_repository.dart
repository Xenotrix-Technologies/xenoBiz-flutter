import '../entities/delivery_challan_entity.dart';

abstract class DeliveryChallanRepository {
  Future<List<DeliveryChallanEntity>> getDeliveryChallans({
    DeliveryChallanStatus? status,
    String? query,
  });

  Future<DeliveryChallanEntity?> getDeliveryChallan(String id);
  Future<DeliveryChallanEntity> createDeliveryChallan(DeliveryChallanEntity challan);
  Future<DeliveryChallanEntity> updateDeliveryChallan(DeliveryChallanEntity challan);
  Future<void> deleteDeliveryChallan(String id);
}
