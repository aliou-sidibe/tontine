// Ported from IP Caisse (lib/sauvegarde/sauvegarde_page.dart), translated to
// English and drawn in Ma Tontine's style.

import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/errors.dart';
import '../common/format.dart';
import '../common/password_field.dart';
import '../common/theme.dart';
import '../common/widgets.dart';
import '../data/providers.dart';
import '../domain/day.dart';
import 'backup_service.dart';

/// Goes through Android's file picker: phone storage, SD card, USB key or
/// Drive, depending on what the device offers.
class FileChooser {
  const FileChooser();

  static const _channel = MethodChannel('matontine/backup');

  /// Copies [source] to the chosen place, in native code so it survives the
  /// app being stopped during the picker. [marker] is written only once the
  /// copy was read back and checked. Returns `false` if the user cancels.
  Future<bool> save({
    required String name,
    required File source,
    required File marker,
  }) async {
    final saved = await _channel.invokeMethod<bool>('save', {
      'name': name,
      'source': source.path,
      'marker': marker.path,
    });
    return saved ?? false;
  }

  /// Relaunches the app: the process stops, then starts from scratch.
  Future<void> restart() => _channel.invokeMethod<void>('restart');

  /// Beyond this, it is not a backup of the app (a video picked by mistake,
  /// for example), and reading it in memory would crash a small phone.
  static const maxSize = 200 * 1024 * 1024;

  Future<Uint8List?> pick() async {
    final file = await FilePicker.pickFile();
    if (file == null) return null;
    final size = await file.length();
    if (size != null && size > maxSize) {
      throw BackupException(
        'Ce fichier est trop gros pour être une sauvegarde Ma Tontine.',
      );
    }
    return file.readAsBytes();
  }
}

final fileChooserProvider = Provider<FileChooser>((ref) => const FileChooser());

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(
    ref.watch(appDatabaseProvider),
    ref.watch(documentsDirectoryProvider),
    now: ref.watch(clockProvider),
  );
});

final lastBackupProvider = FutureProvider<DateTime?>((ref) {
  return ref.watch(backupServiceProvider).lastBackup();
});

String backupFileName(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return 'ma-tontine-${date.year}-${two(date.month)}-${two(date.day)}-'
      '${two(date.hour)}${two(date.minute)}.matontine';
}

/// "ven. 6 nov. 2026 à 14:30".
String formatBackupDate(DateTime date) =>
    '${formatDay(Day.fromDateTime(date), withYear: true)} à '
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';

void _show(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Blocks the screen during a long operation, which runs in the background.
Future<T> _withWaiting<T>(
  BuildContext context,
  String message,
  Future<T> Function() action,
) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          content: Row(
            spacing: 16,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              Expanded(child: Text(message, style: AppText.body)),
            ],
          ),
        ),
      ),
    ),
  );
  try {
    return await action();
  } finally {
    navigator.pop();
  }
}

Future<void> createBackup(BuildContext context, WidgetRef ref) async {
  final password = await showDialog<String>(
    context: context,
    builder: (_) => const _PasswordDialog(creating: true),
  );
  if (password == null || !context.mounted) return;

  final service = ref.read(backupServiceProvider);
  final chooser = ref.read(fileChooserProvider);
  // The container stays usable if the screen closes during the file picker,
  // unlike `ref`.
  final container = ProviderScope.containerOf(context, listen: false);
  File? source;
  // The pending file is a full copy of the data: it must not stay in the app
  // if the picker did not take it over.
  Future<void> deleteSource() async {
    try {
      if (await source?.exists() ?? false) await source!.delete();
    } on Object {
      // Replaced by the next backup.
    }
  }

  try {
    final created = await _withWaiting(
      context,
      'Création de la sauvegarde…',
      () => service.createFile(password),
    );
    source = created;
    if (!context.mounted) {
      await deleteSource();
      return;
    }
    final saved = await chooser.save(
      name: backupFileName(container.read(clockProvider)()),
      source: created,
      marker: service.lastBackupFile,
    );
    if (!saved) return;
    container.invalidate(lastBackupProvider);
    if (context.mounted) _show(context, 'Sauvegarde enregistrée et vérifiée.');
  } catch (error, stack) {
    if (error is! BackupException) logError(error, stack);
    await deleteSource();
    if (context.mounted) {
      _show(
        context,
        error is BackupException ? error.message : 'Sauvegarde impossible.',
      );
    }
  }
}

