import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../application/bloc/accounts_bloc.dart';
import '../../../application/bloc/product_bloc.dart';
import '../../../application/bloc/purchase_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/purchase_entity.dart';
import '../../../domain/repositories/category_repository.dart';

enum UniversalAccountType { customer, supplier, income, expense }

class CreateMasterPage extends StatefulWidget {
  final int initialTabIndex; // 0 = Product/Service, 1+ = Universal Account
  final ProductEntity? productToEdit;
  final CustomerEntity? customerToEdit;
  final SupplierEntity? supplierToEdit;
  final ExpenseAccountSummary? expenseToEdit;
  final CategoryEntity? categoryToEdit;
  final bool initialIsService;

  const CreateMasterPage({
    super.key,
    this.initialTabIndex = 0,
    this.productToEdit,
    this.customerToEdit,
    this.supplierToEdit,
    this.expenseToEdit,
    this.categoryToEdit,
    this.initialIsService = false,
  });

  @override
  State<CreateMasterPage> createState() => _CreateMasterPageState();
}

class _CreateMasterPageState extends State<CreateMasterPage> {
  late int _activeTab; // 0 = Product/Service, 1 = Universal Account

  bool get isEditMode =>
      widget.productToEdit != null ||
      widget.customerToEdit != null ||
      widget.supplierToEdit != null ||
      widget.expenseToEdit != null ||
      widget.categoryToEdit != null;

  // Item vs Service state (0 = Item, 1 = Service)
  int _itemOrServiceIndex = 0;

  // Product / Item Form Controllers
  final _prodNameCtrl = TextEditingController();
  final _prodSkuCtrl = TextEditingController();
  final _prodBarcodeCtrl = TextEditingController();
  final _prodCategoryCtrl = TextEditingController(text: 'General');
  final _prodHsnCtrl = TextEditingController();
  final _prodUnitCtrl = TextEditingController(text: 'PCS');
  final _prodTaxCtrl = TextEditingController(text: '0.00');
  final _prodPurchasePriceCtrl = TextEditingController(text: '0.00');
  final _prodSellingPriceCtrl = TextEditingController(text: '0.00');
  final _prodStockCtrl = TextEditingController(text: '0');
  final _prodLowStockCtrl = TextEditingController(text: '10');
  final _prodDescCtrl = TextEditingController();

  // Service Specific Controllers
  final _serviceSacCtrl = TextEditingController();
  final _serviceTaxCtrl = TextEditingController(text: '0.00');

  // SKU Barcode Scanner controls & state
  MobileScannerController? _skuScannerController;
  bool _isSkuCameraOn = false;

  // =========================================================
  // UNIVERSAL ACCOUNT FORM STATE & CONTROLLERS
  // =========================================================
  UniversalAccountType? _accountType;

  final _accountNameCtrl = TextEditingController();
  String? _accountNameError;
  String? _accountTypeError;

  // Contact Info
  final _phoneCtrl = TextEditingController();
  final _altPhoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Business Info
  final _tradeNameCtrl = TextEditingController();
  String _gstRegType = 'Unregistered'; // Regular, Composition, Unregistered, Consumer
  final _gstinCtrl = TextEditingController();
  final _panCtrl = TextEditingController();

  // Address
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pinCodeCtrl = TextEditingController();

  // Financial & Payment Info
  final _openingBalanceCtrl = TextEditingController(text: '0.00');
  String _balanceType = 'Receivable'; // Receivable, Payable
  final _creditLimitCtrl = TextEditingController();
  String _paymentTerms = 'Immediate'; // Immediate, 7 Days, 15 Days, 30 Days, 45 Days, 60 Days, Custom

