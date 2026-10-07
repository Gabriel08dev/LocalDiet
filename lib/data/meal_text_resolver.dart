import '../domain/meal_text_parser.dart';
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
    this.grams,
  });

  final ParsedMealItem parsed;

  /// Alimentos que combinam com o texto, do mais provável ao menos.
  final List<FoodRow> candidates;

  /// O alimento proposto, ou null quando nada foi encontrado.
  FoodRow? food;

  /// Gramatura, ou null quando o texto não permite determiná-la.
  double? grams;

  /// Óleo de preparo sugerido para o alimento proposto, em gramas.
  double? get oilGrams =>
      food == null ? null : suggestedOilGrams(parsed.preparation, food!.name);
}

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
          grams: food == null ? null : await gramsFor(parsed, food),
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

  /// A gramatura de [parsed] para o alimento [food].
  ///
  /// Massa vem direto do texto. Medida caseira só vira gramas se o alimento
  /// tiver uma medida com esse nome; caso contrário devolve null, e é o
  /// usuário quem informa.
  Future<double?> gramsFor(ParsedMealItem parsed, FoodRow food) async {
    switch (parsed.kind) {
      case QuantityKind.mass:
        return parsed.grams;
      case QuantityKind.measure:
        final wanted = parsed.measure!;
        final measures = await _measures.forFood(food.id);
        for (final measure in measures) {
          final label = normalizeSearchText(measure.label);
          if (label == wanted || label.startsWith('$wanted ')) {
            return parsed.quantity! * measure.grams;
          }
        }
        return null;
      case QuantityKind.volume:
      case QuantityKind.unspecified:
        return null;
    }
  }

  /// O alimento usado na sugestão de óleo de preparo.
  Future<FoodRow?> oilFood() => _foods.byTacoNumber(oilTacoNumber);
}
