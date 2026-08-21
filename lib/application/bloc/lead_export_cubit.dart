import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/lead_entity.dart';
import '../../domain/repositories/lead_repository.dart';
import '../../infrastructure/services/lead_export_service.dart';

enum ExportScope { allLeads, filteredLeads }

abstract class LeadExportState extends Equatable {
  const LeadExportState();
  @override
  List<Object?> get props => [];
}

class LeadExportInitialState extends LeadExportState {
  final ExportFormat format;
  final ExportScope scope;
  final List<String> selectedFieldKeys;

  LeadExportInitialState({
    this.format = ExportFormat.excel,
    this.scope = ExportScope.allLeads,
    List<String>? selectedFieldKeys,
  }) : selectedFieldKeys = selectedFieldKeys ??
            LeadExportService.availableFields
                .where((f) => f.defaultSelected)
                .map((f) => f.key)
                .toList();

  LeadExportInitialState copyWith({
    ExportFormat? format,
    ExportScope? scope,
    List<String>? selectedFieldKeys,
  }) {
    return LeadExportInitialState(
      format: format ?? this.format,
      scope: scope ?? this.scope,
      selectedFieldKeys: selectedFieldKeys ?? this.selectedFieldKeys,
    );
  }

  @override
  List<Object?> get props => [format, scope, selectedFieldKeys];
}

class LeadExportingState extends LeadExportState {}

class LeadExportSuccessState extends LeadExportState {
  final String message;
  const LeadExportSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

class LeadExportErrorState extends LeadExportState {
  final String message;
  const LeadExportErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class LeadExportCubit extends Cubit<LeadExportState> {
  final LeadRepository leadRepository;
  final LeadExportService exportService;

  LeadExportCubit({
    required this.leadRepository,
    required this.exportService,
  }) : super(LeadExportInitialState());

  void setFormat(ExportFormat format) {
    if (state is LeadExportInitialState) {
      emit((state as LeadExportInitialState).copyWith(format: format));
    }
  }

  void setScope(ExportScope scope) {
    if (state is LeadExportInitialState) {
      emit((state as LeadExportInitialState).copyWith(scope: scope));
    }
  }

  void toggleField(String fieldKey) {
    if (state is LeadExportInitialState) {
      final cur = state as LeadExportInitialState;
      final newFields = List<String>.from(cur.selectedFieldKeys);
      if (newFields.contains(fieldKey)) {
        newFields.remove(fieldKey);
      } else {
        newFields.add(fieldKey);
      }
      emit(cur.copyWith(selectedFieldKeys: newFields));
    }
  }

  void selectAllFields() {
    if (state is LeadExportInitialState) {
      final cur = state as LeadExportInitialState;
      final allKeys = LeadExportService.availableFields.map((f) => f.key).toList();
      emit(cur.copyWith(selectedFieldKeys: allKeys));
    }
  }

  void deselectAllFields() {
    if (state is LeadExportInitialState) {
      final cur = state as LeadExportInitialState;
      emit(cur.copyWith(selectedFieldKeys: []));
    }
  }

  Future<void> executeExport({
    required List<LeadEntity> allLeads,
    required List<LeadEntity> filteredLeads,
    required String filterSummary,
  }) async {
    if (state is! LeadExportInitialState) return;
    final config = state as LeadExportInitialState;

    if (config.selectedFieldKeys.isEmpty) {
      emit(const LeadExportErrorState('Please select at least one field to export.'));
      emit(config);
      return;
    }

    final targetLeads = config.scope == ExportScope.allLeads ? allLeads : filteredLeads;

    if (targetLeads.isEmpty) {
      emit(const LeadExportErrorState('No leads available to export.'));
      emit(config);
      return;
    }

    emit(LeadExportingState());

    try {
      if (config.format == ExportFormat.excel) {
        await exportService.exportToExcel(
          leads: targetLeads,
          selectedFieldKeys: config.selectedFieldKeys,
          filterSummary: config.scope == ExportScope.allLeads ? 'All Leads' : filterSummary,
        );
      } else {
        await exportService.exportToPdf(
          leads: targetLeads,
          selectedFieldKeys: config.selectedFieldKeys,
          filterSummary: config.scope == ExportScope.allLeads ? 'All Leads' : filterSummary,
        );
      }

      emit(LeadExportSuccessState('Exported ${targetLeads.length} leads successfully.'));
      emit(config);
    } catch (e) {
      emit(LeadExportErrorState('Export failed: $e'));
      emit(config);
    }
  }
}
