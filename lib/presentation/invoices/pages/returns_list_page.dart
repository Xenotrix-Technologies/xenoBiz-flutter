import 'package:flutter/material.dart';
import '../../../domain/entities/invoice_entity.dart';
import 'credit_debit_notes_page.dart';

class ReturnsListPage extends StatelessWidget {
  final InvoiceType type;

  const ReturnsListPage({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return CreditDebitNotesPage(initialType: type);
  }
}
