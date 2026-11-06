// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<Uint8List> passwordHash =
      GeneratedColumn<Uint8List>(
        'password_hash',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _passwordSaltMeta = const VerificationMeta(
    'passwordSalt',
  );
  @override
  late final GeneratedColumn<Uint8List> passwordSalt =
      GeneratedColumn<Uint8List>(
        'password_salt',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _recoveryCodeHashMeta = const VerificationMeta(
    'recoveryCodeHash',
  );
  @override
  late final GeneratedColumn<Uint8List> recoveryCodeHash =
      GeneratedColumn<Uint8List>(
        'recovery_code_hash',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _recoveryCodeSaltMeta = const VerificationMeta(
    'recoveryCodeSalt',
  );
  @override
  late final GeneratedColumn<Uint8List> recoveryCodeSalt =
      GeneratedColumn<Uint8List>(
        'recovery_code_salt',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _iterationsMeta = const VerificationMeta(
    'iterations',
  );
  @override
  late final GeneratedColumn<int> iterations = GeneratedColumn<int>(
    'iterations',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _failuresMeta = const VerificationMeta(
    'failures',
  );
  @override
  late final GeneratedColumn<int> failures = GeneratedColumn<int>(
    'failures',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lockedUntilMeta = const VerificationMeta(
    'lockedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> lockedUntil = GeneratedColumn<DateTime>(
    'locked_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lockoutsMeta = const VerificationMeta(
    'lockouts',
  );
  @override
  late final GeneratedColumn<int> lockouts = GeneratedColumn<int>(
    'lockouts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    passwordHash,
    passwordSalt,
    recoveryCodeHash,
    recoveryCodeSalt,
    iterations,
    failures,
    lockedUntil,
    lockouts,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('password_salt')) {
      context.handle(
        _passwordSaltMeta,
        passwordSalt.isAcceptableOrUnknown(
          data['password_salt']!,
          _passwordSaltMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordSaltMeta);
    }
    if (data.containsKey('recovery_code_hash')) {
      context.handle(
        _recoveryCodeHashMeta,
        recoveryCodeHash.isAcceptableOrUnknown(
          data['recovery_code_hash']!,
          _recoveryCodeHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recoveryCodeHashMeta);
    }
    if (data.containsKey('recovery_code_salt')) {
      context.handle(
        _recoveryCodeSaltMeta,
        recoveryCodeSalt.isAcceptableOrUnknown(
          data['recovery_code_salt']!,
          _recoveryCodeSaltMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recoveryCodeSaltMeta);
    }
    if (data.containsKey('iterations')) {
      context.handle(
        _iterationsMeta,
        iterations.isAcceptableOrUnknown(data['iterations']!, _iterationsMeta),
      );
    } else if (isInserting) {
      context.missing(_iterationsMeta);
    }
    if (data.containsKey('failures')) {
      context.handle(
        _failuresMeta,
        failures.isAcceptableOrUnknown(data['failures']!, _failuresMeta),
      );
    }
    if (data.containsKey('locked_until')) {
      context.handle(
        _lockedUntilMeta,
        lockedUntil.isAcceptableOrUnknown(
          data['locked_until']!,
          _lockedUntilMeta,
        ),
      );
    }
    if (data.containsKey('lockouts')) {
      context.handle(
        _lockoutsMeta,
        lockouts.isAcceptableOrUnknown(data['lockouts']!, _lockoutsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}password_hash'],
      )!,
      passwordSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}password_salt'],
      )!,
      recoveryCodeHash: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}recovery_code_hash'],
      )!,
      recoveryCodeSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}recovery_code_salt'],
      )!,
      iterations: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}iterations'],
      )!,
      failures: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failures'],
      )!,
      lockedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}locked_until'],
      ),
      lockouts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lockouts'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String username;
  final Uint8List passwordHash;
  final Uint8List passwordSalt;
  final Uint8List recoveryCodeHash;
  final Uint8List recoveryCodeSalt;

  /// Kept per account, so hashing can be strengthened later.
  final int iterations;
  final int failures;
  final DateTime? lockedUntil;

  /// Successive lockouts since the last successful login: each lasts twice
  /// as long as the previous one.
  final int lockouts;
  final DateTime createdAt;
  const Account({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.passwordSalt,
    required this.recoveryCodeHash,
    required this.recoveryCodeSalt,
    required this.iterations,
    required this.failures,
    this.lockedUntil,
    required this.lockouts,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['username'] = Variable<String>(username);
    map['password_hash'] = Variable<Uint8List>(passwordHash);
    map['password_salt'] = Variable<Uint8List>(passwordSalt);
    map['recovery_code_hash'] = Variable<Uint8List>(recoveryCodeHash);
    map['recovery_code_salt'] = Variable<Uint8List>(recoveryCodeSalt);
    map['iterations'] = Variable<int>(iterations);
    map['failures'] = Variable<int>(failures);
    if (!nullToAbsent || lockedUntil != null) {
      map['locked_until'] = Variable<DateTime>(lockedUntil);
    }
    map['lockouts'] = Variable<int>(lockouts);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      username: Value(username),
      passwordHash: Value(passwordHash),
      passwordSalt: Value(passwordSalt),
      recoveryCodeHash: Value(recoveryCodeHash),
      recoveryCodeSalt: Value(recoveryCodeSalt),
      iterations: Value(iterations),
      failures: Value(failures),
      lockedUntil: lockedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(lockedUntil),
      lockouts: Value(lockouts),
      createdAt: Value(createdAt),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      passwordHash: serializer.fromJson<Uint8List>(json['passwordHash']),
      passwordSalt: serializer.fromJson<Uint8List>(json['passwordSalt']),
      recoveryCodeHash: serializer.fromJson<Uint8List>(
        json['recoveryCodeHash'],
      ),
      recoveryCodeSalt: serializer.fromJson<Uint8List>(
        json['recoveryCodeSalt'],
      ),
      iterations: serializer.fromJson<int>(json['iterations']),
      failures: serializer.fromJson<int>(json['failures']),
      lockedUntil: serializer.fromJson<DateTime?>(json['lockedUntil']),
      lockouts: serializer.fromJson<int>(json['lockouts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'username': serializer.toJson<String>(username),
      'passwordHash': serializer.toJson<Uint8List>(passwordHash),
      'passwordSalt': serializer.toJson<Uint8List>(passwordSalt),
      'recoveryCodeHash': serializer.toJson<Uint8List>(recoveryCodeHash),
      'recoveryCodeSalt': serializer.toJson<Uint8List>(recoveryCodeSalt),
      'iterations': serializer.toJson<int>(iterations),
      'failures': serializer.toJson<int>(failures),
      'lockedUntil': serializer.toJson<DateTime?>(lockedUntil),
      'lockouts': serializer.toJson<int>(lockouts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Account copyWith({
    String? id,
    String? username,
    Uint8List? passwordHash,
    Uint8List? passwordSalt,
    Uint8List? recoveryCodeHash,
    Uint8List? recoveryCodeSalt,
    int? iterations,
    int? failures,
    Value<DateTime?> lockedUntil = const Value.absent(),
    int? lockouts,
    DateTime? createdAt,
  }) => Account(
    id: id ?? this.id,
    username: username ?? this.username,
    passwordHash: passwordHash ?? this.passwordHash,
    passwordSalt: passwordSalt ?? this.passwordSalt,
    recoveryCodeHash: recoveryCodeHash ?? this.recoveryCodeHash,
    recoveryCodeSalt: recoveryCodeSalt ?? this.recoveryCodeSalt,
    iterations: iterations ?? this.iterations,
    failures: failures ?? this.failures,
    lockedUntil: lockedUntil.present ? lockedUntil.value : this.lockedUntil,
    lockouts: lockouts ?? this.lockouts,
    createdAt: createdAt ?? this.createdAt,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      passwordSalt: data.passwordSalt.present
          ? data.passwordSalt.value
          : this.passwordSalt,
      recoveryCodeHash: data.recoveryCodeHash.present
          ? data.recoveryCodeHash.value
          : this.recoveryCodeHash,
      recoveryCodeSalt: data.recoveryCodeSalt.present
          ? data.recoveryCodeSalt.value
          : this.recoveryCodeSalt,
      iterations: data.iterations.present
          ? data.iterations.value
          : this.iterations,
      failures: data.failures.present ? data.failures.value : this.failures,
      lockedUntil: data.lockedUntil.present
          ? data.lockedUntil.value
          : this.lockedUntil,
      lockouts: data.lockouts.present ? data.lockouts.value : this.lockouts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('passwordSalt: $passwordSalt, ')
          ..write('recoveryCodeHash: $recoveryCodeHash, ')
          ..write('recoveryCodeSalt: $recoveryCodeSalt, ')
          ..write('iterations: $iterations, ')
          ..write('failures: $failures, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('lockouts: $lockouts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    $driftBlobEquality.hash(passwordHash),
    $driftBlobEquality.hash(passwordSalt),
    $driftBlobEquality.hash(recoveryCodeHash),
    $driftBlobEquality.hash(recoveryCodeSalt),
    iterations,
    failures,
    lockedUntil,
    lockouts,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.username == this.username &&
          $driftBlobEquality.equals(other.passwordHash, this.passwordHash) &&
          $driftBlobEquality.equals(other.passwordSalt, this.passwordSalt) &&
          $driftBlobEquality.equals(
            other.recoveryCodeHash,
            this.recoveryCodeHash,
          ) &&
          $driftBlobEquality.equals(
            other.recoveryCodeSalt,
            this.recoveryCodeSalt,
          ) &&
          other.iterations == this.iterations &&
          other.failures == this.failures &&
          other.lockedUntil == this.lockedUntil &&
          other.lockouts == this.lockouts &&
          other.createdAt == this.createdAt);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> username;
  final Value<Uint8List> passwordHash;
  final Value<Uint8List> passwordSalt;
  final Value<Uint8List> recoveryCodeHash;
  final Value<Uint8List> recoveryCodeSalt;
  final Value<int> iterations;
  final Value<int> failures;
  final Value<DateTime?> lockedUntil;
  final Value<int> lockouts;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.passwordSalt = const Value.absent(),
    this.recoveryCodeHash = const Value.absent(),
    this.recoveryCodeSalt = const Value.absent(),
    this.iterations = const Value.absent(),
    this.failures = const Value.absent(),
    this.lockedUntil = const Value.absent(),
    this.lockouts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required Uint8List passwordHash,
    required Uint8List passwordSalt,
    required Uint8List recoveryCodeHash,
    required Uint8List recoveryCodeSalt,
    required int iterations,
    this.failures = const Value.absent(),
    this.lockedUntil = const Value.absent(),
    this.lockouts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : username = Value(username),
       passwordHash = Value(passwordHash),
       passwordSalt = Value(passwordSalt),
       recoveryCodeHash = Value(recoveryCodeHash),
       recoveryCodeSalt = Value(recoveryCodeSalt),
       iterations = Value(iterations);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? username,
    Expression<Uint8List>? passwordHash,
    Expression<Uint8List>? passwordSalt,
    Expression<Uint8List>? recoveryCodeHash,
    Expression<Uint8List>? recoveryCodeSalt,
    Expression<int>? iterations,
    Expression<int>? failures,
    Expression<DateTime>? lockedUntil,
    Expression<int>? lockouts,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (passwordSalt != null) 'password_salt': passwordSalt,
      if (recoveryCodeHash != null) 'recovery_code_hash': recoveryCodeHash,
      if (recoveryCodeSalt != null) 'recovery_code_salt': recoveryCodeSalt,
      if (iterations != null) 'iterations': iterations,
      if (failures != null) 'failures': failures,
      if (lockedUntil != null) 'locked_until': lockedUntil,
      if (lockouts != null) 'lockouts': lockouts,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? username,
    Value<Uint8List>? passwordHash,
    Value<Uint8List>? passwordSalt,
    Value<Uint8List>? recoveryCodeHash,
    Value<Uint8List>? recoveryCodeSalt,
    Value<int>? iterations,
    Value<int>? failures,
    Value<DateTime?>? lockedUntil,
    Value<int>? lockouts,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      recoveryCodeHash: recoveryCodeHash ?? this.recoveryCodeHash,
      recoveryCodeSalt: recoveryCodeSalt ?? this.recoveryCodeSalt,
      iterations: iterations ?? this.iterations,
      failures: failures ?? this.failures,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      lockouts: lockouts ?? this.lockouts,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<Uint8List>(passwordHash.value);
    }
    if (passwordSalt.present) {
      map['password_salt'] = Variable<Uint8List>(passwordSalt.value);
    }
    if (recoveryCodeHash.present) {
      map['recovery_code_hash'] = Variable<Uint8List>(recoveryCodeHash.value);
    }
    if (recoveryCodeSalt.present) {
      map['recovery_code_salt'] = Variable<Uint8List>(recoveryCodeSalt.value);
    }
    if (iterations.present) {
      map['iterations'] = Variable<int>(iterations.value);
    }
    if (failures.present) {
      map['failures'] = Variable<int>(failures.value);
    }
    if (lockedUntil.present) {
      map['locked_until'] = Variable<DateTime>(lockedUntil.value);
    }
    if (lockouts.present) {
      map['lockouts'] = Variable<int>(lockouts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('passwordSalt: $passwordSalt, ')
          ..write('recoveryCodeHash: $recoveryCodeHash, ')
          ..write('recoveryCodeSalt: $recoveryCodeSalt, ')
          ..write('iterations: $iterations, ')
          ..write('failures: $failures, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('lockouts: $lockouts, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TontinesTable extends Tontines
    with TableInfo<$TontinesTable, TontineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TontinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placesMeta = const VerificationMeta('places');
  @override
  late final GeneratedColumn<int> places = GeneratedColumn<int>(
    'places',
    aliasedName,
    false,
    check: () => ComparableExpr(places).isBiggerOrEqualValue(1),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contributionPerPlaceMeta =
      const VerificationMeta('contributionPerPlace');
  @override
  late final GeneratedColumn<int> contributionPerPlace = GeneratedColumn<int>(
    'contribution_per_place',
    aliasedName,
    false,
    check: () =>
        ComparableExpr(contributionPerPlace).isBiggerThanValue(0) &
        ((contributionPerPlace / const Constant(10)) * const Constant(10))
            .equalsExp(contributionPerPlace),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tourDaysMeta = const VerificationMeta(
    'tourDays',
  );
  @override
  late final GeneratedColumn<int> tourDays = GeneratedColumn<int>(
    'tour_days',
    aliasedName,
    false,
    check: () => ComparableExpr(tourDays).isBiggerOrEqualValue(1),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstDayMeta = const VerificationMeta(
    'firstDay',
  );
  @override
  late final GeneratedColumn<String> firstDay = GeneratedColumn<String>(
    'first_day',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    places,
    contributionPerPlace,
    tourDays,
    firstDay,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tontine';
  @override
  VerificationContext validateIntegrity(
    Insertable<TontineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('places')) {
      context.handle(
        _placesMeta,
        places.isAcceptableOrUnknown(data['places']!, _placesMeta),
      );
    } else if (isInserting) {
      context.missing(_placesMeta);
    }
    if (data.containsKey('contribution_per_place')) {
      context.handle(
        _contributionPerPlaceMeta,
        contributionPerPlace.isAcceptableOrUnknown(
          data['contribution_per_place']!,
          _contributionPerPlaceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contributionPerPlaceMeta);
    }
    if (data.containsKey('tour_days')) {
      context.handle(
        _tourDaysMeta,
        tourDays.isAcceptableOrUnknown(data['tour_days']!, _tourDaysMeta),
      );
    } else if (isInserting) {
      context.missing(_tourDaysMeta);
    }
    if (data.containsKey('first_day')) {
      context.handle(
        _firstDayMeta,
        firstDay.isAcceptableOrUnknown(data['first_day']!, _firstDayMeta),
      );
    } else if (isInserting) {
      context.missing(_firstDayMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TontineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TontineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      places: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}places'],
      )!,
      contributionPerPlace: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contribution_per_place'],
      )!,
      tourDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tour_days'],
      )!,
      firstDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_day'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TontinesTable createAlias(String alias) {
    return $TontinesTable(attachedDatabase, alias);
  }
}

class TontineRow extends DataClass implements Insertable<TontineRow> {
  final String id;
  final String name;
  final int places;
  final int contributionPerPlace;
  final int tourDays;

  /// Day 1 of the tontine, `yyyy-mm-dd`.
  final String firstDay;
  final DateTime createdAt;
  const TontineRow({
    required this.id,
    required this.name,
    required this.places,
    required this.contributionPerPlace,
    required this.tourDays,
    required this.firstDay,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['places'] = Variable<int>(places);
    map['contribution_per_place'] = Variable<int>(contributionPerPlace);
    map['tour_days'] = Variable<int>(tourDays);
    map['first_day'] = Variable<String>(firstDay);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TontinesCompanion toCompanion(bool nullToAbsent) {
    return TontinesCompanion(
      id: Value(id),
      name: Value(name),
      places: Value(places),
      contributionPerPlace: Value(contributionPerPlace),
      tourDays: Value(tourDays),
      firstDay: Value(firstDay),
      createdAt: Value(createdAt),
    );
  }

  factory TontineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TontineRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      places: serializer.fromJson<int>(json['places']),
      contributionPerPlace: serializer.fromJson<int>(
        json['contributionPerPlace'],
      ),
      tourDays: serializer.fromJson<int>(json['tourDays']),
      firstDay: serializer.fromJson<String>(json['firstDay']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'places': serializer.toJson<int>(places),
      'contributionPerPlace': serializer.toJson<int>(contributionPerPlace),
      'tourDays': serializer.toJson<int>(tourDays),
      'firstDay': serializer.toJson<String>(firstDay),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TontineRow copyWith({
    String? id,
    String? name,
    int? places,
    int? contributionPerPlace,
    int? tourDays,
    String? firstDay,
    DateTime? createdAt,
  }) => TontineRow(
    id: id ?? this.id,
    name: name ?? this.name,
    places: places ?? this.places,
    contributionPerPlace: contributionPerPlace ?? this.contributionPerPlace,
    tourDays: tourDays ?? this.tourDays,
    firstDay: firstDay ?? this.firstDay,
    createdAt: createdAt ?? this.createdAt,
  );
  TontineRow copyWithCompanion(TontinesCompanion data) {
    return TontineRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      places: data.places.present ? data.places.value : this.places,
      contributionPerPlace: data.contributionPerPlace.present
          ? data.contributionPerPlace.value
          : this.contributionPerPlace,
      tourDays: data.tourDays.present ? data.tourDays.value : this.tourDays,
      firstDay: data.firstDay.present ? data.firstDay.value : this.firstDay,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TontineRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('places: $places, ')
          ..write('contributionPerPlace: $contributionPerPlace, ')
          ..write('tourDays: $tourDays, ')
          ..write('firstDay: $firstDay, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    places,
    contributionPerPlace,
    tourDays,
    firstDay,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TontineRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.places == this.places &&
          other.contributionPerPlace == this.contributionPerPlace &&
          other.tourDays == this.tourDays &&
          other.firstDay == this.firstDay &&
          other.createdAt == this.createdAt);
}

class TontinesCompanion extends UpdateCompanion<TontineRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> places;
  final Value<int> contributionPerPlace;
  final Value<int> tourDays;
  final Value<String> firstDay;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TontinesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.places = const Value.absent(),
    this.contributionPerPlace = const Value.absent(),
    this.tourDays = const Value.absent(),
    this.firstDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TontinesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int places,
    required int contributionPerPlace,
    required int tourDays,
    required String firstDay,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       places = Value(places),
       contributionPerPlace = Value(contributionPerPlace),
       tourDays = Value(tourDays),
       firstDay = Value(firstDay);
  static Insertable<TontineRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? places,
    Expression<int>? contributionPerPlace,
    Expression<int>? tourDays,
    Expression<String>? firstDay,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (places != null) 'places': places,
      if (contributionPerPlace != null)
        'contribution_per_place': contributionPerPlace,
      if (tourDays != null) 'tour_days': tourDays,
      if (firstDay != null) 'first_day': firstDay,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TontinesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? places,
    Value<int>? contributionPerPlace,
    Value<int>? tourDays,
    Value<String>? firstDay,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TontinesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      places: places ?? this.places,
      contributionPerPlace: contributionPerPlace ?? this.contributionPerPlace,
      tourDays: tourDays ?? this.tourDays,
      firstDay: firstDay ?? this.firstDay,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (places.present) {
      map['places'] = Variable<int>(places.value);
    }
    if (contributionPerPlace.present) {
      map['contribution_per_place'] = Variable<int>(contributionPerPlace.value);
    }
    if (tourDays.present) {
      map['tour_days'] = Variable<int>(tourDays.value);
    }
    if (firstDay.present) {
      map['first_day'] = Variable<String>(firstDay.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TontinesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('places: $places, ')
          ..write('contributionPerPlace: $contributionPerPlace, ')
          ..write('tourDays: $tourDays, ')
          ..write('firstDay: $firstDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembersTable extends Members with TableInfo<$MembersTable, MemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _tontineIdMeta = const VerificationMeta(
    'tontineId',
  );
  @override
  late final GeneratedColumn<String> tontineId = GeneratedColumn<String>(
    'tontine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tontine (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tontineId,
    name,
    phone,
    position,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'member';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tontine_id')) {
      context.handle(
        _tontineIdMeta,
        tontineId.isAcceptableOrUnknown(data['tontine_id']!, _tontineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tontineIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemberRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tontineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tontine_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class MemberRow extends DataClass implements Insertable<MemberRow> {
  final String id;
  final String tontineId;
  final String name;
  final String? phone;

  /// Order in which members were entered.
  final int position;
  final DateTime createdAt;
  const MemberRow({
    required this.id,
    required this.tontineId,
    required this.name,
    this.phone,
    required this.position,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tontine_id'] = Variable<String>(tontineId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['position'] = Variable<int>(position);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      tontineId: Value(tontineId),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      position: Value(position),
      createdAt: Value(createdAt),
    );
  }

  factory MemberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemberRow(
      id: serializer.fromJson<String>(json['id']),
      tontineId: serializer.fromJson<String>(json['tontineId']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      position: serializer.fromJson<int>(json['position']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tontineId': serializer.toJson<String>(tontineId),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'position': serializer.toJson<int>(position),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MemberRow copyWith({
    String? id,
    String? tontineId,
    String? name,
    Value<String?> phone = const Value.absent(),
    int? position,
    DateTime? createdAt,
  }) => MemberRow(
    id: id ?? this.id,
    tontineId: tontineId ?? this.tontineId,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
  );
  MemberRow copyWithCompanion(MembersCompanion data) {
    return MemberRow(
      id: data.id.present ? data.id.value : this.id,
      tontineId: data.tontineId.present ? data.tontineId.value : this.tontineId,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemberRow(')
          ..write('id: $id, ')
          ..write('tontineId: $tontineId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tontineId, name, phone, position, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemberRow &&
          other.id == this.id &&
          other.tontineId == this.tontineId &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.position == this.position &&
          other.createdAt == this.createdAt);
}

class MembersCompanion extends UpdateCompanion<MemberRow> {
  final Value<String> id;
  final Value<String> tontineId;
  final Value<String> name;
  final Value<String?> phone;
  final Value<int> position;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.tontineId = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembersCompanion.insert({
    this.id = const Value.absent(),
    required String tontineId,
    required String name,
    this.phone = const Value.absent(),
    required int position,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tontineId = Value(tontineId),
       name = Value(name),
       position = Value(position);
  static Insertable<MemberRow> custom({
    Expression<String>? id,
    Expression<String>? tontineId,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<int>? position,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tontineId != null) 'tontine_id': tontineId,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembersCompanion copyWith({
    Value<String>? id,
    Value<String>? tontineId,
    Value<String>? name,
    Value<String?>? phone,
    Value<int>? position,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MembersCompanion(
      id: id ?? this.id,
      tontineId: tontineId ?? this.tontineId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tontineId.present) {
      map['tontine_id'] = Variable<String>(tontineId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('tontineId: $tontineId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SlotsTable extends Slots with TableInfo<$SlotsTable, SlotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _tontineIdMeta = const VerificationMeta(
    'tontineId',
  );
  @override
  late final GeneratedColumn<String> tontineId = GeneratedColumn<String>(
    'tontine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tontine (id)',
    ),
  );
  static const VerificationMeta _tourMeta = const VerificationMeta('tour');
  @override
  late final GeneratedColumn<int> tour = GeneratedColumn<int>(
    'tour',
    aliasedName,
    false,
    check: () => ComparableExpr(tour).isBiggerOrEqualValue(1),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES member (id)',
    ),
  );
  static const VerificationMeta _halvesMeta = const VerificationMeta('halves');
  @override
  late final GeneratedColumn<int> halves = GeneratedColumn<int>(
    'halves',
    aliasedName,
    false,
    check: () => halves.isIn(const [1, 2]),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, tontineId, tour, memberId, halves];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'slot';
  @override
  VerificationContext validateIntegrity(
    Insertable<SlotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tontine_id')) {
      context.handle(
        _tontineIdMeta,
        tontineId.isAcceptableOrUnknown(data['tontine_id']!, _tontineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tontineIdMeta);
    }
    if (data.containsKey('tour')) {
      context.handle(
        _tourMeta,
        tour.isAcceptableOrUnknown(data['tour']!, _tourMeta),
      );
    } else if (isInserting) {
      context.missing(_tourMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('halves')) {
      context.handle(
        _halvesMeta,
        halves.isAcceptableOrUnknown(data['halves']!, _halvesMeta),
      );
    } else if (isInserting) {
      context.missing(_halvesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SlotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SlotRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tontineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tontine_id'],
      )!,
      tour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tour'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      halves: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}halves'],
      )!,
    );
  }

  @override
  $SlotsTable createAlias(String alias) {
    return $SlotsTable(attachedDatabase, alias);
  }
}

class SlotRow extends DataClass implements Insertable<SlotRow> {
  final String id;
  final String tontineId;
  final int tour;
  final String memberId;
  final int halves;
  const SlotRow({
    required this.id,
    required this.tontineId,
    required this.tour,
    required this.memberId,
    required this.halves,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tontine_id'] = Variable<String>(tontineId);
    map['tour'] = Variable<int>(tour);
    map['member_id'] = Variable<String>(memberId);
    map['halves'] = Variable<int>(halves);
    return map;
  }

  SlotsCompanion toCompanion(bool nullToAbsent) {
    return SlotsCompanion(
      id: Value(id),
      tontineId: Value(tontineId),
      tour: Value(tour),
      memberId: Value(memberId),
      halves: Value(halves),
    );
  }

  factory SlotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SlotRow(
      id: serializer.fromJson<String>(json['id']),
      tontineId: serializer.fromJson<String>(json['tontineId']),
      tour: serializer.fromJson<int>(json['tour']),
      memberId: serializer.fromJson<String>(json['memberId']),
      halves: serializer.fromJson<int>(json['halves']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tontineId': serializer.toJson<String>(tontineId),
      'tour': serializer.toJson<int>(tour),
      'memberId': serializer.toJson<String>(memberId),
      'halves': serializer.toJson<int>(halves),
    };
  }

  SlotRow copyWith({
    String? id,
    String? tontineId,
    int? tour,
    String? memberId,
    int? halves,
  }) => SlotRow(
    id: id ?? this.id,
    tontineId: tontineId ?? this.tontineId,
    tour: tour ?? this.tour,
    memberId: memberId ?? this.memberId,
    halves: halves ?? this.halves,
  );
  SlotRow copyWithCompanion(SlotsCompanion data) {
    return SlotRow(
      id: data.id.present ? data.id.value : this.id,
      tontineId: data.tontineId.present ? data.tontineId.value : this.tontineId,
      tour: data.tour.present ? data.tour.value : this.tour,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      halves: data.halves.present ? data.halves.value : this.halves,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SlotRow(')
          ..write('id: $id, ')
          ..write('tontineId: $tontineId, ')
          ..write('tour: $tour, ')
          ..write('memberId: $memberId, ')
          ..write('halves: $halves')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tontineId, tour, memberId, halves);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SlotRow &&
          other.id == this.id &&
          other.tontineId == this.tontineId &&
          other.tour == this.tour &&
          other.memberId == this.memberId &&
          other.halves == this.halves);
}

class SlotsCompanion extends UpdateCompanion<SlotRow> {
  final Value<String> id;
  final Value<String> tontineId;
  final Value<int> tour;
  final Value<String> memberId;
  final Value<int> halves;
  final Value<int> rowid;
  const SlotsCompanion({
    this.id = const Value.absent(),
    this.tontineId = const Value.absent(),
    this.tour = const Value.absent(),
    this.memberId = const Value.absent(),
    this.halves = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SlotsCompanion.insert({
    this.id = const Value.absent(),
    required String tontineId,
    required int tour,
    required String memberId,
    required int halves,
    this.rowid = const Value.absent(),
  }) : tontineId = Value(tontineId),
       tour = Value(tour),
       memberId = Value(memberId),
       halves = Value(halves);
  static Insertable<SlotRow> custom({
    Expression<String>? id,
    Expression<String>? tontineId,
    Expression<int>? tour,
    Expression<String>? memberId,
    Expression<int>? halves,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tontineId != null) 'tontine_id': tontineId,
      if (tour != null) 'tour': tour,
      if (memberId != null) 'member_id': memberId,
      if (halves != null) 'halves': halves,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SlotsCompanion copyWith({
    Value<String>? id,
    Value<String>? tontineId,
    Value<int>? tour,
    Value<String>? memberId,
    Value<int>? halves,
    Value<int>? rowid,
  }) {
    return SlotsCompanion(
      id: id ?? this.id,
      tontineId: tontineId ?? this.tontineId,
      tour: tour ?? this.tour,
      memberId: memberId ?? this.memberId,
      halves: halves ?? this.halves,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tontineId.present) {
      map['tontine_id'] = Variable<String>(tontineId.value);
    }
    if (tour.present) {
      map['tour'] = Variable<int>(tour.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (halves.present) {
      map['halves'] = Variable<int>(halves.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SlotsCompanion(')
          ..write('id: $id, ')
          ..write('tontineId: $tontineId, ')
          ..write('tour: $tour, ')
          ..write('memberId: $memberId, ')
          ..write('halves: $halves, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments
    with TableInfo<$PaymentsTable, PaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _tontineIdMeta = const VerificationMeta(
    'tontineId',
  );
  @override
  late final GeneratedColumn<String> tontineId = GeneratedColumn<String>(
    'tontine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tontine (id)',
    ),
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES member (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    check: () => ComparableExpr(amount).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod, String> method =
      GeneratedColumn<String>(
        'method',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PaymentMethod>($PaymentsTable.$convertermethod);
  static const VerificationMeta _paidOnMeta = const VerificationMeta('paidOn');
  @override
  late final GeneratedColumn<String> paidOn = GeneratedColumn<String>(
    'paid_on',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payoutIdMeta = const VerificationMeta(
    'payoutId',
  );
  @override
  late final GeneratedColumn<String> payoutId = GeneratedColumn<String>(
    'payout_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tontineId,
    memberId,
    amount,
    method,
    paidOn,
    payoutId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tontine_id')) {
      context.handle(
        _tontineIdMeta,
        tontineId.isAcceptableOrUnknown(data['tontine_id']!, _tontineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tontineIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('paid_on')) {
      context.handle(
        _paidOnMeta,
        paidOn.isAcceptableOrUnknown(data['paid_on']!, _paidOnMeta),
      );
    } else if (isInserting) {
      context.missing(_paidOnMeta);
    }
    if (data.containsKey('payout_id')) {
      context.handle(
        _payoutIdMeta,
        payoutId.isAcceptableOrUnknown(data['payout_id']!, _payoutIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tontineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tontine_id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      method: $PaymentsTable.$convertermethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}method'],
        )!,
      ),
      paidOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_on'],
      )!,
      payoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payout_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentMethod, String, String> $convertermethod =
      const EnumNameConverter<PaymentMethod>(PaymentMethod.values);
}

class PaymentRow extends DataClass implements Insertable<PaymentRow> {
  final String id;
  final String tontineId;
  final String memberId;
  final int amount;
  final PaymentMethod method;

  /// Day the money was received, `yyyy-mm-dd`.
  final String paidOn;

  /// The payout this amount was withheld from, for [PaymentMethod.withheld].
  final String? payoutId;
  final DateTime createdAt;
  const PaymentRow({
    required this.id,
    required this.tontineId,
    required this.memberId,
    required this.amount,
    required this.method,
    required this.paidOn,
    this.payoutId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tontine_id'] = Variable<String>(tontineId);
    map['member_id'] = Variable<String>(memberId);
    map['amount'] = Variable<int>(amount);
    {
      map['method'] = Variable<String>(
        $PaymentsTable.$convertermethod.toSql(method),
      );
    }
    map['paid_on'] = Variable<String>(paidOn);
    if (!nullToAbsent || payoutId != null) {
      map['payout_id'] = Variable<String>(payoutId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      tontineId: Value(tontineId),
      memberId: Value(memberId),
      amount: Value(amount),
      method: Value(method),
      paidOn: Value(paidOn),
      payoutId: payoutId == null && nullToAbsent
          ? const Value.absent()
          : Value(payoutId),
      createdAt: Value(createdAt),
    );
  }

  factory PaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentRow(
      id: serializer.fromJson<String>(json['id']),
      tontineId: serializer.fromJson<String>(json['tontineId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      amount: serializer.fromJson<int>(json['amount']),
      method: $PaymentsTable.$convertermethod.fromJson(
        serializer.fromJson<String>(json['method']),
      ),
      paidOn: serializer.fromJson<String>(json['paidOn']),
      payoutId: serializer.fromJson<String?>(json['payoutId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tontineId': serializer.toJson<String>(tontineId),
      'memberId': serializer.toJson<String>(memberId),
      'amount': serializer.toJson<int>(amount),
      'method': serializer.toJson<String>(
        $PaymentsTable.$convertermethod.toJson(method),
      ),
      'paidOn': serializer.toJson<String>(paidOn),
      'payoutId': serializer.toJson<String?>(payoutId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PaymentRow copyWith({
    String? id,
    String? tontineId,
    String? memberId,
    int? amount,
    PaymentMethod? method,
    String? paidOn,
    Value<String?> payoutId = const Value.absent(),
    DateTime? createdAt,
  }) => PaymentRow(
    id: id ?? this.id,
    tontineId: tontineId ?? this.tontineId,
    memberId: memberId ?? this.memberId,
    amount: amount ?? this.amount,
    method: method ?? this.method,
    paidOn: paidOn ?? this.paidOn,
    payoutId: payoutId.present ? payoutId.value : this.payoutId,
    createdAt: createdAt ?? this.createdAt,
  );
  PaymentRow copyWithCompanion(PaymentsCompanion data) {
    return PaymentRow(
      id: data.id.present ? data.id.value : this.id,
      tontineId: data.tontineId.present ? data.tontineId.value : this.tontineId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      amount: data.amount.present ? data.amount.value : this.amount,
      method: data.method.present ? data.method.value : this.method,
      paidOn: data.paidOn.present ? data.paidOn.value : this.paidOn,
      payoutId: data.payoutId.present ? data.payoutId.value : this.payoutId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRow(')
          ..write('id: $id, ')
          ..write('tontineId: $tontineId, ')
          ..write('memberId: $memberId, ')
          ..write('amount: $amount, ')
          ..write('method: $method, ')
          ..write('paidOn: $paidOn, ')
          ..write('payoutId: $payoutId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tontineId,
    memberId,
    amount,
    method,
    paidOn,
    payoutId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentRow &&
          other.id == this.id &&
          other.tontineId == this.tontineId &&
          other.memberId == this.memberId &&
          other.amount == this.amount &&
          other.method == this.method &&
          other.paidOn == this.paidOn &&
          other.payoutId == this.payoutId &&
          other.createdAt == this.createdAt);
}

class PaymentsCompanion extends UpdateCompanion<PaymentRow> {
  final Value<String> id;
  final Value<String> tontineId;
  final Value<String> memberId;
  final Value<int> amount;
  final Value<PaymentMethod> method;
  final Value<String> paidOn;
  final Value<String?> payoutId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.tontineId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.amount = const Value.absent(),
    this.method = const Value.absent(),
    this.paidOn = const Value.absent(),
    this.payoutId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    required String tontineId,
    required String memberId,
    required int amount,
    required PaymentMethod method,
    required String paidOn,
    this.payoutId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tontineId = Value(tontineId),
       memberId = Value(memberId),
       amount = Value(amount),
       method = Value(method),
       paidOn = Value(paidOn);
  static Insertable<PaymentRow> custom({
    Expression<String>? id,
    Expression<String>? tontineId,
    Expression<String>? memberId,
    Expression<int>? amount,
    Expression<String>? method,
    Expression<String>? paidOn,
    Expression<String>? payoutId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tontineId != null) 'tontine_id': tontineId,
      if (memberId != null) 'member_id': memberId,
      if (amount != null) 'amount': amount,
      if (method != null) 'method': method,
      if (paidOn != null) 'paid_on': paidOn,
      if (payoutId != null) 'payout_id': payoutId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? tontineId,
    Value<String>? memberId,
    Value<int>? amount,
    Value<PaymentMethod>? method,
    Value<String>? paidOn,
    Value<String?>? payoutId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      tontineId: tontineId ?? this.tontineId,
      memberId: memberId ?? this.memberId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      paidOn: paidOn ?? this.paidOn,
      payoutId: payoutId ?? this.payoutId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tontineId.present) {
      map['tontine_id'] = Variable<String>(tontineId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(
        $PaymentsTable.$convertermethod.toSql(method.value),
      );
    }
    if (paidOn.present) {
      map['paid_on'] = Variable<String>(paidOn.value);
    }
    if (payoutId.present) {
      map['payout_id'] = Variable<String>(payoutId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('tontineId: $tontineId, ')
          ..write('memberId: $memberId, ')
          ..write('amount: $amount, ')
          ..write('method: $method, ')
          ..write('paidOn: $paidOn, ')
          ..write('payoutId: $payoutId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentCancellationsTable extends PaymentCancellations
    with TableInfo<$PaymentCancellationsTable, PaymentCancellationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentCancellationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _paymentIdMeta = const VerificationMeta(
    'paymentId',
  );
  @override
  late final GeneratedColumn<String> paymentId = GeneratedColumn<String>(
    'payment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES payment (id)',
    ),
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [paymentId, reason, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_cancellation';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentCancellationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {paymentId};
  @override
  PaymentCancellationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentCancellationRow(
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PaymentCancellationsTable createAlias(String alias) {
    return $PaymentCancellationsTable(attachedDatabase, alias);
  }
}

class PaymentCancellationRow extends DataClass
    implements Insertable<PaymentCancellationRow> {
  final String paymentId;
  final String? reason;
  final DateTime createdAt;
  const PaymentCancellationRow({
    required this.paymentId,
    this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['payment_id'] = Variable<String>(paymentId);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentCancellationsCompanion toCompanion(bool nullToAbsent) {
    return PaymentCancellationsCompanion(
      paymentId: Value(paymentId),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory PaymentCancellationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentCancellationRow(
      paymentId: serializer.fromJson<String>(json['paymentId']),
      reason: serializer.fromJson<String?>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'paymentId': serializer.toJson<String>(paymentId),
      'reason': serializer.toJson<String?>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PaymentCancellationRow copyWith({
    String? paymentId,
    Value<String?> reason = const Value.absent(),
    DateTime? createdAt,
  }) => PaymentCancellationRow(
    paymentId: paymentId ?? this.paymentId,
    reason: reason.present ? reason.value : this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  PaymentCancellationRow copyWithCompanion(PaymentCancellationsCompanion data) {
    return PaymentCancellationRow(
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentCancellationRow(')
          ..write('paymentId: $paymentId, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(paymentId, reason, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentCancellationRow &&
          other.paymentId == this.paymentId &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class PaymentCancellationsCompanion
    extends UpdateCompanion<PaymentCancellationRow> {
  final Value<String> paymentId;
  final Value<String?> reason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PaymentCancellationsCompanion({
    this.paymentId = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentCancellationsCompanion.insert({
    required String paymentId,
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : paymentId = Value(paymentId);
  static Insertable<PaymentCancellationRow> custom({
    Expression<String>? paymentId,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (paymentId != null) 'payment_id': paymentId,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentCancellationsCompanion copyWith({
    Value<String>? paymentId,
    Value<String?>? reason,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PaymentCancellationsCompanion(
      paymentId: paymentId ?? this.paymentId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentCancellationsCompanion(')
          ..write('paymentId: $paymentId, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PayoutsTable extends Payouts with TableInfo<$PayoutsTable, PayoutRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _tontineIdMeta = const VerificationMeta(
    'tontineId',
  );
  @override
  late final GeneratedColumn<String> tontineId = GeneratedColumn<String>(
    'tontine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tontine (id)',
    ),
  );
  static const VerificationMeta _slotIdMeta = const VerificationMeta('slotId');
  @override
  late final GeneratedColumn<String> slotId = GeneratedColumn<String>(
    'slot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES slot (id)',
    ),
  );
  static const VerificationMeta _paidOnMeta = const VerificationMeta('paidOn');
  @override
  late final GeneratedColumn<String> paidOn = GeneratedColumn<String>(
    'paid_on',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _potMeta = const VerificationMeta('pot');
  @override
  late final GeneratedColumn<int> pot = GeneratedColumn<int>(
    'pot',
    aliasedName,
    false,
    check: () => ComparableExpr(pot).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectedMeta = const VerificationMeta(
    'collected',
  );
  @override
  late final GeneratedColumn<int> collected = GeneratedColumn<int>(
    'collected',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _organizerTopUpMeta = const VerificationMeta(
    'organizerTopUp',
  );
  @override
  late final GeneratedColumn<int> organizerTopUp = GeneratedColumn<int>(
    'organizer_top_up',
    aliasedName,
    false,
    check: () => ComparableExpr(organizerTopUp).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _withheldMeta = const VerificationMeta(
    'withheld',
  );
  @override
  late final GeneratedColumn<int> withheld = GeneratedColumn<int>(
    'withheld',
    aliasedName,
    false,
    check: () => ComparableExpr(withheld).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _handedMeta = const VerificationMeta('handed');
  @override
  late final GeneratedColumn<int> handed = GeneratedColumn<int>(
    'handed',
    aliasedName,
    false,
    check: () => ComparableExpr(handed).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PayoutMethod, String> method =
      GeneratedColumn<String>(
        'method',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PayoutMethod>($PayoutsTable.$convertermethod);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tontineId,
    slotId,
    paidOn,
    pot,
    collected,
    organizerTopUp,
    withheld,
    handed,
    method,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payout';
  @override
  VerificationContext validateIntegrity(
    Insertable<PayoutRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tontine_id')) {
      context.handle(
        _tontineIdMeta,
        tontineId.isAcceptableOrUnknown(data['tontine_id']!, _tontineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tontineIdMeta);
    }
    if (data.containsKey('slot_id')) {
      context.handle(
        _slotIdMeta,
        slotId.isAcceptableOrUnknown(data['slot_id']!, _slotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_slotIdMeta);
    }
    if (data.containsKey('paid_on')) {
      context.handle(
        _paidOnMeta,
        paidOn.isAcceptableOrUnknown(data['paid_on']!, _paidOnMeta),
      );
    } else if (isInserting) {
      context.missing(_paidOnMeta);
    }
    if (data.containsKey('pot')) {
      context.handle(
        _potMeta,
        pot.isAcceptableOrUnknown(data['pot']!, _potMeta),
      );
    } else if (isInserting) {
      context.missing(_potMeta);
    }
    if (data.containsKey('collected')) {
      context.handle(
        _collectedMeta,
        collected.isAcceptableOrUnknown(data['collected']!, _collectedMeta),
      );
    } else if (isInserting) {
      context.missing(_collectedMeta);
    }
    if (data.containsKey('organizer_top_up')) {
      context.handle(
        _organizerTopUpMeta,
        organizerTopUp.isAcceptableOrUnknown(
          data['organizer_top_up']!,
          _organizerTopUpMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizerTopUpMeta);
    }
    if (data.containsKey('withheld')) {
      context.handle(
        _withheldMeta,
        withheld.isAcceptableOrUnknown(data['withheld']!, _withheldMeta),
      );
    } else if (isInserting) {
      context.missing(_withheldMeta);
    }
    if (data.containsKey('handed')) {
      context.handle(
        _handedMeta,
        handed.isAcceptableOrUnknown(data['handed']!, _handedMeta),
      );
    } else if (isInserting) {
      context.missing(_handedMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PayoutRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayoutRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tontineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tontine_id'],
      )!,
      slotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot_id'],
      )!,
      paidOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_on'],
      )!,
      pot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pot'],
      )!,
      collected: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collected'],
      )!,
      organizerTopUp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}organizer_top_up'],
      )!,
      withheld: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}withheld'],
      )!,
      handed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}handed'],
      )!,
      method: $PayoutsTable.$convertermethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}method'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PayoutsTable createAlias(String alias) {
    return $PayoutsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PayoutMethod, String, String> $convertermethod =
      const EnumNameConverter<PayoutMethod>(PayoutMethod.values);
}

class PayoutRow extends DataClass implements Insertable<PayoutRow> {
  final String id;
  final String tontineId;
  final String slotId;

  /// Day the pot was handed, `yyyy-mm-dd`.
  final String paidOn;
  final int pot;
  final int collected;
  final int organizerTopUp;
  final int withheld;
  final int handed;
  final PayoutMethod method;
  final DateTime createdAt;
  const PayoutRow({
    required this.id,
    required this.tontineId,
    required this.slotId,
    required this.paidOn,
    required this.pot,
    required this.collected,
    required this.organizerTopUp,
    required this.withheld,
    required this.handed,
    required this.method,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tontine_id'] = Variable<String>(tontineId);
    map['slot_id'] = Variable<String>(slotId);
    map['paid_on'] = Variable<String>(paidOn);
    map['pot'] = Variable<int>(pot);
    map['collected'] = Variable<int>(collected);
    map['organizer_top_up'] = Variable<int>(organizerTopUp);
    map['withheld'] = Variable<int>(withheld);
    map['handed'] = Variable<int>(handed);
    {
      map['method'] = Variable<String>(
        $PayoutsTable.$convertermethod.toSql(method),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PayoutsCompanion toCompanion(bool nullToAbsent) {
    return PayoutsCompanion(
      id: Value(id),
      tontineId: Value(tontineId),
      slotId: Value(slotId),
      paidOn: Value(paidOn),
      pot: Value(pot),
      collected: Value(collected),
      organizerTopUp: Value(organizerTopUp),
      withheld: Value(withheld),
      handed: Value(handed),
      method: Value(method),
      createdAt: Value(createdAt),
    );
  }

  factory PayoutRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayoutRow(
      id: serializer.fromJson<String>(json['id']),
      tontineId: serializer.fromJson<String>(json['tontineId']),
      slotId: serializer.fromJson<String>(json['slotId']),
      paidOn: serializer.fromJson<String>(json['paidOn']),
      pot: serializer.fromJson<int>(json['pot']),
      collected: serializer.fromJson<int>(json['collected']),
      organizerTopUp: serializer.fromJson<int>(json['organizerTopUp']),
      withheld: serializer.fromJson<int>(json['withheld']),
      handed: serializer.fromJson<int>(json['handed']),
      method: $PayoutsTable.$convertermethod.fromJson(
        serializer.fromJson<String>(json['method']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tontineId': serializer.toJson<String>(tontineId),
      'slotId': serializer.toJson<String>(slotId),
      'paidOn': serializer.toJson<String>(paidOn),
      'pot': serializer.toJson<int>(pot),
      'collected': serializer.toJson<int>(collected),
      'organizerTopUp': serializer.toJson<int>(organizerTopUp),
      'withheld': serializer.toJson<int>(withheld),
      'handed': serializer.toJson<int>(handed),
      'method': serializer.toJson<String>(
        $PayoutsTable.$convertermethod.toJson(method),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PayoutRow copyWith({
    String? id,
    String? tontineId,
    String? slotId,
    String? paidOn,
    int? pot,
    int? collected,
    int? organizerTopUp,
    int? withheld,
    int? handed,
    PayoutMethod? method,
    DateTime? createdAt,
  }) => PayoutRow(
    id: id ?? this.id,
    tontineId: tontineId ?? this.tontineId,
    slotId: slotId ?? this.slotId,
    paidOn: paidOn ?? this.paidOn,
    pot: pot ?? this.pot,
    collected: collected ?? this.collected,
    organizerTopUp: organizerTopUp ?? this.organizerTopUp,
    withheld: withheld ?? this.withheld,
    handed: handed ?? this.handed,
    method: method ?? this.method,
    createdAt: createdAt ?? this.createdAt,
  );
  PayoutRow copyWithCompanion(PayoutsCompanion data) {
    return PayoutRow(
      id: data.id.present ? data.id.value : this.id,
      tontineId: data.tontineId.present ? data.tontineId.value : this.tontineId,
      slotId: data.slotId.present ? data.slotId.value : this.slotId,
      paidOn: data.paidOn.present ? data.paidOn.value : this.paidOn,
      pot: data.pot.present ? data.pot.value : this.pot,
      collected: data.collected.present ? data.collected.value : this.collected,
      organizerTopUp: data.organizerTopUp.present
          ? data.organizerTopUp.value
          : this.organizerTopUp,
      withheld: data.withheld.present ? data.withheld.value : this.withheld,
      handed: data.handed.present ? data.handed.value : this.handed,
      method: data.method.present ? data.method.value : this.method,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayoutRow(')
          ..write('id: $id, ')
          ..write('tontineId: $tontineId, ')
          ..write('slotId: $slotId, ')
          ..write('paidOn: $paidOn, ')
          ..write('pot: $pot, ')
          ..write('collected: $collected, ')
          ..write('organizerTopUp: $organizerTopUp, ')
          ..write('withheld: $withheld, ')
          ..write('handed: $handed, ')
          ..write('method: $method, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tontineId,
    slotId,
    paidOn,
    pot,
    collected,
    organizerTopUp,
    withheld,
    handed,
    method,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayoutRow &&
          other.id == this.id &&
          other.tontineId == this.tontineId &&
          other.slotId == this.slotId &&
          other.paidOn == this.paidOn &&
          other.pot == this.pot &&
          other.collected == this.collected &&
          other.organizerTopUp == this.organizerTopUp &&
          other.withheld == this.withheld &&
          other.handed == this.handed &&
          other.method == this.method &&
          other.createdAt == this.createdAt);
}

class PayoutsCompanion extends UpdateCompanion<PayoutRow> {
  final Value<String> id;
  final Value<String> tontineId;
  final Value<String> slotId;
  final Value<String> paidOn;
  final Value<int> pot;
  final Value<int> collected;
  final Value<int> organizerTopUp;
  final Value<int> withheld;
  final Value<int> handed;
  final Value<PayoutMethod> method;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PayoutsCompanion({
    this.id = const Value.absent(),
    this.tontineId = const Value.absent(),
    this.slotId = const Value.absent(),
    this.paidOn = const Value.absent(),
    this.pot = const Value.absent(),
    this.collected = const Value.absent(),
    this.organizerTopUp = const Value.absent(),
    this.withheld = const Value.absent(),
    this.handed = const Value.absent(),
    this.method = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PayoutsCompanion.insert({
    this.id = const Value.absent(),
    required String tontineId,
    required String slotId,
    required String paidOn,
    required int pot,
    required int collected,
    required int organizerTopUp,
    required int withheld,
    required int handed,
    required PayoutMethod method,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tontineId = Value(tontineId),
       slotId = Value(slotId),
       paidOn = Value(paidOn),
       pot = Value(pot),
       collected = Value(collected),
       organizerTopUp = Value(organizerTopUp),
       withheld = Value(withheld),
       handed = Value(handed),
       method = Value(method);
  static Insertable<PayoutRow> custom({
    Expression<String>? id,
    Expression<String>? tontineId,
    Expression<String>? slotId,
    Expression<String>? paidOn,
    Expression<int>? pot,
    Expression<int>? collected,
    Expression<int>? organizerTopUp,
    Expression<int>? withheld,
    Expression<int>? handed,
    Expression<String>? method,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tontineId != null) 'tontine_id': tontineId,
      if (slotId != null) 'slot_id': slotId,
      if (paidOn != null) 'paid_on': paidOn,
      if (pot != null) 'pot': pot,
      if (collected != null) 'collected': collected,
      if (organizerTopUp != null) 'organizer_top_up': organizerTopUp,
      if (withheld != null) 'withheld': withheld,
      if (handed != null) 'handed': handed,
      if (method != null) 'method': method,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PayoutsCompanion copyWith({
    Value<String>? id,
    Value<String>? tontineId,
    Value<String>? slotId,
    Value<String>? paidOn,
    Value<int>? pot,
    Value<int>? collected,
    Value<int>? organizerTopUp,
    Value<int>? withheld,
    Value<int>? handed,
    Value<PayoutMethod>? method,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PayoutsCompanion(
      id: id ?? this.id,
      tontineId: tontineId ?? this.tontineId,
      slotId: slotId ?? this.slotId,
      paidOn: paidOn ?? this.paidOn,
      pot: pot ?? this.pot,
      collected: collected ?? this.collected,
      organizerTopUp: organizerTopUp ?? this.organizerTopUp,
      withheld: withheld ?? this.withheld,
      handed: handed ?? this.handed,
      method: method ?? this.method,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tontineId.present) {
      map['tontine_id'] = Variable<String>(tontineId.value);
    }
    if (slotId.present) {
      map['slot_id'] = Variable<String>(slotId.value);
    }
    if (paidOn.present) {
      map['paid_on'] = Variable<String>(paidOn.value);
    }
    if (pot.present) {
      map['pot'] = Variable<int>(pot.value);
    }
    if (collected.present) {
      map['collected'] = Variable<int>(collected.value);
    }
    if (organizerTopUp.present) {
      map['organizer_top_up'] = Variable<int>(organizerTopUp.value);
    }
    if (withheld.present) {
      map['withheld'] = Variable<int>(withheld.value);
    }
    if (handed.present) {
      map['handed'] = Variable<int>(handed.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(
        $PayoutsTable.$convertermethod.toSql(method.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayoutsCompanion(')
          ..write('id: $id, ')
          ..write('tontineId: $tontineId, ')
          ..write('slotId: $slotId, ')
          ..write('paidOn: $paidOn, ')
          ..write('pot: $pot, ')
          ..write('collected: $collected, ')
          ..write('organizerTopUp: $organizerTopUp, ')
          ..write('withheld: $withheld, ')
          ..write('handed: $handed, ')
          ..write('method: $method, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PayoutCancellationsTable extends PayoutCancellations
    with TableInfo<$PayoutCancellationsTable, PayoutCancellationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayoutCancellationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _payoutIdMeta = const VerificationMeta(
    'payoutId',
  );
  @override
  late final GeneratedColumn<String> payoutId = GeneratedColumn<String>(
    'payout_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES payout (id)',
    ),
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [payoutId, reason, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payout_cancellation';
  @override
  VerificationContext validateIntegrity(
    Insertable<PayoutCancellationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('payout_id')) {
      context.handle(
        _payoutIdMeta,
        payoutId.isAcceptableOrUnknown(data['payout_id']!, _payoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_payoutIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {payoutId};
  @override
  PayoutCancellationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayoutCancellationRow(
      payoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payout_id'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PayoutCancellationsTable createAlias(String alias) {
    return $PayoutCancellationsTable(attachedDatabase, alias);
  }
}

class PayoutCancellationRow extends DataClass
    implements Insertable<PayoutCancellationRow> {
  final String payoutId;
  final String? reason;
  final DateTime createdAt;
  const PayoutCancellationRow({
    required this.payoutId,
    this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['payout_id'] = Variable<String>(payoutId);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PayoutCancellationsCompanion toCompanion(bool nullToAbsent) {
    return PayoutCancellationsCompanion(
      payoutId: Value(payoutId),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory PayoutCancellationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayoutCancellationRow(
      payoutId: serializer.fromJson<String>(json['payoutId']),
      reason: serializer.fromJson<String?>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'payoutId': serializer.toJson<String>(payoutId),
      'reason': serializer.toJson<String?>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PayoutCancellationRow copyWith({
    String? payoutId,
    Value<String?> reason = const Value.absent(),
    DateTime? createdAt,
  }) => PayoutCancellationRow(
    payoutId: payoutId ?? this.payoutId,
    reason: reason.present ? reason.value : this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  PayoutCancellationRow copyWithCompanion(PayoutCancellationsCompanion data) {
    return PayoutCancellationRow(
      payoutId: data.payoutId.present ? data.payoutId.value : this.payoutId,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayoutCancellationRow(')
          ..write('payoutId: $payoutId, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(payoutId, reason, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayoutCancellationRow &&
          other.payoutId == this.payoutId &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class PayoutCancellationsCompanion
    extends UpdateCompanion<PayoutCancellationRow> {
  final Value<String> payoutId;
  final Value<String?> reason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PayoutCancellationsCompanion({
    this.payoutId = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PayoutCancellationsCompanion.insert({
    required String payoutId,
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : payoutId = Value(payoutId);
  static Insertable<PayoutCancellationRow> custom({
    Expression<String>? payoutId,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (payoutId != null) 'payout_id': payoutId,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PayoutCancellationsCompanion copyWith({
    Value<String>? payoutId,
    Value<String?>? reason,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PayoutCancellationsCompanion(
      payoutId: payoutId ?? this.payoutId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (payoutId.present) {
      map['payout_id'] = Variable<String>(payoutId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayoutCancellationsCompanion(')
          ..write('payoutId: $payoutId, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TourSwapsTable extends TourSwaps
    with TableInfo<$TourSwapsTable, TourSwapRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TourSwapsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _tontineIdMeta = const VerificationMeta(
    'tontineId',
  );
  @override
  late final GeneratedColumn<String> tontineId = GeneratedColumn<String>(
    'tontine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tontine (id)',
    ),
  );
  static const VerificationMeta _tourAMeta = const VerificationMeta('tourA');
  @override
  late final GeneratedColumn<int> tourA = GeneratedColumn<int>(
    'tour_a',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tourBMeta = const VerificationMeta('tourB');
  @override
  late final GeneratedColumn<int> tourB = GeneratedColumn<int>(
    'tour_b',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tontineId,
    tourA,
    tourB,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tour_swap';
  @override
  VerificationContext validateIntegrity(
    Insertable<TourSwapRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tontine_id')) {
      context.handle(
        _tontineIdMeta,
        tontineId.isAcceptableOrUnknown(data['tontine_id']!, _tontineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tontineIdMeta);
    }
    if (data.containsKey('tour_a')) {
      context.handle(
        _tourAMeta,
        tourA.isAcceptableOrUnknown(data['tour_a']!, _tourAMeta),
      );
    } else if (isInserting) {
      context.missing(_tourAMeta);
    }
    if (data.containsKey('tour_b')) {
      context.handle(
        _tourBMeta,
        tourB.isAcceptableOrUnknown(data['tour_b']!, _tourBMeta),
      );
    } else if (isInserting) {
      context.missing(_tourBMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TourSwapRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TourSwapRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tontineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tontine_id'],
      )!,
      tourA: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tour_a'],
      )!,
      tourB: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tour_b'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TourSwapsTable createAlias(String alias) {
    return $TourSwapsTable(attachedDatabase, alias);
  }
}

class TourSwapRow extends DataClass implements Insertable<TourSwapRow> {
  final String id;
  final String tontineId;
  final int tourA;
  final int tourB;
  final DateTime createdAt;
  const TourSwapRow({
    required this.id,
    required this.tontineId,
    required this.tourA,
    required this.tourB,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tontine_id'] = Variable<String>(tontineId);
    map['tour_a'] = Variable<int>(tourA);
    map['tour_b'] = Variable<int>(tourB);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TourSwapsCompanion toCompanion(bool nullToAbsent) {
    return TourSwapsCompanion(
      id: Value(id),
      tontineId: Value(tontineId),
      tourA: Value(tourA),
      tourB: Value(tourB),
      createdAt: Value(createdAt),
    );
  }

  factory TourSwapRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TourSwapRow(
      id: serializer.fromJson<String>(json['id']),
      tontineId: serializer.fromJson<String>(json['tontineId']),
      tourA: serializer.fromJson<int>(json['tourA']),
      tourB: serializer.fromJson<int>(json['tourB']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tontineId': serializer.toJson<String>(tontineId),
      'tourA': serializer.toJson<int>(tourA),
      'tourB': serializer.toJson<int>(tourB),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TourSwapRow copyWith({
    String? id,
    String? tontineId,
    int? tourA,
    int? tourB,
    DateTime? createdAt,
  }) => TourSwapRow(
    id: id ?? this.id,
    tontineId: tontineId ?? this.tontineId,
    tourA: tourA ?? this.tourA,
    tourB: tourB ?? this.tourB,
    createdAt: createdAt ?? this.createdAt,
  );
  TourSwapRow copyWithCompanion(TourSwapsCompanion data) {
    return TourSwapRow(
      id: data.id.present ? data.id.value : this.id,
      tontineId: data.tontineId.present ? data.tontineId.value : this.tontineId,
      tourA: data.tourA.present ? data.tourA.value : this.tourA,
      tourB: data.tourB.present ? data.tourB.value : this.tourB,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TourSwapRow(')
          ..write('id: $id, ')
          ..write('tontineId: $tontineId, ')
          ..write('tourA: $tourA, ')
          ..write('tourB: $tourB, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tontineId, tourA, tourB, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TourSwapRow &&
          other.id == this.id &&
          other.tontineId == this.tontineId &&
          other.tourA == this.tourA &&
          other.tourB == this.tourB &&
          other.createdAt == this.createdAt);
}

class TourSwapsCompanion extends UpdateCompanion<TourSwapRow> {
  final Value<String> id;
  final Value<String> tontineId;
  final Value<int> tourA;
  final Value<int> tourB;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TourSwapsCompanion({
    this.id = const Value.absent(),
    this.tontineId = const Value.absent(),
    this.tourA = const Value.absent(),
    this.tourB = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TourSwapsCompanion.insert({
    this.id = const Value.absent(),
    required String tontineId,
    required int tourA,
    required int tourB,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tontineId = Value(tontineId),
       tourA = Value(tourA),
       tourB = Value(tourB);
  static Insertable<TourSwapRow> custom({
    Expression<String>? id,
    Expression<String>? tontineId,
    Expression<int>? tourA,
    Expression<int>? tourB,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tontineId != null) 'tontine_id': tontineId,
      if (tourA != null) 'tour_a': tourA,
      if (tourB != null) 'tour_b': tourB,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TourSwapsCompanion copyWith({
    Value<String>? id,
    Value<String>? tontineId,
    Value<int>? tourA,
    Value<int>? tourB,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TourSwapsCompanion(
      id: id ?? this.id,
      tontineId: tontineId ?? this.tontineId,
      tourA: tourA ?? this.tourA,
      tourB: tourB ?? this.tourB,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tontineId.present) {
      map['tontine_id'] = Variable<String>(tontineId.value);
    }
    if (tourA.present) {
      map['tour_a'] = Variable<int>(tourA.value);
    }
    if (tourB.present) {
      map['tour_b'] = Variable<int>(tourB.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TourSwapsCompanion(')
          ..write('id: $id, ')
          ..write('tontineId: $tontineId, ')
          ..write('tourA: $tourA, ')
          ..write('tourB: $tourB, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $TontinesTable tontines = $TontinesTable(this);
  late final $MembersTable members = $MembersTable(this);
  late final $SlotsTable slots = $SlotsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $PaymentCancellationsTable paymentCancellations =
      $PaymentCancellationsTable(this);
  late final $PayoutsTable payouts = $PayoutsTable(this);
  late final $PayoutCancellationsTable payoutCancellations =
      $PayoutCancellationsTable(this);
  late final $TourSwapsTable tourSwaps = $TourSwapsTable(this);
  late final Index memberTontine = Index(
    'member_tontine',
    'CREATE INDEX member_tontine ON member (tontine_id)',
  );
  late final Index slotTontineTour = Index(
    'slot_tontine_tour',
    'CREATE INDEX slot_tontine_tour ON slot (tontine_id, tour)',
  );
  late final Index paymentMember = Index(
    'payment_member',
    'CREATE INDEX payment_member ON payment (member_id)',
  );
  late final Index paymentTontineDay = Index(
    'payment_tontine_day',
    'CREATE INDEX payment_tontine_day ON payment (tontine_id, paid_on)',
  );
  late final Index payoutTontine = Index(
    'payout_tontine',
    'CREATE INDEX payout_tontine ON payout (tontine_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    tontines,
    members,
    slots,
    payments,
    paymentCancellations,
    payouts,
    payoutCancellations,
    tourSwaps,
    memberTontine,
    slotTontineTour,
    paymentMember,
    paymentTontineDay,
    payoutTontine,
  ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  required String username,
  required Uint8List passwordHash,
  required Uint8List passwordSalt,
  required Uint8List recoveryCodeHash,
  required Uint8List recoveryCodeSalt,
  required int iterations,
  Value<int> failures,
  Value<DateTime?> lockedUntil,
  Value<int> lockouts,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> username,
  Value<Uint8List> passwordHash,
  Value<Uint8List> passwordSalt,
  Value<Uint8List> recoveryCodeHash,
  Value<Uint8List> recoveryCodeSalt,
  Value<int> iterations,
  Value<int> failures,
  Value<DateTime?> lockedUntil,
  Value<int> lockouts,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get recoveryCodeHash => $composableBuilder(
    column: $table.recoveryCodeHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get recoveryCodeSalt => $composableBuilder(
    column: $table.recoveryCodeSalt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iterations => $composableBuilder(
    column: $table.iterations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failures => $composableBuilder(
    column: $table.failures,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lockouts => $composableBuilder(
    column: $table.lockouts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get recoveryCodeHash => $composableBuilder(
    column: $table.recoveryCodeHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get recoveryCodeSalt => $composableBuilder(
    column: $table.recoveryCodeSalt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iterations => $composableBuilder(
    column: $table.iterations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failures => $composableBuilder(
    column: $table.failures,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lockouts => $composableBuilder(
    column: $table.lockouts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<Uint8List> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get recoveryCodeHash => $composableBuilder(
    column: $table.recoveryCodeHash,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get recoveryCodeSalt => $composableBuilder(
    column: $table.recoveryCodeSalt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get iterations => $composableBuilder(
    column: $table.iterations,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failures =>
      $composableBuilder(column: $table.failures, builder: (column) => column);

  GeneratedColumn<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lockouts =>
      $composableBuilder(column: $table.lockouts, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
          Account,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<Uint8List> passwordHash = const Value.absent(),
                Value<Uint8List> passwordSalt = const Value.absent(),
                Value<Uint8List> recoveryCodeHash = const Value.absent(),
                Value<Uint8List> recoveryCodeSalt = const Value.absent(),
                Value<int> iterations = const Value.absent(),
                Value<int> failures = const Value.absent(),
                Value<DateTime?> lockedUntil = const Value.absent(),
                Value<int> lockouts = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                username: username,
                passwordHash: passwordHash,
                passwordSalt: passwordSalt,
                recoveryCodeHash: recoveryCodeHash,
                recoveryCodeSalt: recoveryCodeSalt,
                iterations: iterations,
                failures: failures,
                lockedUntil: lockedUntil,
                lockouts: lockouts,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String username,
                required Uint8List passwordHash,
                required Uint8List passwordSalt,
                required Uint8List recoveryCodeHash,
                required Uint8List recoveryCodeSalt,
                required int iterations,
                Value<int> failures = const Value.absent(),
                Value<DateTime?> lockedUntil = const Value.absent(),
                Value<int> lockouts = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                username: username,
                passwordHash: passwordHash,
                passwordSalt: passwordSalt,
                recoveryCodeHash: recoveryCodeHash,
                recoveryCodeSalt: recoveryCodeSalt,
                iterations: iterations,
                failures: failures,
                lockedUntil: lockedUntil,
                lockouts: lockouts,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, Account>(table),
                  BaseReferences<_$AppDatabase, $AccountsTable, Account>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
      Account,
      PrefetchHooks Function()
    >;
typedef $$TontinesTableCreateCompanionBuilder = TontinesCompanion Function({
  Value<String> id,
  required String name,
  required int places,
  required int contributionPerPlace,
  required int tourDays,
  required String firstDay,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$TontinesTableUpdateCompanionBuilder = TontinesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> places,
  Value<int> contributionPerPlace,
  Value<int> tourDays,
  Value<String> firstDay,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$TontinesTableReferences
    extends BaseReferences<_$AppDatabase, $TontinesTable, TontineRow> {
  $$TontinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MembersTable, List<MemberRow>> _membersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.members,
    aliasName: 'tontine__id__member__tontine_id',
  );

  $$MembersTableProcessedTableManager get membersRefs {
    final manager = $$MembersTableTableManager(
      $_db,
      $_db.members,
    ).filter((f) => f.tontineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_membersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SlotsTable, List<SlotRow>> _slotsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.slots,
    aliasName: 'tontine__id__slot__tontine_id',
  );

  $$SlotsTableProcessedTableManager get slotsRefs {
    final manager = $$SlotsTableTableManager(
      $_db,
      $_db.slots,
    ).filter((f) => f.tontineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_slotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<PaymentRow>>
  _paymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'tontine__id__payment__tontine_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.tontineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PayoutsTable, List<PayoutRow>> _payoutsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payouts,
    aliasName: 'tontine__id__payout__tontine_id',
  );

  $$PayoutsTableProcessedTableManager get payoutsRefs {
    final manager = $$PayoutsTableTableManager(
      $_db,
      $_db.payouts,
    ).filter((f) => f.tontineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_payoutsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TourSwapsTable, List<TourSwapRow>>
  _tourSwapsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tourSwaps,
    aliasName: 'tontine__id__tour_swap__tontine_id',
  );

  $$TourSwapsTableProcessedTableManager get tourSwapsRefs {
    final manager = $$TourSwapsTableTableManager(
      $_db,
      $_db.tourSwaps,
    ).filter((f) => f.tontineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tourSwapsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TontinesTableFilterComposer
    extends Composer<_$AppDatabase, $TontinesTable> {
  $$TontinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get places => $composableBuilder(
    column: $table.places,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contributionPerPlace => $composableBuilder(
    column: $table.contributionPerPlace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tourDays => $composableBuilder(
    column: $table.tourDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstDay => $composableBuilder(
    column: $table.firstDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> membersRefs(
    Expression<bool> Function($$MembersTableFilterComposer f) f,
  ) {
    final $$MembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.tontineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableFilterComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> slotsRefs(
    Expression<bool> Function($$SlotsTableFilterComposer f) f,
  ) {
    final $$SlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.slots,
      getReferencedColumn: (t) => t.tontineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SlotsTableFilterComposer(
            $db: $db,
            $table: $db.slots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.tontineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> payoutsRefs(
    Expression<bool> Function($$PayoutsTableFilterComposer f) f,
  ) {
    final $$PayoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payouts,
      getReferencedColumn: (t) => t.tontineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayoutsTableFilterComposer(
            $db: $db,
            $table: $db.payouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tourSwapsRefs(
    Expression<bool> Function($$TourSwapsTableFilterComposer f) f,
  ) {
    final $$TourSwapsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tourSwaps,
      getReferencedColumn: (t) => t.tontineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TourSwapsTableFilterComposer(
            $db: $db,
            $table: $db.tourSwaps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TontinesTableOrderingComposer
    extends Composer<_$AppDatabase, $TontinesTable> {
  $$TontinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get places => $composableBuilder(
    column: $table.places,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contributionPerPlace => $composableBuilder(
    column: $table.contributionPerPlace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tourDays => $composableBuilder(
    column: $table.tourDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstDay => $composableBuilder(
    column: $table.firstDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TontinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TontinesTable> {
  $$TontinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get places =>
      $composableBuilder(column: $table.places, builder: (column) => column);

  GeneratedColumn<int> get contributionPerPlace => $composableBuilder(
    column: $table.contributionPerPlace,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tourDays =>
      $composableBuilder(column: $table.tourDays, builder: (column) => column);

  GeneratedColumn<String> get firstDay =>
      $composableBuilder(column: $table.firstDay, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> membersRefs<T extends Object>(
    Expression<T> Function($$MembersTableAnnotationComposer a) f,
  ) {
    final $$MembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.tontineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableAnnotationComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> slotsRefs<T extends Object>(
    Expression<T> Function($$SlotsTableAnnotationComposer a) f,
  ) {
    final $$SlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.slots,
      getReferencedColumn: (t) => t.tontineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.slots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.tontineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> payoutsRefs<T extends Object>(
    Expression<T> Function($$PayoutsTableAnnotationComposer a) f,
  ) {
    final $$PayoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payouts,
      getReferencedColumn: (t) => t.tontineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.payouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tourSwapsRefs<T extends Object>(
    Expression<T> Function($$TourSwapsTableAnnotationComposer a) f,
  ) {
    final $$TourSwapsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tourSwaps,
      getReferencedColumn: (t) => t.tontineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TourSwapsTableAnnotationComposer(
            $db: $db,
            $table: $db.tourSwaps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TontinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TontinesTable,
          TontineRow,
          $$TontinesTableFilterComposer,
          $$TontinesTableOrderingComposer,
          $$TontinesTableAnnotationComposer,
          $$TontinesTableCreateCompanionBuilder,
          $$TontinesTableUpdateCompanionBuilder,
          (TontineRow, $$TontinesTableReferences),
          TontineRow,
          PrefetchHooks Function({
            bool membersRefs,
            bool slotsRefs,
            bool paymentsRefs,
            bool payoutsRefs,
            bool tourSwapsRefs,
          })
        > {
  $$TontinesTableTableManager(_$AppDatabase db, $TontinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TontinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TontinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TontinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> places = const Value.absent(),
                Value<int> contributionPerPlace = const Value.absent(),
                Value<int> tourDays = const Value.absent(),
                Value<String> firstDay = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TontinesCompanion(
                id: id,
                name: name,
                places: places,
                contributionPerPlace: contributionPerPlace,
                tourDays: tourDays,
                firstDay: firstDay,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required int places,
                required int contributionPerPlace,
                required int tourDays,
                required String firstDay,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TontinesCompanion.insert(
                id: id,
                name: name,
                places: places,
                contributionPerPlace: contributionPerPlace,
                tourDays: tourDays,
                firstDay: firstDay,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TontinesTable, TontineRow>(table),
                  $$TontinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                membersRefs = false,
                slotsRefs = false,
                paymentsRefs = false,
                payoutsRefs = false,
                tourSwapsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (membersRefs) db.members,
                    if (slotsRefs) db.slots,
                    if (paymentsRefs) db.payments,
                    if (payoutsRefs) db.payouts,
                    if (tourSwapsRefs) db.tourSwaps,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (membersRefs)
                        await $_getPrefetchedDataByColumns<
                          TontineRow,
                          $TontinesTable,
                          MemberRow,
                          $MembersTable
                        >(
                          currentTable: table,
                          referencedTable: $$TontinesTableReferences
                              ._membersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TontinesTableReferences(
                                db,
                                table,
                                p0,
                              ).membersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'tontine_id',
                          typedResults: items,
                        ),
                      if (slotsRefs)
                        await $_getPrefetchedDataByColumns<
                          TontineRow,
                          $TontinesTable,
                          SlotRow,
                          $SlotsTable
                        >(
                          currentTable: table,
                          referencedTable: $$TontinesTableReferences
                              ._slotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TontinesTableReferences(
                                db,
                                table,
                                p0,
                              ).slotsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'tontine_id',
                          typedResults: items,
                        ),
                      if (paymentsRefs)
                        await $_getPrefetchedDataByColumns<
                          TontineRow,
                          $TontinesTable,
                          PaymentRow,
                          $PaymentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$TontinesTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TontinesTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'tontine_id',
                          typedResults: items,
                        ),
                      if (payoutsRefs)
                        await $_getPrefetchedDataByColumns<
                          TontineRow,
                          $TontinesTable,
                          PayoutRow,
                          $PayoutsTable
                        >(
                          currentTable: table,
                          referencedTable: $$TontinesTableReferences
                              ._payoutsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TontinesTableReferences(
                                db,
                                table,
                                p0,
                              ).payoutsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'tontine_id',
                          typedResults: items,
                        ),
                      if (tourSwapsRefs)
                        await $_getPrefetchedDataByColumns<
                          TontineRow,
                          $TontinesTable,
                          TourSwapRow,
                          $TourSwapsTable
                        >(
                          currentTable: table,
                          referencedTable: $$TontinesTableReferences
                              ._tourSwapsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TontinesTableReferences(
                                db,
                                table,
                                p0,
                              ).tourSwapsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'tontine_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TontinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TontinesTable,
      TontineRow,
      $$TontinesTableFilterComposer,
      $$TontinesTableOrderingComposer,
      $$TontinesTableAnnotationComposer,
      $$TontinesTableCreateCompanionBuilder,
      $$TontinesTableUpdateCompanionBuilder,
      (TontineRow, $$TontinesTableReferences),
      TontineRow,
      PrefetchHooks Function({
        bool membersRefs,
        bool slotsRefs,
        bool paymentsRefs,
        bool payoutsRefs,
        bool tourSwapsRefs,
      })
    >;
typedef $$MembersTableCreateCompanionBuilder = MembersCompanion Function({
  Value<String> id,
  required String tontineId,
  required String name,
  Value<String?> phone,
  required int position,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$MembersTableUpdateCompanionBuilder = MembersCompanion Function({
  Value<String> id,
  Value<String> tontineId,
  Value<String> name,
  Value<String?> phone,
  Value<int> position,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$MembersTableReferences
    extends BaseReferences<_$AppDatabase, $MembersTable, MemberRow> {
  $$MembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TontinesTable _tontineIdTable(_$AppDatabase db) =>
      db.tontines.createAlias('member__tontine_id__tontine__id');

  $$TontinesTableProcessedTableManager get tontineId {
    final $_column = $_itemColumn<String>('tontine_id')!;

    final manager = $$TontinesTableTableManager(
      $_db,
      $_db.tontines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tontineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SlotsTable, List<SlotRow>> _slotsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.slots,
    aliasName: 'member__id__slot__member_id',
  );

  $$SlotsTableProcessedTableManager get slotsRefs {
    final manager = $$SlotsTableTableManager(
      $_db,
      $_db.slots,
    ).filter((f) => f.memberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_slotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<PaymentRow>>
  _paymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'member__id__payment__member_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.memberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MembersTableFilterComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TontinesTableFilterComposer get tontineId {
    final $$TontinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tontineId,
      referencedTable: $db.tontines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TontinesTableFilterComposer(
            $db: $db,
            $table: $db.tontines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> slotsRefs(
    Expression<bool> Function($$SlotsTableFilterComposer f) f,
  ) {
    final $$SlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.slots,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SlotsTableFilterComposer(
            $db: $db,
            $table: $db.slots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TontinesTableOrderingComposer get tontineId {
    final $$TontinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tontineId,
      referencedTable: $db.tontines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TontinesTableOrderingComposer(
            $db: $db,
            $table: $db.tontines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TontinesTableAnnotationComposer get tontineId {
    final $$TontinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tontineId,
      referencedTable: $db.tontines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TontinesTableAnnotationComposer(
            $db: $db,
            $table: $db.tontines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> slotsRefs<T extends Object>(
    Expression<T> Function($$SlotsTableAnnotationComposer a) f,
  ) {
    final $$SlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.slots,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.slots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MembersTable,
          MemberRow,
          $$MembersTableFilterComposer,
          $$MembersTableOrderingComposer,
          $$MembersTableAnnotationComposer,
          $$MembersTableCreateCompanionBuilder,
          $$MembersTableUpdateCompanionBuilder,
          (MemberRow, $$MembersTableReferences),
          MemberRow,
          PrefetchHooks Function({
            bool tontineId,
            bool slotsRefs,
            bool paymentsRefs,
          })
        > {
  $$MembersTableTableManager(_$AppDatabase db, $MembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tontineId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion(
                id: id,
                tontineId: tontineId,
                name: name,
                phone: phone,
                position: position,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String tontineId,
                required String name,
                Value<String?> phone = const Value.absent(),
                required int position,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion.insert(
                id: id,
                tontineId: tontineId,
                name: name,
                phone: phone,
                position: position,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MembersTable, MemberRow>(table),
                  $$MembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({tontineId = false, slotsRefs = false, paymentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (slotsRefs) db.slots,
                    if (paymentsRefs) db.payments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tontineId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.tontineId,
                            referencedTable: $$MembersTableReferences
                                ._tontineIdTable(db),
                            referencedColumn: $$MembersTableReferences
                                ._tontineIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (slotsRefs)
                        await $_getPrefetchedDataByColumns<
                          MemberRow,
                          $MembersTable,
                          SlotRow,
                          $SlotsTable
                        >(
                          currentTable: table,
                          referencedTable: $$MembersTableReferences
                              ._slotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MembersTableReferences(db, table, p0).slotsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'member_id',
                          typedResults: items,
                        ),
                      if (paymentsRefs)
                        await $_getPrefetchedDataByColumns<
                          MemberRow,
                          $MembersTable,
                          PaymentRow,
                          $PaymentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$MembersTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MembersTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'member_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MembersTable,
      MemberRow,
      $$MembersTableFilterComposer,
      $$MembersTableOrderingComposer,
      $$MembersTableAnnotationComposer,
      $$MembersTableCreateCompanionBuilder,
      $$MembersTableUpdateCompanionBuilder,
      (MemberRow, $$MembersTableReferences),
      MemberRow,
      PrefetchHooks Function({
        bool tontineId,
        bool slotsRefs,
        bool paymentsRefs,
      })
    >;
typedef $$SlotsTableCreateCompanionBuilder = SlotsCompanion Function({
  Value<String> id,
  required String tontineId,
  required int tour,
  required String memberId,
  required int halves,
  Value<int> rowid,
});
typedef $$SlotsTableUpdateCompanionBuilder = SlotsCompanion Function({
  Value<String> id,
  Value<String> tontineId,
  Value<int> tour,
  Value<String> memberId,
  Value<int> halves,
  Value<int> rowid,
});

final class $$SlotsTableReferences
    extends BaseReferences<_$AppDatabase, $SlotsTable, SlotRow> {
  $$SlotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TontinesTable _tontineIdTable(_$AppDatabase db) =>
      db.tontines.createAlias('slot__tontine_id__tontine__id');

  $$TontinesTableProcessedTableManager get tontineId {
    final $_column = $_itemColumn<String>('tontine_id')!;

    final manager = $$TontinesTableTableManager(
      $_db,
      $_db.tontines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tontineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MembersTable _memberIdTable(_$AppDatabase db) =>
      db.members.createAlias('slot__member_id__member__id');

  $$MembersTableProcessedTableManager get memberId {
    final $_column = $_itemColumn<String>('member_id')!;

    final manager = $$MembersTableTableManager(
      $_db,
      $_db.members,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PayoutsTable, List<PayoutRow>> _payoutsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payouts,
    aliasName: 'slot__id__payout__slot_id',
  );

  $$PayoutsTableProcessedTableManager get payoutsRefs {
    final manager = $$PayoutsTableTableManager(
      $_db,
      $_db.payouts,
    ).filter((f) => f.slotId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_payoutsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SlotsTableFilterComposer extends Composer<_$AppDatabase, $SlotsTable> {
  $$SlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tour => $composableBuilder(
    column: $table.tour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get halves => $composableBuilder(
    column: $table.halves,
    builder: (column) => ColumnFilters(column),
  );

  $$TontinesTableFilterComposer get tontineId {
    final $$TontinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tontineId,
      referencedTable: $db.tontines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TontinesTableFilterComposer(
            $db: $db,
            $table: $db.tontines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableFilterComposer get memberId {
    final $$MembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableFilterComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> payoutsRefs(
    Expression<bool> Function($$PayoutsTableFilterComposer f) f,
  ) {
    final $$PayoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payouts,
      getReferencedColumn: (t) => t.slotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayoutsTableFilterComposer(
            $db: $db,
            $table: $db.payouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $SlotsTable> {
  $$SlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tour => $composableBuilder(
    column: $table.tour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get halves => $composableBuilder(
    column: $table.halves,
    builder: (column) => ColumnOrderings(column),
  );

  $$TontinesTableOrderingComposer get tontineId {
    final $$TontinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tontineId,
      referencedTable: $db.tontines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TontinesTableOrderingComposer(
            $db: $db,
            $table: $db.tontines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableOrderingComposer get memberId {
    final $$MembersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableOrderingComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SlotsTable> {
  $$SlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tour =>
      $composableBuilder(column: $table.tour, builder: (column) => column);

  GeneratedColumn<int> get halves =>
      $composableBuilder(column: $table.halves, builder: (column) => column);

  $$TontinesTableAnnotationComposer get tontineId {
    final $$TontinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tontineId,
      referencedTable: $db.tontines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TontinesTableAnnotationComposer(
            $db: $db,
            $table: $db.tontines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableAnnotationComposer get memberId {
    final $$MembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableAnnotationComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> payoutsRefs<T extends Object>(
    Expression<T> Function($$PayoutsTableAnnotationComposer a) f,
  ) {
    final $$PayoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payouts,
      getReferencedColumn: (t) => t.slotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.payouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SlotsTable,
          SlotRow,
          $$SlotsTableFilterComposer,
          $$SlotsTableOrderingComposer,
          $$SlotsTableAnnotationComposer,
          $$SlotsTableCreateCompanionBuilder,
          $$SlotsTableUpdateCompanionBuilder,
          (SlotRow, $$SlotsTableReferences),
          SlotRow,
          PrefetchHooks Function({
            bool tontineId,
            bool memberId,
            bool payoutsRefs,
          })
        > {
  $$SlotsTableTableManager(_$AppDatabase db, $SlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tontineId = const Value.absent(),
                Value<int> tour = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<int> halves = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SlotsCompanion(
                id: id,
                tontineId: tontineId,
                tour: tour,
                memberId: memberId,
                halves: halves,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String tontineId,
                required int tour,
                required String memberId,
                required int halves,
                Value<int> rowid = const Value.absent(),
              }) => SlotsCompanion.insert(
                id: id,
                tontineId: tontineId,
                tour: tour,
                memberId: memberId,
                halves: halves,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SlotsTable, SlotRow>(table),
                  $$SlotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({tontineId = false, memberId = false, payoutsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (payoutsRefs) db.payouts],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tontineId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.tontineId,
                            referencedTable: $$SlotsTableReferences
                                ._tontineIdTable(db),
                            referencedColumn: $$SlotsTableReferences
                                ._tontineIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (memberId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.memberId,
                            referencedTable: $$SlotsTableReferences
                                ._memberIdTable(db),
                            referencedColumn: $$SlotsTableReferences
                                ._memberIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (payoutsRefs)
                        await $_getPrefetchedDataByColumns<
                          SlotRow,
                          $SlotsTable,
                          PayoutRow,
                          $PayoutsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SlotsTableReferences
                              ._payoutsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SlotsTableReferences(db, table, p0).payoutsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'slot_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SlotsTable,
      SlotRow,
      $$SlotsTableFilterComposer,
      $$SlotsTableOrderingComposer,
      $$SlotsTableAnnotationComposer,
      $$SlotsTableCreateCompanionBuilder,
      $$SlotsTableUpdateCompanionBuilder,
      (SlotRow, $$SlotsTableReferences),
      SlotRow,
      PrefetchHooks Function({bool tontineId, bool memberId, bool payoutsRefs})
    >;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  Value<String> id,
  required String tontineId,
  required String memberId,
  required int amount,
  required PaymentMethod method,
  required String paidOn,
  Value<String?> payoutId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String> id,
  Value<String> tontineId,
  Value<String> memberId,
  Value<int> amount,
  Value<PaymentMethod> method,
  Value<String> paidOn,
  Value<String?> payoutId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, PaymentRow> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TontinesTable _tontineIdTable(_$AppDatabase db) =>
      db.tontines.createAlias('payment__tontine_id__tontine__id');

  $$TontinesTableProcessedTableManager get tontineId {
    final $_column = $_itemColumn<String>('tontine_id')!;

    final manager = $$TontinesTableTableManager(
      $_db,
      $_db.tontines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tontineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MembersTable _memberIdTable(_$AppDatabase db) =>
      db.members.createAlias('payment__member_id__member__id');

  $$MembersTableProcessedTableManager get memberId {
    final $_column = $_itemColumn<String>('member_id')!;

    final manager = $$MembersTableTableManager(
      $_db,
      $_db.members,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PaymentCancellationsTable,
    List<PaymentCancellationRow>
  >
  _paymentCancellationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.paymentCancellations,
        aliasName: 'payment__id__payment_cancellation__payment_id',
      );

  $$PaymentCancellationsTableProcessedTableManager
  get paymentCancellationsRefs {
    final manager = $$PaymentCancellationsTableTableManager(
      $_db,
      $_db.paymentCancellations,
    ).filter((f) => f.paymentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _paymentCancellationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentMethod, PaymentMethod, String>
  get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get paidOn => $composableBuilder(
    column: $table.paidOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payoutId => $composableBuilder(
    column: $table.payoutId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TontinesTableFilterComposer get tontineId {
    final $$TontinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tontineId,
      referencedTable: $db.tontines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TontinesTableFilterComposer(
            $db: $db,
            $table: $db.tontines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableFilterComposer get memberId {
    final $$MembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableFilterComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentCancellationsRefs(
    Expression<bool> Function($$PaymentCancellationsTableFilterComposer f) f,
  ) {
    final $$PaymentCancellationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentCancellations,
      getReferencedColumn: (t) => t.paymentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentCancellationsTableFilterComposer(
            $db: $db,
            $table: $db.paymentCancellations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paidOn => $composableBuilder(
    column: $table.paidOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payoutId => $composableBuilder(
    column: $table.payoutId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TontinesTableOrderingComposer get tontineId {
    final $$TontinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tontineId,
      referencedTable: $db.tontines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TontinesTableOrderingComposer(
            $db: $db,
            $table: $db.tontines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableOrderingComposer get memberId {
    final $$MembersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableOrderingComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMethod, String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get paidOn =>
      $composableBuilder(column: $table.paidOn, builder: (column) => column);

  GeneratedColumn<String> get payoutId =>
      $composableBuilder(column: $table.payoutId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TontinesTableAnnotationComposer get tontineId {
    final $$TontinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tontineId,
      referencedTable: $db.tontines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TontinesTableAnnotationComposer(
            $db: $db,
            $table: $db.tontines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableAnnotationComposer get memberId {
    final $$MembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableAnnotationComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentCancellationsRefs<T extends Object>(
    Expression<T> Function($$PaymentCancellationsTableAnnotationComposer a) f,
  ) {
    final $$PaymentCancellationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.paymentCancellations,
          getReferencedColumn: (t) => t.paymentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PaymentCancellationsTableAnnotationComposer(
                $db: $db,
                $table: $db.paymentCancellations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          PaymentRow,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (PaymentRow, $$PaymentsTableReferences),
          PaymentRow,
          PrefetchHooks Function({
            bool tontineId,
            bool memberId,
            bool paymentCancellationsRefs,
          })
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tontineId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<PaymentMethod> method = const Value.absent(),
                Value<String> paidOn = const Value.absent(),
                Value<String?> payoutId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                tontineId: tontineId,
                memberId: memberId,
                amount: amount,
                method: method,
                paidOn: paidOn,
                payoutId: payoutId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String tontineId,
                required String memberId,
                required int amount,
                required PaymentMethod method,
                required String paidOn,
                Value<String?> payoutId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                tontineId: tontineId,
                memberId: memberId,
                amount: amount,
                method: method,
                paidOn: paidOn,
                payoutId: payoutId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentsTable, PaymentRow>(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tontineId = false,
                memberId = false,
                paymentCancellationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentCancellationsRefs) db.paymentCancellations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tontineId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.tontineId,
                            referencedTable: $$PaymentsTableReferences
                                ._tontineIdTable(db),
                            referencedColumn: $$PaymentsTableReferences
                                ._tontineIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (memberId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.memberId,
                            referencedTable: $$PaymentsTableReferences
                                ._memberIdTable(db),
                            referencedColumn: $$PaymentsTableReferences
                                ._memberIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentCancellationsRefs)
                        await $_getPrefetchedDataByColumns<
                          PaymentRow,
                          $PaymentsTable,
                          PaymentCancellationRow,
                          $PaymentCancellationsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PaymentsTableReferences
                              ._paymentCancellationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PaymentsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentCancellationsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'payment_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      PaymentRow,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (PaymentRow, $$PaymentsTableReferences),
      PaymentRow,
      PrefetchHooks Function({
        bool tontineId,
        bool memberId,
        bool paymentCancellationsRefs,
      })
    >;
typedef $$PaymentCancellationsTableCreateCompanionBuilder =
    PaymentCancellationsCompanion Function({
      required String paymentId,
      Value<String?> reason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$PaymentCancellationsTableUpdateCompanionBuilder =
    PaymentCancellationsCompanion Function({
      Value<String> paymentId,
      Value<String?> reason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PaymentCancellationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PaymentCancellationsTable,
          PaymentCancellationRow
        > {
  $$PaymentCancellationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PaymentsTable _paymentIdTable(_$AppDatabase db) =>
      db.payments.createAlias('payment_cancellation__payment_id__payment__id');

  $$PaymentsTableProcessedTableManager get paymentId {
    final $_column = $_itemColumn<String>('payment_id')!;

    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentCancellationsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentCancellationsTable> {
  $$PaymentCancellationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PaymentsTableFilterComposer get paymentId {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentCancellationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentCancellationsTable> {
  $$PaymentCancellationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PaymentsTableOrderingComposer get paymentId {
    final $$PaymentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableOrderingComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentCancellationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentCancellationsTable> {
  $$PaymentCancellationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PaymentsTableAnnotationComposer get paymentId {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentCancellationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentCancellationsTable,
          PaymentCancellationRow,
          $$PaymentCancellationsTableFilterComposer,
          $$PaymentCancellationsTableOrderingComposer,
          $$PaymentCancellationsTableAnnotationComposer,
          $$PaymentCancellationsTableCreateCompanionBuilder,
          $$PaymentCancellationsTableUpdateCompanionBuilder,
          (PaymentCancellationRow, $$PaymentCancellationsTableReferences),
          PaymentCancellationRow,
          PrefetchHooks Function({bool paymentId})
        > {
  $$PaymentCancellationsTableTableManager(
    _$AppDatabase db,
    $PaymentCancellationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentCancellationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentCancellationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PaymentCancellationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> paymentId = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentCancellationsCompanion(
                paymentId: paymentId,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String paymentId,
                Value<String?> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentCancellationsCompanion.insert(
                paymentId: paymentId,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $PaymentCancellationsTable,
                    PaymentCancellationRow
                  >(table),
                  $$PaymentCancellationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({paymentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (paymentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.paymentId,
                        referencedTable: $$PaymentCancellationsTableReferences
                            ._paymentIdTable(db),
                        referencedColumn: $$PaymentCancellationsTableReferences
                            ._paymentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentCancellationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentCancellationsTable,
      PaymentCancellationRow,
      $$PaymentCancellationsTableFilterComposer,
      $$PaymentCancellationsTableOrderingComposer,
      $$PaymentCancellationsTableAnnotationComposer,
      $$PaymentCancellationsTableCreateCompanionBuilder,
      $$PaymentCancellationsTableUpdateCompanionBuilder,
      (PaymentCancellationRow, $$PaymentCancellationsTableReferences),
      PaymentCancellationRow,
      PrefetchHooks Function({bool paymentId})
    >;
typedef $$PayoutsTableCreateCompanionBuilder = PayoutsCompanion Function({
  Value<String> id,
  required String tontineId,
  required String slotId,
  required String paidOn,
  required int pot,
  required int collected,
  required int organizerTopUp,
  required int withheld,
  required int handed,
  required PayoutMethod method,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$PayoutsTableUpdateCompanionBuilder = PayoutsCompanion Function({
  Value<String> id,
  Value<String> tontineId,
  Value<String> slotId,
  Value<String> paidOn,
  Value<int> pot,
  Value<int> collected,
  Value<int> organizerTopUp,
  Value<int> withheld,
  Value<int> handed,
  Value<PayoutMethod> method,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$PayoutsTableReferences
    extends BaseReferences<_$AppDatabase, $PayoutsTable, PayoutRow> {
  $$PayoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TontinesTable _tontineIdTable(_$AppDatabase db) =>
      db.tontines.createAlias('payout__tontine_id__tontine__id');

  $$TontinesTableProcessedTableManager get tontineId {
    final $_column = $_itemColumn<String>('tontine_id')!;

    final manager = $$TontinesTableTableManager(
      $_db,
      $_db.tontines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tontineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SlotsTable _slotIdTable(_$AppDatabase db) =>
      db.slots.createAlias('payout__slot_id__slot__id');

  $$SlotsTableProcessedTableManager get slotId {
    final $_column = $_itemColumn<String>('slot_id')!;

    final manager = $$SlotsTableTableManager(
      $_db,
      $_db.slots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_slotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PayoutCancellationsTable,
    List<PayoutCancellationRow>
  >
  _payoutCancellationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.payoutCancellations,
        aliasName: 'payout__id__payout_cancellation__payout_id',
      );

  $$PayoutCancellationsTableProcessedTableManager get payoutCancellationsRefs {
    final manager = $$PayoutCancellationsTableTableManager(
      $_db,
      $_db.payoutCancellations,
    ).filter((f) => f.payoutId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _payoutCancellationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PayoutsTableFilterComposer
    extends Composer<_$AppDatabase, $PayoutsTable> {
  $$PayoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paidOn => $composableBuilder(
    column: $table.paidOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pot => $composableBuilder(
    column: $table.pot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get collected => $composableBuilder(
    column: $table.collected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get organizerTopUp => $composableBuilder(
    column: $table.organizerTopUp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get withheld => $composableBuilder(
    column: $table.withheld,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get handed => $composableBuilder(
    column: $table.handed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PayoutMethod, PayoutMethod, String>
  get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TontinesTableFilterComposer get tontineId {
    final $$TontinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tontineId,
      referencedTable: $db.tontines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TontinesTableFilterComposer(
            $db: $db,
            $table: $db.tontines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SlotsTableFilterComposer get slotId {
    final $$SlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.slotId,
      referencedTable: $db.slots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SlotsTableFilterComposer(
            $db: $db,
            $table: $db.slots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> payoutCancellationsRefs(
    Expression<bool> Function($$PayoutCancellationsTableFilterComposer f) f,
  ) {
    final $$PayoutCancellationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payoutCancellations,
      getReferencedColumn: (t) => t.payoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayoutCancellationsTableFilterComposer(
            $db: $db,
            $table: $db.payoutCancellations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PayoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $PayoutsTable> {
  $$PayoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paidOn => $composableBuilder(
    column: $table.paidOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pot => $composableBuilder(
    column: $table.pot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get collected => $composableBuilder(
    column: $table.collected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get organizerTopUp => $composableBuilder(
    column: $table.organizerTopUp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get withheld => $composableBuilder(
    column: $table.withheld,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get handed => $composableBuilder(
    column: $table.handed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TontinesTableOrderingComposer get tontineId {
    final $$TontinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tontineId,
      referencedTable: $db.tontines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TontinesTableOrderingComposer(
            $db: $db,
            $table: $db.tontines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SlotsTableOrderingComposer get slotId {
    final $$SlotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.slotId,
      referencedTable: $db.slots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SlotsTableOrderingComposer(
            $db: $db,
            $table: $db.slots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PayoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayoutsTable> {
  $$PayoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get paidOn =>
      $composableBuilder(column: $table.paidOn, builder: (column) => column);

  GeneratedColumn<int> get pot =>
      $composableBuilder(column: $table.pot, builder: (column) => column);

  GeneratedColumn<int> get collected =>
      $composableBuilder(column: $table.collected, builder: (column) => column);

  GeneratedColumn<int> get organizerTopUp => $composableBuilder(
    column: $table.organizerTopUp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get withheld =>
      $composableBuilder(column: $table.withheld, builder: (column) => column);

  GeneratedColumn<int> get handed =>
      $composableBuilder(column: $table.handed, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PayoutMethod, String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TontinesTableAnnotationComposer get tontineId {
    final $$TontinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tontineId,
      referencedTable: $db.tontines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TontinesTableAnnotationComposer(
            $db: $db,
            $table: $db.tontines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SlotsTableAnnotationComposer get slotId {
    final $$SlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.slotId,
      referencedTable: $db.slots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.slots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> payoutCancellationsRefs<T extends Object>(
    Expression<T> Function($$PayoutCancellationsTableAnnotationComposer a) f,
  ) {
    final $$PayoutCancellationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.payoutCancellations,
          getReferencedColumn: (t) => t.payoutId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PayoutCancellationsTableAnnotationComposer(
                $db: $db,
                $table: $db.payoutCancellations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PayoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PayoutsTable,
          PayoutRow,
          $$PayoutsTableFilterComposer,
          $$PayoutsTableOrderingComposer,
          $$PayoutsTableAnnotationComposer,
          $$PayoutsTableCreateCompanionBuilder,
          $$PayoutsTableUpdateCompanionBuilder,
          (PayoutRow, $$PayoutsTableReferences),
          PayoutRow,
          PrefetchHooks Function({
            bool tontineId,
            bool slotId,
            bool payoutCancellationsRefs,
          })
        > {
  $$PayoutsTableTableManager(_$AppDatabase db, $PayoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tontineId = const Value.absent(),
                Value<String> slotId = const Value.absent(),
                Value<String> paidOn = const Value.absent(),
                Value<int> pot = const Value.absent(),
                Value<int> collected = const Value.absent(),
                Value<int> organizerTopUp = const Value.absent(),
                Value<int> withheld = const Value.absent(),
                Value<int> handed = const Value.absent(),
                Value<PayoutMethod> method = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayoutsCompanion(
                id: id,
                tontineId: tontineId,
                slotId: slotId,
                paidOn: paidOn,
                pot: pot,
                collected: collected,
                organizerTopUp: organizerTopUp,
                withheld: withheld,
                handed: handed,
                method: method,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String tontineId,
                required String slotId,
                required String paidOn,
                required int pot,
                required int collected,
                required int organizerTopUp,
                required int withheld,
                required int handed,
                required PayoutMethod method,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayoutsCompanion.insert(
                id: id,
                tontineId: tontineId,
                slotId: slotId,
                paidOn: paidOn,
                pot: pot,
                collected: collected,
                organizerTopUp: organizerTopUp,
                withheld: withheld,
                handed: handed,
                method: method,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PayoutsTable, PayoutRow>(table),
                  $$PayoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tontineId = false,
                slotId = false,
                payoutCancellationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (payoutCancellationsRefs) db.payoutCancellations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tontineId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.tontineId,
                            referencedTable: $$PayoutsTableReferences
                                ._tontineIdTable(db),
                            referencedColumn: $$PayoutsTableReferences
                                ._tontineIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (slotId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.slotId,
                            referencedTable: $$PayoutsTableReferences
                                ._slotIdTable(db),
                            referencedColumn: $$PayoutsTableReferences
                                ._slotIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (payoutCancellationsRefs)
                        await $_getPrefetchedDataByColumns<
                          PayoutRow,
                          $PayoutsTable,
                          PayoutCancellationRow,
                          $PayoutCancellationsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PayoutsTableReferences
                              ._payoutCancellationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PayoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).payoutCancellationsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'payout_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PayoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PayoutsTable,
      PayoutRow,
      $$PayoutsTableFilterComposer,
      $$PayoutsTableOrderingComposer,
      $$PayoutsTableAnnotationComposer,
      $$PayoutsTableCreateCompanionBuilder,
      $$PayoutsTableUpdateCompanionBuilder,
      (PayoutRow, $$PayoutsTableReferences),
      PayoutRow,
      PrefetchHooks Function({
        bool tontineId,
        bool slotId,
        bool payoutCancellationsRefs,
      })
    >;
typedef $$PayoutCancellationsTableCreateCompanionBuilder =
    PayoutCancellationsCompanion Function({
      required String payoutId,
      Value<String?> reason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$PayoutCancellationsTableUpdateCompanionBuilder =
    PayoutCancellationsCompanion Function({
      Value<String> payoutId,
      Value<String?> reason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PayoutCancellationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PayoutCancellationsTable,
          PayoutCancellationRow
        > {
  $$PayoutCancellationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PayoutsTable _payoutIdTable(_$AppDatabase db) =>
      db.payouts.createAlias('payout_cancellation__payout_id__payout__id');

  $$PayoutsTableProcessedTableManager get payoutId {
    final $_column = $_itemColumn<String>('payout_id')!;

    final manager = $$PayoutsTableTableManager(
      $_db,
      $_db.payouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_payoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PayoutCancellationsTableFilterComposer
    extends Composer<_$AppDatabase, $PayoutCancellationsTable> {
  $$PayoutCancellationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PayoutsTableFilterComposer get payoutId {
    final $$PayoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.payoutId,
      referencedTable: $db.payouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayoutsTableFilterComposer(
            $db: $db,
            $table: $db.payouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PayoutCancellationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PayoutCancellationsTable> {
  $$PayoutCancellationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PayoutsTableOrderingComposer get payoutId {
    final $$PayoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.payoutId,
      referencedTable: $db.payouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayoutsTableOrderingComposer(
            $db: $db,
            $table: $db.payouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PayoutCancellationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayoutCancellationsTable> {
  $$PayoutCancellationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PayoutsTableAnnotationComposer get payoutId {
    final $$PayoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.payoutId,
      referencedTable: $db.payouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.payouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PayoutCancellationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PayoutCancellationsTable,
          PayoutCancellationRow,
          $$PayoutCancellationsTableFilterComposer,
          $$PayoutCancellationsTableOrderingComposer,
          $$PayoutCancellationsTableAnnotationComposer,
          $$PayoutCancellationsTableCreateCompanionBuilder,
          $$PayoutCancellationsTableUpdateCompanionBuilder,
          (PayoutCancellationRow, $$PayoutCancellationsTableReferences),
          PayoutCancellationRow,
          PrefetchHooks Function({bool payoutId})
        > {
  $$PayoutCancellationsTableTableManager(
    _$AppDatabase db,
    $PayoutCancellationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayoutCancellationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayoutCancellationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PayoutCancellationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> payoutId = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayoutCancellationsCompanion(
                payoutId: payoutId,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String payoutId,
                Value<String?> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayoutCancellationsCompanion.insert(
                payoutId: payoutId,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PayoutCancellationsTable, PayoutCancellationRow>(
                    table,
                  ),
                  $$PayoutCancellationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({payoutId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (payoutId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.payoutId,
                        referencedTable: $$PayoutCancellationsTableReferences
                            ._payoutIdTable(db),
                        referencedColumn: $$PayoutCancellationsTableReferences
                            ._payoutIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PayoutCancellationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PayoutCancellationsTable,
      PayoutCancellationRow,
      $$PayoutCancellationsTableFilterComposer,
      $$PayoutCancellationsTableOrderingComposer,
      $$PayoutCancellationsTableAnnotationComposer,
      $$PayoutCancellationsTableCreateCompanionBuilder,
      $$PayoutCancellationsTableUpdateCompanionBuilder,
      (PayoutCancellationRow, $$PayoutCancellationsTableReferences),
      PayoutCancellationRow,
      PrefetchHooks Function({bool payoutId})
    >;
typedef $$TourSwapsTableCreateCompanionBuilder = TourSwapsCompanion Function({
  Value<String> id,
  required String tontineId,
  required int tourA,
  required int tourB,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$TourSwapsTableUpdateCompanionBuilder = TourSwapsCompanion Function({
  Value<String> id,
  Value<String> tontineId,
  Value<int> tourA,
  Value<int> tourB,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$TourSwapsTableReferences
    extends BaseReferences<_$AppDatabase, $TourSwapsTable, TourSwapRow> {
  $$TourSwapsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TontinesTable _tontineIdTable(_$AppDatabase db) =>
      db.tontines.createAlias('tour_swap__tontine_id__tontine__id');

  $$TontinesTableProcessedTableManager get tontineId {
    final $_column = $_itemColumn<String>('tontine_id')!;

    final manager = $$TontinesTableTableManager(
      $_db,
      $_db.tontines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tontineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TourSwapsTableFilterComposer
    extends Composer<_$AppDatabase, $TourSwapsTable> {
  $$TourSwapsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tourA => $composableBuilder(
    column: $table.tourA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tourB => $composableBuilder(
    column: $table.tourB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TontinesTableFilterComposer get tontineId {
    final $$TontinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tontineId,
      referencedTable: $db.tontines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TontinesTableFilterComposer(
            $db: $db,
            $table: $db.tontines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TourSwapsTableOrderingComposer
    extends Composer<_$AppDatabase, $TourSwapsTable> {
  $$TourSwapsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tourA => $composableBuilder(
    column: $table.tourA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tourB => $composableBuilder(
    column: $table.tourB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TontinesTableOrderingComposer get tontineId {
    final $$TontinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tontineId,
      referencedTable: $db.tontines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TontinesTableOrderingComposer(
            $db: $db,
            $table: $db.tontines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TourSwapsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TourSwapsTable> {
  $$TourSwapsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tourA =>
      $composableBuilder(column: $table.tourA, builder: (column) => column);

  GeneratedColumn<int> get tourB =>
      $composableBuilder(column: $table.tourB, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TontinesTableAnnotationComposer get tontineId {
    final $$TontinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tontineId,
      referencedTable: $db.tontines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TontinesTableAnnotationComposer(
            $db: $db,
            $table: $db.tontines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TourSwapsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TourSwapsTable,
          TourSwapRow,
          $$TourSwapsTableFilterComposer,
          $$TourSwapsTableOrderingComposer,
          $$TourSwapsTableAnnotationComposer,
          $$TourSwapsTableCreateCompanionBuilder,
          $$TourSwapsTableUpdateCompanionBuilder,
          (TourSwapRow, $$TourSwapsTableReferences),
          TourSwapRow,
          PrefetchHooks Function({bool tontineId})
        > {
  $$TourSwapsTableTableManager(_$AppDatabase db, $TourSwapsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TourSwapsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TourSwapsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TourSwapsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tontineId = const Value.absent(),
                Value<int> tourA = const Value.absent(),
                Value<int> tourB = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TourSwapsCompanion(
                id: id,
                tontineId: tontineId,
                tourA: tourA,
                tourB: tourB,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String tontineId,
                required int tourA,
                required int tourB,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TourSwapsCompanion.insert(
                id: id,
                tontineId: tontineId,
                tourA: tourA,
                tourB: tourB,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TourSwapsTable, TourSwapRow>(table),
                  $$TourSwapsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tontineId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tontineId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tontineId,
                        referencedTable: $$TourSwapsTableReferences
                            ._tontineIdTable(db),
                        referencedColumn: $$TourSwapsTableReferences
                            ._tontineIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TourSwapsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TourSwapsTable,
      TourSwapRow,
      $$TourSwapsTableFilterComposer,
      $$TourSwapsTableOrderingComposer,
      $$TourSwapsTableAnnotationComposer,
      $$TourSwapsTableCreateCompanionBuilder,
      $$TourSwapsTableUpdateCompanionBuilder,
      (TourSwapRow, $$TourSwapsTableReferences),
      TourSwapRow,
      PrefetchHooks Function({bool tontineId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$TontinesTableTableManager get tontines =>
      $$TontinesTableTableManager(_db, _db.tontines);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
  $$SlotsTableTableManager get slots =>
      $$SlotsTableTableManager(_db, _db.slots);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$PaymentCancellationsTableTableManager get paymentCancellations =>
      $$PaymentCancellationsTableTableManager(_db, _db.paymentCancellations);
  $$PayoutsTableTableManager get payouts =>
      $$PayoutsTableTableManager(_db, _db.payouts);
  $$PayoutCancellationsTableTableManager get payoutCancellations =>
      $$PayoutCancellationsTableTableManager(_db, _db.payoutCancellations);
  $$TourSwapsTableTableManager get tourSwaps =>
      $$TourSwapsTableTableManager(_db, _db.tourSwaps);
}
