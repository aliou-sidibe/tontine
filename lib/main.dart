import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'auth/auth_pages.dart';
import 'backup/backup_service.dart';
import 'common/theme.dart';
import 'data/providers.dart';
import 'tontines/tontines_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final documents = await getApplicationDocumentsDirectory();
  // Before the database opens: applies a scheduled restore, or puts back
  // the previous data after an interrupted one.
  final startup = await prepareStartup(documents);
  if (startup == StartupResult.blocked) {
    runApp(const BlockedStartupApp());
    return;
  }
  runApp(
    ProviderScope(
      overrides: [documentsDirectoryProvider.overrideWithValue(documents)],
      child: MaTontineApp(
        restoreFailed: startup == StartupResult.restoreFailed,
      ),
    ),
  );
}

class MaTontineApp extends StatefulWidget {
  const MaTontineApp({super.key, this.restoreFailed = false});

  /// A restore did not go through at startup: said once.
  final bool restoreFailed;

  @override
  State<MaTontineApp> createState() => _MaTontineAppState();
}

class _MaTontineAppState extends State<MaTontineApp> {
  final _navigator = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    if (widget.restoreFailed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _navigator.currentContext;
        if (context == null) return;
        showDialog<void>(
          context: context,
          builder: (dialog) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Restauration non effectuée'),
            content: const Text(
              'La restauration de la sauvegarde n’a pas pu se faire. Les '
              'données d’avant sont toujours en place. Tu peux la relancer '
              'depuis Mes tontines › Sauvegarde.',
              style: AppText.body,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialog).pop(),
                child: const Text('Compris'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ma Tontine',
      navigatorKey: _navigator,
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      // French dates in the date picker; the app has no other language.
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // Since Android 15 the app draws under the system bar: without this
      // inset, the Android buttons hide the bottom of the screens.
      builder: (context, child) => ColoredBox(
        color: AppColors.background,
        child: SafeArea(
          top: false,
          left: false,
          right: false,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      home: const AuthGate(child: TontinesPage()),
    );
  }
}

/// Shown when an interrupted restore could not be undone: the database is
/// not opened, so that an empty one is not created over the data. The next
/// launch tries again.
class BlockedStartupApp extends StatelessWidget {
  const BlockedStartupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ma Tontine',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: const Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  Icon(Icons.restore, size: 48, color: AppColors.primary),
                  Text(
                    'Restauration inachevée',
                    style: AppText.screenTitle,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Une restauration de sauvegarde n’a pas pu se terminer. '
                    'Tes données sont conservées sur le téléphone.\n\n'
                    'Ferme complètement l’application, puis rouvre-la. Si ce '
                    'message revient, ne désinstalle pas l’application : '
                    'cela effacerait les données.',
                    textAlign: TextAlign.center,
                    style: AppText.body,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
