/// Os seis nutrientes que o app soma e compara.
///
/// Uma instância pode representar valores por 100 g (na ficha de um alimento)
/// ou valores de uma porção (em um item do Diário). A conversão entre os dois
/// passa sempre por [portion].
class Nutrients {
  const Nutrients({
    this.kcal = 0,
    this.protein = 0,
    this.carb = 0,
    this.fat = 0,
    this.fiber = 0,
    this.sodium = 0,
  });

  static const zero = Nutrients();

  /// Energia em kcal.
  final double kcal;

  /// Proteína em g.
  final double protein;

  /// Carboidrato em g.
  final double carb;

  /// Lipídeos em g.
  final double fat;

  /// Fibra alimentar em g.
  final double fiber;

  /// Sódio em mg.
  final double sodium;

  /// A única conta de porção do app: valor por 100 g × gramas / 100.
  static double portion(double per100g, double grams) => per100g * grams / 100;

  /// Considerando esta instância como valores por 100 g, devolve os valores
  /// de uma porção de [grams] gramas.
  Nutrients forGrams(double grams) => Nutrients(
    kcal: portion(kcal, grams),
    protein: portion(protein, grams),
    carb: portion(carb, grams),
    fat: portion(fat, grams),
    fiber: portion(fiber, grams),
    sodium: portion(sodium, grams),
  );

  Nutrients operator +(Nutrients other) => Nutrients(
    kcal: kcal + other.kcal,
    protein: protein + other.protein,
    carb: carb + other.carb,
    fat: fat + other.fat,
    fiber: fiber + other.fiber,
    sodium: sodium + other.sodium,
  );

  static Nutrients sum(Iterable<Nutrients> values) =>
      values.fold(zero, (total, value) => total + value);

  @override
  bool operator ==(Object other) =>
      other is Nutrients &&
      other.kcal == kcal &&
      other.protein == protein &&
      other.carb == carb &&
      other.fat == fat &&
      other.fiber == fiber &&
      other.sodium == sodium;

  @override
  int get hashCode => Object.hash(kcal, protein, carb, fat, fiber, sodium);

  @override
  String toString() =>
      'Nutrients(kcal: $kcal, protein: $protein, carb: $carb, fat: $fat, '
      'fiber: $fiber, sodium: $sodium)';
}
