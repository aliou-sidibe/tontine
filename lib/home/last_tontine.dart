import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../data/providers.dart';
import 'tontine_home.dart';

/// File of [LastTontineStore], deleted by a backup restore: the restored
/// data may not hold that tontine.
const lastTontineFileName = 'last_tontine.txt';

/// Remembers the last tontine opened, so the app reopens on its
/// "Aujourd'hui" screen. A tiny file, read and written synchronously.
class LastTontineStore {
  LastTontineStore(Directory root)
    : _file = File(p.join(root.path, lastTontineFileName));

  final File _file;

  String? read() {
    try {
      if (!_file.existsSync()) return null;
      final id = _file.readAsStringSync().trim();
      return id.isEmpty ? null : id;
    } on Object {
      return null;
    }
  }

  void write(String id) {
    try {
      _file.writeAsStringSync(id, flush: true);
    } on Object {
      // Only a convenience: the app still opens on "Mes tontines".
    }
  }

  void clear() {
    try {
      if (_file.existsSync()) _file.deleteSync();
    } on Object {
      // Same as above.
    }
  }
}

final lastTontineStoreProvider = Provider<LastTontineStore>((ref) {
  return LastTontineStore(ref.watch(documentsDirectoryProvider));
});

/// Opens a tontine on "Aujourd'hui" and remembers it. Coming back to "Mes
/// tontines" (the "Plus" tab) forgets it, so the next launch shows the list.
Future<void> openTontine(BuildContext context, WidgetRef ref, String id) async {
  final store = ref.read(lastTontineStoreProvider)..write(id);
  await Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => TontineHome(tontineId: id)));
  store.clear();
}
