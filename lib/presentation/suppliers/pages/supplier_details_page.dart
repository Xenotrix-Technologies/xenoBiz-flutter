import 'package:flutter/material.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class SupplierDetailsPage extends StatelessWidget {
  const SupplierDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Supplier Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('TechHardware Distributors Ltd', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
              SizedBox(height: 6),
              Text('Contact: +91 98950 12345 • sales@techhardware.in', style: TextStyle(color: AppColors.outline)),
              SizedBox(height: 16),
              Text('Payable Balance: ₹42,000', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.error)),
            ],
          ),
        ),
      ),
    );
  }
}
