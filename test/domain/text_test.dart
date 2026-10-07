import 'package:flutter_test/flutter_test.dart';
import 'package:localdiet/domain/meal_text_parser.dart';
import 'package:localdiet/domain/preparation.dart';
import 'package:localdiet/domain/search_text.dart';

void main() {
  group('normalização de busca', () {
    test('tira acentos, maiúsculas e pontuação', () {
      expect(normalizeSearchText('Pão, francês'), 'pao frances');
      expect(normalizeSearchText('  AÇÚCAR,  refinado '), 'acucar refinado');
      expect(
        normalizeSearchText('Ovo, cozido/10minutos'),
        'ovo cozido 10minutos',
      );
      expect(normalizeSearchText('Chá, erva-doce'), 'cha erva doce');
    });

    test('consulta vira termos em prefixo, todos obrigatórios', () {
      expect(buildFtsQuery('arroz integral'), '"arroz"* "integral"*');
      expect(buildFtsQuery('Pão'), '"pao"*');
    });

    test('palavras vazias e consulta sem termo', () {
      expect(buildFtsQuery('ovo de galinha'), '"ovo"* "galinh"*');
      expect(buildFtsQuery('   '), isNull);
      expect(buildFtsQuery('de'), isNull);
      expect(buildFtsQuery('"*'), isNull);
    });

    test('plural e gênero caem no mesmo prefixo', () {
      expect(buildFtsQuery('batatas fritas'), buildFtsQuery('batata frito'));
      expect(buildFtsQuery('ovos'), '"ovo"*');
      expect(buildFtsQuery('cozida'), '"cozid"*');
    });

    test('nome regional aceita também o termo da TACO', () {
      expect(buildFtsQuery('macaxeira'), '("macaxeir"* OR "mandioc"*)');
      expect(buildFtsQuery('mussarela'), '("mussarel"* OR "mozarel"*)');
    });

    test('prefixo do primeiro termo', () {
      expect(leadingSearchPrefix('Ovos fritos'), 'ovo');
      expect(leadingSearchPrefix('de'), isNull);
    });
  });

  group('preparo e óleo', () {
    test('detecta refogado, frito e grelhado em qualquer gênero e número', () {
      expect(Preparation.detect('couve refogada'), Preparation.sauteed);
      expect(Preparation.detect('batatas fritas'), Preparation.fried);
      expect(Preparation.detect('frango grelhado'), Preparation.grilled);
      expect(Preparation.detect('arroz cozido'), isNull);
    });

    test('sugere 5 g, 15 g e 2 g conforme o preparo', () {
      expect(
        suggestedOilGrams(Preparation.sauteed, 'Couve, manteiga, crua'),
        5,
      );
      expect(suggestedOilGrams(Preparation.fried, 'Batata, inglesa, crua'), 15);
      expect(suggestedOilGrams(Preparation.grilled, 'Frango, peito, cru'), 2);
    });

    test('não sugere óleo se o alimento já traz o preparo no nome', () {
      expect(
        suggestedOilGrams(Preparation.fried, 'Ovo, de galinha, inteiro, frito'),
        isNull,
      );
      expect(
        suggestedOilGrams(Preparation.fried, 'Batata, inglesa, frita'),
        isNull,
      );
      expect(
        suggestedOilGrams(
          Preparation.grilled,
          'Carne, bovina, patinho, grelhado',
        ),
        isNull,
      );
      expect(
        suggestedOilGrams(Preparation.sauteed, 'Couve, manteiga, refogada'),
        isNull,
      );
    });

    test('sem preparo não há sugestão', () {
      expect(suggestedOilGrams(null, 'Arroz, integral, cozido'), isNull);
    });
  });

  group('parser de refeição', () {
    test('quantidade em gramas vira gramatura', () {
      final item = parseMealText('150 g de arroz integral').single;
      expect(item.kind, QuantityKind.mass);
      expect(item.grams, 150);
      expect(item.foodText, 'arroz integral');
    });

    test('aceita unidade colada, quilo e decimal com vírgula ou ponto', () {
      expect(parseMealText('100g frango').single.grams, 100);
      expect(parseMealText('1,5 kg de batata').single.grams, 1500);
      expect(parseMealText('0.5 kg batata').single.grams, 500);
      expect(parseMealText('80 gramas de aveia').single.grams, 80);
    });

    test('medida caseira guarda quantidade e medida, sem inventar gramas', () {
      final item = parseMealText('2 colheres de sopa de feijão').single;
      expect(item.kind, QuantityKind.measure);
      expect(item.quantity, 2);
      expect(item.measure, 'colher de sopa');
      expect(item.grams, isNull);
      expect(item.foodText, 'feijao');
    });

    test('contagem sem medida é tratada como unidade', () {
      final item = parseMealText('2 ovos').single;
      expect(item.kind, QuantityKind.measure);
      expect(item.quantity, 2);
      expect(item.measure, 'unidade');
      expect(item.foodText, 'ovos');
    });

    test('números por extenso, meia e fração', () {
      expect(parseMealText('uma banana').single.quantity, 1);
      expect(parseMealText('meia xícara de leite').single.quantity, 0.5);
      expect(parseMealText('meia xícara de leite').single.measure, 'xicara');
      expect(parseMealText('1/2 abacate').single.quantity, 0.5);
      expect(parseMealText('1 e meia concha de feijão').single.quantity, 1.5);
    });

    test('volume não vira gramas', () {
      final item = parseMealText('200 ml de leite').single;
      expect(item.kind, QuantityKind.volume);
      expect(item.quantity, 200);
      expect(item.grams, isNull);
    });

    test('sem quantidade o item fica sem gramatura', () {
      final item = parseMealText('arroz').single;
      expect(item.kind, QuantityKind.unspecified);
      expect(item.quantity, isNull);
      expect(item.grams, isNull);
    });

    test(
      'separa itens por vírgula, "e", "com", "+", ponto e vírgula e linha',
      () {
        final items = parseMealText(
          '2 ovos fritos, 150 g de arroz e 1 concha de feijão\n'
          'pão com manteiga; café + 1 banana',
        );
        expect(items.map((item) => item.foodText), [
          'ovos fritos',
          'arroz',
          'feijao',
          'pao',
          'manteiga',
          'cafe',
          'banana',
        ]);
      },
    );

    test('vírgula decimal não separa itens', () {
      final items = parseMealText('1,5 xícara de arroz, 2 ovos');
      expect(items, hasLength(2));
      expect(items.first.quantity, 1.5);
    });

    test('guarda o preparo mencionado', () {
      expect(
        parseMealText('2 ovos fritos').single.preparation,
        Preparation.fried,
      );
      expect(
        parseMealText('100 g de frango grelhado').single.preparation,
        Preparation.grilled,
      );
      expect(parseMealText('arroz').single.preparation, isNull);
    });

    test('alimento que começa com letra de unidade não é confundido', () {
      final goiaba = parseMealText('2 goiabas').single;
      expect(goiaba.kind, QuantityKind.measure);
      expect(goiaba.foodText, 'goiabas');
      final laranja = parseMealText('1 laranja').single;
      expect(laranja.foodText, 'laranja');
    });

    test('texto vazio ou só com separadores não gera itens', () {
      expect(parseMealText(''), isEmpty);
      expect(parseMealText(' , ; \n'), isEmpty);
      expect(parseMealText('150 g'), isEmpty);
    });
  });
}
