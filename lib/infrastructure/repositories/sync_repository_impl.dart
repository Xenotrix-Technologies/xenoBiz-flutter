import '../../domain/entities/sync_item_entity.dart';
import '../../domain/repositories/sync_repository.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import '../network/network_checker.dart';
import '../storage/hive_service.dart';

class SyncRepositoryImpl implements SyncRepository {
  final HiveService hiveService;
  final DioClient dioClient;
  final NetworkChecker networkChecker;

  SyncRepositoryImpl({
    required this.hiveService,
    required this.dioClient,
    required this.networkChecker,
  });

  SyncAction _parseAction(String? actionStr) {
    if (actionStr == 'update' || actionStr == 'SyncAction.update') return SyncAction.update;
    if (actionStr == 'delete' || actionStr == 'SyncAction.delete') return SyncAction.delete;
    return SyncAction.create;
  }

  Map<String, dynamic> _syncItemToMap(SyncItemEntity item) {
    return {
      'id': item.id,
      'entityType': item.entityType,
      'action': item.action.name,
      'payload': item.payload,
      'createdAt': item.createdAt.toIso8601String(),
      'retryCount': item.retryCount,
      'status': item.status,
    };
  }

  SyncItemEntity _mapToSyncItem(Map<dynamic, dynamic> map) {
    return SyncItemEntity(
      id: map['id']?.toString() ?? '',
      entityType: map['entityType']?.toString() ?? 'UNKNOWN',
      action: _parseAction(map['action']?.toString()),
      payload: Map<String, dynamic>.from(map['payload'] is Map ? map['payload'] : {}),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      retryCount: (map['retryCount'] as num?)?.toInt() ?? 0,
      status: map['status']?.toString() ?? 'PENDING',
    );
  }

