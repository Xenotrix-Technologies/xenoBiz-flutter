import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/invoice_return_entity.dart';
import '../../../domain/repositories/customer_repository.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../../domain/repositories/invoice_repository.dart';
import '../../../domain/repositories/purchase_repository.dart';
import '../../../domain/repositories/returns_repository.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';

enum ReturnType { salesReturn, purchaseReturn }

class ReturnVoucherScreen extends StatefulWidget {
  final ReturnType returnType;
  final dynamic existingReturn;

  const ReturnVoucherScreen({
    super.key,
    required this.returnType,
    this.existingReturn,
  });

  @override
  State<ReturnVoucherScreen> createState() => _ReturnVoucherScreenState();
}

class _ReturnVoucherScreenState extends State<ReturnVoucherScreen> {
  bool get isEditMode => widget.existingReturn != null;
  bool get isSalesReturn => widget.returnType == ReturnType.salesReturn;

  // Party Selection (Optional)
  List<CustomerEntity> _allParties = [];
  CustomerEntity? _selectedParty;
  final TextEditingController _partySearchCtrl = TextEditingController();
  final FocusNode _partySearchFocusNode = FocusNode();
  bool _showPartySearchOverlay = false;

  // Invoice Search State (Optional)
  List<InvoiceEntity> _allEligibleInvoices = [];
  List<InvoiceEntity> _filteredInvoices = [];
  InvoiceEntity? _selectedOriginalInvoice;
  final TextEditingController _invoiceSearchCtrl = TextEditingController();
  final FocusNode _invoiceSearchFocusNode = FocusNode();
  bool _showInvoiceSearchOverlay = false;
  Map<String, int> _previouslyReturned = {};
  Map<String, int> _returnQuantities = {};
  bool _isLoadingInvoices = false;

  // Manual items when no original invoice is selected
  List<InvoiceItemEntity> _manualItems = [];

  // Expense Settings (Optional)
  bool _recordReturnAmountAsExpense = false;
  bool _hasAdditionalExpense = false;
  final TextEditingController _expenseAmountCtrl = TextEditingController();
  final TextEditingController _expenseDescCtrl = TextEditingController();
  String _selectedExpenseCategory = 'Transport';
  String _selectedExpensePaymentMode = 'Cash';

  static const List<String> _expenseCategories = [
    'Transport',
    'Handling',
    'Pickup Charge',
    'Restocking Fee',
    'Other',
  ];

  static const List<String> _paymentModes = [
    'Cash',
    'UPI',
    'Bank',
    'Other',
  ];

  final TextEditingController _notesCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadParties();
    _loadInvoices();

