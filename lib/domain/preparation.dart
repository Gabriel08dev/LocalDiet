import 'search_text.dart';

/// Modo de preparo que costuma acrescentar óleo ao alimento.
///
/// As gramaturas são estimativas do app, sem fonte oficial. Por isso a
/// sugestão sempre aparece rotulada como estimativa e pode ser editada ou
/// removida antes de salvar.
enum Preparation {
  sauteed(oilGrams: 5, stem: 'refogad'),
  fried(oilGrams: 15, stem: 'frit'),
  grilled(oilGrams: 2, stem: 'grelhad');

  const Preparation({required this.oilGrams, required this.stem});

  /// Óleo sugerido por item preparado, em gramas.
  final double oilGrams;

  final String stem;

  bool _appearsIn(String text) =>
      normalizeSearchText(text)
          .split(' ')
          .any((token) => token.startsWith(stem));

  /// O preparo mencionado em um texto livre, se houver.
  static Preparation? detect(String text) {
    for (final preparation in values) {
      if (preparation._appearsIn(text)) return preparation;
    }
    return null;
  }

  /// Verdadeiro quando o nome do alimento já traz este preparo, como em
  /// "Ovo, de galinha, inteiro, frito". Nesse caso a composição já inclui a
  /// gordura e sugerir óleo seria contá-la duas vezes.
  bool isIncludedIn(String foodName) => _appearsIn(foodName);
}

/// Número do óleo de soja na TACO, usado como alimento da sugestão de óleo.
const oilTacoNumber = 272;

/// Óleo a sugerir para um item, ou null quando não se aplica.
double? suggestedOilGrams(Preparation? preparation, String foodName) {
  if (preparation == null || preparation.isIncludedIn(foodName)) return null;
  return preparation.oilGrams;
}
