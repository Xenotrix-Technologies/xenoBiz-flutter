import 'package:flutter/foundation.dart';

/// Centralized REST API endpoint constants.
abstract class ApiEndpoints {
  // Configured for local Node.js backend server (http://10.0.2.2:3000 for Android emulator, http://localhost:3000 for Desktop/Web)
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api/v1';
    }
    return 'http://localhost:3000/api/v1';
  }

  // Auth & Profile
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String businessSetup = '/auth/business-setup';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/auth/profile';

  // Subscription
  static const String subscriptionEntitlement = '/subscription/entitlement';
  static const String startTrial = '/subscription/start-trial';
  static const String subscribe = '/subscription/subscribe';

  // Customers
  static const String customers = '/customers';
  static const String customerTimeline = '/customers/{id}/timeline';

  // Products & Inventory
  static const String products = '/products';
  static const String adjustStock = '/products/{id}/adjust-stock';

  // Invoices & Payments
  static const String invoices = '/invoices';
  static const String payments = '/payments';

  // CRM
  static const String leads = '/leads';
  static const String followUps = '/follow-ups';

  // Purchases & Expenses
  static const String suppliers = '/suppliers';
  static const String purchases = '/purchases';
  static const String expenses = '/expenses';

  // Sync
  static const String sync = '/sync/batch';
}
