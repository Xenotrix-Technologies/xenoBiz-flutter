import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/bloc/lead_export_cubit.dart';
import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/lead_entity.dart';
import '../../../domain/repositories/lead_repository.dart';
import '../../../infrastructure/services/lead_export_service.dart';

class ExportLeadsModal extends StatelessWidget {
  final List<LeadEntity> allLeads;
  final List<LeadEntity> filteredLeads;
  final String filterSummary;

  const ExportLeadsModal({
    super.key,
    required this.allLeads,
    required this.filteredLeads,
    required this.filterSummary,
  });

  static void show({
    required BuildContext context,
    required List<LeadEntity> allLeads,
    required List<LeadEntity> filteredLeads,
    required String filterSummary,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BlocProvider<LeadExportCubit>(
            create: (_) => LeadExportCubit(
              leadRepository: getIt<LeadRepository>(),
              exportService: getIt<LeadExportService>(),
            ),
            child: ExportLeadsModal(
              allLeads: allLeads,
              filteredLeads: filteredLeads,
              filterSummary: filterSummary,
            ),
          ),
        );
      },

    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeadExportCubit, LeadExportState>(
      listener: (context, state) {
        if (state is LeadExportErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is LeadExportSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: BlocBuilder<LeadExportCubit, LeadExportState>(
              builder: (context, state) {
                if (state is LeadExportingState) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Generating export file...',
                          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.darkBlueText),
                        ),
                      ],
                    ),
                  );
                }

                final config = state is LeadExportInitialState ? state : LeadExportInitialState();

                final isAllSelected = config.selectedFieldKeys.length == LeadExportService.availableFields.length;

                return Column(
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Export Leads',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkBlueText,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 12),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          // 1. Export Format Selection
                          _buildSectionTitle('Export Format'),
                          Row(
                            children: [
                              Expanded(
                                child: _buildRadioTile<ExportFormat>(
                                  title: 'Excel (.xlsx)',
                                  subtitle: 'Spreadsheet table',
                                  value: ExportFormat.excel,
                                  groupValue: config.format,
                                  icon: Icons.table_chart_rounded,
                                  color: AppColors.success,
                                  onChanged: (val) {
                                    if (val != null) context.read<LeadExportCubit>().setFormat(val);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildRadioTile<ExportFormat>(
                                  title: 'PDF (.pdf)',
                                  subtitle: 'Printable report',
                                  value: ExportFormat.pdf,
                                  groupValue: config.format,
                                  icon: Icons.picture_as_pdf_rounded,
                                  color: Colors.red.shade600,
                                  onChanged: (val) {
                                    if (val != null) context.read<LeadExportCubit>().setFormat(val);
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 2. Export Scope Selection
                          _buildSectionTitle('Leads Scope'),
                          Material(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  RadioListTile<ExportScope>(
                                    dense: true,
                                    title: Text(
                                      'All Leads (${allLeads.length})',
                                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.darkBlueText),
                                    ),
                                    subtitle: const Text('Export full lead database', style: TextStyle(fontSize: 11)),
                                    value: ExportScope.allLeads,
                                    groupValue: config.scope,
                                    activeColor: AppColors.primaryBlue,
                                    onChanged: (val) {
                                      if (val != null) context.read<LeadExportCubit>().setScope(val);
                                    },
                                  ),
                                  const Divider(height: 1, indent: 16, endIndent: 16),
                                  RadioListTile<ExportScope>(
                                    dense: true,
                                    title: Text(
                                      'Current Filtered Leads (${filteredLeads.length})',
                                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.darkBlueText),
                                    ),
                                    subtitle: Text(
                                      filterSummary.isNotEmpty ? 'Filtered by: $filterSummary' : 'Currently active filters on pipeline',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    value: ExportScope.filteredLeads,
                                    groupValue: config.scope,
                                    activeColor: AppColors.primaryBlue,
                                    onChanged: (val) {
                                      if (val != null) context.read<LeadExportCubit>().setScope(val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),


                          const SizedBox(height: 20),

                          // 3. Information Fields Checkboxes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionTitle('Select Information Columns'),
                              TextButton.icon(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                                icon: Icon(
                                  isAllSelected ? Icons.deselect_rounded : Icons.select_all_rounded,
                                  size: 16,
                                  color: AppColors.primaryBlue,
                                ),
                                label: Text(
                                  isAllSelected ? 'Deselect All' : 'Select All',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
                                ),
                                onPressed: () {
                                  if (isAllSelected) {
                                    context.read<LeadExportCubit>().deselectAllFields();
                                  } else {
                                    context.read<LeadExportCubit>().selectAllFields();
                                  }
                                },
                              ),
                            ],
                          ),

                          Material(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: LeadExportService.availableFields.map((field) {
                                  final isSelected = config.selectedFieldKeys.contains(field.key);
                                  return CheckboxListTile(
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    title: Text(
                                      field.label,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        fontSize: 13,
                                        color: isSelected ? AppColors.darkBlueText : AppColors.secondaryText,
                                      ),
                                    ),
                                    value: isSelected,
                                    activeColor: AppColors.primaryBlue,
                                    onChanged: (_) {
                                      context.read<LeadExportCubit>().toggleField(field.key);
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),


                          const SizedBox(height: 24),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Export Button Action
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.file_upload_outlined),
                        label: Text(
                          'Export (${config.selectedFieldKeys.length} Columns)',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        onPressed: () {
                          context.read<LeadExportCubit>().executeExport(
                                allLeads: allLeads,
                                filteredLeads: filteredLeads,
                                filterSummary: filterSummary,
                              );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.secondaryText,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    required String subtitle,
    required T value,
    required T groupValue,
    required IconData icon,
    required Color color,
    required ValueChanged<T?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.08) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? color : AppColors.secondaryText, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? AppColors.darkBlueText : AppColors.secondaryText,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
