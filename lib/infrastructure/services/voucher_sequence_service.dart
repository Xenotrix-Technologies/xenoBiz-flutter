import 'package:get_it/get_it.dart';
import '../database/app_database.dart';

enum VoucherType {
  sale,
  salesReturn,
  purchase,
  purchaseReturn,
  payment,
  receipt,
}

class VoucherSequenceService {
  final AppDatabase db;

  VoucherSequenceService(this.db);

  static VoucherSequenceService get instance {
    if (GetIt.instance.isRegistered<VoucherSequenceService>()) {
      return GetIt.instance<VoucherSequenceService>();
    }
    final db = GetIt.instance<AppDatabase>();
    final service = VoucherSequenceService(db);
    GetIt.instance.registerSingleton<VoucherSequenceService>(service);
    return service;
  }

  static String _getPrefixKey(VoucherType type) {
    switch (type) {
      case VoucherType.sale:
        return 'prefix_sale';
      case VoucherType.salesReturn:
        return 'prefix_sales_return';
      case VoucherType.purchase:
        return 'prefix_purchase';
      case VoucherType.purchaseReturn:
        return 'prefix_purchase_return';
      case VoucherType.payment:
        return 'prefix_payment';
      case VoucherType.receipt:
        return 'prefix_receipt';
    }
  }

  static String _getSeqKey(VoucherType type) {
    switch (type) {
      case VoucherType.sale:
        return 'seq_sale';
      case VoucherType.salesReturn:
        return 'seq_sales_return';
      case VoucherType.purchase:
        return 'seq_purchase';
      case VoucherType.purchaseReturn:
        return 'seq_purchase_return';
      case VoucherType.payment:
        return 'seq_payment';
      case VoucherType.receipt:
        return 'seq_receipt';
    }
  }

  static String getDefaultPrefix(VoucherType type) {
    switch (type) {
      case VoucherType.sale:
        return 'INV';
      case VoucherType.salesReturn:
        return 'SR';
      case VoucherType.purchase:
        return 'PUR';
      case VoucherType.purchaseReturn:
        return 'PR';
      case VoucherType.payment:
        return 'PMT';
      case VoucherType.receipt:
        return 'RCT';
    }
  }

  /// Gets configured prefix for a voucher type.
  Future<String> getPrefix(VoucherType type) async {
    final key = _getPrefixKey(type);
    final val = await db.getKeyValue(key);
    if (val != null && val.trim().isNotEmpty) {
      return val.trim().toUpperCase();
    }
    return getDefaultPrefix(type);
  }

  /// Sets custom prefix for a voucher type.
  Future<void> setPrefix(VoucherType type, String prefix) async {
    final key = _getPrefixKey(type);
    await db.putKeyValue(key, prefix.trim().toUpperCase());
  }

  /// Gets current sequence number for a voucher type.
  Future<int> getCurrentSequence(VoucherType type) async {
    final key = _getSeqKey(type);
    final val = await db.getKeyValue(key);
    if (val != null) {
      final parsed = int.tryParse(val);
      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }
    return 1;
  }

  /// Generates preview formatted Voucher ID (e.g. `INV-#00-0001`).
  Future<String> generateNextVoucherId(VoucherType type) async {
    final prefix = await getPrefix(type);
    final seq = await getCurrentSequence(type);
    final padStr = seq.toString().padLeft(4, '0');
    return '$prefix-#00-$padStr';
  }

  /// Increments sequence counter after a voucher is successfully saved.
  Future<void> incrementSequence(VoucherType type) async {
    final current = await getCurrentSequence(type);
    final key = _getSeqKey(type);
    await db.putKeyValue(key, (current + 1).toString());
  }

  /// Reset sequence back to 1 if needed.
  Future<void> resetSequence(VoucherType type, {int startFrom = 1}) async {
    final key = _getSeqKey(type);
    await db.putKeyValue(key, startFrom.toString());
  }
}