    _partySearchFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _showPartySearchOverlay = _partySearchFocusNode.hasFocus;
        });
      }
    });

    _invoiceSearchFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _showInvoiceSearchOverlay = _invoiceSearchFocusNode.hasFocus;
        });
      }
    });

    if (isEditMode) {
      _populateEditData();
    }
  }

  void _loadParties() async {
    try {
      if (isSalesReturn) {
        final customers = await getIt<CustomerRepository>().getCustomers();
        if (mounted) setState(() => _allParties = customers);
      } else {
        final suppliers = await getIt<PurchaseRepository>().getSuppliers();
        final mapped = suppliers
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
        if (mounted) setState(() => _allParties = mapped);
      }
    } catch (_) {}
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoadingInvoices = true);
    try {
      final targetType = isSalesReturn ? InvoiceType.sale : InvoiceType.purchase;
      final invoices = await getIt<InvoiceRepository>().getInvoices();
      final filtered = invoices.where((i) => i.type == targetType).toList();
      if (mounted) {
        setState(() {
          _allEligibleInvoices = filtered;
          _filteredInvoices = filtered;
          _isLoadingInvoices = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingInvoices = false);
    }
  }

  void _filterInvoices(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredInvoices = _allEligibleInvoices;
      } else {
        _filteredInvoices = _allEligibleInvoices.where((inv) {
          return inv.invoiceNumber.toLowerCase().contains(q) ||
              inv.customerName.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  List<CustomerEntity> get _filteredParties {
    final query = _partySearchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) return _allParties;
    final cleanQuery = query.replaceAll(RegExp(r'[\s\-\+]'), '');
    return _allParties.where((p) {
      final nameMatch = p.name.toLowerCase().contains(query);
      final phoneClean = p.phone.replaceAll(RegExp(r'[\s\-\+]'), '');
      final phoneMatch = phoneClean.contains(cleanQuery);
      return nameMatch || phoneMatch;
    }).toList();
  }

  Future<void> _selectInvoice(InvoiceEntity inv) async {
    setState(() {
      _selectedOriginalInvoice = inv;
      _showInvoiceSearchOverlay = false;
      _returnQuantities = {for (var item in inv.items) item.productId: 0};
    });
    _invoiceSearchFocusNode.unfocus();

    final returnedMap = await getIt<ReturnsRepository>().getReturnedQuantitiesForInvoice(inv.id);
    if (mounted) {
      setState(() {
        _previouslyReturned = returnedMap;
      });
    }
  }

  void _populateEditData() async {
    final ret = widget.existingReturn;
    if (ret is InvoiceReturnEntity) {
      _notesCtrl.text = ret.notes;
      _manualItems = ret.items
          .map((i) => InvoiceItemEntity(
                productId: i.productId,
                productName: i.productName,
                sku: i.sku,
                quantity: i.returnedQuantity,
                unitPrice: i.unitPrice,
              ))
          .toList();

      for (var item in ret.items) {
        _returnQuantities[item.productId] = item.returnedQuantity;
      }

      // Check if return amount expense exists
      try {
        final retAmtExpId = 'exp_ret_amt_${ret.id}';
        final retAmtExp = await getIt<ExpenseRepository>().getExpense(retAmtExpId);
        if (retAmtExp != null && retAmtExp.amount > 0 && mounted) {
          setState(() {
            _recordReturnAmountAsExpense = true;
          });
        }
      } catch (_) {}

      // Check if associated return pickup expense exists
      try {
        final expId = 'exp_sr_${ret.id}';
        final exp = await getIt<ExpenseRepository>().getExpense(expId);
        if (exp != null && exp.amount > 0 && mounted) {
          setState(() {
            _hasAdditionalExpense = true;
            _expenseAmountCtrl.text = exp.amount.toStringAsFixed(0);
            _expenseDescCtrl.text = exp.notes.replaceAll(RegExp(r'\s*\(Return #.*\)\s*'), '');
            _selectedExpenseCategory = exp.category.isNotEmpty ? exp.category : 'Transport';
            _selectedExpensePaymentMode = exp.paymentMode.isNotEmpty ? exp.paymentMode : 'Cash';
          });
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _partySearchCtrl.dispose();
    _partySearchFocusNode.dispose();
    _invoiceSearchCtrl.dispose();
    _invoiceSearchFocusNode.dispose();
    _expenseAmountCtrl.dispose();
    _expenseDescCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  double get _totalReturnAmount {
    if (_selectedOriginalInvoice != null) {
      double sum = 0.0;
      for (var item in _selectedOriginalInvoice!.items) {
        final qty = _returnQuantities[item.productId] ?? 0;
        sum += qty * item.unitPrice;
      }
      return sum;
    } else {
      return _manualItems.fold(0.0, (sum, i) => sum + (i.quantity * i.unitPrice));
    }
  }

  Future<void> _submitReturn() async {
    final returnItems = <InvoiceReturnItemEntity>[];

    if (_selectedOriginalInvoice != null) {
      for (var item in _selectedOriginalInvoice!.items) {
        final qty = _returnQuantities[item.productId] ?? 0;
        if (qty > 0) {
          returnItems.add(
            InvoiceReturnItemEntity(
              productId: item.productId,
              productName: item.productName,
              sku: item.sku,
              originalQuantity: item.quantity,
              returnedQuantity: qty,
              unitPrice: item.unitPrice,
            ),
          );
        }
      }
    } else {
      for (var item in _manualItems) {
        if (item.quantity > 0) {
          returnItems.add(
            InvoiceReturnItemEntity(
              productId: item.productId,
              productName: item.productName,
              sku: item.sku,
              originalQuantity: item.quantity,
              returnedQuantity: item.quantity,
              unitPrice: item.unitPrice,
            ),
          );
        }
      }
    }

    if (returnItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 item to return'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final existingRet = widget.existingReturn as InvoiceReturnEntity?;
      final returnId = isEditMode && existingRet != null ? existingRet.id : 'ret_${DateTime.now().millisecondsSinceEpoch}';
      final returnNum = isEditMode && existingRet != null
          ? existingRet.returnNumber
          : 'RET-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final retEntity = InvoiceReturnEntity(
        id: returnId,
        returnNumber: returnNum,
        invoiceId: _selectedOriginalInvoice?.id ?? existingRet?.invoiceId ?? '',
        invoiceNumber: _selectedOriginalInvoice?.invoiceNumber ?? existingRet?.invoiceNumber ?? '',
        partyId: _selectedParty?.id ?? _selectedOriginalInvoice?.customerId ?? existingRet?.partyId ?? '',
        partyName: _selectedParty?.name ?? _selectedOriginalInvoice?.customerName ?? existingRet?.partyName ?? 'General',
        type: isSalesReturn ? InvoiceType.sale : InvoiceType.purchase,
        items: returnItems,
        totalAmount: _totalReturnAmount > 0 ? _totalReturnAmount : (existingRet?.totalAmount ?? 0.0),
        returnDate: DateTime.now(),
        notes: _notesCtrl.text,
      );

      // 1. Save Return Record (Stock adjusted)
      if (isEditMode) {
        await getIt<ReturnsRepository>().updateReturn(retEntity);
      } else {
        await getIt<ReturnsRepository>().createReturn(retEntity);
      }

      // 2. Handle Optional Total Return Amount as Expense
      final retAmtExpId = 'exp_ret_amt_${retEntity.id}';
      if (_recordReturnAmountAsExpense && _totalReturnAmount > 0) {
        final retAmtExpense = ExpenseEntity(
          id: retAmtExpId,
          title: '${isSalesReturn ? "Sales" : "Purchase"} Return #${retEntity.returnNumber}',
          category: isSalesReturn ? 'Sales Return' : 'Purchase Return',
          amount: _totalReturnAmount,
          paymentMode: _selectedExpensePaymentMode,
          expenseDate: DateTime.now(),
          notes: 'Return amount recorded as expense for #${retEntity.returnNumber}',
        );
        await getIt<ExpenseRepository>().createExpense(retAmtExpense);
      } else if (isEditMode) {
        try {
          await getIt<ExpenseRepository>().createExpense(ExpenseEntity(
            id: retAmtExpId,
            title: 'Cancelled Return Expense',
            category: 'Other',
            amount: 0.0,
            paymentMode: 'Cash',
            expenseDate: DateTime.now(),
            notes: 'Return amount expense removed from #${retEntity.returnNumber}',
          ));
        } catch (_) {}
      }

      // 3. Handle Additional Return Pickup/Transport Expense
      final expId = 'exp_sr_${retEntity.id}';
      if (_hasAdditionalExpense) {
        final expAmount = double.tryParse(_expenseAmountCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        if (expAmount > 0) {
          final expDesc = _expenseDescCtrl.text.trim().isNotEmpty ? _expenseDescCtrl.text.trim() : 'Return pickup charge';
          final expense = ExpenseEntity(
            id: expId,
            title: expDesc,
            category: _selectedExpenseCategory,
            amount: expAmount,
            paymentMode: _selectedExpensePaymentMode,
            expenseDate: DateTime.now(),
            notes: '$expDesc (Return #${retEntity.returnNumber})',
          );
          await getIt<ExpenseRepository>().createExpense(expense);
        }
      } else if (isEditMode) {
        try {
          await getIt<ExpenseRepository>().createExpense(ExpenseEntity(
            id: expId,
            title: 'Cancelled Pickup Expense',
            category: 'Other',
            amount: 0.0,
            paymentMode: 'Cash',
            expenseDate: DateTime.now(),
            notes: 'Expense removed from Return #${retEntity.returnNumber}',
          ));
        } catch (_) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isSalesReturn ? "Sales" : "Purchase"} Return #${retEntity.returnNumber} ${isEditMode ? "updated" : "saved"}!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isSalesReturn ? 'Sales Return' : 'Purchase Return';
    final partyLabel = isSalesReturn ? 'Customer / Account' : 'Supplier / Account';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit $title' : title),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // BOTTOM NAVIGATION PLACE FOR SAVE/UPDATE BUTTON
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: AppButton(
            text: isEditMode ? 'Update Return' : 'Save Return',
            onPressed: _submitReturn,
            isLoading: _isSaving,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION 1: CUSTOMER / SUPPLIER SELECTION (MATCHES REFERENCE IMAGE)
            _buildPartySelectorSection(partyLabel),
            const SizedBox(height: 16),

            // SECTION 2: OPTIONAL OLD INVOICE SEARCH (CLEAN SEAMLESS OVERLAY)
            _buildInvoiceSearchSection(),
            const SizedBox(height: 16),

            // SECTION 3: RETURN ITEMS SECTION (EITHER FROM INVOICE OR MANUAL ADD)
            _buildReturnItemsSection(),
            const SizedBox(height: 16),

            // SECTION 4: EXPENSE OPTIONS (OPTIONAL RETURN AMOUNT & PICKUP EXPENSE)
            _buildExpenseOptionsSection(),
            const SizedBox(height: 16),

            // SECTION 5: NOTES FIELD
            AppTextField(
              label: 'Return Reason / Notes',
              hint: 'Optional notes for return...',
              controller: _notesCtrl,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPartySelectorSection(String partyLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person_search_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              partyLabel,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.onSurface),
            ),
            const SizedBox(width: 8),
            const Text(
              '(Optional)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.outline),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_selectedParty != null) ...[
          AppCard(
            backgroundColor: AppColors.deepNavy,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _getInitials(_selectedParty!.name),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedParty!.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_selectedParty!.phone.isNotEmpty)
                        Text(
                          _selectedParty!.phone,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedParty = null;
                      _partySearchCtrl.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white70, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          TapRegion(
            onTapOutside: (_) => _partySearchFocusNode.unfocus(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _showPartySearchOverlay ? AppColors.primary : AppColors.surfaceContainerHigh,
                      width: _showPartySearchOverlay ? 1.5 : 1.0,
                    ),
                  ),
                  child: TextField(
                    controller: _partySearchCtrl,
                    focusNode: _partySearchFocusNode,
                    onChanged: (val) {
                      if (!_showPartySearchOverlay && _partySearchFocusNode.hasFocus) {
                        setState(() => _showPartySearchOverlay = true);
                      }
                    },
                    onTap: () {
                      if (!_showPartySearchOverlay) {
                        setState(() => _showPartySearchOverlay = true);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: isSalesReturn ? 'Search customer name or phone' : 'Search supplier name or phone',
                      hintStyle: const TextStyle(color: AppColors.outline, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: AppColors.outline, size: 20),
                      suffixIcon: _partySearchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18, color: AppColors.outline),
                              onPressed: () {
                                _partySearchCtrl.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                if (_showPartySearchOverlay && _filteredParties.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  AppCard(
                    padding: const EdgeInsets.all(0),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _filteredParties.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, idx) {
                          final party = _filteredParties[idx];
                          return ListTile(
                            dense: true,
                            title: Text(party.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(party.phone),
                            onTap: () {
                              setState(() {
                                _selectedParty = party;
                                _showPartySearchOverlay = false;
                              });
                              _partySearchFocusNode.unfocus();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInvoiceSearchSection() {
    final titleLabel = isSalesReturn ? 'Original Sales Invoice' : 'Original Purchase Invoice';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.receipt_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              titleLabel,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.onSurface),
            ),
            const SizedBox(width: 8),
            const Text('(Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.outline)),
          ],
        ),
        const SizedBox(height: 8),

        if (_selectedOriginalInvoice != null) ...[
          AppCard(
            backgroundColor: AppColors.deepNavy,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.description, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedOriginalInvoice!.invoiceNumber,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_selectedOriginalInvoice!.customerName} • ₹${_selectedOriginalInvoice!.grandTotal.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedOriginalInvoice = null;
                      _invoiceSearchCtrl.clear();
                      _returnQuantities.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white70, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          TapRegion(
            onTapOutside: (_) => _invoiceSearchFocusNode.unfocus(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _showInvoiceSearchOverlay ? AppColors.primary : AppColors.surfaceContainerHigh,
                      width: _showInvoiceSearchOverlay ? 1.5 : 1.0,
                    ),
                  ),
                  child: TextField(
                    controller: _invoiceSearchCtrl,
                    focusNode: _invoiceSearchFocusNode,
                    onChanged: (val) {
                      _filterInvoices(val);
                      if (!_showInvoiceSearchOverlay && _invoiceSearchFocusNode.hasFocus) {
                        setState(() => _showInvoiceSearchOverlay = true);
                      }
                    },
                    onTap: () {
                      if (!_showInvoiceSearchOverlay) {
                        setState(() => _showInvoiceSearchOverlay = true);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Search invoice number or party name',
                      hintStyle: const TextStyle(color: AppColors.outline, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: AppColors.outline, size: 20),
                      suffixIcon: _invoiceSearchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18, color: AppColors.outline),
                              onPressed: () {
                                _invoiceSearchCtrl.clear();
                                _filterInvoices('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                if (_showInvoiceSearchOverlay) ...[
                  const SizedBox(height: 6),
                  AppCard(
                    padding: const EdgeInsets.all(0),
                    child: _isLoadingInvoices
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : _filteredInvoices.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: Text('No eligible invoices found', style: TextStyle(color: AppColors.outline))),
                              )
                            : Container(
                                constraints: const BoxConstraints(maxHeight: 220),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: _filteredInvoices.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (ctx, idx) {
                                    final inv = _filteredInvoices[idx];
                                    return ListTile(
                                      dense: true,
                                      title: Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w800)),
                                      subtitle: Text('${inv.customerName} • ₹${inv.grandTotal.toStringAsFixed(0)}'),
                                      trailing: const Icon(Icons.chevron_right, size: 18),
                                      onTap: () => _selectInvoice(inv),
                                    );
                                  },
                                ),
                              ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReturnItemsSection() {
    if (_selectedOriginalInvoice != null) {
      final itemsSource = _selectedOriginalInvoice!.items;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Items to Return', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itemsSource.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final item = itemsSource[idx];
              final prevReturned = _previouslyReturned[item.productId] ?? 0;
              final availableForReturn = (item.quantity - prevReturned).clamp(0, item.quantity);
              final currentReturnQty = _returnQuantities[item.productId] ?? 0;

              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.onSurface)),
                        ),
                        Text('₹${item.unitPrice.toStringAsFixed(2)} / unit', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Billed Qty: ${item.quantity} | Max Returnable: $availableForReturn', style: const TextStyle(fontSize: 11, color: AppColors.outline)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Return Qty: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                          onPressed: currentReturnQty > 0
                              ? () => setState(() => _returnQuantities[item.productId] = currentReturnQty - 1)
                              : null,
                        ),
                        Text('$currentReturnQty', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                          onPressed: currentReturnQty < availableForReturn
                              ? () => setState(() => _returnQuantities[item.productId] = currentReturnQty + 1)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Return Amount:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text('₹${_totalReturnAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.danger)),
              ],
            ),
          ),
        ],
      );
    } else {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Items to Return', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                TextButton.icon(
                  onPressed: () async {
                    final result = await context.push<List<InvoiceItemEntity>>(RouteNames.addProducts, extra: _manualItems);
                    if (result != null) {
                      setState(() {
                        _manualItems = result;
                      });
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Add Products'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_manualItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: Colors.grey.shade400, size: 32),
                    const SizedBox(height: 6),
                    Text(
                      'No products added yet',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Tap "+ Add Products" or select an original invoice above',
                      style: TextStyle(color: AppColors.outline, fontSize: 11),
                    ),
                  ],
                ),
              )
            else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _manualItems.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (ctx, idx) {
                  final item = _manualItems[idx];
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text('₹${item.unitPrice.toStringAsFixed(2)} × ${item.quantity}', style: const TextStyle(fontSize: 12, color: AppColors.outline)),
                          ],
                        ),
                      ),
                      Text('₹${(item.quantity * item.unitPrice).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                        onPressed: () {
                          setState(() {
                            _manualItems.removeAt(idx);
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Return Amount:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text('₹${_totalReturnAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.danger)),
                ],
              ),
            ],
          ],
        ),
      );
    }
  }

  Widget _buildExpenseOptionsSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // OPTION 1: RECORD TOTAL RETURN AMOUNT IN EXPENSE LIST
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Record Return Amount in Expense List',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkBlueText),
            ),
            subtitle: Text(
              _totalReturnAmount > 0
                  ? 'Optional: Record ₹${_totalReturnAmount.toStringAsFixed(2)} in Expenses'
                  : 'Optional: Record total return amount in Expenses',
              style: const TextStyle(fontSize: 12, color: AppColors.outline),
            ),
            value: _recordReturnAmountAsExpense,
            activeThumbColor: AppColors.primary,
            onChanged: (val) => setState(() => _recordReturnAmountAsExpense = val),
          ),

          const Divider(height: 16),

          // OPTION 2: ADDITIONAL RETURN EXPENSE (PICKUP/TRANSPORT)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Additional Return Expense',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkBlueText),
            ),
            subtitle: const Text(
              'Optional: Add extra transport or pickup charges',
              style: TextStyle(fontSize: 12, color: AppColors.outline),
            ),
            value: _hasAdditionalExpense,
            activeThumbColor: AppColors.primary,
            onChanged: (val) => setState(() => _hasAdditionalExpense = val),
          ),

          if (_hasAdditionalExpense) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            AppTextField(
              label: 'Expense Amount (₹)',
              hint: 'e.g. 200',
              controller: _expenseAmountCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.currency_rupee,
            ),
            const SizedBox(height: 12),
            Text('Expense Category', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              initialValue: _expenseCategories.contains(_selectedExpenseCategory) ? _selectedExpenseCategory : _expenseCategories.first,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              items: _expenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedExpenseCategory = val);
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Description',
              hint: 'e.g. Return pickup charge',
              controller: _expenseDescCtrl,
            ),
            const SizedBox(height: 12),
            Text('Payment Method', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              initialValue: _selectedExpensePaymentMode,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              items: _paymentModes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedExpensePaymentMode = val);
              },
            ),
          ],
        ],
      ),
    );
  }
}