/// Returns `true` if the data was replaced by the backup's.
Future<bool> restoreBackup(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final chooser = ref.read(fileChooserProvider);
  final Uint8List? picked;
  try {
    picked = await chooser.pick();
  } catch (error, stack) {
    if (error is! BackupException) logError(error, stack);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          error is BackupException
              ? error.message
              : 'Impossible d’ouvrir ce fichier.',
        ),
      ),
    );
    return false;
  }
  if (picked == null || !context.mounted) return false;
  final bytes = picked;

  final password = await showDialog<String>(
    context: context,
    builder: (_) => const _PasswordDialog(creating: false),
  );
  if (password == null || !context.mounted) return false;

  final service = ref.read(backupServiceProvider);
  try {
    final directory = await _withWaiting(
      context,
      'Vérification de la sauvegarde…',
      () => service.prepare(bytes, password),
    );
    if (!context.mounted) return false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remplacer les données ?', style: _dialogTitle),
        content: const Text(
          'Toutes les tontines de ce téléphone seront remplacées par celles '
          'de la sauvegarde. L’application va redémarrer, puis la connexion '
          'se fera avec le compte de la sauvegarde.',
          style: AppText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.onWarningPale,
            ),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: const Text('Remplacer'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      await directory.delete(recursive: true);
      return false;
    }

    // The swap happens at restart, before the database opens: closing a
    // database in use may hang.
    await service.schedule(directory);
    try {
      await chooser.restart();
    } on Object {
      // Without a restart, the restore would wait for the next launch and
      // erase the payments recorded until then: it is given up.
      await service.cancelSchedule();
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Redémarrage impossible : la restauration est annulée, rien n’a '
            'été modifié.',
          ),
        ),
      );
      return false;
    }
    return true;
  } catch (error, stack) {
    if (error is! BackupException) logError(error, stack);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          error is BackupException ? error.message : 'Restauration impossible.',
        ),
      ),
    );
  }
  return false;
}

const _dialogTitle = TextStyle(
  fontFamily: AppFonts.display,
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: AppColors.text,
);

/// "Sauvegarde" (not in the mockup; same style as the other screens).
class BackupPage extends ConsumerWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last = ref.watch(lastBackupProvider).value;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BackHeader(
              title: 'Sauvegarde',
              bottom: 8,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        const Text(
                          'DERNIÈRE SAUVEGARDE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          last == null
                              ? 'Aucune pour l’instant'
                              : formatBackupDate(last),
                          style: AppText.rowTitle.copyWith(fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enregistre la sauvegarde hors du téléphone : carte SD, '
                    'clé USB ou Drive. Elle contient toutes les tontines, les '
                    'versements, les remises et le compte.',
                    style: AppText.body,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Le mot de passe de sauvegarde n’est conservé nulle part. '
                    'S’il est perdu, le fichier ne peut plus être ouvert.',
                    style: AppText.body,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () => createBackup(context, ref),
                    icon: const Icon(Icons.save_alt, size: 20),
                    label: const Text('Créer une sauvegarde'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => restoreBackup(context, ref),
                    icon: const Icon(Icons.restore, size: 18),
                    label: const Text('Restaurer une sauvegarde'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.creating});

  final bool creating;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      Navigator.of(context).pop(_password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Mot de passe de sauvegarde', style: _dialogTitle),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              PasswordField(
                controller: _password,
                label: 'Mot de passe',
                validator: (value) {
                  if (!widget.creating) {
                    return value == null || value.isEmpty
                        ? 'Obligatoire'
                        : null;
                  }
                  return (value?.length ?? 0) < backupPasswordMinLength
                      ? 'Au moins $backupPasswordMinLength caractères.'
                      : null;
                },
              ),
              if (widget.creating)
                PasswordField(
                  controller: _confirmation,
                  label: 'Confirmer le mot de passe',
                  validator: (value) => value != _password.text
                      ? 'Les mots de passe diffèrent.'
                      : null,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(onPressed: _submit, child: const Text('Valider')),
      ],
    );
  }
}
