// Behaviour ported from IP Caisse (lib/auth/auth_pages.dart). These screens
// are not in the mockup: they follow its style (header of "Mes tontines",
// white fields, 54 px green button).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../backup/backup_page.dart';
import '../common/errors.dart';
import '../common/logo.dart';
import '../common/password_field.dart';
import '../common/theme.dart';
import 'auth_service.dart';
import 'session.dart';

/// Shows [child] only when the user is logged in.
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onPause: () =>
          ref.read(sessionProvider.notifier).goToBackground(DateTime.now()),
      onResume: () => ref.read(sessionProvider.notifier).resume(DateTime.now()),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Once locked, no screen may stay open on top.
    ref.listen(sessionProvider, (_, loggedIn) {
      if (!loggedIn) Navigator.of(context).popUntil((route) => route.isFirst);
    });

    if (ref.watch(sessionProvider)) return widget.child;
    // While a still valid session resumes, without flashing the login.
    if (ref.watch(sessionRestoreProvider).isLoading) return const _Loading();

    return ref
        .watch(accountExistsProvider)
        .when(
          data: (exists) =>
              exists ? const LoginPage() : const CreateAccountPage(),
          loading: () => const _Loading(),
          error: (error, _) =>
              Scaffold(body: Center(child: Text('Base indisponible : $error'))),
        );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
  );
}

class CreateAccountPage extends ConsumerStatefulWidget {
  const CreateAccountPage({super.key});

  @override
  ConsumerState<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends ConsumerState<CreateAccountPage> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  var _busy = false;
  String? _error;
  String? _recoveryCode;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final code = await ref
          .read(authServiceProvider)
          .createAccount(_username.text, _password.text);
      if (mounted) {
        setState(() {
          _busy = false;
          _recoveryCode = code;
        });
      }
    } catch (error, stack) {
      logError(error, stack);
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Création du compte impossible. Réessayez.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _recoveryCode;
    if (code != null) {
      return RecoveryCodePage(
        code: code,
        // The session opens before the login screen can show up.
        onContinue: () async {
          ref.read(sessionProvider.notifier).login();
          ref.invalidate(accountExistsProvider);
        },
      );
    }

    return _AuthScaffold(
      title: 'Créer le compte',
      form: _form,
      children: [
        _UsernameField(_username),
        _NewPasswordField(_password),
        if (_error != null) _ErrorText(_error!),
        FilledButton(
          onPressed: _busy ? null : _create,
          child: const Text('Créer le compte'),
        ),
        // A new phone starts here: the backup brings its own account back.
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          onPressed: _busy ? null : () => restoreBackup(context, ref),
          child: const Text('Restaurer une sauvegarde'),
        ),
      ],
    );
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final LoginResult result;
    try {
      result = await ref
          .read(authServiceProvider)
          .login(_username.text, _password.text);
      if (result == LoginResult.success) {
        ref.read(sessionProvider.notifier).login();
        return;
      }
    } catch (error, stack) {
      logError(error, stack);
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Connexion impossible. Réessayez.';
        });
      }
      return;
    }
    final message = await _rejectionMessage(
      ref.read(authServiceProvider),
      result,
      'Identifiant ou mot de passe incorrect.',
    );
    if (!mounted) return;
    _password.clear();
    _passwordFocus.requestFocus();
    setState(() {
      _busy = false;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Connexion',
      children: [
        _UsernameField(_username),
        PasswordField(
          controller: _password,
          focusNode: _passwordFocus,
          label: 'Mot de passe',
        ),
        if (_error != null) _ErrorText(_error!),
        FilledButton(
          onPressed: _busy ? null : _login,
          child: const Text('Se connecter'),
        ),
        // Not during a login attempt: it could succeed while the page is
        // open.
        TextButton(
          onPressed: _busy
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ResetPasswordPage(),
                  ),
                ),
          child: const Text(
            'Mot de passe oublié',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _recoveryCode = TextEditingController();
  final _password = TextEditingController();
  var _busy = false;
  String? _error;
  String? _newCode;

  @override
  void dispose() {
    _username.dispose();
    _recoveryCode.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final LoginResult result;
    final String? code;
    try {
      (result, code) = await ref
          .read(authServiceProvider)
          .resetPassword(_username.text, _recoveryCode.text, _password.text);
    } catch (error, stack) {
      logError(error, stack);
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Changement impossible. Réessayez.';
        });
      }
      return;
    }
    final message = code == null
        ? await _rejectionMessage(
            ref.read(authServiceProvider),
            result,
            'Identifiant ou code de secours incorrect.',
          )
        : null;
    if (!mounted) return;
    setState(() {
      _busy = false;
      _newCode = code;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final code = _newCode;
    if (code != null) {
      return RecoveryCodePage(
        code: code,
        // The page closes before the session opens: it does not stay on top
        // of the home screen.
        onContinue: () async {
          final session = ref.read(sessionProvider.notifier);
          Navigator.of(context).pop();
          session.login();
        },
      );
    }

    return _AuthScaffold(
      title: 'Mot de passe oublié',
      showBack: true,
      form: _form,
      children: [
        _UsernameField(_username),
        TextFormField(
          controller: _recoveryCode,
          autocorrect: false,
          textCapitalization: TextCapitalization.characters,
          style: AppText.rowTitle.copyWith(fontSize: 16),
          decoration: const InputDecoration(labelText: 'Code de secours'),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Saisissez le code de secours.'
              : null,
        ),
        _NewPasswordField(_password),
        if (_error != null) _ErrorText(_error!),
        FilledButton(
          onPressed: _busy ? null : _reset,
          child: const Text('Changer le mot de passe'),
        ),
      ],
    );
  }
}

/// Shows the recovery code once, at account creation or after a reset.
class RecoveryCodePage extends StatefulWidget {
  const RecoveryCodePage({
    super.key,
    required this.code,
    required this.onContinue,
  });

  final String code;
  final Future<void> Function() onContinue;

  @override
  State<RecoveryCodePage> createState() => _RecoveryCodePageState();
}

class _RecoveryCodePageState extends State<RecoveryCodePage> {
  var _busy = false;
  String? _error;

  /// Only one tap counts, and a failure lets the user try again.
  Future<void> _continue() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onContinue();
    } catch (error, stack) {
      logError(error, stack);
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Ouverture de la session impossible. Réessayez.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Code de secours',
      children: [
        const Text(
          'Notez ce code et gardez-le en lieu sûr. Il permet de changer le '
          'mot de passe en cas d’oubli et ne sera plus affiché.',
          style: AppText.body,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.primaryPale,
            borderRadius: BorderRadius.circular(14),
          ),
          child: SelectableText(
            widget.code,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.onPrimaryPale,
              letterSpacing: 1,
            ),
          ),
        ),
        if (_error != null) _ErrorText(_error!),
        FilledButton(
          onPressed: _busy ? null : _continue,
          child: const Text('J’ai noté ce code'),
        ),
      ],
    );
  }
}

