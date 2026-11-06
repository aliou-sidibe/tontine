import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Current time, replaceable in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

/// App documents directory, resolved once in `main` and overridden there.
final documentsDirectoryProvider = Provider<Directory>((ref) {
  throw UnimplementedError('Overridden in main().');
});
