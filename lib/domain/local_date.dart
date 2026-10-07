/// Data de calendário sem hora e sem fuso.
///
/// Nascimento, dia do Diário e dia de uma medição são datas, não instantes.
/// Guardá-las como instante faz o dia mudar conforme o fuso de quem lê, então
/// elas circulam neste tipo e são persistidas como texto `AAAA-MM-DD`.
class LocalDate implements Comparable<LocalDate> {
  const LocalDate(this.year, this.month, this.day);

  /// Usa os campos de calendário do [dateTime] como estão, sem converter fuso.
  factory LocalDate.fromDateTime(DateTime dateTime) =>
      LocalDate(dateTime.year, dateTime.month, dateTime.day);

  factory LocalDate.today() => LocalDate.fromDateTime(DateTime.now());

  final int year;
  final int month;
  final int day;

  static final _isoPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  static LocalDate? tryParse(String text) {
    final match = _isoPattern.firstMatch(text);
    if (match == null) return null;
    final date = LocalDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
    // Rejeita datas que o calendário não tem, como 2026-02-30.
    return date._normalized() == date ? date : null;
  }

  static LocalDate parse(String text) {
    final date = tryParse(text);
    if (date == null) throw FormatException('Data inválida', text);
    return date;
  }

  String toIso() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  // As contas usam UTC apenas como calendário, para não sofrer com horário de
  // verão: em UTC todo dia tem 24 horas.
  DateTime _asUtc() => DateTime.utc(year, month, day);

  LocalDate _normalized() => LocalDate.fromDateTime(_asUtc());

  LocalDate addDays(int days) =>
      LocalDate.fromDateTime(DateTime.utc(year, month, day + days));

  int differenceInDays(LocalDate other) =>
      _asUtc().difference(other._asUtc()).inDays;

  /// 1 = segunda-feira, 7 = domingo.
  int get weekday => _asUtc().weekday;

  /// Idade em anos completos na data [reference].
  int ageOn(LocalDate reference) {
    var age = reference.year - year;
    final hadBirthday =
        reference.month > month ||
        (reference.month == month && reference.day >= day);
    if (!hadBirthday) age--;
    return age;
  }

  /// Meio-dia local do dia, para widgets que exigem `DateTime`.
  DateTime toLocalNoon() => DateTime(year, month, day, 12);

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;

  @override
  int compareTo(LocalDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}
