const _diacritics = {
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ï': 'i',
  'ó': 'o',
  'ò': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
  'ñ': 'n',
};

final _notAlphanumeric = RegExp(r'[^a-z0-9]+');

/// Minúsculas, sem acentos, com qualquer pontuação trocada por um espaço.
///
/// É a forma em que nomes de alimentos são indexados e consultas são lidas,
/// de modo que "Pão, francês" e "pao frances" se encontrem.
String normalizeSearchText(String text) {
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_diacritics[char] ?? char);
  }
  return buffer.toString().replaceAll(_notAlphanumeric, ' ').trim();
}

/// Palavras que não ajudam a distinguir um alimento.
const _stopwords = {'de', 'da', 'do', 'das', 'dos', 'e', 'com', 'em', 'a', 'o'};

/// Nomes regionais ou grafias comuns e o termo usado pela TACO.
const _synonyms = {
  'aipim': 'mandioca',
  'macaxeira': 'mandioca',
  'jerimum': 'abobora',
  'mexerica': 'tangerina',
  'bergamota': 'tangerina',
  'bolacha': 'biscoito',
  'mussarela': 'mozarela',
  'mucarela': 'mozarela',
  'muzzarela': 'mozarela',
  'mozzarella': 'mozarela',
  'refri': 'refrigerante',
  'papaya': 'papaia',
  'iogurt': 'iogurte',
  'yogurt': 'iogurte',
  'catchup': 'ketchup',
};

/// Reduz plural e gênero a um prefixo comum: "cozidas" e "cozido" viram
/// "cozid". Só encurta palavras longas o bastante para o prefixo continuar
/// específico.
String _stem(String token) {
  var stem = token;
  if (stem.length >= 4 && stem.endsWith('s')) {
    stem = stem.substring(0, stem.length - 1);
  }
  if (stem.length >= 5 && (stem.endsWith('a') || stem.endsWith('o'))) {
    stem = stem.substring(0, stem.length - 1);
  }
  return stem;
}

/// Termos de busca de uma consulta digitada, já normalizados.
List<String> searchTokens(String input) =>
    normalizeSearchText(input)
        .split(' ')
        .where((token) => token.isNotEmpty && !_stopwords.contains(token))
        .toList();

/// Prefixo do primeiro termo da consulta, usado para dar prioridade aos nomes
/// que começam por ele. Null se não houver termo pesquisável.
String? leadingSearchPrefix(String input) {
  final tokens = searchTokens(input);
  return tokens.isEmpty ? null : _stem(tokens.first);
}

/// Monta a expressão FTS5 para a consulta digitada, ou null se não sobrar
/// nenhum termo pesquisável.
///
/// Todos os termos precisam aparecer (E implícito), cada um como prefixo.
/// Um termo com sinônimo aceita qualquer das duas formas.
String? buildFtsQuery(String input) {
  final tokens = searchTokens(input);
  if (tokens.isEmpty) return null;
  return tokens
      .map((token) {
        final own = '"${_stem(token)}"*';
        final synonym = _synonyms[token];
        return synonym == null ? own : '($own OR "${_stem(synonym)}"*)';
      })
      .join(' ');
}
