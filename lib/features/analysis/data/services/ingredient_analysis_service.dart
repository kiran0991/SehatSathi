import '../../../profile/domain/models/health_profile.dart';
import '../../../scanner/domain/models/ocr_result.dart';
import '../../domain/models/analysis_warning.dart';
import '../../domain/models/ingredient_analysis_result.dart';
import '../../domain/models/ingredient_signal.dart';

abstract class IngredientAnalysisService {
  IngredientAnalysisResult analyze({
    required OcrResult ocrResult,
    required HealthProfile healthProfile,
  });
}

class DeterministicIngredientAnalysisService
    implements IngredientAnalysisService {
  static const Map<String, IngredientRule> _rules = {
    'whole wheat': IngredientRule(
      type: IngredientType.good,
      scoreImpact: 12,
      reason:
          'Whole grains are often a better source of fiber than refined flour.',
    ),
    'oats': IngredientRule(
      type: IngredientType.good,
      scoreImpact: 10,
      reason:
          'Oats are commonly associated with fiber and a steadier energy release.',
    ),
    'millet': IngredientRule(
      type: IngredientType.good,
      scoreImpact: 10,
      reason:
          'Millets are often included for their fiber and whole-grain value.',
    ),
    'nuts': IngredientRule(
      type: IngredientType.good,
      scoreImpact: 6,
      reason:
          'Nuts can contribute healthy fats, though portion size still matters.',
    ),
    'almond': IngredientRule(
      type: IngredientType.good,
      scoreImpact: 6,
      reason: 'Almonds may contribute healthy fats and some protein.',
    ),
    'peanut': IngredientRule(
      type: IngredientType.neutral,
      scoreImpact: 0,
      reason: 'Peanuts can be nutritious, but they are also a common allergen.',
    ),
    'sugar': IngredientRule(
      type: IngredientType.watchOut,
      scoreImpact: -18,
      reason:
          'Added sugar can make a product less balanced, especially when it appears early in the list.',
    ),
    'glucose': IngredientRule(
      type: IngredientType.watchOut,
      scoreImpact: -16,
      reason:
          'Glucose-based sweeteners can raise the overall sugar load of a product.',
    ),
    'corn syrup': IngredientRule(
      type: IngredientType.watchOut,
      scoreImpact: -18,
      reason:
          'Corn syrup is another added sweetener to watch for in packaged foods.',
    ),
    'maida': IngredientRule(
      type: IngredientType.watchOut,
      scoreImpact: -12,
      reason:
          'Refined flour usually offers less fiber than whole-grain alternatives.',
    ),
    'refined wheat flour': IngredientRule(
      type: IngredientType.watchOut,
      scoreImpact: -12,
      reason:
          'Refined wheat flour is less nutrient-dense than whole-grain flour.',
    ),
    'sodium': IngredientRule(
      type: IngredientType.watchOut,
      scoreImpact: -12,
      reason:
          'Higher sodium ingredients may matter for people monitoring blood pressure.',
    ),
    'salt': IngredientRule(
      type: IngredientType.watchOut,
      scoreImpact: -10,
      reason: 'Salt can add to the overall sodium content of a product.',
    ),
    'palm oil': IngredientRule(
      type: IngredientType.watchOut,
      scoreImpact: -10,
      reason:
          'Palm oil is often used in processed foods and may increase saturated fat intake.',
    ),
    'hydrogenated': IngredientRule(
      type: IngredientType.watchOut,
      scoreImpact: -20,
      reason:
          'Hydrogenated fats are worth watching because they can signal a more processed product.',
    ),
    'preservative': IngredientRule(
      type: IngredientType.watchOut,
      scoreImpact: -6,
      reason:
          'Preservatives are common in packaged foods and may indicate heavier processing.',
    ),
    'artificial flavor': IngredientRule(
      type: IngredientType.watchOut,
      scoreImpact: -8,
      reason:
          'Artificial flavors can be a sign that the product is more highly processed.',
    ),
    'cocoa': IngredientRule(
      type: IngredientType.good,
      scoreImpact: 4,
      reason:
          'Cocoa can add flavor with less reliance on artificial ingredients.',
    ),
  };

  static const Map<String, ProfileTrigger> _allergyTriggers = {
    HealthProfile.dairy: ProfileTrigger(
      keywords: ['milk', 'dairy', 'whey', 'casein', 'butter', 'cheese'],
      title: 'Dairy alert',
      message:
          'This ingredient list appears to include dairy-related terms. If you avoid dairy, review the package carefully.',
      severity: WarningSeverity.high,
    ),
    HealthProfile.gluten: ProfileTrigger(
      keywords: ['wheat', 'maida', 'barley', 'rye', 'gluten'],
      title: 'Gluten alert',
      message:
          'This ingredient list appears to include gluten-related grains. If you avoid gluten, this product may not be suitable.',
      severity: WarningSeverity.high,
    ),
    HealthProfile.peanut: ProfileTrigger(
      keywords: ['peanut', 'groundnut'],
      title: 'Peanut alert',
      message:
          'Peanut-related terms were detected. If you have a peanut allergy, treat this as a high-priority check.',
      severity: WarningSeverity.high,
    ),
  };

  static const Map<String, ProfileTrigger> _conditionTriggers = {
    HealthProfile.diabetes: ProfileTrigger(
      keywords: ['sugar', 'glucose', 'corn syrup', 'maltose'],
      title: 'Added sugar watch-out',
      message:
          'Several sweetening ingredients were detected. For diabetes management, it may help to compare portion sizes and total sugar before choosing this product.',
      severity: WarningSeverity.high,
    ),
    HealthProfile.hypertension: ProfileTrigger(
      keywords: ['salt', 'sodium', 'sodium bicarbonate', 'monosodium'],
      title: 'Sodium watch-out',
      message:
          'Sodium-related ingredients were detected. If you monitor blood pressure, this may be worth a closer look.',
      severity: WarningSeverity.medium,
    ),
  };

  @override
  IngredientAnalysisResult analyze({
    required OcrResult ocrResult,
    required HealthProfile healthProfile,
  }) {
    final ingredients = ocrResult.ingredients.map((item) => item.name).toList();
    final lowered = ingredients.map(_normalize).toList();

    final goodSignals = <IngredientSignal>[];
    final watchSignals = <IngredientSignal>[];
    final warnings = <AnalysisWarning>[];
    var score = 50;

    for (var index = 0; index < lowered.length; index++) {
      final ingredient = ingredients[index];
      final normalized = lowered[index];
      final rule = _matchRule(normalized);
      if (rule == null) {
        continue;
      }

      final adjustedImpact = index < 3
          ? rule.scoreImpact
          : (rule.scoreImpact / 2).round();
      score += adjustedImpact;

      final signal = IngredientSignal(name: ingredient, reason: rule.reason);
      if (rule.type == IngredientType.good) {
        goodSignals.add(signal);
      } else if (rule.type == IngredientType.watchOut) {
        watchSignals.add(signal);
      }
    }

    warnings.addAll(_buildProfileWarnings(lowered, healthProfile));

    if (healthProfile.goal == HealthProfile.healthyEating &&
        watchSignals.length > goodSignals.length) {
      warnings.add(
        const AnalysisWarning(
          title: 'Healthy eating goal mismatch',
          message:
              'This product appears to lean more processed than whole-food focused. It may be worth comparing with a simpler ingredient list.',
          severity: WarningSeverity.medium,
        ),
      );
      score -= 8;
    }

    if (healthProfile.goal == HealthProfile.weightLoss &&
        lowered.any(
          (item) => item.contains('sugar') || item.contains('corn syrup'),
        )) {
      warnings.add(
        const AnalysisWarning(
          title: 'Weight loss goal watch-out',
          message:
              'Added sweeteners may make this product easier to overconsume. Looking at serving size can help put it in context.',
          severity: WarningSeverity.medium,
        ),
      );
      score -= 6;
    }

    if (goodSignals.isEmpty && watchSignals.isEmpty) {
      warnings.add(
        const AnalysisWarning(
          title: 'Limited ingredient interpretation',
          message:
              'The ingredient list was read, but only a few ingredients matched the current rule set. Treat this as educational guidance, not a medical judgment.',
          severity: WarningSeverity.low,
        ),
      );
    }

    final clampedScore = score.clamp(0, 100);

    return IngredientAnalysisResult(
      healthScore: clampedScore,
      goodIngredients: _uniqueSignals(goodSignals),
      watchOutIngredients: _uniqueSignals(watchSignals),
      warnings: _uniqueWarnings(warnings),
      summary: _buildSummary(
        score: clampedScore,
        goods: goodSignals,
        watchOuts: watchSignals,
        warnings: warnings,
      ),
    );
  }

  List<AnalysisWarning> _buildProfileWarnings(
    List<String> lowered,
    HealthProfile profile,
  ) {
    final warnings = <AnalysisWarning>[];
    final conditions = profile.displayConditions.map(_normalize);
    final allergies = profile.displayAllergies.map(_normalize);

    for (final allergy in allergies) {
      ProfileTrigger? trigger;
      for (final entry in _allergyTriggers.entries) {
        if (_normalize(entry.key) == allergy) {
          trigger = entry.value;
          break;
        }
      }
      if (trigger != null && _containsAny(lowered, trigger.keywords)) {
        warnings.add(
          AnalysisWarning(
            title: trigger.title,
            message: trigger.message,
            severity: trigger.severity,
          ),
        );
      }
    }

    for (final condition in conditions) {
      ProfileTrigger? trigger;
      for (final entry in _conditionTriggers.entries) {
        if (_normalize(entry.key) == condition) {
          trigger = entry.value;
          break;
        }
      }
      if (trigger != null && _containsAny(lowered, trigger.keywords)) {
        warnings.add(
          AnalysisWarning(
            title: trigger.title,
            message: trigger.message,
            severity: trigger.severity,
          ),
        );
      }
    }

    return warnings;
  }

  bool _containsAny(List<String> ingredients, List<String> keywords) {
    for (final ingredient in ingredients) {
      for (final keyword in keywords) {
        if (ingredient.contains(_normalize(keyword))) {
          return true;
        }
      }
    }
    return false;
  }

  IngredientRule? _matchRule(String ingredient) {
    for (final entry in _rules.entries) {
      if (ingredient.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  List<IngredientSignal> _uniqueSignals(List<IngredientSignal> signals) {
    final seen = <String>{};
    return signals
        .where((signal) => seen.add(_normalize(signal.name)))
        .toList();
  }

  List<AnalysisWarning> _uniqueWarnings(List<AnalysisWarning> warnings) {
    final seen = <String>{};
    return warnings.where((warning) => seen.add(warning.title)).toList();
  }

  String _buildSummary({
    required int score,
    required List<IngredientSignal> goods,
    required List<IngredientSignal> watchOuts,
    required List<AnalysisWarning> warnings,
  }) {
    final band = switch (score) {
      >= 75 => 'fairly balanced',
      >= 50 => 'mixed',
      _ => 'more caution-worthy',
    };

    final positivePart = goods.isNotEmpty
        ? 'Some ingredients such as ${goods.take(2).map((item) => item.name).join(' and ')} support a more positive read.'
        : 'The ingredient list does not show many clearly positive signals in the current rule set.';

    final cautionPart = watchOuts.isNotEmpty
        ? 'At the same time, ingredients like ${watchOuts.take(2).map((item) => item.name).join(' and ')} are worth a closer look.'
        : 'No major watch-out ingredients stood out strongly in the current rule set.';

    final warningPart = warnings.isNotEmpty
        ? 'Because of your health profile, ${warnings.first.message.toLowerCase()}'
        : 'This summary is educational and should be read alongside the nutrition label and serving size.';

    return 'This product looks $band overall. $positivePart $cautionPart $warningPart';
  }

  String _normalize(String value) {
    return value.toLowerCase().trim();
  }
}

class IngredientRule {
  const IngredientRule({
    required this.type,
    required this.scoreImpact,
    required this.reason,
  });

  final IngredientType type;
  final int scoreImpact;
  final String reason;
}

class ProfileTrigger {
  const ProfileTrigger({
    required this.keywords,
    required this.title,
    required this.message,
    required this.severity,
  });

  final List<String> keywords;
  final String title;
  final String message;
  final WarningSeverity severity;
}

enum IngredientType { good, watchOut, neutral }
