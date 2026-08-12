import '../entities/sync_item_entity.dart';

abstract class SyncRepository {
  Future<List<SyncItemEntity>> getPendingSyncItems();
  Future<void> enqueueSyncItem(SyncItemEntity item);
  Future<void> processSyncQueue();
  Future<void> clearCompletedSyncItems();
}
