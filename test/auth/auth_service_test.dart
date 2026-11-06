// Ported from IP Caisse (test/auth/auth_service_test.dart).

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matontine/auth/auth_service.dart';
import 'package:matontine/data/app_database.dart';

void main() {
  late AppDatabase database;
  late AuthService auth;
  late DateTime now;

  /// Time since launch, independent of the phone's clock.
  late Duration elapsed;

  /// Time passes: the clock and the stopwatch move together.
  void wait(Duration duration) {
    now = now.add(duration);
    elapsed += duration;
  }

  Future<void> lockOut() async {
    for (var i = 0; i < 5; i++) {
      await auth.login('karim', 'wrong!');
    }
  }

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 6, 12);
    elapsed = Duration.zero;
    auth = AuthService(
      database,
      iterations: 1000,
      now: () => now,
      stopwatch: () => elapsed,
    );
  });
  tearDown(() => database.close());

  test('creates only one account', () async {
    expect(await auth.accountExists(), isFalse);
    await auth.createAccount('karim', 'secret1');

    expect(await auth.accountExists(), isTrue);
    await expectLater(auth.createAccount('other', 'secret2'), throwsStateError);
  });

  test('rejects a password that is too short', () async {
    await expectLater(
      auth.createAccount('karim', '12345'),
      throwsArgumentError,
    );
  });

  test('stores neither the password nor the recovery code', () async {
    final code = await auth.createAccount('karim', 'secret1');
    final account = await database.select(database.accounts).getSingle();

    expect(account.passwordHash, isNot(utf8.encode('secret1')));
    expect(account.recoveryCodeHash, isNot(utf8.encode(code)));
    expect(account.passwordSalt, isNot(account.recoveryCodeSalt));
  });

  test('logs in only with the right username and password', () async {
    await auth.createAccount('Karim', 'secret1');

    expect(await auth.login(' karim ', 'secret1'), LoginResult.success);
    expect(await auth.login('karim', 'wrong!'), LoginResult.rejected);
    expect(await auth.login('other', 'secret1'), LoginResult.rejected);
  });

  test(
    'locks for 30 s after 5 failures, even with the right password',
    () async {
      await auth.createAccount('karim', 'secret1');

      for (var i = 0; i < 4; i++) {
        expect(await auth.login('karim', 'wrong!'), LoginResult.rejected);
      }
      expect(await auth.login('karim', 'wrong!'), LoginResult.locked);
      expect(await auth.login('karim', 'secret1'), LoginResult.locked);

      wait(const Duration(seconds: 31));
      expect(await auth.login('karim', 'secret1'), LoginResult.success);
    },
  );

  test('each new lockout lasts twice as long', () async {
    await auth.createAccount('karim', 'secret1');
    await lockOut();
    expect(await auth.lockoutWait(), const Duration(seconds: 30));

    wait(const Duration(seconds: 31));
    await lockOut();
    expect(await auth.lockoutWait(), const Duration(minutes: 1));

    wait(const Duration(seconds: 61));
    expect(await auth.login('karim', 'secret1'), LoginResult.success);

    // A successful login starts again from the first step.
    await lockOut();
    expect(await auth.lockoutWait(), const Duration(seconds: 30));
  });

  test('lockouts are capped at 16 minutes', () {
    expect(lockoutDuration(0), const Duration(seconds: 30));
    expect(lockoutDuration(4), const Duration(minutes: 8));
    expect(lockoutDuration(5), const Duration(minutes: 16));
    expect(lockoutDuration(12), const Duration(minutes: 16));
  });

  test('a clock moved back does not lock for days', () async {
    await auth.createAccount('karim', 'secret1');
    await lockOut();

    now = now.subtract(const Duration(days: 1));
    elapsed += const Duration(seconds: 31);

    expect(await auth.login('karim', 'secret1'), LoginResult.success);
  });

  group('recovery code', () {
    test('resets the password and replaces the code', () async {
      final code = await auth.createAccount('karim', 'secret1');

      final (result, newCode) = await auth.resetPassword(
        'karim',
        code.toLowerCase().replaceAll('-', ' '),
        'nouveau1',
      );

      expect(result, LoginResult.success);
      expect(newCode, isNotNull);
      expect(newCode, isNot(code));
      expect(await auth.login('karim', 'secret1'), LoginResult.rejected);
      expect(await auth.login('karim', 'nouveau1'), LoginResult.success);

      // The old code no longer works.
      final (again, _) = await auth.resetPassword('karim', code, 'autre12');
      expect(again, LoginResult.rejected);
    });

    test('a wrong code counts as a failure', () async {
      await auth.createAccount('karim', 'secret1');
      for (var i = 0; i < 4; i++) {
        final (result, _) = await auth.resetPassword(
          'karim',
          'AAAA-BBBB-CCCC',
          'nouveau1',
        );
        expect(result, LoginResult.rejected);
      }
      final (result, code) = await auth.resetPassword(
        'karim',
        'AAAA-BBBB-CCCC',
        'nouveau1',
      );
      expect(result, LoginResult.locked);
      expect(code, isNull);
    });
  });

  test('formatWait reads naturally', () {
    expect(formatWait(const Duration(seconds: 1)), '1 seconde');
    expect(formatWait(const Duration(seconds: 30)), '30 secondes');
    expect(formatWait(const Duration(minutes: 2)), '2 min');
    expect(formatWait(const Duration(seconds: 90)), '1 min 30 s');
  });
}
