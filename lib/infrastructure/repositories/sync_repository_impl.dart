import '../../domain/entities/sync_item_entity.dart';
import '../../domain/repositories/sync_repository.dart';
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
    // Cloud sync for business data is disabled in Local-First mode.
    // Business data is managed locally on device in Hive.
    return;
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
