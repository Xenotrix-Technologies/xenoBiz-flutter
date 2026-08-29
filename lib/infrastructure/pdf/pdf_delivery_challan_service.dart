import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/entities/business_entity.dart';
import '../../domain/entities/delivery_challan_entity.dart';

class PdfDeliveryChallanService {
  static Future<Uint8List> generatePdf({
    required DeliveryChallanEntity challan,
    required BusinessEntity business,
  }) async {
    final pdf = pw.Document();
    final dateFormatter = DateFormat('MMM dd, yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (pw.Context context) {
          return pw.Column(
            children: [
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
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      if (business.address.isNotEmpty)
                        pw.Text(business.address, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      if (business.phone.isNotEmpty)
                        pw.Text('Phone: ${business.phone}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      if ((business.email ?? '').isNotEmpty)
                        pw.Text('Email: ${business.email}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      if ((business.gstin ?? '').isNotEmpty)
                        pw.Text('GSTIN: ${business.gstin}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue900,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          'DELIVERY CHALLAN',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text('Challan No: ${challan.challanNumber}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Date: ${dateFormatter.format(challan.issueDate)}', style: const pw.TextStyle(fontSize: 9)),
                      if (challan.deliveryDate != null)
                        pw.Text('Delivery Date: ${dateFormatter.format(challan.deliveryDate!)}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 10),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'This is a Delivery Challan and not a Tax Invoice.',
                    style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  ),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            // DELIVER TO & DELIVERY DETAILS GRID
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // DELIVER TO
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'DELIVER TO (PARTY)',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          challan.customerName.isNotEmpty ? challan.customerName : 'General Customer',
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                        ),
                        if (challan.customerAddress.isNotEmpty)
                          pw.Text(challan.customerAddress, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                        if (challan.customerPhone.isNotEmpty)
                          pw.Text('Phone: ${challan.customerPhone}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                        if (challan.customerGstin.isNotEmpty)
                          pw.Text('GSTIN: ${challan.customerGstin}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),

                // DELIVERY DETAILS
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'DELIVERY DETAILS',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                        ),
                        pw.SizedBox(height: 4),
                        if (challan.transporterName.isNotEmpty)
                          pw.Text('Transporter: ${challan.transporterName}', style: const pw.TextStyle(fontSize: 9)),
                        if (challan.vehicleNumber.isNotEmpty)
                          pw.Text('Vehicle No: ${challan.vehicleNumber}', style: const pw.TextStyle(fontSize: 9)),
                        if (challan.placeOfSupply.isNotEmpty)
                          pw.Text('Place of Supply: ${challan.placeOfSupply}', style: const pw.TextStyle(fontSize: 9)),
                        if (challan.referenceNumber.isNotEmpty)
                          pw.Text('Ref / PO No: ${challan.referenceNumber}', style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('Status: ${challan.status.label}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // ITEMS TABLE
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              columnWidths: {
                0: const pw.FixedColumnWidth(28),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(1.2),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1),
              },
              headers: ['No.', 'Description / Product', 'HSN/SAC', 'Qty', 'Unit'],
              data: List.generate(challan.items.length, (idx) {
                final item = challan.items[idx];
                return [
                  '${idx + 1}',
                  item.productName,
                  item.hsnSac.isNotEmpty ? item.hsnSac : 'N/A',
                  '${item.quantity}',
                  item.unit,
                ];
              }),
            ),
            pw.SizedBox(height: 12),

            // TOTAL QUANTITY SUMMARY
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(4),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Text(
                    'TOTAL QUANTITY: ${challan.totalQuantity}',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // REMARKS / NOTES
            if (challan.notes.isNotEmpty) ...[
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('REMARKS / NOTES:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(challan.notes, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
            ],

            // SIGNATURE BLOCK
            pw.SizedBox(height: 30),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(width: 140, height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 4),
                    pw.Text("Receiver's Signature", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Received By: _________________', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    pw.Text('Date: ________________________', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('For ${business.name}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 24),
                    pw.Container(width: 140, height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 4),
                    pw.Text('Authorized Signatory', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> printChallan({
    required DeliveryChallanEntity challan,
    required BusinessEntity business,
  }) async {
    final bytes = await generatePdf(challan: challan, business: business);
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  static Future<void> sharePdf({
    required DeliveryChallanEntity challan,
    required BusinessEntity business,
  }) async {
    final bytes = await generatePdf(challan: challan, business: business);
    await Printing.sharePdf(bytes: bytes, filename: 'Challan_${challan.challanNumber}.pdf');
  }
}
