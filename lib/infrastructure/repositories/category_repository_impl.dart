import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../storage/hive_service.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final HiveService _hiveService;

  CategoryRepositoryImpl(this._hiveService);

  Box get _box => _hiveService.getBox(HiveService.boxCategories);

  Future<void> _seedDefaultsIfEmpty() async {
    if (_box.isEmpty) {
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
        await _box.put(cat.id, cat.toMap());
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
        await _box.put(cat.id, cat.toMap());
      }
    }
  }

  @override
  Future<List<CategoryEntity>> getCategories({CategoryType? type, bool activeOnly = true}) async {
    await _seedDefaultsIfEmpty();
    final List<CategoryEntity> categories = [];

    for (var key in _box.keys) {
      final raw = _box.get(key);
      if (raw != null && raw is Map) {
        final cat = CategoryEntity.fromMap(Map<String, dynamic>.from(raw));
        if (type != null && cat.type != type) continue;
        if (activeOnly && !cat.isActive) continue;
        categories.add(cat);
      }
    }

    categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return categories;
  }

  @override
  Future<CategoryEntity?> getCategory(String id) async {
    await _seedDefaultsIfEmpty();
    final raw = _box.get(id);
    if (raw != null && raw is Map) {
      return CategoryEntity.fromMap(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  @override
  Future<CategoryEntity> createCategory(CategoryEntity category) async {
    await _seedDefaultsIfEmpty();
    final map = category.toMap();
    await _box.put(category.id, map);
    return category;
  }

  @override
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    await _seedDefaultsIfEmpty();
    final updated = category.copyWith(updatedAt: DateTime.now());
    await _box.put(updated.id, updated.toMap());
    return updated;
  }

  @override
  Future<void> deactivateCategory(String id) async {
    await _seedDefaultsIfEmpty();
    final cat = await getCategory(id);
    if (cat != null) {
      final deactivated = cat.copyWith(isActive: false, updatedAt: DateTime.now());
      await _box.put(deactivated.id, deactivated.toMap());
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _seedDefaultsIfEmpty();
    await _box.delete(id);
  }
}
