import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../storage/hive_service.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final HiveService hiveService;

  SubscriptionRepositoryImpl({required this.hiveService});

  @override
  Future<SubscriptionEntity> checkEntitlement(String businessId) async {
    final box = hiveService.getBox(HiveService.boxSubscription);
    final startDateMillis = box.get('trial_start_date');

    if (startDateMillis == null) {
      // Initialize 7-day free trial on first check
      return await startTrial(businessId);
    }

    final startDate = DateTime.fromMillisecondsSinceEpoch(startDateMillis);
    final endDate = startDate.add(const Duration(days: 7));
    final isPaid = box.get('is_paid', defaultValue: false);

    if (isPaid) {
      return SubscriptionEntity(
        id: 'sub_paid_101',
        businessId: businessId,
        status: SubscriptionStatus.activeSubscription,
        planName: 'Enterprise Growth Annual',
        trialStartDate: startDate,
        trialEndDate: endDate,
        subscriptionEndDate: DateTime.now().add(const Duration(days: 365)),
      );
    }

    if (DateTime.now().isAfter(endDate)) {
      return SubscriptionEntity(
        id: 'sub_trial_101',
        businessId: businessId,
        status: SubscriptionStatus.trialExpired,
        trialStartDate: startDate,
        trialEndDate: endDate,
      );
    }

    return SubscriptionEntity(
      id: 'sub_trial_101',
      businessId: businessId,
      status: SubscriptionStatus.activeTrial,
      trialStartDate: startDate,
      trialEndDate: endDate,
    );
  }

  @override
  Future<SubscriptionEntity> startTrial(String businessId) async {
    final box = hiveService.getBox(HiveService.boxSubscription);
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 7));
    await box.put('trial_start_date', now.millisecondsSinceEpoch);
    await box.put('is_paid', false);

    return SubscriptionEntity(
      id: 'sub_trial_101',
      businessId: businessId,
      status: SubscriptionStatus.activeTrial,
      trialStartDate: now,
      trialEndDate: endDate,
    );
  }

  @override
  Future<SubscriptionEntity> purchasePlan(String businessId, String planId) async {
    final box = hiveService.getBox(HiveService.boxSubscription);
    await box.put('is_paid', true);
    final startDateMillis = box.get('trial_start_date', defaultValue: DateTime.now().millisecondsSinceEpoch);
    final startDate = DateTime.fromMillisecondsSinceEpoch(startDateMillis);

    return SubscriptionEntity(
      id: 'sub_paid_101',
      businessId: businessId,
      status: SubscriptionStatus.activeSubscription,
      planName: 'Pro Business Plan ($planId)',
      trialStartDate: startDate,
      trialEndDate: startDate.add(const Duration(days: 7)),
      subscriptionEndDate: DateTime.now().add(const Duration(days: 365)),
    );
  }

  @override
  Future<SubscriptionEntity> restorePurchase(String businessId) async {
    return purchasePlan(businessId, 'PRO_ANNUAL');
  }
}
