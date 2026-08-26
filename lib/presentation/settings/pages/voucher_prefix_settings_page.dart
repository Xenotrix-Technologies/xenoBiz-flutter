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

  int _saleSeq = 1;
  int _salesReturnSeq = 1;
  int _purchaseSeq = 1;
  int _purchaseReturnSeq = 1;
  int _paymentSeq = 1;
  int _receiptSeq = 1;

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voucher prefix settings saved successfully!'),
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sample Preview',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPreview(controller.text, currentSeq),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlue,
                          letterSpacing: 0.5,
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
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Voucher Prefix Settings'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informational Header Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.numbers_rounded,
                            color: AppColors.primaryBlue, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Customize prefixes for each voucher type. Generated IDs auto-increment sequentially (e.g., INV-#00-0001).',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildPrefixCard(
                    title: 'Sale Voucher',
                    icon: Icons.point_of_sale_rounded,
                    iconColor: AppColors.primaryBlue,
                    controller: _salePrefixCtrl,
                    currentSeq: _saleSeq,
                  ),

                  _buildPrefixCard(
                    title: 'Sales Return Voucher',
                    icon: Icons.assignment_return_rounded,
                    iconColor: AppColors.danger,
                    controller: _salesReturnPrefixCtrl,
                    currentSeq: _salesReturnSeq,
                  ),

                  _buildPrefixCard(
                    title: 'Purchase Voucher',
                    icon: Icons.shopping_bag_rounded,
                    iconColor: AppColors.success,
                    controller: _purchasePrefixCtrl,
                    currentSeq: _purchaseSeq,
                  ),

                  _buildPrefixCard(
                    title: 'Purchase Return Voucher',
                    icon: Icons.keyboard_return_rounded,
                    iconColor: Colors.orange,
                    controller: _purchaseReturnPrefixCtrl,
                    currentSeq: _purchaseReturnSeq,
                  ),

                  _buildPrefixCard(
                    title: 'Payment Voucher',
                    icon: Icons.arrow_circle_up_rounded,
                    iconColor: Colors.purple,
                    controller: _paymentPrefixCtrl,
                    currentSeq: _paymentSeq,
                  ),

                  _buildPrefixCard(
                    title: 'Receipt Voucher',
                    icon: Icons.arrow_circle_down_rounded,
                    iconColor: Colors.teal,
                    controller: _receiptPrefixCtrl,
                    currentSeq: _receiptSeq,
                  ),

                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Save Prefix Settings',
                    icon: Icons.save_rounded,
                    isLoading: _isSaving,
                    onPressed: _saveSettings,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
