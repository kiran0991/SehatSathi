import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/models/analysis_warning.dart';
import '../domain/models/ingredient_analysis_result.dart';
import '../domain/models/ingredient_signal.dart';
import '../domain/models/scan_analysis_payload.dart';

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({super.key, required this.payload});

  final ScanAnalysisPayload? payload;

  @override
  Widget build(BuildContext context) {
    final data = payload;
    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.text('resultTitle'))),
        body: Center(child: Text(context.l10n.text('resultNoData'))),
      );
    }

    final localizer = _AnalysisContentLocalizer(context.l10n);
    final localizedWarnings = data.analysisResult.warnings
        .map(localizer.localizeWarning)
        .toList();
    final localizedGoodIngredients = data.analysisResult.goodIngredients
        .map(localizer.localizeSignal)
        .toList();
    final localizedWatchIngredients = data.analysisResult.watchOutIngredients
        .map(localizer.localizeSignal)
        .toList();
    final localizedSummary = localizer.buildSummary(
      IngredientAnalysisResult(
        healthScore: data.analysisResult.healthScore,
        goodIngredients: localizedGoodIngredients,
        watchOutIngredients: localizedWatchIngredients,
        warnings: localizedWarnings,
        summary: data.analysisResult.summary,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
          onPressed: () => context.go('/scanner'),
        ),
        title: Text(
          context.l10n.text('appTitle'),
          style: const TextStyle(
            color: AppColors.primary,
            fontFamily: AppStyles.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopCard(data: data),
            const SizedBox(height: 16),
            ...localizedWarnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WarningCard(warning: warning),
              ),
            ),
            _SectionCard(
              title: context.l10n.text('resultSummary'),
              child: Text(
                localizedSummary,
                style: const TextStyle(
                  fontFamily: AppStyles.fontFamily,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: context.l10n.text('resultStructuredIngredients'),
              child: Text(
                data.ocrResult.ingredients
                    .map((item) => context.l10n.ingredientLabel(item.name))
                    .join(', '),
                style: const TextStyle(
                  fontFamily: AppStyles.fontFamily,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SignalsCard(
              title: context.l10n.text('resultGoodIngredients'),
              emptyText: context.l10n.text('resultNoGoodIngredients'),
              items: localizedGoodIngredients
                  .map(
                    (signal) => _SignalCard(
                      color: AppColors.success,
                      name: signal.name,
                      reason: signal.reason,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            _SignalsCard(
              title: context.l10n.text('resultWatchOutIngredients'),
              emptyText: context.l10n.text('resultNoWatchIngredients'),
              items: localizedWatchIngredients
                  .map(
                    (signal) => _SignalCard(
                      color: AppColors.error,
                      name: signal.name,
                      reason: signal.reason,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisContentLocalizer {
  const _AnalysisContentLocalizer(this.l10n);

  final AppLocalizations l10n;

  IngredientSignal localizeSignal(IngredientSignal signal) {
    return IngredientSignal(
      name: l10n.ingredientLabel(signal.name),
      reason: _translateReason(signal.reason),
    );
  }

  AnalysisWarning localizeWarning(AnalysisWarning warning) {
    return AnalysisWarning(
      title: _translateWarningTitle(warning.title),
      message: _translateWarningMessage(warning.message),
      severity: warning.severity,
    );
  }

  String buildSummary(IngredientAnalysisResult result) {
    final band = switch (result.healthScore) {
      >= 75 => l10n.text('analysisBandBalanced'),
      >= 50 => l10n.text('analysisBandMixed'),
      _ => l10n.text('analysisBandCaution'),
    };

    final positivePart = result.goodIngredients.isNotEmpty
        ? l10n.text(
            'analysisSummaryPositiveWithItems',
            params: {
              'items': _joinItems(
                result.goodIngredients
                    .take(2)
                    .map((item) => item.name)
                    .toList(),
              ),
            },
          )
        : l10n.text('analysisSummaryPositiveEmpty');

    final cautionPart = result.watchOutIngredients.isNotEmpty
        ? l10n.text(
            'analysisSummaryCautionWithItems',
            params: {
              'items': _joinItems(
                result.watchOutIngredients
                    .take(2)
                    .map((item) => item.name)
                    .toList(),
              ),
            },
          )
        : l10n.text('analysisSummaryCautionEmpty');

    final warningPart = result.warnings.isNotEmpty
        ? l10n.text(
            'analysisSummaryWarningWithText',
            params: {'message': result.warnings.first.message},
          )
        : l10n.text('analysisSummaryWarningEmpty');

    return [
      l10n.text('analysisSummaryOverall', params: {'band': band}),
      positivePart,
      cautionPart,
      warningPart,
    ].join(' ');
  }

  String _joinItems(List<String> items) {
    if (items.isEmpty) {
      return '';
    }
    if (items.length == 1) {
      return items.first;
    }
    return '${items.first} ${l10n.text('commonAnd')} ${items.last}';
  }

  String _translateReason(String value) {
    return switch (value) {
      'Whole grains are often a better source of fiber than refined flour.' =>
        l10n.text('analysisReasonWholeWheat'),
      'Oats are commonly associated with fiber and a steadier energy release.' =>
        l10n.text('analysisReasonOats'),
      'Millets are often included for their fiber and whole-grain value.' =>
        l10n.text('analysisReasonMillet'),
      'Nuts can contribute healthy fats, though portion size still matters.' =>
        l10n.text('analysisReasonNuts'),
      'Almonds may contribute healthy fats and some protein.' => l10n.text(
        'analysisReasonAlmond',
      ),
      'Peanuts can be nutritious, but they are also a common allergen.' =>
        l10n.text('analysisReasonPeanut'),
      'Added sugar can make a product less balanced, especially when it appears early in the list.' =>
        l10n.text('analysisReasonSugar'),
      'Glucose-based sweeteners can raise the overall sugar load of a product.' =>
        l10n.text('analysisReasonGlucose'),
      'Corn syrup is another added sweetener to watch for in packaged foods.' =>
        l10n.text('analysisReasonCornSyrup'),
      'Refined flour usually offers less fiber than whole-grain alternatives.' =>
        l10n.text('analysisReasonMaida'),
      'Refined wheat flour is less nutrient-dense than whole-grain flour.' =>
        l10n.text('analysisReasonRefinedWheatFlour'),
      'Higher sodium ingredients may matter for people monitoring blood pressure.' =>
        l10n.text('analysisReasonSodium'),
      'Salt can add to the overall sodium content of a product.' => l10n.text(
        'analysisReasonSalt',
      ),
      'Palm oil is often used in processed foods and may increase saturated fat intake.' =>
        l10n.text('analysisReasonPalmOil'),
      'Hydrogenated fats are worth watching because they can signal a more processed product.' =>
        l10n.text('analysisReasonHydrogenated'),
      'Preservatives are common in packaged foods and may indicate heavier processing.' =>
        l10n.text('analysisReasonPreservative'),
      'Artificial flavors can be a sign that the product is more highly processed.' =>
        l10n.text('analysisReasonArtificialFlavor'),
      'Cocoa can add flavor with less reliance on artificial ingredients.' =>
        l10n.text('analysisReasonCocoa'),
      _ => value,
    };
  }

  String _translateWarningTitle(String value) {
    return switch (value) {
      'Dairy alert' => l10n.text('analysisWarningDairyTitle'),
      'Gluten alert' => l10n.text('analysisWarningGlutenTitle'),
      'Peanut alert' => l10n.text('analysisWarningPeanutTitle'),
      'Added sugar watch-out' => l10n.text('analysisWarningSugarTitle'),
      'Sodium watch-out' => l10n.text('analysisWarningSodiumTitle'),
      'Healthy eating goal mismatch' => l10n.text(
        'analysisWarningHealthyEatingTitle',
      ),
      'Weight loss goal watch-out' => l10n.text(
        'analysisWarningWeightLossTitle',
      ),
      'Limited ingredient interpretation' => l10n.text(
        'analysisWarningLimitedTitle',
      ),
      _ => value,
    };
  }

  String _translateWarningMessage(String value) {
    return switch (value) {
      'This ingredient list appears to include dairy-related terms. If you avoid dairy, review the package carefully.' =>
        l10n.text('analysisWarningDairyMessage'),
      'This ingredient list appears to include gluten-related grains. If you avoid gluten, this product may not be suitable.' =>
        l10n.text('analysisWarningGlutenMessage'),
      'Peanut-related terms were detected. If you have a peanut allergy, treat this as a high-priority check.' =>
        l10n.text('analysisWarningPeanutMessage'),
      'Several sweetening ingredients were detected. For diabetes management, it may help to compare portion sizes and total sugar before choosing this product.' =>
        l10n.text('analysisWarningSugarMessage'),
      'Sodium-related ingredients were detected. If you monitor blood pressure, this may be worth a closer look.' =>
        l10n.text('analysisWarningSodiumMessage'),
      'This product appears to lean more processed than whole-food focused. It may be worth comparing with a simpler ingredient list.' =>
        l10n.text('analysisWarningHealthyEatingMessage'),
      'Added sweeteners may make this product easier to overconsume. Looking at serving size can help put it in context.' =>
        l10n.text('analysisWarningWeightLossMessage'),
      'The ingredient list was read, but only a few ingredients matched the current rule set. Treat this as educational guidance, not a medical judgment.' =>
        l10n.text('analysisWarningLimitedMessage'),
      _ => value,
    };
  }
}

class _TopCard extends StatelessWidget {
  const _TopCard({required this.data});

  final ScanAnalysisPayload data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              data.uploadedImage.publicUrl,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  context.l10n.text(
                    'resultHealthScore',
                    params: {
                      'score': data.analysisResult.healthScore.toString(),
                    },
                  ),
                  style: const TextStyle(
                    fontFamily: AppStyles.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.text(
                    'resultOcrConfidence',
                    params: {
                      'confidence': ((data.ocrResult.confidence ?? 0) * 100)
                          .toStringAsFixed(0),
                    },
                  ),
                  style: const TextStyle(
                    fontFamily: AppStyles.fontFamily,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/scanner'),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(context.l10n.text('resultScanAnother')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppStyles.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.warning});

  final AnalysisWarning warning;

  @override
  Widget build(BuildContext context) {
    final color = switch (warning.severity) {
      WarningSeverity.high => AppColors.error,
      WarningSeverity.medium => const Color(0xFFD97706),
      WarningSeverity.low => AppColors.textSecondary,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            warning.title,
            style: TextStyle(
              color: color,
              fontFamily: AppStyles.fontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            warning.message,
            style: const TextStyle(
              fontFamily: AppStyles.fontFamily,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalsCard extends StatelessWidget {
  const _SignalsCard({
    required this.title,
    required this.emptyText,
    required this.items,
  });

  final String title;
  final String emptyText;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      child: items.isEmpty
          ? Text(
              emptyText,
              style: const TextStyle(
                fontFamily: AppStyles.fontFamily,
                color: AppColors.textSecondary,
              ),
            )
          : Column(children: items),
    );
  }
}

class _SignalCard extends StatelessWidget {
  const _SignalCard({
    required this.color,
    required this.name,
    required this.reason,
  });

  final Color color;
  final String name;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              color: color,
              fontFamily: AppStyles.fontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reason,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontFamily: AppStyles.fontFamily,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
