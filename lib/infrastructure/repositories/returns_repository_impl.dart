import 'package:uuid/uuid.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/invoice_return_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../domain/repositories/returns_repository.dart';
import '../storage/hive_service.dart';

class ReturnsRepositoryImpl implements ReturnsRepository {
  final HiveService hiveService;
  final ProductRepository productRepository;
  final CustomerRepository customerRepository;
  final PurchaseRepository purchaseRepository;

  ReturnsRepositoryImpl({
    required this.hiveService,
    required this.productRepository,
    required this.customerRepository,
    required this.purchaseRepository,
  });

  String _getBoxName(InvoiceType type) {
    return type == InvoiceType.sale
        ? HiveService.boxSalesReturns
        : HiveService.boxPurchaseReturns;
  }

  Map<String, dynamic> _returnToMap(InvoiceReturnEntity r) {
    return {
      'id': r.id,
      'returnNumber': r.returnNumber,
      'invoiceId': r.invoiceId,
      'invoiceNumber': r.invoiceNumber,
      'partyId': r.partyId,
      'partyName': r.partyName,
      'type': r.type.name,
      'items': r.items
          .map((i) => {
                'productId': i.productId,
                'productName': i.productName,
                'sku': i.sku,
                'originalQuantity': i.originalQuantity,
                'returnedQuantity': i.returnedQuantity,
                'unitPrice': i.unitPrice,
              })
          .toList(),
      'totalAmount': r.totalAmount,
      'returnDate': r.returnDate.toIso8601String(),
      'notes': r.notes,
    };
  }

  InvoiceReturnEntity _mapToReturn(Map<dynamic, dynamic> map) {
    final List rawItems = map['items'] is List ? map['items'] : [];
    final items = rawItems.map((itm) {
      if (itm is Map) {
        return InvoiceReturnItemEntity(
          productId: itm['productId']?.toString() ?? '',
          productName: itm['productName']?.toString() ?? 'Item',
          sku: itm['sku']?.toString() ?? '',
          originalQuantity: (itm['originalQuantity'] as num?)?.toInt() ?? 0,
          returnedQuantity: (itm['returnedQuantity'] as num?)?.toInt() ?? 0,
          unitPrice: (itm['unitPrice'] as num?)?.toDouble() ?? 0.0,
        );
      }
      return const InvoiceReturnItemEntity(
        productId: '',
        productName: '',
        originalQuantity: 0,
        returnedQuantity: 0,
        unitPrice: 0.0,
      );
    }).toList();

    final typeStr = map['type']?.toString();
    final type = typeStr == 'purchase' ? InvoiceType.purchase : InvoiceType.sale;

    return InvoiceReturnEntity(
      id: map['id']?.toString() ?? '',
      returnNumber: map['returnNumber']?.toString() ?? 'RET-000',
      invoiceId: map['invoiceId']?.toString() ?? '',
      invoiceNumber: map['invoiceNumber']?.toString() ?? '',
      partyId: map['partyId']?.toString() ?? '',
      partyName: map['partyName']?.toString() ?? 'Party',
      type: type,
      items: items,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      returnDate: DateTime.tryParse(map['returnDate']?.toString() ?? '') ?? DateTime.now(),
      notes: map['notes']?.toString() ?? '',
    );
  }

  @override
  Future<List<InvoiceReturnEntity>> getReturns(InvoiceType type) async {
    final box = hiveService.getBox(_getBoxName(type));
    final List<InvoiceReturnEntity> list = [];
    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        list.add(_mapToReturn(val));
      }
    }
    list.sort((a, b) => b.returnDate.compareTo(a.returnDate));
    return list;
  }

  @override
  Future<Map<String, int>> getReturnedQuantitiesForInvoice(String invoiceId) async {
    final Map<String, int> returnedCounts = {};
    for (var type in [InvoiceType.sale, InvoiceType.purchase]) {
      final box = hiveService.getBox(_getBoxName(type));
      for (var key in box.keys) {
        final val = box.get(key);
        if (val is Map && val['invoiceId'] == invoiceId) {
          final ret = _mapToReturn(val);
          for (var item in ret.items) {
            returnedCounts[item.productId] =
                (returnedCounts[item.productId] ?? 0) + item.returnedQuantity;
          }
        }
      }
    }
    return returnedCounts;
  }

  @override
  Future<InvoiceReturnEntity> createReturn(InvoiceReturnEntity returnEntity) async {
    final box = hiveService.getBox(_getBoxName(returnEntity.type));
    final String id = returnEntity.id.isNotEmpty ? returnEntity.id : const Uuid().v4();
    final String retNum = returnEntity.returnNumber.isNotEmpty && returnEntity.returnNumber != 'RET-000'
        ? returnEntity.returnNumber
        : 'RET-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final localReturn = InvoiceReturnEntity(
      id: id,
      returnNumber: retNum,
      invoiceId: returnEntity.invoiceId,
      invoiceNumber: returnEntity.invoiceNumber,
      partyId: returnEntity.partyId,
      partyName: returnEntity.partyName,
      type: returnEntity.type,
      items: returnEntity.items,
      totalAmount: returnEntity.totalAmount,
      returnDate: returnEntity.returnDate,
      notes: returnEntity.notes,
    );

    // 1. Save Return Record
    await box.put(id, _returnToMap(localReturn));

    // 2. Adjust Stock
    for (var item in localReturn.items) {
      if (item.returnedQuantity > 0) {
        final stockDelta = returnEntity.isSale
            ? item.returnedQuantity // Sales return -> item added back to stock
            : -item.returnedQuantity; // Purchase return -> item removed from stock

        await productRepository.adjustStock(
          item.productId,
          stockDelta,
          'Return #${localReturn.returnNumber} (${localReturn.invoiceNumber})',
        );
      }
    }

    // 3. Adjust Account Balance
    if (localReturn.partyId.isNotEmpty) {
      if (localReturn.isSale) {
        try {
          final customer = await customerRepository.getCustomer(localReturn.partyId);
          final updated = customer.copyWith(
            outstandingBalance: (customer.outstandingBalance - localReturn.totalAmount).clamp(0, double.infinity),
          );
          await customerRepository.updateCustomer(updated);
        } catch (_) {}
      } else {
        try {
          final suppliers = await purchaseRepository.getSuppliers();
          final matches = suppliers.where((s) => s.id == localReturn.partyId || s.name == localReturn.partyName);
          if (matches.isNotEmpty) {
            final sup = matches.first;
            final updated = sup.copyWith(
              payableBalance: (sup.payableBalance - localReturn.totalAmount).clamp(0, double.infinity),
            );
            await purchaseRepository.updateSupplier(updated);
          }
        } catch (_) {}
      }
    }

    return localReturn;
  }
}
