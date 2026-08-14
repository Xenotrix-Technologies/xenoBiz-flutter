import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../const/colors.dart';
import '../../../const/dummy.dart';
import '../../../const/sizes.dart';
import '../../../const/strings.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../../application/bloc/invoice_bloc.dart';

class CreateInvoicePage extends StatefulWidget {
  const CreateInvoicePage({super.key});

  @override
  State<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  bool get _isCashSale => _selectedCustomer == null;
  final String _invoiceId = 'XNOB-1001';
  final DateTime _createdDateTime = DateTime.now();

  CustomerEntity? _selectedCustomer;
  final TextEditingController _customerSearchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchOverlay = false;

  late List<CustomerEntity> _allCustomers;

  final _notesCtrl =
      TextEditingController(text: 'Thank you for your business!');

  @override
  void initState() {
    super.initState();

    _allCustomers = [
      ...DummyData.customers,
      CustomerEntity(
        id: 'cust_biz_apex',
        name: 'Apex Technologies Pvt Ltd',
        phone: '+91 98470 11223',
        email: 'contact@apextech.in',
        address: 'MG Road, Kochi',
        outstandingBalance: 2500.0,
        totalPurchases: 145000.0,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      CustomerEntity(
        id: 'cust_john_mathew',
        name: 'John Mathew',
        phone: '98765 43210',
        email: 'john.mathew@example.com',
        address: 'Sector 5, Kochi',
        outstandingBalance: 2500.0,
        totalPurchases: 89000.0,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        setState(() {
          _showSearchOverlay = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _customerSearchCtrl.dispose();
    _searchFocusNode.dispose();
    _notesCtrl.dispose();
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

  void _showCreateCustomerDialog([String prefill = '']) {
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
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create New Customer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlueText,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Quickly add customer details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
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
            const SizedBox(height: 8),
            AppTextField(
              label: 'Customer Name',
              controller: nameCtrl,
              hint: 'e.g. John Mathew',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Mobile Number',
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              hint: 'e.g. 98765 43210',
              prefixIcon: Icons.phone_outlined,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final newCust = CustomerEntity(
                      id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim().isEmpty
                          ? '+91 98765 43210'
                          : phoneCtrl.text.trim(),
                      email: '',
                      address: '',
                      outstandingBalance: 0.0,
                      totalPurchases: 0.0,
                      createdAt: DateTime.now(),
                    );
                    setState(() {
                      _allCustomers.insert(0, newCust);
                      _selectedCustomer = newCust;
                      _showSearchOverlay = false;
                      _customerSearchCtrl.clear();
                    });
                    Navigator.pop(ctx);
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

  final List<InvoiceItemEntity> _items = [
    const InvoiceItemEntity(
      productId: 'prod_101',
      productName: 'Wireless Smart POS Machine v2',
      quantity: 2,
      unitPrice: 8500.0,
      taxPercentage: 18.0,
    ),
    const InvoiceItemEntity(
      productId: 'prod_103',
      productName: 'Bluetooth Barcode Scanner HD',
      quantity: 1,
      unitPrice: 3200.0,
      taxPercentage: 18.0,
    ),
  ];

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get taxTotal => _items.fold(0.0, (sum, item) => sum + item.taxAmount);
  double get grandTotal => subtotal + taxTotal;

  void _onCreateInvoice() {
    final invoice = InvoiceEntity(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      invoiceNumber: _invoiceId,
      customerId:
          _isCashSale ? 'cust_cash' : (_selectedCustomer?.id ?? 'cust_101'),
      customerName: _isCashSale
          ? 'Cash Customer'
          : (_selectedCustomer?.name ?? 'Customer'),
      customerPhone: _isCashSale ? 'N/A' : (_selectedCustomer?.phone ?? 'N/A'),
      items: _items,
      subtotal: subtotal,
      taxTotal: taxTotal,
      grandTotal: grandTotal,
      paidAmount: 0.0,
      status: _isCashSale ? InvoiceStatus.paid : InvoiceStatus.unpaid,
      issueDate: _createdDateTime,
      dueDate: _createdDateTime.add(const Duration(days: 10)),
      notes: _notesCtrl.text,
    );

    context.read<InvoiceBloc>().add(CreateInvoiceSubmittedEvent(invoice));
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
                          border:
                              Border.all(color: AppColors.surfaceContainerHigh),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.06),
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
                    // Title
                    const Text(
                      AppStrings.newInvoice,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const Spacer(),
                    // Top Right: Invoice ID & Timestamp
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _invoiceId,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlueText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDateTime,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Customer Selection Section (Default: Cash Sale if unselected)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedCustomer != null)
                      // Selected Customer Card (Reference Image 3 Style)
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
                                    _selectedCustomer!.phone,
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
                                    color:
                                        _selectedCustomer!.outstandingBalance >
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
                                setState(() {
                                  _selectedCustomer = null;
                                  _customerSearchCtrl.clear();
                                  _showSearchOverlay = true;
                                });
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
                      // Search Input Field & Dropdown Overlay (Reference Image 2 Style)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.person_search_outlined,
                                  size: 18, color: AppColors.primary),
                              SizedBox(width: 6),
                              Text('Customer',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: AppColors.onSurface)),
                              SizedBox(width: 8),
                              Text('(Optional)',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.outline)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
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
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _customerSearchCtrl,
                              focusNode: _searchFocusNode,
                              onChanged: (val) {
                                setState(() {
                                  _showSearchOverlay = true;
                                });
                              },
                              onTap: () {
                                setState(() {
                                  _showSearchOverlay = true;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search customer name or phone',
                                hintStyle: const TextStyle(
                                    color: AppColors.outline, fontSize: 14),
                                prefixIcon: const Icon(Icons.search,
                                    color: AppColors.outline, size: 20),
                                suffixIcon: _customerSearchCtrl.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close,
                                            size: 18, color: AppColors.outline),
                                        onPressed: () {
                                          _customerSearchCtrl.clear();
                                          setState(() {});
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                            ),
                          ),
                          if (_showSearchOverlay) ...[
                            const SizedBox(height: 6),
                            AppCard(
                              padding: const EdgeInsets.all(0),
                              border: Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.2)),
                              child: Container(
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
                                                children: const [
                                                  Icon(Icons.search_off,
                                                      size: 20,
                                                      color: AppColors.outline),
                                                  SizedBox(width: 8),
                                                  Text('Customer not found',
                                                      style: TextStyle(
                                                          color:
                                                              AppColors.outline,
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
                                                      _selectedCustomer = cust;
                                                      _showSearchOverlay =
                                                          false;
                                                    });
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
                                                          alignment:
                                                              Alignment.center,
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
                                                                  fontSize: 14,
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
                                                                          .circular(
                                                                              6),
                                                                  border: Border.all(
                                                                      color: AppColors
                                                                          .warning
                                                                          .withValues(
                                                                              alpha: 0.3)),
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
                                                                          .circular(
                                                                              6),
                                                                  border: Border.all(
                                                                      color: AppColors
                                                                          .success
                                                                          .withValues(
                                                                              alpha: 0.3)),
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
                                      onTap: () => _showCreateCustomerDialog(
                                          _customerSearchCtrl.text),
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
                                          children: const [
                                            Icon(Icons.add_circle_outline,
                                                size: 18,
                                                color: AppColors.primary),
                                            SizedBox(width: 8),
                                            Text(
                                              'Create New Customer',
                                              style: TextStyle(
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
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Invoice Items',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: const Text('Add Item'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: AppCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(
                                    '${item.quantity} x ₹${item.unitPrice.toStringAsFixed(0)} (18% GST)',
                                    style: const TextStyle(
                                        color: AppColors.outline,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          Text('₹${item.total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.primary)),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    children: [
                      _SummaryRow(
                          'Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 6),
                      _SummaryRow(
                          'GST Total (18%)', '₹${taxTotal.toStringAsFixed(2)}'),
                      const Divider(height: 20),
                      _SummaryRow(
                          'Grand Total', '₹${grandTotal.toStringAsFixed(2)}',
                          isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<InvoiceBloc, InvoiceState>(
                  builder: (context, state) {
                    return AppButton(
                      text: 'Generate & Save Invoice',
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
