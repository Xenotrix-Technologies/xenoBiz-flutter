import 'package:flutter/material.dart';
import '../../../const/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class CreatePurchaseOrderPage extends StatelessWidget {
  const CreatePurchaseOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Purchase Order'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const AppTextField(label: 'Supplier Name'),
            const SizedBox(height: 14),
            const AppTextField(label: 'PO Number'),
            const SizedBox(height: 14),
            const AppTextField(label: 'Total Amount (₹)', keyboardType: TextInputType.number),
            const SizedBox(height: 28),
            AppButton(
              text: 'Save Purchase Order',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
