/// Valor de um nutriente como a TACO o publica.
///
/// A tabela distingue número, traço (`Tr`), não aplicável (`NA`), análise em
/// reavaliação (`*`) e célula em branco (análise não solicitada). O app
/// preserva essa distinção: na ficha do alimento cada caso aparece como é.
sealed class TacoValue {
  const TacoValue();

  /// Interpreta o valor bruto do asset: número, `"Tr"`, `"NA"`, `"*"` ou null.
  factory TacoValue.fromRaw(Object? raw) {
    if (raw == null) return const TacoMissing();
    if (raw is num) return TacoNumber(raw.toDouble());
    return switch (raw) {
      'Tr' => const TacoTrace(),
      'NA' => const TacoNotApplicable(),
      '*' => const TacoUnderReview(),
      _ => throw FormatException('Valor de nutriente desconhecido', raw),
    };
  }

  /// Valor usado em somas. Traço conta como zero; os demais casos sem número
  /// devolvem null, e quem soma os trata como zero.
  double? get numeric => switch (this) {
    TacoNumber(:final value) => value,
    TacoTrace() => 0,
    _ => null,
  };
}

class TacoNumber extends TacoValue {
  const TacoNumber(this.value);
  final double value;
}

/// Traço: valor abaixo do limite de quantificação ou arredondado para zero.
class TacoTrace extends TacoValue {
  const TacoTrace();
}

/// Não aplicável ao alimento.
class TacoNotApplicable extends TacoValue {
  const TacoNotApplicable();
}

/// Análise em reavaliação na edição publicada.
class TacoUnderReview extends TacoValue {
  const TacoUnderReview();
}

/// Análise não solicitada (célula em branco).
class TacoMissing extends TacoValue {
  const TacoMissing();
}
