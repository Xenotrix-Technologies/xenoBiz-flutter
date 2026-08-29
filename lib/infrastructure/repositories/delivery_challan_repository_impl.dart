import 'dart:convert';
import '../../domain/entities/delivery_challan_entity.dart';
import '../../domain/repositories/delivery_challan_repository.dart';
import '../database/app_database.dart';

class DeliveryChallanRepositoryImpl implements DeliveryChallanRepository {
  final AppDatabase db;

  DeliveryChallanRepositoryImpl({required this.db});

  static const String _prefix = 'tbl_dc_';

  @override
  Future<List<DeliveryChallanEntity>> getDeliveryChallans({
    DeliveryChallanStatus? status,
    String? query,
  }) async {
    final List<DeliveryChallanEntity> list = [];
    final rows = await db.select(db.appKeyValueStore).get();
    final dcRows = rows.where((r) => r.key.startsWith(_prefix));

    for (var row in dcRows) {
      try {
        final jsonMap = jsonDecode(row.value) as Map<String, dynamic>;
        list.add(DeliveryChallanEntity.fromJson(jsonMap));
      } catch (_) {}
    }

    list.sort((a, b) => b.issueDate.compareTo(a.issueDate));

    List<DeliveryChallanEntity> filtered = list;
    if (status != null) {
      filtered = filtered.where((c) => c.status == status).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered.where((c) {
        return c.challanNumber.toLowerCase().contains(q) ||
            c.customerName.toLowerCase().contains(q) ||
            c.customerPhone.toLowerCase().contains(q);
      }).toList();
    }
    return filtered;
  }

  @override
  Future<DeliveryChallanEntity?> getDeliveryChallan(String id) async {
    final val = await db.getKeyValue('$_prefix$id');
    if (val != null) {
      try {
        final jsonMap = jsonDecode(val) as Map<String, dynamic>;
        return DeliveryChallanEntity.fromJson(jsonMap);
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<DeliveryChallanEntity> createDeliveryChallan(DeliveryChallanEntity challan) async {
    final jsonStr = jsonEncode(challan.toJson());
    await db.putKeyValue('$_prefix${challan.id}', jsonStr);
    return challan;
  }

  @override
  Future<DeliveryChallanEntity> updateDeliveryChallan(DeliveryChallanEntity challan) async {
    final jsonStr = jsonEncode(challan.toJson());
    await db.putKeyValue('$_prefix${challan.id}', jsonStr);
    return challan;
  }

  @override
  Future<void> deleteDeliveryChallan(String id) async {
    await db.deleteKeyValue('$_prefix$id');
  }
}
