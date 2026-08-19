import 'package:uuid/uuid.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../storage/hive_service.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final HiveService hiveService;

  ExpenseRepositoryImpl({required this.hiveService});

  ExpenseEntity _mapToExpense(Map<dynamic, dynamic> map) {
    return ExpenseEntity(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Expense',
      category: map['category']?.toString() ?? 'OTHER',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMode: map['paymentMode']?.toString() ?? 'Cash',
      expenseDate: DateTime.tryParse(map['expenseDate']?.toString() ?? '') ??
          DateTime.now(),
      notes: map['notes']?.toString() ?? '',
    );
  }

  @override
  Future<List<ExpenseEntity>> getExpenses({String? category}) async {
    final box = hiveService.getBox(HiveService.boxExpenses);
    final List<ExpenseEntity> list = [];
    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        final exp = _mapToExpense(val);
        if (category == null ||
            category.isEmpty ||
            category == 'All' ||
            exp.category == category) {
          list.add(exp);
        }
      }
    }
    list.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
    return list;
  }

  @override
  Future<ExpenseEntity?> getExpense(String id) async {
    final box = hiveService.getBox(HiveService.boxExpenses);
    final map = box.get(id);
    if (map is Map) {
      return _mapToExpense(map);
    }
    return null;
  }

  @override
  Future<ExpenseEntity> createExpense(ExpenseEntity expense) async {
    final box = hiveService.getBox(HiveService.boxExpenses);
    final String id = expense.id.isNotEmpty ? expense.id : const Uuid().v4();
    final local = ExpenseEntity(
      id: id,
      title: expense.title,
      category: expense.category,
      amount: expense.amount,
      paymentMode: expense.paymentMode,
      expenseDate: expense.expenseDate,
      notes: expense.notes,
    );

    await box.put(id, {
      'id': local.id,
      'title': local.title,
      'category': local.category,
      'amount': local.amount,
      'paymentMode': local.paymentMode,
      'expenseDate': local.expenseDate.toIso8601String(),
      'notes': local.notes,
    });

    return local;
  }

  @override
  Future<void> updateExpense(ExpenseEntity expense) async {
    await createExpense(expense);
  }
}
