import 'package:drift/drift.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../database/app_database.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase db;

  CategoryRepositoryImpl(this.db);

  CategoryEntity _rowToCategory(Category row) {
    final type = row.type == 'income' ? CategoryType.income : CategoryType.expense;
    return CategoryEntity(
      id: row.id,
      name: row.name,
      type: type,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt ?? row.createdAt,
    );
  }

  CategoriesCompanion _categoryToCompanion(CategoryEntity c) {
    return CategoriesCompanion(
      id: Value(c.id),
      name: Value(c.name),
      type: Value(c.type.name),
      isActive: Value(c.isActive),
      createdAt: Value(c.createdAt),
      updatedAt: Value(c.updatedAt),
    );
  }

  Future<void> _seedDefaultsIfEmpty() async {
    final count = await db.select(db.categories).get();
    if (count.isEmpty) {
      final now = DateTime.now();
      final defaultIncomeCategories = [
        'Other Income',
        'Commission',
        'Service Income',
        'Interest',
        'Miscellaneous',
      ];

      for (var i = 0; i < defaultIncomeCategories.length; i++) {
        final cat = CategoryEntity(
          id: 'cat_inc_$i',
          name: defaultIncomeCategories[i],
          type: CategoryType.income,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );
        await db.into(db.categories).insertOnConflictUpdate(_categoryToCompanion(cat));
      }

      final defaultExpenseCategories = [
        'Rent',
        'Utilities',
        'Salary',
        'Transport',
        'Fuel',
        'Repairs',
        'Other Expense',
      ];

      for (var i = 0; i < defaultExpenseCategories.length; i++) {
        final cat = CategoryEntity(
          id: 'cat_exp_$i',
          name: defaultExpenseCategories[i],
          type: CategoryType.expense,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );
        await db.into(db.categories).insertOnConflictUpdate(_categoryToCompanion(cat));
      }
    }
  }

  @override
  Future<List<CategoryEntity>> getCategories({CategoryType? type, bool activeOnly = true}) async {
    await _seedDefaultsIfEmpty();
    final rows = await db.select(db.categories).get();
    final categories = rows.map(_rowToCategory).toList();

    List<CategoryEntity> filtered = categories;
    if (type != null) {
      filtered = filtered.where((c) => c.type == type).toList();
    }
    if (activeOnly) {
      filtered = filtered.where((c) => c.isActive).toList();
    }

    filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return filtered;
  }

  @override
  Future<CategoryEntity?> getCategory(String id) async {
    await _seedDefaultsIfEmpty();
    final row = await (db.select(db.categories)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row != null) {
      return _rowToCategory(row);
    }
    return null;
  }

  @override
  Future<CategoryEntity> createCategory(CategoryEntity category) async {
    await _seedDefaultsIfEmpty();
    await db.into(db.categories).insertOnConflictUpdate(_categoryToCompanion(category));
    return category;
  }

  @override
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    await _seedDefaultsIfEmpty();
    final updated = category.copyWith(updatedAt: DateTime.now());
    await db.into(db.categories).insertOnConflictUpdate(_categoryToCompanion(updated));
    return updated;
  }

  @override
  Future<void> deactivateCategory(String id) async {
    await _seedDefaultsIfEmpty();
    final cat = await getCategory(id);
    if (cat != null) {
      final deactivated = cat.copyWith(isActive: false, updatedAt: DateTime.now());
      await db.into(db.categories).insertOnConflictUpdate(_categoryToCompanion(deactivated));
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _seedDefaultsIfEmpty();
    await (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
  }
}
