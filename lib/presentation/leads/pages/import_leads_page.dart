import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../application/bloc/lead_bloc.dart';
import '../../../application/bloc/lead_import_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../infrastructure/services/lead_import_service.dart';
import '../../widgets/app_card.dart';


class ImportLeadsPage extends StatelessWidget {
  const ImportLeadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LeadImportBloc>(
      create: (_) => LeadImportBloc(
        importService: getIt<LeadImportService>(),
      ),
      child: const _ImportLeadsView(),
    );
  }
}

class _ImportLeadsView extends StatefulWidget {
  const _ImportLeadsView();

  @override
  State<_ImportLeadsView> createState() => _ImportLeadsViewState();
}

class _ImportLeadsViewState extends State<_ImportLeadsView> {
  bool _showErrorDetails = false;

  void _pickFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        if (context.mounted) {
          context.read<LeadImportBloc>().add(SelectImportFileEvent(result.files.first));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File selection failed: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _downloadTemplate(BuildContext context) async {
    try {
      await getIt<LeadImportService>().generateTemplate();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Import template generated and ready to share!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Template generation failed: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bulk Import Leads', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkBlueText,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<LeadImportBloc>().add(ResetImportEvent()),
          ),
        ],
      ),
      body: BlocConsumer<LeadImportBloc, LeadImportState>(
        listener: (context, state) {
          if (state is ImportErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ImportLoadingState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primaryBlue),
                  const SizedBox(height: 16),
                  Text(state.message, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                ],
              ),
            );
          }

          if (state is ImportMappingState) {
            return _buildMappingStep(context, state);
          }

          if (state is ImportPreviewState) {
            return _buildPreviewStep(context, state);
          }

          if (state is ImportSuccessState) {
            return _buildSuccessStep(context, state);
          }

          return _buildUploadStep(context);
        },
      ),
    );
  }

  // ==================== STEP 1: UPLOAD FILE & DOWNLOAD TEMPLATE ====================
  Widget _buildUploadStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_upload_rounded, size: 36, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Upload Excel or CSV File',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.darkBlueText),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Add multiple leads at once by uploading your existing spreadsheet or lead list.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                ),
                const SizedBox(height: 20),

                // Upload Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.file_open_rounded),
                  label: const Text('Choose File', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  onPressed: () => _pickFile(context),
                ),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Supported formats: .xlsx, .csv',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Template Download Card
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.file_download_rounded, color: AppColors.success),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Download Import Template',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.darkBlueText),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Get a pre-formatted Excel template with standard lead column headers.',
                        style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, color: AppColors.primaryBlue),
                  onPressed: () => _downloadTemplate(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Instructions Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Import Guidelines:',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primaryBlue),
                ),
                SizedBox(height: 8),
                Text('• Lead Name / Contact Name is required for every row.', style: TextStyle(fontSize: 12, color: AppColors.darkBlueText)),
                SizedBox(height: 4),
                Text('• Phone numbers and email addresses will be validated.', style: TextStyle(fontSize: 12, color: AppColors.darkBlueText)),
                SizedBox(height: 4),
                Text('• Dates should be formatted as DD/MM/YYYY or YYYY-MM-DD.', style: TextStyle(fontSize: 12, color: AppColors.darkBlueText)),
                SizedBox(height: 4),
                Text('• Duplicates will be checked automatically against existing leads.', style: TextStyle(fontSize: 12, color: AppColors.darkBlueText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STEP 2: COLUMN MAPPING ====================
  Widget _buildMappingStep(BuildContext context, ImportMappingState state) {
    final availableCrmFields = Map<String, String>.from(LeadImportService.crmFields);
    availableCrmFields['SKIP'] = '-- Skip this column --';

    return Column(
      children: [
        // Step Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.alt_route_rounded, color: AppColors.primaryBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Map Columns — ${state.file.name}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.darkBlueText),
                    ),
                    Text(
                      'Matched ${state.fileHeaders.length} columns from your file to CRM Lead fields.',
                      style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Mapping List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.fileHeaders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, index) {
              final header = state.fileHeaders[index];
              final currentSelection = state.columnMapping[header] ?? 'SKIP';
              final sampleValue = state.dataRows.isNotEmpty && index < state.dataRows.first.length
                  ? state.dataRows.first[index]
                  : '';

              return AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            header,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.darkBlueText),
                          ),
                          if (sampleValue.isNotEmpty)
                            Text(
                              'Sample: "$sampleValue"',
                              style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: AppColors.secondaryText, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: DropdownButtonFormField<String>(
                        initialValue: availableCrmFields.containsKey(currentSelection) ? currentSelection : 'SKIP',
                        isExpanded: true,

                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),

                        items: availableCrmFields.entries.map((e) {
                          return DropdownMenuItem<String>(
                            value: e.key,
                            child: Text(
                              e.value,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: e.key != 'SKIP' ? FontWeight.w700 : FontWeight.w400,
                                color: e.key != 'SKIP' ? AppColors.darkBlueText : Colors.grey,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            context.read<LeadImportBloc>().add(
                                  UpdateColumnMappingEvent(fileHeader: header, crmFieldKey: val),
                                );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Actions Footer
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () => context.read<LeadImportBloc>().add(ResetImportEvent()),
                  child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => context.read<LeadImportBloc>().add(ValidateImportDataEvent()),
                  child: const Text('Preview Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== STEP 3: IMPORT PREVIEW & VALIDATION ====================
  Widget _buildPreviewStep(BuildContext context, ImportPreviewState state) {
    final parsed = state.parsedData;

    return Column(
      children: [
        // Summary Header Cards
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryBadge(
                      label: 'Total Found',
                      count: parsed.totalRows,
                      color: AppColors.darkBlueText,
                      icon: Icons.format_list_bulleted_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryBadge(
                      label: 'Valid ✓',
                      count: parsed.validCount,
                      color: AppColors.success,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryBadge(
                      label: 'Attention ⚠',
                      count: parsed.invalidCount,
                      color: Colors.red.shade700,
                      icon: Icons.error_outline_rounded,
                    ),
                  ),
                ],
              ),

              if (parsed.duplicateCount > 0) ...[
                const SizedBox(height: 12),

                // Duplicate Handling Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${parsed.duplicateCount} possible duplicate leads found.',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkBlueText),
                        ),
                      ),
                      DropdownButton<String>(
                        value: state.duplicateOption,
                        underline: const SizedBox.shrink(),
                        isDense: true,
                        items: const [
                          DropdownMenuItem(value: 'skip', child: Text('Skip duplicates', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'import_anyway', child: Text('Import as new leads', style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            context.read<LeadImportBloc>().add(SetDuplicateOptionEvent(val));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const Divider(height: 1),

        // Preview Rows List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: parsed.rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final row = parsed.rows[idx];
              return _buildRowPreviewTile(row);
            },
          ),
        ),

        // Actions Footer
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () => context.read<LeadImportBloc>().add(ResetImportEvent()),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: parsed.validCount == 0
                      ? null
                      : () => context.read<LeadImportBloc>().add(ExecuteImportEvent()),
                  child: Text(
                    'Import (${parsed.validCount} Leads)',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBadge({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildRowPreviewTile(RawImportRow row) {
    final lead = row.parsedLead;
    final isError = !row.isValid;
    final isDup = row.isDuplicate;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isError
                      ? Colors.red.shade100
                      : (isDup ? Colors.amber.shade100 : Colors.green.shade100),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Row ${row.rowIndex}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isError
                        ? Colors.red.shade800
                        : (isDup ? Colors.amber.shade900 : Colors.green.shade800),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lead?.contactName.isNotEmpty == true
                      ? lead!.contactName
                      : (row.rawData['Lead Name'] ?? row.rawData['Customer Name'] ?? 'Unnamed Row'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.darkBlueText),
                ),
              ),
              if (isError)
                const Icon(Icons.cancel_rounded, color: Colors.red, size: 20)
              else if (isDup)
                const Icon(Icons.warning_rounded, color: Colors.amber, size: 20)
              else
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
            ],
          ),
          if (lead != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (lead.phone.isNotEmpty) Text('${lead.phone} • ', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                if (lead.companyName.isNotEmpty) Text('${lead.companyName} • ', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                Text(lead.stage.name.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                const Spacer(),
                Text('₹${lead.estimatedValue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.success)),
              ],
            ),
          ],
          if (row.errors.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...row.errors.map(
              (err) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('⚠ $err', style: TextStyle(fontSize: 11, color: Colors.red.shade700, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
          if (row.duplicateReason != null) ...[
            const SizedBox(height: 4),
            Text('ℹ ${row.duplicateReason}', style: const TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }

  // ==================== STEP 4: IMPORT SUCCESS & SUMMARY ====================
  Widget _buildSuccessStep(BuildContext context, ImportSuccessState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, size: 48, color: AppColors.success),
          ),
          const SizedBox(height: 20),
          const Text(
            'Import Complete!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.darkBlueText),
          ),
          const SizedBox(height: 8),
          const Text(
            'Leads have been processed and added to your CRM database.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 24),

          // Summary Stats Card
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSummaryRow('Total Rows:', '${state.total}', AppColors.darkBlueText),
                const Divider(height: 16),
                _buildSummaryRow('Successfully Added:', '${state.successCount}', AppColors.success),
                const Divider(height: 16),
                _buildSummaryRow('Skipped:', '${state.skippedCount}', Colors.amber.shade800),
                const Divider(height: 16),
                _buildSummaryRow('Failed:', '${state.failedCount}', Colors.red.shade700),
              ],
            ),
          ),

          if (state.failedRows.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              icon: Icon(_showErrorDetails ? Icons.expand_less_rounded : Icons.expand_more_rounded),
              label: Text(_showErrorDetails ? 'Hide Error Details' : 'View Errors (${state.failedRows.length})'),
              onPressed: () {
                setState(() {
                  _showErrorDetails = !_showErrorDetails;
                });
              },
            ),
            if (_showErrorDetails)
              Container(
                height: 150,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: ListView.separated(
                  itemCount: state.failedRows.length,
                  separatorBuilder: (_, __) => const Divider(height: 8),
                  itemBuilder: (ctx, i) {
                    final f = state.failedRows[i];
                    return Text(
                      'Row ${f.rowIndex}: ${f.errors.join(", ")}',
                      style: TextStyle(fontSize: 11, color: Colors.red.shade800, fontWeight: FontWeight.w600),
                    );
                  },
                ),
              ),
          ],

          const Spacer(),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              // Refresh LeadBloc so new leads appear in pipeline
              context.read<LeadBloc>().add(const FetchLeadsEvent());
              context.pop();
            },
            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.darkBlueText)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)),
      ],
    );
  }
}
