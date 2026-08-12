import '../entities/subscription_entity.dart';

abstract class SubscriptionRepository {
  Future<SubscriptionEntity> checkEntitlement(String businessId);
  Future<SubscriptionEntity> startTrial(String businessId);
  Future<SubscriptionEntity> purchasePlan(String businessId, String planId);
  Future<SubscriptionEntity> restorePurchase(String businessId);
}
