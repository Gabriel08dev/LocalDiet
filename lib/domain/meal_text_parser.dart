import 'preparation.dart';
import 'search_text.dart';

/// Como a quantidade de um item foi expressa no texto.
enum QuantityKind {
  /// Em massa (g ou kg): a gramatura é conhecida.
  mass,

  /// Em volume (ml ou l): sem densidade documentada não vira gramas.
  volume,

  /// Em medida caseira ("2 colheres de sopa") ou contagem ("2 ovos").
  measure,

  /// O texto não trouxe quantidade.
  unspecified,
}

/// Um item reconhecido em um texto livre de refeição.
///
/// O parser só lê o texto. Escolher o alimento e converter medida caseira em
/// gramas depende da base e fica para quem usa o resultado.
class ParsedMealItem {
  const ParsedMealItem({
    required this.source,
    required this.foodText,
    required this.kind,
    this.quantity,
    this.grams,
    this.measure,
    this.preparation,
  });

  /// O trecho original do texto.
  final String source;

  /// O que sobrou como nome do alimento, normalizado para busca.
  final String foodText;

  final QuantityKind kind;
  final double? quantity;

  /// Gramatura, conhecida apenas quando [kind] é [QuantityKind.mass].
  final double? grams;

  /// Medida caseira na forma canônica ("colher de sopa", "unidade").
  final String? measure;

  final Preparation? preparation;
}

const _numberWords = {
  'um': 1.0,
  'uma': 1.0,
  'dois': 2.0,
  'duas': 2.0,
  'tres': 3.0,
  'quatro': 4.0,
  'cinco': 5.0,
  'seis': 6.0,
  'meia': 0.5,
  'meio': 0.5,
};

/// Medidas reconhecidas, da mais específica para a mais genérica, com a
/// forma canônica de cada uma.
const _measures = [
  ('colheres de sopa', 'colher de sopa'),
  ('colher de sopa', 'colher de sopa'),
  ('colheres de cha', 'colher de cha'),
  ('colher de cha', 'colher de cha'),
  ('colheres de sobremesa', 'colher de sobremesa'),
  ('colher de sobremesa', 'colher de sobremesa'),
  ('colheres de servir', 'colher de servir'),
  ('colher de servir', 'colher de servir'),
  ('colheres', 'colher'),
  ('colher', 'colher'),
  ('xicaras de cha', 'xicara de cha'),
  ('xicara de cha', 'xicara de cha'),
  ('xicaras', 'xicara'),
  ('xicara', 'xicara'),
  ('copos americanos', 'copo americano'),
  ('copo americano', 'copo americano'),
  ('copos', 'copo'),
  ('copo', 'copo'),
  ('unidades', 'unidade'),
  ('unidade', 'unidade'),
  ('fatias', 'fatia'),
  ('fatia', 'fatia'),
  ('conchas', 'concha'),
  ('concha', 'concha'),
  ('pedacos', 'pedaco'),
  ('pedaco', 'pedaco'),
  ('pratos', 'prato'),
  ('prato', 'prato'),
  ('porcoes', 'porcao'),
  ('porcao', 'porcao'),
  ('escumadeiras', 'escumadeira'),
  ('escumadeira', 'escumadeira'),
  ('pegadores', 'pegador'),
  ('pegador', 'pegador'),
  ('files', 'file'),
  ('file', 'file'),
  ('bifes', 'bife'),
  ('bife', 'bife'),
  ('postas', 'posta'),
  ('posta', 'posta'),
  ('gomos', 'gomo'),
  ('gomo', 'gomo'),
  ('latas', 'lata'),
  ('lata', 'lata'),
  ('potes', 'pote'),
  ('pote', 'pote'),
  ('scoops', 'scoop'),
  ('scoop', 'scoop'),
  ('dosadores', 'dosador'),
  ('dosador', 'dosador'),
  ('punhados', 'punhado'),
  ('punhado', 'punhado'),
  ('rodelas', 'rodela'),
  ('rodela', 'rodela'),
];