  @override
  Future<List<SyncItemEntity>> getPendingSyncItems() async {
    final box = hiveService.getBox(HiveService.boxSyncQueue);
    final List<SyncItemEntity> list = [];

    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        final item = _mapToSyncItem(val);
        if (item.status == 'PENDING' || item.status == 'FAILED') {
          list.add(item);
        }
      }
    }
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  @override
  Future<void> enqueueSyncItem(SyncItemEntity item) async {
    final box = hiveService.getBox(HiveService.boxSyncQueue);
    await box.put(item.id, _syncItemToMap(item));
  }

  @override
  Future<void> processSyncQueue() async {
    if (!await networkChecker.isConnected) return;

    final box = hiveService.getBox(HiveService.boxSyncQueue);
    final pendingItems = await getPendingSyncItems();

    for (final item in pendingItems) {
      bool success = false;
      try {
        if (item.entityType == 'CUSTOMER') {
          success = await _syncCustomer(item);
        } else if (item.entityType == 'PRODUCT') {
          success = await _syncProduct(item);
        } else if (item.entityType == 'INVOICE') {
          success = await _syncInvoice(item);
        } else if (item.entityType == 'PAYMENT') {
          success = await _syncPayment(item);
        } else if (item.entityType == 'LEAD') {
          success = await _syncLead(item);
        } else if (item.entityType == 'INVENTORY_ADJUST') {
          success = await _syncInventoryAdjust(item);
        } else {
          success = true;
        }
      } catch (_) {
        success = false;
      }

      if (success) {
        final completedItem = SyncItemEntity(
          id: item.id,
          entityType: item.entityType,
          action: item.action,
          payload: item.payload,
          createdAt: item.createdAt,
          retryCount: item.retryCount,
          status: 'COMPLETED',
        );
        await box.put(item.id, _syncItemToMap(completedItem));
      } else {
        final failedItem = SyncItemEntity(
          id: item.id,
          entityType: item.entityType,
          action: item.action,
          payload: item.payload,
          createdAt: item.createdAt,
          retryCount: item.retryCount + 1,
          status: 'FAILED',
        );
        await box.put(item.id, _syncItemToMap(failedItem));
      }
    }

    // Pull Server -> Hive updates
    await _pullServerUpdates();
  }

  Future<bool> _syncCustomer(SyncItemEntity item) async {
    final payload = item.payload;
    if (item.action == SyncAction.create) {
      final response = await dioClient.dio.post(
        ApiEndpoints.customers,
        data: {
          'name': payload['name'],
          'phone': payload['phone'],
          'email': payload['email'],
          'address': payload['address'],
        },
      );
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        final serverId = data['id']?.toString();
        final localId = payload['localId']?.toString();
        if (serverId != null && localId != null) {
          final custBox = hiveService.getBox(HiveService.boxCustomers);
          final localData = custBox.get(localId);
          if (localData is Map) {
            final updatedMap = Map<String, dynamic>.from(localData);
            updatedMap['id'] = serverId;
            updatedMap['syncStatus'] = 'synced';
            await custBox.delete(localId);
            await custBox.put(serverId, updatedMap);
          }
        }
        return true;
      }
    } else if (item.action == SyncAction.update) {
      final id = payload['id'];
      final response = await dioClient.dio.put(
        '${ApiEndpoints.customers}/$id',
        data: {
          'name': payload['name'],
          'phone': payload['phone'],
          'email': payload['email'],
          'address': payload['address'],
        },
      );
      if (response.data != null && response.data['success'] == true) {
        final custBox = hiveService.getBox(HiveService.boxCustomers);
        final localData = custBox.get(id);
        if (localData is Map) {
          final updatedMap = Map<String, dynamic>.from(localData);
          updatedMap['syncStatus'] = 'synced';
          await custBox.put(id, updatedMap);
        }
        return true;
      }
    }
    return false;
  }

  Future<bool> _syncProduct(SyncItemEntity item) async {
    final payload = item.payload;
    if (item.action == SyncAction.create) {
      final response = await dioClient.dio.post(
        ApiEndpoints.products,
        data: {
          'name': payload['name'],
          'sku': payload['sku'],
          'category': payload['category'],
          'sellingPrice': payload['sellingPrice'],
          'purchasePrice': payload['purchasePrice'],
          'currentStock': payload['currentStock'],
          'minStockLevel': payload['minStockLevel'],
          'unit': payload['unit'],
        },
      );
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        final serverId = data['id']?.toString();
        final localId = payload['localId']?.toString();
        if (serverId != null && localId != null) {
          final prodBox = hiveService.getBox(HiveService.boxProducts);
          final localData = prodBox.get(localId);
          if (localData is Map) {
            final updatedMap = Map<String, dynamic>.from(localData);
            updatedMap['id'] = serverId;
            updatedMap['syncStatus'] = 'synced';
            await prodBox.delete(localId);
            await prodBox.put(serverId, updatedMap);
          }
        }
        return true;
      }
    } else if (item.action == SyncAction.update) {
      final id = payload['id'];
      final response = await dioClient.dio.put(
        '${ApiEndpoints.products}/$id',
        data: {
          'name': payload['name'],
          'sku': payload['sku'],
          'category': payload['category'],
          'sellingPrice': payload['sellingPrice'],
          'purchasePrice': payload['purchasePrice'],
          'currentStock': payload['currentStock'],
          'minStockLevel': payload['minStockLevel'],
          'unit': payload['unit'],
        },
      );
      if (response.data != null && response.data['success'] == true) {
        final prodBox = hiveService.getBox(HiveService.boxProducts);
        final localData = prodBox.get(id);
        if (localData is Map) {
          final updatedMap = Map<String, dynamic>.from(localData);
          updatedMap['syncStatus'] = 'synced';
          await prodBox.put(id, updatedMap);
        }
        return true;
      }
    }
    return false;
  }

  Future<bool> _syncInvoice(SyncItemEntity item) async {
    final payload = item.payload;
    if (item.action == SyncAction.create) {
      final response = await dioClient.dio.post(
        ApiEndpoints.invoices,
        data: {
          'customerId': payload['customerId'],
          'customerName': payload['customerName'],
          'customerPhone': payload['customerPhone'],
          'items': payload['items'],
          'subtotal': payload['subtotal'],
          'taxTotal': payload['taxTotal'],
          'discountTotal': payload['discountTotal'],
          'grandTotal': payload['grandTotal'],
          'paidAmount': payload['paidAmount'],
          'paymentMethod': (payload['paidAmount'] as num? ?? 0) > 0 ? 'Cash' : null,
          'dueDate': payload['dueDate'],
          'notes': payload['notes'],
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        final serverId = data['id']?.toString();
        final localId = payload['localId']?.toString();
        final serverNum = data['invoice_number']?.toString();

        if (serverId != null && localId != null) {
          final invBox = hiveService.getBox(HiveService.boxInvoices);
          final localData = invBox.get(localId);
          if (localData is Map) {
            final updatedMap = Map<String, dynamic>.from(localData);
            updatedMap['id'] = serverId;
            if (serverNum != null) updatedMap['invoiceNumber'] = serverNum;
            updatedMap['syncStatus'] = 'synced';
            await invBox.delete(localId);
            await invBox.put(serverId, updatedMap);
          }
        }
        return true;
      }
    }
    return false;
  }

  Future<bool> _syncPayment(SyncItemEntity item) async {
    final payload = item.payload;
    final response = await dioClient.dio.post(
      ApiEndpoints.payments,
      data: {
        'invoiceId': payload['invoiceId'],
        'customerId': payload['customerId'],
        'amount': payload['amount'],
        'paymentMethod': payload['paymentMethod'],
        'paymentType': 'IN',
        'notes': payload['notes'],
      },
    );

    if (response.data != null && response.data['success'] == true) {
      final data = response.data['data'];
      final serverId = data['id']?.toString();
      final localId = payload['localId']?.toString();

      if (serverId != null && localId != null) {
        final payBox = hiveService.getBox(HiveService.boxPayments);
        final localData = payBox.get(localId);
        if (localData is Map) {
          final updatedMap = Map<String, dynamic>.from(localData);
          updatedMap['id'] = serverId;
          updatedMap['syncStatus'] = 'synced';
          await payBox.delete(localId);
          await payBox.put(serverId, updatedMap);
        }
      }
      return true;
    }
    return false;
  }

  Future<bool> _syncLead(SyncItemEntity item) async {
    final payload = item.payload;
    if (item.action == SyncAction.create) {
      final response = await dioClient.dio.post(
        '/crm/leads',
        data: {
          'title': payload['title'],
          'contactName': payload['contactName'],
          'contactPhone': payload['contactPhone'],
          'contactEmail': payload['contactEmail'],
          'leadValue': payload['leadValue'],
          'notes': payload['notes'],
        },
      );
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        final serverId = data['id']?.toString();
        final localId = payload['localId']?.toString();

        if (serverId != null && localId != null) {
          final leadBox = hiveService.getBox(HiveService.boxLeads);
          final localData = leadBox.get(localId);
          if (localData is Map) {
            final updatedMap = Map<String, dynamic>.from(localData);
            updatedMap['id'] = serverId;
            updatedMap['syncStatus'] = 'synced';
            await leadBox.delete(localId);
            await leadBox.put(serverId, updatedMap);
          }
        }
        return true;
      }
    } else if (item.action == SyncAction.update) {
      final id = payload['id'];
      final response = await dioClient.dio.put(
        '/crm/leads/$id',
        data: {
          'stage': payload['stage'],
        },
      );
      if (response.data != null && response.data['success'] == true) {
        final leadBox = hiveService.getBox(HiveService.boxLeads);
        final localData = leadBox.get(id);
        if (localData is Map) {
          final updatedMap = Map<String, dynamic>.from(localData);
          updatedMap['syncStatus'] = 'synced';
          await leadBox.put(id, updatedMap);
        }
        return true;
      }
    }
    return false;
  }

  Future<bool> _syncInventoryAdjust(SyncItemEntity item) async {
    final payload = item.payload;
    final response = await dioClient.dio.post(
      '/inventory/adjust',
      data: {
        'productId': payload['productId'],
        'quantityDelta': payload['quantityDelta'],
        'movementType': (payload['quantityDelta'] as num? ?? 0) >= 0 ? 'Manual Adjustment' : 'Damaged',
        'reason': payload['reason'],
      },
    );
    return response.data != null && response.data['success'] == true;
  }

  Future<void> _pullServerUpdates() async {
    try {
      // 1. Pull Customers
      final custResponse = await dioClient.dio.get(ApiEndpoints.customers);
      if (custResponse.data != null && custResponse.data['success'] == true) {
        final List list = custResponse.data['data'] ?? [];
        final custBox = hiveService.getBox(HiveService.boxCustomers);
        for (var item in list) {
          final id = item['id']?.toString();
          if (id != null) {
            final existing = custBox.get(id);
            if (existing == null || (existing is Map && existing['syncStatus'] == 'synced')) {
              await custBox.put(id, {
                'id': id,
                'name': item['name'] ?? '',
                'phone': item['phone'] ?? '',
                'email': item['email'] ?? '',
                'address': item['address'] ?? '',
                'outstandingBalance': (item['outstanding_balance'] as num?)?.toDouble() ?? 0.0,
                'totalPurchases': (item['total_purchases'] as num?)?.toDouble() ?? 0.0,
                'createdAt': item['created_at'] ?? DateTime.now().toIso8601String(),
                'syncStatus': 'synced',
              });
            }
          }
        }
      }
    } catch (_) {}

    try {
      // 2. Pull Products
      final prodResponse = await dioClient.dio.get(ApiEndpoints.products);
      if (prodResponse.data != null && prodResponse.data['success'] == true) {
        final List list = prodResponse.data['data'] ?? [];
        final prodBox = hiveService.getBox(HiveService.boxProducts);
        for (var item in list) {
          final id = item['id']?.toString();
          if (id != null) {
            final existing = prodBox.get(id);
            if (existing == null || (existing is Map && existing['syncStatus'] == 'synced')) {
              await prodBox.put(id, {
                'id': id,
                'name': item['name'] ?? '',
                'sku': item['sku'] ?? 'SKU-000',
                'category': item['category'] ?? 'General',
                'sellingPrice': (item['selling_price'] as num?)?.toDouble() ?? 0.0,
                'purchasePrice': (item['purchase_price'] as num?)?.toDouble() ?? 0.0,
                'stockQuantity': (item['current_stock'] as num?)?.toInt() ?? 0,
                'reorderLevel': (item['min_stock_level'] as num?)?.toInt() ?? 5,
                'unit': item['unit'] ?? 'Pcs',
                'createdAt': item['created_at'] ?? DateTime.now().toIso8601String(),
                'syncStatus': 'synced',
              });
            }
          }
        }
      }
    } catch (_) {}
  }

  @override
  Future<void> clearCompletedSyncItems() async {
    final box = hiveService.getBox(HiveService.boxSyncQueue);
    final List<dynamic> keysToRemove = [];
    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map && val['status'] == 'COMPLETED') {
        keysToRemove.add(key);
      }
    }
    await box.deleteAll(keysToRemove);
  }
}
