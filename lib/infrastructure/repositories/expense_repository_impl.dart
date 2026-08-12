import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../storage/hive_service.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final HiveService hiveService;
  final List<ExpenseEntity> _expenses = [];

  ExpenseRepositoryImpl({required this.hiveService});

  @override
  Future<List<ExpenseEntity>> getExpenses({String? category}) async {
    if (category != null && category.isNotEmpty && category != 'All') {
      return _expenses.where((e) => e.category == category).toList();
    }
    return List.unmodifiable(_expenses);
  }

  @override
  Future<ExpenseEntity> createExpense(ExpenseEntity expense) async {
    _expenses.insert(0, expense);
    return expense;
  }
}