  // Category & Accounting Details
  final _descriptionCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      _activeTab = 0;
      final p = widget.productToEdit!;
      _itemOrServiceIndex = p.isService ? 1 : 0;
      _prodNameCtrl.text = p.name;
      _prodSkuCtrl.text = p.sku;
      _prodBarcodeCtrl.text = p.barcode;
      _prodHsnCtrl.text = p.hsnCode;
      _prodUnitCtrl.text = p.unit.isNotEmpty ? p.unit.toUpperCase() : (p.isService ? 'SERVICE' : 'PCS');
      _prodCategoryCtrl.text = p.category.isNotEmpty ? p.category : 'General';
      _serviceSacCtrl.text = p.hsnCode;
      _prodPurchasePriceCtrl.text = p.purchasePrice > 0
          ? (p.purchasePrice % 1 == 0
              ? p.purchasePrice.toInt().toString()
              : p.purchasePrice.toStringAsFixed(2))
          : '0.00';
      _prodSellingPriceCtrl.text = p.sellingPrice % 1 == 0
          ? p.sellingPrice.toInt().toString()
          : p.sellingPrice.toStringAsFixed(2);
      _prodStockCtrl.text = p.stockQuantity.toString();
      _prodLowStockCtrl.text = p.reorderLevel.toString();
      _prodDescCtrl.text = p.description;
      if (p.taxPercentage != null) {
        final taxStr = p.taxPercentage! % 1 == 0
            ? p.taxPercentage!.toInt().toString()
            : p.taxPercentage!.toStringAsFixed(2);
        _prodTaxCtrl.text = taxStr;
        _serviceTaxCtrl.text = taxStr;
      }
    } else if (widget.customerToEdit != null) {
      _activeTab = 1;
      _accountType = UniversalAccountType.customer;
      final c = widget.customerToEdit!;
      _accountNameCtrl.text = c.name;
      _phoneCtrl.text = c.phone;
      _emailCtrl.text = c.email;
      _addressCtrl.text = c.address;
      _openingBalanceCtrl.text = c.outstandingBalance % 1 == 0
          ? c.outstandingBalance.abs().toInt().toString()
          : c.outstandingBalance.abs().toStringAsFixed(2);
      _balanceType = c.outstandingBalance >= 0 ? 'Receivable' : 'Payable';
    } else if (widget.supplierToEdit != null) {
      _activeTab = 1;
      _accountType = UniversalAccountType.supplier;
      final s = widget.supplierToEdit!;
      _accountNameCtrl.text = s.name;
      _tradeNameCtrl.text = s.companyName;
      _phoneCtrl.text = s.phone;
      _emailCtrl.text = s.email;
      _addressCtrl.text = s.address;
      _openingBalanceCtrl.text = s.payableBalance % 1 == 0
          ? s.payableBalance.toInt().toString()
          : s.payableBalance.toStringAsFixed(2);
      _balanceType = 'Payable';
    } else if (widget.expenseToEdit != null) {
      _activeTab = 1;
      _accountType = UniversalAccountType.expense;
      final e = widget.expenseToEdit!;
      _accountNameCtrl.text = e.title;
      _openingBalanceCtrl.text = e.outstandingBalance % 1 == 0
          ? e.outstandingBalance.toInt().toString()
          : e.outstandingBalance.toStringAsFixed(2);
    } else if (widget.categoryToEdit != null) {
      _activeTab = 1;
      final cat = widget.categoryToEdit!;
      _accountNameCtrl.text = cat.name;
      _accountType = cat.type == CategoryType.income
          ? UniversalAccountType.income
          : UniversalAccountType.expense;
    } else {
      _activeTab = widget.initialTabIndex;
      if (_activeTab == 2) {
        _accountType = UniversalAccountType.supplier;
      } else if (_activeTab == 3) {
        _accountType = UniversalAccountType.expense;
      } else {
        _accountType = null; // Blank by default for Create Account
      }

      if (widget.initialIsService) {
        _itemOrServiceIndex = 1;
        _prodCategoryCtrl.text = 'Services';
      }
    }
  }

  @override
  void dispose() {
    _skuScannerController?.dispose();
    _prodNameCtrl.dispose();
    _prodSkuCtrl.dispose();
    _prodCategoryCtrl.dispose();
    _prodPurchasePriceCtrl.dispose();
    _prodSellingPriceCtrl.dispose();
    _prodStockCtrl.dispose();
    _prodLowStockCtrl.dispose();
    _serviceSacCtrl.dispose();
    _serviceTaxCtrl.dispose();

    _accountNameCtrl.dispose();
    _phoneCtrl.dispose();
    _altPhoneCtrl.dispose();
    _emailCtrl.dispose();
    _tradeNameCtrl.dispose();
    _gstinCtrl.dispose();
    _panCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pinCodeCtrl.dispose();
    _openingBalanceCtrl.dispose();
    _creditLimitCtrl.dispose();
    _descriptionCtrl.dispose();
    _notesCtrl.dispose();

    super.dispose();
  }

  void _toggleSkuScanner() {
    setState(() {
      _isSkuCameraOn = !_isSkuCameraOn;
      if (_isSkuCameraOn) {
        _skuScannerController ??= MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          torchEnabled: false,
          autoStart: true,
        );
        _skuScannerController?.start();
      } else {
        _skuScannerController?.stop();
      }
    });
  }

  void _onSkuBarcodeDetected(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue ?? barcode.displayValue;
      if (code != null && code.trim().isNotEmpty) {
        setState(() {
          _prodSkuCtrl.text = code.trim();
          _isSkuCameraOn = false;
        });
        _skuScannerController?.stop();
        break;
      }
    }
  }

  void _saveCurrentForm() {
    if (_activeTab == 0) {
      if (_itemOrServiceIndex == 0) {
        _saveProduct();
      } else {
        _saveService();
      }
    } else {
      _saveUniversalAccount();
    }
  }

  void _saveService() {
    final name = _prodNameCtrl.text.trim();
    if (name.isEmpty) {
      _showErrorSnackBar('Please enter service name');
      return;
    }
    final sellingPrice =
        double.tryParse(_prodSellingPriceCtrl.text.trim()) ?? 0.0;
    if (sellingPrice <= 0) {
      _showErrorSnackBar('Please enter a valid service price');
      return;
    }
    final sku = _prodSkuCtrl.text.trim();
    final sacCode = _serviceSacCtrl.text.trim();
    final unit = _prodUnitCtrl.text.trim().isNotEmpty ? _prodUnitCtrl.text.trim() : 'Service';
    final tax = double.tryParse(_serviceTaxCtrl.text.trim()) ?? 0.0;

    if (widget.productToEdit != null) {
      final existing = widget.productToEdit!;
      final updatedService = existing.copyWith(
        name: name,
        sku: sku,
        barcode: sacCode,
        category: 'Services',
        sellingPrice: sellingPrice,
        purchasePrice: 0.0,
        stockQuantity: 0,
        reorderLevel: 0,
        unit: unit,
        taxPercentage: tax,
        hsnCode: sacCode,
        description: _prodDescCtrl.text.trim(),
        updatedAt: DateTime.now(),
      );

      context.read<ProductBloc>().add(UpdateProductEvent(updatedService));
      context.read<ProductBloc>().add(const FetchProductsEvent());
      _showSuccessSnackBar(
          'Service "${updatedService.name}" updated successfully!');
    } else {
      final service = ProductEntity(
        id: 'srv_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        sku: sku,
        barcode: sacCode,
        category: 'Services',
        sellingPrice: sellingPrice,
        purchasePrice: 0.0,
        stockQuantity: 0,
        reorderLevel: 0,
        unit: unit,
        taxPercentage: tax,
        hsnCode: sacCode,
        description: _prodDescCtrl.text.trim(),
        createdAt: DateTime.now(),
      );

      context.read<ProductBloc>().add(CreateProductEvent(service));
      context.read<ProductBloc>().add(const FetchProductsEvent());
      _showSuccessSnackBar('Service "${service.name}" created successfully!');
    }

    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.services);
    }
  }

  void _saveProduct() {
    final name = _prodNameCtrl.text.trim();
    if (name.isEmpty) {
      _showErrorSnackBar('Please enter product name');
      return;
    }
    final sellingPrice =
        double.tryParse(_prodSellingPriceCtrl.text.trim()) ?? 0.0;
    if (sellingPrice <= 0) {
      _showErrorSnackBar('Please enter a valid selling price');
      return;
    }
    final purchasePrice =
        double.tryParse(_prodPurchasePriceCtrl.text.trim()) ?? 0.0;
    final stock = int.tryParse(_prodStockCtrl.text.trim()) ?? 0;
    final lowStock = int.tryParse(_prodLowStockCtrl.text.trim()) ?? 10;
    final category = _prodCategoryCtrl.text.trim().isNotEmpty
        ? _prodCategoryCtrl.text.trim()
        : 'General';
    final sku = _prodSkuCtrl.text.trim();
    final barcode = _prodBarcodeCtrl.text.trim();
    final hsnCode = _prodHsnCtrl.text.trim();
    final unit = _prodUnitCtrl.text.trim().isNotEmpty ? _prodUnitCtrl.text.trim() : 'PCS';
    final tax = double.tryParse(_prodTaxCtrl.text.trim());

    if (widget.productToEdit != null) {
      final existing = widget.productToEdit!;
      final updatedProduct = existing.copyWith(
        name: name,
        sku: sku,
        barcode: barcode,
        category: category,
        sellingPrice: sellingPrice,
        purchasePrice: purchasePrice,
        stockQuantity: stock,
        reorderLevel: lowStock,
        unit: unit,
        taxPercentage: tax,
        hsnCode: hsnCode,
        description: _prodDescCtrl.text.trim(),
        updatedAt: DateTime.now(),
      );

      context.read<ProductBloc>().add(UpdateProductEvent(updatedProduct));
      context.read<ProductBloc>().add(const FetchProductsEvent());
      _showSuccessSnackBar(
          'Product "${updatedProduct.name}" updated successfully!');
    } else {
      final product = ProductEntity(
        id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        sku: sku,
        barcode: barcode,
        category: category,
        sellingPrice: sellingPrice,
        purchasePrice: purchasePrice,
        stockQuantity: stock,
        reorderLevel: lowStock,
        unit: unit,
        taxPercentage: tax,
        hsnCode: hsnCode,
        description: _prodDescCtrl.text.trim(),
        createdAt: DateTime.now(),
      );

      context.read<ProductBloc>().add(CreateProductEvent(product));
      context.read<ProductBloc>().add(const FetchProductsEvent());
      _showSuccessSnackBar('Product "${product.name}" created successfully!');
    }

    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.stockManagement);
    }
  }

  void _saveUniversalAccount() async {
    setState(() {
      _accountNameError = null;
      _accountTypeError = null;
    });

    final name = _accountNameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() {
        _accountNameError = 'Account name is required.';
      });
      _showErrorSnackBar('Account name is required.');
      return;
    }

    if (_accountType == null) {
      setState(() {
        _accountTypeError = 'Please select an account type.';
      });
      _showErrorSnackBar('Please select an account type.');
      return;
    }

    // Phone validation if entered (Customer & Supplier)
    if (_accountType == UniversalAccountType.customer ||
        _accountType == UniversalAccountType.supplier) {
      final phone = _phoneCtrl.text.trim();
      if (phone.isNotEmpty && phone.length < 7) {
        _showErrorSnackBar('Enter a valid phone number.');
        return;
      }

      // Email validation if entered
      final email = _emailCtrl.text.trim();
      if (email.isNotEmpty && !email.contains('@')) {
        _showErrorSnackBar('Enter a valid email address.');
        return;
      }

      // GSTIN validation if entered
      final gstin = _gstinCtrl.text.trim();
      if (gstin.isNotEmpty) {
        final gstinRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
        if (!gstinRegex.hasMatch(gstin.toUpperCase())) {
          _showErrorSnackBar('Enter a valid GSTIN.');
          return;
        }
      }
    }

    final balance = double.tryParse(_openingBalanceCtrl.text.trim()) ?? 0.0;
    final signedBalance = _balanceType == 'Payable' ? -balance.abs() : balance.abs();

    if (_accountType == UniversalAccountType.customer) {
      final fullAddress = [
        _addressCtrl.text.trim(),
        _cityCtrl.text.trim(),
        _stateCtrl.text.trim(),
        _pinCodeCtrl.text.trim(),
      ].where((s) => s.isNotEmpty).join(', ');

      if (widget.customerToEdit != null) {
        final existing = widget.customerToEdit!;
        final updated = existing.copyWith(
          name: name,
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          address: fullAddress,
          outstandingBalance: signedBalance,
        );
        context.read<AccountsBloc>().add(UpdateCustomerAccountEvent(updated));
        context.read<AccountsBloc>().add(const FetchAccountsEvent());
        _showSuccessSnackBar('Customer "${updated.name}" updated successfully!');
      } else {
        final customer = CustomerEntity(
          id: 'CUST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          name: name,
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          address: fullAddress,
          outstandingBalance: signedBalance,
          createdAt: DateTime.now(),
        );
        context.read<AccountsBloc>().add(CreateCustomerAccountEvent(customer));
        context.read<AccountsBloc>().add(const FetchAccountsEvent());
        _showSuccessSnackBar('Customer "${customer.name}" created successfully!');
      }
    } else if (_accountType == UniversalAccountType.supplier) {
      final fullAddress = [
        _addressCtrl.text.trim(),
        _cityCtrl.text.trim(),
        _stateCtrl.text.trim(),
        _pinCodeCtrl.text.trim(),
      ].where((s) => s.isNotEmpty).join(', ');

      final tradeName = _tradeNameCtrl.text.trim().isNotEmpty
          ? _tradeNameCtrl.text.trim()
          : name;

      if (widget.supplierToEdit != null) {
        final existing = widget.supplierToEdit!;
        final updated = existing.copyWith(
          name: name,
          companyName: tradeName,
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          address: fullAddress,
          payableBalance: signedBalance.abs(),
        );
        context.read<PurchaseBloc>().add(UpdateSupplierSubmittedEvent(updated));
        context.read<PurchaseBloc>().add(const FetchPurchasesEvent());
        context.read<AccountsBloc>().add(const FetchAccountsEvent());
        _showSuccessSnackBar('Supplier "${updated.name}" updated successfully!');
      } else {
        final supplier = SupplierEntity(
          id: 'sup_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          companyName: tradeName,
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          address: fullAddress,
          payableBalance: signedBalance.abs(),
          createdAt: DateTime.now(),
        );
        context.read<PurchaseBloc>().add(CreateSupplierSubmittedEvent(supplier));
        context.read<PurchaseBloc>().add(const FetchPurchasesEvent());
        context.read<AccountsBloc>().add(const FetchAccountsEvent());
        _showSuccessSnackBar('Supplier "${supplier.name}" created successfully!');
      }
    } else if (_accountType == UniversalAccountType.income) {
      if (widget.categoryToEdit != null) {
        final existing = widget.categoryToEdit!;
        final updated = existing.copyWith(
          name: name,
          type: CategoryType.income,
          updatedAt: DateTime.now(),
        );
        await getIt<CategoryRepository>().updateCategory(updated);
        if (!mounted) return;
        context.read<AccountsBloc>().add(
          UpdateExpenseAccountEvent(
            oldCategory: existing.name,
            newTitle: name,
            newCategory: name,
          ),
        );
        context.read<AccountsBloc>().add(const FetchAccountsEvent());
        _showSuccessSnackBar('Income Category "$name" updated successfully!');
      } else {
        final newCat = CategoryEntity(
          id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          type: CategoryType.income,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await getIt<CategoryRepository>().createCategory(newCat);
        if (!mounted) return;
        context.read<AccountsBloc>().add(
          CreateExpenseAccountEvent(
            title: name,
            category: name,
            openingBalance: 0.0,
          ),
        );
        context.read<AccountsBloc>().add(const FetchAccountsEvent());
        _showSuccessSnackBar('Income Category "$name" created successfully!');
      }
    } else if (_accountType == UniversalAccountType.expense) {
      if (widget.categoryToEdit != null) {
        final existing = widget.categoryToEdit!;
        final updated = existing.copyWith(
          name: name,
          type: CategoryType.expense,
          updatedAt: DateTime.now(),
        );
        await getIt<CategoryRepository>().updateCategory(updated);
        if (!mounted) return;
        context.read<AccountsBloc>().add(
          UpdateExpenseAccountEvent(
            oldCategory: existing.name,
            newTitle: name,
            newCategory: name,
          ),
        );
        context.read<AccountsBloc>().add(const FetchAccountsEvent());
        _showSuccessSnackBar('Expense Category "$name" updated successfully!');
      } else {
        final newCat = CategoryEntity(
          id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          type: CategoryType.expense,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await getIt<CategoryRepository>().createCategory(newCat);
        if (!mounted) return;
        context.read<AccountsBloc>().add(
          CreateExpenseAccountEvent(
            title: name,
            category: name,
            openingBalance: 0.0,
          ),
        );
        context.read<AccountsBloc>().add(const FetchAccountsEvent());
        _showSuccessSnackBar('Expense Category "$name" created successfully!');
      }
    }

    if (!mounted) return;
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
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: Color(0xFF050B20)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditMode
                            ? (_activeTab == 0
                                ? (_itemOrServiceIndex == 0 ? 'Edit Item' : 'Edit Service')
                                : 'Edit Account')
                            : (_activeTab == 0
                                ? (_itemOrServiceIndex == 0 ? 'Create Item' : 'Create Service')
                                : 'Create Account'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF050B20),
                        ),
                      ),
                      if (_activeTab != 0)
                        const Text(
                          'Add a customer, supplier, income or expense account',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // FORM BODY + FIXED BOTTOM BUTTON
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_activeTab == 0) _buildAddProductForm(),
                          if (_activeTab != 0) _buildUniversalAccountForm(),
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
                          _activeTab == 0
                              ? (_itemOrServiceIndex == 0
                                  ? (widget.productToEdit != null ? 'Update Item' : 'Save Item')
                                  : (widget.productToEdit != null ? 'Update Service' : 'Save Service'))
                              : (isEditMode ? 'Save Changes' : 'Create Account'),
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

  // ==========================================
  // UNIVERSAL ACCOUNT FORM WIDGETS
  // ==========================================
  Widget _buildUniversalAccountForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Account Name * (First Field)
        _buildFormFieldLabel('Account Name', required: true),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _accountNameCtrl,
          hint: 'Enter account name (e.g. ABC Traders, Office Rent)',
          errorText: _accountNameError,
        ),
        const SizedBox(height: 16),

        // Account Type * (Required Dropdown directly after Account Name)
        _buildFormFieldLabel('Account Type', required: true),
        const SizedBox(height: 6),
        _buildAccountTypeDropdown(),
        const SizedBox(height: 20),

        // Dynamic Form Sections
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: KeyedSubtree(
            key: ValueKey(_accountType),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_accountType == UniversalAccountType.customer ||
                    _accountType == UniversalAccountType.supplier) ...[
                  _buildCustomerSupplierDynamicFields(),
                ] else if (_accountType == UniversalAccountType.income ||
                    _accountType == UniversalAccountType.expense) ...[
                  _buildCategoryDynamicFields(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ACCOUNT TYPE DROPDOWN (Customer default, Customer/Supplier/Income/Expense)
  Widget _buildAccountTypeDropdown() {
    final Map<UniversalAccountType, String> options = {
      UniversalAccountType.customer: 'Customer',
      UniversalAccountType.supplier: 'Supplier',
      UniversalAccountType.income: 'Income',
      UniversalAccountType.expense: 'Expense',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _accountTypeError != null ? AppColors.danger : const Color(0xFFE5E7EB),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<UniversalAccountType>(
              value: _accountType,
              hint: const Text(
                'Select account type',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w400,
                ),
              ),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.darkBlueText, size: 26),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF050B20),
              ),
              items: options.entries.map((entry) {
                return DropdownMenuItem<UniversalAccountType>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: isEditMode
                  ? null
                  : (val) {
                      if (val != null) {
                        setState(() {
                          _accountType = val;
                          _accountTypeError = null;
                        });
                      }
                    },
            ),
          ),
        ),
        if (_accountTypeError != null) ...[
          const SizedBox(height: 4),
          Text(
            _accountTypeError!,
            style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }

  Widget _buildCustomerSupplierDynamicFields() {
    final isCustomer = _accountType == UniversalAccountType.customer;
    final sectionTitle = isCustomer ? 'CUSTOMER INFORMATION' : 'SUPPLIER INFORMATION';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CONTACT INFORMATION
        _buildSectionHeader(sectionTitle),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('Phone'),
                  const SizedBox(height: 6),
                  _buildCustomTextField(
                    controller: _phoneCtrl,
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
                  _buildFormFieldLabel('Alternate Phone'),
                  const SizedBox(height: 6),
                  _buildCustomTextField(
                    controller: _altPhoneCtrl,
                    hint: 'Alt phone',
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _buildFormFieldLabel('Email'),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _emailCtrl,
          hint: 'Enter email address',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),

        // BUSINESS INFORMATION
        _buildSectionHeader('BUSINESS INFORMATION'),
        const SizedBox(height: 10),

        _buildFormFieldLabel('Business / Trade Name'),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _tradeNameCtrl,
          hint: 'Enter registered business name',
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('GST Registration Type'),
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
                        value: _gstRegType,
                        isExpanded: true,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF050B20),
                        ),
                        items: ['Regular', 'Composition', 'Unregistered', 'Consumer']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _gstRegType = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('GSTIN'),
                  const SizedBox(height: 6),
                  _buildCustomTextField(
                    controller: _gstinCtrl,
                    hint: '15-digit GSTIN',
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _buildFormFieldLabel('PAN'),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _panCtrl,
          hint: 'e.g. ABCDE1234F',
        ),
        const SizedBox(height: 18),

        // ADDRESS
        _buildSectionHeader('ADDRESS'),
        const SizedBox(height: 10),

        _buildFormFieldLabel('Billing Address'),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _addressCtrl,
          hint: 'Street, Building, Suite',
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('City'),
                  const SizedBox(height: 6),
                  _buildCustomTextField(
                    controller: _cityCtrl,
                    hint: 'City',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('State'),
                  const SizedBox(height: 6),
                  _buildCustomTextField(
                    controller: _stateCtrl,
                    hint: 'State',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('PIN Code'),
                  const SizedBox(height: 6),
                  _buildCustomTextField(
                    controller: _pinCodeCtrl,
                    hint: '6-digit PIN',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // FINANCIAL & PAYMENT INFORMATION
        _buildSectionHeader('FINANCIAL INFORMATION'),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('Opening Balance'),
                  const SizedBox(height: 6),
                  _buildCustomTextField(
                    controller: _openingBalanceCtrl,
                    hint: '0.00',
                    prefixText: '₹ ',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('Balance Type'),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _balanceType,
                        isExpanded: true,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF050B20),
                        ),
                        items: ['Receivable', 'Payable']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _balanceType = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('Credit Limit'),
                  const SizedBox(height: 6),
                  _buildCustomTextField(
                    controller: _creditLimitCtrl,
                    hint: 'Optional limit',
                    prefixText: '₹ ',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('Payment Terms'),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _paymentTerms,
                        isExpanded: true,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF050B20),
                        ),
                        items: [
                          'Immediate',
                          '7 Days',
                          '15 Days',
                          '30 Days',
                          '45 Days',
                          '60 Days',
                          'Custom'
                        ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _paymentTerms = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _buildFormFieldLabel('Notes'),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _notesCtrl,
          hint: 'Add notes about this ${isCustomer ? "customer" : "supplier"}...',
          maxLines: 3,
        ),
      ],
    );
  }

  // CATEGORY FORM FOR INCOME & EXPENSE
  Widget _buildCategoryDynamicFields() {
    final isIncome = _accountType == UniversalAccountType.income;
    final typeText = isIncome ? 'Income' : 'Expense';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('CATEGORY INFORMATION'),
        const SizedBox(height: 10),

        _buildFormFieldLabel('Description'),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _descriptionCtrl,
          hint: 'Optional description for this $typeText category',
          maxLines: 3,
        ),
        const SizedBox(height: 12),

        _buildFormFieldLabel('Notes'),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _notesCtrl,
          hint: 'Add optional notes...',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            fontFamily: 'PlusJakartaSans',
            color: AppColors.secondaryText,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        const Divider(height: 1, color: AppColors.border),
      ],
    );
  }

  // ==========================================
  // ADD PRODUCT FORM & HELPERS
  // ==========================================
  Widget _buildAddProductForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildItemServiceSegmentedControl(),
        const SizedBox(height: 16),

        Text(
          widget.productToEdit != null
              ? (_itemOrServiceIndex == 0 ? 'Edit Item' : 'Edit Service')
              : (_itemOrServiceIndex == 0 ? 'Add Item' : 'Add Service'),
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF050B20)),
        ),
        const SizedBox(height: 2),
        Text(
          widget.productToEdit != null
              ? (_itemOrServiceIndex == 0
                  ? 'Update physical inventory product details'
                  : 'Update billable service details')
              : (_itemOrServiceIndex == 0
                  ? 'Add a physical product to track inventory & stock'
                  : 'Add a billable service (consulting, labor, repairs, etc.)'),
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 18),

        if (_itemOrServiceIndex == 0) ...[
          _buildFormFieldLabel('Product Name', required: true),
          const SizedBox(height: 6),
          _buildCustomTextField(
            controller: _prodNameCtrl,
            hint: 'e.g. Parle-G Biscuit 100g',
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormFieldLabel('SKU / Product Code'),
                    const SizedBox(height: 6),
                    _buildCustomTextField(
                      controller: _prodSkuCtrl,
                      hint: 'e.g. PRD-001',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isSkuCameraOn
                              ? Icons.camera_alt
                              : Icons.qr_code_scanner_rounded,
                          color: _isSkuCameraOn
                              ? AppColors.primaryBlue
                              : AppColors.secondaryText,
                          size: 20,
                        ),
                        onPressed: _toggleSkuScanner,
                      ),
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
                    _buildCustomTextField(
                      controller: _prodCategoryCtrl,
                      hint: 'General',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (_isSkuCameraOn) _buildEmbeddedSkuScanner(),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormFieldLabel('Selling Price', required: true),
                    const SizedBox(height: 6),
                    _buildCustomTextField(
                      controller: _prodSellingPriceCtrl,
                      hint: '₹ 0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormFieldLabel('Purchase Price'),
                    const SizedBox(height: 6),
                    _buildCustomTextField(
                      controller: _prodPurchasePriceCtrl,
                      hint: '₹ 0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

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
                    _buildFormFieldLabel('Low Stock Alert Level'),
                    const SizedBox(height: 6),
                    _buildCustomTextField(
                      controller: _prodLowStockCtrl,
                      hint: '10',
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
        ] else ...[
          _buildFormFieldLabel('Service Name', required: true),
          const SizedBox(height: 6),
          _buildCustomTextField(
            controller: _prodNameCtrl,
            hint: 'e.g. AC Repair & Maintenance',
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormFieldLabel('Service Charge', required: true),
                    const SizedBox(height: 6),
                    _buildCustomTextField(
                      controller: _prodSellingPriceCtrl,
                      hint: '₹ 0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormFieldLabel('SAC Code'),
                    const SizedBox(height: 6),
                    _buildCustomTextField(
                      controller: _serviceSacCtrl,
                      hint: 'e.g. 998714',
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
            hint: 'Optional service details',
            maxLines: 3,
          ),
        ],
      ],
    );
  }

  Widget _buildItemServiceSegmentedControl() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFF4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _itemOrServiceIndex = 0;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: _itemOrServiceIndex == 0
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: _itemOrServiceIndex == 0
                            ? Colors.white
                            : AppColors.secondaryText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Item',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _itemOrServiceIndex == 0
                              ? Colors.white
                              : AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _itemOrServiceIndex = 1;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: _itemOrServiceIndex == 1
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.build_outlined,
                        size: 16,
                        color: _itemOrServiceIndex == 1
                            ? Colors.white
                            : AppColors.secondaryText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Service',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _itemOrServiceIndex == 1
                              ? Colors.white
                              : AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmbeddedSkuScanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 180,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: MobileScanner(
          controller: _skuScannerController,
          onDetect: _onSkuBarcodeDetected,
        ),
      ),
    );
  }

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
          const Text('*',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
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
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: maxLines == 1 ? 48 : null,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? AppColors.danger : const Color(0xFFE5E7EB),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF050B20)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w400),
              prefixText: prefixText,
              prefixStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF050B20)),
              suffixIcon: suffixIcon,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.danger,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
