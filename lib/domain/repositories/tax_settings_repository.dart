import '../entities/tax_settings_entity.dart';

abstract class TaxSettingsRepository {
  Future<TaxSettingsEntity> getTaxSettings();
  Future<void> saveTaxSettings(TaxSettingsEntity settings);
}
