import 'dart:convert';

import 'package:drift/drift.dart';

import '../domain/search_text.dart';
import '../domain/taco_value.dart';
import 'app_database.dart';
import 'tables.dart';

const tacoAssetPath = 'assets/data/taco.jsonl';
const measuresAssetPath = 'assets/data/measures.jsonl';

const _tacoAssetKey = 'taco';
const _measuresAssetKey = 'measures';

String tacoFoodId(int number) => 'taco:$number';

/// Versão de um asset derivada do próprio conteúdo (FNV-1a de 64 bits).
///
/// Como a versão muda sempre que o arquivo muda, não há número para lembrar
/// de atualizar à mão.
String contentVersion(String content) {
  var hash = 0xcbf29ce484222325;
  for (final unit in utf8.encode(content)) {
    hash ^= unit;
    hash *= 0x100000001b3;
  }
  return hash.toRadixString(16);
}

Iterable<Map<String, dynamic>> _lines(String content) => const LineSplitter()
    .convert(content)
    .where((line) => line.trim().isNotEmpty)
    .map((line) => jsonDecode(line) as Map<String, dynamic>);

/// Sincroniza os assets de dados com o banco.
///
/// Cada sincronização é uma transação que insere o que é novo, atualiza o que
/// mudou e desativa o que saiu do asset. Rodar de novo com o mesmo conteúdo
/// não faz nada.
class AssetImporter {
  AssetImporter(this._db);

  final AppDatabase _db;

  Future<String?> _importedVersion(String asset) async {
    final row = await (_db.select(
      _db.assetVersions,
    )..where((t) => t.asset.equals(asset))).getSingleOrNull();
    return row?.version;
  }

  Future<void> _recordVersion(String asset, String version, int count) => _db
      .into(_db.assetVersions)
      .insertOnConflictUpdate(
        AssetVersionsCompanion.insert(
          asset: asset,
          version: version,
          itemCount: count,
          importedAt: DateTime.now(),
        ),
      );

  /// Importa a TACO. Devolve true se o banco foi alterado.
  Future<bool> syncTaco(String content) async {
    final version = contentVersion(content);
    if (await _importedVersion(_tacoAssetKey) == version) return false;

    final foods = _lines(content).map(_tacoFood).toList();
    final ids = foods.map((food) => food.id.value).toList();
    await _db.transaction(() async {
      await _db.batch(
        (batch) => batch.insertAllOnConflictUpdate(_db.foods, foods),
      );
      await (_db.update(_db.foods)..where(
            (t) => t.source.equalsValue(FoodSource.taco) & t.id.isNotIn(ids),
          ))
          .write(const FoodsCompanion(isActive: Value(false)));
      await _recordVersion(_tacoAssetKey, version, foods.length);
    });
    return true;
  }

  FoodsCompanion _tacoFood(Map<String, dynamic> json) {
    final name = json['name'] as String;
    double? numeric(String key) => TacoValue.fromRaw(json[key]).numeric;
    final nutrients = Map<String, dynamic>.of(json)
      ..remove('n')
      ..remove('name')
      ..remove('category');
    return FoodsCompanion.insert(
      id: tacoFoodId(json['n'] as int),
      source: FoodSource.taco,
      tacoNumber: Value(json['n'] as int),
      name: name,
      searchText: normalizeSearchText(name),
      category: Value(json['category'] as String?),
      kcal: Value(numeric('energy_kcal')),
      protein: Value(numeric('protein_g')),
      carb: Value(numeric('carb_g')),
      fat: Value(numeric('lipid_g')),
      fiber: Value(numeric('fiber_g')),
      sodium: Value(numeric('sodium_mg')),
      nutrientsJson: Value(jsonEncode(nutrients)),
      isActive: const Value(true),
    );
  }

  /// Importa as medidas caseiras do sistema. Devolve true se o banco foi
  /// alterado.
  ///
  /// Cada linha precisa citar a fonte da conversão. Uma linha sem fonte, ou
  /// que aponte para um alimento inexistente, invalida o asset inteiro.
  Future<bool> syncMeasures(String content) async {
    final version = contentVersion(content);
    if (await _importedVersion(_measuresAssetKey) == version) return false;

    final measures = <MeasuresCompanion>[];
    var order = 0;
    for (final json in _lines(content)) {
      final label = (json['label'] as String).trim();
      final reference = (json['ref'] as String? ?? '').trim();
      final grams = (json['grams'] as num).toDouble();
      if (label.isEmpty || reference.isEmpty || grams <= 0) {
        throw FormatException(
          'Medida caseira sem rótulo, fonte ou gramas',
          json,
        );
      }
      final foodId = tacoFoodId(json['food'] as int);
      final slug = normalizeSearchText(label).replaceAll(' ', '-');
      measures.add(
        MeasuresCompanion.insert(
          id: 'sys:$foodId:$slug',
          foodId: foodId,
          source: MeasureSource.system,
          label: label,
          grams: grams,
          reference: Value(reference),
          sortOrder: Value(order++),
          isActive: const Value(true),
        ),
      );
    }

    final ids = measures.map((measure) => measure.id.value).toList();
    await _db.transaction(() async {
      await _db.batch(
        (batch) => batch.insertAllOnConflictUpdate(_db.measures, measures),
      );
      await (_db.update(_db.measures)..where(
            (t) =>
                t.source.equalsValue(MeasureSource.system) & t.id.isNotIn(ids),
          ))
          .write(const MeasuresCompanion(isActive: Value(false)));
      await _recordVersion(_measuresAssetKey, version, measures.length);
    });
    return true;
  }

  /// Sincroniza todos os assets, lendo cada um com [load].
  Future<void> syncAll(Future<String> Function(String path) load) async {
    await syncTaco(await load(tacoAssetPath));
    await syncMeasures(await load(measuresAssetPath));
  }
}
