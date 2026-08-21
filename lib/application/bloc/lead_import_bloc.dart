import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../infrastructure/services/lead_import_service.dart';

// ==================== EVENTS ====================
abstract class LeadImportEvent extends Equatable {
  const LeadImportEvent();
  @override
  List<Object?> get props => [];
}

class SelectImportFileEvent extends LeadImportEvent {
  final PlatformFile file;
  const SelectImportFileEvent(this.file);

  @override
  List<Object?> get props => [file];
}

class UpdateColumnMappingEvent extends LeadImportEvent {
  final String fileHeader;
  final String crmFieldKey;

  const UpdateColumnMappingEvent({
    required this.fileHeader,
    required this.crmFieldKey,
  });

  @override
  List<Object?> get props => [fileHeader, crmFieldKey];
}

class ValidateImportDataEvent extends LeadImportEvent {}

class SetDuplicateOptionEvent extends LeadImportEvent {
  final String option; // 'skip', 'import_anyway'
  const SetDuplicateOptionEvent(this.option);

  @override
  List<Object?> get props => [option];
}

class ExecuteImportEvent extends LeadImportEvent {}

class ResetImportEvent extends LeadImportEvent {}

// ==================== STATES ====================
abstract class LeadImportState extends Equatable {
  const LeadImportState();
  @override
  List<Object?> get props => [];
}

class ImportInitialState extends LeadImportState {}

class ImportLoadingState extends LeadImportState {
  final String message;
  const ImportLoadingState(this.message);

  @override
  List<Object?> get props => [message];
}

class ImportMappingState extends LeadImportState {
  final PlatformFile file;
  final List<String> fileHeaders;
  final List<List<String>> dataRows;
  final Map<String, String> columnMapping; // File Header -> CRM Field Key

  const ImportMappingState({
    required this.file,
    required this.fileHeaders,
    required this.dataRows,
    required this.columnMapping,
  });

  ImportMappingState copyWith({
    Map<String, String>? columnMapping,
  }) {
    return ImportMappingState(
      file: file,
      fileHeaders: fileHeaders,
      dataRows: dataRows,
      columnMapping: columnMapping ?? this.columnMapping,
    );
  }

  @override
  List<Object?> get props => [file, fileHeaders, dataRows, columnMapping];
}

class ImportPreviewState extends LeadImportState {
  final PlatformFile file;
  final ParsedImportData parsedData;
  final Map<String, String> columnMapping;
  final String duplicateOption; // 'skip', 'import_anyway'

  const ImportPreviewState({
    required this.file,
    required this.parsedData,
    required this.columnMapping,
    this.duplicateOption = 'skip',
  });

  ImportPreviewState copyWith({
    ParsedImportData? parsedData,
    String? duplicateOption,
  }) {
    return ImportPreviewState(
      file: file,
      parsedData: parsedData ?? this.parsedData,
      columnMapping: columnMapping,
      duplicateOption: duplicateOption ?? this.duplicateOption,
    );
  }

  @override
  List<Object?> get props => [file, parsedData, columnMapping, duplicateOption];
}

class ImportSuccessState extends LeadImportState {
  final int total;
  final int successCount;
  final int skippedCount;
  final int failedCount;
  final List<RawImportRow> failedRows;

  const ImportSuccessState({
    required this.total,
    required this.successCount,
    required this.skippedCount,
    required this.failedCount,
    required this.failedRows,
  });

  @override
  List<Object?> get props => [
        total,
        successCount,
        skippedCount,
        failedCount,
        failedRows,
      ];
}

class ImportErrorState extends LeadImportState {
  final String message;
  const ImportErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================
class LeadImportBloc extends Bloc<LeadImportEvent, LeadImportState> {
  final LeadImportService importService;

  LeadImportBloc({required this.importService}) : super(ImportInitialState()) {
    on<SelectImportFileEvent>(_onSelectImportFile);
    on<UpdateColumnMappingEvent>(_onUpdateColumnMapping);
    on<ValidateImportDataEvent>(_onValidateImportData);
    on<SetDuplicateOptionEvent>(_onSetDuplicateOption);
    on<ExecuteImportEvent>(_onExecuteImport);
    on<ResetImportEvent>(_onResetImport);
  }

  Future<void> _onSelectImportFile(
    SelectImportFileEvent event,
    Emitter<LeadImportState> emit,
  ) async {
    emit(const ImportLoadingState('Reading & parsing file...'));
    try {
      final parsed = await importService.parseFile(event.file);
      final headers = parsed['headers'] as List<String>;
      final dataRows = parsed['rows'] as List<List<String>>;

      if (headers.isEmpty) {
        emit(const ImportErrorState('File contains no column headers.'));
        return;
      }

      final autoMapping = importService.autoMapColumns(headers);

      emit(ImportMappingState(
        file: event.file,
        fileHeaders: headers,
        dataRows: dataRows,
        columnMapping: autoMapping,
      ));
    } catch (e) {
      emit(ImportErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onUpdateColumnMapping(
    UpdateColumnMappingEvent event,
    Emitter<LeadImportState> emit,
  ) {
    if (state is ImportMappingState) {
      final cur = state as ImportMappingState;
      final updatedMap = Map<String, String>.from(cur.columnMapping);
      updatedMap[event.fileHeader] = event.crmFieldKey;
      emit(cur.copyWith(columnMapping: updatedMap));
    }
  }

  Future<void> _onValidateImportData(
    ValidateImportDataEvent event,
    Emitter<LeadImportState> emit,
  ) async {
    if (state is! ImportMappingState) return;
    final cur = state as ImportMappingState;

    emit(const ImportLoadingState('Validating rows & checking duplicates...'));
    try {
      final parsedData = await importService.validateAndParseRows(
        fileHeaders: cur.fileHeaders,
        dataRows: cur.dataRows,
        columnMapping: cur.columnMapping,
      );

      emit(ImportPreviewState(
        file: cur.file,
        parsedData: parsedData,
        columnMapping: cur.columnMapping,
        duplicateOption: 'skip',
      ));
    } catch (e) {
      emit(ImportErrorState('Validation failed: $e'));
    }
  }

  void _onSetDuplicateOption(
    SetDuplicateOptionEvent event,
    Emitter<LeadImportState> emit,
  ) {
    if (state is ImportPreviewState) {
      final cur = state as ImportPreviewState;
      emit(cur.copyWith(duplicateOption: event.option));
    }
  }

  Future<void> _onExecuteImport(
    ExecuteImportEvent event,
    Emitter<LeadImportState> emit,
  ) async {
    if (state is! ImportPreviewState) return;
    final cur = state as ImportPreviewState;

    emit(const ImportLoadingState('Importing leads into CRM database...'));
    try {
      final result = await importService.executeBulkImport(
        rows: cur.parsedData.rows,
        duplicateOption: cur.duplicateOption,
      );

      final failedRows = cur.parsedData.rows.where((r) => !r.isValid).toList();

      emit(ImportSuccessState(
        total: result['total'] ?? 0,
        successCount: result['success'] ?? 0,
        skippedCount: result['skipped'] ?? 0,
        failedCount: result['failed'] ?? 0,
        failedRows: failedRows,
      ));
    } catch (e) {
      emit(ImportErrorState('Import execution failed: $e'));
    }
  }

  void _onResetImport(
    ResetImportEvent event,
    Emitter<LeadImportState> emit,
  ) {
    emit(ImportInitialState());
  }
}
