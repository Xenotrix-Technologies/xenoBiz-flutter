import 'package:flutter/material.dart';
import '../../../const/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class EditRulePage extends StatelessWidget {
  const EditRulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Reminder Rule'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const AppTextField(label: 'Rule Name'),
            const SizedBox(height: 14),
            const AppTextField(label: 'Trigger Event (Days Before/After Due Date)', keyboardType: TextInputType.number),
            const SizedBox(height: 14),
            const AppTextField(label: 'Message Body Template', maxLines: 4),
            const SizedBox(height: 28),
            AppButton(
              text: 'Save Rule',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
