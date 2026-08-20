import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/entities/income_entity.dart';
import '../../../domain/entities/purchase_entity.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../domain/repositories/customer_repository.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../../domain/repositories/income_repository.dart';
import '../../../domain/repositories/purchase_repository.dart';
import '../../widgets/app_button.dart';

enum TransactionType { income, expense }

class TransactionScreen extends StatefulWidget {
  final TransactionType transactionType;
  final dynamic existingTransaction;

  const TransactionScreen({
    super.key,
    required this.transactionType,
    this.existingTransaction,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  bool get isEditMode => widget.existingTransaction != null;
  bool get isExpense => widget.transactionType == TransactionType.expense;

  late TextEditingController _amountCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _partySearchCtrl;
  late DateTime _selectedDate;
  late String _selectedPaymentMethod;

  List<CategoryEntity> _categories = [];
  CategoryEntity? _selectedCategory;
  String? _selectedCategoryId;
  String _customCategoryName = '';

  // Optional Account / Party Selection
  List<dynamic> _allParties = [];
  List<dynamic> _filteredParties = [];
  dynamic _selectedParty; // CustomerEntity or SupplierEntity
  bool _showPartyOverlay = false;
  bool _isLoadingCategories = true;
  bool _isSaving = false;

  static const List<Map<String, dynamic>> _paymentMethods = [
    {'label': 'Cash', 'icon': Icons.crop_square_rounded},
    {'label': 'UPI', 'icon': Icons.crop_square_rounded},
    {'label': 'Bank', 'icon': Icons.keyboard_arrow_up_rounded},
    {'label': 'Other', 'icon': Icons.circle_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    _partySearchCtrl = TextEditingController();
    _selectedDate = DateTime.now();
    _selectedPaymentMethod = 'Cash';

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingCategories = true);
    try {
      final categoryRepo = getIt<CategoryRepository>();
      final cats = await categoryRepo.getCategories(
        type: isExpense ? CategoryType.expense : CategoryType.income,
        activeOnly: true,
      );

      // Load Customers (for Income) or Suppliers (for Expense)
      if (isExpense) {
        try {
          final suppliers = await getIt<PurchaseRepository>().getSuppliers();
          _allParties = suppliers;
        } catch (_) {}
      } else {
        try {
          final customers = await getIt<CustomerRepository>().getCustomers();
          _allParties = customers;
        } catch (_) {}
      }

      _categories = cats;

      if (isEditMode) {
        _populateData();
      } else if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
        _selectedCategoryId = _selectedCategory!.id;
        _customCategoryName = _selectedCategory!.name;
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoadingCategories = false);
    }
  }

  void _populateData() {
    final tx = widget.existingTransaction;
    String txCatName = '';
    String? txCatId;
    String? txPartyId;
    String? txPartyName;

    if (tx is ExpenseEntity) {
      _amountCtrl.text = tx.amount > 0 ? tx.amount.toStringAsFixed(0) : '';
      _descriptionCtrl.text = tx.notes.isNotEmpty ? tx.notes : tx.title;
      _selectedDate = tx.expenseDate;
      _selectedPaymentMethod = tx.paymentMode.isNotEmpty ? tx.paymentMode : 'Cash';
      txCatName = tx.category;
      txCatId = tx.categoryId;
      txPartyId = tx.partyId;
      txPartyName = tx.partyName;
    } else if (tx is IncomeEntity) {
      _amountCtrl.text = tx.amount > 0 ? tx.amount.toStringAsFixed(0) : '';
      _descriptionCtrl.text = tx.notes.isNotEmpty ? tx.notes : tx.title;
      _selectedDate = tx.incomeDate;
      _selectedPaymentMethod = tx.paymentMode.isNotEmpty ? tx.paymentMode : 'Cash';
      txCatName = tx.category;
      txCatId = tx.categoryId;
      txPartyId = tx.partyId;
      txPartyName = tx.partyName;
    }

    _customCategoryName = txCatName;
    _selectedCategoryId = txCatId;

    // Match category in loaded categories or create fallback item if inactive
    final match = _categories.firstWhere(
      (c) => (txCatId != null && c.id == txCatId) || c.name.toLowerCase() == txCatName.toLowerCase(),
      orElse: () {
        final fallback = CategoryEntity(
          id: txCatId ?? 'cat_legacy_${DateTime.now().millisecondsSinceEpoch}',
          name: txCatName.isNotEmpty ? txCatName : (isExpense ? 'Other Expense' : 'Other Income'),
          type: isExpense ? CategoryType.expense : CategoryType.income,
          isActive: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _categories.add(fallback);
        return fallback;
      },
    );

    _selectedCategory = match;
    _selectedCategoryId = match.id;
    _customCategoryName = match.name;

    // Resolve selected party if present
    if (txPartyId != null && txPartyId.isNotEmpty) {
      for (var party in _allParties) {
        final partyId = party is CustomerEntity ? party.id : (party is SupplierEntity ? party.id : '');
        if (partyId == txPartyId) {
          _selectedParty = party;
          break;
        }
      }
      if (_selectedParty == null && txPartyName != null && txPartyName.isNotEmpty) {
        _selectedParty = isExpense
            ? SupplierEntity(id: txPartyId, name: txPartyName, companyName: txPartyName, email: '', phone: '', address: '', createdAt: DateTime.now())
            : CustomerEntity(id: txPartyId, name: txPartyName, phone: '', email: '', address: '', createdAt: DateTime.now());
      }
    }
  }

  void _onSearchParty(String q) {
    if (q.trim().isEmpty) {
      setState(() {
        _filteredParties = [];
        _showPartyOverlay = false;
      });
      return;
    }

    final query = q.trim().toLowerCase();
    final results = _allParties.where((party) {
      final name = party is CustomerEntity
          ? party.name
          : (party is SupplierEntity ? party.name : '');
      final phone = party is CustomerEntity
          ? party.phone
          : (party is SupplierEntity ? party.phone : '');
      return name.toLowerCase().contains(query) || phone.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _filteredParties = results;
      _showPartyOverlay = true;
    });
  }

  void _selectParty(dynamic party) {
    setState(() {
      _selectedParty = party;
      _showPartyOverlay = false;
      _partySearchCtrl.clear();
    });
  }

  void _clearSelectedParty() {
    setState(() {
      _selectedParty = null;
      _partySearchCtrl.clear();
      _showPartyOverlay = false;
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    _partySearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    final rawAmount = _amountCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final amount = double.tryParse(rawAmount) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSaving = true);

    final catName = _selectedCategory?.name ?? (_customCategoryName.isNotEmpty ? _customCategoryName : (isExpense ? 'Other Expense' : 'Other Income'));
    final catId = _selectedCategory?.id ?? _selectedCategoryId;

    final partyId = _selectedParty != null
        ? (_selectedParty is CustomerEntity
            ? (_selectedParty as CustomerEntity).id
            : (_selectedParty as SupplierEntity).id)
        : null;

    final partyName = _selectedParty != null
        ? (_selectedParty is CustomerEntity
            ? (_selectedParty as CustomerEntity).name
            : (_selectedParty as SupplierEntity).name)
        : null;

    try {
      if (isExpense) {
        final existing = widget.existingTransaction as ExpenseEntity?;
        final expense = ExpenseEntity(
          id: isEditMode && existing != null ? existing.id : 'exp_${DateTime.now().millisecondsSinceEpoch}',
          title: _descriptionCtrl.text.trim().isNotEmpty ? _descriptionCtrl.text.trim() : catName,
          category: catName,
          categoryId: catId,
          amount: amount,
          paymentMode: _selectedPaymentMethod,
          expenseDate: _selectedDate,
          notes: _descriptionCtrl.text.trim(),
          partyId: partyId,
          partyName: partyName,
        );

        if (isEditMode) {
          await getIt<ExpenseRepository>().updateExpense(expense);
        } else {
          await getIt<ExpenseRepository>().createExpense(expense);
        }
      } else {
        final existing = widget.existingTransaction as IncomeEntity?;
        final income = IncomeEntity(
          id: isEditMode && existing != null ? existing.id : 'inc_${DateTime.now().millisecondsSinceEpoch}',
          title: _descriptionCtrl.text.trim().isNotEmpty ? _descriptionCtrl.text.trim() : catName,
          category: catName,
          categoryId: catId,
          amount: amount,
          paymentMode: _selectedPaymentMethod,
          incomeDate: _selectedDate,
          notes: _descriptionCtrl.text.trim(),
          partyId: partyId,
          partyName: partyName,
        );

        if (isEditMode) {
          await getIt<IncomeRepository>().updateIncome(income);
        } else {
          await getIt<IncomeRepository>().createIncome(income);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isExpense ? "Expense" : "Income"} ${isEditMode ? "updated" : "saved"} successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isExpense ? 'Expense' : 'Income';
    final amountLabel = isExpense ? 'EXPENSE AMOUNT' : 'INCOME AMOUNT';
    final partyLabel = isExpense ? 'Supplier / Account' : 'Customer / Account';
    final partyHint = isExpense ? 'Search supplier name or phone' : 'Search customer name or phone';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit $title' : title),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION 1: AMOUNT HEADER
            const Text(
              'AMOUNT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryText,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            // LARGE AMOUNT DISPLAY / CARD (Matches Reference Image)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: isExpense ? const Color(0xFFFFF1F2) : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isExpense ? const Color(0xFFFECDD3) : const Color(0xFFBBF7D0),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    amountLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isExpense ? const Color(0xFFE11D48) : const Color(0xFF16A34A),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: isExpense ? const Color(0xFFE11D48) : const Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: isExpense ? const Color(0xFFE11D48) : const Color(0xFF16A34A),
                          ),
                          decoration: const InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.black26),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SECTION 2: CUSTOMER / SUPPLIER SELECTION (Optional)
            Row(
              children: [
                Text(
                  partyLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlueText,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '(Optional)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            if (_selectedParty != null) ...[
              // Selected Party Card with Clear Button (X)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.blueTint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        (_selectedParty is CustomerEntity
                                ? (_selectedParty as CustomerEntity).name
                                : (_selectedParty as SupplierEntity).name)[0]
                            .toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedParty is CustomerEntity
                                ? (_selectedParty as CustomerEntity).name
                                : (_selectedParty as SupplierEntity).name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.darkBlueText,
                            ),
                          ),
                          Text(
                            _selectedParty is CustomerEntity
                                ? ((_selectedParty as CustomerEntity).phone.isNotEmpty
                                    ? (_selectedParty as CustomerEntity).phone
                                    : 'Customer Account')
                                : ((_selectedParty as SupplierEntity).phone.isNotEmpty
                                    ? (_selectedParty as SupplierEntity).phone
                                    : 'Supplier Account'),
                            style: const TextStyle(fontSize: 12, color: AppColors.outline),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.outline, size: 20),
                      onPressed: _clearSelectedParty,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Search Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _partySearchCtrl,
                  onChanged: _onSearchParty,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlueText),
                  decoration: InputDecoration(
                    hintText: partyHint,
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.outline, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),
              if (_showPartyOverlay && _filteredParties.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _filteredParties.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, idx) {
                      final item = _filteredParties[idx];
                      final name = item is CustomerEntity ? item.name : (item as SupplierEntity).name;
                      final phone = item is CustomerEntity ? item.phone : (item as SupplierEntity).phone;

                      return ListTile(
                        dense: true,
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: phone.isNotEmpty ? Text(phone, style: const TextStyle(fontSize: 12)) : null,
                        onTap: () => _selectParty(item),
                      );
                    },
                  ),
                ),
              ],
            ],
            const SizedBox(height: 20),

