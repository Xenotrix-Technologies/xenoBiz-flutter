import 'package:flutter/material.dart';
import '../../../domain/entities/invoice_entity.dart';
import 'return_voucher_screen.dart';

class CreateReturnPage extends StatelessWidget {
  final InvoiceType type;
  final dynamic existingReturn;

  const CreateReturnPage({
    super.key,
    required this.type,
    this.existingReturn,
  });

  @override
  Widget build(BuildContext context) {
    final returnType = type == InvoiceType.purchase ? ReturnType.purchaseReturn : ReturnType.salesReturn;
    return ReturnVoucherScreen(
      returnType: returnType,
      existingReturn: existingReturn,
    );
  }
}
