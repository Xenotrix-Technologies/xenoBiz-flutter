import 'package:equatable/equatable.dart';

enum SubscriptionStatus {
  unknown,
  checking,
  activeTrial,
  activeSubscription,
  trialExpired,
  subscriptionExpired,
  notSubscribed,
  gracePeriod,
  error,
}

class SubscriptionEntity extends Equatable {
  final String id;
  final String businessId;
  final SubscriptionStatus status;
  final String planName;
  final DateTime trialStartDate;
  final DateTime trialEndDate;
  final DateTime? subscriptionEndDate;
  final int configuredTrialDays;

  const SubscriptionEntity({
    required this.id,
    required this.businessId,
    required this.status,
    this.planName = '7-Day Free Trial',
    required this.trialStartDate,
    required this.trialEndDate,
    this.subscriptionEndDate,
    this.configuredTrialDays = 7,
  });

  bool get isEntitled =>
      status == SubscriptionStatus.activeTrial ||
      status == SubscriptionStatus.activeSubscription ||
      status == SubscriptionStatus.gracePeriod;

  int get remainingTrialDays {
    final now = DateTime.now();
    if (now.isAfter(trialEndDate)) return 0;
    return trialEndDate.difference(now).inDays + 1;
  }

  @override
  List<Object?> get props => [
        id,
        businessId,
        status,
        planName,
        trialStartDate,
        trialEndDate,
        subscriptionEndDate,
        configuredTrialDays,
      ];
}