            // SECTION 3: DYNAMIC CATEGORY SELECTOR
            Text(
              isExpense ? 'Expense Category' : 'Income Category',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CategoryEntity>(
                  value: _selectedCategory != null && _categories.contains(_selectedCategory)
                      ? _selectedCategory
                      : (_categories.isNotEmpty ? _categories.first : null),
                  isExpanded: true,
                  hint: Text(_isLoadingCategories ? 'Loading categories...' : 'Select Category'),
                  items: _categories.map((cat) {
                    return DropdownMenuItem<CategoryEntity>(
                      value: cat,
                      child: Row(
                        children: [
                          Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (!cat.isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Inactive', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                        _selectedCategoryId = val.id;
                        _customCategoryName = val.name;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // SECTION 4: DATE (Matches Reference Image)
            const Text(
              'Date',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  DateFormat('dd MMM yyyy').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlueText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // SECTION 5: DESCRIPTION (Matches Reference Image)
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _descriptionCtrl,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.darkBlueText),
                decoration: InputDecoration(
                  hintText: isExpense ? 'e.g. August shop rent — MG Road' : 'e.g. Service payment received',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // SECTION 6: PAYMENT METHOD (Matches Reference Image)
            const Text(
              'PAYMENT METHOD',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryText,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: _paymentMethods.map((pm) {
                final label = pm['label'] as String;
                final icon = pm['icon'] as IconData;
                final isSelected = _selectedPaymentMethod == label;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedPaymentMethod = label),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE0F2FE) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF38BDF8) : Colors.grey.shade300,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFBAE6FD) : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(icon, size: 18, color: isSelected ? const Color(0xFF0284C7) : AppColors.secondaryText),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? const Color(0xFF0369A1) : AppColors.darkBlueText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // SAVE / UPDATE BUTTON
            AppButton(
              text: isEditMode
                  ? (isExpense ? 'Update Expense' : 'Update Income')
                  : (isExpense ? 'Save Expense' : 'Save Income'),
              onPressed: _submit,
              isLoading: _isSaving,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
