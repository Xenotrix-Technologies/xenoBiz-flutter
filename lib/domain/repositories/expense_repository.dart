import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseEntity>> getExpenses({String? category});
  Future<ExpenseEntity?> getExpense(String id);
  Future<ExpenseEntity> createExpense(ExpenseEntity expense);
  Future<void> updateExpense(ExpenseEntity expense);
}
