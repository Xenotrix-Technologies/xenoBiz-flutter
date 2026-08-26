// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _outstandingBalanceMeta =
      const VerificationMeta('outstandingBalance');
  @override
  late final GeneratedColumn<double> outstandingBalance =
      GeneratedColumn<double>('outstanding_balance', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _totalPurchasesMeta =
      const VerificationMeta('totalPurchases');
  @override
  late final GeneratedColumn<double> totalPurchases = GeneratedColumn<double>(
      'total_purchases', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        phone,
        email,
        address,
        state,
        outstandingBalance,
        totalPurchases,
        createdAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(Insertable<Customer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    }
    if (data.containsKey('outstanding_balance')) {
      context.handle(
          _outstandingBalanceMeta,
          outstandingBalance.isAcceptableOrUnknown(
              data['outstanding_balance']!, _outstandingBalanceMeta));
    }
    if (data.containsKey('total_purchases')) {
      context.handle(
          _totalPurchasesMeta,
          totalPurchases.isAcceptableOrUnknown(
              data['total_purchases']!, _totalPurchasesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state']),
      outstandingBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}outstanding_balance'])!,
      totalPurchases: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_purchases'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String? state;
  final double outstandingBalance;
  final double totalPurchases;
  final DateTime createdAt;
  final String syncStatus;
  const Customer(
      {required this.id,
      required this.name,
      required this.phone,
      required this.email,
      required this.address,
      this.state,
      required this.outstandingBalance,
      required this.totalPurchases,
      required this.createdAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    map['email'] = Variable<String>(email);
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    map['outstanding_balance'] = Variable<double>(outstandingBalance);
    map['total_purchases'] = Variable<double>(totalPurchases);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      email: Value(email),
      address: Value(address),
      state:
          state == null && nullToAbsent ? const Value.absent() : Value(state),
      outstandingBalance: Value(outstandingBalance),
      totalPurchases: Value(totalPurchases),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String>(json['email']),
      address: serializer.fromJson<String>(json['address']),
      state: serializer.fromJson<String?>(json['state']),
      outstandingBalance:
          serializer.fromJson<double>(json['outstandingBalance']),
      totalPurchases: serializer.fromJson<double>(json['totalPurchases']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String>(email),
      'address': serializer.toJson<String>(address),
      'state': serializer.toJson<String?>(state),
      'outstandingBalance': serializer.toJson<double>(outstandingBalance),
      'totalPurchases': serializer.toJson<double>(totalPurchases),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Customer copyWith(
          {String? id,
          String? name,
          String? phone,
          String? email,
          String? address,
          Value<String?> state = const Value.absent(),
          double? outstandingBalance,
          double? totalPurchases,
          DateTime? createdAt,
          String? syncStatus}) =>
      Customer(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        state: state.present ? state.value : this.state,
        outstandingBalance: outstandingBalance ?? this.outstandingBalance,
        totalPurchases: totalPurchases ?? this.totalPurchases,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      state: data.state.present ? data.state.value : this.state,
      outstandingBalance: data.outstandingBalance.present
          ? data.outstandingBalance.value
          : this.outstandingBalance,
      totalPurchases: data.totalPurchases.present
          ? data.totalPurchases.value
          : this.totalPurchases,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('state: $state, ')
          ..write('outstandingBalance: $outstandingBalance, ')
          ..write('totalPurchases: $totalPurchases, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, email, address, state,
      outstandingBalance, totalPurchases, createdAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.state == this.state &&
          other.outstandingBalance == this.outstandingBalance &&
          other.totalPurchases == this.totalPurchases &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String> email;
  final Value<String> address;
  final Value<String?> state;
  final Value<double> outstandingBalance;
  final Value<double> totalPurchases;
  final Value<DateTime> createdAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.state = const Value.absent(),
    this.outstandingBalance = const Value.absent(),
    this.totalPurchases = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String name,
    required String phone,
    required String email,
    required String address,
    this.state = const Value.absent(),
    this.outstandingBalance = const Value.absent(),
    this.totalPurchases = const Value.absent(),
    required DateTime createdAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        phone = Value(phone),
        email = Value(email),
        address = Value(address),
        createdAt = Value(createdAt);
  static Insertable<Customer> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? state,
    Expression<double>? outstandingBalance,
    Expression<double>? totalPurchases,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (state != null) 'state': state,
      if (outstandingBalance != null) 'outstanding_balance': outstandingBalance,
      if (totalPurchases != null) 'total_purchases': totalPurchases,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? phone,
      Value<String>? email,
      Value<String>? address,
      Value<String?>? state,
      Value<double>? outstandingBalance,
      Value<double>? totalPurchases,
      Value<DateTime>? createdAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      state: state ?? this.state,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (outstandingBalance.present) {
      map['outstanding_balance'] = Variable<double>(outstandingBalance.value);
    }
    if (totalPurchases.present) {
      map['total_purchases'] = Variable<double>(totalPurchases.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('state: $state, ')
          ..write('outstandingBalance: $outstandingBalance, ')
          ..write('totalPurchases: $totalPurchases, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('General'));
  static const VerificationMeta _sellingPriceMeta =
      const VerificationMeta('sellingPrice');
  @override
  late final GeneratedColumn<double> sellingPrice = GeneratedColumn<double>(
      'selling_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _purchasePriceMeta =
      const VerificationMeta('purchasePrice');
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
      'purchase_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _stockQuantityMeta =
      const VerificationMeta('stockQuantity');
  @override
  late final GeneratedColumn<int> stockQuantity = GeneratedColumn<int>(
      'stock_quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _reorderLevelMeta =
      const VerificationMeta('reorderLevel');
  @override
  late final GeneratedColumn<int> reorderLevel = GeneratedColumn<int>(
      'reorder_level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Pcs'));
  static const VerificationMeta _taxPercentageMeta =
      const VerificationMeta('taxPercentage');
  @override
  late final GeneratedColumn<double> taxPercentage = GeneratedColumn<double>(
      'tax_percentage', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _hsnCodeMeta =
      const VerificationMeta('hsnCode');
  @override
  late final GeneratedColumn<String> hsnCode = GeneratedColumn<String>(
      'hsn_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        sku,
        barcode,
        category,
        sellingPrice,
        purchasePrice,
        stockQuantity,
        reorderLevel,
        unit,
        taxPercentage,
        hsnCode,
        description,
        isActive,
        createdAt,
        updatedAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<Product> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('selling_price')) {
      context.handle(
          _sellingPriceMeta,
          sellingPrice.isAcceptableOrUnknown(
              data['selling_price']!, _sellingPriceMeta));
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
          _purchasePriceMeta,
          purchasePrice.isAcceptableOrUnknown(
              data['purchase_price']!, _purchasePriceMeta));
    }
    if (data.containsKey('stock_quantity')) {
      context.handle(
          _stockQuantityMeta,
          stockQuantity.isAcceptableOrUnknown(
              data['stock_quantity']!, _stockQuantityMeta));
    }
    if (data.containsKey('reorder_level')) {
      context.handle(
          _reorderLevelMeta,
          reorderLevel.isAcceptableOrUnknown(
              data['reorder_level']!, _reorderLevelMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('tax_percentage')) {
      context.handle(
          _taxPercentageMeta,
          taxPercentage.isAcceptableOrUnknown(
              data['tax_percentage']!, _taxPercentageMeta));
    }
    if (data.containsKey('hsn_code')) {
      context.handle(_hsnCodeMeta,
          hsnCode.isAcceptableOrUnknown(data['hsn_code']!, _hsnCodeMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      sellingPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}selling_price'])!,
      purchasePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}purchase_price'])!,
      stockQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock_quantity'])!,
      reorderLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reorder_level'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      taxPercentage: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tax_percentage']),
      hsnCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hsn_code'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final String name;
  final String sku;
  final String barcode;
  final String category;
  final double sellingPrice;
  final double purchasePrice;
  final int stockQuantity;
  final int reorderLevel;
  final String unit;
  final double? taxPercentage;
  final String hsnCode;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String syncStatus;
  const Product(
      {required this.id,
      required this.name,
      required this.sku,
      required this.barcode,
      required this.category,
      required this.sellingPrice,
      required this.purchasePrice,
      required this.stockQuantity,
      required this.reorderLevel,
      required this.unit,
      this.taxPercentage,
      required this.hsnCode,
      required this.description,
      required this.isActive,
      required this.createdAt,
      this.updatedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sku'] = Variable<String>(sku);
    map['barcode'] = Variable<String>(barcode);
    map['category'] = Variable<String>(category);
    map['selling_price'] = Variable<double>(sellingPrice);
    map['purchase_price'] = Variable<double>(purchasePrice);
    map['stock_quantity'] = Variable<int>(stockQuantity);
    map['reorder_level'] = Variable<int>(reorderLevel);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || taxPercentage != null) {
      map['tax_percentage'] = Variable<double>(taxPercentage);
    }
    map['hsn_code'] = Variable<String>(hsnCode);
    map['description'] = Variable<String>(description);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      sku: Value(sku),
      barcode: Value(barcode),
      category: Value(category),
      sellingPrice: Value(sellingPrice),
      purchasePrice: Value(purchasePrice),
      stockQuantity: Value(stockQuantity),
      reorderLevel: Value(reorderLevel),
      unit: Value(unit),
      taxPercentage: taxPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(taxPercentage),
      hsnCode: Value(hsnCode),
      description: Value(description),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sku: serializer.fromJson<String>(json['sku']),
      barcode: serializer.fromJson<String>(json['barcode']),
      category: serializer.fromJson<String>(json['category']),
      sellingPrice: serializer.fromJson<double>(json['sellingPrice']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      stockQuantity: serializer.fromJson<int>(json['stockQuantity']),
      reorderLevel: serializer.fromJson<int>(json['reorderLevel']),
      unit: serializer.fromJson<String>(json['unit']),
      taxPercentage: serializer.fromJson<double?>(json['taxPercentage']),
      hsnCode: serializer.fromJson<String>(json['hsnCode']),
      description: serializer.fromJson<String>(json['description']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sku': serializer.toJson<String>(sku),
      'barcode': serializer.toJson<String>(barcode),
      'category': serializer.toJson<String>(category),
      'sellingPrice': serializer.toJson<double>(sellingPrice),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'stockQuantity': serializer.toJson<int>(stockQuantity),
      'reorderLevel': serializer.toJson<int>(reorderLevel),
      'unit': serializer.toJson<String>(unit),
      'taxPercentage': serializer.toJson<double?>(taxPercentage),
      'hsnCode': serializer.toJson<String>(hsnCode),
      'description': serializer.toJson<String>(description),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Product copyWith(
          {String? id,
          String? name,
          String? sku,
          String? barcode,
          String? category,
          double? sellingPrice,
          double? purchasePrice,
          int? stockQuantity,
          int? reorderLevel,
          String? unit,
          Value<double?> taxPercentage = const Value.absent(),
          String? hsnCode,
          String? description,
          bool? isActive,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          String? syncStatus}) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        sku: sku ?? this.sku,
        barcode: barcode ?? this.barcode,
        category: category ?? this.category,
        sellingPrice: sellingPrice ?? this.sellingPrice,
        purchasePrice: purchasePrice ?? this.purchasePrice,
        stockQuantity: stockQuantity ?? this.stockQuantity,
        reorderLevel: reorderLevel ?? this.reorderLevel,
        unit: unit ?? this.unit,
        taxPercentage:
            taxPercentage.present ? taxPercentage.value : this.taxPercentage,
        hsnCode: hsnCode ?? this.hsnCode,
        description: description ?? this.description,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sku: data.sku.present ? data.sku.value : this.sku,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      category: data.category.present ? data.category.value : this.category,
      sellingPrice: data.sellingPrice.present
          ? data.sellingPrice.value
          : this.sellingPrice,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      stockQuantity: data.stockQuantity.present
          ? data.stockQuantity.value
          : this.stockQuantity,
      reorderLevel: data.reorderLevel.present
          ? data.reorderLevel.value
          : this.reorderLevel,
      unit: data.unit.present ? data.unit.value : this.unit,
      taxPercentage: data.taxPercentage.present
          ? data.taxPercentage.value
          : this.taxPercentage,
      hsnCode: data.hsnCode.present ? data.hsnCode.value : this.hsnCode,
      description:
          data.description.present ? data.description.value : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('category: $category, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('unit: $unit, ')
          ..write('taxPercentage: $taxPercentage, ')
          ..write('hsnCode: $hsnCode, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      sku,
      barcode,
      category,
      sellingPrice,
      purchasePrice,
      stockQuantity,
      reorderLevel,
      unit,
      taxPercentage,
      hsnCode,
      description,
      isActive,
      createdAt,
      updatedAt,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.sku == this.sku &&
          other.barcode == this.barcode &&
          other.category == this.category &&
          other.sellingPrice == this.sellingPrice &&
          other.purchasePrice == this.purchasePrice &&
          other.stockQuantity == this.stockQuantity &&
          other.reorderLevel == this.reorderLevel &&
          other.unit == this.unit &&
          other.taxPercentage == this.taxPercentage &&
          other.hsnCode == this.hsnCode &&
          other.description == this.description &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> sku;
  final Value<String> barcode;
  final Value<String> category;
  final Value<double> sellingPrice;
  final Value<double> purchasePrice;
  final Value<int> stockQuantity;
  final Value<int> reorderLevel;
  final Value<String> unit;
  final Value<double?> taxPercentage;
  final Value<String> hsnCode;
  final Value<String> description;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sku = const Value.absent(),
    this.barcode = const Value.absent(),
    this.category = const Value.absent(),
    this.sellingPrice = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.unit = const Value.absent(),
    this.taxPercentage = const Value.absent(),
    this.hsnCode = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String name,
    required String sku,
    required String barcode,
    this.category = const Value.absent(),
    this.sellingPrice = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.unit = const Value.absent(),
    this.taxPercentage = const Value.absent(),
    this.hsnCode = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        sku = Value(sku),
        barcode = Value(barcode),
        createdAt = Value(createdAt);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? sku,
    Expression<String>? barcode,
    Expression<String>? category,
    Expression<double>? sellingPrice,
    Expression<double>? purchasePrice,
    Expression<int>? stockQuantity,
    Expression<int>? reorderLevel,
    Expression<String>? unit,
    Expression<double>? taxPercentage,
    Expression<String>? hsnCode,
    Expression<String>? description,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sku != null) 'sku': sku,
      if (barcode != null) 'barcode': barcode,
      if (category != null) 'category': category,
      if (sellingPrice != null) 'selling_price': sellingPrice,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (stockQuantity != null) 'stock_quantity': stockQuantity,
      if (reorderLevel != null) 'reorder_level': reorderLevel,
      if (unit != null) 'unit': unit,
      if (taxPercentage != null) 'tax_percentage': taxPercentage,
      if (hsnCode != null) 'hsn_code': hsnCode,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? sku,
      Value<String>? barcode,
      Value<String>? category,
      Value<double>? sellingPrice,
      Value<double>? purchasePrice,
      Value<int>? stockQuantity,
      Value<int>? reorderLevel,
      Value<String>? unit,
      Value<double?>? taxPercentage,
      Value<String>? hsnCode,
      Value<String>? description,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      unit: unit ?? this.unit,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      hsnCode: hsnCode ?? this.hsnCode,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (sellingPrice.present) {
      map['selling_price'] = Variable<double>(sellingPrice.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (stockQuantity.present) {
      map['stock_quantity'] = Variable<int>(stockQuantity.value);
    }
    if (reorderLevel.present) {
      map['reorder_level'] = Variable<int>(reorderLevel.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (taxPercentage.present) {
      map['tax_percentage'] = Variable<double>(taxPercentage.value);
    }
    if (hsnCode.present) {
      map['hsn_code'] = Variable<String>(hsnCode.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('category: $category, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('unit: $unit, ')
          ..write('taxPercentage: $taxPercentage, ')
          ..write('hsnCode: $hsnCode, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityChangeMeta =
      const VerificationMeta('quantityChange');
  @override
  late final GeneratedColumn<int> quantityChange = GeneratedColumn<int>(
      'quantity_change', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _previousQuantityMeta =
      const VerificationMeta('previousQuantity');
  @override
  late final GeneratedColumn<int> previousQuantity = GeneratedColumn<int>(
      'previous_quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _newQuantityMeta =
      const VerificationMeta('newQuantity');
  @override
  late final GeneratedColumn<int> newQuantity = GeneratedColumn<int>(
      'new_quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        productId,
        productName,
        type,
        quantityChange,
        previousQuantity,
        newQuantity,
        reason,
        timestamp
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(Insertable<StockMovement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantity_change')) {
      context.handle(
          _quantityChangeMeta,
          quantityChange.isAcceptableOrUnknown(
              data['quantity_change']!, _quantityChangeMeta));
    } else if (isInserting) {
      context.missing(_quantityChangeMeta);
    }
    if (data.containsKey('previous_quantity')) {
      context.handle(
          _previousQuantityMeta,
          previousQuantity.isAcceptableOrUnknown(
              data['previous_quantity']!, _previousQuantityMeta));
    } else if (isInserting) {
      context.missing(_previousQuantityMeta);
    }
    if (data.containsKey('new_quantity')) {
      context.handle(
          _newQuantityMeta,
          newQuantity.isAcceptableOrUnknown(
              data['new_quantity']!, _newQuantityMeta));
    } else if (isInserting) {
      context.missing(_newQuantityMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      quantityChange: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity_change'])!,
      previousQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}previous_quantity'])!,
      newQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}new_quantity'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovement extends DataClass implements Insertable<StockMovement> {
  final String id;
  final String productId;
  final String productName;
  final String type;
  final int quantityChange;
  final int previousQuantity;
  final int newQuantity;
  final String reason;
  final DateTime timestamp;
  const StockMovement(
      {required this.id,
      required this.productId,
      required this.productName,
      required this.type,
      required this.quantityChange,
      required this.previousQuantity,
      required this.newQuantity,
      required this.reason,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['type'] = Variable<String>(type);
    map['quantity_change'] = Variable<int>(quantityChange);
    map['previous_quantity'] = Variable<int>(previousQuantity);
    map['new_quantity'] = Variable<int>(newQuantity);
    map['reason'] = Variable<String>(reason);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      productName: Value(productName),
      type: Value(type),
      quantityChange: Value(quantityChange),
      previousQuantity: Value(previousQuantity),
      newQuantity: Value(newQuantity),
      reason: Value(reason),
      timestamp: Value(timestamp),
    );
  }

  factory StockMovement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovement(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      type: serializer.fromJson<String>(json['type']),
      quantityChange: serializer.fromJson<int>(json['quantityChange']),
      previousQuantity: serializer.fromJson<int>(json['previousQuantity']),
      newQuantity: serializer.fromJson<int>(json['newQuantity']),
      reason: serializer.fromJson<String>(json['reason']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'type': serializer.toJson<String>(type),
      'quantityChange': serializer.toJson<int>(quantityChange),
      'previousQuantity': serializer.toJson<int>(previousQuantity),
      'newQuantity': serializer.toJson<int>(newQuantity),
      'reason': serializer.toJson<String>(reason),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  StockMovement copyWith(
          {String? id,
          String? productId,
          String? productName,
          String? type,
          int? quantityChange,
          int? previousQuantity,
          int? newQuantity,
          String? reason,
          DateTime? timestamp}) =>
      StockMovement(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        type: type ?? this.type,
        quantityChange: quantityChange ?? this.quantityChange,
        previousQuantity: previousQuantity ?? this.previousQuantity,
        newQuantity: newQuantity ?? this.newQuantity,
        reason: reason ?? this.reason,
        timestamp: timestamp ?? this.timestamp,
      );
  StockMovement copyWithCompanion(StockMovementsCompanion data) {
    return StockMovement(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      type: data.type.present ? data.type.value : this.type,
      quantityChange: data.quantityChange.present
          ? data.quantityChange.value
          : this.quantityChange,
      previousQuantity: data.previousQuantity.present
          ? data.previousQuantity.value
          : this.previousQuantity,
      newQuantity:
          data.newQuantity.present ? data.newQuantity.value : this.newQuantity,
      reason: data.reason.present ? data.reason.value : this.reason,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovement(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('type: $type, ')
          ..write('quantityChange: $quantityChange, ')
          ..write('previousQuantity: $previousQuantity, ')
          ..write('newQuantity: $newQuantity, ')
          ..write('reason: $reason, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, productId, productName, type,
      quantityChange, previousQuantity, newQuantity, reason, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovement &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.type == this.type &&
          other.quantityChange == this.quantityChange &&
          other.previousQuantity == this.previousQuantity &&
          other.newQuantity == this.newQuantity &&
          other.reason == this.reason &&
          other.timestamp == this.timestamp);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovement> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> productName;
  final Value<String> type;
  final Value<int> quantityChange;
  final Value<int> previousQuantity;
  final Value<int> newQuantity;
  final Value<String> reason;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.type = const Value.absent(),
    this.quantityChange = const Value.absent(),
    this.previousQuantity = const Value.absent(),
    this.newQuantity = const Value.absent(),
    this.reason = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    required String id,
    required String productId,
    required String productName,
    required String type,
    required int quantityChange,
    required int previousQuantity,
    required int newQuantity,
    required String reason,
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        productId = Value(productId),
        productName = Value(productName),
        type = Value(type),
        quantityChange = Value(quantityChange),
        previousQuantity = Value(previousQuantity),
        newQuantity = Value(newQuantity),
        reason = Value(reason),
        timestamp = Value(timestamp);
  static Insertable<StockMovement> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<String>? type,
    Expression<int>? quantityChange,
    Expression<int>? previousQuantity,
    Expression<int>? newQuantity,
    Expression<String>? reason,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (type != null) 'type': type,
      if (quantityChange != null) 'quantity_change': quantityChange,
      if (previousQuantity != null) 'previous_quantity': previousQuantity,
      if (newQuantity != null) 'new_quantity': newQuantity,
      if (reason != null) 'reason': reason,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockMovementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? productId,
      Value<String>? productName,
      Value<String>? type,
      Value<int>? quantityChange,
      Value<int>? previousQuantity,
      Value<int>? newQuantity,
      Value<String>? reason,
      Value<DateTime>? timestamp,
      Value<int>? rowid}) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      quantityChange: quantityChange ?? this.quantityChange,
      previousQuantity: previousQuantity ?? this.previousQuantity,
      newQuantity: newQuantity ?? this.newQuantity,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (quantityChange.present) {
      map['quantity_change'] = Variable<int>(quantityChange.value);
    }
    if (previousQuantity.present) {
      map['previous_quantity'] = Variable<int>(previousQuantity.value);
    }
    if (newQuantity.present) {
      map['new_quantity'] = Variable<int>(newQuantity.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('type: $type, ')
          ..write('quantityChange: $quantityChange, ')
          ..write('previousQuantity: $previousQuantity, ')
          ..write('newQuantity: $newQuantity, ')
          ..write('reason: $reason, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTable extends Invoices with TableInfo<$InvoicesTable, Invoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceNumberMeta =
      const VerificationMeta('invoiceNumber');
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
      'invoice_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerPhoneMeta =
      const VerificationMeta('customerPhone');
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
      'customer_phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _taxTotalMeta =
      const VerificationMeta('taxTotal');
  @override
  late final GeneratedColumn<double> taxTotal = GeneratedColumn<double>(
      'tax_total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _discountTotalMeta =
      const VerificationMeta('discountTotal');
  @override
  late final GeneratedColumn<double> discountTotal = GeneratedColumn<double>(
      'discount_total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _grandTotalMeta =
      const VerificationMeta('grandTotal');
  @override
  late final GeneratedColumn<double> grandTotal = GeneratedColumn<double>(
      'grand_total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _paidAmountMeta =
      const VerificationMeta('paidAmount');
  @override
  late final GeneratedColumn<double> paidAmount = GeneratedColumn<double>(
      'paid_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _issueDateMeta =
      const VerificationMeta('issueDate');
  @override
  late final GeneratedColumn<DateTime> issueDate = GeneratedColumn<DateTime>(
      'issue_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        invoiceNumber,
        type,
        customerId,
        customerName,
        customerPhone,
        subtotal,
        taxTotal,
        discountTotal,
        grandTotal,
        paidAmount,
        status,
        issueDate,
        dueDate,
        notes,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(Insertable<Invoice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
          _invoiceNumberMeta,
          invoiceNumber.isAcceptableOrUnknown(
              data['invoice_number']!, _invoiceNumberMeta));
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
          _customerPhoneMeta,
          customerPhone.isAcceptableOrUnknown(
              data['customer_phone']!, _customerPhoneMeta));
    } else if (isInserting) {
      context.missing(_customerPhoneMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    }
    if (data.containsKey('tax_total')) {
      context.handle(_taxTotalMeta,
          taxTotal.isAcceptableOrUnknown(data['tax_total']!, _taxTotalMeta));
    }
    if (data.containsKey('discount_total')) {
      context.handle(
          _discountTotalMeta,
          discountTotal.isAcceptableOrUnknown(
              data['discount_total']!, _discountTotalMeta));
    }
    if (data.containsKey('grand_total')) {
      context.handle(
          _grandTotalMeta,
          grandTotal.isAcceptableOrUnknown(
              data['grand_total']!, _grandTotalMeta));
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
          _paidAmountMeta,
          paidAmount.isAcceptableOrUnknown(
              data['paid_amount']!, _paidAmountMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('issue_date')) {
      context.handle(_issueDateMeta,
          issueDate.isAcceptableOrUnknown(data['issue_date']!, _issueDateMeta));
    } else if (isInserting) {
      context.missing(_issueDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Invoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Invoice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      invoiceNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_number'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id'])!,
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name'])!,
      customerPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_phone'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal'])!,
      taxTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tax_total'])!,
      discountTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}discount_total'])!,
      grandTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}grand_total'])!,
      paidAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}paid_amount'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      issueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}issue_date'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }
}

class Invoice extends DataClass implements Insertable<Invoice> {
  final String id;
  final String invoiceNumber;
  final String type;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final double subtotal;
  final double taxTotal;
  final double discountTotal;
  final double grandTotal;
  final double paidAmount;
  final String status;
  final DateTime issueDate;
  final DateTime dueDate;
  final String notes;
  final String syncStatus;
  const Invoice(
      {required this.id,
      required this.invoiceNumber,
      required this.type,
      required this.customerId,
      required this.customerName,
      required this.customerPhone,
      required this.subtotal,
      required this.taxTotal,
      required this.discountTotal,
      required this.grandTotal,
      required this.paidAmount,
      required this.status,
      required this.issueDate,
      required this.dueDate,
      required this.notes,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    map['type'] = Variable<String>(type);
    map['customer_id'] = Variable<String>(customerId);
    map['customer_name'] = Variable<String>(customerName);
    map['customer_phone'] = Variable<String>(customerPhone);
    map['subtotal'] = Variable<double>(subtotal);
    map['tax_total'] = Variable<double>(taxTotal);
    map['discount_total'] = Variable<double>(discountTotal);
    map['grand_total'] = Variable<double>(grandTotal);
    map['paid_amount'] = Variable<double>(paidAmount);
    map['status'] = Variable<String>(status);
    map['issue_date'] = Variable<DateTime>(issueDate);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['notes'] = Variable<String>(notes);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      invoiceNumber: Value(invoiceNumber),
      type: Value(type),
      customerId: Value(customerId),
      customerName: Value(customerName),
      customerPhone: Value(customerPhone),
      subtotal: Value(subtotal),
      taxTotal: Value(taxTotal),
      discountTotal: Value(discountTotal),
      grandTotal: Value(grandTotal),
      paidAmount: Value(paidAmount),
      status: Value(status),
      issueDate: Value(issueDate),
      dueDate: Value(dueDate),
      notes: Value(notes),
      syncStatus: Value(syncStatus),
    );
  }

  factory Invoice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Invoice(
      id: serializer.fromJson<String>(json['id']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      type: serializer.fromJson<String>(json['type']),
      customerId: serializer.fromJson<String>(json['customerId']),
      customerName: serializer.fromJson<String>(json['customerName']),
      customerPhone: serializer.fromJson<String>(json['customerPhone']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      taxTotal: serializer.fromJson<double>(json['taxTotal']),
      discountTotal: serializer.fromJson<double>(json['discountTotal']),
      grandTotal: serializer.fromJson<double>(json['grandTotal']),
      paidAmount: serializer.fromJson<double>(json['paidAmount']),
      status: serializer.fromJson<String>(json['status']),
      issueDate: serializer.fromJson<DateTime>(json['issueDate']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      notes: serializer.fromJson<String>(json['notes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'type': serializer.toJson<String>(type),
      'customerId': serializer.toJson<String>(customerId),
      'customerName': serializer.toJson<String>(customerName),
      'customerPhone': serializer.toJson<String>(customerPhone),
      'subtotal': serializer.toJson<double>(subtotal),
      'taxTotal': serializer.toJson<double>(taxTotal),
      'discountTotal': serializer.toJson<double>(discountTotal),
      'grandTotal': serializer.toJson<double>(grandTotal),
      'paidAmount': serializer.toJson<double>(paidAmount),
      'status': serializer.toJson<String>(status),
      'issueDate': serializer.toJson<DateTime>(issueDate),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'notes': serializer.toJson<String>(notes),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Invoice copyWith(
          {String? id,
          String? invoiceNumber,
          String? type,
          String? customerId,
          String? customerName,
          String? customerPhone,
          double? subtotal,
          double? taxTotal,
          double? discountTotal,
          double? grandTotal,
          double? paidAmount,
          String? status,
          DateTime? issueDate,
          DateTime? dueDate,
          String? notes,
          String? syncStatus}) =>
      Invoice(
        id: id ?? this.id,
        invoiceNumber: invoiceNumber ?? this.invoiceNumber,
        type: type ?? this.type,
        customerId: customerId ?? this.customerId,
        customerName: customerName ?? this.customerName,
        customerPhone: customerPhone ?? this.customerPhone,
        subtotal: subtotal ?? this.subtotal,
        taxTotal: taxTotal ?? this.taxTotal,
        discountTotal: discountTotal ?? this.discountTotal,
        grandTotal: grandTotal ?? this.grandTotal,
        paidAmount: paidAmount ?? this.paidAmount,
        status: status ?? this.status,
        issueDate: issueDate ?? this.issueDate,
        dueDate: dueDate ?? this.dueDate,
        notes: notes ?? this.notes,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Invoice copyWithCompanion(InvoicesCompanion data) {
    return Invoice(
      id: data.id.present ? data.id.value : this.id,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      type: data.type.present ? data.type.value : this.type,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      taxTotal: data.taxTotal.present ? data.taxTotal.value : this.taxTotal,
      discountTotal: data.discountTotal.present
          ? data.discountTotal.value
          : this.discountTotal,
      grandTotal:
          data.grandTotal.present ? data.grandTotal.value : this.grandTotal,
      paidAmount:
          data.paidAmount.present ? data.paidAmount.value : this.paidAmount,
      status: data.status.present ? data.status.value : this.status,
      issueDate: data.issueDate.present ? data.issueDate.value : this.issueDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Invoice(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('type: $type, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('subtotal: $subtotal, ')
          ..write('taxTotal: $taxTotal, ')
          ..write('discountTotal: $discountTotal, ')
          ..write('grandTotal: $grandTotal, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('status: $status, ')
          ..write('issueDate: $issueDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      invoiceNumber,
      type,
      customerId,
      customerName,
      customerPhone,
      subtotal,
      taxTotal,
      discountTotal,
      grandTotal,
      paidAmount,
      status,
      issueDate,
      dueDate,
      notes,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Invoice &&
          other.id == this.id &&
          other.invoiceNumber == this.invoiceNumber &&
          other.type == this.type &&
          other.customerId == this.customerId &&
          other.customerName == this.customerName &&
          other.customerPhone == this.customerPhone &&
          other.subtotal == this.subtotal &&
          other.taxTotal == this.taxTotal &&
          other.discountTotal == this.discountTotal &&
          other.grandTotal == this.grandTotal &&
          other.paidAmount == this.paidAmount &&
          other.status == this.status &&
          other.issueDate == this.issueDate &&
          other.dueDate == this.dueDate &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus);
}

class InvoicesCompanion extends UpdateCompanion<Invoice> {
  final Value<String> id;
  final Value<String> invoiceNumber;
  final Value<String> type;
  final Value<String> customerId;
  final Value<String> customerName;
  final Value<String> customerPhone;
  final Value<double> subtotal;
  final Value<double> taxTotal;
  final Value<double> discountTotal;
  final Value<double> grandTotal;
  final Value<double> paidAmount;
  final Value<String> status;
  final Value<DateTime> issueDate;
  final Value<DateTime> dueDate;
  final Value<String> notes;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.type = const Value.absent(),
    this.customerId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.taxTotal = const Value.absent(),
    this.discountTotal = const Value.absent(),
    this.grandTotal = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.issueDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoicesCompanion.insert({
    required String id,
    required String invoiceNumber,
    required String type,
    required String customerId,
    required String customerName,
    required String customerPhone,
    this.subtotal = const Value.absent(),
    this.taxTotal = const Value.absent(),
    this.discountTotal = const Value.absent(),
    this.grandTotal = const Value.absent(),
    this.paidAmount = const Value.absent(),
    required String status,
    required DateTime issueDate,
    required DateTime dueDate,
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        invoiceNumber = Value(invoiceNumber),
        type = Value(type),
        customerId = Value(customerId),
        customerName = Value(customerName),
        customerPhone = Value(customerPhone),
        status = Value(status),
        issueDate = Value(issueDate),
        dueDate = Value(dueDate);
  static Insertable<Invoice> custom({
    Expression<String>? id,
    Expression<String>? invoiceNumber,
    Expression<String>? type,
    Expression<String>? customerId,
    Expression<String>? customerName,
    Expression<String>? customerPhone,
    Expression<double>? subtotal,
    Expression<double>? taxTotal,
    Expression<double>? discountTotal,
    Expression<double>? grandTotal,
    Expression<double>? paidAmount,
    Expression<String>? status,
    Expression<DateTime>? issueDate,
    Expression<DateTime>? dueDate,
    Expression<String>? notes,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (type != null) 'type': type,
      if (customerId != null) 'customer_id': customerId,
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (subtotal != null) 'subtotal': subtotal,
      if (taxTotal != null) 'tax_total': taxTotal,
      if (discountTotal != null) 'discount_total': discountTotal,
      if (grandTotal != null) 'grand_total': grandTotal,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (status != null) 'status': status,
      if (issueDate != null) 'issue_date': issueDate,
      if (dueDate != null) 'due_date': dueDate,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoicesCompanion copyWith(
      {Value<String>? id,
      Value<String>? invoiceNumber,
      Value<String>? type,
      Value<String>? customerId,
      Value<String>? customerName,
      Value<String>? customerPhone,
      Value<double>? subtotal,
      Value<double>? taxTotal,
      Value<double>? discountTotal,
      Value<double>? grandTotal,
      Value<double>? paidAmount,
      Value<String>? status,
      Value<DateTime>? issueDate,
      Value<DateTime>? dueDate,
      Value<String>? notes,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return InvoicesCompanion(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      type: type ?? this.type,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      subtotal: subtotal ?? this.subtotal,
      taxTotal: taxTotal ?? this.taxTotal,
      discountTotal: discountTotal ?? this.discountTotal,
      grandTotal: grandTotal ?? this.grandTotal,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (taxTotal.present) {
      map['tax_total'] = Variable<double>(taxTotal.value);
    }
    if (discountTotal.present) {
      map['discount_total'] = Variable<double>(discountTotal.value);
    }
    if (grandTotal.present) {
      map['grand_total'] = Variable<double>(grandTotal.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<double>(paidAmount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (issueDate.present) {
      map['issue_date'] = Variable<DateTime>(issueDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('type: $type, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('subtotal: $subtotal, ')
          ..write('taxTotal: $taxTotal, ')
          ..write('discountTotal: $discountTotal, ')
          ..write('grandTotal: $grandTotal, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('status: $status, ')
          ..write('issueDate: $issueDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceItemsTable extends InvoiceItems
    with TableInfo<$InvoiceItemsTable, InvoiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _invoiceIdMeta =
      const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
      'invoice_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _taxPercentageMeta =
      const VerificationMeta('taxPercentage');
  @override
  late final GeneratedColumn<double> taxPercentage = GeneratedColumn<double>(
      'tax_percentage', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        invoiceId,
        productId,
        productName,
        sku,
        quantity,
        unitPrice,
        taxPercentage
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_items';
  @override
  VerificationContext validateIntegrity(Insertable<InvoiceItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta,
          invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    }
    if (data.containsKey('tax_percentage')) {
      context.handle(
          _taxPercentageMeta,
          taxPercentage.isAcceptableOrUnknown(
              data['tax_percentage']!, _taxPercentageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      invoiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
      taxPercentage: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tax_percentage'])!,
    );
  }

  @override
  $InvoiceItemsTable createAlias(String alias) {
    return $InvoiceItemsTable(attachedDatabase, alias);
  }
}

class InvoiceItem extends DataClass implements Insertable<InvoiceItem> {
  final int id;
  final String invoiceId;
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double taxPercentage;
  const InvoiceItem(
      {required this.id,
      required this.invoiceId,
      required this.productId,
      required this.productName,
      required this.sku,
      required this.quantity,
      required this.unitPrice,
      required this.taxPercentage});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['sku'] = Variable<String>(sku);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['tax_percentage'] = Variable<double>(taxPercentage);
    return map;
  }

  InvoiceItemsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceItemsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      productId: Value(productId),
      productName: Value(productName),
      sku: Value(sku),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      taxPercentage: Value(taxPercentage),
    );
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceItem(
      id: serializer.fromJson<int>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      sku: serializer.fromJson<String>(json['sku']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      taxPercentage: serializer.fromJson<double>(json['taxPercentage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'sku': serializer.toJson<String>(sku),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'taxPercentage': serializer.toJson<double>(taxPercentage),
    };
  }

  InvoiceItem copyWith(
          {int? id,
          String? invoiceId,
          String? productId,
          String? productName,
          String? sku,
          int? quantity,
          double? unitPrice,
          double? taxPercentage}) =>
      InvoiceItem(
        id: id ?? this.id,
        invoiceId: invoiceId ?? this.invoiceId,
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        sku: sku ?? this.sku,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        taxPercentage: taxPercentage ?? this.taxPercentage,
      );
  InvoiceItem copyWithCompanion(InvoiceItemsCompanion data) {
    return InvoiceItem(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      sku: data.sku.present ? data.sku.value : this.sku,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      taxPercentage: data.taxPercentage.present
          ? data.taxPercentage.value
          : this.taxPercentage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItem(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('sku: $sku, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('taxPercentage: $taxPercentage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, invoiceId, productId, productName, sku,
      quantity, unitPrice, taxPercentage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceItem &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.sku == this.sku &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.taxPercentage == this.taxPercentage);
}

class InvoiceItemsCompanion extends UpdateCompanion<InvoiceItem> {
  final Value<int> id;
  final Value<String> invoiceId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<String> sku;
  final Value<int> quantity;
  final Value<double> unitPrice;
  final Value<double> taxPercentage;
  const InvoiceItemsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.sku = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.taxPercentage = const Value.absent(),
  });
  InvoiceItemsCompanion.insert({
    this.id = const Value.absent(),
    required String invoiceId,
    required String productId,
    required String productName,
    this.sku = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.taxPercentage = const Value.absent(),
  })  : invoiceId = Value(invoiceId),
        productId = Value(productId),
        productName = Value(productName);
  static Insertable<InvoiceItem> custom({
    Expression<int>? id,
    Expression<String>? invoiceId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<String>? sku,
    Expression<int>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? taxPercentage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (sku != null) 'sku': sku,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (taxPercentage != null) 'tax_percentage': taxPercentage,
    });
  }

  InvoiceItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? invoiceId,
      Value<String>? productId,
      Value<String>? productName,
      Value<String>? sku,
      Value<int>? quantity,
      Value<double>? unitPrice,
      Value<double>? taxPercentage}) {
    return InvoiceItemsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      taxPercentage: taxPercentage ?? this.taxPercentage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (taxPercentage.present) {
      map['tax_percentage'] = Variable<double>(taxPercentage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('sku: $sku, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('taxPercentage: $taxPercentage')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceIdMeta =
      const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
      'invoice_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _paymentModeMeta =
      const VerificationMeta('paymentMode');
  @override
  late final GeneratedColumn<String> paymentMode = GeneratedColumn<String>(
      'payment_mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceNumberMeta =
      const VerificationMeta('referenceNumber');
  @override
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
      'reference_number', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _paymentDateMeta =
      const VerificationMeta('paymentDate');
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
      'payment_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        invoiceId,
        customerId,
        customerName,
        amount,
        paymentMode,
        referenceNumber,
        paymentDate,
        notes,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<Payment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta,
          invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    }
    if (data.containsKey('payment_mode')) {
      context.handle(
          _paymentModeMeta,
          paymentMode.isAcceptableOrUnknown(
              data['payment_mode']!, _paymentModeMeta));
    } else if (isInserting) {
      context.missing(_paymentModeMeta);
    }
    if (data.containsKey('reference_number')) {
      context.handle(
          _referenceNumberMeta,
          referenceNumber.isAcceptableOrUnknown(
              data['reference_number']!, _referenceNumberMeta));
    }
    if (data.containsKey('payment_date')) {
      context.handle(
          _paymentDateMeta,
          paymentDate.isAcceptableOrUnknown(
              data['payment_date']!, _paymentDateMeta));
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      invoiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_id'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id'])!,
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      paymentMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_mode'])!,
      referenceNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reference_number'])!,
      paymentDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}payment_date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String invoiceId;
  final String customerId;
  final String customerName;
  final double amount;
  final String paymentMode;
  final String referenceNumber;
  final DateTime paymentDate;
  final String notes;
  final String syncStatus;
  const Payment(
      {required this.id,
      required this.invoiceId,
      required this.customerId,
      required this.customerName,
      required this.amount,
      required this.paymentMode,
      required this.referenceNumber,
      required this.paymentDate,
      required this.notes,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['customer_id'] = Variable<String>(customerId);
    map['customer_name'] = Variable<String>(customerName);
    map['amount'] = Variable<double>(amount);
    map['payment_mode'] = Variable<String>(paymentMode);
    map['reference_number'] = Variable<String>(referenceNumber);
    map['payment_date'] = Variable<DateTime>(paymentDate);
    map['notes'] = Variable<String>(notes);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      customerId: Value(customerId),
      customerName: Value(customerName),
      amount: Value(amount),
      paymentMode: Value(paymentMode),
      referenceNumber: Value(referenceNumber),
      paymentDate: Value(paymentDate),
      notes: Value(notes),
      syncStatus: Value(syncStatus),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      customerName: serializer.fromJson<String>(json['customerName']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentMode: serializer.fromJson<String>(json['paymentMode']),
      referenceNumber: serializer.fromJson<String>(json['referenceNumber']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      notes: serializer.fromJson<String>(json['notes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'customerId': serializer.toJson<String>(customerId),
      'customerName': serializer.toJson<String>(customerName),
      'amount': serializer.toJson<double>(amount),
      'paymentMode': serializer.toJson<String>(paymentMode),
      'referenceNumber': serializer.toJson<String>(referenceNumber),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'notes': serializer.toJson<String>(notes),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Payment copyWith(
          {String? id,
          String? invoiceId,
          String? customerId,
          String? customerName,
          double? amount,
          String? paymentMode,
          String? referenceNumber,
          DateTime? paymentDate,
          String? notes,
          String? syncStatus}) =>
      Payment(
        id: id ?? this.id,
        invoiceId: invoiceId ?? this.invoiceId,
        customerId: customerId ?? this.customerId,
        customerName: customerName ?? this.customerName,
        amount: amount ?? this.amount,
        paymentMode: paymentMode ?? this.paymentMode,
        referenceNumber: referenceNumber ?? this.referenceNumber,
        paymentDate: paymentDate ?? this.paymentDate,
        notes: notes ?? this.notes,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentMode:
          data.paymentMode.present ? data.paymentMode.value : this.paymentMode,
      referenceNumber: data.referenceNumber.present
          ? data.referenceNumber.value
          : this.referenceNumber,
      paymentDate:
          data.paymentDate.present ? data.paymentDate.value : this.paymentDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('amount: $amount, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, invoiceId, customerId, customerName,
      amount, paymentMode, referenceNumber, paymentDate, notes, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.customerId == this.customerId &&
          other.customerName == this.customerName &&
          other.amount == this.amount &&
          other.paymentMode == this.paymentMode &&
          other.referenceNumber == this.referenceNumber &&
          other.paymentDate == this.paymentDate &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<String> customerId;
  final Value<String> customerName;
  final Value<double> amount;
  final Value<String> paymentMode;
  final Value<String> referenceNumber;
  final Value<DateTime> paymentDate;
  final Value<String> notes;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String invoiceId,
    required String customerId,
    required String customerName,
    this.amount = const Value.absent(),
    required String paymentMode,
    this.referenceNumber = const Value.absent(),
    required DateTime paymentDate,
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        invoiceId = Value(invoiceId),
        customerId = Value(customerId),
        customerName = Value(customerName),
        paymentMode = Value(paymentMode),
        paymentDate = Value(paymentDate);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<String>? customerId,
    Expression<String>? customerName,
    Expression<double>? amount,
    Expression<String>? paymentMode,
    Expression<String>? referenceNumber,
    Expression<DateTime>? paymentDate,
    Expression<String>? notes,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (customerId != null) 'customer_id': customerId,
      if (customerName != null) 'customer_name': customerName,
      if (amount != null) 'amount': amount,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? invoiceId,
      Value<String>? customerId,
      Value<String>? customerName,
      Value<double>? amount,
      Value<String>? paymentMode,
      Value<String>? referenceNumber,
      Value<DateTime>? paymentDate,
      Value<String>? notes,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return PaymentsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(paymentMode.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('amount: $amount, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchasesTable extends Purchases
    with TableInfo<$PurchasesTable, Purchase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _poNumberMeta =
      const VerificationMeta('poNumber');
  @override
  late final GeneratedColumn<String> poNumber = GeneratedColumn<String>(
      'po_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _supplierIdMeta =
      const VerificationMeta('supplierId');
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
      'supplier_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _supplierNameMeta =
      const VerificationMeta('supplierName');
  @override
  late final GeneratedColumn<String> supplierName = GeneratedColumn<String>(
      'supplier_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderDateMeta =
      const VerificationMeta('orderDate');
  @override
  late final GeneratedColumn<DateTime> orderDate = GeneratedColumn<DateTime>(
      'order_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        poNumber,
        supplierId,
        supplierName,
        totalAmount,
        status,
        orderDate,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchases';
  @override
  VerificationContext validateIntegrity(Insertable<Purchase> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('po_number')) {
      context.handle(_poNumberMeta,
          poNumber.isAcceptableOrUnknown(data['po_number']!, _poNumberMeta));
    } else if (isInserting) {
      context.missing(_poNumberMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
          _supplierIdMeta,
          supplierId.isAcceptableOrUnknown(
              data['supplier_id']!, _supplierIdMeta));
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('supplier_name')) {
      context.handle(
          _supplierNameMeta,
          supplierName.isAcceptableOrUnknown(
              data['supplier_name']!, _supplierNameMeta));
    } else if (isInserting) {
      context.missing(_supplierNameMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('order_date')) {
      context.handle(_orderDateMeta,
          orderDate.isAcceptableOrUnknown(data['order_date']!, _orderDateMeta));
    } else if (isInserting) {
      context.missing(_orderDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Purchase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Purchase(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      poNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}po_number'])!,
      supplierId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier_id'])!,
      supplierName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier_name'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      orderDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}order_date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
    );
  }

  @override
  $PurchasesTable createAlias(String alias) {
    return $PurchasesTable(attachedDatabase, alias);
  }
}

class Purchase extends DataClass implements Insertable<Purchase> {
  final String id;
  final String poNumber;
  final String supplierId;
  final String supplierName;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final String notes;
  const Purchase(
      {required this.id,
      required this.poNumber,
      required this.supplierId,
      required this.supplierName,
      required this.totalAmount,
      required this.status,
      required this.orderDate,
      required this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['po_number'] = Variable<String>(poNumber);
    map['supplier_id'] = Variable<String>(supplierId);
    map['supplier_name'] = Variable<String>(supplierName);
    map['total_amount'] = Variable<double>(totalAmount);
    map['status'] = Variable<String>(status);
    map['order_date'] = Variable<DateTime>(orderDate);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  PurchasesCompanion toCompanion(bool nullToAbsent) {
    return PurchasesCompanion(
      id: Value(id),
      poNumber: Value(poNumber),
      supplierId: Value(supplierId),
      supplierName: Value(supplierName),
      totalAmount: Value(totalAmount),
      status: Value(status),
      orderDate: Value(orderDate),
      notes: Value(notes),
    );
  }

  factory Purchase.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Purchase(
      id: serializer.fromJson<String>(json['id']),
      poNumber: serializer.fromJson<String>(json['poNumber']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      supplierName: serializer.fromJson<String>(json['supplierName']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      status: serializer.fromJson<String>(json['status']),
      orderDate: serializer.fromJson<DateTime>(json['orderDate']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'poNumber': serializer.toJson<String>(poNumber),
      'supplierId': serializer.toJson<String>(supplierId),
      'supplierName': serializer.toJson<String>(supplierName),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'status': serializer.toJson<String>(status),
      'orderDate': serializer.toJson<DateTime>(orderDate),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Purchase copyWith(
          {String? id,
          String? poNumber,
          String? supplierId,
          String? supplierName,
          double? totalAmount,
          String? status,
          DateTime? orderDate,
          String? notes}) =>
      Purchase(
        id: id ?? this.id,
        poNumber: poNumber ?? this.poNumber,
        supplierId: supplierId ?? this.supplierId,
        supplierName: supplierName ?? this.supplierName,
        totalAmount: totalAmount ?? this.totalAmount,
        status: status ?? this.status,
        orderDate: orderDate ?? this.orderDate,
        notes: notes ?? this.notes,
      );
  Purchase copyWithCompanion(PurchasesCompanion data) {
    return Purchase(
      id: data.id.present ? data.id.value : this.id,
      poNumber: data.poNumber.present ? data.poNumber.value : this.poNumber,
      supplierId:
          data.supplierId.present ? data.supplierId.value : this.supplierId,
      supplierName: data.supplierName.present
          ? data.supplierName.value
          : this.supplierName,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      status: data.status.present ? data.status.value : this.status,
      orderDate: data.orderDate.present ? data.orderDate.value : this.orderDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Purchase(')
          ..write('id: $id, ')
          ..write('poNumber: $poNumber, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplierName: $supplierName, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('status: $status, ')
          ..write('orderDate: $orderDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, poNumber, supplierId, supplierName,
      totalAmount, status, orderDate, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Purchase &&
          other.id == this.id &&
          other.poNumber == this.poNumber &&
          other.supplierId == this.supplierId &&
          other.supplierName == this.supplierName &&
          other.totalAmount == this.totalAmount &&
          other.status == this.status &&
          other.orderDate == this.orderDate &&
          other.notes == this.notes);
}

class PurchasesCompanion extends UpdateCompanion<Purchase> {
  final Value<String> id;
  final Value<String> poNumber;
  final Value<String> supplierId;
  final Value<String> supplierName;
  final Value<double> totalAmount;
  final Value<String> status;
  final Value<DateTime> orderDate;
  final Value<String> notes;
  final Value<int> rowid;
  const PurchasesCompanion({
    this.id = const Value.absent(),
    this.poNumber = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.supplierName = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.orderDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchasesCompanion.insert({
    required String id,
    required String poNumber,
    required String supplierId,
    required String supplierName,
    this.totalAmount = const Value.absent(),
    required String status,
    required DateTime orderDate,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        poNumber = Value(poNumber),
        supplierId = Value(supplierId),
        supplierName = Value(supplierName),
        status = Value(status),
        orderDate = Value(orderDate);
  static Insertable<Purchase> custom({
    Expression<String>? id,
    Expression<String>? poNumber,
    Expression<String>? supplierId,
    Expression<String>? supplierName,
    Expression<double>? totalAmount,
    Expression<String>? status,
    Expression<DateTime>? orderDate,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (poNumber != null) 'po_number': poNumber,
      if (supplierId != null) 'supplier_id': supplierId,
      if (supplierName != null) 'supplier_name': supplierName,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (status != null) 'status': status,
      if (orderDate != null) 'order_date': orderDate,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchasesCompanion copyWith(
      {Value<String>? id,
      Value<String>? poNumber,
      Value<String>? supplierId,
      Value<String>? supplierName,
      Value<double>? totalAmount,
      Value<String>? status,
      Value<DateTime>? orderDate,
      Value<String>? notes,
      Value<int>? rowid}) {
    return PurchasesCompanion(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (poNumber.present) {
      map['po_number'] = Variable<String>(poNumber.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (supplierName.present) {
      map['supplier_name'] = Variable<String>(supplierName.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (orderDate.present) {
      map['order_date'] = Variable<DateTime>(orderDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchasesCompanion(')
          ..write('id: $id, ')
          ..write('poNumber: $poNumber, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplierName: $supplierName, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('status: $status, ')
          ..write('orderDate: $orderDate, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, Supplier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _companyNameMeta =
      const VerificationMeta('companyName');
  @override
  late final GeneratedColumn<String> companyName = GeneratedColumn<String>(
      'company_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payableBalanceMeta =
      const VerificationMeta('payableBalance');
  @override
  late final GeneratedColumn<double> payableBalance = GeneratedColumn<double>(
      'payable_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, companyName, phone, email, address, payableBalance, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(Insertable<Supplier> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('company_name')) {
      context.handle(
          _companyNameMeta,
          companyName.isAcceptableOrUnknown(
              data['company_name']!, _companyNameMeta));
    } else if (isInserting) {
      context.missing(_companyNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('payable_balance')) {
      context.handle(
          _payableBalanceMeta,
          payableBalance.isAcceptableOrUnknown(
              data['payable_balance']!, _payableBalanceMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Supplier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supplier(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      companyName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}company_name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      payableBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}payable_balance'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }
}

class Supplier extends DataClass implements Insertable<Supplier> {
  final String id;
  final String name;
  final String companyName;
  final String phone;
  final String email;
  final String address;
  final double payableBalance;
  final DateTime createdAt;
  const Supplier(
      {required this.id,
      required this.name,
      required this.companyName,
      required this.phone,
      required this.email,
      required this.address,
      required this.payableBalance,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['company_name'] = Variable<String>(companyName);
    map['phone'] = Variable<String>(phone);
    map['email'] = Variable<String>(email);
    map['address'] = Variable<String>(address);
    map['payable_balance'] = Variable<double>(payableBalance);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      name: Value(name),
      companyName: Value(companyName),
      phone: Value(phone),
      email: Value(email),
      address: Value(address),
      payableBalance: Value(payableBalance),
      createdAt: Value(createdAt),
    );
  }

  factory Supplier.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supplier(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      companyName: serializer.fromJson<String>(json['companyName']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String>(json['email']),
      address: serializer.fromJson<String>(json['address']),
      payableBalance: serializer.fromJson<double>(json['payableBalance']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'companyName': serializer.toJson<String>(companyName),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String>(email),
      'address': serializer.toJson<String>(address),
      'payableBalance': serializer.toJson<double>(payableBalance),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Supplier copyWith(
          {String? id,
          String? name,
          String? companyName,
          String? phone,
          String? email,
          String? address,
          double? payableBalance,
          DateTime? createdAt}) =>
      Supplier(
        id: id ?? this.id,
        name: name ?? this.name,
        companyName: companyName ?? this.companyName,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        payableBalance: payableBalance ?? this.payableBalance,
        createdAt: createdAt ?? this.createdAt,
      );
  Supplier copyWithCompanion(SuppliersCompanion data) {
    return Supplier(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      companyName:
          data.companyName.present ? data.companyName.value : this.companyName,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      payableBalance: data.payableBalance.present
          ? data.payableBalance.value
          : this.payableBalance,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supplier(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('companyName: $companyName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('payableBalance: $payableBalance, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, companyName, phone, email, address, payableBalance, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supplier &&
          other.id == this.id &&
          other.name == this.name &&
          other.companyName == this.companyName &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.payableBalance == this.payableBalance &&
          other.createdAt == this.createdAt);
}

class SuppliersCompanion extends UpdateCompanion<Supplier> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> companyName;
  final Value<String> phone;
  final Value<String> email;
  final Value<String> address;
  final Value<double> payableBalance;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.companyName = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.payableBalance = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliersCompanion.insert({
    required String id,
    required String name,
    required String companyName,
    required String phone,
    required String email,
    required String address,
    this.payableBalance = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        companyName = Value(companyName),
        phone = Value(phone),
        email = Value(email),
        address = Value(address),
        createdAt = Value(createdAt);
  static Insertable<Supplier> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? companyName,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<double>? payableBalance,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (companyName != null) 'company_name': companyName,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (payableBalance != null) 'payable_balance': payableBalance,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? companyName,
      Value<String>? phone,
      Value<String>? email,
      Value<String>? address,
      Value<double>? payableBalance,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SuppliersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      payableBalance: payableBalance ?? this.payableBalance,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (companyName.present) {
      map['company_name'] = Variable<String>(companyName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (payableBalance.present) {
      map['payable_balance'] = Variable<double>(payableBalance.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('companyName: $companyName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('payableBalance: $payableBalance, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _paymentModeMeta =
      const VerificationMeta('paymentMode');
  @override
  late final GeneratedColumn<String> paymentMode = GeneratedColumn<String>(
      'payment_mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _expenseDateMeta =
      const VerificationMeta('expenseDate');
  @override
  late final GeneratedColumn<DateTime> expenseDate = GeneratedColumn<DateTime>(
      'expense_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, category, amount, paymentMode, expenseDate, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(Insertable<Expense> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    }
    if (data.containsKey('payment_mode')) {
      context.handle(
          _paymentModeMeta,
          paymentMode.isAcceptableOrUnknown(
              data['payment_mode']!, _paymentModeMeta));
    } else if (isInserting) {
      context.missing(_paymentModeMeta);
    }
    if (data.containsKey('expense_date')) {
      context.handle(
          _expenseDateMeta,
          expenseDate.isAcceptableOrUnknown(
              data['expense_date']!, _expenseDateMeta));
    } else if (isInserting) {
      context.missing(_expenseDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      paymentMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_mode'])!,
      expenseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expense_date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final String id;
  final String title;
  final String category;
  final double amount;
  final String paymentMode;
  final DateTime expenseDate;
  final String notes;
  const Expense(
      {required this.id,
      required this.title,
      required this.category,
      required this.amount,
      required this.paymentMode,
      required this.expenseDate,
      required this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<double>(amount);
    map['payment_mode'] = Variable<String>(paymentMode);
    map['expense_date'] = Variable<DateTime>(expenseDate);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      title: Value(title),
      category: Value(category),
      amount: Value(amount),
      paymentMode: Value(paymentMode),
      expenseDate: Value(expenseDate),
      notes: Value(notes),
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentMode: serializer.fromJson<String>(json['paymentMode']),
      expenseDate: serializer.fromJson<DateTime>(json['expenseDate']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<double>(amount),
      'paymentMode': serializer.toJson<String>(paymentMode),
      'expenseDate': serializer.toJson<DateTime>(expenseDate),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Expense copyWith(
          {String? id,
          String? title,
          String? category,
          double? amount,
          String? paymentMode,
          DateTime? expenseDate,
          String? notes}) =>
      Expense(
        id: id ?? this.id,
        title: title ?? this.title,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        paymentMode: paymentMode ?? this.paymentMode,
        expenseDate: expenseDate ?? this.expenseDate,
        notes: notes ?? this.notes,
      );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentMode:
          data.paymentMode.present ? data.paymentMode.value : this.paymentMode,
      expenseDate:
          data.expenseDate.present ? data.expenseDate.value : this.expenseDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, category, amount, paymentMode, expenseDate, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.title == this.title &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.paymentMode == this.paymentMode &&
          other.expenseDate == this.expenseDate &&
          other.notes == this.notes);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> category;
  final Value<double> amount;
  final Value<String> paymentMode;
  final Value<DateTime> expenseDate;
  final Value<String> notes;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.expenseDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String title,
    required String category,
    this.amount = const Value.absent(),
    required String paymentMode,
    required DateTime expenseDate,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        category = Value(category),
        paymentMode = Value(paymentMode),
        expenseDate = Value(expenseDate);
  static Insertable<Expense> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? category,
    Expression<double>? amount,
    Expression<String>? paymentMode,
    Expression<DateTime>? expenseDate,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? category,
      Value<double>? amount,
      Value<String>? paymentMode,
      Value<DateTime>? expenseDate,
      Value<String>? notes,
      Value<int>? rowid}) {
    return ExpensesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      expenseDate: expenseDate ?? this.expenseDate,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(paymentMode.value);
    }
    if (expenseDate.present) {
      map['expense_date'] = Variable<DateTime>(expenseDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncomeTable extends Income with TableInfo<$IncomeTable, IncomeData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomeTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _paymentModeMeta =
      const VerificationMeta('paymentMode');
  @override
  late final GeneratedColumn<String> paymentMode = GeneratedColumn<String>(
      'payment_mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _incomeDateMeta =
      const VerificationMeta('incomeDate');
  @override
  late final GeneratedColumn<DateTime> incomeDate = GeneratedColumn<DateTime>(
      'income_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, category, amount, paymentMode, incomeDate, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'income';
  @override
  VerificationContext validateIntegrity(Insertable<IncomeData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    }
    if (data.containsKey('payment_mode')) {
      context.handle(
          _paymentModeMeta,
          paymentMode.isAcceptableOrUnknown(
              data['payment_mode']!, _paymentModeMeta));
    } else if (isInserting) {
      context.missing(_paymentModeMeta);
    }
    if (data.containsKey('income_date')) {
      context.handle(
          _incomeDateMeta,
          incomeDate.isAcceptableOrUnknown(
              data['income_date']!, _incomeDateMeta));
    } else if (isInserting) {
      context.missing(_incomeDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IncomeData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncomeData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      paymentMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_mode'])!,
      incomeDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}income_date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
    );
  }

  @override
  $IncomeTable createAlias(String alias) {
    return $IncomeTable(attachedDatabase, alias);
  }
}

class IncomeData extends DataClass implements Insertable<IncomeData> {
  final String id;
  final String title;
  final String category;
  final double amount;
  final String paymentMode;
  final DateTime incomeDate;
  final String notes;
  const IncomeData(
      {required this.id,
      required this.title,
      required this.category,
      required this.amount,
      required this.paymentMode,
      required this.incomeDate,
      required this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<double>(amount);
    map['payment_mode'] = Variable<String>(paymentMode);
    map['income_date'] = Variable<DateTime>(incomeDate);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  IncomeCompanion toCompanion(bool nullToAbsent) {
    return IncomeCompanion(
      id: Value(id),
      title: Value(title),
      category: Value(category),
      amount: Value(amount),
      paymentMode: Value(paymentMode),
      incomeDate: Value(incomeDate),
      notes: Value(notes),
    );
  }

  factory IncomeData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncomeData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentMode: serializer.fromJson<String>(json['paymentMode']),
      incomeDate: serializer.fromJson<DateTime>(json['incomeDate']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<double>(amount),
      'paymentMode': serializer.toJson<String>(paymentMode),
      'incomeDate': serializer.toJson<DateTime>(incomeDate),
      'notes': serializer.toJson<String>(notes),
    };
  }

  IncomeData copyWith(
          {String? id,
          String? title,
          String? category,
          double? amount,
          String? paymentMode,
          DateTime? incomeDate,
          String? notes}) =>
      IncomeData(
        id: id ?? this.id,
        title: title ?? this.title,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        paymentMode: paymentMode ?? this.paymentMode,
        incomeDate: incomeDate ?? this.incomeDate,
        notes: notes ?? this.notes,
      );
  IncomeData copyWithCompanion(IncomeCompanion data) {
    return IncomeData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentMode:
          data.paymentMode.present ? data.paymentMode.value : this.paymentMode,
      incomeDate:
          data.incomeDate.present ? data.incomeDate.value : this.incomeDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncomeData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('incomeDate: $incomeDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, category, amount, paymentMode, incomeDate, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncomeData &&
          other.id == this.id &&
          other.title == this.title &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.paymentMode == this.paymentMode &&
          other.incomeDate == this.incomeDate &&
          other.notes == this.notes);
}

class IncomeCompanion extends UpdateCompanion<IncomeData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> category;
  final Value<double> amount;
  final Value<String> paymentMode;
  final Value<DateTime> incomeDate;
  final Value<String> notes;
  final Value<int> rowid;
  const IncomeCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.incomeDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncomeCompanion.insert({
    required String id,
    required String title,
    required String category,
    this.amount = const Value.absent(),
    required String paymentMode,
    required DateTime incomeDate,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        category = Value(category),
        paymentMode = Value(paymentMode),
        incomeDate = Value(incomeDate);
  static Insertable<IncomeData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? category,
    Expression<double>? amount,
    Expression<String>? paymentMode,
    Expression<DateTime>? incomeDate,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (incomeDate != null) 'income_date': incomeDate,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncomeCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? category,
      Value<double>? amount,
      Value<String>? paymentMode,
      Value<DateTime>? incomeDate,
      Value<String>? notes,
      Value<int>? rowid}) {
    return IncomeCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      incomeDate: incomeDate ?? this.incomeDate,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(paymentMode.value);
    }
    if (incomeDate.present) {
      map['income_date'] = Variable<DateTime>(incomeDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomeCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('incomeDate: $incomeDate, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, type, isActive, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final String type;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const Category(
      {required this.id,
      required this.name,
      required this.type,
      required this.isActive,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Category copyWith(
          {String? id,
          String? name,
          String? type,
          bool? isActive,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, type, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        type = Value(type),
        createdAt = Value(createdAt);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? type,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceReturnsTable extends InvoiceReturns
    with TableInfo<$InvoiceReturnsTable, InvoiceReturn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceReturnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _returnNumberMeta =
      const VerificationMeta('returnNumber');
  @override
  late final GeneratedColumn<String> returnNumber = GeneratedColumn<String>(
      'return_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceIdMeta =
      const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
      'invoice_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceNumberMeta =
      const VerificationMeta('invoiceNumber');
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
      'invoice_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _partyIdMeta =
      const VerificationMeta('partyId');
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
      'party_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _partyNameMeta =
      const VerificationMeta('partyName');
  @override
  late final GeneratedColumn<String> partyName = GeneratedColumn<String>(
      'party_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _returnDateMeta =
      const VerificationMeta('returnDate');
  @override
  late final GeneratedColumn<DateTime> returnDate = GeneratedColumn<DateTime>(
      'return_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        returnNumber,
        invoiceId,
        invoiceNumber,
        partyId,
        partyName,
        type,
        totalAmount,
        returnDate,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_returns';
  @override
  VerificationContext validateIntegrity(Insertable<InvoiceReturn> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('return_number')) {
      context.handle(
          _returnNumberMeta,
          returnNumber.isAcceptableOrUnknown(
              data['return_number']!, _returnNumberMeta));
    } else if (isInserting) {
      context.missing(_returnNumberMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta,
          invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
          _invoiceNumberMeta,
          invoiceNumber.isAcceptableOrUnknown(
              data['invoice_number']!, _invoiceNumberMeta));
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(_partyIdMeta,
          partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta));
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('party_name')) {
      context.handle(_partyNameMeta,
          partyName.isAcceptableOrUnknown(data['party_name']!, _partyNameMeta));
    } else if (isInserting) {
      context.missing(_partyNameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    }
    if (data.containsKey('return_date')) {
      context.handle(
          _returnDateMeta,
          returnDate.isAcceptableOrUnknown(
              data['return_date']!, _returnDateMeta));
    } else if (isInserting) {
      context.missing(_returnDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceReturn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceReturn(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      returnNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}return_number'])!,
      invoiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_id'])!,
      invoiceNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_number'])!,
      partyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}party_id'])!,
      partyName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}party_name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      returnDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}return_date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
    );
  }

  @override
  $InvoiceReturnsTable createAlias(String alias) {
    return $InvoiceReturnsTable(attachedDatabase, alias);
  }
}

class InvoiceReturn extends DataClass implements Insertable<InvoiceReturn> {
  final String id;
  final String returnNumber;
  final String invoiceId;
  final String invoiceNumber;
  final String partyId;
  final String partyName;
  final String type;
  final double totalAmount;
  final DateTime returnDate;
  final String notes;
  const InvoiceReturn(
      {required this.id,
      required this.returnNumber,
      required this.invoiceId,
      required this.invoiceNumber,
      required this.partyId,
      required this.partyName,
      required this.type,
      required this.totalAmount,
      required this.returnDate,
      required this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['return_number'] = Variable<String>(returnNumber);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    map['party_id'] = Variable<String>(partyId);
    map['party_name'] = Variable<String>(partyName);
    map['type'] = Variable<String>(type);
    map['total_amount'] = Variable<double>(totalAmount);
    map['return_date'] = Variable<DateTime>(returnDate);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  InvoiceReturnsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceReturnsCompanion(
      id: Value(id),
      returnNumber: Value(returnNumber),
      invoiceId: Value(invoiceId),
      invoiceNumber: Value(invoiceNumber),
      partyId: Value(partyId),
      partyName: Value(partyName),
      type: Value(type),
      totalAmount: Value(totalAmount),
      returnDate: Value(returnDate),
      notes: Value(notes),
    );
  }

  factory InvoiceReturn.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceReturn(
      id: serializer.fromJson<String>(json['id']),
      returnNumber: serializer.fromJson<String>(json['returnNumber']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      partyId: serializer.fromJson<String>(json['partyId']),
      partyName: serializer.fromJson<String>(json['partyName']),
      type: serializer.fromJson<String>(json['type']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      returnDate: serializer.fromJson<DateTime>(json['returnDate']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'returnNumber': serializer.toJson<String>(returnNumber),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'partyId': serializer.toJson<String>(partyId),
      'partyName': serializer.toJson<String>(partyName),
      'type': serializer.toJson<String>(type),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'returnDate': serializer.toJson<DateTime>(returnDate),
      'notes': serializer.toJson<String>(notes),
    };
  }

  InvoiceReturn copyWith(
          {String? id,
          String? returnNumber,
          String? invoiceId,
          String? invoiceNumber,
          String? partyId,
          String? partyName,
          String? type,
          double? totalAmount,
          DateTime? returnDate,
          String? notes}) =>
      InvoiceReturn(
        id: id ?? this.id,
        returnNumber: returnNumber ?? this.returnNumber,
        invoiceId: invoiceId ?? this.invoiceId,
        invoiceNumber: invoiceNumber ?? this.invoiceNumber,
        partyId: partyId ?? this.partyId,
        partyName: partyName ?? this.partyName,
        type: type ?? this.type,
        totalAmount: totalAmount ?? this.totalAmount,
        returnDate: returnDate ?? this.returnDate,
        notes: notes ?? this.notes,
      );
  InvoiceReturn copyWithCompanion(InvoiceReturnsCompanion data) {
    return InvoiceReturn(
      id: data.id.present ? data.id.value : this.id,
      returnNumber: data.returnNumber.present
          ? data.returnNumber.value
          : this.returnNumber,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      partyName: data.partyName.present ? data.partyName.value : this.partyName,
      type: data.type.present ? data.type.value : this.type,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      returnDate:
          data.returnDate.present ? data.returnDate.value : this.returnDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceReturn(')
          ..write('id: $id, ')
          ..write('returnNumber: $returnNumber, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('partyId: $partyId, ')
          ..write('partyName: $partyName, ')
          ..write('type: $type, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('returnDate: $returnDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, returnNumber, invoiceId, invoiceNumber,
      partyId, partyName, type, totalAmount, returnDate, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceReturn &&
          other.id == this.id &&
          other.returnNumber == this.returnNumber &&
          other.invoiceId == this.invoiceId &&
          other.invoiceNumber == this.invoiceNumber &&
          other.partyId == this.partyId &&
          other.partyName == this.partyName &&
          other.type == this.type &&
          other.totalAmount == this.totalAmount &&
          other.returnDate == this.returnDate &&
          other.notes == this.notes);
}

class InvoiceReturnsCompanion extends UpdateCompanion<InvoiceReturn> {
  final Value<String> id;
  final Value<String> returnNumber;
  final Value<String> invoiceId;
  final Value<String> invoiceNumber;
  final Value<String> partyId;
  final Value<String> partyName;
  final Value<String> type;
  final Value<double> totalAmount;
  final Value<DateTime> returnDate;
  final Value<String> notes;
  final Value<int> rowid;
  const InvoiceReturnsCompanion({
    this.id = const Value.absent(),
    this.returnNumber = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.partyId = const Value.absent(),
    this.partyName = const Value.absent(),
    this.type = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.returnDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoiceReturnsCompanion.insert({
    required String id,
    required String returnNumber,
    required String invoiceId,
    required String invoiceNumber,
    required String partyId,
    required String partyName,
    required String type,
    this.totalAmount = const Value.absent(),
    required DateTime returnDate,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        returnNumber = Value(returnNumber),
        invoiceId = Value(invoiceId),
        invoiceNumber = Value(invoiceNumber),
        partyId = Value(partyId),
        partyName = Value(partyName),
        type = Value(type),
        returnDate = Value(returnDate);
  static Insertable<InvoiceReturn> custom({
    Expression<String>? id,
    Expression<String>? returnNumber,
    Expression<String>? invoiceId,
    Expression<String>? invoiceNumber,
    Expression<String>? partyId,
    Expression<String>? partyName,
    Expression<String>? type,
    Expression<double>? totalAmount,
    Expression<DateTime>? returnDate,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (returnNumber != null) 'return_number': returnNumber,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (partyId != null) 'party_id': partyId,
      if (partyName != null) 'party_name': partyName,
      if (type != null) 'type': type,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (returnDate != null) 'return_date': returnDate,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoiceReturnsCompanion copyWith(
      {Value<String>? id,
      Value<String>? returnNumber,
      Value<String>? invoiceId,
      Value<String>? invoiceNumber,
      Value<String>? partyId,
      Value<String>? partyName,
      Value<String>? type,
      Value<double>? totalAmount,
      Value<DateTime>? returnDate,
      Value<String>? notes,
      Value<int>? rowid}) {
    return InvoiceReturnsCompanion(
      id: id ?? this.id,
      returnNumber: returnNumber ?? this.returnNumber,
      invoiceId: invoiceId ?? this.invoiceId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      partyId: partyId ?? this.partyId,
      partyName: partyName ?? this.partyName,
      type: type ?? this.type,
      totalAmount: totalAmount ?? this.totalAmount,
      returnDate: returnDate ?? this.returnDate,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (returnNumber.present) {
      map['return_number'] = Variable<String>(returnNumber.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (partyName.present) {
      map['party_name'] = Variable<String>(partyName.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (returnDate.present) {
      map['return_date'] = Variable<DateTime>(returnDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceReturnsCompanion(')
          ..write('id: $id, ')
          ..write('returnNumber: $returnNumber, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('partyId: $partyId, ')
          ..write('partyName: $partyName, ')
          ..write('type: $type, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('returnDate: $returnDate, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceReturnItemsTable extends InvoiceReturnItems
    with TableInfo<$InvoiceReturnItemsTable, InvoiceReturnItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceReturnItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _returnIdMeta =
      const VerificationMeta('returnId');
  @override
  late final GeneratedColumn<String> returnId = GeneratedColumn<String>(
      'return_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _originalQuantityMeta =
      const VerificationMeta('originalQuantity');
  @override
  late final GeneratedColumn<int> originalQuantity = GeneratedColumn<int>(
      'original_quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _returnedQuantityMeta =
      const VerificationMeta('returnedQuantity');
  @override
  late final GeneratedColumn<int> returnedQuantity = GeneratedColumn<int>(
      'returned_quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        returnId,
        productId,
        productName,
        sku,
        originalQuantity,
        returnedQuantity,
        unitPrice
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_return_items';
  @override
  VerificationContext validateIntegrity(Insertable<InvoiceReturnItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('return_id')) {
      context.handle(_returnIdMeta,
          returnId.isAcceptableOrUnknown(data['return_id']!, _returnIdMeta));
    } else if (isInserting) {
      context.missing(_returnIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    }
    if (data.containsKey('original_quantity')) {
      context.handle(
          _originalQuantityMeta,
          originalQuantity.isAcceptableOrUnknown(
              data['original_quantity']!, _originalQuantityMeta));
    }
    if (data.containsKey('returned_quantity')) {
      context.handle(
          _returnedQuantityMeta,
          returnedQuantity.isAcceptableOrUnknown(
              data['returned_quantity']!, _returnedQuantityMeta));
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceReturnItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceReturnItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      returnId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}return_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      originalQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}original_quantity'])!,
      returnedQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}returned_quantity'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
    );
  }

  @override
  $InvoiceReturnItemsTable createAlias(String alias) {
    return $InvoiceReturnItemsTable(attachedDatabase, alias);
  }
}

class InvoiceReturnItem extends DataClass
    implements Insertable<InvoiceReturnItem> {
  final int id;
  final String returnId;
  final String productId;
  final String productName;
  final String sku;
  final int originalQuantity;
  final int returnedQuantity;
  final double unitPrice;
  const InvoiceReturnItem(
      {required this.id,
      required this.returnId,
      required this.productId,
      required this.productName,
      required this.sku,
      required this.originalQuantity,
      required this.returnedQuantity,
      required this.unitPrice});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['return_id'] = Variable<String>(returnId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['sku'] = Variable<String>(sku);
    map['original_quantity'] = Variable<int>(originalQuantity);
    map['returned_quantity'] = Variable<int>(returnedQuantity);
    map['unit_price'] = Variable<double>(unitPrice);
    return map;
  }

  InvoiceReturnItemsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceReturnItemsCompanion(
      id: Value(id),
      returnId: Value(returnId),
      productId: Value(productId),
      productName: Value(productName),
      sku: Value(sku),
      originalQuantity: Value(originalQuantity),
      returnedQuantity: Value(returnedQuantity),
      unitPrice: Value(unitPrice),
    );
  }

  factory InvoiceReturnItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceReturnItem(
      id: serializer.fromJson<int>(json['id']),
      returnId: serializer.fromJson<String>(json['returnId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      sku: serializer.fromJson<String>(json['sku']),
      originalQuantity: serializer.fromJson<int>(json['originalQuantity']),
      returnedQuantity: serializer.fromJson<int>(json['returnedQuantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'returnId': serializer.toJson<String>(returnId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'sku': serializer.toJson<String>(sku),
      'originalQuantity': serializer.toJson<int>(originalQuantity),
      'returnedQuantity': serializer.toJson<int>(returnedQuantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
    };
  }

  InvoiceReturnItem copyWith(
          {int? id,
          String? returnId,
          String? productId,
          String? productName,
          String? sku,
          int? originalQuantity,
          int? returnedQuantity,
          double? unitPrice}) =>
      InvoiceReturnItem(
        id: id ?? this.id,
        returnId: returnId ?? this.returnId,
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        sku: sku ?? this.sku,
        originalQuantity: originalQuantity ?? this.originalQuantity,
        returnedQuantity: returnedQuantity ?? this.returnedQuantity,
        unitPrice: unitPrice ?? this.unitPrice,
      );
  InvoiceReturnItem copyWithCompanion(InvoiceReturnItemsCompanion data) {
    return InvoiceReturnItem(
      id: data.id.present ? data.id.value : this.id,
      returnId: data.returnId.present ? data.returnId.value : this.returnId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      sku: data.sku.present ? data.sku.value : this.sku,
      originalQuantity: data.originalQuantity.present
          ? data.originalQuantity.value
          : this.originalQuantity,
      returnedQuantity: data.returnedQuantity.present
          ? data.returnedQuantity.value
          : this.returnedQuantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceReturnItem(')
          ..write('id: $id, ')
          ..write('returnId: $returnId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('sku: $sku, ')
          ..write('originalQuantity: $originalQuantity, ')
          ..write('returnedQuantity: $returnedQuantity, ')
          ..write('unitPrice: $unitPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, returnId, productId, productName, sku,
      originalQuantity, returnedQuantity, unitPrice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceReturnItem &&
          other.id == this.id &&
          other.returnId == this.returnId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.sku == this.sku &&
          other.originalQuantity == this.originalQuantity &&
          other.returnedQuantity == this.returnedQuantity &&
          other.unitPrice == this.unitPrice);
}

class InvoiceReturnItemsCompanion extends UpdateCompanion<InvoiceReturnItem> {
  final Value<int> id;
  final Value<String> returnId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<String> sku;
  final Value<int> originalQuantity;
  final Value<int> returnedQuantity;
  final Value<double> unitPrice;
  const InvoiceReturnItemsCompanion({
    this.id = const Value.absent(),
    this.returnId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.sku = const Value.absent(),
    this.originalQuantity = const Value.absent(),
    this.returnedQuantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
  });
  InvoiceReturnItemsCompanion.insert({
    this.id = const Value.absent(),
    required String returnId,
    required String productId,
    required String productName,
    this.sku = const Value.absent(),
    this.originalQuantity = const Value.absent(),
    this.returnedQuantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
  })  : returnId = Value(returnId),
        productId = Value(productId),
        productName = Value(productName);
  static Insertable<InvoiceReturnItem> custom({
    Expression<int>? id,
    Expression<String>? returnId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<String>? sku,
    Expression<int>? originalQuantity,
    Expression<int>? returnedQuantity,
    Expression<double>? unitPrice,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (returnId != null) 'return_id': returnId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (sku != null) 'sku': sku,
      if (originalQuantity != null) 'original_quantity': originalQuantity,
      if (returnedQuantity != null) 'returned_quantity': returnedQuantity,
      if (unitPrice != null) 'unit_price': unitPrice,
    });
  }

  InvoiceReturnItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? returnId,
      Value<String>? productId,
      Value<String>? productName,
      Value<String>? sku,
      Value<int>? originalQuantity,
      Value<int>? returnedQuantity,
      Value<double>? unitPrice}) {
    return InvoiceReturnItemsCompanion(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      originalQuantity: originalQuantity ?? this.originalQuantity,
      returnedQuantity: returnedQuantity ?? this.returnedQuantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (returnId.present) {
      map['return_id'] = Variable<String>(returnId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (originalQuantity.present) {
      map['original_quantity'] = Variable<int>(originalQuantity.value);
    }
    if (returnedQuantity.present) {
      map['returned_quantity'] = Variable<int>(returnedQuantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceReturnItemsCompanion(')
          ..write('id: $id, ')
          ..write('returnId: $returnId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('sku: $sku, ')
          ..write('originalQuantity: $originalQuantity, ')
          ..write('returnedQuantity: $returnedQuantity, ')
          ..write('unitPrice: $unitPrice')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PENDING'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, entityType, action, payload, createdAt, retryCount, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final String id;
  final String entityType;
  final String action;
  final String payload;
  final DateTime createdAt;
  final int retryCount;
  final String status;
  const SyncQueueData(
      {required this.id,
      required this.entityType,
      required this.action,
      required this.payload,
      required this.createdAt,
      required this.retryCount,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    map['status'] = Variable<String>(status);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      action: Value(action),
      payload: Value(payload),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      status: Value(status),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'status': serializer.toJson<String>(status),
    };
  }

  SyncQueueData copyWith(
          {String? id,
          String? entityType,
          String? action,
          String? payload,
          DateTime? createdAt,
          int? retryCount,
          String? status}) =>
      SyncQueueData(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        action: action ?? this.action,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
        status: status ?? this.status,
      );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, entityType, action, payload, createdAt, retryCount, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.status == this.status);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> action;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String> status;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String id,
    required String entityType,
    required String action,
    required String payload,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        action = Value(action),
        payload = Value(payload),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String>? action,
      Value<String>? payload,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<String>? status,
      Value<int>? rowid}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppKeyValueStoreTable extends AppKeyValueStore
    with TableInfo<$AppKeyValueStoreTable, AppKeyValueStoreData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppKeyValueStoreTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_key_value_store';
  @override
  VerificationContext validateIntegrity(
      Insertable<AppKeyValueStoreData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppKeyValueStoreData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppKeyValueStoreData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppKeyValueStoreTable createAlias(String alias) {
    return $AppKeyValueStoreTable(attachedDatabase, alias);
  }
}

class AppKeyValueStoreData extends DataClass
    implements Insertable<AppKeyValueStoreData> {
  final String key;
  final String value;
  const AppKeyValueStoreData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppKeyValueStoreCompanion toCompanion(bool nullToAbsent) {
    return AppKeyValueStoreCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppKeyValueStoreData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppKeyValueStoreData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppKeyValueStoreData copyWith({String? key, String? value}) =>
      AppKeyValueStoreData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppKeyValueStoreData copyWithCompanion(AppKeyValueStoreCompanion data) {
    return AppKeyValueStoreData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppKeyValueStoreData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppKeyValueStoreData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppKeyValueStoreCompanion extends UpdateCompanion<AppKeyValueStoreData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppKeyValueStoreCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppKeyValueStoreCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppKeyValueStoreData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppKeyValueStoreCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppKeyValueStoreCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppKeyValueStoreCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $InvoiceItemsTable invoiceItems = $InvoiceItemsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $PurchasesTable purchases = $PurchasesTable(this);
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $IncomeTable income = $IncomeTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $InvoiceReturnsTable invoiceReturns = $InvoiceReturnsTable(this);
  late final $InvoiceReturnItemsTable invoiceReturnItems =
      $InvoiceReturnItemsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $AppKeyValueStoreTable appKeyValueStore =
      $AppKeyValueStoreTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        customers,
        products,
        stockMovements,
        invoices,
        invoiceItems,
        payments,
        purchases,
        suppliers,
        expenses,
        income,
        categories,
        invoiceReturns,
        invoiceReturnItems,
        syncQueue,
        appKeyValueStore
      ];
}

typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  required String id,
  required String name,
  required String phone,
  required String email,
  required String address,
  Value<String?> state,
  Value<double> outstandingBalance,
  Value<double> totalPurchases,
  required DateTime createdAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> phone,
  Value<String> email,
  Value<String> address,
  Value<String?> state,
  Value<double> outstandingBalance,
  Value<double> totalPurchases,
  Value<DateTime> createdAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get outstandingBalance => $composableBuilder(
      column: $table.outstandingBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalPurchases => $composableBuilder(
      column: $table.totalPurchases,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get outstandingBalance => $composableBuilder(
      column: $table.outstandingBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalPurchases => $composableBuilder(
      column: $table.totalPurchases,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<double> get outstandingBalance => $composableBuilder(
      column: $table.outstandingBalance, builder: (column) => column);

  GeneratedColumn<double> get totalPurchases => $composableBuilder(
      column: $table.totalPurchases, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$CustomersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
    Customer,
    PrefetchHooks Function()> {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String?> state = const Value.absent(),
            Value<double> outstandingBalance = const Value.absent(),
            Value<double> totalPurchases = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomersCompanion(
            id: id,
            name: name,
            phone: phone,
            email: email,
            address: address,
            state: state,
            outstandingBalance: outstandingBalance,
            totalPurchases: totalPurchases,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String phone,
            required String email,
            required String address,
            Value<String?> state = const Value.absent(),
            Value<double> outstandingBalance = const Value.absent(),
            Value<double> totalPurchases = const Value.absent(),
            required DateTime createdAt,
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomersCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            email: email,
            address: address,
            state: state,
            outstandingBalance: outstandingBalance,
            totalPurchases: totalPurchases,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
    Customer,
    PrefetchHooks Function()>;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  required String name,
  required String sku,
  required String barcode,
  Value<String> category,
  Value<double> sellingPrice,
  Value<double> purchasePrice,
  Value<int> stockQuantity,
  Value<int> reorderLevel,
  Value<String> unit,
  Value<double?> taxPercentage,
  Value<String> hsnCode,
  Value<String> description,
  Value<bool> isActive,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> sku,
  Value<String> barcode,
  Value<String> category,
  Value<double> sellingPrice,
  Value<double> purchasePrice,
  Value<int> stockQuantity,
  Value<int> reorderLevel,
  Value<String> unit,
  Value<double?> taxPercentage,
  Value<String> hsnCode,
  Value<String> description,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sellingPrice => $composableBuilder(
      column: $table.sellingPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stockQuantity => $composableBuilder(
      column: $table.stockQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reorderLevel => $composableBuilder(
      column: $table.reorderLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get taxPercentage => $composableBuilder(
      column: $table.taxPercentage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hsnCode => $composableBuilder(
      column: $table.hsnCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sellingPrice => $composableBuilder(
      column: $table.sellingPrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stockQuantity => $composableBuilder(
      column: $table.stockQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reorderLevel => $composableBuilder(
      column: $table.reorderLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get taxPercentage => $composableBuilder(
      column: $table.taxPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hsnCode => $composableBuilder(
      column: $table.hsnCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get sellingPrice => $composableBuilder(
      column: $table.sellingPrice, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => column);

  GeneratedColumn<int> get stockQuantity => $composableBuilder(
      column: $table.stockQuantity, builder: (column) => column);

  GeneratedColumn<int> get reorderLevel => $composableBuilder(
      column: $table.reorderLevel, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get taxPercentage => $composableBuilder(
      column: $table.taxPercentage, builder: (column) => column);

  GeneratedColumn<String> get hsnCode =>
      $composableBuilder(column: $table.hsnCode, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
    Product,
    PrefetchHooks Function()> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> sku = const Value.absent(),
            Value<String> barcode = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double> sellingPrice = const Value.absent(),
            Value<double> purchasePrice = const Value.absent(),
            Value<int> stockQuantity = const Value.absent(),
            Value<int> reorderLevel = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double?> taxPercentage = const Value.absent(),
            Value<String> hsnCode = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            name: name,
            sku: sku,
            barcode: barcode,
            category: category,
            sellingPrice: sellingPrice,
            purchasePrice: purchasePrice,
            stockQuantity: stockQuantity,
            reorderLevel: reorderLevel,
            unit: unit,
            taxPercentage: taxPercentage,
            hsnCode: hsnCode,
            description: description,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String sku,
            required String barcode,
            Value<String> category = const Value.absent(),
            Value<double> sellingPrice = const Value.absent(),
            Value<double> purchasePrice = const Value.absent(),
            Value<int> stockQuantity = const Value.absent(),
            Value<int> reorderLevel = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double?> taxPercentage = const Value.absent(),
            Value<String> hsnCode = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            name: name,
            sku: sku,
            barcode: barcode,
            category: category,
            sellingPrice: sellingPrice,
            purchasePrice: purchasePrice,
            stockQuantity: stockQuantity,
            reorderLevel: reorderLevel,
            unit: unit,
            taxPercentage: taxPercentage,
            hsnCode: hsnCode,
            description: description,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
    Product,
    PrefetchHooks Function()>;
typedef $$StockMovementsTableCreateCompanionBuilder = StockMovementsCompanion
    Function({
  required String id,
  required String productId,
  required String productName,
  required String type,
  required int quantityChange,
  required int previousQuantity,
  required int newQuantity,
  required String reason,
  required DateTime timestamp,
  Value<int> rowid,
});
typedef $$StockMovementsTableUpdateCompanionBuilder = StockMovementsCompanion
    Function({
  Value<String> id,
  Value<String> productId,
  Value<String> productName,
  Value<String> type,
  Value<int> quantityChange,
  Value<int> previousQuantity,
  Value<int> newQuantity,
  Value<String> reason,
  Value<DateTime> timestamp,
  Value<int> rowid,
});

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantityChange => $composableBuilder(
      column: $table.quantityChange,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get previousQuantity => $composableBuilder(
      column: $table.previousQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get newQuantity => $composableBuilder(
      column: $table.newQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantityChange => $composableBuilder(
      column: $table.quantityChange,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get previousQuantity => $composableBuilder(
      column: $table.previousQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get newQuantity => $composableBuilder(
      column: $table.newQuantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get quantityChange => $composableBuilder(
      column: $table.quantityChange, builder: (column) => column);

  GeneratedColumn<int> get previousQuantity => $composableBuilder(
      column: $table.previousQuantity, builder: (column) => column);

  GeneratedColumn<int> get newQuantity => $composableBuilder(
      column: $table.newQuantity, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$StockMovementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StockMovementsTable,
    StockMovement,
    $$StockMovementsTableFilterComposer,
    $$StockMovementsTableOrderingComposer,
    $$StockMovementsTableAnnotationComposer,
    $$StockMovementsTableCreateCompanionBuilder,
    $$StockMovementsTableUpdateCompanionBuilder,
    (
      StockMovement,
      BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement>
    ),
    StockMovement,
    PrefetchHooks Function()> {
  $$StockMovementsTableTableManager(
      _$AppDatabase db, $StockMovementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> quantityChange = const Value.absent(),
            Value<int> previousQuantity = const Value.absent(),
            Value<int> newQuantity = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StockMovementsCompanion(
            id: id,
            productId: productId,
            productName: productName,
            type: type,
            quantityChange: quantityChange,
            previousQuantity: previousQuantity,
            newQuantity: newQuantity,
            reason: reason,
            timestamp: timestamp,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String productId,
            required String productName,
            required String type,
            required int quantityChange,
            required int previousQuantity,
            required int newQuantity,
            required String reason,
            required DateTime timestamp,
            Value<int> rowid = const Value.absent(),
          }) =>
              StockMovementsCompanion.insert(
            id: id,
            productId: productId,
            productName: productName,
            type: type,
            quantityChange: quantityChange,
            previousQuantity: previousQuantity,
            newQuantity: newQuantity,
            reason: reason,
            timestamp: timestamp,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StockMovementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StockMovementsTable,
    StockMovement,
    $$StockMovementsTableFilterComposer,
    $$StockMovementsTableOrderingComposer,
    $$StockMovementsTableAnnotationComposer,
    $$StockMovementsTableCreateCompanionBuilder,
    $$StockMovementsTableUpdateCompanionBuilder,
    (
      StockMovement,
      BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement>
    ),
    StockMovement,
    PrefetchHooks Function()>;
typedef $$InvoicesTableCreateCompanionBuilder = InvoicesCompanion Function({
  required String id,
  required String invoiceNumber,
  required String type,
  required String customerId,
  required String customerName,
  required String customerPhone,
  Value<double> subtotal,
  Value<double> taxTotal,
  Value<double> discountTotal,
  Value<double> grandTotal,
  Value<double> paidAmount,
  required String status,
  required DateTime issueDate,
  required DateTime dueDate,
  Value<String> notes,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$InvoicesTableUpdateCompanionBuilder = InvoicesCompanion Function({
  Value<String> id,
  Value<String> invoiceNumber,
  Value<String> type,
  Value<String> customerId,
  Value<String> customerName,
  Value<String> customerPhone,
  Value<double> subtotal,
  Value<double> taxTotal,
  Value<double> discountTotal,
  Value<double> grandTotal,
  Value<double> paidAmount,
  Value<String> status,
  Value<DateTime> issueDate,
  Value<DateTime> dueDate,
  Value<String> notes,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$InvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get taxTotal => $composableBuilder(
      column: $table.taxTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discountTotal => $composableBuilder(
      column: $table.discountTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get grandTotal => $composableBuilder(
      column: $table.grandTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get issueDate => $composableBuilder(
      column: $table.issueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get taxTotal => $composableBuilder(
      column: $table.taxTotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discountTotal => $composableBuilder(
      column: $table.discountTotal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get grandTotal => $composableBuilder(
      column: $table.grandTotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get issueDate => $composableBuilder(
      column: $table.issueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get taxTotal =>
      $composableBuilder(column: $table.taxTotal, builder: (column) => column);

  GeneratedColumn<double> get discountTotal => $composableBuilder(
      column: $table.discountTotal, builder: (column) => column);

  GeneratedColumn<double> get grandTotal => $composableBuilder(
      column: $table.grandTotal, builder: (column) => column);

  GeneratedColumn<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get issueDate =>
      $composableBuilder(column: $table.issueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$InvoicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoicesTable,
    Invoice,
    $$InvoicesTableFilterComposer,
    $$InvoicesTableOrderingComposer,
    $$InvoicesTableAnnotationComposer,
    $$InvoicesTableCreateCompanionBuilder,
    $$InvoicesTableUpdateCompanionBuilder,
    (Invoice, BaseReferences<_$AppDatabase, $InvoicesTable, Invoice>),
    Invoice,
    PrefetchHooks Function()> {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> invoiceNumber = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> customerId = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<String> customerPhone = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<double> taxTotal = const Value.absent(),
            Value<double> discountTotal = const Value.absent(),
            Value<double> grandTotal = const Value.absent(),
            Value<double> paidAmount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> issueDate = const Value.absent(),
            Value<DateTime> dueDate = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoicesCompanion(
            id: id,
            invoiceNumber: invoiceNumber,
            type: type,
            customerId: customerId,
            customerName: customerName,
            customerPhone: customerPhone,
            subtotal: subtotal,
            taxTotal: taxTotal,
            discountTotal: discountTotal,
            grandTotal: grandTotal,
            paidAmount: paidAmount,
            status: status,
            issueDate: issueDate,
            dueDate: dueDate,
            notes: notes,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String invoiceNumber,
            required String type,
            required String customerId,
            required String customerName,
            required String customerPhone,
            Value<double> subtotal = const Value.absent(),
            Value<double> taxTotal = const Value.absent(),
            Value<double> discountTotal = const Value.absent(),
            Value<double> grandTotal = const Value.absent(),
            Value<double> paidAmount = const Value.absent(),
            required String status,
            required DateTime issueDate,
            required DateTime dueDate,
            Value<String> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoicesCompanion.insert(
            id: id,
            invoiceNumber: invoiceNumber,
            type: type,
            customerId: customerId,
            customerName: customerName,
            customerPhone: customerPhone,
            subtotal: subtotal,
            taxTotal: taxTotal,
            discountTotal: discountTotal,
            grandTotal: grandTotal,
            paidAmount: paidAmount,
            status: status,
            issueDate: issueDate,
            dueDate: dueDate,
            notes: notes,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InvoicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoicesTable,
    Invoice,
    $$InvoicesTableFilterComposer,
    $$InvoicesTableOrderingComposer,
    $$InvoicesTableAnnotationComposer,
    $$InvoicesTableCreateCompanionBuilder,
    $$InvoicesTableUpdateCompanionBuilder,
    (Invoice, BaseReferences<_$AppDatabase, $InvoicesTable, Invoice>),
    Invoice,
    PrefetchHooks Function()>;
typedef $$InvoiceItemsTableCreateCompanionBuilder = InvoiceItemsCompanion
    Function({
  Value<int> id,
  required String invoiceId,
  required String productId,
  required String productName,
  Value<String> sku,
  Value<int> quantity,
  Value<double> unitPrice,
  Value<double> taxPercentage,
});
typedef $$InvoiceItemsTableUpdateCompanionBuilder = InvoiceItemsCompanion
    Function({
  Value<int> id,
  Value<String> invoiceId,
  Value<String> productId,
  Value<String> productName,
  Value<String> sku,
  Value<int> quantity,
  Value<double> unitPrice,
  Value<double> taxPercentage,
});

class $$InvoiceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceId => $composableBuilder(
      column: $table.invoiceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get taxPercentage => $composableBuilder(
      column: $table.taxPercentage, builder: (column) => ColumnFilters(column));
}

class $$InvoiceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceId => $composableBuilder(
      column: $table.invoiceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get taxPercentage => $composableBuilder(
      column: $table.taxPercentage,
      builder: (column) => ColumnOrderings(column));
}

class $$InvoiceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get taxPercentage => $composableBuilder(
      column: $table.taxPercentage, builder: (column) => column);
}

class $$InvoiceItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoiceItemsTable,
    InvoiceItem,
    $$InvoiceItemsTableFilterComposer,
    $$InvoiceItemsTableOrderingComposer,
    $$InvoiceItemsTableAnnotationComposer,
    $$InvoiceItemsTableCreateCompanionBuilder,
    $$InvoiceItemsTableUpdateCompanionBuilder,
    (
      InvoiceItem,
      BaseReferences<_$AppDatabase, $InvoiceItemsTable, InvoiceItem>
    ),
    InvoiceItem,
    PrefetchHooks Function()> {
  $$InvoiceItemsTableTableManager(_$AppDatabase db, $InvoiceItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> invoiceId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<String> sku = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> taxPercentage = const Value.absent(),
          }) =>
              InvoiceItemsCompanion(
            id: id,
            invoiceId: invoiceId,
            productId: productId,
            productName: productName,
            sku: sku,
            quantity: quantity,
            unitPrice: unitPrice,
            taxPercentage: taxPercentage,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String invoiceId,
            required String productId,
            required String productName,
            Value<String> sku = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> taxPercentage = const Value.absent(),
          }) =>
              InvoiceItemsCompanion.insert(
            id: id,
            invoiceId: invoiceId,
            productId: productId,
            productName: productName,
            sku: sku,
            quantity: quantity,
            unitPrice: unitPrice,
            taxPercentage: taxPercentage,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InvoiceItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoiceItemsTable,
    InvoiceItem,
    $$InvoiceItemsTableFilterComposer,
    $$InvoiceItemsTableOrderingComposer,
    $$InvoiceItemsTableAnnotationComposer,
    $$InvoiceItemsTableCreateCompanionBuilder,
    $$InvoiceItemsTableUpdateCompanionBuilder,
    (
      InvoiceItem,
      BaseReferences<_$AppDatabase, $InvoiceItemsTable, InvoiceItem>
    ),
    InvoiceItem,
    PrefetchHooks Function()>;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  required String id,
  required String invoiceId,
  required String customerId,
  required String customerName,
  Value<double> amount,
  required String paymentMode,
  Value<String> referenceNumber,
  required DateTime paymentDate,
  Value<String> notes,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String> id,
  Value<String> invoiceId,
  Value<String> customerId,
  Value<String> customerName,
  Value<double> amount,
  Value<String> paymentMode,
  Value<String> referenceNumber,
  Value<DateTime> paymentDate,
  Value<String> notes,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceId => $composableBuilder(
      column: $table.invoiceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceNumber => $composableBuilder(
      column: $table.referenceNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceId => $composableBuilder(
      column: $table.invoiceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceNumber => $composableBuilder(
      column: $table.referenceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => column);

  GeneratedColumn<String> get referenceNumber => $composableBuilder(
      column: $table.referenceNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$PaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
    Payment,
    PrefetchHooks Function()> {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> invoiceId = const Value.absent(),
            Value<String> customerId = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> paymentMode = const Value.absent(),
            Value<String> referenceNumber = const Value.absent(),
            Value<DateTime> paymentDate = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion(
            id: id,
            invoiceId: invoiceId,
            customerId: customerId,
            customerName: customerName,
            amount: amount,
            paymentMode: paymentMode,
            referenceNumber: referenceNumber,
            paymentDate: paymentDate,
            notes: notes,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String invoiceId,
            required String customerId,
            required String customerName,
            Value<double> amount = const Value.absent(),
            required String paymentMode,
            Value<String> referenceNumber = const Value.absent(),
            required DateTime paymentDate,
            Value<String> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion.insert(
            id: id,
            invoiceId: invoiceId,
            customerId: customerId,
            customerName: customerName,
            amount: amount,
            paymentMode: paymentMode,
            referenceNumber: referenceNumber,
            paymentDate: paymentDate,
            notes: notes,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
    Payment,
    PrefetchHooks Function()>;
typedef $$PurchasesTableCreateCompanionBuilder = PurchasesCompanion Function({
  required String id,
  required String poNumber,
  required String supplierId,
  required String supplierName,
  Value<double> totalAmount,
  required String status,
  required DateTime orderDate,
  Value<String> notes,
  Value<int> rowid,
});
typedef $$PurchasesTableUpdateCompanionBuilder = PurchasesCompanion Function({
  Value<String> id,
  Value<String> poNumber,
  Value<String> supplierId,
  Value<String> supplierName,
  Value<double> totalAmount,
  Value<String> status,
  Value<DateTime> orderDate,
  Value<String> notes,
  Value<int> rowid,
});

class $$PurchasesTableFilterComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get poNumber => $composableBuilder(
      column: $table.poNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierName => $composableBuilder(
      column: $table.supplierName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get orderDate => $composableBuilder(
      column: $table.orderDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$PurchasesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get poNumber => $composableBuilder(
      column: $table.poNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierName => $composableBuilder(
      column: $table.supplierName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get orderDate => $composableBuilder(
      column: $table.orderDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$PurchasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get poNumber =>
      $composableBuilder(column: $table.poNumber, builder: (column) => column);

  GeneratedColumn<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => column);

  GeneratedColumn<String> get supplierName => $composableBuilder(
      column: $table.supplierName, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get orderDate =>
      $composableBuilder(column: $table.orderDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$PurchasesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PurchasesTable,
    Purchase,
    $$PurchasesTableFilterComposer,
    $$PurchasesTableOrderingComposer,
    $$PurchasesTableAnnotationComposer,
    $$PurchasesTableCreateCompanionBuilder,
    $$PurchasesTableUpdateCompanionBuilder,
    (Purchase, BaseReferences<_$AppDatabase, $PurchasesTable, Purchase>),
    Purchase,
    PrefetchHooks Function()> {
  $$PurchasesTableTableManager(_$AppDatabase db, $PurchasesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> poNumber = const Value.absent(),
            Value<String> supplierId = const Value.absent(),
            Value<String> supplierName = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> orderDate = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchasesCompanion(
            id: id,
            poNumber: poNumber,
            supplierId: supplierId,
            supplierName: supplierName,
            totalAmount: totalAmount,
            status: status,
            orderDate: orderDate,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String poNumber,
            required String supplierId,
            required String supplierName,
            Value<double> totalAmount = const Value.absent(),
            required String status,
            required DateTime orderDate,
            Value<String> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchasesCompanion.insert(
            id: id,
            poNumber: poNumber,
            supplierId: supplierId,
            supplierName: supplierName,
            totalAmount: totalAmount,
            status: status,
            orderDate: orderDate,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PurchasesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PurchasesTable,
    Purchase,
    $$PurchasesTableFilterComposer,
    $$PurchasesTableOrderingComposer,
    $$PurchasesTableAnnotationComposer,
    $$PurchasesTableCreateCompanionBuilder,
    $$PurchasesTableUpdateCompanionBuilder,
    (Purchase, BaseReferences<_$AppDatabase, $PurchasesTable, Purchase>),
    Purchase,
    PrefetchHooks Function()>;
typedef $$SuppliersTableCreateCompanionBuilder = SuppliersCompanion Function({
  required String id,
  required String name,
  required String companyName,
  required String phone,
  required String email,
  required String address,
  Value<double> payableBalance,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SuppliersTableUpdateCompanionBuilder = SuppliersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> companyName,
  Value<String> phone,
  Value<String> email,
  Value<String> address,
  Value<double> payableBalance,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get payableBalance => $composableBuilder(
      column: $table.payableBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get payableBalance => $composableBuilder(
      column: $table.payableBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get payableBalance => $composableBuilder(
      column: $table.payableBalance, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SuppliersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SuppliersTable,
    Supplier,
    $$SuppliersTableFilterComposer,
    $$SuppliersTableOrderingComposer,
    $$SuppliersTableAnnotationComposer,
    $$SuppliersTableCreateCompanionBuilder,
    $$SuppliersTableUpdateCompanionBuilder,
    (Supplier, BaseReferences<_$AppDatabase, $SuppliersTable, Supplier>),
    Supplier,
    PrefetchHooks Function()> {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> companyName = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<double> payableBalance = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SuppliersCompanion(
            id: id,
            name: name,
            companyName: companyName,
            phone: phone,
            email: email,
            address: address,
            payableBalance: payableBalance,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String companyName,
            required String phone,
            required String email,
            required String address,
            Value<double> payableBalance = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SuppliersCompanion.insert(
            id: id,
            name: name,
            companyName: companyName,
            phone: phone,
            email: email,
            address: address,
            payableBalance: payableBalance,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SuppliersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SuppliersTable,
    Supplier,
    $$SuppliersTableFilterComposer,
    $$SuppliersTableOrderingComposer,
    $$SuppliersTableAnnotationComposer,
    $$SuppliersTableCreateCompanionBuilder,
    $$SuppliersTableUpdateCompanionBuilder,
    (Supplier, BaseReferences<_$AppDatabase, $SuppliersTable, Supplier>),
    Supplier,
    PrefetchHooks Function()>;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  required String id,
  required String title,
  required String category,
  Value<double> amount,
  required String paymentMode,
  required DateTime expenseDate,
  Value<String> notes,
  Value<int> rowid,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> category,
  Value<double> amount,
  Value<String> paymentMode,
  Value<DateTime> expenseDate,
  Value<String> notes,
  Value<int> rowid,
});

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => column);

  GeneratedColumn<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$ExpensesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
    Expense,
    PrefetchHooks Function()> {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> paymentMode = const Value.absent(),
            Value<DateTime> expenseDate = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesCompanion(
            id: id,
            title: title,
            category: category,
            amount: amount,
            paymentMode: paymentMode,
            expenseDate: expenseDate,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String category,
            Value<double> amount = const Value.absent(),
            required String paymentMode,
            required DateTime expenseDate,
            Value<String> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesCompanion.insert(
            id: id,
            title: title,
            category: category,
            amount: amount,
            paymentMode: paymentMode,
            expenseDate: expenseDate,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExpensesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
    Expense,
    PrefetchHooks Function()>;
typedef $$IncomeTableCreateCompanionBuilder = IncomeCompanion Function({
  required String id,
  required String title,
  required String category,
  Value<double> amount,
  required String paymentMode,
  required DateTime incomeDate,
  Value<String> notes,
  Value<int> rowid,
});
typedef $$IncomeTableUpdateCompanionBuilder = IncomeCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> category,
  Value<double> amount,
  Value<String> paymentMode,
  Value<DateTime> incomeDate,
  Value<String> notes,
  Value<int> rowid,
});

class $$IncomeTableFilterComposer
    extends Composer<_$AppDatabase, $IncomeTable> {
  $$IncomeTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get incomeDate => $composableBuilder(
      column: $table.incomeDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$IncomeTableOrderingComposer
    extends Composer<_$AppDatabase, $IncomeTable> {
  $$IncomeTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get incomeDate => $composableBuilder(
      column: $table.incomeDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$IncomeTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncomeTable> {
  $$IncomeTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => column);

  GeneratedColumn<DateTime> get incomeDate => $composableBuilder(
      column: $table.incomeDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$IncomeTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IncomeTable,
    IncomeData,
    $$IncomeTableFilterComposer,
    $$IncomeTableOrderingComposer,
    $$IncomeTableAnnotationComposer,
    $$IncomeTableCreateCompanionBuilder,
    $$IncomeTableUpdateCompanionBuilder,
    (IncomeData, BaseReferences<_$AppDatabase, $IncomeTable, IncomeData>),
    IncomeData,
    PrefetchHooks Function()> {
  $$IncomeTableTableManager(_$AppDatabase db, $IncomeTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomeTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomeTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomeTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> paymentMode = const Value.absent(),
            Value<DateTime> incomeDate = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IncomeCompanion(
            id: id,
            title: title,
            category: category,
            amount: amount,
            paymentMode: paymentMode,
            incomeDate: incomeDate,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String category,
            Value<double> amount = const Value.absent(),
            required String paymentMode,
            required DateTime incomeDate,
            Value<String> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IncomeCompanion.insert(
            id: id,
            title: title,
            category: category,
            amount: amount,
            paymentMode: paymentMode,
            incomeDate: incomeDate,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$IncomeTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $IncomeTable,
    IncomeData,
    $$IncomeTableFilterComposer,
    $$IncomeTableOrderingComposer,
    $$IncomeTableAnnotationComposer,
    $$IncomeTableCreateCompanionBuilder,
    $$IncomeTableUpdateCompanionBuilder,
    (IncomeData, BaseReferences<_$AppDatabase, $IncomeTable, IncomeData>),
    IncomeData,
    PrefetchHooks Function()>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  required String type,
  Value<bool> isActive,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> type,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            type: type,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String type,
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            type: type,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()>;
typedef $$InvoiceReturnsTableCreateCompanionBuilder = InvoiceReturnsCompanion
    Function({
  required String id,
  required String returnNumber,
  required String invoiceId,
  required String invoiceNumber,
  required String partyId,
  required String partyName,
  required String type,
  Value<double> totalAmount,
  required DateTime returnDate,
  Value<String> notes,
  Value<int> rowid,
});
typedef $$InvoiceReturnsTableUpdateCompanionBuilder = InvoiceReturnsCompanion
    Function({
  Value<String> id,
  Value<String> returnNumber,
  Value<String> invoiceId,
  Value<String> invoiceNumber,
  Value<String> partyId,
  Value<String> partyName,
  Value<String> type,
  Value<double> totalAmount,
  Value<DateTime> returnDate,
  Value<String> notes,
  Value<int> rowid,
});

class $$InvoiceReturnsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceReturnsTable> {
  $$InvoiceReturnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get returnNumber => $composableBuilder(
      column: $table.returnNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceId => $composableBuilder(
      column: $table.invoiceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partyName => $composableBuilder(
      column: $table.partyName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get returnDate => $composableBuilder(
      column: $table.returnDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$InvoiceReturnsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceReturnsTable> {
  $$InvoiceReturnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get returnNumber => $composableBuilder(
      column: $table.returnNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceId => $composableBuilder(
      column: $table.invoiceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partyName => $composableBuilder(
      column: $table.partyName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get returnDate => $composableBuilder(
      column: $table.returnDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$InvoiceReturnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceReturnsTable> {
  $$InvoiceReturnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get returnNumber => $composableBuilder(
      column: $table.returnNumber, builder: (column) => column);

  GeneratedColumn<String> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => column);

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get partyName =>
      $composableBuilder(column: $table.partyName, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get returnDate => $composableBuilder(
      column: $table.returnDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$InvoiceReturnsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoiceReturnsTable,
    InvoiceReturn,
    $$InvoiceReturnsTableFilterComposer,
    $$InvoiceReturnsTableOrderingComposer,
    $$InvoiceReturnsTableAnnotationComposer,
    $$InvoiceReturnsTableCreateCompanionBuilder,
    $$InvoiceReturnsTableUpdateCompanionBuilder,
    (
      InvoiceReturn,
      BaseReferences<_$AppDatabase, $InvoiceReturnsTable, InvoiceReturn>
    ),
    InvoiceReturn,
    PrefetchHooks Function()> {
  $$InvoiceReturnsTableTableManager(
      _$AppDatabase db, $InvoiceReturnsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceReturnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceReturnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceReturnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> returnNumber = const Value.absent(),
            Value<String> invoiceId = const Value.absent(),
            Value<String> invoiceNumber = const Value.absent(),
            Value<String> partyId = const Value.absent(),
            Value<String> partyName = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<DateTime> returnDate = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoiceReturnsCompanion(
            id: id,
            returnNumber: returnNumber,
            invoiceId: invoiceId,
            invoiceNumber: invoiceNumber,
            partyId: partyId,
            partyName: partyName,
            type: type,
            totalAmount: totalAmount,
            returnDate: returnDate,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String returnNumber,
            required String invoiceId,
            required String invoiceNumber,
            required String partyId,
            required String partyName,
            required String type,
            Value<double> totalAmount = const Value.absent(),
            required DateTime returnDate,
            Value<String> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoiceReturnsCompanion.insert(
            id: id,
            returnNumber: returnNumber,
            invoiceId: invoiceId,
            invoiceNumber: invoiceNumber,
            partyId: partyId,
            partyName: partyName,
            type: type,
            totalAmount: totalAmount,
            returnDate: returnDate,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InvoiceReturnsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoiceReturnsTable,
    InvoiceReturn,
    $$InvoiceReturnsTableFilterComposer,
    $$InvoiceReturnsTableOrderingComposer,
    $$InvoiceReturnsTableAnnotationComposer,
    $$InvoiceReturnsTableCreateCompanionBuilder,
    $$InvoiceReturnsTableUpdateCompanionBuilder,
    (
      InvoiceReturn,
      BaseReferences<_$AppDatabase, $InvoiceReturnsTable, InvoiceReturn>
    ),
    InvoiceReturn,
    PrefetchHooks Function()>;
typedef $$InvoiceReturnItemsTableCreateCompanionBuilder
    = InvoiceReturnItemsCompanion Function({
  Value<int> id,
  required String returnId,
  required String productId,
  required String productName,
  Value<String> sku,
  Value<int> originalQuantity,
  Value<int> returnedQuantity,
  Value<double> unitPrice,
});
typedef $$InvoiceReturnItemsTableUpdateCompanionBuilder
    = InvoiceReturnItemsCompanion Function({
  Value<int> id,
  Value<String> returnId,
  Value<String> productId,
  Value<String> productName,
  Value<String> sku,
  Value<int> originalQuantity,
  Value<int> returnedQuantity,
  Value<double> unitPrice,
});

class $$InvoiceReturnItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceReturnItemsTable> {
  $$InvoiceReturnItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get returnId => $composableBuilder(
      column: $table.returnId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get originalQuantity => $composableBuilder(
      column: $table.originalQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get returnedQuantity => $composableBuilder(
      column: $table.returnedQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));
}

class $$InvoiceReturnItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceReturnItemsTable> {
  $$InvoiceReturnItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get returnId => $composableBuilder(
      column: $table.returnId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get originalQuantity => $composableBuilder(
      column: $table.originalQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get returnedQuantity => $composableBuilder(
      column: $table.returnedQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));
}

class $$InvoiceReturnItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceReturnItemsTable> {
  $$InvoiceReturnItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get returnId =>
      $composableBuilder(column: $table.returnId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<int> get originalQuantity => $composableBuilder(
      column: $table.originalQuantity, builder: (column) => column);

  GeneratedColumn<int> get returnedQuantity => $composableBuilder(
      column: $table.returnedQuantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);
}

class $$InvoiceReturnItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoiceReturnItemsTable,
    InvoiceReturnItem,
    $$InvoiceReturnItemsTableFilterComposer,
    $$InvoiceReturnItemsTableOrderingComposer,
    $$InvoiceReturnItemsTableAnnotationComposer,
    $$InvoiceReturnItemsTableCreateCompanionBuilder,
    $$InvoiceReturnItemsTableUpdateCompanionBuilder,
    (
      InvoiceReturnItem,
      BaseReferences<_$AppDatabase, $InvoiceReturnItemsTable, InvoiceReturnItem>
    ),
    InvoiceReturnItem,
    PrefetchHooks Function()> {
  $$InvoiceReturnItemsTableTableManager(
      _$AppDatabase db, $InvoiceReturnItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceReturnItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceReturnItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceReturnItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> returnId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<String> sku = const Value.absent(),
            Value<int> originalQuantity = const Value.absent(),
            Value<int> returnedQuantity = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
          }) =>
              InvoiceReturnItemsCompanion(
            id: id,
            returnId: returnId,
            productId: productId,
            productName: productName,
            sku: sku,
            originalQuantity: originalQuantity,
            returnedQuantity: returnedQuantity,
            unitPrice: unitPrice,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String returnId,
            required String productId,
            required String productName,
            Value<String> sku = const Value.absent(),
            Value<int> originalQuantity = const Value.absent(),
            Value<int> returnedQuantity = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
          }) =>
              InvoiceReturnItemsCompanion.insert(
            id: id,
            returnId: returnId,
            productId: productId,
            productName: productName,
            sku: sku,
            originalQuantity: originalQuantity,
            returnedQuantity: returnedQuantity,
            unitPrice: unitPrice,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InvoiceReturnItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoiceReturnItemsTable,
    InvoiceReturnItem,
    $$InvoiceReturnItemsTableFilterComposer,
    $$InvoiceReturnItemsTableOrderingComposer,
    $$InvoiceReturnItemsTableAnnotationComposer,
    $$InvoiceReturnItemsTableCreateCompanionBuilder,
    $$InvoiceReturnItemsTableUpdateCompanionBuilder,
    (
      InvoiceReturnItem,
      BaseReferences<_$AppDatabase, $InvoiceReturnItemsTable, InvoiceReturnItem>
    ),
    InvoiceReturnItem,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  required String id,
  required String entityType,
  required String action,
  required String payload,
  required DateTime createdAt,
  Value<int> retryCount,
  Value<String> status,
  Value<int> rowid,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> action,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String> status,
  Value<int> rowid,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            entityType: entityType,
            action: action,
            payload: payload,
            createdAt: createdAt,
            retryCount: retryCount,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            required String action,
            required String payload,
            required DateTime createdAt,
            Value<int> retryCount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            entityType: entityType,
            action: action,
            payload: payload,
            createdAt: createdAt,
            retryCount: retryCount,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()>;
typedef $$AppKeyValueStoreTableCreateCompanionBuilder
    = AppKeyValueStoreCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppKeyValueStoreTableUpdateCompanionBuilder
    = AppKeyValueStoreCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppKeyValueStoreTableFilterComposer
    extends Composer<_$AppDatabase, $AppKeyValueStoreTable> {
  $$AppKeyValueStoreTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppKeyValueStoreTableOrderingComposer
    extends Composer<_$AppDatabase, $AppKeyValueStoreTable> {
  $$AppKeyValueStoreTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppKeyValueStoreTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppKeyValueStoreTable> {
  $$AppKeyValueStoreTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppKeyValueStoreTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppKeyValueStoreTable,
    AppKeyValueStoreData,
    $$AppKeyValueStoreTableFilterComposer,
    $$AppKeyValueStoreTableOrderingComposer,
    $$AppKeyValueStoreTableAnnotationComposer,
    $$AppKeyValueStoreTableCreateCompanionBuilder,
    $$AppKeyValueStoreTableUpdateCompanionBuilder,
    (
      AppKeyValueStoreData,
      BaseReferences<_$AppDatabase, $AppKeyValueStoreTable,
          AppKeyValueStoreData>
    ),
    AppKeyValueStoreData,
    PrefetchHooks Function()> {
  $$AppKeyValueStoreTableTableManager(
      _$AppDatabase db, $AppKeyValueStoreTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppKeyValueStoreTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppKeyValueStoreTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppKeyValueStoreTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppKeyValueStoreCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppKeyValueStoreCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppKeyValueStoreTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppKeyValueStoreTable,
    AppKeyValueStoreData,
    $$AppKeyValueStoreTableFilterComposer,
    $$AppKeyValueStoreTableOrderingComposer,
    $$AppKeyValueStoreTableAnnotationComposer,
    $$AppKeyValueStoreTableCreateCompanionBuilder,
    $$AppKeyValueStoreTableUpdateCompanionBuilder,
    (
      AppKeyValueStoreData,
      BaseReferences<_$AppDatabase, $AppKeyValueStoreTable,
          AppKeyValueStoreData>
    ),
    AppKeyValueStoreData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$InvoiceItemsTableTableManager get invoiceItems =>
      $$InvoiceItemsTableTableManager(_db, _db.invoiceItems);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$PurchasesTableTableManager get purchases =>
      $$PurchasesTableTableManager(_db, _db.purchases);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$IncomeTableTableManager get income =>
      $$IncomeTableTableManager(_db, _db.income);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$InvoiceReturnsTableTableManager get invoiceReturns =>
      $$InvoiceReturnsTableTableManager(_db, _db.invoiceReturns);
  $$InvoiceReturnItemsTableTableManager get invoiceReturnItems =>
      $$InvoiceReturnItemsTableTableManager(_db, _db.invoiceReturnItems);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$AppKeyValueStoreTableTableManager get appKeyValueStore =>
      $$AppKeyValueStoreTableTableManager(_db, _db.appKeyValueStore);
}
