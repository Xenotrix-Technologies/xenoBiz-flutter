import 'dart:convert';
import '../../domain/entities/tax_settings_entity.dart';
import '../../domain/repositories/tax_settings_repository.dart';
import '../database/app_database.dart';

class TaxSettingsRepositoryImpl implements TaxSettingsRepository {
  final AppDatabase db;
  static const String _key = 'tax_settings';

  TaxSettingsRepositoryImpl({required this.db});

  @override
  Future<TaxSettingsEntity> getTaxSettings() async {
    final raw = await db.getKeyValue(_key);
    if (raw != null) {
      try {
        final data = jsonDecode(raw);
        if (data is Map) {
          return TaxSettingsEntity.fromMap(Map<String, dynamic>.from(data));
        }
      } catch (_) {}
    }
    return const TaxSettingsEntity();
  }

  @override
  Future<void> saveTaxSettings(TaxSettingsEntity settings) async {
    await db.putKeyValue(_key, jsonEncode(settings.toMap()));
  }
}
