import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/accounts_bloc.dart';
import '../../../application/bloc/product_bloc.dart';
import '../../../application/bloc/purchase_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/purchase_entity.dart';
import '../../widgets/app_card.dart';

class CreateMasterPage extends StatefulWidget {
  final int initialTabIndex; // 0 = Product, 1 = Sale, 2 = Purchase, 3 = Expense, 4 = AccountChooser

  const CreateMasterPage({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<CreateMasterPage> createState() => _CreateMasterPageState();
}

class _CreateMasterPageState extends State<CreateMasterPage> {
  late int _activeTab; // 0 = Product, 1 = Sale, 2 = Purchase, 3 = Expense, 4 = AccountChooser

  // Product Form Controllers
  final _prodNameCtrl = TextEditingController();
  final _prodSkuCtrl = TextEditingController();
  final _prodCategoryCtrl = TextEditingController(text: 'Grocery');
  final _prodPurchasePriceCtrl = TextEditingController(text: '0.00');
  final _prodSellingPriceCtrl = TextEditingController(text: '0.00');
  final _prodStockCtrl = TextEditingController(text: '0');
  final _prodLowStockCtrl = TextEditingController(text: '10');
  final _prodDescCtrl = TextEditingController();
  String? _prodImagePath;

  // Sale Account Form Controllers
  final _saleNameCtrl = TextEditingController();
  final _salePhoneCtrl = TextEditingController();
  final _saleEmailCtrl = TextEditingController();
  final _saleAddressCtrl = TextEditingController();
  final _saleOpeningBalanceCtrl = TextEditingController(text: '0.00');
  final _saleNotesCtrl = TextEditingController();

  // Purchase Account Form Controllers
  final _purNameCtrl = TextEditingController();
  final _purPhoneCtrl = TextEditingController();
  final _purEmailCtrl = TextEditingController();
  final _purAddressCtrl = TextEditingController();
  final _purOpeningBalanceCtrl = TextEditingController(text: '0.00');
  final _purNotesCtrl = TextEditingController();

  // Expense Account Form Controllers
  final _expNameCtrl = TextEditingController();
  String _expCategory = 'Rent';
  final _expDescCtrl = TextEditingController();
  final _expOpeningBalanceCtrl = TextEditingController(text: '0.00');
  final List<String> _expenseCategories = ['Utilities', 'Rent', 'Salary', 'Transport', 'Fuel', 'Custom +'];

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTabIndex;
  }

  @override
  void dispose() {
    _prodNameCtrl.dispose();
    _prodSkuCtrl.dispose();
    _prodCategoryCtrl.dispose();
    _prodPurchasePriceCtrl.dispose();
    _prodSellingPriceCtrl.dispose();
    _prodStockCtrl.dispose();
    _prodLowStockCtrl.dispose();
    _prodDescCtrl.dispose();

    _saleNameCtrl.dispose();
    _salePhoneCtrl.dispose();
    _saleEmailCtrl.dispose();
    _saleAddressCtrl.dispose();
    _saleOpeningBalanceCtrl.dispose();
    _saleNotesCtrl.dispose();

    _purNameCtrl.dispose();
    _purPhoneCtrl.dispose();
    _purEmailCtrl.dispose();
    _purAddressCtrl.dispose();
    _purOpeningBalanceCtrl.dispose();
    _purNotesCtrl.dispose();

    _expNameCtrl.dispose();
    _expDescCtrl.dispose();
    _expOpeningBalanceCtrl.dispose();
    super.dispose();
  }

  void _saveCurrentForm() {
    if (_activeTab == 0) {
      _saveProduct();
    } else if (_activeTab == 1) {
      _saveSaleAccount();
    } else if (_activeTab == 2) {
      _savePurchaseAccount();
    } else if (_activeTab == 3) {
      _saveExpenseAccount();
    }
  }

  void _saveProduct() {
    final name = _prodNameCtrl.text.trim();
    if (name.isEmpty) {
      _showErrorSnackBar('Please enter product name');
      return;
    }
    final sellingPrice = double.tryParse(_prodSellingPriceCtrl.text.trim()) ?? 0.0;
    if (sellingPrice <= 0) {
      _showErrorSnackBar('Please enter a valid selling price');
      return;
    }
    final purchasePrice = double.tryParse(_prodPurchasePriceCtrl.text.trim()) ?? 0.0;
    final stock = int.tryParse(_prodStockCtrl.text.trim()) ?? 0;
    final lowStock = int.tryParse(_prodLowStockCtrl.text.trim()) ?? 10;
    final category = _prodCategoryCtrl.text.trim().isNotEmpty ? _prodCategoryCtrl.text.trim() : 'Grocery';
    final sku = _prodSkuCtrl.text.trim().isNotEmpty
        ? _prodSkuCtrl.text.trim()
        : 'SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final product = ProductEntity(
      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      sku: sku,
      barcode: sku,
      category: category,
      sellingPrice: sellingPrice,
      purchasePrice: purchasePrice,
      stockQuantity: stock,
      reorderLevel: lowStock,
      unit: 'Pcs',
      description: _prodDescCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    context.read<ProductBloc>().add(CreateProductEvent(product));
    _showSuccessSnackBar('Product "${product.name}" created successfully!');
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.stockManagement);
    }
  }

  void _saveSaleAccount() {
    final name = _saleNameCtrl.text.trim();
    if (name.isEmpty) {
      _showErrorSnackBar('Please enter customer name');
      return;
    }
    final balance = double.tryParse(_saleOpeningBalanceCtrl.text.trim()) ?? 0.0;

    final customer = CustomerEntity(
      id: 'CUST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      name: name,
      phone: _salePhoneCtrl.text.trim(),
      email: _saleEmailCtrl.text.trim(),
      address: _saleAddressCtrl.text.trim(),
      outstandingBalance: balance,
      createdAt: DateTime.now(),
    );

    context.read<AccountsBloc>().add(CreateCustomerAccountEvent(customer));
    _showSuccessSnackBar('Sale Account for "${customer.name}" created successfully!');
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.accounts);
    }
  }

  void _savePurchaseAccount() {
    final name = _purNameCtrl.text.trim();
    if (name.isEmpty) {
      _showErrorSnackBar('Please enter supplier name');
      return;
    }
    final balance = double.tryParse(_purOpeningBalanceCtrl.text.trim()) ?? 0.0;

    final supplier = SupplierEntity(
      id: 'sup_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      companyName: name,
      phone: _purPhoneCtrl.text.trim(),
      email: _purEmailCtrl.text.trim(),
      address: _purAddressCtrl.text.trim(),
      payableBalance: balance,
      createdAt: DateTime.now(),
    );

    context.read<PurchaseBloc>().add(CreateSupplierSubmittedEvent(supplier));
    _showSuccessSnackBar('Purchase Account for "${supplier.name}" created successfully!');
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.accounts);
    }
  }

  void _saveExpenseAccount() {
    final name = _expNameCtrl.text.trim();
    if (name.isEmpty) {
      _showErrorSnackBar('Please enter account name');
      return;
    }
    final balance = double.tryParse(_expOpeningBalanceCtrl.text.trim()) ?? 0.0;

    context.read<AccountsBloc>().add(
          CreateExpenseAccountEvent(
            title: name,
            category: _expCategory,
            openingBalance: balance,
          ),
        );

    _showSuccessSnackBar('Expense Account "$name" created successfully!');
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.accounts);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  void _promptAddCustomCategory() {
    final customCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Add Custom Category', style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: customCtrl,
          decoration: const InputDecoration(hintText: 'Enter category name (e.g. Marketing)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF050B20), foregroundColor: Colors.white),
            onPressed: () {
              final cat = customCtrl.text.trim();
              if (cat.isNotEmpty) {
                setState(() {
                  if (!_expenseCategories.contains(cat)) {
                    _expenseCategories.insert(_expenseCategories.length - 1, cat);
                  }
                  _expCategory = cat;
                });
                Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Add Category'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: SafeArea(
        child: Column(
          children: [
            // TOP HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(RouteNames.dashboard);
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF050B20)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Create',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF050B20),
                    ),
                  ),
                ],
              ),
            ),

            // CREATION TYPE SELECTOR BAR (Product, Sale, Purchase, Expense)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _buildSelectorTab(0, 'Product', Icons.inventory_2_outlined)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSelectorTab(1, 'Sale', Icons.person_outline)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSelectorTab(2, 'Purchase', Icons.business_outlined)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSelectorTab(3, 'Expense', Icons.account_balance_outlined)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // FORM BODY + FIXED BOTTOM BUTTON
            Expanded(
              child: _activeTab == 4
                  ? _buildAccountChooserBody()
                  : Stack(
                      children: [
                        Positioned.fill(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // UPPERCASE TAG INDICATOR
                                _buildTypeIndicatorTag(),
                                const SizedBox(height: 8),

                                if (_activeTab == 0) _buildAddProductForm(),
                                if (_activeTab == 1) _buildAddSaleAccountForm(),
                                if (_activeTab == 2) _buildAddPurchaseAccountForm(),
                                if (_activeTab == 3) _buildAddExpenseAccountForm(),
                              ],
                            ),
                          ),
                        ),

                        // FIXED BOTTOM SAVE BUTTON
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: AppColors.primaryBlue.withValues(alpha: 0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _saveCurrentForm,
                              child: Text(
                                _activeTab == 0 ? 'Save Product' : 'Save Account',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorTab(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF4B5563),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF4B5563),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIndicatorTag() {
    String tagText;
    switch (_activeTab) {
      case 0:
        tagText = 'CREATETYPE.PRODUCT';
        break;
      case 1:
        tagText = 'CREATETYPE.SALE';
        break;
      case 2:
        tagText = 'CREATETYPE.PURCHASE';
        break;
      case 3:
        tagText = 'CREATETYPE.EXPENSE';
        break;
      default:
        tagText = 'CREATETYPE.ACCOUNT';
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF0099FF),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          tagText,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0099FF),
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 1. ADD PRODUCT FORM
  // ==========================================
  Widget _buildAddProductForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Product',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF050B20)),
        ),
        const SizedBox(height: 2),
        const Text(
          'Add a new item to your inventory',
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 16),

        // DASHED IMAGE UPLOAD AREA
        GestureDetector(
          onTap: () {
            // Pick image simulation/placeholder
            setState(() {
              _prodImagePath = 'assets/icons/app_icon.png';
            });
          },
          child: Container(
            width: double.infinity,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5, style: BorderStyle.solid),
            ),
            child: _prodImagePath != null
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(_prodImagePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 110,
                          errorBuilder: (ctx, err, stack) => const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 36, color: Color(0xFF050B20)),
                              SizedBox(height: 6),
                              Text('Image Uploaded', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close, size: 16, color: Colors.white),
                            onPressed: () => setState(() => _prodImagePath = null),
                          ),
                        ),
                      ),
                    ],
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 32, color: Color(0xFF4B5563)),
                      SizedBox(height: 8),
                      Text(
                        'Upload product image',
                        style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 18),

        // Product Name *
        _buildFormFieldLabel('Product Name', required: true),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _prodNameCtrl,
          hint: 'e.g. Basmati Rice 5kg',
        ),
        const SizedBox(height: 14),

        // SKU / Barcode + Category Side-by-Side
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('SKU / Barcode'),
                  const SizedBox(height: 6),
                  _buildCustomTextField(
                    controller: _prodSkuCtrl,
                    hint: 'Scan or enter',
                    suffixIcon: const Icon(Icons.qr_code_scanner, size: 18, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('Category'),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: ['Grocery', 'Beverages', 'Electronics', 'Clothing', 'General'].contains(_prodCategoryCtrl.text)
                            ? _prodCategoryCtrl.text
                            : 'Grocery',
                        isExpanded: true,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF050B20)),
                        items: ['Grocery', 'Beverages', 'Electronics', 'Clothing', 'General'].map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _prodCategoryCtrl.text = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Purchase Price + Selling Price * Side-by-Side
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('Purchase Price'),
                  const SizedBox(height: 6),
                  _buildCustomTextField(
                    controller: _prodPurchasePriceCtrl,
                    hint: '0.00',
                    prefixText: '₹ ',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('Selling Price', required: true),
                  const SizedBox(height: 6),
                  _buildCustomTextField(
                    controller: _prodSellingPriceCtrl,
                    hint: '0.00',
                    prefixText: '₹ ',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Opening Stock + Low-stock Alert Side-by-Side
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('Opening Stock'),
                  const SizedBox(height: 6),
                  _buildCustomTextField(
                    controller: _prodStockCtrl,
                    hint: '0',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('Low-stock Alert'),
                  const SizedBox(height: 6),
                  _buildCustomTextField(
                    controller: _prodLowStockCtrl,
                    hint: 'e.g. 10',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        _buildFormFieldLabel('Description'),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _prodDescCtrl,
          hint: 'Optional description',
          maxLines: 3,
        ),
      ],
    );
  }

  // ==========================================
  // 2. ADD SALE ACCOUNT FORM
  // ==========================================
  Widget _buildAddSaleAccountForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Sale Account',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF050B20)),
        ),
        const SizedBox(height: 2),
        const Text(
          'Create a customer you sell to',
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 18),

        // Customer Name *
        _buildFormFieldLabel('Customer Name', required: true),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _saleNameCtrl,
          hint: 'Enter customer name',
        ),
        const SizedBox(height: 14),

        // Phone + Email Side-by-Side
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('Phone'),
                  const SizedBox(height: 6),
                  _buildCustomTextField(
                    controller: _salePhoneCtrl,
                    hint: 'Enter phone',
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('Email'),
                  const SizedBox(height: 6),
                  _buildCustomTextField(
                    controller: _saleEmailCtrl,
                    hint: 'Enter email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Address
        _buildFormFieldLabel('Address'),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _saleAddressCtrl,
          hint: 'Enter address',
        ),
        const SizedBox(height: 14),

        // Opening Balance
        _buildFormFieldLabel('Opening Balance'),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _saleOpeningBalanceCtrl,
          hint: '0.00',
          prefixText: '₹ ',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),

        // LIGHT CYAN INFO CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F7FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF0284C7)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Amount the customer currently owes you',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF050B20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Notes
        _buildFormFieldLabel('Notes'),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _saleNotesCtrl,
          hint: 'Optional notes',
          maxLines: 3,
        ),
      ],
    );
  }

  // ==========================================
  // 3. ADD PURCHASE ACCOUNT FORM
  // ==========================================
  Widget _buildAddPurchaseAccountForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Purchase Account',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF050B20)),
        ),
        const SizedBox(height: 2),
        const Text(
          'Create a supplier you buy from',
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 18),

        // Supplier Name *
        _buildFormFieldLabel('Supplier Name', required: true),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _purNameCtrl,
          hint: 'Enter supplier name',
        ),
        const SizedBox(height: 14),

        // Phone + Email Side-by-Side
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('Phone'),
                  const SizedBox(height: 6),
                  _buildCustomTextField(
                    controller: _purPhoneCtrl,
                    hint: 'Enter phone',
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('Email'),
                  const SizedBox(height: 6),
                  _buildCustomTextField(
                    controller: _purEmailCtrl,
                    hint: 'Enter email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Address
        _buildFormFieldLabel('Address'),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _purAddressCtrl,
          hint: 'Enter address',
        ),
        const SizedBox(height: 14),

        // Opening Balance
        _buildFormFieldLabel('Opening Balance'),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _purOpeningBalanceCtrl,
          hint: '0.00',
          prefixText: '₹ ',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),

        // LIGHT CYAN INFO CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F7FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF0284C7)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Amount currently owed to this supplier',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF050B20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Notes
        _buildFormFieldLabel('Notes'),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _purNotesCtrl,
          hint: 'Optional notes',
          maxLines: 3,
        ),
      ],
    );
  }

  // ==========================================
  // 4. ADD EXPENSE ACCOUNT FORM
  // ==========================================
  Widget _buildAddExpenseAccountForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Expense Account',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF050B20)),
        ),
        const SizedBox(height: 2),
        const Text(
          'Track a recurring or one-off business cost',
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 18),

        // Account Name *
        _buildFormFieldLabel('Account Name', required: true),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _expNameCtrl,
          hint: 'e.g. Shop Electricity',
        ),
        const SizedBox(height: 14),

        // Category Dropdown
        _buildFormFieldLabel('Category'),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _expenseCategories.contains(_expCategory) ? _expCategory : 'Rent',
              isExpanded: true,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF050B20)),
              items: _expenseCategories.where((c) => c != 'Custom +').map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _expCategory = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 10),

        // CATEGORY CHIPS
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _expenseCategories.map((cat) {
            final isSel = _expCategory == cat;
            return ChoiceChip(
              label: Text(cat),
              selected: isSel,
              selectedColor: AppColors.primaryBlue,
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              labelStyle: TextStyle(
                color: isSel ? Colors.white : const Color(0xFF050B20),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              onSelected: (selected) {
                if (cat == 'Custom +') {
                  _promptAddCustomCategory();
                } else if (selected) {
                  setState(() => _expCategory = cat);
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // Description
        _buildFormFieldLabel('Description'),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _expDescCtrl,
          hint: 'Optional description',
          maxLines: 3,
        ),
        const SizedBox(height: 14),

        // Opening Balance
        _buildFormFieldLabel('Opening Balance'),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _expOpeningBalanceCtrl,
          hint: '0.00',
          prefixText: '₹ ',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  // ==========================================
  // 5. ACCOUNT CHOOSER BODY
  // ==========================================
  Widget _buildAccountChooserBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Account',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF050B20)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose the type of account you want to create',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),

          // Sale Account Card
          AppCard(
            onTap: () {
              setState(() {
                _activeTab = 1; // Switch to Sale Account
              });
            },
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person_outline, size: 28, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sale Account',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF050B20)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Create a customer account for sales',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF6B7280)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Purchase Account Card
          AppCard(
            onTap: () {
              setState(() {
                _activeTab = 2; // Switch to Purchase Account
              });
            },
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.business_outlined, size: 28, color: AppColors.warning),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Purchase Account',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF050B20)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Create a supplier account for purchases',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF6B7280)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  Widget _buildFormFieldLabel(String label, {bool required = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF050B20),
          ),
        ),
        if (required) ...[
          const SizedBox(width: 3),
          const Text('*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
        ],
      ],
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hint,
    String? prefixText,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      height: maxLines == 1 ? 48 : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF050B20)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400),
          prefixText: prefixText,
          prefixStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF050B20)),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
