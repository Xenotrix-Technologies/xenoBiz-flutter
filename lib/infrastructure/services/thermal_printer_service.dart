import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../domain/entities/business_entity.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/invoice_display_settings.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/tax_settings_entity.dart';
import 'esc_pos_invoice_builder.dart';

class ThermalPrinterResult {
  final bool success;
  final String message;
  const ThermalPrinterResult({required this.success, required this.message});
}

/// Service managing printer discovery, connection state, and raw ESC/POS byte printing.
class ThermalPrinterService {
  static Printer? _connectedPrinter;

  static Printer? get connectedPrinter => _connectedPrinter;

  static void setConnectedPrinter(Printer? printer) {
    _connectedPrinter = printer;
  }

  /// Send ESC/POS bytes directly to connected thermal printer.
  static Future<ThermalPrinterResult> printInvoiceEscPos({
    required BuildContext context,
    required InvoiceEntity invoice,
    required BusinessEntity business,
    required InvoiceDisplaySettingsEntity settings,
    required TaxSettingsEntity taxSettings,
    CustomerEntity? customer,
    double previousBalance = 0.0,
    String paymentMethod = 'Cash',
  }) async {
    try {
      // 1. Generate raw ESC/POS bytes
      final Uint8List escPosBytes = EscPosInvoiceBuilder.buildInvoiceBytes(
        invoice: invoice,
        business: business,
        settings: settings,
        taxSettings: taxSettings,
        customer: customer,
        previousBalance: previousBalance,
        paymentMethod: paymentMethod,
      );

      Printer? printer = _connectedPrinter;

      // 2. Discover/auto-select connected printer if null
      if (printer == null) {
        final printers = await Printing.listPrinters();
        if (printers.isNotEmpty) {
          printer = printers.firstWhere(
            (p) => p.isAvailable && (p.name.toLowerCase().contains('pos') || p.name.toLowerCase().contains('thermal') || p.name.toLowerCase().contains('print')),
            orElse: () => printers.first,
          );
          _connectedPrinter = printer;
        }
      }

      // 3. Prompt user picker if printer still null
      if (printer == null) {
        if (!context.mounted) {
          return const ThermalPrinterResult(
            success: false,
            message: 'No thermal printer connected.',
          );
        }
        final pickedPrinter = await Printing.pickPrinter(context: context);
        if (pickedPrinter != null) {
          _connectedPrinter = pickedPrinter;
          printer = pickedPrinter;
        } else {
          return const ThermalPrinterResult(
            success: false,
            message: 'No thermal printer connected. Please connect a printer.',
          );
        }
      }

      // 4. Send raw ESC/POS bytes directly to printer
      final result = await Printing.directPrintPdf(
        printer: printer,
        onLayout: (PdfPageFormat format) async => escPosBytes,
        format: const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity),
      );

      if (result) {
        return ThermalPrinterResult(
          success: true,
          message: 'Invoice sent directly to printer "${printer.name}"',
        );
      } else {
        return const ThermalPrinterResult(
          success: false,
          message: 'Failed to send ESC/POS bytes to thermal printer.',
        );
      }
    } catch (e) {
      return ThermalPrinterResult(
        success: false,
        message: 'Printer error: ${e.toString()}',
      );
    }
  }
}
