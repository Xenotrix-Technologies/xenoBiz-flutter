import '../../domain/entities/tax_settings_entity.dart';
import '../../domain/repositories/tax_settings_repository.dart';
import '../storage/hive_service.dart';

class TaxSettingsRepositoryImpl implements TaxSettingsRepository {
  final HiveService hiveService;
  static const String _key = 'tax_settings';

  TaxSettingsRepositoryImpl({required this.hiveService});

  @override
  Future<TaxSettingsEntity> getTaxSettings() async {
    final box = hiveService.getBox(HiveService.boxBusiness);
    final data = box.get(_key);
    if (data is Map) {
      return TaxSettingsEntity.fromMap(data);
    }
    // Return default TaxSettingsEntity if not previously saved
    return const TaxSettingsEntity();
  }

  @override
  Future<void> saveTaxSettings(TaxSettingsEntity settings) async {
    final box = hiveService.getBox(HiveService.boxBusiness);
    await box.put(_key, settings.toMap());
  }
}
