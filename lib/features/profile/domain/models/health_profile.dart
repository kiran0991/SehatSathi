class HealthProfile {
  const HealthProfile({
    required this.conditions,
    required this.allergies,
    required this.goal,
    this.customCondition = '',
    this.customAllergy = '',
    this.isSaved = false,
  });

  static const String none = 'None';
  static const String diabetes = 'Diabetes';
  static const String hypertension = 'Hypertension';
  static const String dairy = 'Dairy';
  static const String gluten = 'Gluten';
  static const String peanut = 'Peanut';
  static const String weightLoss = 'Weight Loss';
  static const String healthyEating = 'Healthy Eating';

  static const List<String> availableConditions = [
    none,
    diabetes,
    hypertension,
  ];

  static const List<String> availableAllergies = [none, dairy, gluten, peanut];

  static const List<String> availableGoals = [none, weightLoss, healthyEating];

  final List<String> conditions;
  final List<String> allergies;
  final String goal;
  final String customCondition;
  final String customAllergy;
  final bool isSaved;

  factory HealthProfile.initial() {
    return const HealthProfile(
      conditions: [none],
      allergies: [none],
      goal: none,
      isSaved: false,
    );
  }

  factory HealthProfile.fromMetadata(Map<String, dynamic> json) {
    final conditions = _sanitizeSelections(
      (json['conditions'] as List<dynamic>? ?? const [none]).cast<String>(),
    );
    final allergies = _sanitizeSelections(
      (json['allergies'] as List<dynamic>? ?? const [none]).cast<String>(),
    );
    final goal = availableGoals.contains(json['goal'])
        ? json['goal'] as String
        : none;

    return HealthProfile(
      conditions: conditions,
      allergies: allergies,
      goal: goal,
      customCondition: (json['custom_condition'] as String? ?? '').trim(),
      customAllergy: (json['custom_allergy'] as String? ?? '').trim(),
      isSaved: true,
    );
  }

  Map<String, dynamic> toMetadata() {
    return {
      'conditions': conditions,
      'allergies': allergies,
      'goal': goal,
      'custom_condition': customCondition.trim(),
      'custom_allergy': customAllergy.trim(),
    };
  }

  bool get hasCustomCondition => customCondition.trim().isNotEmpty;
  bool get hasCustomAllergy => customAllergy.trim().isNotEmpty;

  List<String> get displayConditions =>
      _withCustom(conditions, customCondition);
  List<String> get displayAllergies => _withCustom(allergies, customAllergy);
  List<String> get displayGoals => goal == none ? [none] : [goal];

  HealthProfile copyWith({
    List<String>? conditions,
    List<String>? allergies,
    String? goal,
    String? customCondition,
    String? customAllergy,
    bool? isSaved,
  }) {
    return HealthProfile(
      conditions: conditions ?? this.conditions,
      allergies: allergies ?? this.allergies,
      goal: goal ?? this.goal,
      customCondition: customCondition ?? this.customCondition,
      customAllergy: customAllergy ?? this.customAllergy,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  static List<String> _sanitizeSelections(List<String> values) {
    final cleaned = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();

    if (cleaned.isEmpty || cleaned.contains(none)) {
      return [none];
    }

    return cleaned;
  }

  static List<String> _withCustom(List<String> base, String custom) {
    if (custom.trim().isEmpty) {
      return base;
    }

    return [...base.where((value) => value != none), custom.trim()];
  }
}
