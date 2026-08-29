import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/customer_bloc.dart';
import '../../../application/bloc/delivery_challan_bloc.dart';
import '../../../application/bloc/product_bloc.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/delivery_challan_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../infrastructure/services/voucher_sequence_service.dart';
import '../../widgets/app_card.dart';

class CreateDeliveryChallanPage extends StatefulWidget {
  final DeliveryChallanEntity? challanToEdit;

  const CreateDeliveryChallanPage({super.key, this.challanToEdit});

  @override
  State<CreateDeliveryChallanPage> createState() => _CreateDeliveryChallanPageState();
}

class _CreateDeliveryChallanPageState extends State<CreateDeliveryChallanPage> {
  final _formKey = GlobalKey<FormState>();

  String _challanNumber = 'DC-000001';
  CustomerEntity? _selectedCustomer;
  DateTime _issueDate = DateTime.now();
  DateTime? _deliveryDate;

  final TextEditingController _transporterCtrl = TextEditingController();
  final TextEditingController _vehicleCtrl = TextEditingController();
  final TextEditingController _placeOfSupplyCtrl = TextEditingController();
  final TextEditingController _referenceCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  DeliveryChallanStatus _status = DeliveryChallanStatus.issued;
  List<DeliveryChallanItemEntity> _items = [];

