import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/app_providers.dart';
import '../../../const/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class NewTemplatePage extends ConsumerWidget {
  const NewTemplatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New WhatsApp Template'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(label: 'Template Title', controller: titleCtrl),
            const SizedBox(height: 14),
            AppTextField(label: 'Message Content', controller: bodyCtrl, maxLines: 5, hint: 'Use {CustomerName}, {Amount}, {InvoiceNumber}...'),
            const SizedBox(height: 28),
            AppButton(
              text: 'Save & Register Template',
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty && bodyCtrl.text.trim().isNotEmpty) {
                  final newTpl = {
                    'id': 'tpl_${DateTime.now().millisecondsSinceEpoch}',
                    'title': titleCtrl.text.trim(),
                    'body': bodyCtrl.text.trim(),
                    'status': 'Approved',
                  };
                  final currentList = ref.read(whatsappTemplatesProvider);
                  ref.read(whatsappTemplatesProvider.notifier).state = [newTpl, ...currentList];
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('WhatsApp template created & registered successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill out all fields'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
