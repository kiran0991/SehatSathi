class AnalysisWarning {
  const AnalysisWarning({
    required this.title,
    required this.message,
    required this.severity,
  });

  final String title;
  final String message;
  final WarningSeverity severity;
}

enum WarningSeverity { high, medium, low }
