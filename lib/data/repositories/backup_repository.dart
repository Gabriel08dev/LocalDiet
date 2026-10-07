import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

const backupFormat = 'localdiet-backup';
const backupFormatVersion = 1;

/// O arquivo não é um backup do LocalDiet que esta versão consiga ler.
class BackupFormatException implements Exception {
  const BackupFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// O que um arquivo de backup contém, para o usuário conferir antes de
/// substituir os dados atuais.
class BackupSummary {
  const BackupSummary({
    required this.exportedAt,
    required this.hasProfile,
    required this.diaryItems,
    required this.diaryDays,
    required this.planItems,
    required this.bodyMeasurements,
    required this.userFoods,
    required this.userMeasures,
    required this.favorites,
  });

  final DateTime? exportedAt;
  final bool hasProfile;
  final int diaryItems;
  final int diaryDays;
  final int planItems;
  final int bodyMeasurements;
  final int userFoods;
  final int userMeasures;
  final int favorites;
}

class _ParsedBackup {
  _ParsedBackup({
    required this.exportedAt,
    required this.profile,
    required this.bodyMeasurements,
    required this.userFoods,
    required this.userMeasures,
    required this.diaryItems,
    required this.planItems,
    required this.favorites,
    required this.settings,
  });

  final DateTime? exportedAt;
  final ProfileRow? profile;
  final List<BodyMeasurementRow> bodyMeasurements;
  final List<FoodRow> userFoods;
  final List<MeasureRow> userMeasures;
  final List<DiaryItemRow> diaryItems;
  final List<PlanItemRow> planItems;
  final List<FavoriteRow> favorites;
  final List<SettingRow> settings;
}

/// Exporta e importa os dados do usuário em um único arquivo JSON.
///
/// O arquivo traz perfil, medições, Diário (com snapshots), Plano, alimentos
/// e medidas do usuário, favoritos e preferências. A TACO e as medidas do
/// sistema não entram: são recriadas a partir dos assets do app.
class BackupRepository {
  BackupRepository(this._db);

  final AppDatabase _db;

  Future<String> export() async {
    final profile = await _db.select(_db.profiles).getSingleOrNull();
    final userFoods = await (_db.select(
      _db.foods,
    )..where((t) => t.source.equalsValue(FoodSource.user))).get();
    final userMeasures = await (_db.select(
      _db.measures,
    )..where((t) => t.source.equalsValue(MeasureSource.user))).get();
    List<Map<String, dynamic>> all<T extends DataClass>(List<T> rows) =>
        rows.map((row) => row.toJson()).toList();

    return jsonEncode({
      'format': backupFormat,
      'formatVersion': backupFormatVersion,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'profile': profile?.toJson(),
      'bodyMeasurements': all(await _db.select(_db.bodyMeasurements).get()),
      'userFoods': all(userFoods),
      'userMeasures': all(userMeasures),
      'diaryItems': all(await _db.select(_db.diaryItems).get()),
      'planItems': all(await _db.select(_db.planItems).get()),
      'favorites': all(await _db.select(_db.favorites).get()),
      'settings': all(await _db.select(_db.settings).get()),
    });
  }

  _ParsedBackup _parse(String content) {
    try {
      final json = jsonDecode(content);
      if (json is! Map<String, dynamic> || json['format'] != backupFormat) {
        throw const BackupFormatException(
          'Este arquivo não é um backup do LocalDiet.',
        );
      }
      final formatVersion = json['formatVersion'];
      final schemaVersion = json['schemaVersion'];
      if (formatVersion is! int ||
          schemaVersion is! int ||
          formatVersion > backupFormatVersion ||
          schemaVersion > _db.schemaVersion) {
        throw const BackupFormatException(
          'Este backup foi criado por uma versão mais nova do app.',
        );
      }

      List<T> rows<T>(String key, T Function(Map<String, dynamic>) fromJson) =>
          (json[key] as List)
              .map((row) => fromJson(row as Map<String, dynamic>))
              .toList();

      final userFoods = rows('userFoods', FoodRow.fromJson);
      final userMeasures = rows('userMeasures', MeasureRow.fromJson);
      if (userFoods.any((food) => food.source != FoodSource.user) ||
          userMeasures.any((m) => m.source != MeasureSource.user)) {
        throw const BackupFormatException('O backup está corrompido.');
      }
      final profile = json['profile'];
      return _ParsedBackup(
        exportedAt: DateTime.tryParse(json['exportedAt'] as String? ?? ''),
        profile: profile == null
            ? null
            : ProfileRow.fromJson(profile as Map<String, dynamic>),
        bodyMeasurements: rows('bodyMeasurements', BodyMeasurementRow.fromJson),
        userFoods: userFoods,
        userMeasures: userMeasures,
        diaryItems: rows('diaryItems', DiaryItemRow.fromJson),
        planItems: rows('planItems', PlanItemRow.fromJson),
        favorites: rows('favorites', FavoriteRow.fromJson),
        settings: rows('settings', SettingRow.fromJson),
      );
    } on BackupFormatException {
      rethrow;
    } catch (_) {
      // JSON malformado, chave ausente ou tipo errado em qualquer linha.
      throw const BackupFormatException(
        'O arquivo está corrompido ou incompleto.',
      );
    }
  }

  /// Valida o arquivo e resume o conteúdo, sem alterar o banco.
  BackupSummary inspect(String content) {
    final backup = _parse(content);
    return BackupSummary(
      exportedAt: backup.exportedAt,
      hasProfile: backup.profile != null,
      diaryItems: backup.diaryItems.length,
      diaryDays: backup.diaryItems.map((item) => item.date).toSet().length,
      planItems: backup.planItems.length,
      bodyMeasurements: backup.bodyMeasurements.length,
      userFoods: backup.userFoods.length,
      userMeasures: backup.userMeasures.length,
      favorites: backup.favorites.length,
    );
  }

  /// Substitui todos os dados do usuário pelo conteúdo do backup.
  ///
  /// O arquivo é validado por inteiro antes de qualquer escrita, e a
  /// substituição é uma transação: em caso de erro, nada muda.
  Future<void> restore(String content) async {
    final backup = _parse(content);
    await _db.transaction(() async {
      await _db.delete(_db.favorites).go();
      await _db.delete(_db.planItems).go();
      await _db.delete(_db.diaryItems).go();
      await _db.delete(_db.bodyMeasurements).go();
      await _db.delete(_db.profiles).go();
      await _db.delete(_db.settings).go();
      await (_db.delete(
        _db.measures,
      )..where((t) => t.source.equalsValue(MeasureSource.user))).go();
      await (_db.delete(
        _db.foods,
      )..where((t) => t.source.equalsValue(FoodSource.user))).go();

      await _db.batch((batch) {
        batch.insertAll(_db.foods, backup.userFoods);
        batch.insertAll(_db.measures, backup.userMeasures);
        if (backup.profile != null) batch.insert(_db.profiles, backup.profile!);
        batch.insertAll(_db.bodyMeasurements, backup.bodyMeasurements);
        batch.insertAll(_db.diaryItems, backup.diaryItems);
        batch.insertAll(_db.planItems, backup.planItems);
        batch.insertAll(_db.favorites, backup.favorites);
        batch.insertAll(_db.settings, backup.settings);
      });
    });
  }
}
