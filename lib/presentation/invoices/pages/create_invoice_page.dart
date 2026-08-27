import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/bloc/invoice_bloc.dart';
import '../../../application/bloc/tax_settings_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../application/providers/create_invoice_provider.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/purchase_entity.dart';
import '../../../domain/entities/tax_settings_entity.dart';
import '../../../domain/repositories/customer_repository.dart';
import '../../../domain/repositories/purchase_repository.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../infrastructure/services/voucher_sequence_service.dart';
import '../../../application/services/transaction_stack_manager.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../widgets/common_voucher_app_bar.dart';
import '../widgets/voucher_summary_card.dart';
import 'return_voucher_screen.dart';

enum DocumentType {
  sale,
  purchase,
  payment,
  receipt,
  salesReturn,
  purchaseReturn,
}

extension DocumentTypeExt on DocumentType {
  String get titlePrefix {
    switch (this) {
      case DocumentType.sale:
        return 'Sale';
      case DocumentType.purchase:
        return 'Purchase';
      case DocumentType.payment:
        return 'Payment';
      case DocumentType.receipt:
        return 'Receipt';
      case DocumentType.salesReturn:
        return 'Sales Return';
      case DocumentType.purchaseReturn:
        return 'Purchase Return';
    }
  }

  String getAppBarTitle({bool isEditMode = false}) {
    final prefix = titlePrefix;
    return isEditMode ? 'Edit $prefix' : 'Add $prefix';
  }

  InvoiceType toInvoiceType() {
    switch (this) {
      case DocumentType.purchase:
      case DocumentType.purchaseReturn:
        return InvoiceType.purchase;
      default:
        return InvoiceType.sale;
    }
  }
}

class CreateInvoicePage extends ConsumerStatefulWidget {
  final InvoiceType invoiceType;
  final InvoiceEntity? invoiceToEdit;

  const CreateInvoicePage({
    super.key,
    this.invoiceType = InvoiceType.sale,
    this.invoiceToEdit,
  });

