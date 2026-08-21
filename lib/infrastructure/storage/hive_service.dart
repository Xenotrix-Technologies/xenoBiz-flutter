import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String boxAuth = 'auth_box';
  static const String boxBusiness = 'business_box';
  static const String boxSubscription = 'subscription_box';
  static const String boxBillingCustomers = 'billing_customers_box';
  static const String boxCrmCustomers = 'crm_customers_box';
  static const String boxCustomers = 'customers_box';
  static const String boxProducts = 'products_box';
  static const String boxInvoices = 'invoices_box';
  static const String boxLeads = 'leads_box';
  static const String boxSyncQueue = 'sync_queue_box';
  static const String boxPayments = 'payments_box';
  static const String boxPurchases = 'purchases_box';
  static const String boxExpenses = 'expenses_box';
  static const String boxSuppliers = 'suppliers_box';
  static const String boxStockMovements = 'stock_movements_box';
  static const String boxSalesReturns = 'sales_returns_box';
  static const String boxPurchaseReturns = 'purchase_returns_box';
  static const String boxIncome = 'income_box';
  static const String boxCategories = 'categories_box';
  static const String boxCrmNotes = 'crm_notes_box';
  static const String boxCrmFollowUps = 'crm_followups_box';
  static const String boxCrmSettings = 'crm_settings_box';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxAuth);
    await Hive.openBox(boxBusiness);
    await Hive.openBox(boxSubscription);
    await Hive.openBox(boxBillingCustomers);
    await Hive.openBox(boxCrmCustomers);
    await Hive.openBox(boxCustomers);
    await Hive.openBox(boxProducts);
    await Hive.openBox(boxInvoices);
    await Hive.openBox(boxLeads);
    await Hive.openBox(boxSyncQueue);
    await Hive.openBox(boxPayments);
    await Hive.openBox(boxPurchases);
    await Hive.openBox(boxExpenses);
    await Hive.openBox(boxSuppliers);
    await Hive.openBox(boxStockMovements);
    await Hive.openBox(boxSalesReturns);
    await Hive.openBox(boxPurchaseReturns);
    await Hive.openBox(boxIncome);
    await Hive.openBox(boxCategories);
    await Hive.openBox(boxCrmNotes);
    await Hive.openBox(boxCrmFollowUps);
    await Hive.openBox(boxCrmSettings);

    _migrateLegacyCustomers();
  }

  void _migrateLegacyCustomers() {
    try {
      final billingBox = Hive.box(boxBillingCustomers);
      final legacyBox = Hive.box(boxCustomers);
      if (billingBox.isEmpty && legacyBox.isNotEmpty) {
        for (var key in legacyBox.keys) {
          final val = legacyBox.get(key);
          if (val != null) {
            billingBox.put(key, val);
          }
        }
      }
    } catch (_) {}
  }

  Box getBox(String boxName) => Hive.box(boxName);

  Future<void> seedDummyDataIfEmpty() async {
    // Left empty so local boxes start clean and only display server or user-created data.
  }
}