  bool get isEditMode => widget.challanToEdit != null;

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const FetchCustomersEvent());
    context.read<ProductBloc>().add(const FetchProductsEvent());

    if (isEditMode) {
      final edit = widget.challanToEdit!;
      _challanNumber = edit.challanNumber;
      _issueDate = edit.issueDate;
      _deliveryDate = edit.deliveryDate;
      _transporterCtrl.text = edit.transporterName;
      _vehicleCtrl.text = edit.vehicleNumber;
      _placeOfSupplyCtrl.text = edit.placeOfSupply;
      _referenceCtrl.text = edit.referenceNumber;
      _notesCtrl.text = edit.notes;
      _status = edit.status;
      _items = List.from(edit.items);
      _selectedCustomer = CustomerEntity(
        id: edit.customerId,
        name: edit.customerName,
        phone: edit.customerPhone,
        address: edit.customerAddress,
        email: '',
        createdAt: DateTime.now(),
      );
    } else {
      _initNextSequence();
    }
  }

  Future<void> _initNextSequence() async {
    final nextId = await VoucherSequenceService.instance
        .generateNextVoucherId(VoucherType.deliveryChallan);
    if (mounted) {
      setState(() {
        _challanNumber = nextId;
      });
    }
  }

  @override
  void dispose() {
    _transporterCtrl.dispose();
    _vehicleCtrl.dispose();
    _placeOfSupplyCtrl.dispose();
    _referenceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _saveChallan() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product item to the challan.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final entity = DeliveryChallanEntity(
      id: isEditMode ? widget.challanToEdit!.id : 'dc_${DateTime.now().millisecondsSinceEpoch}',
      challanNumber: _challanNumber,
      customerId: _selectedCustomer?.id ?? '',
      customerName: _selectedCustomer?.name ?? 'Cash Customer',
      customerPhone: _selectedCustomer?.phone ?? '',
      customerAddress: _selectedCustomer?.address ?? '',
      customerGstin: '',
      items: _items,
      issueDate: _issueDate,
      deliveryDate: _deliveryDate,
      placeOfSupply: _placeOfSupplyCtrl.text.trim(),
      transporterName: _transporterCtrl.text.trim(),
      vehicleNumber: _vehicleCtrl.text.trim(),
      referenceNumber: _referenceCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      status: _status,
    );

    if (isEditMode) {
      context.read<DeliveryChallanBloc>().add(UpdateDeliveryChallanSubmittedEvent(entity));
    } else {
      context.read<DeliveryChallanBloc>().add(CreateDeliveryChallanSubmittedEvent(entity));
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Delivery Challan' : 'Create Delivery Challan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document Header Card
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CHALLAN NUMBER',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.secondaryText)),
                        const SizedBox(height: 2),
                        Text(
                          _challanNumber,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryBlue),
                        ),
                      ],
                    ),
                    DropdownButton<DeliveryChallanStatus>(
                      value: _status,
                      onChanged: (val) {
                        if (val != null) setState(() => _status = val);
                      },
                      items: DeliveryChallanStatus.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s.label),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Party Selection Section
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PARTY / CUSTOMER',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText)),
                    const SizedBox(height: 10),
                    BlocBuilder<CustomerBloc, CustomerState>(
                      builder: (context, state) {
                        List<CustomerEntity> customers = [];
                        if (state is CustomersLoadedState) {
                          customers = state.customers;
                        }
                        return DropdownButtonFormField<CustomerEntity>(
                          initialValue: _selectedCustomer,
                          decoration: InputDecoration(
                            hintText: 'Select Party / Customer',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: customers.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(c.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedCustomer = val);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Date Pickers
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _issueDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) setState(() => _issueDate = picked);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CHALLAN DATE',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.secondaryText)),
                            const SizedBox(height: 4),
                            Text(dateFormatter.format(_issueDate),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _deliveryDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) setState(() => _deliveryDate = picked);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DELIVERY DATE',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.secondaryText)),
                            const SizedBox(height: 4),
                            Text(
                              _deliveryDate != null ? dateFormatter.format(_deliveryDate!) : 'Select Date',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _deliveryDate != null ? AppColors.darkBlueText : AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Transport & Delivery Details
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TRANSPORT & DELIVERY DETAILS',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _transporterCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Transporter Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _vehicleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Number (e.g. DL-01-AB-1234)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _placeOfSupplyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Place of Supply / Destination',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _referenceCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Reference / PO Number',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Dispatched Items Section
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('DISPATCHED ITEMS',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText)),
                        TextButton.icon(
                          onPressed: () => _openAddProductBottomSheet(context),
                          icon: const Icon(Icons.add_circle_outline, size: 16),
                          label: const Text('Add Product'),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    if (_items.isEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'No items added to this challan yet.',
                            style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                          ),
                        ),
                      ),
                    ] else ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const Divider(height: 12),
                        itemBuilder: (ctx, idx) {
                          final item = _items[idx];
                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.productName,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                                    if (item.hsnSac.isNotEmpty)
                                      Text('HSN: ${item.hsnSac}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20, color: AppColors.secondaryText),
                                    onPressed: () {
                                      if (item.quantity > 1) {
                                        setState(() {
                                          _items[idx] = DeliveryChallanItemEntity(
                                            productId: item.productId,
                                            productName: item.productName,
                                            sku: item.sku,
                                            hsnSac: item.hsnSac,
                                            quantity: item.quantity - 1,
                                            unit: item.unit,
                                            unitPrice: item.unitPrice,
                                            taxPercentage: item.taxPercentage,
                                          );
                                        });
                                      } else {
                                        setState(() => _items.removeAt(idx));
                                      }
                                    },
                                  ),
                                  Text('${item.quantity} ${item.unit}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20, color: AppColors.primaryBlue),
                                    onPressed: () {
                                      setState(() {
                                        _items[idx] = DeliveryChallanItemEntity(
                                          productId: item.productId,
                                          productName: item.productName,
                                          sku: item.sku,
                                          hsnSac: item.hsnSac,
                                          quantity: item.quantity + 1,
                                          unit: item.unit,
                                          unitPrice: item.unitPrice,
                                          taxPercentage: item.taxPercentage,
                                        );
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                                    onPressed: () => setState(() => _items.removeAt(idx)),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Notes / Remarks
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NOTES / REMARKS',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Enter dispatch remarks, instructions or terms...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveChallan,
                  child: Text(
                    isEditMode ? 'SAVE CHANGES' : 'SAVE DELIVERY CHALLAN',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddProductBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            List<ProductEntity> products = [];
            if (state is ProductsLoadedState) {
              products = state.products;
            }
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Product',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                  const Divider(height: 20),
                  Expanded(
                    child: products.isEmpty
                        ? const Center(child: Text('No products available.'))
                        : ListView.separated(
                            itemCount: products.length,
                            separatorBuilder: (_, __) => const Divider(height: 12),
                            itemBuilder: (c, idx) {
                              final prod = products[idx];
                              return ListTile(
                                title: Text(prod.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                subtitle: Text('Stock: ${prod.stockQuantity} ${prod.unit}'),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    final existingIdx = _items.indexWhere((i) => i.productId == prod.id);
                                    setState(() {
                                      if (existingIdx >= 0) {
                                        final current = _items[existingIdx];
                                        _items[existingIdx] = DeliveryChallanItemEntity(
                                          productId: current.productId,
                                          productName: current.productName,
                                          sku: current.sku,
                                          hsnSac: current.hsnSac,
                                          quantity: current.quantity + 1,
                                          unit: current.unit,
                                          unitPrice: current.unitPrice,
                                          taxPercentage: current.taxPercentage,
                                        );
                                      } else {
                                        _items.add(DeliveryChallanItemEntity(
                                          productId: prod.id,
                                          productName: prod.name,
                                          sku: prod.sku,
                                          hsnSac: prod.hsnCode,
                                          quantity: 1,
                                          unit: prod.unit,
                                          unitPrice: prod.sellingPrice,
                                          taxPercentage: prod.taxPercentage ?? 0.0,
                                        ));
                                      }
                                    });
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('Add'),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
