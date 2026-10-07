import 'package:intl/intl.dart';

import '../domain/local_date.dart';

const _locale = 'pt_BR';

final _oneDecimal = NumberFormat('#,##0.#', _locale);
final _integer = NumberFormat('#,##0', _locale);
final _twoDecimals = NumberFormat('#,##0.##', _locale);
final _longDay = DateFormat("EEEE, d 'de' MMMM", _locale);
final _dayMonth = DateFormat("d 'de' MMMM", _locale);
final _weekday = DateFormat('EEEE', _locale);
final _weekdayShort = DateFormat('E', _locale);
final _shortDate = DateFormat('dd/MM/yyyy', _locale);
final _dayMonthShort = DateFormat('dd/MM', _locale);

/// Número com no máximo uma casa decimal, no formato brasileiro: "312,5".
String formatNumber(num value) => _oneDecimal.format(value);

/// Número inteiro arredondado: "1.840".
String formatInteger(num value) => _integer.format(value);

/// Número com até duas casas, para a ficha do alimento: "0,08".
String formatPrecise(num value) => _twoDecimals.format(value);

/// "quarta-feira, 7 de outubro".
String formatLongDay(LocalDate date) => _longDay.format(date.toLocalNoon());

String formatKcal(num value) => '${formatInteger(value)} kcal';

String formatGrams(num value) => '${formatNumber(value)} g';

/// Texto de um valor para pôr em um campo editável, sem separador de milhar.
String formatForInput(num value) {
  final rounded = (value * 100).round() / 100;
  final text = rounded == rounded.roundToDouble()
      ? rounded.toStringAsFixed(0)
      : rounded.toString();
  return text.replaceAll('.', ',');
}

/// Lê um número digitado com vírgula ou ponto decimal.
///
/// Devolve null para texto vazio, inválido, negativo ou não finito.
double? parseDecimal(String text) {
  final cleaned = text.trim().replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null || !value.isFinite || value < 0) return null;
  return value;
}

/// "seg", "ter", "qua": o dia da semana em três letras.
String formatWeekdayShort(LocalDate date) =>
    _weekdayShort.format(date.toLocalNoon()).replaceAll('.', '');

String formatDate(LocalDate date) => _shortDate.format(date.toLocalNoon());

String formatDayMonth(LocalDate date) =>
    _dayMonthShort.format(date.toLocalNoon());

/// "Hoje", "Ontem", "Amanhã" ou "terça-feira, 7 de outubro".
String formatRelativeDay(LocalDate date, LocalDate today) {
  final difference = date.differenceInDays(today);
  if (difference == 0) return 'Hoje';
  if (difference == -1) return 'Ontem';
  if (difference == 1) return 'Amanhã';
  final noon = date.toLocalNoon();
  return '${_weekday.format(noon)}, ${_dayMonth.format(noon)}';
}
