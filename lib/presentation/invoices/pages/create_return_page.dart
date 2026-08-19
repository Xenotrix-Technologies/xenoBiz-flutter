import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/invoice_return_entity.dart';
import '../../../domain/repositories/invoice_repository.dart';
import '../../../domain/repositories/returns_repository.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/ui_state_widgets.dart';

class CreateReturnPage extends StatefulWidget {
  final InvoiceType type;

  const CreateReturnPage({super.key, required this.type});

  @override
  State<CreateReturnPage> createState() => _CreateReturnPageState();
}

class _CreateReturnPageState extends State<CreateReturnPage> {
  bool _isLoadingInvoices = true;
  List<InvoiceEntity> _availableInvoices = [];
  InvoiceEntity? _selectedInvoice;
  Map<String, int> _previouslyReturned = {};
  Map<String, int> _returnQuantities = {};
  final TextEditingController _notesCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    try {
      final all = await getIt<InvoiceRepository>().getInvoices();
      final filtered = all.where((i) => i.type == widget.type).toList();
      if (mounted) {
        setState(() {
          _availableInvoices = filtered;
          _isLoadingInvoices = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingInvoices = false);
    }
  }

  Future<void> _selectInvoice(InvoiceEntity inv) async {
    setState(() {
      _selectedInvoice = inv;
      _returnQuantities = {for (var item in inv.items) item.productId: 0};
    });

    final returnedMap = await getIt<ReturnsRepository>().getReturnedQuantitiesForInvoice(inv.id);
    if (mounted) {
      setState(() {
        _previouslyReturned = returnedMap;
      });
    }
  }

  double get _totalReturnAmount {
    if (_selectedInvoice == null) return 0.0;
    double sum = 0.0;
    for (var item in _selectedInvoice!.items) {
      final qty = _returnQuantities[item.productId] ?? 0;
      sum += qty * item.unitPrice;
    }
    return sum;
  }

  Future<void> _submitReturn() async {
    if (_selectedInvoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an invoice first'), backgroundColor: AppColors.error),
      );
      return;
    }

    final returnItems = <InvoiceReturnItemEntity>[];
    for (var item in _selectedInvoice!.items) {
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

    if (returnItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 item quantity to return'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final retEntity = InvoiceReturnEntity(
        id: '',
        returnNumber: 'RET-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        invoiceId: _selectedInvoice!.id,
        invoiceNumber: _selectedInvoice!.invoiceNumber,
        partyId: _selectedInvoice!.customerId,
        partyName: _selectedInvoice!.customerName,
        type: widget.type,
        items: returnItems,
        totalAmount: _totalReturnAmount,
        returnDate: DateTime.now(),
        notes: _notesCtrl.text,
      );

      await getIt<ReturnsRepository>().createReturn(retEntity);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Return #${retEntity.returnNumber} saved successfully!'),
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
    final title = widget.type == InvoiceType.sale ? 'Create Sales Return' : 'Create Purchase Return';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingInvoices
          ? const LoadingState(message: 'Loading eligible invoices...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Invoice', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                  const SizedBox(height: 8),
                  if (_availableInvoices.isEmpty)
                    const Text('No invoices available for return.', style: TextStyle(color: AppColors.outline))
                  else
                    AppCard(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<InvoiceEntity>(
                          isExpanded: true,
                          hint: const Text('Tap to choose an invoice...'),
                          value: _selectedInvoice,
                          items: _availableInvoices.map((inv) {
                            return DropdownMenuItem(
                              value: inv,
                              child: Text('${inv.invoiceNumber} - ${inv.customerName} (₹${inv.grandTotal.toStringAsFixed(0)})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) _selectInvoice(val);
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  if (_selectedInvoice != null) ...[
                    const Text('Select Items to Return', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                    const SizedBox(height: 10),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedInvoice!.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, idx) {
                        final item = _selectedInvoice!.items[idx];
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
                                    child: Text(
                                      item.productName,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.onSurface),
                                    ),
                                  ),
                                  Text(
                                    '₹${item.unitPrice.toStringAsFixed(2)} / unit',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Billed Qty: ${item.quantity} | Previously Returned: $prevReturned | Max Returnable: $availableForReturn',
                                style: const TextStyle(fontSize: 11, color: AppColors.outline),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Text('Return Qty: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                                    onPressed: currentReturnQty > 0
                                        ? () {
                                            setState(() {
                                              _returnQuantities[item.productId] = currentReturnQty - 1;
                                            });
                                          }
                                        : null,
                                  ),
                                  Text(
                                    '$currentReturnQty',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                                    onPressed: currentReturnQty < availableForReturn
                                        ? () {
                                            setState(() {
                                              _returnQuantities[item.productId] = currentReturnQty + 1;
                                            });
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    AppTextField(
                      label: 'Return Reason / Notes',
                      hint: 'Optional notes for return...',
                      controller: _notesCtrl,
                    ),
                    const SizedBox(height: 20),

                    AppCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Return Amount:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          Text(
                            '₹${_totalReturnAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.danger),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    AppButton(
                      text: 'Save Return',
                      onPressed: _submitReturn,
                      isLoading: _isSaving,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
