import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/common/logo.dart';
import 'package:matontine/auth/auth_pages.dart';
import 'package:matontine/auth/session.dart';
import 'package:matontine/common/theme.dart';
import 'package:matontine/data/app_database.dart';
import 'package:matontine/data/providers.dart';
import 'package:matontine/tontines/tontines_page.dart';

Widget _app(Widget home, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: appTheme(), home: home),
    );

void main() {
  testWidgets('"Mes tontines" shows the mockup header and buttons', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      _app(
        const TontinesPage(),
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          documentsDirectoryProvider.overrideWithValue(
            Directory.systemTemp.createTempSync('matontine_test'),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ma Tontine'), findsOneWidget);
    expect(find.text('Mes tontines'), findsOneWidget);
    expect(find.text('EN COURS'), findsOneWidget);
    expect(find.text('Aucune tontine pour l’instant'), findsOneWidget);
    expect(find.text('Nouvelle tontine'), findsOneWidget);
    expect(find.text('Sauvegarde'), findsOneWidget);
    expect(find.text('Mon compte'), findsOneWidget);
  });

  testWidgets('without an account, the gate asks to create one', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const AuthGate(child: TontinesPage()),
        overrides: [
          accountExistsProvider.overrideWith((ref) async => false),
          sessionRestoreProvider.overrideWith((ref) async {}),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Créer le compte'), findsWidgets);
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('Restaurer une sauvegarde'), findsOneWidget);
    expect(find.text('Mes tontines'), findsNothing);
  });

  testWidgets('with an account, the gate asks to log in', (tester) async {
    await tester.pumpWidget(
      _app(
        const AuthGate(child: TontinesPage()),
        overrides: [
          accountExistsProvider.overrideWith((ref) async => true),
          sessionRestoreProvider.overrideWith((ref) async {}),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('Mot de passe oublié'), findsOneWidget);
  });
}
