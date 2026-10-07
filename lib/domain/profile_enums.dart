/// Sexo usado apenas nas fórmulas de gasto energético e gordura corporal.
enum Sex { male, female }

enum Goal { lose, maintain, gain }

enum ActivityLevel {
  sedentary(1.2),
  light(1.375),
  moderate(1.55),
  active(1.725),
  veryActive(1.9);

  const ActivityLevel(this.factor);

  /// Multiplicador aplicado à taxa metabólica basal.
  final double factor;
}

enum MealType { breakfast, lunch, snack, dinner, other }
