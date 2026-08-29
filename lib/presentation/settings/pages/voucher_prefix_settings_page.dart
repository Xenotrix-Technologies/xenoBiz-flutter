import 'package:flutter/material.dart';
import '../../../const/colors.dart';
import '../../../infrastructure/services/voucher_sequence_service.dart';
import '../../widgets/app_button.dart';

class VoucherPrefixSettingsPage extends StatefulWidget {
  const VoucherPrefixSettingsPage({super.key});

  @override
  State<VoucherPrefixSettingsPage> createState() =>
      _VoucherPrefixSettingsPageState();
}

class _VoucherPrefixSettingsPageState
    extends State<VoucherPrefixSettingsPage> {
  late final VoucherSequenceService _sequenceService;

  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _salePrefixCtrl = TextEditingController();
  final TextEditingController _salesReturnPrefixCtrl = TextEditingController();
  final TextEditingController _purchasePrefixCtrl = TextEditingController();
  final TextEditingController _purchaseReturnPrefixCtrl = TextEditingController();
  final TextEditingController _paymentPrefixCtrl = TextEditingController();
  final TextEditingController _receiptPrefixCtrl = TextEditingController();
  final TextEditingController _quotationPrefixCtrl = TextEditingController();
  final TextEditingController _deliveryChallanPrefixCtrl = TextEditingController();
  final TextEditingController _creditNotePrefixCtrl = TextEditingController();
  final TextEditingController _debitNotePrefixCtrl = TextEditingController();
  final TextEditingController _expensePrefixCtrl = TextEditingController();
  final TextEditingController _proformaPrefixCtrl = TextEditingController();
  final TextEditingController _ewayBillPrefixCtrl = TextEditingController();

  int _saleSeq = 1;
  int _salesReturnSeq = 1;
  int _purchaseSeq = 1;
  int _purchaseReturnSeq = 1;
  int _paymentSeq = 1;
  int _receiptSeq = 1;
  int _quotationSeq = 1;
  int _deliveryChallanSeq = 1;
  int _creditNoteSeq = 1;
  int _debitNoteSeq = 1;
  int _expenseSeq = 1;
  int _proformaSeq = 1;
  int _ewayBillSeq = 1;

  @override
  void initState() {
    super.initState();
    _sequenceService = VoucherSequenceService.instance;
    _loadSettings();
  }

  @override
  void dispose() {
    _salePrefixCtrl.dispose();
    _salesReturnPrefixCtrl.dispose();
    _purchasePrefixCtrl.dispose();
    _purchaseReturnPrefixCtrl.dispose();
    _paymentPrefixCtrl.dispose();
    _receiptPrefixCtrl.dispose();
    _quotationPrefixCtrl.dispose();
    _deliveryChallanPrefixCtrl.dispose();
    _creditNotePrefixCtrl.dispose();
    _debitNotePrefixCtrl.dispose();
    _expensePrefixCtrl.dispose();
    _proformaPrefixCtrl.dispose();
    _ewayBillPrefixCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    _salePrefixCtrl.text = await _sequenceService.getPrefix(VoucherType.sale);
    _salesReturnPrefixCtrl.text =
        await _sequenceService.getPrefix(VoucherType.salesReturn);
    _purchasePrefixCtrl.text =
        await _sequenceService.getPrefix(VoucherType.purchase);
    _purchaseReturnPrefixCtrl.text =
        await _sequenceService.getPrefix(VoucherType.purchaseReturn);
    _paymentPrefixCtrl.text =
        await _sequenceService.getPrefix(VoucherType.payment);
    _receiptPrefixCtrl.text =
        await _sequenceService.getPrefix(VoucherType.receipt);
    _quotationPrefixCtrl.text =
        await _sequenceService.getPrefix(VoucherType.quotation);
    _deliveryChallanPrefixCtrl.text =
        await _sequenceService.getPrefix(VoucherType.deliveryChallan);
    _creditNotePrefixCtrl.text =
        await _sequenceService.getPrefix(VoucherType.creditNote);
    _debitNotePrefixCtrl.text =
        await _sequenceService.getPrefix(VoucherType.debitNote);
    _expensePrefixCtrl.text =
        await _sequenceService.getPrefix(VoucherType.expense);
    _proformaPrefixCtrl.text =
        await _sequenceService.getPrefix(VoucherType.proforma);
    _ewayBillPrefixCtrl.text =
        await _sequenceService.getPrefix(VoucherType.eWayBill);

    _saleSeq = await _sequenceService.getCurrentSequence(VoucherType.sale);
    _salesReturnSeq =
        await _sequenceService.getCurrentSequence(VoucherType.salesReturn);
    _purchaseSeq =
        await _sequenceService.getCurrentSequence(VoucherType.purchase);
    _purchaseReturnSeq =
        await _sequenceService.getCurrentSequence(VoucherType.purchaseReturn);
    _paymentSeq =
        await _sequenceService.getCurrentSequence(VoucherType.payment);
    _receiptSeq =
        await _sequenceService.getCurrentSequence(VoucherType.receipt);
    _quotationSeq =
        await _sequenceService.getCurrentSequence(VoucherType.quotation);
    _deliveryChallanSeq =
        await _sequenceService.getCurrentSequence(VoucherType.deliveryChallan);
    _creditNoteSeq =
        await _sequenceService.getCurrentSequence(VoucherType.creditNote);
    _debitNoteSeq =
        await _sequenceService.getCurrentSequence(VoucherType.debitNote);
    _expenseSeq =
        await _sequenceService.getCurrentSequence(VoucherType.expense);
    _proformaSeq =
        await _sequenceService.getCurrentSequence(VoucherType.proforma);
    _ewayBillSeq =
        await _sequenceService.getCurrentSequence(VoucherType.eWayBill);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      await _sequenceService.setPrefix(VoucherType.sale, _salePrefixCtrl.text);
      await _sequenceService.setPrefix(
          VoucherType.salesReturn, _salesReturnPrefixCtrl.text);
      await _sequenceService.setPrefix(
          VoucherType.purchase, _purchasePrefixCtrl.text);
      await _sequenceService.setPrefix(
          VoucherType.purchaseReturn, _purchaseReturnPrefixCtrl.text);
      await _sequenceService.setPrefix(
          VoucherType.payment, _paymentPrefixCtrl.text);
      await _sequenceService.setPrefix(
          VoucherType.receipt, _receiptPrefixCtrl.text);
      await _sequenceService.setPrefix(
          VoucherType.quotation, _quotationPrefixCtrl.text);
      await _sequenceService.setPrefix(
          VoucherType.deliveryChallan, _deliveryChallanPrefixCtrl.text);
      await _sequenceService.setPrefix(
          VoucherType.creditNote, _creditNotePrefixCtrl.text);
      await _sequenceService.setPrefix(
          VoucherType.debitNote, _debitNotePrefixCtrl.text);
      await _sequenceService.setPrefix(
          VoucherType.expense, _expensePrefixCtrl.text);
      await _sequenceService.setPrefix(
          VoucherType.proforma, _proformaPrefixCtrl.text);
      await _sequenceService.setPrefix(
          VoucherType.eWayBill, _ewayBillPrefixCtrl.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All voucher prefix settings saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _formatPreview(String prefix, int seq) {
    final cleanPrefix =
        prefix.trim().isEmpty ? 'VOC' : prefix.trim().toUpperCase();
    final padStr = seq.toString().padLeft(4, '0');
    return '$cleanPrefix-#00-$padStr';
  }

  Widget _buildPrefixCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required TextEditingController controller,
    required int currentSeq,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Prefix Code',
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.8,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sample Preview',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatPreview(controller.text, currentSeq),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Voucher Prefix Settings',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.numbers, color: AppColors.primary, size: 22),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Customize prefixes for each transaction type. Generated IDs auto-increment sequentially (e.g., INV-#00-0001).',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'SALES TRANSACTIONS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondaryText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildPrefixCard(
                    title: 'Sale Voucher (Tax Invoice)',
                    icon: Icons.receipt_long,
                    iconColor: AppColors.primary,
                    controller: _salePrefixCtrl,
                    currentSeq: _saleSeq,
                  ),
                  _buildPrefixCard(
                    title: 'Sales Return Voucher',
                    icon: Icons.assignment_return,
                    iconColor: Colors.red.shade600,
                    controller: _salesReturnPrefixCtrl,
                    currentSeq: _salesReturnSeq,
                  ),
                  _buildPrefixCard(
                    title: 'Credit Note Voucher',
                    icon: Icons.note_add,
                    iconColor: Colors.indigo,
                    controller: _creditNotePrefixCtrl,
                    currentSeq: _creditNoteSeq,
                  ),
                  _buildPrefixCard(
                    title: 'Quotation / Estimate',
                    icon: Icons.request_quote,
                    iconColor: Colors.cyan.shade700,
                    controller: _quotationPrefixCtrl,
                    currentSeq: _quotationSeq,
                  ),
                  _buildPrefixCard(
                    title: 'Proforma Invoice',
                    icon: Icons.description,
                    iconColor: Colors.blue.shade700,
                    controller: _proformaPrefixCtrl,
                    currentSeq: _proformaSeq,
                  ),
                  _buildPrefixCard(
                    title: 'Delivery Challan',
                    icon: Icons.local_shipping,
                    iconColor: Colors.brown,
                    controller: _deliveryChallanPrefixCtrl,
                    currentSeq: _deliveryChallanSeq,
                  ),

                  const SizedBox(height: 14),
                  const Text(
                    'PURCHASE TRANSACTIONS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondaryText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildPrefixCard(
                    title: 'Purchase Voucher',
                    icon: Icons.shopping_bag,
                    iconColor: Colors.teal,
                    controller: _purchasePrefixCtrl,
                    currentSeq: _purchaseSeq,
                  ),
                  _buildPrefixCard(
                    title: 'Purchase Return Voucher',
                    icon: Icons.replay,
                    iconColor: Colors.orange.shade700,
                    controller: _purchaseReturnPrefixCtrl,
                    currentSeq: _purchaseReturnSeq,
                  ),
                  _buildPrefixCard(
                    title: 'Debit Note Voucher',
                    icon: Icons.post_add,
                    iconColor: Colors.amber.shade800,
                    controller: _debitNotePrefixCtrl,
                    currentSeq: _debitNoteSeq,
                  ),

                  const SizedBox(height: 14),
                  const Text(
                    'PAYMENTS & COMPLIANCE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondaryText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildPrefixCard(
                    title: 'Payment Voucher',
                    icon: Icons.payment,
                    iconColor: Colors.purple,
                    controller: _paymentPrefixCtrl,
                    currentSeq: _paymentSeq,
                  ),
                  _buildPrefixCard(
                    title: 'Receipt Voucher',
                    icon: Icons.account_balance_wallet,
                    iconColor: AppColors.success,
                    controller: _receiptPrefixCtrl,
                    currentSeq: _receiptSeq,
                  ),
                  _buildPrefixCard(
                    title: 'Expense Voucher',
                    icon: Icons.receipt,
                    iconColor: Colors.deepOrange,
                    controller: _expensePrefixCtrl,
                    currentSeq: _expenseSeq,
                  ),
                  _buildPrefixCard(
                    title: 'E-Way Bill Voucher',
                    icon: Icons.drive_eta,
                    iconColor: Colors.green.shade700,
                    controller: _ewayBillPrefixCtrl,
                    currentSeq: _ewayBillSeq,
                  ),

                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Save Prefix Settings',
                    onPressed: _saveSettings,
                    isLoading: _isSaving,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
