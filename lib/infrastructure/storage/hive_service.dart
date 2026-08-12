import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String boxAuth = 'auth_box';
  static const String boxBusiness = 'business_box';
  static const String boxSubscription = 'subscription_box';
  static const String boxCustomers = 'customers_box';
  static const String boxProducts = 'products_box';
  static const String boxInvoices = 'invoices_box';
  static const String boxLeads = 'leads_box';
  static const String boxSyncQueue = 'sync_queue_box';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxAuth);
    await Hive.openBox(boxBusiness);
    await Hive.openBox(boxSubscription);
    await Hive.openBox(boxCustomers);
    await Hive.openBox(boxProducts);
    await Hive.openBox(boxInvoices);
    await Hive.openBox(boxLeads);
    await Hive.openBox(boxSyncQueue);
  }

  Box getBox(String boxName) => Hive.box(boxName);
}
