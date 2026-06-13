import 'analysis_warning.dart';
import 'ingredient_signal.dart';

class IngredientAnalysisResult {
  const IngredientAnalysisResult({
    required this.healthScore,
    required this.goodIngredients,
    required this.watchOutIngredients,
    required this.warnings,
    required this.summary,
  });

  final int healthScore;
  final List<IngredientSignal> goodIngredients;
  final List<IngredientSignal> watchOutIngredients;
  final List<AnalysisWarning> warnings;
  final String summary;
}