/// The message of a refused attempt: when locked, the real wait, which grows
/// with each lockout.
Future<String> _rejectionMessage(
  AuthService auth,
  LoginResult result,
  String rejectedMessage,
) async {
  if (result != LoginResult.locked) return rejectedMessage;
  final wait = await auth.lockoutWait();
  return 'Trop de tentatives. Réessayez dans ${formatWait(wait)}.';
}

/// Header of "Mes tontines" (caption "Ma Tontine", 28 px title), then the
/// fields 10 px apart, as in "Nouvelle tontine".
class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({
    required this.title,
    required this.children,
    this.form,
    this.showBack = false,
  });

  final String title;
  final List<Widget> children;
  final Key? form;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showBack)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                    child: IconButton(
                      tooltip: 'Retour',
                      color: AppColors.text,
                      icon: const Icon(Icons.chevron_left, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              // The form sits in the middle of the screen, as in IP Caisse;
              // it scrolls when the keyboard leaves too little room.
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(16),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 4, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 18),
                                child: AppLogo(),
                              ),
                              const Text('Ma Tontine', style: AppText.caption),
                              Text(title, style: AppText.homeTitle),
                            ],
                          ),
                        ),
                        for (final child in children)
                          Padding(
                            // The main button stands apart from the fields
                            // above it: 24 px instead of 12.
                            padding: EdgeInsets.only(
                              top: child is FilledButton ? 12 : 0,
                              bottom: 12,
                            ),
                            child: child,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsernameField extends StatelessWidget {
  const _UsernameField(this.controller);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autocorrect: false,
      style: AppText.rowTitle.copyWith(fontSize: 16),
      decoration: const InputDecoration(labelText: 'Identifiant'),
      validator: (value) => value == null || value.trim().isEmpty
          ? 'Saisissez un identifiant.'
          : null,
    );
  }
}

class _NewPasswordField extends StatelessWidget {
  const _NewPasswordField(this.controller);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return PasswordField(
      controller: controller,
      label: 'Nouveau mot de passe',
      validator: (value) => value == null || value.length < minPasswordLength
          ? 'Au moins $minPasswordLength caractères.'
          : null,
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: AppText.body.copyWith(
        color: AppColors.onWarningPale,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
