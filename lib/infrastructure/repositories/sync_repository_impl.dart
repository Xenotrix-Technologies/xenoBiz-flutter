import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/entities/sync_item_entity.dart';
import '../../domain/repositories/sync_repository.dart';
import '../database/app_database.dart';
import '../network/dio_client.dart';
import '../network/network_checker.dart';

class SyncRepositoryImpl implements SyncRepository {
  final AppDatabase db;
  final DioClient dioClient;
  final NetworkChecker networkChecker;

  SyncRepositoryImpl({
    required this.db,
    required this.dioClient,
    required this.networkChecker,
  });

  SyncAction _parseAction(String actionStr) {
    if (actionStr == 'update' || actionStr == 'SyncAction.update') return SyncAction.update;
    if (actionStr == 'delete' || actionStr == 'SyncAction.delete') return SyncAction.delete;
    return SyncAction.create;
  }

  SyncItemEntity _rowToSyncItem(SyncQueueData row) {
    Map<String, dynamic> payloadMap = {};
    try {
      payloadMap = Map<String, dynamic>.from(jsonDecode(row.payload));
    } catch (_) {}

    return SyncItemEntity(
      id: row.id,
      entityType: row.entityType,
      action: _parseAction(row.action),
      payload: payloadMap,
      createdAt: row.createdAt,
      retryCount: row.retryCount,
      status: row.status,
    );
  }

  SyncQueueCompanion _syncItemToCompanion(SyncItemEntity item) {
    return SyncQueueCompanion(
      id: Value(item.id),
      entityType: Value(item.entityType),
      action: Value(item.action.name),
      payload: Value(jsonEncode(item.payload)),
      createdAt: Value(item.createdAt),
      retryCount: Value(item.retryCount),
      status: Value(item.status),
    );
  }

  @override
  Future<List<SyncItemEntity>> getPendingSyncItems() async {
    final q = db.select(db.syncQueue)
      ..where((t) => t.status.equals('PENDING') | t.status.equals('FAILED'))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    final rows = await q.get();
    return rows.map(_rowToSyncItem).toList();
  }

  @override
  Future<void> enqueueSyncItem(SyncItemEntity item) async {
    await db.into(db.syncQueue).insertOnConflictUpdate(_syncItemToCompanion(item));
  }

  @override
  Future<void> processSyncQueue() async {
    return;
  }

  @override
  Future<void> clearCompletedSyncItems() async {
    await (db.delete(db.syncQueue)..where((t) => t.status.equals('COMPLETED'))).go();
  }
}
