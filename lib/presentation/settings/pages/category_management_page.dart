import 'package:flutter/material.dart';
import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/ui_state_widgets.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CategoryEntity> _incomeCategories = [];
  List<CategoryEntity> _expenseCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final repo = getIt<CategoryRepository>();
      final inc = await repo.getCategories(type: CategoryType.income, activeOnly: false);
      final exp = await repo.getCategories(type: CategoryType.expense, activeOnly: false);
      if (mounted) {
        setState(() {
          _incomeCategories = inc;
          _expenseCategories = exp;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog(CategoryType type) {
    final nameCtrl = TextEditingController();
    final typeText = type == CategoryType.income ? 'Income' : 'Expense';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Add $typeText Category', style: const TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Create a new category for $typeText transactions:'),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Category Name',
                hint: 'e.g. ${type == CategoryType.income ? "Consulting" : "Software License"}',
                controller: nameCtrl,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final newCat = CategoryEntity(
                  id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  type: type,
                  isActive: true,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await getIt<CategoryRepository>().createCategory(newCat);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                _loadCategories();
              },
              child: const Text('Save Category'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(CategoryEntity category) {
    final nameCtrl = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Category', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Category Name',
                controller: nameCtrl,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final updated = category.copyWith(name: name);
                await getIt<CategoryRepository>().updateCategory(updated);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                _loadCategories();
              },
              child: const Text('Update Category'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeactivateCategory(CategoryEntity category) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Deactivate Category?', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Text(
            'Are you sure you want to deactivate "${category.name}"?\n\n'
            'It will no longer appear when creating new transactions, but all historical records will be preserved.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await getIt<CategoryRepository>().deactivateCategory(category.id);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                _loadCategories();
              },
              child: const Text('Deactivate'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Income & Expense Categories'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          tabs: const [
            Tab(text: 'Income Categories'),
            Tab(text: 'Expense Categories'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingState(message: 'Loading categories...')
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryListTab(CategoryType.income, _incomeCategories),
                _buildCategoryListTab(CategoryType.expense, _expenseCategories),
              ],
            ),
    );
  }

  Widget _buildCategoryListTab(CategoryType type, List<CategoryEntity> categories) {
    final typeText = type == CategoryType.income ? 'Income' : 'Expense';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$typeText Categories (${categories.where((c) => c.isActive).length})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _showAddCategoryDialog(type),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Category', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (categories.isEmpty)
            EmptyState(
              title: 'No $typeText categories found',
              message: 'Tap "+ Add Category" to create one.',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, idx) {
                final cat = categories[idx];
                return AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cat.isActive
                                  ? (type == CategoryType.income
                                      ? AppColors.success.withValues(alpha: 0.1)
                                      : AppColors.danger.withValues(alpha: 0.1))
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              type == CategoryType.income ? Icons.arrow_downward : Icons.arrow_upward,
                              color: cat.isActive
                                  ? (type == CategoryType.income ? AppColors.success : AppColors.danger)
                                  : Colors.grey,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: cat.isActive ? AppColors.darkBlueText : AppColors.outline,
                                ),
                              ),
                              if (!cat.isActive)
                                const Text(
                                  'Inactive (Hidden from new forms)',
                                  style: TextStyle(fontSize: 11, color: AppColors.outline),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                            onPressed: () => _showEditCategoryDialog(cat),
                          ),
                          if (cat.isActive)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                              onPressed: () => _confirmDeactivateCategory(cat),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
