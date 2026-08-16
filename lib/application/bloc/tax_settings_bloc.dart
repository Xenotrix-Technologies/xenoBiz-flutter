import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/tax_settings_entity.dart';
import '../../domain/repositories/tax_settings_repository.dart';

// --- Events ---
abstract class TaxSettingsEvent extends Equatable {
  const TaxSettingsEvent();

  @override
  List<Object?> get props => [];
}

class FetchTaxSettingsEvent extends TaxSettingsEvent {
  const FetchTaxSettingsEvent();
}

class UpdateTaxSettingsEvent extends TaxSettingsEvent {
  final TaxSettingsEntity settings;
  const UpdateTaxSettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ToggleGstEnabledEvent extends TaxSettingsEvent {
  final bool isEnabled;
  const ToggleGstEnabledEvent(this.isEnabled);

  @override
  List<Object?> get props => [isEnabled];
}

// --- States ---
abstract class TaxSettingsState extends Equatable {
  const TaxSettingsState();

  @override
  List<Object?> get props => [];
}

class TaxSettingsInitialState extends TaxSettingsState {}

class TaxSettingsLoadingState extends TaxSettingsState {}

class TaxSettingsLoadedState extends TaxSettingsState {
  final TaxSettingsEntity settings;

  const TaxSettingsLoadedState(this.settings);

  @override
  List<Object?> get props => [settings];
}

class TaxSettingsErrorState extends TaxSettingsState {
  final String message;

  const TaxSettingsErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class TaxSettingsBloc extends Bloc<TaxSettingsEvent, TaxSettingsState> {
  final TaxSettingsRepository repository;

  TaxSettingsBloc({required this.repository})
      : super(TaxSettingsInitialState()) {
    on<FetchTaxSettingsEvent>(_onFetchTaxSettings);
    on<UpdateTaxSettingsEvent>(_onUpdateTaxSettings);
    on<ToggleGstEnabledEvent>(_onToggleGstEnabled);
  }

  Future<void> _onFetchTaxSettings(
    FetchTaxSettingsEvent event,
    Emitter<TaxSettingsState> emit,
  ) async {
    emit(TaxSettingsLoadingState());
    try {
      final settings = await repository.getTaxSettings();
      emit(TaxSettingsLoadedState(settings));
    } catch (e) {
      emit(TaxSettingsErrorState('Failed to load tax settings: $e'));
    }
  }

  Future<void> _onUpdateTaxSettings(
    UpdateTaxSettingsEvent event,
    Emitter<TaxSettingsState> emit,
  ) async {
    try {
      await repository.saveTaxSettings(event.settings);
      emit(TaxSettingsLoadedState(event.settings));
    } catch (e) {
      emit(TaxSettingsErrorState('Failed to update tax settings: $e'));
    }
  }

  Future<void> _onToggleGstEnabled(
    ToggleGstEnabledEvent event,
    Emitter<TaxSettingsState> emit,
  ) async {
    final currentState = state;
    TaxSettingsEntity currentSettings = const TaxSettingsEntity();
    if (currentState is TaxSettingsLoadedState) {
      currentSettings = currentState.settings;
    }
    final updated = currentSettings.copyWith(isGstEnabled: event.isEnabled);
    try {
      await repository.saveTaxSettings(updated);
      emit(TaxSettingsLoadedState(updated));
    } catch (e) {
      emit(TaxSettingsErrorState('Failed to toggle GST state: $e'));
    }
  }
}
