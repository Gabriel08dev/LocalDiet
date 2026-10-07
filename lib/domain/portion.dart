import 'nutrients.dart';

/// Uma quantidade expressa em alguma medida.
///
/// A gramatura é sempre `quantidade × gramas da medida`. Quando a medida é o
/// próprio grama, [measureGrams] vale 1.
class Portion {
  const Portion({
    required this.measureLabel,
    required this.measureGrams,
    required this.quantity,
  });

  const Portion.grams(double grams)
    : measureLabel = gramLabel,
      measureGrams = 1,
      quantity = grams;

  static const gramLabel = 'g';

  final String measureLabel;
  final double measureGrams;
  final double quantity;

  double get grams => quantity * measureGrams;

  bool get isInGrams => measureLabel == gramLabel && measureGrams == 1;

  bool get isValid =>
      quantity.isFinite && measureGrams.isFinite && quantity > 0 && grams > 0;
}

/// Um alimento com a porção escolhida, pronto para ir ao Diário ou ao Plano.
class FoodPortion {
  const FoodPortion({
    required this.foodId,
    required this.foodName,
    required this.per100,
    required this.portion,
    this.isEstimate = false,
  });

  final String? foodId;
  final String foodName;

  /// Valores por 100 g do alimento no momento da escolha.
  final Nutrients per100;
  final Portion portion;

  /// Marca itens sugeridos pelo app por estimativa, como o óleo de preparo.
  final bool isEstimate;

  Nutrients get nutrients => per100.forGrams(portion.grams);

  FoodPortion withPortion(Portion portion) => FoodPortion(
    foodId: foodId,
    foodName: foodName,
    per100: per100,
    portion: portion,
    isEstimate: isEstimate,
  );
}
