import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/entities/business_entity.dart';

class PdfLedgerTransactionItem {
  final String time;
  final String title;
  final String type;
  final String paymentMethod;
  final double amount;
  final bool isIncome;

  const PdfLedgerTransactionItem({
    required this.time,
    required this.title,
    required this.type,
    required this.paymentMethod,
    required this.amount,
    required this.isIncome,
  });
}

class PdfLedgerService {
  static Future<Uint8List> generatePdf({
    required DateTime date,
    required BusinessEntity business,
    required double openingBalance,
    required double cashIn,
    required double cashOut,
    required double closingBalance,
    required double totalSales,
    required double cashSales,
    required double upiCardSales,
    required double totalExpenses,
    required double cashExpenses,
    required double accountExpenses,
    required List<PdfLedgerTransactionItem> salesTransactions,
    required List<PdfLedgerTransactionItem> expenseTransactions,
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
              // Header
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
                      pw.Text('DAILY LEDGER REPORT', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                      pw.SizedBox(height: 4),
                      pw.Text('Date: ${dateFormatter.format(date)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 14),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              // PHYSICAL CASH BALANCE SUMMARY
              pw.Text('CASH BALANCE SUMMARY', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _pdfMetricItem('Opening Balance', 'INR ${openingBalance.toStringAsFixed(0)}'),
                    _pdfMetricItem('Cash In (+)', 'INR ${cashIn.toStringAsFixed(0)}', color: PdfColors.green800),
                    _pdfMetricItem('Cash Out (-)', 'INR ${cashOut.toStringAsFixed(0)}', color: PdfColors.red800),
                    _pdfMetricItem('Closing Balance', 'INR ${closingBalance.toStringAsFixed(0)}', isBold: true),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              // SALES & EXPENSE SUMMARY BREAKDOWN
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.blue200),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('SALES SUMMARY', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                          pw.SizedBox(height: 6),
                          _pdfSummaryRow('Total Sales', 'INR ${totalSales.toStringAsFixed(0)}', isBold: true),
                          _pdfSummaryRow('Cash Received', 'INR ${cashSales.toStringAsFixed(0)}'),
                          _pdfSummaryRow('UPI / Card / Other', 'INR ${upiCardSales.toStringAsFixed(0)}'),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.orange200),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('EXPENSES SUMMARY', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.orange900)),
                          pw.SizedBox(height: 6),
                          _pdfSummaryRow('Total Expenses', 'INR ${totalExpenses.toStringAsFixed(0)}', isBold: true),
                          _pdfSummaryRow('Cash Expenses', 'INR ${cashExpenses.toStringAsFixed(0)}'),
                          _pdfSummaryRow('Account Expenses', 'INR ${accountExpenses.toStringAsFixed(0)}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // SALES TRANSACTIONS TABLE
              if (salesTransactions.isNotEmpty) ...[
                pw.Text('SALES TRANSACTIONS (${salesTransactions.length})', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.SizedBox(height: 6),
                pw.TableHelper.fromTextArray(
                  headers: ['TIME', 'DESCRIPTION', 'TYPE', 'PAYMENT', 'AMOUNT'],
                  data: salesTransactions.map((tx) {
                    return [
                      tx.time,
                      tx.title,
                      tx.type,
                      tx.paymentMethod,
                      '+ INR ${tx.amount.toStringAsFixed(0)}',
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                  cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.center,
                    3: pw.Alignment.center,
                    4: pw.Alignment.centerRight,
                  },
                ),
                pw.SizedBox(height: 14),
              ],

              // EXPENSE TRANSACTIONS TABLE
              if (expenseTransactions.isNotEmpty) ...[
                pw.Text('EXPENSE TRANSACTIONS (${expenseTransactions.length})', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.orange900)),
                pw.SizedBox(height: 6),
                pw.TableHelper.fromTextArray(
                  headers: ['TIME', 'CATEGORY / NOTE', 'TYPE', 'PAYMENT', 'AMOUNT'],
                  data: expenseTransactions.map((tx) {
                    return [
                      tx.time,
                      tx.title,
                      tx.type,
                      tx.paymentMethod,
                      '- INR ${tx.amount.toStringAsFixed(0)}',
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.orange800),
                  cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.center,
                    3: pw.Alignment.center,
                    4: pw.Alignment.centerRight,
                  },
                ),
              ],

              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Generated by XenoBiz POS Application',
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

  static pw.Widget _pdfMetricItem(String label, String value, {bool isBold = false, PdfColor? color}) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color ?? PdfColors.black,
          ),
        ),
      ],
    );
  }

  static pw.Widget _pdfSummaryRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  static Future<void> shareLedgerReport({
    required DateTime date,
    required BusinessEntity business,
    required double openingBalance,
    required double cashIn,
    required double cashOut,
    required double closingBalance,
    required double totalSales,
    required double cashSales,
    required double upiCardSales,
    required double totalExpenses,
    required double cashExpenses,
    required double accountExpenses,
    required List<PdfLedgerTransactionItem> salesTransactions,
    required List<PdfLedgerTransactionItem> expenseTransactions,
  }) async {
    final pdfBytes = await generatePdf(
      date: date,
      business: business,
      openingBalance: openingBalance,
      cashIn: cashIn,
      cashOut: cashOut,
      closingBalance: closingBalance,
      totalSales: totalSales,
      cashSales: cashSales,
      upiCardSales: upiCardSales,
      totalExpenses: totalExpenses,
      cashExpenses: cashExpenses,
      accountExpenses: accountExpenses,
      salesTransactions: salesTransactions,
      expenseTransactions: expenseTransactions,
    );

    final dateStr = DateFormat('yyyy_MM_dd').format(date);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Daily_Ledger_$dateStr.pdf',
    );
  }
}
