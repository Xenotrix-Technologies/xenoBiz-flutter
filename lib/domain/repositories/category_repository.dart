import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories({CategoryType? type, bool activeOnly = true});
  Future<CategoryEntity?> getCategory(String id);
  Future<CategoryEntity> createCategory(CategoryEntity category);
  Future<CategoryEntity> updateCategory(CategoryEntity category);
  Future<void> deactivateCategory(String id);
  Future<void> deleteCategory(String id);
}
