import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  final int
      initialTabIndex; // 0 = Product, 1 = Sale, 2 = Purchase, 3 = Expense, 4 = AccountChooser
  final ProductEntity? productToEdit;
  final CustomerEntity? customerToEdit;
  final SupplierEntity? supplierToEdit;
  final ExpenseAccountSummary? expenseToEdit;
  final bool initialIsService;

  const CreateMasterPage({
    super.key,
    this.initialTabIndex = 0,
    this.productToEdit,
    this.customerToEdit,
    this.supplierToEdit,
    this.expenseToEdit,
    this.initialIsService = false,
  });

  @override
  State<CreateMasterPage> createState() => _CreateMasterPageState();
}

class _CreateMasterPageState extends State<CreateMasterPage> {
  late int
      _activeTab; // 0 = Product, 1 = Sale, 2 = Purchase, 3 = Expense, 4 = AccountChooser

  bool get isEditMode =>
      widget.productToEdit != null ||
      widget.customerToEdit != null ||
      widget.supplierToEdit != null ||
      widget.expenseToEdit != null;

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
  bool _isSkuFlashOn = false;

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

  // Expense/Income Account Form Controllers
  final _expNameCtrl = TextEditingController();
  String _expAccountType = 'Expense';
  String _expCategory = 'General';
  final _expDescCtrl = TextEditingController();
  final _expOpeningBalanceCtrl = TextEditingController(text: '0.00');
  final List<String> _expenseCategories = [
    'General',
    'Utilities',
    'Rent',
    'Salary',
    'Transport',
    'Fuel',
  ];
  final List<String> _incomeCategories = [
    'General',
    'Sales Income',
    'Services',
    'Consulting',
    'Commission',
    'Rental Income',
    'Interest',
  ];

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
      final c = widget.customerToEdit!;
      _saleNameCtrl.text = c.name;
      _salePhoneCtrl.text = c.phone;
      _saleEmailCtrl.text = c.email;
      _saleAddressCtrl.text = c.address;
      _saleOpeningBalanceCtrl.text = c.outstandingBalance % 1 == 0
          ? c.outstandingBalance.toInt().toString()
          : c.outstandingBalance.toStringAsFixed(2);
    } else if (widget.supplierToEdit != null) {
      _activeTab = 2;
      final s = widget.supplierToEdit!;
      _purNameCtrl.text = s.name;
      _purPhoneCtrl.text = s.phone;
      _purEmailCtrl.text = s.email;
      _purAddressCtrl.text = s.address;
      _purOpeningBalanceCtrl.text = s.payableBalance % 1 == 0
          ? s.payableBalance.toInt().toString()
          : s.payableBalance.toStringAsFixed(2);
    } else if (widget.expenseToEdit != null) {
      _activeTab = 3;
      final e = widget.expenseToEdit!;
      _expNameCtrl.text = e.title;
      _expCategory = e.category;
      if (!_expenseCategories.contains(_expCategory)) {
        _expenseCategories.insert(_expenseCategories.length - 1, _expCategory);
      }
      _expOpeningBalanceCtrl.text = e.outstandingBalance % 1 == 0
          ? e.outstandingBalance.toInt().toString()
          : e.outstandingBalance.toStringAsFixed(2);
    } else {
      _activeTab = widget.initialTabIndex;
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

  void _toggleSkuFlash() async {
    if (_skuScannerController != null) {
      await _skuScannerController!.toggleTorch();
      setState(() {
        _isSkuFlashOn = !_isSkuFlashOn;
      });
    }
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
    } else if (_activeTab == 1) {
      _saveSaleAccount();
    } else if (_activeTab == 2) {
      _savePurchaseAccount();
    } else if (_activeTab == 3) {
      _saveExpenseAccount();
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

  void _saveSaleAccount() {
    final name = _saleNameCtrl.text.trim();
    if (name.isEmpty) {
      _showErrorSnackBar('Please enter customer name');
      return;
    }
    final balance = double.tryParse(_saleOpeningBalanceCtrl.text.trim()) ?? 0.0;

    if (widget.customerToEdit != null) {
      final existing = widget.customerToEdit!;
      final updatedCustomer = existing.copyWith(
        name: name,
        phone: _salePhoneCtrl.text.trim(),
        email: _saleEmailCtrl.text.trim(),
        address: _saleAddressCtrl.text.trim(),
        outstandingBalance: balance,
      );

      context
          .read<AccountsBloc>()
          .add(UpdateCustomerAccountEvent(updatedCustomer));
      context.read<AccountsBloc>().add(const FetchAccountsEvent());
      _showSuccessSnackBar(
          'Sale Account for "${updatedCustomer.name}" updated successfully!');
    } else {
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
      context.read<AccountsBloc>().add(const FetchAccountsEvent());
      _showSuccessSnackBar(
          'Sale Account for "${customer.name}" created successfully!');
    }

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

    if (widget.supplierToEdit != null) {
      final existing = widget.supplierToEdit!;
      final updatedSupplier = existing.copyWith(
        name: name,
        companyName: name,
        phone: _purPhoneCtrl.text.trim(),
        email: _purEmailCtrl.text.trim(),
        address: _purAddressCtrl.text.trim(),
        payableBalance: balance,
      );

      context
          .read<PurchaseBloc>()
          .add(UpdateSupplierSubmittedEvent(updatedSupplier));
      context.read<PurchaseBloc>().add(const FetchPurchasesEvent());
      context.read<AccountsBloc>().add(const FetchAccountsEvent());
      _showSuccessSnackBar(
          'Purchase Account for "${updatedSupplier.name}" updated successfully!');
    } else {
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
      context.read<PurchaseBloc>().add(const FetchPurchasesEvent());
      context.read<AccountsBloc>().add(const FetchAccountsEvent());
      _showSuccessSnackBar(
          'Purchase Account for "${supplier.name}" created successfully!');
    }

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

    if (widget.expenseToEdit != null) {
      context.read<AccountsBloc>().add(
            UpdateExpenseAccountEvent(
              oldCategory: widget.expenseToEdit!.category,
              newTitle: name,
              newCategory: _expCategory,
            ),
          );
      context.read<AccountsBloc>().add(const FetchAccountsEvent());

      _showSuccessSnackBar('$_expAccountType Account "$name" updated successfully!');
    } else {
      context.read<AccountsBloc>().add(
            CreateExpenseAccountEvent(
              title: name,
              category: _expCategory,
              openingBalance: balance,
            ),
          );
      context.read<AccountsBloc>().add(const FetchAccountsEvent());

      _showSuccessSnackBar('$_expAccountType Account "$name" created successfully!');
    }

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
                  Text(
                    isEditMode
                        ? (_activeTab == 0
                            ? (_itemOrServiceIndex == 0
                                ? 'Edit Item'
                                : 'Edit Service')
                            : (_activeTab == 1
                                ? 'Edit Customer'
                                : (_activeTab == 2
                                    ? 'Edit Supplier'
                                    : 'Edit Account')))
                        : (_activeTab == 0
                            ? (_itemOrServiceIndex == 0
                                ? 'Create Item'
                                : 'Create Service')
                            : (_activeTab == 1 || _activeTab == 2
                                ? 'Create Party'
                                : 'Create Account')),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF050B20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

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

                                if (_activeTab == 0) _buildAddProductForm(),
                                if (_activeTab == 1) _buildAddSaleAccountForm(),
                                if (_activeTab == 2)
                                  _buildAddPurchaseAccountForm(),
                                if (_activeTab == 3)
                                  _buildAddExpenseAccountForm(),
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
                                shadowColor: AppColors.primaryBlue
                                    .withValues(alpha: 0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _saveCurrentForm,
                              child: Text(
                                _activeTab == 0
                                    ? (_itemOrServiceIndex == 0
                                        ? (widget.productToEdit != null
                                            ? 'Update Item'
                                            : 'Save Item')
                                        : (widget.productToEdit != null
                                            ? 'Update Service'
                                            : 'Save Service'))
                                    : (_activeTab == 1
                                        ? (widget.customerToEdit != null
                                            ? 'Update Customer'
                                            : 'Save Customer')
                                        : (_activeTab == 2
                                            ? (widget.supplierToEdit != null
                                                ? 'Update Supplier'
                                                : 'Save Supplier')
                                            : (isEditMode
                                                ? 'Update Account'
                                                : 'Save Account'))),
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
  // 1. ADD PRODUCT FORM
  // ==========================================
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
                  boxShadow: _itemOrServiceIndex == 0
                      ? [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
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
                  if (_prodCategoryCtrl.text == 'Grocery') {
                    _prodCategoryCtrl.text = 'Services';
                  }
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
                  boxShadow: _itemOrServiceIndex == 1
                      ? [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
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

  Widget _buildCustomerSupplierSegmentedControl() {
    final isCustomer = _activeTab == 1;
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
                  _activeTab = 1;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isCustomer
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isCustomer
                      ? [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 16,
                        color: isCustomer
                            ? Colors.white
                            : AppColors.secondaryText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Customer',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isCustomer
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
                  _activeTab = 2;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: !isCustomer
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: !isCustomer
                      ? [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.business_outlined,
                        size: 16,
                        color: !isCustomer
                            ? Colors.white
                            : AppColors.secondaryText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Supplier',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: !isCustomer
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

  Widget _buildAddProductForm() {
    final isItem = _itemOrServiceIndex == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Segmented Switch [ Item | Service ] - ONLY shown when creating new record
        if (!isEditMode) ...[
          _buildItemServiceSegmentedControl(),
          const SizedBox(height: 16),
        ],

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.productToEdit != null
                  ? (isItem ? 'Edit Item' : 'Edit Service')
                  : (isItem ? 'Add Item' : 'Add Service'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF050B20),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.productToEdit != null
                  ? (isItem
                      ? 'Update item information'
                      : 'Update service details')
                  : (isItem
                      ? 'Add a new item to your inventory'
                      : 'Add a new service to your business'),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (isItem && _isSkuCameraOn) _buildSkuScannerHeader(),

        if (isItem) ...[
          // ITEM FORM
          _buildFormFieldLabel('Item Name', required: true),
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
                      hint: 'Scan or enter SKU',
                      suffixIcon: InkWell(
                        onTap: _toggleSkuScanner,
                        borderRadius: BorderRadius.circular(8),
                        child: Icon(
                          _isSkuCameraOn
                              ? Icons.close
                              : Icons.qr_code_scanner,
                          size: 18,
                          color: _isSkuCameraOn
                              ? AppColors.danger
                              : const Color(0xFF6B7280),
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
                          value: [
                            'General',
                            'Grocery',
                            'Beverages',
                            'Electronics',
                            'Clothing',
                            'Services',
                            'Other'
                          ].contains(_prodCategoryCtrl.text)
                              ? _prodCategoryCtrl.text
                              : 'General',
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF050B20),
                          ),
                          items: [
                            'General',
                            'Grocery',
                            'Beverages',
                            'Electronics',
                            'Clothing',
                            'Services',
                            'Other'
                          ].map((cat) {
                            return DropdownMenuItem(
                                value: cat, child: Text(cat));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _prodCategoryCtrl.text = val);
                            }
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

          // HSN Code + Unit Side-by-Side
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormFieldLabel('HSN Code'),
                    const SizedBox(height: 6),
                    _buildCustomTextField(
                      controller: _prodHsnCtrl,
                      hint: 'e.g. 1001',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormFieldLabel('Unit'),
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
                          value: [
                            'PCS',
                            'KG',
                            'G',
                            'L',
                            'M',
                            'BOX',
                            'SET'
                          ].contains(_prodUnitCtrl.text.toUpperCase())
                              ? _prodUnitCtrl.text.toUpperCase()
                              : 'PCS',
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF050B20),
                          ),
                          items: [
                            'PCS',
                            'KG',
                            'G',
                            'L',
                            'M',
                            'BOX',
                            'SET'
                          ].map((u) {
                            return DropdownMenuItem(value: u, child: Text(u));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _prodUnitCtrl.text = val);
                            }
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
            ],
          ),
          const SizedBox(height: 14),

          // Tax / GST Rate + Opening Stock Side-by-Side
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormFieldLabel('Tax / GST Rate'),
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
                          value: [
                            '0.00',
                            '5.00',
                            '12.00',
                            '18.00',
                            '28.00'
                          ].contains(_prodTaxCtrl.text)
                              ? _prodTaxCtrl.text
                              : '0.00',
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF050B20),
                          ),
                          items: const [
                            DropdownMenuItem(value: '0.00', child: Text('Exempt / 0%')),
                            DropdownMenuItem(value: '5.00', child: Text('5% GST')),
                            DropdownMenuItem(value: '12.00', child: Text('12% GST')),
                            DropdownMenuItem(value: '18.00', child: Text('18% GST')),
                            DropdownMenuItem(value: '28.00', child: Text('28% GST')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _prodTaxCtrl.text = val);
                            }
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
            ],
          ),
          const SizedBox(height: 14),

          // Low-stock Alert
          _buildFormFieldLabel('Low-stock Alert'),
          const SizedBox(height: 6),
          _buildCustomTextField(
            controller: _prodLowStockCtrl,
            hint: 'e.g. 10',
            keyboardType: TextInputType.number,
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
          // SERVICE FORM (Strictly No Category, Stock, Low Stock, or Inventory controls)
          _buildFormFieldLabel('Service Name', required: true),
          const SizedBox(height: 6),
          _buildCustomTextField(
            controller: _prodNameCtrl,
            hint: 'e.g. AC Repair & Maintenance',
          ),
          const SizedBox(height: 14),

          // Service Code + SAC Code Side-by-Side
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormFieldLabel('Service Code / SKU'),
                    const SizedBox(height: 6),
                    _buildCustomTextField(
                      controller: _prodSkuCtrl,
                      hint: 'Optional code',
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

          // Service Price * + Tax Rate Side-by-Side
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
                    _buildFormFieldLabel('GST / Tax Rate'),
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
                          value: [
                            '0.00',
                            '5.00',
                            '12.00',
                            '18.00',
                            '28.00'
                          ].contains(_serviceTaxCtrl.text)
                              ? _serviceTaxCtrl.text
                              : '0.00',
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF050B20),
                          ),
                          items: const [
                            DropdownMenuItem(value: '0.00', child: Text('Exempt / 0%')),
                            DropdownMenuItem(value: '5.00', child: Text('5% GST')),
                            DropdownMenuItem(value: '12.00', child: Text('12% GST')),
                            DropdownMenuItem(value: '18.00', child: Text('18% GST')),
                            DropdownMenuItem(value: '28.00', child: Text('28% GST')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _serviceTaxCtrl.text = val);
                            }
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

  // ==========================================
  // 2. ADD SALE ACCOUNT FORM
  // ==========================================
  Widget _buildAddSaleAccountForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Segmented Switch [ Customer | Supplier ]
        _buildCustomerSupplierSegmentedControl(),
        const SizedBox(height: 16),

        Text(
          widget.customerToEdit != null
              ? 'Edit Customer'
              : 'Add Customer',
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF050B20)),
        ),
        const SizedBox(height: 2),
        Text(
          widget.customerToEdit != null
              ? 'Update customer information'
              : 'Add a new customer account for sales',
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
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
              Icon(Icons.info_outline_rounded,
                  size: 18, color: Color(0xFF0284C7)),
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
        // Segmented Switch [ Customer | Supplier ]
        _buildCustomerSupplierSegmentedControl(),
        const SizedBox(height: 16),

        Text(
          widget.supplierToEdit != null
              ? 'Edit Supplier'
              : 'Add Supplier',
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF050B20)),
        ),
        const SizedBox(height: 2),
        Text(
          widget.supplierToEdit != null
              ? 'Update supplier information'
              : 'Add a new supplier account for purchases',
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
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
              Icon(Icons.info_outline_rounded,
                  size: 18, color: Color(0xFF0284C7)),
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
  // 4. ADD INCOME/EXPENSE ACCOUNT FORM
  // ==========================================
  Widget _buildAddExpenseAccountForm() {
    final activeCategories = _expAccountType == 'Income' ? _incomeCategories : _expenseCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.expenseToEdit != null
              ? 'Edit Income/Expense Account'
              : 'Add Income/Expense Account',
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF050B20)),
        ),
        const SizedBox(height: 2),
        Text(
          widget.expenseToEdit != null
              ? 'Update income/expense account'
              : 'Track recurring or one-off business income or costs',
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 18),

        // Account Type Dropdown
        _buildFormFieldLabel('Account Type'),
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
              value: _expAccountType,
              isExpanded: true,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF050B20)),
              items: ['Expense', 'Income'].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) {
                if (val != null && val != _expAccountType) {
                  setState(() {
                    _expAccountType = val;
                    final targetCategories = val == 'Income' ? _incomeCategories : _expenseCategories;
                    if (!targetCategories.contains(_expCategory)) {
                      _expCategory = targetCategories.first;
                    }
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Account Name *
        _buildFormFieldLabel('Account Name', required: true),
        const SizedBox(height: 6),
        _buildCustomTextField(
          controller: _expNameCtrl,
          hint: _expAccountType == 'Income' ? 'e.g. Consulting Revenue' : 'e.g. Shop Electricity',
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
              value: activeCategories.contains(_expCategory) ? _expCategory : activeCategories.first,
              isExpanded: true,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF050B20)),
              items: activeCategories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _expCategory = val);
                }
              },
            ),
          ),
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
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF050B20)),
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
                  child: const Icon(Icons.person_outline,
                      size: 28, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sale Account',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF050B20)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Create a customer account for sales',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Color(0xFF6B7280)),
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
                  child: const Icon(Icons.business_outlined,
                      size: 28, color: AppColors.warning),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Purchase Account',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF050B20)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Create a supplier account for purchases',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Color(0xFF6B7280)),
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
  Widget _buildSkuScannerHeader() {
    if (!_isSkuCameraOn || _skuScannerController == null) {
      return const SizedBox.shrink();
    }
    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          alignment: Alignment.center,
          children: [
            MobileScanner(
              controller: _skuScannerController!,
              onDetect: _onSkuBarcodeDetected,
              errorBuilder: (context, error) {
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          color: AppColors.danger, size: 36),
                      const SizedBox(height: 8),
                      const Text(
                        'Camera unavailable or permission denied',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF050B20)),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => _skuScannerController?.start(),
                        child: const Text('Retry Camera',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Barcode Box Overlay Area
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryBlue,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              width: 220,
              height: 90,
              child: Center(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            // Indicator Text
            Positioned(
              bottom: 8,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Align Barcode / SKU in box',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
            // Top Controls (Flash & Cam OFF)
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  InkWell(
                    onTap: _toggleSkuFlash,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isSkuFlashOn
                            ? Colors.amber
                            : Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                _isSkuFlashOn ? Colors.amber : Colors.white30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isSkuFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: _isSkuFlashOn ? Colors.black : Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isSkuFlashOn ? 'Flash ON' : 'Flash OFF',
                            style: TextStyle(
                              color:
                                  _isSkuFlashOn ? Colors.black : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _toggleSkuScanner,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.videocam_off,
                              color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Cam OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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
    );
  }
}
