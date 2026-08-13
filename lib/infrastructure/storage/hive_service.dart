import 'package:hive_flutter/hive_flutter.dart';
import '../../const/dummy.dart';

class HiveService {
  static const String boxAuth = 'auth_box';
  static const String boxBusiness = 'business_box';
  static const String boxSubscription = 'subscription_box';
  static const String boxCustomers = 'customers_box';
  static const String boxProducts = 'products_box';
  static const String boxInvoices = 'invoices_box';
  static const String boxLeads = 'leads_box';
  static const String boxSyncQueue = 'sync_queue_box';
  static const String boxPayments = 'payments_box';
  static const String boxPurchases = 'purchases_box';
  static const String boxExpenses = 'expenses_box';
  static const String boxSuppliers = 'suppliers_box';

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
    await Hive.openBox(boxPayments);
    await Hive.openBox(boxPurchases);
    await Hive.openBox(boxExpenses);
    await Hive.openBox(boxSuppliers);
  }

  Box getBox(String boxName) => Hive.box(boxName);

  Future<void> seedDummyDataIfEmpty() async {
    final custBox = getBox(boxCustomers);
    final prodBox = getBox(boxProducts);
    final invBox = getBox(boxInvoices);

    // Only populate dummy data if Hive local storage is currently empty
    if (custBox.isEmpty && prodBox.isEmpty && invBox.isEmpty) {
      // Seed Customers
      for (final cust in DummyData.customers) {
        await custBox.put(cust.id, {
          'id': cust.id,
          'name': cust.name,
          'phone': cust.phone,
          'email': cust.email,
          'address': cust.address,
          'outstandingBalance': cust.outstandingBalance,
          'totalPurchases': cust.totalPurchases,
          'createdAt': cust.createdAt.toIso8601String(),
          'syncStatus': 'synced',
        });
      }

      // Seed Products
      for (final prod in DummyData.products) {
        await prodBox.put(prod.id, {
          'id': prod.id,
          'name': prod.name,
          'sku': prod.sku,
          'category': prod.category,
          'sellingPrice': prod.sellingPrice,
          'purchasePrice': prod.purchasePrice,
          'stockQuantity': prod.stockQuantity,
          'reorderLevel': prod.reorderLevel,
          'unit': prod.unit,
          'createdAt': prod.createdAt.toIso8601String(),
          'syncStatus': 'synced',
        });
      }

      // Seed Invoices
      for (final inv in DummyData.invoices) {
        await invBox.put(inv.id, {
          'id': inv.id,
          'invoiceNumber': inv.invoiceNumber,
          'customerId': inv.customerId,
          'customerName': inv.customerName,
          'customerPhone': inv.customerPhone,
          'items': inv.items.map((i) => {
            'productId': i.productId,
            'productName': i.productName,
            'quantity': i.quantity,
            'unitPrice': i.unitPrice,
            'taxPercentage': i.taxPercentage,
          }).toList(),
          'subtotal': inv.subtotal,
          'taxTotal': inv.taxTotal,
          'discountTotal': inv.discountTotal,
          'grandTotal': inv.grandTotal,
          'paidAmount': inv.paidAmount,
          'status': inv.status.name,
          'issueDate': inv.issueDate.toIso8601String(),
          'dueDate': inv.dueDate.toIso8601String(),
          'notes': inv.notes,
          'syncStatus': 'synced',
        });
      }

      // Seed Payments
      final payBox = getBox(boxPayments);
      for (final pay in DummyData.payments) {
        await payBox.put(pay.id, {
          'id': pay.id,
          'invoiceId': pay.invoiceId,
          'customerId': pay.customerId,
          'customerName': pay.customerName,
          'amount': pay.amount,
          'paymentMode': pay.paymentMode,
          'paymentDate': pay.paymentDate.toIso8601String(),
          'notes': pay.notes,
          'syncStatus': 'synced',
        });
      }

      // Seed Leads
      final leadBox = getBox(boxLeads);
      for (final lead in DummyData.leads) {
        await leadBox.put(lead.id, {
          'id': lead.id,
          'title': lead.title,
          'contactName': lead.contactName,
          'phone': lead.phone,
          'email': lead.email,
          'estimatedValue': lead.estimatedValue,
          'stage': lead.stage.name,
          'notes': lead.notes,
          'createdAt': lead.createdAt.toIso8601String(),
          'nextFollowUpDate': lead.nextFollowUpDate?.toIso8601String(),
          'syncStatus': 'synced',
        });
      }

      // Seed Suppliers
      final suppBox = getBox(boxSuppliers);
      for (final supp in DummyData.suppliers) {
        await suppBox.put(supp.id, {
          'id': supp.id,
          'name': supp.name,
          'companyName': supp.companyName,
          'phone': supp.phone,
          'email': supp.email,
          'address': supp.address,
          'payableBalance': supp.payableBalance,
          'createdAt': supp.createdAt.toIso8601String(),
          'syncStatus': 'synced',
        });
      }

      // Seed Purchases
      final purBox = getBox(boxPurchases);
      for (final pur in DummyData.purchases) {
        await purBox.put(pur.id, {
          'id': pur.id,
          'poNumber': pur.poNumber,
          'supplierId': pur.supplierId,
          'supplierName': pur.supplierName,
          'totalAmount': pur.totalAmount,
          'status': pur.status,
          'orderDate': pur.orderDate.toIso8601String(),
          'notes': pur.notes,
          'syncStatus': 'synced',
        });
      }

      // Seed Expenses
      final expBox = getBox(boxExpenses);
      for (final exp in DummyData.expenses) {
        await expBox.put(exp.id, {
          'id': exp.id,
          'title': exp.title,
          'category': exp.category,
          'amount': exp.amount,
          'paymentMode': exp.paymentMode,
          'expenseDate': exp.expenseDate.toIso8601String(),
          'notes': exp.notes,
          'syncStatus': 'synced',
        });
      }
    }
  }
}

