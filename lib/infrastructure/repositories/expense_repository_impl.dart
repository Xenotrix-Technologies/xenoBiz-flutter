import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../database/app_database.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final AppDatabase db;

  ExpenseRepositoryImpl({required this.db});

  ExpenseEntity _rowToExpense(Expense row) {
    return ExpenseEntity(
      id: row.id,
      title: row.title,
      category: row.category,
      amount: row.amount,
      paymentMode: row.paymentMode,
      expenseDate: row.expenseDate,
      notes: row.notes,
    );
  }

  ExpensesCompanion _expenseToCompanion(ExpenseEntity e) {
    return ExpensesCompanion(
      id: Value(e.id),
      title: Value(e.title),
      category: Value(e.category),
      amount: Value(e.amount),
      paymentMode: Value(e.paymentMode),
      expenseDate: Value(e.expenseDate),
      notes: Value(e.notes),
    );
  }

  @override
  Future<List<ExpenseEntity>> getExpenses({String? category}) async {
    final q = db.select(db.expenses)..orderBy([(t) => OrderingTerm.desc(t.expenseDate)]);
    final rows = await q.get();

    final list = rows.map(_rowToExpense).toList();
    if (category == null || category.isEmpty || category == 'All') {
      return list;
    }
    return list.where((e) => e.category == category).toList();
  }

  @override
  Future<ExpenseEntity?> getExpense(String id) async {
    final row = await (db.select(db.expenses)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row != null) {
      return _rowToExpense(row);
    }
    return null;
  }

  @override
  Future<ExpenseEntity> createExpense(ExpenseEntity expense) async {
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

    await db.into(db.expenses).insertOnConflictUpdate(_expenseToCompanion(local));
    return local;
  }

  @override
  Future<void> updateExpense(ExpenseEntity expense) async {
    await createExpense(expense);
  }
}
