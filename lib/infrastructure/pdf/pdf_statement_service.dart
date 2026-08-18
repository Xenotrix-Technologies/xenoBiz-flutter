import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/entities/business_entity.dart';
import '../../domain/entities/customer_entity.dart';

class PdfStatementLedgerRow {
  final String date;
  final String description;
  final String reference;
  final double debit; // (+) Charge/Invoice
  final double credit; // (-) Payment
  final double balance;

  const PdfStatementLedgerRow({
    required this.date,
    required this.description,
    required this.reference,
    required this.debit,
    required this.credit,
    required this.balance,
  });
}

class PdfStatementService {
  static Future<Uint8List> generateCustomerStatement({
    required BusinessEntity business,
    required CustomerEntity customer,
    required double totalPurchases,
    required double totalPaid,
    required double outstandingBalance,
    required List<PdfStatementLedgerRow> ledgerRows,
  }) async {
    final pdf = pw.Document();
    final dateFormatter = DateFormat('dd MMMM yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Business & Statement Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        business.name.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      if (business.address.isNotEmpty)
                        pw.Text(business.address, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      if (business.phone.isNotEmpty)
                        pw.Text('Phone: ${business.phone}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('CUSTOMER STATEMENT', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                      pw.SizedBox(height: 4),
                      pw.Text('Date: ${dateFormatter.format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 14),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              // Customer Info Header
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('STATEMENT FOR', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                        pw.SizedBox(height: 2),
                        pw.Text(customer.name, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        if (customer.phone.isNotEmpty)
                          pw.Text('Phone: ${customer.phone}', style: const pw.TextStyle(fontSize: 9)),
                        if (customer.email.isNotEmpty)
                          pw.Text('Email: ${customer.email}', style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _pdfSummaryMini('Total Invoiced', 'INR ${totalPurchases.toStringAsFixed(0)}'),
                        _pdfSummaryMini('Total Paid', 'INR ${totalPaid.toStringAsFixed(0)}', color: PdfColors.green800),
                        _pdfSummaryMini('Outstanding Due', 'INR ${outstandingBalance.toStringAsFixed(0)}', isBold: true, color: PdfColors.red800),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // LEDGER TABLE
              pw.Text('ACCOUNT LEDGER TRANSACTIONS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: ['DATE', 'DESCRIPTION', 'REFERENCE', 'CHARGES (+)', 'PAYMENTS (-)', 'BALANCE'],
                data: ledgerRows.map((row) {
                  return [
                    row.date,
                    row.description,
                    row.reference,
                    row.debit > 0 ? 'INR ${row.debit.toStringAsFixed(0)}' : '-',
                    row.credit > 0 ? 'INR ${row.credit.toStringAsFixed(0)}' : '-',
                    'INR ${row.balance.toStringAsFixed(0)}',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                  5: pw.Alignment.centerRight,
                },
              ),

              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Generated by XenoBiz Business Manager',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _pdfSummaryMini(String label, String value, {bool isBold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text('$label: ', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> shareCustomerStatement({
    required BusinessEntity business,
    required CustomerEntity customer,
    required double totalPurchases,
    required double totalPaid,
    required double outstandingBalance,
    required List<PdfStatementLedgerRow> ledgerRows,
  }) async {
    final pdfBytes = await generateCustomerStatement(
      business: business,
      customer: customer,
      totalPurchases: totalPurchases,
      totalPaid: totalPaid,
      outstandingBalance: outstandingBalance,
      ledgerRows: ledgerRows,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Statement_${customer.name.replaceAll(' ', '_')}.pdf',
    );
  }
}
