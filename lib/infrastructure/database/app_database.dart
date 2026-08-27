import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// 1. Customers Table
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get email => text()();
  TextColumn get address => text()();
  TextColumn get state => text().nullable()();
  RealColumn get outstandingBalance => real().withDefault(const Constant(0.0))();
  RealColumn get totalPurchases => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}

// 2. Products Table
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get sku => text()();
  TextColumn get barcode => text()();
  TextColumn get category => text().withDefault(const Constant('General'))();
  RealColumn get sellingPrice => real().withDefault(const Constant(0.0))();
  RealColumn get purchasePrice => real().withDefault(const Constant(0.0))();
  IntColumn get stockQuantity => integer().withDefault(const Constant(0))();
  IntColumn get reorderLevel => integer().withDefault(const Constant(5))();
  TextColumn get unit => text().withDefault(const Constant('Pcs'))();
  RealColumn get taxPercentage => real().nullable()();
  TextColumn get hsnCode => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}

// 3. Stock Movements Table
class StockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  TextColumn get type => text()();
  IntColumn get quantityChange => integer()();
  IntColumn get previousQuantity => integer()();
  IntColumn get newQuantity => integer()();
  TextColumn get reason => text()();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 4. Invoices Table
class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNumber => text()();
  TextColumn get type => text()();
  TextColumn get customerId => text()();
  TextColumn get customerName => text()();
  TextColumn get customerPhone => text()();
  RealColumn get subtotal => real().withDefault(const Constant(0.0))();
  RealColumn get taxTotal => real().withDefault(const Constant(0.0))();
  RealColumn get discountTotal => real().withDefault(const Constant(0.0))();
  RealColumn get grandTotal => real().withDefault(const Constant(0.0))();
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();
  TextColumn get status => text()();
  DateTimeColumn get issueDate => dateTime()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}

// 5. Invoice Items Table
class InvoiceItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get invoiceId => text().references(Invoices, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  TextColumn get sku => text().withDefault(const Constant(''))();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  RealColumn get unitPrice => real().withDefault(const Constant(0.0))();
  RealColumn get taxPercentage => real().withDefault(const Constant(0.0))();
}

// 6. Payments Table
class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text()();
  TextColumn get customerId => text()();
  TextColumn get customerName => text()();
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  TextColumn get paymentMode => text()();
  TextColumn get referenceNumber => text().withDefault(const Constant(''))();
  DateTimeColumn get paymentDate => dateTime()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}

// 7. Purchases Table
class Purchases extends Table {
  TextColumn get id => text()();
  TextColumn get poNumber => text()();
  TextColumn get supplierId => text()();
  TextColumn get supplierName => text()();
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  TextColumn get status => text()();
  DateTimeColumn get orderDate => dateTime()();
  TextColumn get notes => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

// 8. Suppliers Table
class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get companyName => text()();
  TextColumn get phone => text()();
  TextColumn get email => text()();
  TextColumn get address => text()();
  RealColumn get payableBalance => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 9. Expenses Table
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get category => text()();
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  TextColumn get paymentMode => text()();
  DateTimeColumn get expenseDate => dateTime()();
  TextColumn get notes => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

// 10. Income Table
class Income extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get category => text()();
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  TextColumn get paymentMode => text()();
  DateTimeColumn get incomeDate => dateTime()();
  TextColumn get notes => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

// 11. Categories Table
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// 12. Invoice Returns Table
class InvoiceReturns extends Table {
  TextColumn get id => text()();
  TextColumn get returnNumber => text()();
  TextColumn get invoiceId => text()();
  TextColumn get invoiceNumber => text()();
  TextColumn get partyId => text()();
  TextColumn get partyName => text()();
  TextColumn get type => text()();
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get returnDate => dateTime()();
  TextColumn get notes => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

// 13. Invoice Return Items Table
class InvoiceReturnItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get returnId => text().references(InvoiceReturns, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  TextColumn get sku => text().withDefault(const Constant(''))();
  IntColumn get originalQuantity => integer().withDefault(const Constant(0))();
  IntColumn get returnedQuantity => integer().withDefault(const Constant(0))();
  RealColumn get unitPrice => real().withDefault(const Constant(0.0))();
}

// 14. Sync Queue Table
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get action => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('PENDING'))();

  @override
  Set<Column> get primaryKey => {id};
}

// 15. App Key Value Store (Replacement for generic Hive settings boxes)
class AppKeyValueStore extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  Customers,
  Products,
  StockMovements,
  Invoices,
  InvoiceItems,
  Payments,
  Purchases,
  Suppliers,
  Expenses,
  Income,
  Categories,
  InvoiceReturns,
  InvoiceReturnItems,
  SyncQueue,
  AppKeyValueStore,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'xenobiz_app_db');
  }

  // Key-Value Helper Methods
  Future<String?> getKeyValue(String key) async {
    final query = select(appKeyValueStore)..where((tbl) => tbl.key.equals(key));
    final row = await query.getSingleOrNull();
    return row?.value;
  }

  Future<void> putKeyValue(String key, String value) async {
    await into(appKeyValueStore).insertOnConflictUpdate(
      AppKeyValueStoreCompanion.insert(key: key, value: value),
    );
  }

  Future<void> deleteKeyValue(String key) async {
    await (delete(appKeyValueStore)..where((tbl) => tbl.key.equals(key))).go();
  }

  Future<void> clearKeyValuesWithPrefix(String prefix) async {
    await (delete(appKeyValueStore)..where((tbl) => tbl.key.like('$prefix%'))).go();
  }
}
