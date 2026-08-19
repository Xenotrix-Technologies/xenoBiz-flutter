import '../entities/income_entity.dart';

abstract class IncomeRepository {
  Future<void> createIncome(IncomeEntity income);
  Future<List<IncomeEntity>> getIncomes();
  Future<IncomeEntity?> getIncome(String id);
  Future<void> updateIncome(IncomeEntity income);
  Future<void> deleteIncome(String id);
}
