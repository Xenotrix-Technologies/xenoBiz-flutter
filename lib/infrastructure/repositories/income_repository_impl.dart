import 'package:drift/drift.dart';
import '../../domain/entities/income_entity.dart';
import '../../domain/repositories/income_repository.dart';
import '../database/app_database.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final AppDatabase db;

  IncomeRepositoryImpl(this.db);

  IncomeEntity _rowToIncome(IncomeData row) {
    return IncomeEntity(
      id: row.id,
      title: row.title,
      category: row.category,
      amount: row.amount,
      paymentMode: row.paymentMode,
      incomeDate: row.incomeDate,
      notes: row.notes,
    );
  }

  IncomeCompanion _incomeToCompanion(IncomeEntity i) {
    return IncomeCompanion(
      id: Value(i.id),
      title: Value(i.title),
      category: Value(i.category),
      amount: Value(i.amount),
      paymentMode: Value(i.paymentMode),
      incomeDate: Value(i.incomeDate),
      notes: Value(i.notes),
    );
  }

  @override
  Future<void> createIncome(IncomeEntity income) async {
    await db.into(db.income).insertOnConflictUpdate(_incomeToCompanion(income));
  }

  @override
  Future<List<IncomeEntity>> getIncomes() async {
    final q = db.select(db.income)..orderBy([(t) => OrderingTerm.desc(t.incomeDate)]);
    final rows = await q.get();
    return rows.map(_rowToIncome).toList();
  }

  @override
  Future<IncomeEntity?> getIncome(String id) async {
    final row = await (db.select(db.income)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row != null) {
      return _rowToIncome(row);
    }
    return null;
  }

  @override
  Future<void> updateIncome(IncomeEntity income) async {
    await createIncome(income);
  }

  @override
  Future<void> deleteIncome(String id) async {
    await (db.delete(db.income)..where((t) => t.id.equals(id))).go();
  }
}
