import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/lead_entity.dart';

enum ExportFormat { excel, pdf }

class ExportField {
  final String key;
  final String label;
  final bool defaultSelected;

  const ExportField({
    required this.key,
    required this.label,
    this.defaultSelected = true,
  });
}

class LeadExportService {
  static const List<ExportField> availableFields = [
    ExportField(key: 'contactName', label: 'Lead Name', defaultSelected: true),
    ExportField(key: 'title', label: 'Title / Subject', defaultSelected: false),
    ExportField(key: 'phone', label: 'Phone Number', defaultSelected: true),
    ExportField(key: 'email', label: 'Email', defaultSelected: true),
    ExportField(key: 'companyName', label: 'Company', defaultSelected: true),
    ExportField(key: 'source', label: 'Lead Source', defaultSelected: true),
    ExportField(key: 'stage', label: 'Stage / Status', defaultSelected: true),
    ExportField(key: 'priority', label: 'Priority', defaultSelected: true),
    ExportField(key: 'estimatedValue', label: 'Expected Value', defaultSelected: true),
    ExportField(key: 'expectedClosingDate', label: 'Expected Closing Date', defaultSelected: true),
    ExportField(key: 'assignedStaff', label: 'Assigned Staff', defaultSelected: true),
    ExportField(key: 'nextFollowUpDate', label: 'Follow-up Date', defaultSelected: true),
    ExportField(key: 'notes', label: 'Notes', defaultSelected: true),
    ExportField(key: 'address', label: 'Address', defaultSelected: false),
    ExportField(key: 'whatsapp', label: 'WhatsApp', defaultSelected: false),
    ExportField(key: 'createdBy', label: 'Created By', defaultSelected: false),
    ExportField(key: 'createdAt', label: 'Created Date', defaultSelected: false),
    ExportField(key: 'updatedAt', label: 'Updated Date', defaultSelected: false),
    ExportField(key: 'lostReason', label: 'Lost Reason', defaultSelected: false),
  ];

  static String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  static String _formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('dd/MM/yyyy hh:mm a').format(dt);
  }

  static String _formatCurrency(double val) {
    return '₹${val.toStringAsFixed(0)}';
  }

  static String _getStageName(LeadStage stage) {
    switch (stage) {
      case LeadStage.newLead:
        return 'New';
      case LeadStage.contacted:
        return 'Contacted';
      case LeadStage.qualified:
        return 'Qualified';
      case LeadStage.proposalSent:
        return 'Proposal';
      case LeadStage.negotiating:
        return 'Negotiation';
      case LeadStage.won:
        return 'Won';
      case LeadStage.lost:
        return 'Lost';
    }
  }

  static String _getFieldValue(LeadEntity lead, String fieldKey) {
    switch (fieldKey) {
      case 'contactName':
        return lead.contactName.isNotEmpty ? lead.contactName : lead.title;
      case 'title':
        return lead.title;
      case 'phone':
        return lead.phone;
      case 'email':
        return lead.email;
      case 'companyName':
        return lead.companyName;
      case 'source':
        return lead.source;
      case 'stage':
        return _getStageName(lead.stage);
      case 'priority':
        return lead.priority.name.toUpperCase();
      case 'estimatedValue':
        return _formatCurrency(lead.estimatedValue);
      case 'expectedClosingDate':
        return _formatDate(lead.expectedClosingDate);
      case 'assignedStaff':
        return lead.assignedStaff;
      case 'nextFollowUpDate':
        final d = _formatDate(lead.nextFollowUpDate);
        final t = lead.nextFollowUpTime ?? '';
        return d.isNotEmpty ? (t.isNotEmpty ? '$d ($t)' : d) : '';
      case 'notes':
        return lead.notes;
      case 'address':
        return lead.address;
      case 'whatsapp':
        return lead.whatsapp;
      case 'createdBy':
        return lead.createdBy;
      case 'createdAt':
        return _formatDate(lead.createdAt);
      case 'updatedAt':
        return _formatDate(lead.updatedAt);
      case 'lostReason':
        return lead.lostReason ?? '';
      default:
        return '';
    }
  }

  /// Exports leads to an Excel (.xlsx) file and triggers share/open
  Future<File> exportToExcel({
    required List<LeadEntity> leads,
    required List<String> selectedFieldKeys,
    String? filterSummary,
  }) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['CRM Leads'];
    excel.delete('Sheet1'); // Remove default sheet if exists

    final selectedFields = availableFields
        .where((f) => selectedFieldKeys.contains(f.key))
        .toList();

    // Create Header Row
    List<CellValue> headerRow = selectedFields
        .map((f) => TextCellValue(f.label))
        .toList();

    sheetObject.appendRow(headerRow);

    // Apply header style
    for (int col = 0; col < selectedFields.length; col++) {
      var cell = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
      );
      cell.cellStyle = CellStyle(
        bold: true,
        fontFamily: getFontFamily(FontFamily.Arial),
        fontSize: 11,
      );
    }

    // Append Lead Data Rows
    for (var lead in leads) {
      List<CellValue> dataRow = [];
      for (var field in selectedFields) {
        final val = _getFieldValue(lead, field.key);
        if (field.key == 'estimatedValue') {
          dataRow.add(DoubleCellValue(lead.estimatedValue));
        } else {
          dataRow.add(TextCellValue(val));
        }
      }
      sheetObject.appendRow(dataRow);
    }

    // Set Column Widths
    for (int col = 0; col < selectedFields.length; col++) {
      sheetObject.setColumnWidth(col, 20.0);
    }

    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to generate Excel bytes');

    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/CRM_Leads_$timestamp.xlsx');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Exported CRM Leads (${leads.length} records)',
    );

    return file;
  }

  /// Exports leads to a professional PDF report
  Future<void> exportToPdf({
    required List<LeadEntity> leads,
    required List<String> selectedFieldKeys,
    String filterSummary = 'All Leads',
  }) async {
    final pdf = pw.Document();
    final selectedFields = availableFields
        .where((f) => selectedFieldKeys.contains(f.key))
        .toList();

    // Use Landscape if more than 5 columns selected for clean readable table layout
    final pageFormat = selectedFields.length > 5
        ? PdfPageFormat.a4.landscape
        : PdfPageFormat.a4;

    final nowStr = _formatDateTime(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(24),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CRM LEADS REPORT',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'XenoBiz Business Manager',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [

                      pw.Text(
                        'Generated: $nowStr',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Scope: $filterSummary',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                      ),
                      pw.Text(
                        'Total Records: ${leads.length}',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.blue900, thickness: 1.5),
              pw.SizedBox(height: 8),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue800,
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey900,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              headers: selectedFields.map((f) => f.label).toList(),
              data: leads.map((lead) {
                return selectedFields.map((field) {
                  return _getFieldValue(lead, field.key);
                }).toList();
              }).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'CRM_Leads_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }
}
