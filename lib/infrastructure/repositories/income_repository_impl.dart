import '../../domain/entities/income_entity.dart';
import '../../domain/repositories/income_repository.dart';
import '../storage/hive_service.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final HiveService _hiveService;

  IncomeRepositoryImpl(this._hiveService);

  @override
  Future<void> createIncome(IncomeEntity income) async {
    final box = _hiveService.getBox(HiveService.boxIncome);
    final map = {
      'id': income.id,
      'title': income.title,
      'category': income.category,
      'amount': income.amount,
      'paymentMode': income.paymentMode,
      'incomeDate': income.incomeDate.toIso8601String(),
      'notes': income.notes,
    };
    await box.put(income.id, map);
  }

  @override
  Future<List<IncomeEntity>> getIncomes() async {
    final box = _hiveService.getBox(HiveService.boxIncome);
    final list = <IncomeEntity>[];
    for (var key in box.keys) {
      final map = box.get(key);
      if (map is Map) {
        list.add(IncomeEntity(
          id: map['id']?.toString() ?? key.toString(),
          title: map['title']?.toString() ?? '',
          category: map['category']?.toString() ?? '',
          amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
          paymentMode: map['paymentMode']?.toString() ?? 'Cash',
          incomeDate: map['incomeDate'] != null
              ? DateTime.tryParse(map['incomeDate'].toString()) ?? DateTime.now()
              : DateTime.now(),
          notes: map['notes']?.toString() ?? '',
        ));
      }
    }
    list.sort((a, b) => b.incomeDate.compareTo(a.incomeDate));
    return list;
  }

  @override
  Future<IncomeEntity?> getIncome(String id) async {
    final box = _hiveService.getBox(HiveService.boxIncome);
    final map = box.get(id);
    if (map is Map) {
      return IncomeEntity(
        id: map['id']?.toString() ?? id,
        title: map['title']?.toString() ?? '',
        category: map['category']?.toString() ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        paymentMode: map['paymentMode']?.toString() ?? 'Cash',
        incomeDate: map['incomeDate'] != null
            ? DateTime.tryParse(map['incomeDate'].toString()) ?? DateTime.now()
            : DateTime.now(),
        notes: map['notes']?.toString() ?? '',
      );
    }
    return null;
  }

  @override
  Future<void> updateIncome(IncomeEntity income) async {
    await createIncome(income);
  }

  @override
  Future<void> deleteIncome(String id) async {
    final box = _hiveService.getBox(HiveService.boxIncome);
    await box.delete(id);
  }
}
