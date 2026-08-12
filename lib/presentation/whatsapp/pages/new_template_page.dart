import 'package:flutter/material.dart';
import '../../../const/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class NewTemplatePage extends StatelessWidget {
  const NewTemplatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Template'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const AppTextField(label: 'Template Title'),
            const SizedBox(height: 14),
            const AppTextField(label: 'Message Text', maxLines: 5),
            const SizedBox(height: 28),
            AppButton(
              text: 'Save Template',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
