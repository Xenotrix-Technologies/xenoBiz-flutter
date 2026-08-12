import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../application/bloc/invoice_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/strings.dart';
import '../../../domain/entities/payment_entity.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';

class InvoiceDetailsPage extends StatelessWidget {
  const InvoiceDetailsPage({super.key});

  Future<void> _shareInvoice() async {
    const text = 'Invoice #XB-2026-004 generated via XenoBiz Manager. Total: ₹45,000';
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showRecordPaymentDialog(BuildContext context) {
    final amountCtrl = TextEditingController(text: '14500');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.recordPayment),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Invoice #XB-2026-004'),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Payment Amount (₹)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text) ?? 1000.0;
              final payment = PaymentEntity(
                id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
                invoiceId: 'inv_101',
                customerId: 'cust_101',
                customerName: 'Apex Technologies Pvt Ltd',
                amount: amount,
                paymentMode: 'UPI',
                paymentDate: DateTime.now(),
              );
              context.read<InvoiceBloc>().add(RecordPaymentSubmittedEvent(payment));
              Navigator.pop(ctx);
            },
            child: const Text('Confirm Payment'),
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
        title: const Text(AppStrings.invoiceDetails),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareInvoice,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('INVOICE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.secondary)),
                          SizedBox(height: 2),
                          Text('#XB-2026-004', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        ],
                      ),
                      StatusChip.partiallyPaid(),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text('Customer: Apex Technologies Pvt Ltd', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const Text('Phone: +91 98470 11223', style: TextStyle(fontSize: 13, color: AppColors.outline)),
                  const SizedBox(height: 16),
                  const _ItemRow('Wireless Smart POS Machine v2 (5x)', '₹42,500'),
                  const _ItemRow('GST Tax (18%)', '₹7,650'),
                  const _ItemRow('Special Discount', '-₹5,150'),
                  const Divider(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Grand Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      Text('₹45,000', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Balance Due', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.error)),
                      Text('₹14,500', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.error)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Share WhatsApp',
                    icon: Icons.chat,
                    variant: AppButtonVariant.secondary,
                    onPressed: () {
                      context.push(RouteNames.whatsappTemplates);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Record Payment',
                    icon: Icons.payments,
                    onPressed: () => _showRecordPaymentDialog(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final String title;
  final String price;
  const _ItemRow(this.title, this.price);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: AppColors.onSurface)),
          Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ],
      ),
    );
  }
}
