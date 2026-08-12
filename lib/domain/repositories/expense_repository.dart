import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseEntity>> getExpenses({String? category});
  Future<ExpenseEntity> createExpense(ExpenseEntity expense);
}