  @override
  ConsumerState<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends ConsumerState<CreateInvoicePage>
    with WidgetsBindingObserver {
  late DocumentType _docType;
  late String _invoiceId;
  late DateTime _createdDateTime;

  bool get isEditMode => widget.invoiceToEdit != null;
  bool get isPurchase => _docType == DocumentType.purchase;

  bool get _isCashSale => _selectedCustomer == null;
  CustomerEntity? get _selectedCustomer =>
      ref.watch(createInvoiceFormProvider).selectedCustomer;
  List<InvoiceItemEntity> get _items =>
      ref.watch(createInvoiceFormProvider).items;

  final TextEditingController _customerSearchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchOverlay = false;
  bool _isGstExpanded = false;
  bool _isDiscountExpanded = false;

  List<CustomerEntity> _allCustomers = [];
  List<ProductEntity> _allProducts = [];

  // Inline Add Product State
  bool _showInlineAddProduct = false;
  ProductEntity? _inlineSelectedProduct;
  late TextEditingController _inlineSearchCtrl;
  late TextEditingController _inlinePriceCtrl;
  final FocusNode _inlineSearchFocusNode = FocusNode();
  final GlobalKey _inlineCardKey = GlobalKey();
  int _inlineQuantity = 1;
  bool _showSearchResultsOverlay = false;

  bool _inlineProductError = false;
  String? _inlineProductErrorMsg;
  bool _inlineQuantityError = false;
  String? _inlineQuantityErrorMsg;
  bool _inlinePriceError = false;
  String? _inlinePriceErrorMsg;

  void _scrollToInlineCard() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && _inlineCardKey.currentContext != null) {
        Scrollable.ensureVisible(
          _inlineCardKey.currentContext!,
          alignment: 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Barcode Scanner controls & state
  MobileScannerController? _scannerController;
  bool _isCameraOn = false;
  bool _isFlashOn = false;
  DateTime? _lastScanTime;
  String? _lastScannedCode;

  late TextEditingController _notesCtrl;
  late TextEditingController _discountCtrl;
  late TextEditingController _extraAmtCtrl;
  late TextEditingController _extraDescCtrl;

  late final String _sessionId =
      'session_${DateTime.now().microsecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _notesCtrl = TextEditingController(text: 'Thank you for your business!');
    _discountCtrl = TextEditingController();
    _extraAmtCtrl = TextEditingController();
    _extraDescCtrl = TextEditingController();
    _inlineSearchCtrl = TextEditingController();
    _inlinePriceCtrl = TextEditingController();

    _loadProducts();

    _docType = widget.invoiceToEdit != null
        ? (widget.invoiceToEdit!.type == InvoiceType.purchase
            ? DocumentType.purchase
            : DocumentType.sale)
        : (widget.invoiceType == InvoiceType.purchase
            ? DocumentType.purchase
            : DocumentType.sale);

    if (widget.invoiceToEdit != null) {
      _invoiceId = widget.invoiceToEdit!.invoiceNumber;
    } else {
      _invoiceId = widget.invoiceType == InvoiceType.purchase
          ? 'PUR-#00-0001'
          : 'INV-#00-0001';
      _loadVoucherIdFromService();
    }

    _createdDateTime = widget.invoiceToEdit != null
        ? widget.invoiceToEdit!.issueDate
        : DateTime.now();

    _loadParties();

    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _showSearchOverlay = _searchFocusNode.hasFocus;
        });
      }
    });

    TransactionStackManager.instance.registerSession(
      TransactionSession(
        id: _sessionId,
        type: isPurchase
            ? TransactionTypeCategory.purchase
            : TransactionTypeCategory.sale,
        isEdit: isEditMode,
        entityId: widget.invoiceToEdit?.id,
        hasMeaningfulData: () => _hasUnsavedData,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.invoiceToEdit != null) {
        final inv = widget.invoiceToEdit!;
        final party = CustomerEntity(
          id: inv.customerId,
          name: inv.customerName,
          phone: inv.customerPhone,
          email: '',
          address: '',
          outstandingBalance: 0.0,
          createdAt: inv.issueDate,
        );
        ref.read(createInvoiceFormProvider.notifier).setItems(inv.items);
        if (inv.customerId.isNotEmpty) {
          ref.read(createInvoiceFormProvider.notifier).selectCustomer(party);
        }
        ref
            .read(createInvoiceFormProvider.notifier)
            .updateDateTime(inv.issueDate);
        _notesCtrl.text = inv.notes;

        ref.read(createInvoiceFormProvider.notifier).toggleGst(inv.gstEnabled);
        ref
            .read(createInvoiceFormProvider.notifier)
            .updateDiscount(inv.discountAmount, inv.discountIsPercentage);
        ref.read(createInvoiceFormProvider.notifier).updateExtraExpense(
            inv.extraExpenseAmount, inv.extraExpenseDescription);

        _discountCtrl.text =
            inv.discountAmount > 0 ? inv.discountAmount.toStringAsFixed(2) : '';
        _extraAmtCtrl.text = inv.extraExpenseAmount > 0
            ? inv.extraExpenseAmount.toStringAsFixed(2)
            : '';
        _extraDescCtrl.text = inv.extraExpenseDescription;
      } else {
        ref.read(createInvoiceFormProvider.notifier).reset();
      }
    });
  }

  Future<void> _loadVoucherIdFromService() async {
    final type = widget.invoiceType == InvoiceType.purchase
        ? VoucherType.purchase
        : VoucherType.sale;
    final generated =
        await VoucherSequenceService.instance.generateNextVoucherId(type);
    if (mounted) {
      setState(() {
        _invoiceId = generated;
      });
    }
  }

  Widget _buildVoucherIdBanner(String voucherId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.confirmation_number_outlined,
                  color: AppColors.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text(
                'Voucher / Invoice ID',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              voucherId,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadParties() async {
    try {
      if (isPurchase) {
        final suppliers = await getIt<PurchaseRepository>().getSuppliers();
        final mappedAsCustomers = suppliers
            .map((s) => CustomerEntity(
                  id: s.id,
                  name: s.companyName.isNotEmpty ? s.companyName : s.name,
                  phone: s.phone,
                  email: s.email,
                  address: s.address,
                  outstandingBalance: s.payableBalance,
                  createdAt: s.createdAt,
                ))
            .toList();
        if (mounted) {
          setState(() {
            _allCustomers = mappedAsCustomers;
          });
        }
      } else {
        final customers = await getIt<CustomerRepository>().getCustomers();
        if (mounted) {
          setState(() {
            _allCustomers = customers;
          });
        }
      }
    } catch (_) {}
  }

  String get _headerLabel {
    final shortRef =
        _invoiceId.contains('-') ? _invoiceId.split('-').last : _invoiceId;
    return '${_docType.titlePrefix} #$shortRef';
  }

  Widget _buildMoreSheetTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color titleColor = AppColors.darkBlueText,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.secondaryText),
          ],
        ),
      ),
    );
  }

  void _showMoreBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'More',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _headerLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 20),
              _buildMoreSheetTile(
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                title: 'Add Item / Service',
                subtitle: 'Create a new item or service in master catalog',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteNames.createMaster, extra: 0);
                },
              ),
              const SizedBox(height: 12),
              _buildMoreSheetTile(
                icon: isPurchase
                    ? Icons.business_outlined
                    : Icons.person_add_alt_1_outlined,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                title: 'Add Party',
                subtitle: isPurchase
                    ? 'Create a new supplier account'
                    : 'Create a new customer account',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteNames.createMaster,
                      extra: isPurchase ? 2 : 1);
                },
              ),
              const SizedBox(height: 12),
              _buildMoreSheetTile(
                icon: Icons.collections_bookmark_outlined,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                title: 'Product Catalogue',
                subtitle: 'Browse & select items from catalog',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteNames.products);
                },
              ),
              const SizedBox(height: 12),
              _buildMoreSheetTile(
                icon: Icons.note_add_outlined,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                title: 'Add Another Voucher',
                subtitle: 'Create another voucher without losing this one',
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddAnotherVoucherSheet();
                },
              ),
              const SizedBox(height: 12),
              _buildMoreSheetTile(
                icon: Icons.delete_outline,
                iconColor: AppColors.danger,
                iconBgColor: AppColors.danger.withValues(alpha: 0.1),
                title: 'Discard Invoice',
                titleColor: AppColors.danger,
                subtitle: 'Permanently remove this document',
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDiscardInvoice();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddAnotherVoucherSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add Another Voucher',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Select voucher type to create without losing current progress',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 20),
              _buildMoreSheetTile(
                icon: Icons.receipt_long_outlined,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                title: 'Add Sale',
                subtitle: 'Create a sale bill',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(
                    RouteNames.createInvoice,
                    extra: {'invoiceType': InvoiceType.sale},
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildMoreSheetTile(
                icon: Icons.assignment_return_outlined,
                iconColor: const Color(0xFF7C3AED),
                iconBgColor: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                title: 'Add Sales Return',
                subtitle: 'Create a sales return / credit note',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(
                    RouteNames.createReturn,
                    extra: {'returnType': ReturnType.salesReturn},
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildMoreSheetTile(
                icon: Icons.shopping_bag_outlined,
                iconColor: const Color(0xFF0D9488),
                iconBgColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
                title: 'Add Purchase',
                subtitle: 'Create a purchase bill',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(
                    RouteNames.createInvoice,
                    extra: {'invoiceType': InvoiceType.purchase},
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildMoreSheetTile(
                icon: Icons.assignment_return_outlined,
                iconColor: const Color(0xFFD97706),
                iconBgColor: const Color(0xFFD97706).withValues(alpha: 0.1),
                title: 'Add Purchase Return',
                subtitle: 'Create a purchase return / debit note',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(
                    RouteNames.createReturn,
                    extra: {'returnType': ReturnType.purchaseReturn},
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildMoreSheetTile(
                icon: Icons.arrow_upward_rounded,
                iconColor: AppColors.danger,
                iconBgColor: AppColors.danger.withValues(alpha: 0.1),
                title: 'Add Money Out',
                subtitle: 'Record an expense / money out',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteNames.expense);
                },
              ),
              const SizedBox(height: 10),
              _buildMoreSheetTile(
                icon: Icons.arrow_downward_rounded,
                iconColor: AppColors.success,
                iconBgColor: AppColors.success.withValues(alpha: 0.1),
                title: 'Add Money In',
                subtitle: 'Record an income / money in',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteNames.income);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool get _hasUnsavedData {
    return _items.isNotEmpty ||
        (!_isCashSale && _selectedCustomer != null) ||
        _notesCtrl.text.trim().isNotEmpty ||
        _discountAmount > 0 ||
        _extraExpenseAmount > 0;
  }

  void _safePop() {
    TransactionStackManager.instance
        .handleBackFromTransaction(context, _sessionId);
  }

  void _handleBackPressed() {
    TransactionStackManager.instance
        .handleBackFromTransaction(context, _sessionId);
  }

  void _confirmDiscardInvoice() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard Invoice?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'Are you sure you want to quit? The data you entered will be lost.'),
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
            onPressed: () {
              Navigator.pop(ctx);
              _safePop();
            },
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    TransactionStackManager.instance.unregisterSession(_sessionId);
    _scannerController?.dispose();
    _inlineSearchCtrl.dispose();
    _inlinePriceCtrl.dispose();
    _customerSearchCtrl.dispose();
    _searchFocusNode.dispose();
    _notesCtrl.dispose();
    _discountCtrl.dispose();
    _extraAmtCtrl.dispose();
    _extraDescCtrl.dispose();
    super.dispose();
  }

  List<CustomerEntity> get _filteredCustomers {
    final query = _customerSearchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _allCustomers;
    }
    final cleanQuery = query.replaceAll(RegExp(r'[\s\-\+]'), '');
    return _allCustomers.where((c) {
      final nameMatch = c.name.toLowerCase().contains(query);
      final phoneClean = c.phone.replaceAll(RegExp(r'[\s\-\+]'), '');
      final phoneMatch = phoneClean.contains(cleanQuery);
      return nameMatch || phoneMatch;
    }).toList();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  void _showEditPriceDialog(int index, InvoiceItemEntity item) {
    final priceCtrl =
        TextEditingController(text: item.unitPrice.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            isPurchase ? 'Purchase Price' : 'Selling Price',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit unit price for "${item.productName}". This price only applies to this invoice line item.',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: priceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary),
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  labelText: 'Unit Price',
                  border: OutlineInputBorder(),
                ),
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
              onPressed: () {
                final newPrice =
                    double.tryParse(priceCtrl.text.replaceAll(',', '')) ??
                        item.unitPrice;
                ref
                    .read(createInvoiceFormProvider.notifier)
                    .updateItemPrice(index, newPrice);
                Navigator.pop(ctx);
              },
              child: const Text('Update Price'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateCustomerDialog([String prefill = '']) {
    _searchFocusNode.unfocus();
    setState(() {
      _showSearchOverlay = false;
    });
    final isNumber = RegExp(r'^[0-9+\s]+$').hasMatch(prefill);
    final nameCtrl = TextEditingController(text: isNumber ? '' : prefill);
    final phoneCtrl = TextEditingController(text: isNumber ? prefill : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.blueTint,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: Icon(
                isPurchase
                    ? Icons.business_outlined
                    : Icons.person_add_alt_1_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPurchase ? 'Add New Supplier' : 'Add New Customer',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    isPurchase
                        ? 'Quickly register supplier'
                        : 'Quickly register customer',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: isPurchase ? 'Supplier Name *' : 'Full Name *',
              hint: isPurchase ? 'e.g. Acme Wholesalers' : 'e.g. Rajesh Kumar',
              controller: nameCtrl,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Phone Number',
              hint: 'e.g. 9876543210',
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                  ),
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isPurchase
                              ? 'Please enter supplier name'
                              : 'Please enter customer name'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    final phone = phoneCtrl.text.trim();
                    final nav = Navigator.of(ctx);

                    if (isPurchase) {
                      final newSup = SupplierEntity(
                        id: 'sup_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameCtrl.text.trim(),
                        companyName: nameCtrl.text.trim(),
                        phone: phone,
                        email: '',
                        address: '',
                        payableBalance: 0.0,
                        createdAt: DateTime.now(),
                      );
                      await getIt<PurchaseRepository>().createSupplier(newSup);
                      final mappedCust = CustomerEntity(
                        id: newSup.id,
                        name: newSup.name,
                        phone: newSup.phone,
                        email: newSup.email,
                        address: newSup.address,
                        outstandingBalance: 0.0,
                        createdAt: newSup.createdAt,
                      );
                      if (mounted) {
                        setState(() {
                          _allCustomers.insert(0, mappedCust);
                          ref
                              .read(createInvoiceFormProvider.notifier)
                              .selectCustomer(mappedCust);
                          _showSearchOverlay = false;
                          _customerSearchCtrl.clear();
                        });
                        nav.pop();
                      }
                    } else {
                      final newCust = CustomerEntity(
                        id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameCtrl.text.trim(),
                        phone: phone,
                        email: '',
                        address: '',
                        outstandingBalance: 0.0,
                        totalPurchases: 0.0,
                        createdAt: DateTime.now(),
                      );
                      await getIt<CustomerRepository>().createCustomer(newCust);
                      if (mounted) {
                        setState(() {
                          _allCustomers.insert(0, newCust);
                          ref
                              .read(createInvoiceFormProvider.notifier)
                              .selectCustomer(newCust);
                          _showSearchOverlay = false;
                          _customerSearchCtrl.clear();
                        });
                        nav.pop();
                      }
                    }
                  },
                  child: const Text(
                    'Save & Select',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int? _focusedItemIndex;

  void _loadProducts() async {
    try {
      final products = await getIt<ProductRepository>().getProducts();
      if (mounted) {
        setState(() {
          _allProducts = products;
        });
      }
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_scannerController == null ||
        !_scannerController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _scannerController?.stop();
    } else if (state == AppLifecycleState.resumed && _isCameraOn) {
      _scannerController?.start();
    }
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
      if (_isCameraOn) {
        _scannerController ??= MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          torchEnabled: false,
          autoStart: true,
        );
        _scannerController?.start();
      } else {
        _scannerController?.stop();
      }
    });
  }

  void _toggleFlash() async {
    if (_scannerController != null) {
      await _scannerController!.toggleTorch();
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final now = DateTime.now();
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue ?? barcode.displayValue;
      if (code == null || code.trim().isEmpty) continue;

      if (_lastScannedCode == code &&
          _lastScanTime != null &&
          now.difference(_lastScanTime!) < const Duration(milliseconds: 1500)) {
        continue;
      }

      _lastScanTime = now;
      _lastScannedCode = code;

      final cleanCode = code.trim().toLowerCase();
      final matchedProduct = _allProducts.cast<ProductEntity?>().firstWhere(
            (p) =>
                p != null &&
                (p.sku.trim().toLowerCase() == cleanCode ||
                    p.id.trim().toLowerCase() == cleanCode ||
                    p.name.trim().toLowerCase() == cleanCode),
            orElse: () => null,
          );

      if (matchedProduct != null) {
        setState(() {
          _isCameraOn = false;
          _showInlineAddProduct = true;
          _selectInlineProduct(matchedProduct);
        });
        _scannerController?.stop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scanned: ${matchedProduct.name}'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product not found'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
      break;
    }
  }

  void _selectInlineProduct(ProductEntity prod) {
    setState(() {
      _inlineSelectedProduct = prod;
      _inlineSearchCtrl.text = prod.name;
      _inlineSearchCtrl.selection =
          TextSelection.collapsed(offset: prod.name.length);
      _inlinePriceCtrl.text = prod.sellingPrice.toStringAsFixed(0);
      _inlineQuantity = 1;
      _showSearchResultsOverlay = false;
      _inlineProductError = false;
      _inlineProductErrorMsg = null;
      _inlineQuantityError = false;
      _inlineQuantityErrorMsg = null;
      _inlinePriceError = false;
      _inlinePriceErrorMsg = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _inlineSearchFocusNode.requestFocus();
      }
    });
  }

  List<ProductEntity> get _inlineSearchResults {
    final query = _inlineSearchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) return [];
    return _allProducts.where((p) {
      final nameMatch = p.name.toLowerCase().contains(query);
      final skuMatch = p.sku.toLowerCase().contains(query);
      final categoryMatch = p.category.toLowerCase().contains(query);
      return nameMatch || skuMatch || categoryMatch;
    }).toList();
  }

  void _openInlineAddProductCard() {
    setState(() {
      _showInlineAddProduct = true;
      _inlineProductError = false;
      _inlineProductErrorMsg = null;
      _inlineQuantityError = false;
      _inlineQuantityErrorMsg = null;
      _inlinePriceError = false;
      _inlinePriceErrorMsg = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _inlineSearchFocusNode.requestFocus();
        _scrollToInlineCard();
      }
    });
  }

  void _closeInlineAddProductCard() {
    _inlineSearchFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    if (mounted) {
      setState(() {
        _showInlineAddProduct = false;
        _showSearchResultsOverlay = false;
        _inlineSelectedProduct = null;
        _inlineSearchCtrl.clear();
        _inlinePriceCtrl.clear();
        _inlineQuantity = 1;
        _inlineProductError = false;
        _inlineProductErrorMsg = null;
        _inlineQuantityError = false;
        _inlineQuantityErrorMsg = null;
        _inlinePriceError = false;
        _inlinePriceErrorMsg = null;
      });
    }
  }

  void _addInlineProductToInvoice({bool closeAfterAdd = false}) {
    // Step 1 - Product Validation: A real product must be selected from search results
    if (_inlineSelectedProduct == null) {
      setState(() {
        _inlineProductError = true;
        _inlineProductErrorMsg = 'Please select a product';
        _showSearchResultsOverlay = false;
      });
      return;
    }

    // Step 2 - Quantity Validation
    if (_inlineQuantity <= 0) {
      setState(() {
        _inlineQuantityError = true;
        _inlineQuantityErrorMsg = 'Quantity must be greater than 0';
      });
      return;
    }

    // Step 3 - Unit Price Validation
    final priceText = _inlinePriceCtrl.text.trim();
    final double? parsedPrice = double.tryParse(priceText);
    if (priceText.isNotEmpty && (parsedPrice == null || parsedPrice < 0)) {
      setState(() {
        _inlinePriceError = true;
        _inlinePriceErrorMsg = 'Please enter a valid price';
      });
      return;
    }

    final double unitPrice =
        parsedPrice ?? _inlineSelectedProduct!.sellingPrice;

    final taxState = context.read<TaxSettingsBloc>().state;
    TaxSettingsEntity taxSettings = const TaxSettingsEntity();
    if (taxState is TaxSettingsLoadedState) {
      taxSettings = taxState.settings;
    }

    final double effectiveTaxRate = taxSettings.isGstEnabled
        ? (((_inlineSelectedProduct!.taxPercentage ?? 0.0) > 0)
            ? _inlineSelectedProduct!.taxPercentage!
            : taxSettings.defaultGstRate)
        : 0.0;

    final newItem = InvoiceItemEntity(
      productId: _inlineSelectedProduct!.id,
      productName: _inlineSelectedProduct!.name,
      sku: _inlineSelectedProduct!.sku,
      quantity: _inlineQuantity,
      unitPrice: unitPrice,
      taxPercentage: effectiveTaxRate,
    );

    final currentItems =
        List<InvoiceItemEntity>.from(ref.read(createInvoiceFormProvider).items);

    final existingIdx = currentItems.indexWhere((item) =>
        (item.productId.isNotEmpty && item.productId == newItem.productId) ||
        (item.productName.toLowerCase() == newItem.productName.toLowerCase()));

    if (existingIdx != -1) {
      final existingItem = currentItems[existingIdx];
      currentItems[existingIdx] = existingItem.copyWith(
        quantity: existingItem.quantity + newItem.quantity,
        unitPrice: unitPrice,
      );
    } else {
      currentItems.add(newItem);
    }

    ref.read(createInvoiceFormProvider.notifier).setItems(currentItems);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${newItem.productName}"'),
        backgroundColor: AppColors.darkBlueText,
        duration: const Duration(seconds: 2),
      ),
    );

    if (closeAfterAdd) {
      _closeInlineAddProductCard();
    } else {
      // Continuous Product Entry Mode: keep card visible & active, reset search & price, focus search field
      setState(() {
        _inlineSelectedProduct = null;
        _inlineSearchCtrl.clear();
        _inlinePriceCtrl.clear();
        _inlineQuantity = 1;
        _showSearchResultsOverlay = false;
        _showInlineAddProduct = true;
        _inlineProductError = false;
        _inlineProductErrorMsg = null;
        _inlineQuantityError = false;
        _inlineQuantityErrorMsg = null;
        _inlinePriceError = false;
        _inlinePriceErrorMsg = null;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _inlineSearchFocusNode.requestFocus();
          _scrollToInlineCard();
        }
      });
    }
  }

  void _updateItemQuantity(int index, int delta) {
    ref.read(createInvoiceFormProvider.notifier).updateQuantity(
      index,
      delta,
      (removedName) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$removedName removed'),
            backgroundColor: AppColors.darkBlueText,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _removeItem(int index) {
    ref.read(createInvoiceFormProvider.notifier).removeItem(
      index,
      (removedName) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$removedName removed'),
            backgroundColor: AppColors.darkBlueText,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  TaxSettingsEntity get _taxSettings {
    final taxState = context.read<TaxSettingsBloc>().state;
    if (taxState is TaxSettingsLoadedState) {
      return taxState.settings;
    }
    return const TaxSettingsEntity();
  }

  bool get _isGstEnabled => _taxSettings.isGstEnabled;
  bool get _gstEnabled => ref.watch(createInvoiceFormProvider).gstEnabled;

  double get rawSubtotal => ref.watch(createInvoiceFormProvider).rawSubtotal;
  double get calculatedDiscountTotal =>
      ref.watch(createInvoiceFormProvider).calculatedDiscountTotal;
  double get taxableAmount =>
      ref.watch(createInvoiceFormProvider).taxableAmount;
  double get taxTotal =>
      ref.watch(createInvoiceFormProvider).taxTotal(_taxSettings);
  double get grandTotal =>
      ref.watch(createInvoiceFormProvider).grandTotal(_taxSettings);

  double get _discountAmount =>
      ref.watch(createInvoiceFormProvider).discountAmount;
  bool get _discountIsPercentage =>
      ref.watch(createInvoiceFormProvider).discountIsPercentage;
  double get _extraExpenseAmount =>
      ref.watch(createInvoiceFormProvider).extraExpenseAmount;
  String get _extraExpenseDescription =>
      ref.watch(createInvoiceFormProvider).extraExpenseDescription;

  void _updateGstRate(double rate) {
    final updatedSettings = _taxSettings.copyWith(defaultGstRate: rate);
    context
        .read<TaxSettingsBloc>()
        .add(UpdateTaxSettingsEvent(updatedSettings));

    final currentItems = ref.read(createInvoiceFormProvider).items;
    if (currentItems.isNotEmpty) {
      final updatedItems = currentItems
          .map((item) => item.copyWith(taxPercentage: rate))
          .toList();
      ref.read(createInvoiceFormProvider.notifier).setItems(updatedItems);
    }
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: AppSizes.inputHeight,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium - 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }

  void _onCreateInvoice() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final String partyName = _isCashSale
        ? (isPurchase ? 'Cash Supplier' : 'Cash Customer')
        : (_selectedCustomer?.name ?? (isPurchase ? 'Supplier' : 'Customer'));

    final String partyPhone =
        _isCashSale ? 'N/A' : (_selectedCustomer?.phone ?? 'N/A');

    if (isEditMode) {
      final updatedInvoice = widget.invoiceToEdit!.copyWith(
        type: isPurchase ? InvoiceType.purchase : InvoiceType.sale,
        customerId: _selectedCustomer?.id ?? widget.invoiceToEdit!.customerId,
        customerName: partyName,
        customerPhone: partyPhone,
        items: _items,
        subtotal: rawSubtotal,
        taxTotal: taxTotal,
        discountTotal: calculatedDiscountTotal,
        grandTotal: grandTotal,
        notes: _notesCtrl.text,
        gstEnabled: _gstEnabled,
        discountAmount: _discountAmount,
        discountIsPercentage: _discountIsPercentage,
        extraExpenseAmount: _extraExpenseAmount,
        extraExpenseDescription: _extraExpenseDescription,
      );

      context
          .read<InvoiceBloc>()
          .add(UpdateInvoiceSubmittedEvent(updatedInvoice));
    } else {
      final invoiceToProcess = InvoiceEntity(
        id: isPurchase
            ? 'pur_${DateTime.now().millisecondsSinceEpoch}'
            : 'inv_${DateTime.now().millisecondsSinceEpoch}',
        invoiceNumber: _invoiceId,
        type: isPurchase ? InvoiceType.purchase : InvoiceType.sale,
        customerId: _isCashSale
            ? ''
            : (_selectedCustomer?.id ?? (isPurchase ? 'sup_101' : 'cust_101')),
        customerName: partyName,
        customerPhone: partyPhone,
        items: _items,
        subtotal: rawSubtotal,
        taxTotal: taxTotal,
        discountTotal: calculatedDiscountTotal,
        grandTotal: grandTotal,
        paidAmount: 0.0,
        status: InvoiceStatus.unpaid,
        issueDate: _createdDateTime,
        dueDate: _createdDateTime.add(Duration(days: isPurchase ? 30 : 10)),
        notes: _notesCtrl.text,
        gstEnabled: _gstEnabled,
        discountAmount: _discountAmount,
        discountIsPercentage: _discountIsPercentage,
        extraExpenseAmount: _extraExpenseAmount,
        extraExpenseDescription: _extraExpenseDescription,
      );

      context.push(
        RouteNames.payment,
        extra: {
          'invoice': invoiceToProcess,
          'customer': _selectedCustomer,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPressed();
      },
      child: BlocListener<InvoiceBloc, InvoiceState>(
        listener: (context, state) {
          if (isEditMode &&
              state is InvoiceOperationSuccessState &&
              state.isUpdate &&
              state.invoiceId == widget.invoiceToEdit?.id) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success),
            );
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: CommonVoucherAppBar(
              title: _docType.getAppBarTitle(isEditMode: isEditMode),
              onBackPressed: _handleBackPressed,
              onMorePressed: _showMoreBottomSheet,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer / Supplier Search Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildVoucherIdBanner(_invoiceId),
                        Row(
                          children: [
                            Icon(
                              isPurchase
                                  ? Icons.business_outlined
                                  : Icons.person_outline,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Party / Account',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '(Optional)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.outline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_selectedCustomer != null)
                          AppCard(
                            backgroundColor: AppColors.deepNavy,
                            border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.3)),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMedium),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _getInitials(_selectedCustomer!.name),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedCustomer!.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _selectedCustomer!.phone.isNotEmpty
                                            ? _selectedCustomer!.phone
                                            : 'Contact account',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _selectedCustomer!.outstandingBalance > 0
                                          ? 'PREVIOUS BALANCE'
                                          : 'STATUS',
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _selectedCustomer!.outstandingBalance > 0
                                          ? '₹${_selectedCustomer!.outstandingBalance.toStringAsFixed(0)}'
                                          : 'No Due',
                                      style: TextStyle(
                                        color: _selectedCustomer!
                                                    .outstandingBalance >
                                                0
                                            ? AppColors.warning
                                            : AppColors.success,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(
                                            createInvoiceFormProvider.notifier)
                                        .selectCustomer(null);
                                    _customerSearchCtrl.clear();
                                    _searchFocusNode.requestFocus();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        color: Colors.white70, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          TapRegion(
                            groupId: 'customer_search_tap_group',
                            onTapOutside: (_) {
                              if (_searchFocusNode.hasFocus) {
                                _searchFocusNode.unfocus();
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceCard,
                                borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium),
                                border: Border.all(
                                  color: _showSearchOverlay
                                      ? AppColors.primary
                                      : AppColors.surfaceContainerHigh,
                                  width: _showSearchOverlay ? 1.5 : 1.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _customerSearchCtrl,
                                    focusNode: _searchFocusNode,
                                    onChanged: (_) {
                                      setState(() {});
                                    },
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search party name or phone',
                                      hintStyle: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.outline,
                                      ),
                                      prefixIcon: const Icon(
                                          Icons.search_rounded,
                                          color: AppColors.outline,
                                          size: 20),
                                      suffixIcon:
                                          _customerSearchCtrl.text.isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(Icons.clear,
                                                      size: 18),
                                                  onPressed: () {
                                                    _customerSearchCtrl.clear();
                                                    setState(() {});
                                                  },
                                                )
                                              : null,
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 12),
                                    ),
                                  ),
                                  if (_showSearchOverlay) ...[
                                    const Divider(height: 1),
                                    Container(
                                      constraints:
                                          const BoxConstraints(maxHeight: 280),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: _filteredCustomers.isEmpty
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                            Icons.search_off,
                                                            size: 20,
                                                            color: AppColors
                                                                .outline),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                            isPurchase
                                                                ? 'Supplier not found'
                                                                : 'Customer not found',
                                                            style: const TextStyle(
                                                                color: AppColors
                                                                    .outline,
                                                                fontSize: 14)),
                                                      ],
                                                    ),
                                                  )
                                                : ListView.separated(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        _filteredCustomers
                                                            .length,
                                                    separatorBuilder: (_, __) =>
                                                        const Divider(
                                                            height: 1,
                                                            indent: 16,
                                                            endIndent: 16),
                                                    itemBuilder: (ctx, idx) {
                                                      final cust =
                                                          _filteredCustomers[
                                                              idx];
                                                      return InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            ref
                                                                .read(createInvoiceFormProvider
                                                                    .notifier)
                                                                .selectCustomer(
                                                                    cust);
                                                            _showSearchOverlay =
                                                                false;
                                                          });
                                                          _searchFocusNode
                                                              .unfocus();
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      16.0,
                                                                  vertical:
                                                                      12.0),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                width: 38,
                                                                height: 38,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: AppColors
                                                                      .surfaceContainerLow,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  border: Border.all(
                                                                      color: AppColors
                                                                          .border),
                                                                ),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                  _getInitials(
                                                                      cust.name),
                                                                  style:
                                                                      const TextStyle(
                                                                    color: AppColors
                                                                        .primary,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 12),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      cust.name,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                        fontSize:
                                                                            14,
                                                                        color: AppColors
                                                                            .onSurface,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    Text(
                                                                      cust.phone,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              AppColors.outline),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              cust.outstandingBalance >
                                                                      0
                                                                  ? Container(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              8,
                                                                          vertical:
                                                                              4),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: AppColors
                                                                            .warningTint,
                                                                        borderRadius:
                                                                            BorderRadius.circular(6),
                                                                        border: Border.all(
                                                                            color:
                                                                                AppColors.warning.withValues(alpha: 0.3)),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        'Pending Due · ₹${cust.outstandingBalance.toStringAsFixed(0)}',
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              11,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          color:
                                                                              AppColors.warning,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Container(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              8,
                                                                          vertical:
                                                                              4),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: AppColors
                                                                            .successTint,
                                                                        borderRadius:
                                                                            BorderRadius.circular(6),
                                                                        border: Border.all(
                                                                            color:
                                                                                AppColors.success.withValues(alpha: 0.3)),
                                                                      ),
                                                                      child:
                                                                          const Text(
                                                                        'No Due',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              11,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          color:
                                                                              AppColors.success,
                                                                        ),
                                                                      ),
                                                                    ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                          ),
                                          const Divider(height: 1),
                                          InkWell(
                                            onTap: () {
                                              // _searchFocusNode.unfocus();
                                              _showCreateCustomerDialog(
                                                  _customerSearchCtrl.text);
                                            },
                                            borderRadius:
                                                const BorderRadius.only(
                                              bottomLeft: Radius.circular(
                                                  AppSizes.radiusLarge),
                                              bottomRight: Radius.circular(
                                                  AppSizes.radiusLarge),
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              color:
                                                  AppColors.surfaceContainerLow,
                                              alignment: Alignment.center,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                      Icons.add_circle_outline,
                                                      size: 18,
                                                      color: AppColors.primary),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    isPurchase
                                                        ? 'Create New Supplier'
                                                        : 'Create New Customer',
                                                    style: const TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 14,
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
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TapRegion(
                      onTapOutside: (_) {
                        if (_focusedItemIndex != null ||
                            _showSearchResultsOverlay) {
                          setState(() {
                            _focusedItemIndex = null;
                            _showSearchResultsOverlay = false;
                          });
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Items',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: AppColors.darkBlueText,
                                ),
                              ),
                              if (_isCameraOn)
                                InkWell(
                                  onTap: _toggleCamera,
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusSmall),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorContainer,
                                      borderRadius: BorderRadius.circular(
                                          AppSizes.radiusSmall),
                                      border: Border.all(
                                          color: AppColors.danger
                                              .withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.videocam_off,
                                            size: 14, color: AppColors.danger),
                                        SizedBox(width: 4),
                                        Text(
                                          'Disable Camera',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.danger,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Inline Barcode / SKU Camera Scanner Preview
                          if (_isCameraOn && _scannerController != null) ...[
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusLarge),
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusLarge),
                                  border: Border.all(
                                      color: AppColors.primary, width: 2),
                                ),
                                child: Stack(
                                  children: [
                                    MobileScanner(
                                      controller: _scannerController!,
                                      onDetect: _onBarcodeDetected,
                                    ),
                                    Center(
                                      child: Container(
                                        width: 220,
                                        height: 110,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColors.primary,
                                              width: 2),
                                          borderRadius: BorderRadius.circular(
                                              AppSizes.radiusMedium),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: _toggleFlash,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withValues(alpha: 0.6),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    _isFlashOn
                                                        ? Icons.flash_on
                                                        : Icons.flash_off,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _isFlashOn
                                                        ? 'Flash ON'
                                                        : 'Flash OFF',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: _toggleCamera,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withValues(alpha: 0.6),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Icon(
                                                    Icons.videocam_off,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Cam OFF',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 12,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.65),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'Align Barcode / SKU in box',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Empty State (when no products added yet)
                          if (_items.isEmpty)
                            AppCard(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 32,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No products added yet',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _openInlineAddProductCard,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 18, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppSizes.radiusMedium),
                                          ),
                                        ),
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text(
                                          'Add Manually',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      OutlinedButton.icon(
                                        onPressed: _toggleCamera,
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              AppColors.darkBlueText,
                                          side: const BorderSide(
                                              color: AppColors.border),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppSizes.radiusMedium),
                                          ),
                                        ),
                                        icon: const Icon(Icons.qr_code_scanner,
                                            size: 18,
                                            color: AppColors.darkBlueText),
                                        label: const Text(
                                          'Scan to Add',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AppColors.darkBlueText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          else ...[
                            // Product List (when items exist)
                            ...List.generate(_items.length, (index) {
                              final item = _items[index];
                              final isFocused = _focusedItemIndex == index;

                              if (isFocused) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: AppCard(
                                    padding: const EdgeInsets.all(14),
                                    border: Border.all(
                                        color: AppColors.primary, width: 1.5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.productName,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: AppColors
                                                          .darkBlueText,
                                                    ),
                                                  ),
                                                  if (item.sku.isNotEmpty) ...[
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'SKU: ${item.sku}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors
                                                            .secondaryText,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () => _showEditPriceDialog(
                                                  index, item),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppColors
                                                      .primaryContainer,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                      color: AppColors.primary
                                                          .withValues(
                                                              alpha: 0.3)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      '₹${item.unitPrice.toStringAsFixed(0)}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: 15,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    const Icon(
                                                        Icons.edit_outlined,
                                                        size: 14,
                                                        color:
                                                            AppColors.primary),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.pageBackground,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppSizes.radiusMedium),
                                                border: Border.all(
                                                    color: AppColors.border),
                                              ),
                                              child: Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () =>
                                                        _updateItemQuantity(
                                                            index, -1),
                                                    child: Container(
                                                      width: 34,
                                                      height: 34,
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Icon(
                                                          Icons.remove,
                                                          size: 16,
                                                          color: AppColors
                                                              .darkBlueText),
                                                    ),
                                                  ),
                                                  Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                            minWidth: 32),
                                                    height: 34,
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      '${item.quantity}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14,
                                                        color: AppColors
                                                            .darkBlueText,
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () =>
                                                        _updateItemQuantity(
                                                            index, 1),
                                                    child: Container(
                                                      width: 34,
                                                      height: 34,
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Icon(
                                                          Icons.add,
                                                          size: 16,
                                                          color: AppColors
                                                              .darkBlueText),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              'Sub: ₹${item.subtotal.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            GestureDetector(
                                              onTap: () => _removeItem(index),
                                              child: const Icon(Icons.close,
                                                  size: 18,
                                                  color: AppColors.error),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              // Compact Product Card (Default)
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: AppCard(
                                  padding: const EdgeInsets.all(14),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _focusedItemIndex = index;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMedium),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.productName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: AppColors.darkBlueText,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _isGstEnabled && _gstEnabled
                                                    ? '${item.quantity} × ₹${item.unitPrice.toStringAsFixed(0)} (${(item.taxPercentage > 0 ? item.taxPercentage : _taxSettings.defaultGstRate).toStringAsFixed(0)}% GST)'
                                                    : '${item.quantity} × ₹${item.unitPrice.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.secondaryText,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.pageBackground,
                                            borderRadius: BorderRadius.circular(
                                                AppSizes.radiusMedium),
                                            border: Border.all(
                                                color: AppColors.border),
                                          ),
                                          child: Row(
                                            children: [
                                              InkWell(
                                                onTap: () =>
                                                    _updateItemQuantity(
                                                        index, -1),
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  alignment: Alignment.center,
                                                  child: const Icon(
                                                      Icons.remove,
                                                      size: 14,
                                                      color: AppColors
                                                          .darkBlueText),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6),
                                                child: Text(
                                                  '${item.quantity}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13,
                                                    color:
                                                        AppColors.darkBlueText,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () =>
                                                    _updateItemQuantity(
                                                        index, 1),
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  alignment: Alignment.center,
                                                  child: const Icon(Icons.add,
                                                      size: 14,
                                                      color: AppColors
                                                          .darkBlueText),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '₹${(item.quantity * item.unitPrice).toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                            color: AppColors.darkBlueText,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () => _removeItem(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: AppColors.errorContainer,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close,
                                                size: 14,
                                                color: AppColors.error),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _openInlineAddProductCard,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppSizes.radiusMedium),
                                      ),
                                    ),
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text(
                                      'Add More',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton.icon(
                                  onPressed: _toggleCamera,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.darkBlueText,
                                    side: const BorderSide(
                                        color: AppColors.border),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppSizes.radiusMedium),
                                    ),
                                  ),
                                  icon: const Icon(Icons.qr_code_scanner,
                                      size: 18, color: AppColors.darkBlueText),
                                  label: const Text(
                                    'Scan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.darkBlueText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Inline Add Product Form Section
                          AnimatedCrossFade(
                            firstChild: const SizedBox(
                                width: double.infinity, height: 0),
                            secondChild: Padding(
                              padding: const EdgeInsets.only(top: 14.0),
                              child: TapRegion(
                                groupId: 'inline_add_product_card_group',
                                onTapOutside: (_) {
                                  if (_showInlineAddProduct) {
                                    _closeInlineAddProductCard();
                                  }
                                },
                                child: AppCard(
                                  key: _inlineCardKey,
                                  padding: const EdgeInsets.all(16),
                                  border: Border.all(
                                      color: AppColors.primary, width: 1.5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'ADD PRODUCT',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.secondaryText,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: _closeInlineAddProductCard,
                                            child: const Icon(Icons.close,
                                                size: 18,
                                                color: AppColors.secondaryText),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      // Search / Product Name Field with Dropdown Overlay
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'PRODUCT NAME',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.secondaryText,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          SizedBox(
                                            height: AppSizes.inputHeight,
                                            child: TextField(
                                              controller: _inlineSearchCtrl,
                                              focusNode: _inlineSearchFocusNode,
                                              textInputAction:
                                                  TextInputAction.next,
                                              onEditingComplete: () {
                                                _inlineSearchFocusNode
                                                    .unfocus();
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                                setState(() {
                                                  _showSearchResultsOverlay =
                                                      false;
                                                });
                                              },
                                              onSubmitted: (_) {
                                                _closeInlineAddProductCard();
                                              },
                                              onTap: () {
                                                _scrollToInlineCard();
                                                if (_inlineSearchCtrl.text
                                                        .trim()
                                                        .isNotEmpty &&
                                                    _inlineSelectedProduct ==
                                                        null) {
                                                  setState(() {
                                                    _showSearchResultsOverlay =
                                                        true;
                                                  });
                                                }
                                              },
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.darkBlueText,
                                              ),
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Search product name, SKU or ID',
                                                hintStyle: const TextStyle(
                                                  color:
                                                      AppColors.secondaryText,
                                                  fontSize: 13,
                                                ),
                                                prefixIcon: const Icon(
                                                    Icons.search,
                                                    size: 18,
                                                    color: AppColors
                                                        .secondaryText),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 12),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppSizes
                                                              .radiusMedium),
                                                  borderSide: BorderSide(
                                                    color: _inlineProductError
                                                        ? AppColors.error
                                                        : AppColors.border,
                                                    width: _inlineProductError
                                                        ? 1.5
                                                        : 1.0,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppSizes
                                                              .radiusMedium),
                                                  borderSide: BorderSide(
                                                    color: _inlineProductError
                                                        ? AppColors.error
                                                        : AppColors.border,
                                                    width: _inlineProductError
                                                        ? 1.5
                                                        : 1.0,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppSizes
                                                              .radiusMedium),
                                                  borderSide: BorderSide(
                                                    color: _inlineProductError
                                                        ? AppColors.error
                                                        : AppColors.primary,
                                                    width: 1.5,
                                                  ),
                                                ),
                                              ),
                                              onChanged: (val) {
                                                setState(() {
                                                  if (_inlineSelectedProduct !=
                                                          null &&
                                                      val.trim() !=
                                                          _inlineSelectedProduct!
                                                              .name) {
                                                    _inlineSelectedProduct =
                                                        null;
                                                  }
                                                  if (_inlineProductError) {
                                                    _inlineProductError = false;
                                                    _inlineProductErrorMsg =
                                                        null;
                                                  }
                                                  _showSearchResultsOverlay = val
                                                          .trim()
                                                          .isNotEmpty &&
                                                      _inlineSelectedProduct ==
                                                          null;
                                                });
                                              },
                                            ),
                                          ),

                                          if (_inlineProductError &&
                                              _inlineProductErrorMsg != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4, left: 4),
                                              child: Text(
                                                _inlineProductErrorMsg!,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.error,
                                                ),
                                              ),
                                            ),

                                          // Floating Search Results Dropdown Overlay
                                          if (_showSearchResultsOverlay &&
                                              _inlineSearchCtrl.text
                                                  .trim()
                                                  .isNotEmpty &&
                                              _inlineSelectedProduct == null)
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 4),
                                              constraints: const BoxConstraints(
                                                  maxHeight: 180),
                                              decoration: BoxDecoration(
                                                color: AppColors.surfaceCard,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppSizes.radiusMedium),
                                                border: Border.all(
                                                    color: AppColors.border),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                            alpha: 0.08),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: _inlineSearchResults
                                                      .isNotEmpty
                                                  ? ListView.separated(
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.zero,
                                                      itemCount:
                                                          _inlineSearchResults
                                                              .length,
                                                      separatorBuilder: (_,
                                                              __) =>
                                                          const Divider(
                                                              height: 1,
                                                              color: AppColors
                                                                  .border),
                                                      itemBuilder:
                                                          (context, idx) {
                                                        final prod =
                                                            _inlineSearchResults[
                                                                idx];
                                                        return ListTile(
                                                          dense: true,
                                                          title: Text(
                                                            prod.name,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 14,
                                                              color: AppColors
                                                                  .darkBlueText,
                                                            ),
                                                          ),
                                                          subtitle: prod.sku
                                                                  .isNotEmpty
                                                              ? Text(
                                                                  'SKU: ${prod.sku}',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: AppColors
                                                                        .secondaryText,
                                                                  ),
                                                                )
                                                              : null,
                                                          trailing: Text(
                                                            '₹${prod.sellingPrice.toStringAsFixed(2)}',
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              fontSize: 14,
                                                              color: AppColors
                                                                  .primary,
                                                            ),
                                                          ),
                                                          onTap: () =>
                                                              _selectInlineProduct(
                                                                  prod),
                                                        );
                                                      },
                                                    )
                                                  : const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 14,
                                                              vertical: 12),
                                                      child: Text(
                                                        'No products found',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppColors
                                                              .secondaryText,
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),

                                      // Quantity & Unit Price Controls Row
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'QUANTITY',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        AppColors.secondaryText,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Container(
                                                  height: AppSizes.inputHeight,
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .pageBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            AppSizes
                                                                .radiusMedium),
                                                    border: Border.all(
                                                      color: _inlineQuantityError
                                                          ? AppColors.error
                                                          : AppColors.border,
                                                      width: _inlineQuantityError
                                                          ? 1.5
                                                          : 1.0,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          if (_inlineQuantity >
                                                              1) {
                                                            setState(() {
                                                              _inlineQuantity--;
                                                              if (_inlineQuantityError) {
                                                                _inlineQuantityError =
                                                                    false;
                                                                _inlineQuantityErrorMsg =
                                                                    null;
                                                              }
                                                            });
                                                          }
                                                        },
                                                        child: Container(
                                                          width: 36,
                                                          height: AppSizes
                                                              .inputHeight,
                                                          alignment:
                                                              Alignment.center,
                                                          child: const Icon(
                                                              Icons.remove,
                                                              size: 18,
                                                              color: AppColors
                                                                  .darkBlueText),
                                                        ),
                                                      ),
                                                      Text(
                                                        '$_inlineQuantity',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: AppColors
                                                              .darkBlueText,
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _inlineQuantity++;
                                                            if (_inlineQuantityError) {
                                                              _inlineQuantityError =
                                                                  false;
                                                              _inlineQuantityErrorMsg =
                                                                  null;
                                                            }
                                                          });
                                                        },
                                                        child: Container(
                                                          width: 36,
                                                          height: AppSizes
                                                              .inputHeight,
                                                          alignment:
                                                              Alignment.center,
                                                          child: const Icon(
                                                              Icons.add,
                                                              size: 18,
                                                              color: AppColors
                                                                  .darkBlueText),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (_inlineQuantityError &&
                                                    _inlineQuantityErrorMsg !=
                                                        null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4, left: 4),
                                                    child: Text(
                                                      _inlineQuantityErrorMsg!,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors.error,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            flex: 1,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'UNIT PRICE (₹)',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        AppColors.secondaryText,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                SizedBox(
                                                  height: AppSizes.inputHeight,
                                                  child: TextField(
                                                    controller:
                                                        _inlinePriceCtrl,
                                                    keyboardType:
                                                        const TextInputType
                                                            .numberWithOptions(
                                                            decimal: true),
                                                    textInputAction:
                                                        TextInputAction.done,
                                                    onEditingComplete: () {
                                                      _closeInlineAddProductCard();
                                                    },
                                                    onSubmitted: (_) {
                                                      _closeInlineAddProductCard();
                                                    },
                                                    onTapOutside: (_) =>
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus(),
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppColors
                                                          .darkBlueText,
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText: '0',
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 14,
                                                              vertical: 12),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius: BorderRadius
                                                            .circular(AppSizes
                                                                .radiusMedium),
                                                        borderSide: BorderSide(
                                                          color:
                                                              _inlinePriceError
                                                                  ? AppColors
                                                                      .error
                                                                  : AppColors
                                                                      .border,
                                                          width:
                                                              _inlinePriceError
                                                                  ? 1.5
                                                                  : 1.0,
                                                        ),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius: BorderRadius
                                                            .circular(AppSizes
                                                                .radiusMedium),
                                                        borderSide: BorderSide(
                                                          color:
                                                              _inlinePriceError
                                                                  ? AppColors
                                                                      .error
                                                                  : AppColors
                                                                      .border,
                                                          width:
                                                              _inlinePriceError
                                                                  ? 1.5
                                                                  : 1.0,
                                                        ),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius: BorderRadius
                                                            .circular(AppSizes
                                                                .radiusMedium),
                                                        borderSide: BorderSide(
                                                          color:
                                                              _inlinePriceError
                                                                  ? AppColors
                                                                      .error
                                                                  : AppColors
                                                                      .primary,
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                    ),
                                                    onChanged: (_) {
                                                      setState(() {
                                                        if (_inlinePriceError) {
                                                          _inlinePriceError =
                                                              false;
                                                          _inlinePriceErrorMsg =
                                                              null;
                                                        }
                                                      });
                                                    },
                                                  ),
                                                ),
                                                if (_inlinePriceError &&
                                                    _inlinePriceErrorMsg !=
                                                        null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4, left: 4),
                                                    child: Text(
                                                      _inlinePriceErrorMsg!,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors.error,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),

                                      // Calculated Line Total Display
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Line Total',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.secondaryText,
                                            ),
                                          ),
                                          Text(
                                            '₹${(_inlineQuantity * (double.tryParse(_inlinePriceCtrl.text) ?? 0.0)).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // Action Buttons (Cancel / Add Product)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed:
                                                  _closeInlineAddProductCard,
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    AppColors.darkBlueText,
                                                side: const BorderSide(
                                                    color: AppColors.border),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppSizes
                                                              .radiusMedium),
                                                ),
                                              ),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  _addInlineProductToInvoice(
                                                      closeAfterAdd: false),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primary,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppSizes
                                                              .radiusMedium),
                                                ),
                                              ),
                                              child: const Text(
                                                'Add Product',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            crossFadeState: _showInlineAddProduct
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 250),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // GST Enable/Disable & Expandable Card (If global GST is enabled)
                    if (_isGstEnabled) ...[
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isGstExpanded = !_isGstExpanded;
                                });
                              },
                              borderRadius: BorderRadius.only(
                                topLeft:
                                    const Radius.circular(AppSizes.radiusLarge),
                                topRight:
                                    const Radius.circular(AppSizes.radiusLarge),
                                bottomLeft: Radius.circular(
                                    _isGstExpanded ? 0 : AppSizes.radiusLarge),
                                bottomRight: Radius.circular(
                                    _isGstExpanded ? 0 : AppSizes.radiusLarge),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                            AppSizes.radiusSmall),
                                      ),
                                      child: const Icon(
                                        Icons.receipt_long_outlined,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Apply GST Tax',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.darkBlueText,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _gstEnabled
                                                ? 'On • ${_taxSettings.defaultGstRate.toStringAsFixed(0)}% applied'
                                                : 'Off',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.secondaryText,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch.adaptive(
                                      value: _gstEnabled,
                                      activeTrackColor: AppColors.primary,
                                      onChanged: (val) => ref
                                          .read(createInvoiceFormProvider
                                              .notifier)
                                          .toggleGst(val),
                                    ),
                                    const SizedBox(width: 4),
                                    AnimatedRotation(
                                      turns: _isGstExpanded ? 0.5 : 0.0,
                                      duration:
                                          const Duration(milliseconds: 250),
                                      child: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: AppColors.secondaryText,
                                        size: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedCrossFade(
                              firstChild: const SizedBox(
                                  width: double.infinity, height: 0),
                              secondChild: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(
                                      height: 1, color: AppColors.border),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Opacity(
                                      opacity: _gstEnabled ? 1.0 : 0.4,
                                      child: IgnorePointer(
                                        ignoring: !_gstEnabled,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'GST RATE',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.secondaryText,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [5.0, 12.0, 18.0, 28.0]
                                                  .map((rate) {
                                                final isSelected = (_taxSettings
                                                                .defaultGstRate -
                                                            rate)
                                                        .abs() <
                                                    0.01;
                                                return Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 4.0),
                                                    child: InkWell(
                                                      onTap: () =>
                                                          _updateGstRate(rate),
                                                      borderRadius: BorderRadius
                                                          .circular(AppSizes
                                                              .radiusMedium),
                                                      child: AnimatedContainer(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    200),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isSelected
                                                              ? AppColors
                                                                  .primaryContainer
                                                              : AppColors
                                                                  .surfaceCard,
                                                          borderRadius: BorderRadius
                                                              .circular(AppSizes
                                                                  .radiusMedium),
                                                          border: Border.all(
                                                            color: isSelected
                                                                ? AppColors
                                                                    .primary
                                                                : AppColors
                                                                    .border,
                                                            width: isSelected
                                                                ? 1.5
                                                                : 1.0,
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            '${rate.toStringAsFixed(0)}%',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: isSelected
                                                                  ? AppColors
                                                                      .primary
                                                                  : AppColors
                                                                      .darkBlueText,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              crossFadeState: _isGstExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 250),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Discount & Extra Charges Expandable Card
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isDiscountExpanded = !_isDiscountExpanded;
                              });
                            },
                            borderRadius: BorderRadius.only(
                              topLeft:
                                  const Radius.circular(AppSizes.radiusLarge),
                              topRight:
                                  const Radius.circular(AppSizes.radiusLarge),
                              bottomLeft: Radius.circular(_isDiscountExpanded
                                  ? 0
                                  : AppSizes.radiusLarge),
                              bottomRight: Radius.circular(_isDiscountExpanded
                                  ? 0
                                  : AppSizes.radiusLarge),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      borderRadius: BorderRadius.circular(
                                          AppSizes.radiusSmall),
                                    ),
                                    child: const Icon(
                                      Icons.local_offer_outlined,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Discount & Extra Charges',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkBlueText,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Discount: ${_discountIsPercentage ? '${_discountAmount.toStringAsFixed(0)}%' : '₹${_discountAmount.toStringAsFixed(0)}'}   Extra: ₹${_extraExpenseAmount.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.secondaryText,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedRotation(
                                    turns: _isDiscountExpanded ? 0.5 : 0.0,
                                    duration: const Duration(milliseconds: 250),
                                    child: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: AppColors.secondaryText,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AnimatedCrossFade(
                            firstChild: const SizedBox(
                                width: double.infinity, height: 0),
                            secondChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(
                                    height: 1, color: AppColors.border),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'DISCOUNT AMOUNT',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.secondaryText,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: AppSizes.inputHeight,
                                              child: TextField(
                                                controller: _discountCtrl,
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                                onTapOutside: (_) =>
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus(),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.darkBlueText,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: '0',
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 14,
                                                          vertical: 12),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            AppSizes
                                                                .radiusMedium),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: AppColors
                                                                .border),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            AppSizes
                                                                .radiusMedium),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: AppColors
                                                                .border),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            AppSizes
                                                                .radiusMedium),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: AppColors
                                                                .primary,
                                                            width: 1.5),
                                                  ),
                                                ),
                                                onChanged: (val) {
                                                  final d =
                                                      double.tryParse(val) ??
                                                          0.0;
                                                  ref
                                                      .read(
                                                          createInvoiceFormProvider
                                                              .notifier)
                                                      .updateDiscount(d,
                                                          _discountIsPercentage);
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            height: AppSizes.inputHeight,
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceCard,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppSizes.radiusMedium),
                                              border: Border.all(
                                                  color: AppColors.border),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                _buildSegmentButton(
                                                  label: '₹',
                                                  isSelected:
                                                      !_discountIsPercentage,
                                                  onTap: () {
                                                    ref
                                                        .read(
                                                            createInvoiceFormProvider
                                                                .notifier)
                                                        .updateDiscount(
                                                            _discountAmount,
                                                            false);
                                                  },
                                                ),
                                                _buildSegmentButton(
                                                  label: '%',
                                                  isSelected:
                                                      _discountIsPercentage,
                                                  onTap: () {
                                                    ref
                                                        .read(
                                                            createInvoiceFormProvider
                                                                .notifier)
                                                        .updateDiscount(
                                                            _discountAmount,
                                                            true);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'EXTRA EXPENSE AMOUNT',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.secondaryText,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: AppSizes.inputHeight,
                                        child: TextField(
                                          controller: _extraAmtCtrl,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          onTapOutside: (_) => FocusManager
                                              .instance.primaryFocus
                                              ?.unfocus(),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.darkBlueText,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '0',
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 12),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppSizes.radiusMedium),
                                              borderSide: const BorderSide(
                                                  color: AppColors.border),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppSizes.radiusMedium),
                                              borderSide: const BorderSide(
                                                  color: AppColors.border),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppSizes.radiusMedium),
                                              borderSide: const BorderSide(
                                                  color: AppColors.primary,
                                                  width: 1.5),
                                            ),
                                          ),
                                          onChanged: (val) {
                                            final amt =
                                                double.tryParse(val) ?? 0.0;
                                            ref
                                                .read(createInvoiceFormProvider
                                                    .notifier)
                                                .updateExtraExpense(
                                                    amt, _extraDescCtrl.text);
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'EXPENSE NOTE',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.secondaryText,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: AppSizes.inputHeight,
                                        child: TextField(
                                          controller: _extraDescCtrl,
                                          onTapOutside: (_) => FocusManager
                                              .instance.primaryFocus
                                              ?.unfocus(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.darkBlueText,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'e.g. Delivery charge',
                                            hintStyle: const TextStyle(
                                              color: AppColors.secondaryText,
                                              fontSize: 14,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 12),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppSizes.radiusMedium),
                                              borderSide: const BorderSide(
                                                  color: AppColors.border),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppSizes.radiusMedium),
                                              borderSide: const BorderSide(
                                                  color: AppColors.border),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppSizes.radiusMedium),
                                              borderSide: const BorderSide(
                                                  color: AppColors.primary,
                                                  width: 1.5),
                                            ),
                                          ),
                                          onChanged: (val) {
                                            ref
                                                .read(createInvoiceFormProvider
                                                    .notifier)
                                                .updateExtraExpense(
                                                    _extraExpenseAmount, val);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            crossFadeState: _isDiscountExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 250),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    VoucherSummaryCard(
                      subtotal: rawSubtotal,
                      totalTax: taxTotal,
                      discountAmount: calculatedDiscountTotal,
                      extraCharges: _extraExpenseAmount,
                      grandTotal: grandTotal,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 12 + MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Total = ₹${grandTotal.toStringAsFixed(2)} /-',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: BlocBuilder<InvoiceBloc, InvoiceState>(
                      builder: (context, state) {
                        return AppButton(
                          text: isEditMode
                              ? 'Update Invoice'
                              : 'Proceed to Payment',
                          onPressed: _onCreateInvoice,
                          isLoading: state is InvoiceLoadingState,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
