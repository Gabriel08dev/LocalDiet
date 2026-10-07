import 'dart:math';

final _random = Random.secure();

/// Identificador aleatório de 128 bits em hexadecimal.
///
/// Registros criados pelo usuário usam este formato em vez de autoincremento
/// para que backups e reimportações preservem os vínculos.
String newId() => List.generate(
  16,
  (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();
