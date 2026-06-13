import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sehat_sathi/app/sehat_sathi_app.dart';
import 'package:sehat_sathi/core/localization/locale_providers.dart';

void main() {
  testWidgets('app renders authentication screen by default', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SehatSathiApp()));

    await tester.pumpAndSettle();

    expect(find.text('Sehat Sathi'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsNWidgets(2));
  });

  testWidgets('app updates strings when locale changes at runtime', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SehatSathiApp(),
      ),
    );

    await tester.pumpAndSettle();

    container
        .read(localeControllerProvider.notifier)
        .setLocale(const Locale('hi'));

    await tester.pumpAndSettle();

    expect(find.text('सेहत साथी'), findsOneWidget);
    expect(find.text('वापसी पर स्वागत है'), findsOneWidget);
    expect(find.text('लॉग इन'), findsNWidgets(2));
  });
}
