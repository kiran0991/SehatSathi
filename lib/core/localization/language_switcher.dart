import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_localizations.dart';
import 'locale_providers.dart';

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final l10n = context.l10n;
    final controller = ref.read(localeControllerProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: AppLocalizations.supportedLocales.map((item) {
          final code = item.languageCode;

          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => controller.setLocale(item),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: code,
                    groupValue: locale.languageCode,
                    onChanged: (_) => controller.setLocale(item),
                  ),
                  Text(l10n.languageLabel(code)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
