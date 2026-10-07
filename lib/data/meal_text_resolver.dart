import '../domain/meal_text_parser.dart';
import '../domain/portion.dart';
import '../domain/preparation.dart';
import '../domain/search_text.dart';
import 'app_database.dart';
import 'repositories/food_repository.dart';
import 'repositories/measure_repository.dart';

/// Um item do texto livre com os alimentos candidatos da base.
///
/// É apenas uma proposta: o usuário escolhe o alimento, confere a gramatura e
/// confirma antes de qualquer coisa ser salva.
class ResolvedMealItem {
  ResolvedMealItem({
    required this.parsed,
    required this.candidates,
    this.food,
    this.portion,
  });

  final ParsedMealItem parsed;

  /// Alimentos que combinam com o texto, do mais provável ao menos.
  final List<FoodRow> candidates;

  /// O alimento proposto, ou null quando nada foi encontrado.
  FoodRow? food;

  /// A porção na medida em que foi dita ("2 fatias" fica como 2 × fatia), ou
  /// null quando o texto não permite determinar a gramatura.
  Portion? portion;

  double? get grams => portion?.grams;

  /// Óleo de preparo sugerido para o alimento proposto, em gramas.
  double? get oilGrams =>
      food == null ? null : suggestedOilGrams(parsed.preparation, food!.name);
}

/// A medida entendida quando o texto traz só a palavra genérica: "1 copo de
/// leite" é lido como copo médio, "2 colheres de arroz" como colher de sopa.
const _genericMeasures = {
  'colher': 'colher de sopa',
  'copo': 'copo medio',
  'xicara': 'xicara de cha',
  'prato': 'prato raso',
};

/// Liga o resultado do parser de texto aos alimentos e medidas da base.
class MealTextResolver {
  MealTextResolver(this._foods, this._measures);

  final FoodRepository _foods;
  final MeasureRepository _measures;

  Future<List<ResolvedMealItem>> resolve(String text) async {
    final items = <ResolvedMealItem>[];
    for (final parsed in parseMealText(text)) {
      final candidates = await _candidates(parsed);
      final food = candidates.firstOrNull;
      items.add(
        ResolvedMealItem(
          parsed: parsed,
          candidates: candidates,
          food: food,
          portion: food == null ? null : await portionFor(parsed, food),
        ),
      );
    }
    return items;
  }

  Future<List<FoodRow>> _candidates(ParsedMealItem parsed) async {
    final found = await _foods.search(parsed.foodText, limit: 6);
    final preparation = parsed.preparation;
    if (found.isNotEmpty || preparation == null) return found;
    // "bife frito" pode não existir com o preparo no nome; tenta sem ele.
    final withoutPreparation = parsed.foodText
        .split(' ')
        .where((token) => !token.startsWith(preparation.stem))
        .join(' ');
    return _foods.search(withoutPreparation, limit: 6);
  }

  /// A porção de [parsed] para o alimento [food].
  ///
  /// Massa vem direto do texto. Medida caseira só vira porção se o alimento
  /// tiver uma medida com esse nome; caso contrário devolve null, e é o
  /// usuário quem informa os gramas.
  Future<Portion?> portionFor(ParsedMealItem parsed, FoodRow food) async {
    switch (parsed.kind) {
      case QuantityKind.mass:
        return Portion.grams(parsed.grams!);
      case QuantityKind.measure:
        final wanted = parsed.measure!;
        final measures = await _measures.forFood(food.id);
        final byLabel = {
          for (final measure in measures)
            normalizeSearchText(measure.label): measure,
        };
        final measure =
            byLabel[wanted] ??
            byLabel[_genericMeasures[wanted]] ??
            byLabel.entries
                .where((entry) => entry.key.startsWith('$wanted '))
                .firstOrNull
                ?.value;
        if (measure == null) return null;
        return Portion(
          measureLabel: measure.label,
          measureGrams: measure.grams,
          quantity: parsed.quantity!,
        );
      case QuantityKind.volume:
      case QuantityKind.unspecified:
        return null;
    }
  }

  Future<double?> gramsFor(ParsedMealItem parsed, FoodRow food) async =>
      (await portionFor(parsed, food))?.grams;

  /// O alimento usado na sugestão de óleo de preparo.
  Future<FoodRow?> oilFood() => _foods.byTacoNumber(oilTacoNumber);
}
