import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'auth/auth_pages.dart';
import 'common/theme.dart';
import 'data/providers.dart';
import 'tontines/tontines_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final documents = await getApplicationDocumentsDirectory();
  runApp(
    ProviderScope(
      overrides: [documentsDirectoryProvider.overrideWithValue(documents)],
      child: const MaTontineApp(),
    ),
  );
}

class MaTontineApp extends StatelessWidget {
  const MaTontineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ma Tontine',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
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
