import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class WhatsAppTemplatesPage extends StatelessWidget {
  const WhatsAppTemplatesPage({super.key});

  Future<void> _launchWhatsApp(String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUri = Uri.parse('https://wa.me/?text=$encodedMessage');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('WhatsApp Templates'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.rule),
            onPressed: () {
              context.push(RouteNames.automatedReminders);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          context.push(RouteNames.newTemplate);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            onTap: () {
              _launchWhatsApp(
                'Dear Customer, your invoice #XB-2026-004 of ₹45,000 is generated. Please pay via UPI link: https://pay.xenobiz.com/inv/101',
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Invoice Sharing Template', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primary)),
                SizedBox(height: 6),
                Text('Hi {{customer_name}}, thank you for shopping at {{business_name}}. Here is your invoice #{{invoice_num}} for {{amount}}.', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                SizedBox(height: 10),
                Text('Tap to Send WhatsApp Message', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.secondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
