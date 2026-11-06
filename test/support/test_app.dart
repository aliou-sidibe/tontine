import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/common/theme.dart';
import 'package:matontine/data/app_database.dart';
import 'package:matontine/data/providers.dart';

/// The mockup writes amounts with spaces; the app puts non-breaking ones
/// inside amounts only ("5 000 F"), not between words.
String nb(String text) => text
    .replaceAllMapped(RegExp(r'(\d) (?=\d{3}\b)'), (m) => '${m[1]} ')
    .replaceAllMapped(RegExp(r'(\d) F\b'), (m) => '${m[1]} F');

/// A phone the size of the mockup frames (390 × 844).
void usePhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// The app on Friday 6 November 2026 (day 37 of the mockup's tontine), with
/// an in-memory database and a temporary documents folder.
Widget testApp(Widget home, AppDatabase db) {
  final documents = Directory.systemTemp.createTempSync('matontine_test');
  addTearDown(() => documents.deleteSync(recursive: true));
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(() => DateTime(2026, 11, 6, 10)),
      documentsDirectoryProvider.overrideWithValue(documents),
    ],
    child: MaterialApp(
      theme: appTheme(),
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: home,
    ),
  );
}