// Vírgula só separa itens quando não está entre dois dígitos ("1,5").
final _separator = RegExp(
  r'\s*(?:;|\n|\+|(?<!\d),|,(?!\d)|\s+e\s+|\s+com\s+)\s*',
);
final _andHalf = RegExp(r'(\d+)\s+e\s+mei[ao]\b');
final _number = RegExp(r'^(\d+(?:[.,]\d+)?)(?:\s*/\s*(\d+))?');
final _massOrVolume = RegExp(
  r'^(kg|quilos?|gramas?|gr|g|ml|litros?|l)(?![a-z0-9])',
);
final _leadingPreposition = RegExp(r'^(de|da|do)\s+');

/// Minúsculas e sem acentos, mas preservando os sinais usados em números.
String _simplify(String text) {
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final plain = normalizeSearchText(char);
    buffer.write(plain.isEmpty ? char : plain);
  }
  // Quebras de linha separam itens, então só espaços e tabs são colapsados.
  return buffer.toString().replaceAll(RegExp(r'[ \t]+'), ' ').trim();
}

/// Lê um texto livre de refeição, como "2 ovos fritos, 150 g de arroz e
/// 1 concha de feijão", e devolve os itens reconhecidos.
///
/// O parser é heurístico. Ele não inventa gramatura: quando o texto não traz
/// quantidade em massa, [ParsedMealItem.grams] fica null.
List<ParsedMealItem> parseMealText(String text) {
  // A divisão em itens é feita no texto como foi digitado, para que o trecho
  // mostrado ao usuário mantenha os acentos. Cada trecho é simplificado só
  // na hora de ser lido.
  final lowered = text.toLowerCase().replaceAllMapped(
    _andHalf,
    (match) => '${match.group(1)}.5',
  );
  return lowered
      .split(_separator)
      .map((segment) => segment.replaceAll(RegExp(r'[ \t]+'), ' ').trim())
      .where((segment) => segment.isNotEmpty)
      .map(_parseSegment)
      .whereType<ParsedMealItem>()
      .toList();
}

ParsedMealItem? _parseSegment(String segment) {
  var rest = _simplify(segment);
  double? quantity;

  final numberMatch = _number.firstMatch(rest);
  if (numberMatch != null) {
    quantity = double.parse(numberMatch.group(1)!.replaceAll(',', '.'));
    final denominator = numberMatch.group(2);
    if (denominator != null && int.parse(denominator) != 0) {
      quantity = quantity / int.parse(denominator);
    }
    rest = rest.substring(numberMatch.end).trimLeft();
  } else {
    final firstWord = rest.split(' ').first;
    final wordValue = _numberWords[firstWord];
    if (wordValue != null) {
      quantity = wordValue;
      rest = rest.substring(firstWord.length).trimLeft();
    }
  }

  var kind = QuantityKind.unspecified;
  double? grams;
  String? measure;

  final unitMatch = quantity == null ? null : _massOrVolume.firstMatch(rest);
  if (unitMatch != null) {
    final unit = unitMatch.group(1)!;
    rest = rest.substring(unitMatch.end).trimLeft();
    if (unit == 'ml' || unit == 'l' || unit.startsWith('litro')) {
      kind = QuantityKind.volume;
    } else {
      kind = QuantityKind.mass;
      final isKilo = unit == 'kg' || unit.startsWith('quilo');
      grams = isKilo ? quantity! * 1000 : quantity;
    }
  } else if (quantity != null) {
    kind = QuantityKind.measure;
    measure = 'unidade';
    for (final (spoken, canonical) in _measures) {
      if (rest == spoken || rest.startsWith('$spoken ')) {
        measure = canonical;
        rest = rest.substring(spoken.length).trimLeft();
        break;
      }
    }
  }

  rest = rest.replaceFirst(_leadingPreposition, '');
  final foodText = normalizeSearchText(rest);
  if (foodText.isEmpty) return null;

  return ParsedMealItem(
    source: segment,
    foodText: foodText,
    kind: kind,
    quantity: quantity,
    grams: grams,
    measure: measure,
    preparation: Preparation.detect(foodText),
  );
}
