import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';

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

class _CreateInvoicePageState extends ConsumerState<CreateInvoicePage> {
  bool get isEditMode => widget.invoiceToEdit != null;
  bool get isPurchase =>
      (widget.invoiceToEdit?.type ?? widget.invoiceType) ==
      InvoiceType.purchase;

  bool get _isCashSale => _selectedCustomer == null;
  late String _invoiceId;
  final TextEditingController _customerSearchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchOverlay = false;

  List<CustomerEntity> _allCustomers = [];

  late TextEditingController _notesCtrl;
  late TextEditingController _discountCtrl;
  late TextEditingController _extraAmtCtrl;
  late TextEditingController _extraDescCtrl;

  @override
  void initState() {
    super.initState();

    _notesCtrl = TextEditingController(text: 'Thank you for your business!');
    _discountCtrl = TextEditingController();
    _extraAmtCtrl = TextEditingController();
    _extraDescCtrl = TextEditingController();

    _invoiceId = isEditMode
        ? widget.invoiceToEdit!.invoiceNumber
        : (isPurchase
            ? 'PUR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
            : 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');

    _loadParties();

    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _showSearchOverlay = _searchFocusNode.hasFocus;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isEditMode) {
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

  @override
  void dispose() {
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

  List<InvoiceItemEntity> get _items =>
      ref.watch(createInvoiceFormProvider).items;
  CustomerEntity? get _selectedCustomer =>
      ref.watch(createInvoiceFormProvider).selectedCustomer;
  DateTime get _createdDateTime =>
      ref.watch(createInvoiceFormProvider).createdDateTime;

  Future<void> _navigateToAddProducts() async {
    final currentItems = ref.read(createInvoiceFormProvider).items;
    final updatedItems = await context.push<List<InvoiceItemEntity>>(
      RouteNames.addProducts,
      extra: currentItems,
    );
    if (updatedItems != null) {
      ref.read(createInvoiceFormProvider.notifier).setItems(updatedItems);
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
  bool get _isIgst => ref.watch(createInvoiceFormProvider).isIgst(_taxSettings);

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
    final formattedDateTime =
        DateFormat('dd MMM, h:mm a').format(_createdDateTime);

    return BlocListener<InvoiceBloc, InvoiceState>(
      listener: (context, state) {
        if (state is InvoiceOperationSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success),
          );
          Navigator.pop(context);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Row
                  Row(
                    children: [
                      // Back Button Card
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMedium),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMedium),
                            border: Border.all(
                                color: AppColors.surfaceContainerHigh),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            color: AppColors.onSurface,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditMode
                                ? (isPurchase
                                    ? 'Edit Purchase Invoice'
                                    : 'Edit Sale Invoice')
                                : (isPurchase
                                    ? 'New Purchase Invoice'
                                    : 'New Sale Invoice'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _invoiceId,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlueText,
                            ),
                          ),
                          Text(
                            formattedDateTime,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.outline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Customer / Supplier Search Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            isPurchase
                                ? 'Supplier / Account'
                                : 'Customer / Account',
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
                              color: AppColors.primary.withValues(alpha: 0.3)),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      .read(createInvoiceFormProvider.notifier)
                                      .selectCustomer(null);
                                  _customerSearchCtrl.clear();
                                  _searchFocusNode.requestFocus();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
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
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusMedium),
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
                                  hintText: isPurchase
                                      ? 'Search supplier name or phone'
                                      : 'Search customer name or phone',
                                  hintStyle: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.outline,
                                  ),
                                  prefixIcon: const Icon(Icons.search_rounded,
                                      color: AppColors.outline, size: 20),
                                  suffixIcon: _customerSearchCtrl
                                          .text.isNotEmpty
                                      ? IconButton(
                                          icon:
                                              const Icon(Icons.clear, size: 18),
                                          onPressed: () {
                                            _customerSearchCtrl.clear();
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
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
                                                    const EdgeInsets.all(20.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.search_off,
                                                        size: 20,
                                                        color:
                                                            AppColors.outline),
                                                    const SizedBox(width: 8),
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
                                                    _filteredCustomers.length,
                                                separatorBuilder: (_, __) =>
                                                    const Divider(
                                                        height: 1,
                                                        indent: 16,
                                                        endIndent: 16),
                                                itemBuilder: (ctx, idx) {
                                                  final cust =
                                                      _filteredCustomers[idx];
                                                  return InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        ref
                                                            .read(
                                                                createInvoiceFormProvider
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
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16.0,
                                                          vertical: 12.0),
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
                                                            alignment: Alignment
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
                                                                fontSize: 14,
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
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        14,
                                                                    color: AppColors
                                                                        .onSurface,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 2),
                                                                Text(
                                                                  cust.phone,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: AppColors
                                                                          .outline),
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
                                                                        BorderRadius
                                                                            .circular(6),
                                                                    border: Border.all(
                                                                        color: AppColors
                                                                            .warning
                                                                            .withValues(alpha: 0.3)),
                                                                  ),
                                                                  child: Text(
                                                                    'Pending Due · ₹${cust.outstandingBalance.toStringAsFixed(0)}',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: AppColors
                                                                          .warning,
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
                                                                        BorderRadius
                                                                            .circular(6),
                                                                    border: Border.all(
                                                                        color: AppColors
                                                                            .success
                                                                            .withValues(alpha: 0.3)),
                                                                  ),
                                                                  child:
                                                                      const Text(
                                                                    'No Due',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: AppColors
                                                                          .success,
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
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(
                                              AppSizes.radiusLarge),
                                          bottomRight: Radius.circular(
                                              AppSizes.radiusLarge),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          color: AppColors.surfaceContainerLow,
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
                                                  fontWeight: FontWeight.w700,
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
                      if (_focusedItemIndex != null) {
                        setState(() {
                          _focusedItemIndex = null;
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
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.onSurface,
                              ),
                            ),
                            if (_items.isNotEmpty)
                              TextButton.icon(
                                onPressed: _navigateToAddProducts,
                                icon: const Icon(Icons.add_shopping_cart,
                                    size: 18),
                                label: const Text(
                                  'Add Item',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_items.isEmpty)
                          AppCard(
                            padding: const EdgeInsets.all(28),
                            child: Center(
                              child: InkWell(
                                onTap: _navigateToAddProducts,
                                borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: AppColors.blueTint,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.add_shopping_cart,
                                          size: 28,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No products added yet',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.outline,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.add,
                                              size: 18,
                                              color: AppColors.primary),
                                          SizedBox(width: 6),
                                          Text(
                                            'Add Product',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          // List of items
                          ...List.generate(_items.length, (index) {
                            final item = _items[index];
                            final isFocused = _focusedItemIndex == index;

                            if (isFocused) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: AppCard(
                                  padding: const EdgeInsets.all(16),
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title & Editable Unit Price
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
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.onSurface,
                                                  ),
                                                ),
                                                if (item.sku.isNotEmpty) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'SKU: ${item.sku}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.outline,
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
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.1),
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
                                                          FontWeight.w900,
                                                      fontSize: 16,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(
                                                      Icons.edit_outlined,
                                                      size: 14,
                                                      color: AppColors.primary),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),

                                      // Quantity controls & Subtotal / Remove
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColors.surfaceContainerLow,
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                                    width: 36,
                                                    height: 36,
                                                    alignment: Alignment.center,
                                                    child: const Icon(
                                                        Icons.remove,
                                                        size: 16,
                                                        color: AppColors
                                                            .onSurface),
                                                  ),
                                                ),
                                                Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                          minWidth: 38),
                                                  height: 36,
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '${item.quantity}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 15,
                                                      color:
                                                          AppColors.onSurface,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () =>
                                                      _updateItemQuantity(
                                                          index, 1),
                                                  child: Container(
                                                    width: 36,
                                                    height: 36,
                                                    alignment: Alignment.center,
                                                    child: const Icon(Icons.add,
                                                        size: 16,
                                                        color: AppColors
                                                            .onSurface),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Sub: ₹${item.subtotal.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.outline,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              GestureDetector(
                                                onTap: () => _removeItem(index),
                                                child: const Text(
                                                  'Remove',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.error,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            // Compact Product Card (Reference Image 1 Style)
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: AppCard(
                                padding: const EdgeInsets.all(14),
                                border: Border.all(
                                  color: AppColors.surfaceContainerHigh,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _focusedItemIndex = index;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusMedium),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                                color: AppColors.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _isGstEnabled && _gstEnabled
                                                  ? '${item.quantity} × ₹${item.unitPrice.toStringAsFixed(0)} (${(item.taxPercentage > 0 ? item.taxPercentage : _taxSettings.defaultGstRate).toStringAsFixed(0)}% GST)'
                                                  : '${item.quantity} × ₹${item.unitPrice.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                color: AppColors.outline,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () =>
                                            _showEditPriceDialog(index, item),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.08),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.2)),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                '₹${(item.quantity * item.unitPrice).toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(Icons.edit_outlined,
                                                  size: 14,
                                                  color: AppColors.primary),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // GST Enable/Disable Toggle Card (If global GST is enabled)
                  if (_isGstEnabled) ...[
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.receipt_long_outlined,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 10),
                              const Text(
                                'Apply GST Tax',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkBlueText),
                              ),
                            ],
                          ),
                          Switch.adaptive(
                            value: _gstEnabled,
                            activeTrackColor: AppColors.primary,
                            onChanged: (val) => ref
                                .read(createInvoiceFormProvider.notifier)
                                .toggleGst(val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Discount & Extra Expense Controls Card
                  AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Discount & Extra Expense',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlueText),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _discountCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                onTapOutside: (_) => FocusManager
                                    .instance.primaryFocus
                                    ?.unfocus(),
                                decoration: InputDecoration(
                                  labelText: 'Discount',
                                  hintText: '0.00',
                                  prefixText: _discountIsPercentage ? '' : '₹ ',
                                  suffixText: _discountIsPercentage ? '%' : '',
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                ),
                                onChanged: (val) {
                                  final d = double.tryParse(val) ?? 0.0;
                                  ref
                                      .read(createInvoiceFormProvider.notifier)
                                      .updateDiscount(d, _discountIsPercentage);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            ToggleButtons(
                              isSelected: [
                                !_discountIsPercentage,
                                _discountIsPercentage
                              ],
                              onPressed: (idx) {
                                final isPct = idx == 1;
                                ref
                                    .read(createInvoiceFormProvider.notifier)
                                    .updateDiscount(_discountAmount, isPct);
                              },
                              borderRadius: BorderRadius.circular(8),
                              children: const [
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('₹',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800))),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('%',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800))),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _extraAmtCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                onTapOutside: (_) => FocusManager
                                    .instance.primaryFocus
                                    ?.unfocus(),
                                decoration: const InputDecoration(
                                  labelText: 'Extra Amount',
                                  hintText: '0.00',
                                  prefixText: '₹ ',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                ),
                                onChanged: (val) {
                                  final amt = double.tryParse(val) ?? 0.0;
                                  ref
                                      .read(createInvoiceFormProvider.notifier)
                                      .updateExtraExpense(
                                          amt, _extraDescCtrl.text);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _extraDescCtrl,
                                onTapOutside: (_) => FocusManager
                                    .instance.primaryFocus
                                    ?.unfocus(),
                                decoration: const InputDecoration(
                                  labelText: 'Expense Note',
                                  hintText: 'e.g. Delivery Charge',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                ),
                                onChanged: (val) {
                                  ref
                                      .read(createInvoiceFormProvider.notifier)
                                      .updateExtraExpense(
                                          _extraExpenseAmount, val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
              left: 20,
              right: 20,
              top: 14,
              bottom: 14 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SummaryRow('Subtotal', '₹${rawSubtotal.toStringAsFixed(2)}'),
                if (calculatedDiscountTotal > 0) ...[
                  const SizedBox(height: 6),
                  _SummaryRow('Discount',
                      '-₹${calculatedDiscountTotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  _SummaryRow(
                      'Taxable Amount', '₹${taxableAmount.toStringAsFixed(2)}'),
                ],
                if (_isGstEnabled &&
                    _gstEnabled &&
                    _taxSettings.showTaxDetailsOnInvoice &&
                    taxTotal > 0) ...[
                  const SizedBox(height: 6),
                  if (_isIgst) ...[
                    _SummaryRow('IGST', '₹${taxTotal.toStringAsFixed(2)}'),
                  ] else ...[
                    _SummaryRow(
                        'CGST', '₹${(taxTotal / 2).toStringAsFixed(2)}'),
                    const SizedBox(height: 6),
                    _SummaryRow(
                        'SGST', '₹${(taxTotal / 2).toStringAsFixed(2)}'),
                  ],
                  const SizedBox(height: 6),
                  _SummaryRow('Total Tax', '₹${taxTotal.toStringAsFixed(2)}'),
                ],
                if (_extraExpenseAmount > 0) ...[
                  const SizedBox(height: 6),
                  _SummaryRow(
                    _extraExpenseDescription.isNotEmpty
                        ? 'Extra Expense ($_extraExpenseDescription)'
                        : 'Extra Expense',
                    '₹${_extraExpenseAmount.toStringAsFixed(2)}',
                  ),
                ],
                const Divider(height: 16),
                _SummaryRow('Grand Total', '₹${grandTotal.toStringAsFixed(2)}',
                    isBold: true),
                const SizedBox(height: 12),
                BlocBuilder<InvoiceBloc, InvoiceState>(
                  builder: (context, state) {
                    return AppButton(
                      text:
                          isEditMode ? 'Update Invoice' : 'Proceed to Payment',
                      onPressed: _onCreateInvoice,
                      isLoading: state is InvoiceLoadingState,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isBold ? 16 : 14,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w500)),
        Text(value,
            style: TextStyle(
                fontSize: isBold ? 18 : 14,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: isBold ? AppColors.primary : AppColors.onSurface)),
      ],
    );
  }
}
