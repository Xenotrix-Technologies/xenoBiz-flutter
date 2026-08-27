import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../database/app_database.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final AppDatabase db;

  SubscriptionRepositoryImpl({required this.db});

  @override
  Future<SubscriptionEntity> checkEntitlement(String businessId) async {
    final startDateStr = await db.getKeyValue('sub_trial_start_date');

    if (startDateStr == null) {
      return await startTrial(businessId);
    }

    final startDateMillis = int.tryParse(startDateStr) ?? DateTime.now().millisecondsSinceEpoch;
    final startDate = DateTime.fromMillisecondsSinceEpoch(startDateMillis);
    final endDate = startDate.add(const Duration(days: 7));
    final isPaid = (await db.getKeyValue('sub_is_paid')) == 'true';

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
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 7));
    await db.putKeyValue('sub_trial_start_date', now.millisecondsSinceEpoch.toString());
    await db.putKeyValue('sub_is_paid', 'false');

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
    await db.putKeyValue('sub_is_paid', 'true');
    final startDateStr = await db.getKeyValue('sub_trial_start_date');
    final startDateMillis = int.tryParse(startDateStr ?? '') ?? DateTime.now().millisecondsSinceEpoch;
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
