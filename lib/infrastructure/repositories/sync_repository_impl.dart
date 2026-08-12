import '../../domain/entities/sync_item_entity.dart';
import '../../domain/repositories/sync_repository.dart';
import '../storage/hive_service.dart';

class SyncRepositoryImpl implements SyncRepository {
  final HiveService hiveService;
  final List<SyncItemEntity> _queue = [];

  SyncRepositoryImpl({required this.hiveService});

  @override
  Future<List<SyncItemEntity>> getPendingSyncItems() async {
    return _queue.where((i) => i.status == 'PENDING' || i.status == 'FAILED').toList();
  }

  @override
  Future<void> enqueueSyncItem(SyncItemEntity item) async {
    _queue.insert(0, item);
  }

  @override
  Future<void> processSyncQueue() async {
    for (int i = 0; i < _queue.length; i++) {
      if (_queue[i].status == 'PENDING' || _queue[i].status == 'FAILED') {
        _queue[i] = SyncItemEntity(
          id: _queue[i].id,
          entityType: _queue[i].entityType,
          action: _queue[i].action,
          payload: _queue[i].payload,
          createdAt: _queue[i].createdAt,
          retryCount: _queue[i].retryCount + 1,
          status: 'COMPLETED',
        );
      }
    }
  }

  @override
  Future<void> clearCompletedSyncItems() async {
    _queue.removeWhere((i) => i.status == 'COMPLETED');
  }
}
