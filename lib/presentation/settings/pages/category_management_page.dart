import 'package:flutter/material.dart';
import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/ui_state_widgets.dart';

enum CategoryTypeFilter { all, income, expense }

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  CategoryTypeFilter _selectedFilter = CategoryTypeFilter.all;

  List<CategoryEntity> _incomeCategories = [];
  List<CategoryEntity> _expenseCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          title: const Text('Delete Category?', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Text(
            'Are you sure you want to delete "${category.name}"?\n\n'
            'Historical records will be preserved.',
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  List<CategoryEntity> _getFilteredCategories() {
    final List<CategoryEntity> list = [];
    if (_selectedFilter == CategoryTypeFilter.all ||
        _selectedFilter == CategoryTypeFilter.income) {
      list.addAll(_incomeCategories);
    }
    if (_selectedFilter == CategoryTypeFilter.all ||
        _selectedFilter == CategoryTypeFilter.expense) {
      list.addAll(_expenseCategories);
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      return list.where((cat) => cat.name.toLowerCase().contains(query)).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _getFilteredCategories();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Income & Expense Categories',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 1),
            Text(
              'Manage your income and expense categories',
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const CustomerListSkeleton()
          : Column(
              children: [
                // Search Bar Container
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search categories by name...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.secondaryText,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),

                // Horizontally Scrollable Filter Chips Bar (Tabs)
                _buildFilterChipsBar(),

                const Divider(height: 1, color: AppColors.border),

                // Main Category List
                Expanded(
                  child: _buildCategoryListView(filteredCategories),
                ),
              ],
            ),
    );
  }

  // HORIZONTALLY SCROLLABLE FILTER CHIPS BAR (TABS)
  Widget _buildFilterChipsBar() {
    final totalCount = _incomeCategories.length + _expenseCategories.length;
    final incomeCount = _incomeCategories.length;
    final expenseCount = _expenseCategories.length;

    final options = [
      {'type': CategoryTypeFilter.all, 'label': 'All ($totalCount)'},
      {'type': CategoryTypeFilter.income, 'label': 'Income ($incomeCount)'},
      {'type': CategoryTypeFilter.expense, 'label': 'Expense ($expenseCount)'},
    ];

    return Container(
      color: Colors.white,
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, idx) {
          final opt = options[idx];
          final fType = opt['type'] as CategoryTypeFilter;
          final isSelected = _selectedFilter == fType;

          return ChoiceChip(
            label: Text(opt['label'] as String),
            selected: isSelected,
            selectedColor: AppColors.primaryBlue,
            backgroundColor: AppColors.surfaceContainerLow,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.darkBlueText,
            ),
            onSelected: (val) {
              if (val) {
                setState(() => _selectedFilter = fType);
              }
            },
          );
        },
      ),
    );
  }

  // MAIN CATEGORY LIST VIEW
  Widget _buildCategoryListView(List<CategoryEntity> categories) {
    if (categories.isEmpty) {
      String title = 'No categories found';
      if (_selectedFilter == CategoryTypeFilter.income) {
        title = 'No income categories found';
      } else if (_selectedFilter == CategoryTypeFilter.expense) {
        title = 'No expense categories found';
      }

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.55,
          alignment: Alignment.center,
          child: EmptyState(
            title: title,
            message: 'No categories match your current search criteria.',
            icon: Icons.category_outlined,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      color: AppColors.primaryBlue,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, idx) {
          final cat = categories[idx];
          return _buildCategoryCard(cat);
        },
      ),
    );
  }

  // CATEGORY CARD ITEM
  Widget _buildCategoryCard(CategoryEntity cat) {
    final isIncome = cat.type == CategoryType.income;
    final typeLabel = isIncome ? 'Income' : 'Expense';

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Icon Container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isIncome
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? AppColors.success : AppColors.danger,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Middle Column Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isIncome
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          typeLabel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'PlusJakartaSans',
                            color: isIncome ? AppColors.success : AppColors.danger,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          cat.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'PlusJakartaSans',
                            color: AppColors.darkBlueText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    cat.isActive ? 'Active Category' : 'Inactive Category',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: cat.isActive ? AppColors.secondaryText : AppColors.outline,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Edit & Delete Action Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primaryBlue),
                  onPressed: () => _showEditCategoryDialog(cat),
                  tooltip: 'Edit Category',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                  onPressed: () => _confirmDeactivateCategory(cat),
                  tooltip: 'Delete Category',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
