import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:localdiet/data/app_database.dart';
import 'package:localdiet/data/asset_importer.dart';
import 'package:localdiet/data/repositories/food_repository.dart';
import 'package:localdiet/data/repositories/measure_repository.dart';
import 'package:localdiet/data/tables.dart';
import 'package:localdiet/domain/nutrients.dart';

import 'support.dart';

void main() {
  late AppDatabase db;

  tearDown(() => db.close());

  Future<int> count(String table) async {
    final row = await db
        .customSelect('SELECT COUNT(*) AS c FROM $table')
        .getSingle();
    return row.read<int>('c');
  }

  group('importação da TACO', () {
    setUp(() => db = memoryDatabase());

    test('o asset traz os 597 alimentos da 4ª edição', () async {
      expect(await AssetImporter(db).syncTaco(tacoAsset()), isTrue);
      expect(await count('foods'), 597);
      expect(await count('food_search'), 597);
      final numbers = await db
          .customSelect('SELECT taco_number AS n FROM foods ORDER BY n')
          .map((row) => row.read<int>('n'))
          .get();
      expect(numbers, List.generate(597, (index) => index + 1));
    });

    test('arroz integral cozido: 252 g dão 312,5 kcal', () async {
      await AssetImporter(db).syncTaco(tacoAsset());
      final rice = (await FoodRepository(db).byId(riceId))!;
      expect(rice.name, 'Arroz, integral, cozido');
      expect(rice.kcal, 124);
      expect(rice.per100.forGrams(252).kcal, closeTo(312.5, 0.05));
      expect(rice.per100.forGrams(252).protein, closeTo(6.55, 0.01));
    });

    test('reimportar o mesmo conteúdo não altera nem duplica nada', () async {
      final importer = AssetImporter(db);
      await importer.syncTaco(tacoAsset());
      expect(await importer.syncTaco(tacoAsset()), isFalse);
      expect(await count('foods'), 597);
      expect(await count('food_search'), 597);
      expect(await count('asset_versions'), 1);
    });

    test('traço, NA e reavaliação continuam distintos no banco', () async {
      await AssetImporter(db).syncTaco(tacoAsset());
      final rice = (await FoodRepository(db).byId(riceId))!;
      final raw = jsonDecode(rice.nutrientsJson!) as Map<String, dynamic>;
      expect(raw['cholesterol_mg'], 'NA');
      expect(raw['riboflavin_mg'], 'Tr');
      expect(raw['vitamin_c_mg'], isNull);
      expect(raw['energy_kcal'], 124);

      // Fibra "NA" no ovo frito: sem número no banco, zero nas somas.
      final egg = (await FoodRepository(db).byId('taco:490'))!;
      expect(egg.name, 'Ovo, de galinha, inteiro, frito');
      expect(egg.fiber, isNull);
      expect(egg.per100.fiber, 0);

      final underReview = await db
          .customSelect("SELECT COUNT(*) AS c FROM foods WHERE kcal IS NULL")
          .getSingle();
      expect(underReview.read<int>('c'), 6);
    });

    test(
      'nova versão atualiza valores, insere novos e desativa os que saíram',
      () async {
        final importer = AssetImporter(db);
        await importer.syncTaco(
          [
            tacoLine(1, 'Arroz, cozido'),
            tacoLine(2, 'Feijão, cozido'),
          ].join('\n'),
        );
        final changed = await importer.syncTaco(
          [
            tacoLine(1, 'Arroz, cozido', kcal: 130),
            tacoLine(3, 'Batata, cozida'),
          ].join('\n'),
        );
        expect(changed, isTrue);

        final foods = FoodRepository(db);
        expect((await foods.byId('taco:1'))!.kcal, 130);
        expect((await foods.byId('taco:3'))!.isActive, isTrue);
        final removed = (await foods.byId('taco:2'))!;
        expect(removed.isActive, isFalse, reason: 'desativado, não apagado');
        expect(await foods.search('feijao'), isEmpty);
        expect(await count('foods'), 3);
      },
    );

    test('alimento que volta ao asset é reativado', () async {
      final importer = AssetImporter(db);
      final both = [tacoLine(1, 'Arroz'), tacoLine(2, 'Feijão')].join('\n');
      await importer.syncTaco(both);
      await importer.syncTaco(tacoLine(1, 'Arroz'));
      await importer.syncTaco(both);
      expect((await FoodRepository(db).byId('taco:2'))!.isActive, isTrue);
      expect(await FoodRepository(db).search('feijao'), hasLength(1));
    });

    test('erro no meio da importação não deixa o banco pela metade', () async {
      final importer = AssetImporter(db);
      await importer.syncTaco(tacoLine(1, 'Arroz'));
      final broken = [tacoLine(1, 'Arroz', kcal: 999), '{"n":2}'].join('\n');
      await expectLater(importer.syncTaco(broken), throwsA(anything));
      expect((await FoodRepository(db).byId('taco:1'))!.kcal, 100);
      expect(await count('foods'), 1);
    });
  });

  group('medidas caseiras do sistema', () {
    setUp(() async {
      db = memoryDatabase();
      await AssetImporter(db).syncTaco(
        [tacoLine(488, 'Ovo, cozido'), tacoLine(1, 'Arroz, cozido')].join('\n'),
      );
    });

    const egg =
        '{"food":488,"label":"unidade","grams":50,"ref":"Fonte X, p. 10"}';
    const spoon =
        '{"food":1,"label":"colher de sopa","grams":25,"ref":"Fonte X, p. 12"}';

    test('importa com a fonte e de forma idempotente', () async {
      final importer = AssetImporter(db);
      expect(await importer.syncMeasures('$egg\n$spoon'), isTrue);
      expect(await importer.syncMeasures('$egg\n$spoon'), isFalse);
      final measures = await MeasureRepository(db).forFood('taco:488');
      expect(measures.single.label, 'unidade');
      expect(measures.single.grams, 50);
      expect(measures.single.reference, 'Fonte X, p. 10');
      expect(measures.single.source, MeasureSource.system);
    });

    test('medida que sai do asset é desativada', () async {
      final importer = AssetImporter(db);
      await importer.syncMeasures('$egg\n$spoon');
      await importer.syncMeasures(egg);
      expect(await MeasureRepository(db).forFood('taco:1'), isEmpty);
      expect(await count('measures'), 2, reason: 'desativada, não apagada');
    });

    test('medida sem fonte invalida o asset inteiro', () async {
      final importer = AssetImporter(db);
      const noSource = '{"food":1,"label":"concha","grams":80,"ref":""}';
      await expectLater(
        importer.syncMeasures('$egg\n$noSource'),
        throwsFormatException,
      );
      expect(await count('measures'), 0);
    });

    test('asset vazio é válido e não cria medidas', () async {
      expect(await AssetImporter(db).syncMeasures(''), isTrue);
      expect(await count('measures'), 0);
    });

    test(
      'o asset do projeto traz as medidas do IBGE, todas com fonte',
      () async {
        await db.close();
        db = await databaseWithTaco();
        await AssetImporter(db).syncAll((path) async {
          return path == tacoAssetPath ? tacoAsset() : measuresAsset();
        });
        expect(await count('foods'), 597);
        expect(await count('measures'), 912);
        final foods = await db
            .customSelect('SELECT COUNT(DISTINCT food_id) AS c FROM measures')
            .getSingle();
        expect(foods.read<int>('c'), 225);
        final unsourced = await db
            .customSelect(
              "SELECT COUNT(*) AS c FROM measures WHERE reference IS NULL OR "
              "reference NOT LIKE 'IBGE, POF 2008-2009%p. % do PDF:%'",
            )
            .getSingle();
        expect(unsourced.read<int>('c'), 0);
        final invalid = await db
            .customSelect('SELECT COUNT(*) AS c FROM measures WHERE grams <= 0')
            .getSingle();
        expect(invalid.read<int>('c'), 0);
      },
    );

    test('medidas de alimentos do dia a dia', () async {
      await db.close();
      db = await databaseWithAssets();
      Future<Map<String, double>> of(int tacoNumber) async => {
        for (final measure in await MeasureRepository(
          db,
        ).forFood(tacoFoodId(tacoNumber)))
          measure.label: measure.grams,
      };

      final rice = await of(3);
      expect(rice['colher de sopa'], 25);
      expect(rice['colher de servir'], 45);
      expect(rice['concha'], 100);
      expect(rice.keys.first, 'colher de sopa', reason: 'ordem do asset');

      expect((await of(561))['concha'], 140);
      expect(await of(53), {'unidade': 50});
      expect(await of(490), {'unidade': 50});
      expect((await of(182))['unidade'], 75);
      expect((await of(458))['copo médio'], 240);
      expect((await of(52))['fatia'], 25);

      // Formas cruas de alimentos que se comem cozidos ficam sem medida: as
      // quantidades do IBGE são do alimento pronto.
      expect(await of(4), isEmpty);
      expect(await of(562), isEmpty);
    });
  });

  group('busca de alimentos', () {
    setUpAll(() {});
    setUp(() async => db = await databaseWithTaco());

    Future<List<String>> names(String query) async =>
        (await FoodRepository(db).search(query))
            .map((food) => food.name)
            .toList();

    test('encontra com e sem acento, em qualquer caixa', () async {
      final plain = await names('pao frances');
      expect(plain, contains('Pão, trigo, francês'));
      expect(await names('PÃO FRANCÊS'), plain);
    });

    test('todos os termos precisam aparecer, em qualquer ordem', () async {
      final results = await names('integral arroz');
      expect(
        results,
        unorderedEquals(['Arroz, integral, cozido', 'Arroz, integral, cru']),
      );
    });

    test('busca por prefixo enquanto o usuário digita', () async {
      final results = await names('arr');
      expect(results, isNotEmpty);
      expect(results.take(6).every((name) => name.startsWith('Arroz')), isTrue);
    });

    test(
      'nomes que começam pelo termo vêm antes dos que só o contêm',
      () async {
        final results = await names('ovo');
        final firstOther = results.indexWhere(
          (name) => !name.startsWith('Ovo'),
        );
        final lastOvo = results.lastIndexWhere(
          (name) => name.startsWith('Ovo'),
        );
        expect(lastOvo, greaterThanOrEqualTo(0));
        if (firstOther != -1) expect(firstOther, greaterThan(lastOvo));
      },
    );

    test(
      'a versão pronta vem antes da crua, salvo se pedirem a crua',
      () async {
        final rice = await names('arroz integral');
        expect(rice, ['Arroz, integral, cozido', 'Arroz, integral, cru']);
        final beans = await names('feijao carioca');
        expect(beans.first, 'Feijão, carioca, cozido');
        final chicken = await names('frango peito sem pele');
        expect(chicken.last, 'Frango, peito, sem pele, cru');

        expect(
          (await names('arroz integral cru')).single,
          'Arroz, integral, cru',
        );
        // Fruta crua não tem versão pronta: não é rebaixada.
        expect(await names('banana prata'), ['Banana, prata, crua']);
      },
    );

    test('plural e gênero diferentes encontram o alimento', () async {
      expect(
        await names('ovos fritos'),
        contains('Ovo, de galinha, inteiro, frito'),
      );
      expect(await names('batatas fritas'), isNotEmpty);
    });

    test('nome regional encontra o termo da TACO', () async {
      final results = await names('macaxeira');
      expect(results, isNotEmpty);
      expect(results.every((name) => name.contains('andioca')), isTrue);
      expect(await names('mussarela'), contains('Queijo, mozarela'));
    });

    test(
      'consulta vazia, só com símbolos ou sem resultado devolve lista vazia',
      () async {
        expect(await names(''), isEmpty);
        expect(await names('"* ( ) -'), isEmpty);
        expect(await names('xyzxyz'), isEmpty);
      },
    );

    test('respeita o limite de resultados', () async {
      expect(await FoodRepository(db).search('ca', limit: 5), hasLength(5));
    });
  });

  group('alimentos e medidas do usuário', () {
    setUp(() async => db = await databaseWithTaco());

    test(
      'alimento personalizado entra na busca e aparece antes da TACO',
      () async {
        final foods = FoodRepository(db);
        final id = await foods.saveUserFood(
          name: 'Whey protein baunilha',
          per100: sampleNutrients,
        );
        expect(id, startsWith('user:'));
        final found = (await foods.search('whey')).single;
        expect(found.source, FoodSource.user);
        expect(found.per100, sampleNutrients);

        await foods.saveUserFood(
          name: 'Arroz da casa',
          per100: sampleNutrients,
        );
        expect((await foods.search('arroz')).first.name, 'Arroz da casa');
      },
    );

    test('renomear atualiza a busca', () async {
      final foods = FoodRepository(db);
      final id = await foods.saveUserFood(
        name: 'Zzbarra X',
        per100: sampleNutrients,
      );
      await foods.saveUserFood(
        id: id,
        name: 'Granola Y',
        per100: sampleNutrients,
      );
      expect(await foods.search('zzbarra x'), isEmpty);
      expect((await foods.search('granola y')).single.id, id);
      expect(await foods.watchUserFoods().first, hasLength(1));
    });

    test('desativar tira da busca sem apagar', () async {
      final foods = FoodRepository(db);
      final id = await foods.saveUserFood(
        name: 'Zzbarra X',
        per100: sampleNutrients,
      );
      await foods.deactivateUserFood(id);
      expect(await foods.search('zzbarra'), isEmpty);
      expect((await foods.byId(id))!.isActive, isFalse);
      expect(await foods.watchUserFoods().first, isEmpty);
    });

    test('alimento da TACO não pode ser desativado pelo usuário', () async {
      await FoodRepository(db).deactivateUserFood(riceId);
      expect((await FoodRepository(db).byId(riceId))!.isActive, isTrue);
    });

    test('nome em branco é recusado', () async {
      expect(
        () =>
            FoodRepository(db).saveUserFood(name: '  ', per100: Nutrients.zero),
        throwsArgumentError,
      );
    });

    test('medida do usuário é salva, listada e pode ser desativada', () async {
      final measures = MeasureRepository(db);
      final id = await measures.addUserMeasure(
        foodId: riceId,
        label: 'minha concha',
        grams: 90,
      );
      final listed = (await measures.forFood(riceId)).single;
      expect(listed.label, 'minha concha');
      expect(listed.grams, 90);
      expect(listed.source, MeasureSource.user);

      await measures.deactivateUserMeasure(id);
      expect(await measures.forFood(riceId), isEmpty);
    });

    test('medida com gramas inválidas ou sem rótulo é recusada', () async {
      final measures = MeasureRepository(db);
      expect(
        () => measures.addUserMeasure(foodId: riceId, label: 'x', grams: 0),
        throwsArgumentError,
      );
      expect(
        () => measures.addUserMeasure(foodId: riceId, label: ' ', grams: 10),
        throwsArgumentError,
      );
    });

    test('favoritar e desfavoritar', () async {
      final foods = FoodRepository(db);
      await foods.setFavorite(riceId, favorite: true);
      await foods.setFavorite(riceId, favorite: true);
      expect((await foods.watchFavorites().first).single.id, riceId);
      expect(await foods.watchIsFavorite(riceId).first, isTrue);
      await foods.setFavorite(riceId, favorite: false);
      expect(await foods.watchFavorites().first, isEmpty);
    });
  });
}
