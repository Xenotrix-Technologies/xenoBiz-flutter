import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../application/providers/app_providers.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class WhatsAppTemplatesPage extends ConsumerWidget {
  const WhatsAppTemplatesPage({super.key});

  Future<void> _launchWhatsApp(String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUri = Uri.parse('https://wa.me/?text=$encodedMessage');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(whatsappTemplatesProvider);

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
        heroTag: null,
        backgroundColor: AppColors.primary,
        onPressed: () {
          context.push(RouteNames.newTemplate);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: templates.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, idx) {
          final tpl = templates[idx];
          return AppCard(
            onTap: () {
              _launchWhatsApp(tpl['body'] ?? '');
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tpl['title'] ?? 'Template',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.successContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tpl['status'] ?? 'Approved',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  tpl['body'] ?? '',
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tap to Send via WhatsApp',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.secondary, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
