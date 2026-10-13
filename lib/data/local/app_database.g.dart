// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserSessionsTable extends UserSessions
    with TableInfo<$UserSessionsTable, UserSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
      'token', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _siteMeta = const VerificationMeta('site');
  @override
  late final GeneratedColumn<String> site = GeneratedColumn<String>(
      'site', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _storedAtMeta =
      const VerificationMeta('storedAt');
  @override
  late final GeneratedColumn<DateTime> storedAt = GeneratedColumn<DateTime>(
      'stored_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [userId, token, role, name, email, site, storedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<UserSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
          _tokenMeta, token.isAcceptableOrUnknown(data['token']!, _tokenMeta));
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('site')) {
      context.handle(
          _siteMeta, site.isAcceptableOrUnknown(data['site']!, _siteMeta));
    } else if (isInserting) {
      context.missing(_siteMeta);
    }
    if (data.containsKey('stored_at')) {
      context.handle(_storedAtMeta,
          storedAt.isAcceptableOrUnknown(data['stored_at']!, _storedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UserSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSession(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      token: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      site: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}site'])!,
      storedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}stored_at'])!,
    );
  }

  @override
  $UserSessionsTable createAlias(String alias) {
    return $UserSessionsTable(attachedDatabase, alias);
  }
}

class UserSession extends DataClass implements Insertable<UserSession> {
  final String userId;
  final String token;
  final String role;
  final String name;
  final String email;
  final String site;
  final DateTime storedAt;
  const UserSession(
      {required this.userId,
      required this.token,
      required this.role,
      required this.name,
      required this.email,
      required this.site,
      required this.storedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['token'] = Variable<String>(token);
    map['role'] = Variable<String>(role);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['site'] = Variable<String>(site);
    map['stored_at'] = Variable<DateTime>(storedAt);
    return map;
  }

  UserSessionsCompanion toCompanion(bool nullToAbsent) {
    return UserSessionsCompanion(
      userId: Value(userId),
      token: Value(token),
      role: Value(role),
      name: Value(name),
      email: Value(email),
      site: Value(site),
      storedAt: Value(storedAt),
    );
  }

  factory UserSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSession(
      userId: serializer.fromJson<String>(json['userId']),
      token: serializer.fromJson<String>(json['token']),
      role: serializer.fromJson<String>(json['role']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      site: serializer.fromJson<String>(json['site']),
      storedAt: serializer.fromJson<DateTime>(json['storedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'token': serializer.toJson<String>(token),
      'role': serializer.toJson<String>(role),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'site': serializer.toJson<String>(site),
      'storedAt': serializer.toJson<DateTime>(storedAt),
    };
  }

  UserSession copyWith(
          {String? userId,
          String? token,
          String? role,
          String? name,
          String? email,
          String? site,
          DateTime? storedAt}) =>
      UserSession(
        userId: userId ?? this.userId,
        token: token ?? this.token,
        role: role ?? this.role,
        name: name ?? this.name,
        email: email ?? this.email,
        site: site ?? this.site,
        storedAt: storedAt ?? this.storedAt,
      );
  UserSession copyWithCompanion(UserSessionsCompanion data) {
    return UserSession(
      userId: data.userId.present ? data.userId.value : this.userId,
      token: data.token.present ? data.token.value : this.token,
      role: data.role.present ? data.role.value : this.role,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      site: data.site.present ? data.site.value : this.site,
      storedAt: data.storedAt.present ? data.storedAt.value : this.storedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSession(')
          ..write('userId: $userId, ')
          ..write('token: $token, ')
          ..write('role: $role, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('site: $site, ')
          ..write('storedAt: $storedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, token, role, name, email, site, storedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSession &&
          other.userId == this.userId &&
          other.token == this.token &&
          other.role == this.role &&
          other.name == this.name &&
          other.email == this.email &&
          other.site == this.site &&
          other.storedAt == this.storedAt);
}

class UserSessionsCompanion extends UpdateCompanion<UserSession> {
  final Value<String> userId;
  final Value<String> token;
  final Value<String> role;
  final Value<String> name;
  final Value<String> email;
  final Value<String> site;
  final Value<DateTime> storedAt;
  final Value<int> rowid;
  const UserSessionsCompanion({
    this.userId = const Value.absent(),
    this.token = const Value.absent(),
    this.role = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.site = const Value.absent(),
    this.storedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSessionsCompanion.insert({
    required String userId,
    required String token,
    required String role,
    required String name,
    required String email,
    required String site,
    this.storedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        token = Value(token),
        role = Value(role),
        name = Value(name),
        email = Value(email),
        site = Value(site);
  static Insertable<UserSession> custom({
    Expression<String>? userId,
    Expression<String>? token,
    Expression<String>? role,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? site,
    Expression<DateTime>? storedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (token != null) 'token': token,
      if (role != null) 'role': role,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (site != null) 'site': site,
      if (storedAt != null) 'stored_at': storedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSessionsCompanion copyWith(
      {Value<String>? userId,
      Value<String>? token,
      Value<String>? role,
      Value<String>? name,
      Value<String>? email,
      Value<String>? site,
      Value<DateTime>? storedAt,
      Value<int>? rowid}) {
    return UserSessionsCompanion(
      userId: userId ?? this.userId,
      token: token ?? this.token,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      site: site ?? this.site,
      storedAt: storedAt ?? this.storedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (site.present) {
      map['site'] = Variable<String>(site.value);
    }
    if (storedAt.present) {
      map['stored_at'] = Variable<DateTime>(storedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSessionsCompanion(')
          ..write('userId: $userId, ')
          ..write('token: $token, ')
          ..write('role: $role, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('site: $site, ')
          ..write('storedAt: $storedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CountSessionsTable extends CountSessions
    with TableInfo<$CountSessionsTable, CountSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _submittedAtMeta =
      const VerificationMeta('submittedAt');
  @override
  late final GeneratedColumn<DateTime> submittedAt = GeneratedColumn<DateTime>(
      'submitted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _locationIdMeta =
      const VerificationMeta('locationId');
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
      'location_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _assignedWorkerIdMeta =
      const VerificationMeta('assignedWorkerId');
  @override
  late final GeneratedColumn<String> assignedWorkerId = GeneratedColumn<String>(
      'assigned_worker_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deadlineMeta =
      const VerificationMeta('deadline');
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
      'deadline', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _zoneAisleMeta =
      const VerificationMeta('zoneAisle');
  @override
  late final GeneratedColumn<String> zoneAisle = GeneratedColumn<String>(
      'zone_aisle', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        location,
        label,
        status,
        startedAt,
        submittedAt,
        locationId,
        assignedWorkerId,
        deadline,
        zoneAisle
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'count_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<CountSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
          _submittedAtMeta,
          submittedAt.isAcceptableOrUnknown(
              data['submitted_at']!, _submittedAtMeta));
    }
    if (data.containsKey('location_id')) {
      context.handle(
          _locationIdMeta,
          locationId.isAcceptableOrUnknown(
              data['location_id']!, _locationIdMeta));
    }
    if (data.containsKey('assigned_worker_id')) {
      context.handle(
          _assignedWorkerIdMeta,
          assignedWorkerId.isAcceptableOrUnknown(
              data['assigned_worker_id']!, _assignedWorkerIdMeta));
    }
    if (data.containsKey('deadline')) {
      context.handle(_deadlineMeta,
          deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta));
    }
    if (data.containsKey('zone_aisle')) {
      context.handle(_zoneAisleMeta,
          zoneAisle.isAcceptableOrUnknown(data['zone_aisle']!, _zoneAisleMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CountSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CountSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      submittedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}submitted_at']),
      locationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_id']),
      assignedWorkerId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}assigned_worker_id']),
      deadline: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deadline']),
      zoneAisle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}zone_aisle']),
    );
  }

  @override
  $CountSessionsTable createAlias(String alias) {
    return $CountSessionsTable(attachedDatabase, alias);
  }
}

class CountSession extends DataClass implements Insertable<CountSession> {
  final String id;
  final String location;
  final String? label;
  final String status;
  final DateTime startedAt;
  final DateTime? submittedAt;
  final String? locationId;
  final String? assignedWorkerId;
  final DateTime? deadline;
  final String? zoneAisle;
  const CountSession(
      {required this.id,
      required this.location,
      this.label,
      required this.status,
      required this.startedAt,
      this.submittedAt,
      this.locationId,
      this.assignedWorkerId,
      this.deadline,
      this.zoneAisle});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['location'] = Variable<String>(location);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || submittedAt != null) {
      map['submitted_at'] = Variable<DateTime>(submittedAt);
    }
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<String>(locationId);
    }
    if (!nullToAbsent || assignedWorkerId != null) {
      map['assigned_worker_id'] = Variable<String>(assignedWorkerId);
    }
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    if (!nullToAbsent || zoneAisle != null) {
      map['zone_aisle'] = Variable<String>(zoneAisle);
    }
    return map;
  }

  CountSessionsCompanion toCompanion(bool nullToAbsent) {
    return CountSessionsCompanion(
      id: Value(id),
      location: Value(location),
      label:
          label == null && nullToAbsent ? const Value.absent() : Value(label),
      status: Value(status),
      startedAt: Value(startedAt),
      submittedAt: submittedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(submittedAt),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
      assignedWorkerId: assignedWorkerId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedWorkerId),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      zoneAisle: zoneAisle == null && nullToAbsent
          ? const Value.absent()
          : Value(zoneAisle),
    );
  }

  factory CountSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CountSession(
      id: serializer.fromJson<String>(json['id']),
      location: serializer.fromJson<String>(json['location']),
      label: serializer.fromJson<String?>(json['label']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      submittedAt: serializer.fromJson<DateTime?>(json['submittedAt']),
      locationId: serializer.fromJson<String?>(json['locationId']),
      assignedWorkerId: serializer.fromJson<String?>(json['assignedWorkerId']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      zoneAisle: serializer.fromJson<String?>(json['zoneAisle']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'location': serializer.toJson<String>(location),
      'label': serializer.toJson<String?>(label),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'submittedAt': serializer.toJson<DateTime?>(submittedAt),
      'locationId': serializer.toJson<String?>(locationId),
      'assignedWorkerId': serializer.toJson<String?>(assignedWorkerId),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'zoneAisle': serializer.toJson<String?>(zoneAisle),
    };
  }

  CountSession copyWith(
          {String? id,
          String? location,
          Value<String?> label = const Value.absent(),
          String? status,
          DateTime? startedAt,
          Value<DateTime?> submittedAt = const Value.absent(),
          Value<String?> locationId = const Value.absent(),
          Value<String?> assignedWorkerId = const Value.absent(),
          Value<DateTime?> deadline = const Value.absent(),
          Value<String?> zoneAisle = const Value.absent()}) =>
      CountSession(
        id: id ?? this.id,
        location: location ?? this.location,
        label: label.present ? label.value : this.label,
        status: status ?? this.status,
        startedAt: startedAt ?? this.startedAt,
        submittedAt: submittedAt.present ? submittedAt.value : this.submittedAt,
        locationId: locationId.present ? locationId.value : this.locationId,
        assignedWorkerId: assignedWorkerId.present
            ? assignedWorkerId.value
            : this.assignedWorkerId,
        deadline: deadline.present ? deadline.value : this.deadline,
        zoneAisle: zoneAisle.present ? zoneAisle.value : this.zoneAisle,
      );
  CountSession copyWithCompanion(CountSessionsCompanion data) {
    return CountSession(
      id: data.id.present ? data.id.value : this.id,
      location: data.location.present ? data.location.value : this.location,
      label: data.label.present ? data.label.value : this.label,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      submittedAt:
          data.submittedAt.present ? data.submittedAt.value : this.submittedAt,
      locationId:
          data.locationId.present ? data.locationId.value : this.locationId,
      assignedWorkerId: data.assignedWorkerId.present
          ? data.assignedWorkerId.value
          : this.assignedWorkerId,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      zoneAisle: data.zoneAisle.present ? data.zoneAisle.value : this.zoneAisle,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CountSession(')
          ..write('id: $id, ')
          ..write('location: $location, ')
          ..write('label: $label, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('locationId: $locationId, ')
          ..write('assignedWorkerId: $assignedWorkerId, ')
          ..write('deadline: $deadline, ')
          ..write('zoneAisle: $zoneAisle')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, location, label, status, startedAt,
      submittedAt, locationId, assignedWorkerId, deadline, zoneAisle);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CountSession &&
          other.id == this.id &&
          other.location == this.location &&
          other.label == this.label &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.submittedAt == this.submittedAt &&
          other.locationId == this.locationId &&
          other.assignedWorkerId == this.assignedWorkerId &&
          other.deadline == this.deadline &&
          other.zoneAisle == this.zoneAisle);
}

class CountSessionsCompanion extends UpdateCompanion<CountSession> {
  final Value<String> id;
  final Value<String> location;
  final Value<String?> label;
  final Value<String> status;
  final Value<DateTime> startedAt;
  final Value<DateTime?> submittedAt;
  final Value<String?> locationId;
  final Value<String?> assignedWorkerId;
  final Value<DateTime?> deadline;
  final Value<String?> zoneAisle;
  final Value<int> rowid;
  const CountSessionsCompanion({
    this.id = const Value.absent(),
    this.location = const Value.absent(),
    this.label = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.locationId = const Value.absent(),
    this.assignedWorkerId = const Value.absent(),
    this.deadline = const Value.absent(),
    this.zoneAisle = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountSessionsCompanion.insert({
    required String id,
    required String location,
    this.label = const Value.absent(),
    required String status,
    required DateTime startedAt,
    this.submittedAt = const Value.absent(),
    this.locationId = const Value.absent(),
    this.assignedWorkerId = const Value.absent(),
    this.deadline = const Value.absent(),
    this.zoneAisle = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        location = Value(location),
        status = Value(status),
        startedAt = Value(startedAt);
  static Insertable<CountSession> custom({
    Expression<String>? id,
    Expression<String>? location,
    Expression<String>? label,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? submittedAt,
    Expression<String>? locationId,
    Expression<String>? assignedWorkerId,
    Expression<DateTime>? deadline,
    Expression<String>? zoneAisle,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (location != null) 'location': location,
      if (label != null) 'label': label,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (locationId != null) 'location_id': locationId,
      if (assignedWorkerId != null) 'assigned_worker_id': assignedWorkerId,
      if (deadline != null) 'deadline': deadline,
      if (zoneAisle != null) 'zone_aisle': zoneAisle,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CountSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? location,
      Value<String?>? label,
      Value<String>? status,
      Value<DateTime>? startedAt,
      Value<DateTime?>? submittedAt,
      Value<String?>? locationId,
      Value<String?>? assignedWorkerId,
      Value<DateTime?>? deadline,
      Value<String?>? zoneAisle,
      Value<int>? rowid}) {
    return CountSessionsCompanion(
      id: id ?? this.id,
      location: location ?? this.location,
      label: label ?? this.label,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      locationId: locationId ?? this.locationId,
      assignedWorkerId: assignedWorkerId ?? this.assignedWorkerId,
      deadline: deadline ?? this.deadline,
      zoneAisle: zoneAisle ?? this.zoneAisle,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<DateTime>(submittedAt.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (assignedWorkerId.present) {
      map['assigned_worker_id'] = Variable<String>(assignedWorkerId.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (zoneAisle.present) {
      map['zone_aisle'] = Variable<String>(zoneAisle.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountSessionsCompanion(')
          ..write('id: $id, ')
          ..write('location: $location, ')
          ..write('label: $label, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('locationId: $locationId, ')
          ..write('assignedWorkerId: $assignedWorkerId, ')
          ..write('deadline: $deadline, ')
          ..write('zoneAisle: $zoneAisle, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CountItemsTable extends CountItems
    with TableInfo<$CountItemsTable, CountItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemCodeMeta =
      const VerificationMeta('itemCode');
  @override
  late final GeneratedColumn<String> itemCode = GeneratedColumn<String>(
      'item_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemNameMeta =
      const VerificationMeta('itemName');
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
      'item_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _expectedQtyMeta =
      const VerificationMeta('expectedQty');
  @override
  late final GeneratedColumn<int> expectedQty = GeneratedColumn<int>(
      'expected_qty', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _actualQtyMeta =
      const VerificationMeta('actualQty');
  @override
  late final GeneratedColumn<int> actualQty = GeneratedColumn<int>(
      'actual_qty', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _entryMethodMeta =
      const VerificationMeta('entryMethod');
  @override
  late final GeneratedColumn<String> entryMethod = GeneratedColumn<String>(
      'entry_method', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('scanned'));
  static const VerificationMeta _skippedMeta =
      const VerificationMeta('skipped');
  @override
  late final GeneratedColumn<bool> skipped = GeneratedColumn<bool>(
      'skipped', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("skipped" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        itemCode,
        itemName,
        itemId,
        expectedQty,
        actualQty,
        entryMethod,
        skipped
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'count_items';
  @override
  VerificationContext validateIntegrity(Insertable<CountItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('item_code')) {
      context.handle(_itemCodeMeta,
          itemCode.isAcceptableOrUnknown(data['item_code']!, _itemCodeMeta));
    } else if (isInserting) {
      context.missing(_itemCodeMeta);
    }
    if (data.containsKey('item_name')) {
      context.handle(_itemNameMeta,
          itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta));
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    }
    if (data.containsKey('expected_qty')) {
      context.handle(
          _expectedQtyMeta,
          expectedQty.isAcceptableOrUnknown(
              data['expected_qty']!, _expectedQtyMeta));
    } else if (isInserting) {
      context.missing(_expectedQtyMeta);
    }
    if (data.containsKey('actual_qty')) {
      context.handle(_actualQtyMeta,
          actualQty.isAcceptableOrUnknown(data['actual_qty']!, _actualQtyMeta));
    } else if (isInserting) {
      context.missing(_actualQtyMeta);
    }
    if (data.containsKey('entry_method')) {
      context.handle(
          _entryMethodMeta,
          entryMethod.isAcceptableOrUnknown(
              data['entry_method']!, _entryMethodMeta));
    }
    if (data.containsKey('skipped')) {
      context.handle(_skippedMeta,
          skipped.isAcceptableOrUnknown(data['skipped']!, _skippedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CountItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CountItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      itemCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_code'])!,
      itemName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_name'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id']),
      expectedQty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expected_qty'])!,
      actualQty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}actual_qty'])!,
      entryMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_method'])!,
      skipped: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}skipped'])!,
    );
  }

  @override
  $CountItemsTable createAlias(String alias) {
    return $CountItemsTable(attachedDatabase, alias);
  }
}

class CountItem extends DataClass implements Insertable<CountItem> {
  final String id;
  final String sessionId;
  final String itemCode;
  final String itemName;

  /// The server's item id. Null in Sample mode, where itemCode is all there is.
  final String? itemId;
  final int expectedQty;
  final int actualQty;
  final String entryMethod;
  final bool skipped;
  const CountItem(
      {required this.id,
      required this.sessionId,
      required this.itemCode,
      required this.itemName,
      this.itemId,
      required this.expectedQty,
      required this.actualQty,
      required this.entryMethod,
      required this.skipped});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['item_code'] = Variable<String>(itemCode);
    map['item_name'] = Variable<String>(itemName);
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<String>(itemId);
    }
    map['expected_qty'] = Variable<int>(expectedQty);
    map['actual_qty'] = Variable<int>(actualQty);
    map['entry_method'] = Variable<String>(entryMethod);
    map['skipped'] = Variable<bool>(skipped);
    return map;
  }

  CountItemsCompanion toCompanion(bool nullToAbsent) {
    return CountItemsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      itemCode: Value(itemCode),
      itemName: Value(itemName),
      itemId:
          itemId == null && nullToAbsent ? const Value.absent() : Value(itemId),
      expectedQty: Value(expectedQty),
      actualQty: Value(actualQty),
      entryMethod: Value(entryMethod),
      skipped: Value(skipped),
    );
  }

  factory CountItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CountItem(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      itemCode: serializer.fromJson<String>(json['itemCode']),
      itemName: serializer.fromJson<String>(json['itemName']),
      itemId: serializer.fromJson<String?>(json['itemId']),
      expectedQty: serializer.fromJson<int>(json['expectedQty']),
      actualQty: serializer.fromJson<int>(json['actualQty']),
      entryMethod: serializer.fromJson<String>(json['entryMethod']),
      skipped: serializer.fromJson<bool>(json['skipped']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'itemCode': serializer.toJson<String>(itemCode),
      'itemName': serializer.toJson<String>(itemName),
      'itemId': serializer.toJson<String?>(itemId),
      'expectedQty': serializer.toJson<int>(expectedQty),
      'actualQty': serializer.toJson<int>(actualQty),
      'entryMethod': serializer.toJson<String>(entryMethod),
      'skipped': serializer.toJson<bool>(skipped),
    };
  }

  CountItem copyWith(
          {String? id,
          String? sessionId,
          String? itemCode,
          String? itemName,
          Value<String?> itemId = const Value.absent(),
          int? expectedQty,
          int? actualQty,
          String? entryMethod,
          bool? skipped}) =>
      CountItem(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        itemCode: itemCode ?? this.itemCode,
        itemName: itemName ?? this.itemName,
        itemId: itemId.present ? itemId.value : this.itemId,
        expectedQty: expectedQty ?? this.expectedQty,
        actualQty: actualQty ?? this.actualQty,
        entryMethod: entryMethod ?? this.entryMethod,
        skipped: skipped ?? this.skipped,
      );
  CountItem copyWithCompanion(CountItemsCompanion data) {
    return CountItem(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      itemCode: data.itemCode.present ? data.itemCode.value : this.itemCode,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      expectedQty:
          data.expectedQty.present ? data.expectedQty.value : this.expectedQty,
      actualQty: data.actualQty.present ? data.actualQty.value : this.actualQty,
      entryMethod:
          data.entryMethod.present ? data.entryMethod.value : this.entryMethod,
      skipped: data.skipped.present ? data.skipped.value : this.skipped,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CountItem(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('itemCode: $itemCode, ')
          ..write('itemName: $itemName, ')
          ..write('itemId: $itemId, ')
          ..write('expectedQty: $expectedQty, ')
          ..write('actualQty: $actualQty, ')
          ..write('entryMethod: $entryMethod, ')
          ..write('skipped: $skipped')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, itemCode, itemName, itemId,
      expectedQty, actualQty, entryMethod, skipped);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CountItem &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.itemCode == this.itemCode &&
          other.itemName == this.itemName &&
          other.itemId == this.itemId &&
          other.expectedQty == this.expectedQty &&
          other.actualQty == this.actualQty &&
          other.entryMethod == this.entryMethod &&
          other.skipped == this.skipped);
}

class CountItemsCompanion extends UpdateCompanion<CountItem> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> itemCode;
  final Value<String> itemName;
  final Value<String?> itemId;
  final Value<int> expectedQty;
  final Value<int> actualQty;
  final Value<String> entryMethod;
  final Value<bool> skipped;
  final Value<int> rowid;
  const CountItemsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.itemCode = const Value.absent(),
    this.itemName = const Value.absent(),
    this.itemId = const Value.absent(),
    this.expectedQty = const Value.absent(),
    this.actualQty = const Value.absent(),
    this.entryMethod = const Value.absent(),
    this.skipped = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountItemsCompanion.insert({
    required String id,
    required String sessionId,
    required String itemCode,
    required String itemName,
    this.itemId = const Value.absent(),
    required int expectedQty,
    required int actualQty,
    this.entryMethod = const Value.absent(),
    this.skipped = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        itemCode = Value(itemCode),
        itemName = Value(itemName),
        expectedQty = Value(expectedQty),
        actualQty = Value(actualQty);
  static Insertable<CountItem> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? itemCode,
    Expression<String>? itemName,
    Expression<String>? itemId,
    Expression<int>? expectedQty,
    Expression<int>? actualQty,
    Expression<String>? entryMethod,
    Expression<bool>? skipped,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (itemCode != null) 'item_code': itemCode,
      if (itemName != null) 'item_name': itemName,
      if (itemId != null) 'item_id': itemId,
      if (expectedQty != null) 'expected_qty': expectedQty,
      if (actualQty != null) 'actual_qty': actualQty,
      if (entryMethod != null) 'entry_method': entryMethod,
      if (skipped != null) 'skipped': skipped,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CountItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<String>? itemCode,
      Value<String>? itemName,
      Value<String?>? itemId,
      Value<int>? expectedQty,
      Value<int>? actualQty,
      Value<String>? entryMethod,
      Value<bool>? skipped,
      Value<int>? rowid}) {
    return CountItemsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      itemId: itemId ?? this.itemId,
      expectedQty: expectedQty ?? this.expectedQty,
      actualQty: actualQty ?? this.actualQty,
      entryMethod: entryMethod ?? this.entryMethod,
      skipped: skipped ?? this.skipped,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (itemCode.present) {
      map['item_code'] = Variable<String>(itemCode.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (expectedQty.present) {
      map['expected_qty'] = Variable<int>(expectedQty.value);
    }
    if (actualQty.present) {
      map['actual_qty'] = Variable<int>(actualQty.value);
    }
    if (entryMethod.present) {
      map['entry_method'] = Variable<String>(entryMethod.value);
    }
    if (skipped.present) {
      map['skipped'] = Variable<bool>(skipped.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountItemsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('itemCode: $itemCode, ')
          ..write('itemName: $itemName, ')
          ..write('itemId: $itemId, ')
          ..write('expectedQty: $expectedQty, ')
          ..write('actualQty: $actualQty, ')
          ..write('entryMethod: $entryMethod, ')
          ..write('skipped: $skipped, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationEntriesTable extends LocationEntries
    with TableInfo<$LocationEntriesTable, LocationEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'location_entries';
  @override
  VerificationContext validateIntegrity(Insertable<LocationEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
    );
  }

  @override
  $LocationEntriesTable createAlias(String alias) {
    return $LocationEntriesTable(attachedDatabase, alias);
  }
}

class LocationEntry extends DataClass implements Insertable<LocationEntry> {
  final int id;
  final String name;
  final String type;
  const LocationEntry(
      {required this.id, required this.name, required this.type});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    return map;
  }

  LocationEntriesCompanion toCompanion(bool nullToAbsent) {
    return LocationEntriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
    );
  }

  factory LocationEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationEntry(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
    };
  }

  LocationEntry copyWith({int? id, String? name, String? type}) =>
      LocationEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
      );
  LocationEntry copyWithCompanion(LocationEntriesCompanion data) {
    return LocationEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type);
}

class LocationEntriesCompanion extends UpdateCompanion<LocationEntry> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  const LocationEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
  });
  LocationEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
  })  : name = Value(name),
        type = Value(type);
  static Insertable<LocationEntry> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
    });
  }

  LocationEntriesCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<String>? type}) {
    return LocationEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $DeliveryOrderEntriesTable extends DeliveryOrderEntries
    with TableInfo<$DeliveryOrderEntriesTable, DeliveryOrderEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeliveryOrderEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderNumberMeta =
      const VerificationMeta('orderNumber');
  @override
  late final GeneratedColumn<String> orderNumber = GeneratedColumn<String>(
      'order_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fromLocationIdMeta =
      const VerificationMeta('fromLocationId');
  @override
  late final GeneratedColumn<int> fromLocationId = GeneratedColumn<int>(
      'from_location_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _toLocationIdMeta =
      const VerificationMeta('toLocationId');
  @override
  late final GeneratedColumn<int> toLocationId = GeneratedColumn<int>(
      'to_location_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deliveryDateMeta =
      const VerificationMeta('deliveryDate');
  @override
  late final GeneratedColumn<DateTime> deliveryDate = GeneratedColumn<DateTime>(
      'delivery_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _requiresApprovalMeta =
      const VerificationMeta('requiresApproval');
  @override
  late final GeneratedColumn<bool> requiresApproval = GeneratedColumn<bool>(
      'requires_approval', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("requires_approval" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        orderNumber,
        fromLocationId,
        toLocationId,
        deliveryDate,
        status,
        requiresApproval,
        notes,
        createdBy,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'delivery_order_entries';
  @override
  VerificationContext validateIntegrity(Insertable<DeliveryOrderEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_number')) {
      context.handle(
          _orderNumberMeta,
          orderNumber.isAcceptableOrUnknown(
              data['order_number']!, _orderNumberMeta));
    } else if (isInserting) {
      context.missing(_orderNumberMeta);
    }
    if (data.containsKey('from_location_id')) {
      context.handle(
          _fromLocationIdMeta,
          fromLocationId.isAcceptableOrUnknown(
              data['from_location_id']!, _fromLocationIdMeta));
    } else if (isInserting) {
      context.missing(_fromLocationIdMeta);
    }
    if (data.containsKey('to_location_id')) {
      context.handle(
          _toLocationIdMeta,
          toLocationId.isAcceptableOrUnknown(
              data['to_location_id']!, _toLocationIdMeta));
    } else if (isInserting) {
      context.missing(_toLocationIdMeta);
    }
    if (data.containsKey('delivery_date')) {
      context.handle(
          _deliveryDateMeta,
          deliveryDate.isAcceptableOrUnknown(
              data['delivery_date']!, _deliveryDateMeta));
    } else if (isInserting) {
      context.missing(_deliveryDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('requires_approval')) {
      context.handle(
          _requiresApprovalMeta,
          requiresApproval.isAcceptableOrUnknown(
              data['requires_approval']!, _requiresApprovalMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeliveryOrderEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeliveryOrderEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_number'])!,
      fromLocationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}from_location_id'])!,
      toLocationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}to_location_id'])!,
      deliveryDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}delivery_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      requiresApproval: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}requires_approval'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DeliveryOrderEntriesTable createAlias(String alias) {
    return $DeliveryOrderEntriesTable(attachedDatabase, alias);
  }
}

class DeliveryOrderEntry extends DataClass
    implements Insertable<DeliveryOrderEntry> {
  final int id;
  final String orderNumber;
  final int fromLocationId;
  final int toLocationId;
  final DateTime deliveryDate;
  final String status;
  final bool requiresApproval;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DeliveryOrderEntry(
      {required this.id,
      required this.orderNumber,
      required this.fromLocationId,
      required this.toLocationId,
      required this.deliveryDate,
      required this.status,
      required this.requiresApproval,
      this.notes,
      required this.createdBy,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_number'] = Variable<String>(orderNumber);
    map['from_location_id'] = Variable<int>(fromLocationId);
    map['to_location_id'] = Variable<int>(toLocationId);
    map['delivery_date'] = Variable<DateTime>(deliveryDate);
    map['status'] = Variable<String>(status);
    map['requires_approval'] = Variable<bool>(requiresApproval);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DeliveryOrderEntriesCompanion toCompanion(bool nullToAbsent) {
    return DeliveryOrderEntriesCompanion(
      id: Value(id),
      orderNumber: Value(orderNumber),
      fromLocationId: Value(fromLocationId),
      toLocationId: Value(toLocationId),
      deliveryDate: Value(deliveryDate),
      status: Value(status),
      requiresApproval: Value(requiresApproval),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DeliveryOrderEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeliveryOrderEntry(
      id: serializer.fromJson<int>(json['id']),
      orderNumber: serializer.fromJson<String>(json['orderNumber']),
      fromLocationId: serializer.fromJson<int>(json['fromLocationId']),
      toLocationId: serializer.fromJson<int>(json['toLocationId']),
      deliveryDate: serializer.fromJson<DateTime>(json['deliveryDate']),
      status: serializer.fromJson<String>(json['status']),
      requiresApproval: serializer.fromJson<bool>(json['requiresApproval']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderNumber': serializer.toJson<String>(orderNumber),
      'fromLocationId': serializer.toJson<int>(fromLocationId),
      'toLocationId': serializer.toJson<int>(toLocationId),
      'deliveryDate': serializer.toJson<DateTime>(deliveryDate),
      'status': serializer.toJson<String>(status),
      'requiresApproval': serializer.toJson<bool>(requiresApproval),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DeliveryOrderEntry copyWith(
          {int? id,
          String? orderNumber,
          int? fromLocationId,
          int? toLocationId,
          DateTime? deliveryDate,
          String? status,
          bool? requiresApproval,
          Value<String?> notes = const Value.absent(),
          String? createdBy,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DeliveryOrderEntry(
        id: id ?? this.id,
        orderNumber: orderNumber ?? this.orderNumber,
        fromLocationId: fromLocationId ?? this.fromLocationId,
        toLocationId: toLocationId ?? this.toLocationId,
        deliveryDate: deliveryDate ?? this.deliveryDate,
        status: status ?? this.status,
        requiresApproval: requiresApproval ?? this.requiresApproval,
        notes: notes.present ? notes.value : this.notes,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DeliveryOrderEntry copyWithCompanion(DeliveryOrderEntriesCompanion data) {
    return DeliveryOrderEntry(
      id: data.id.present ? data.id.value : this.id,
      orderNumber:
          data.orderNumber.present ? data.orderNumber.value : this.orderNumber,
      fromLocationId: data.fromLocationId.present
          ? data.fromLocationId.value
          : this.fromLocationId,
      toLocationId: data.toLocationId.present
          ? data.toLocationId.value
          : this.toLocationId,
      deliveryDate: data.deliveryDate.present
          ? data.deliveryDate.value
          : this.deliveryDate,
      status: data.status.present ? data.status.value : this.status,
      requiresApproval: data.requiresApproval.present
          ? data.requiresApproval.value
          : this.requiresApproval,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryOrderEntry(')
          ..write('id: $id, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('fromLocationId: $fromLocationId, ')
          ..write('toLocationId: $toLocationId, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('status: $status, ')
          ..write('requiresApproval: $requiresApproval, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      orderNumber,
      fromLocationId,
      toLocationId,
      deliveryDate,
      status,
      requiresApproval,
      notes,
      createdBy,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveryOrderEntry &&
          other.id == this.id &&
          other.orderNumber == this.orderNumber &&
          other.fromLocationId == this.fromLocationId &&
          other.toLocationId == this.toLocationId &&
          other.deliveryDate == this.deliveryDate &&
          other.status == this.status &&
          other.requiresApproval == this.requiresApproval &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DeliveryOrderEntriesCompanion
    extends UpdateCompanion<DeliveryOrderEntry> {
  final Value<int> id;
  final Value<String> orderNumber;
  final Value<int> fromLocationId;
  final Value<int> toLocationId;
  final Value<DateTime> deliveryDate;
  final Value<String> status;
  final Value<bool> requiresApproval;
  final Value<String?> notes;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DeliveryOrderEntriesCompanion({
    this.id = const Value.absent(),
    this.orderNumber = const Value.absent(),
    this.fromLocationId = const Value.absent(),
    this.toLocationId = const Value.absent(),
    this.deliveryDate = const Value.absent(),
    this.status = const Value.absent(),
    this.requiresApproval = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DeliveryOrderEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String orderNumber,
    required int fromLocationId,
    required int toLocationId,
    required DateTime deliveryDate,
    required String status,
    this.requiresApproval = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : orderNumber = Value(orderNumber),
        fromLocationId = Value(fromLocationId),
        toLocationId = Value(toLocationId),
        deliveryDate = Value(deliveryDate),
        status = Value(status),
        createdBy = Value(createdBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DeliveryOrderEntry> custom({
    Expression<int>? id,
    Expression<String>? orderNumber,
    Expression<int>? fromLocationId,
    Expression<int>? toLocationId,
    Expression<DateTime>? deliveryDate,
    Expression<String>? status,
    Expression<bool>? requiresApproval,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderNumber != null) 'order_number': orderNumber,
      if (fromLocationId != null) 'from_location_id': fromLocationId,
      if (toLocationId != null) 'to_location_id': toLocationId,
      if (deliveryDate != null) 'delivery_date': deliveryDate,
      if (status != null) 'status': status,
      if (requiresApproval != null) 'requires_approval': requiresApproval,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DeliveryOrderEntriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? orderNumber,
      Value<int>? fromLocationId,
      Value<int>? toLocationId,
      Value<DateTime>? deliveryDate,
      Value<String>? status,
      Value<bool>? requiresApproval,
      Value<String?>? notes,
      Value<String>? createdBy,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return DeliveryOrderEntriesCompanion(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      fromLocationId: fromLocationId ?? this.fromLocationId,
      toLocationId: toLocationId ?? this.toLocationId,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      status: status ?? this.status,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderNumber.present) {
      map['order_number'] = Variable<String>(orderNumber.value);
    }
    if (fromLocationId.present) {
      map['from_location_id'] = Variable<int>(fromLocationId.value);
    }
    if (toLocationId.present) {
      map['to_location_id'] = Variable<int>(toLocationId.value);
    }
    if (deliveryDate.present) {
      map['delivery_date'] = Variable<DateTime>(deliveryDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (requiresApproval.present) {
      map['requires_approval'] = Variable<bool>(requiresApproval.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryOrderEntriesCompanion(')
          ..write('id: $id, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('fromLocationId: $fromLocationId, ')
          ..write('toLocationId: $toLocationId, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('status: $status, ')
          ..write('requiresApproval: $requiresApproval, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SalesOrderEntriesTable extends SalesOrderEntries
    with TableInfo<$SalesOrderEntriesTable, SalesOrderEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesOrderEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderNumberMeta =
      const VerificationMeta('orderNumber');
  @override
  late final GeneratedColumn<String> orderNumber = GeneratedColumn<String>(
      'order_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderDateMeta =
      const VerificationMeta('orderDate');
  @override
  late final GeneratedColumn<DateTime> orderDate = GeneratedColumn<DateTime>(
      'order_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _requiresApprovalMeta =
      const VerificationMeta('requiresApproval');
  @override
  late final GeneratedColumn<bool> requiresApproval = GeneratedColumn<bool>(
      'requires_approval', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("requires_approval" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        orderNumber,
        customerName,
        orderDate,
        status,
        requiresApproval,
        notes,
        createdBy,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales_order_entries';
  @override
  VerificationContext validateIntegrity(Insertable<SalesOrderEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_number')) {
      context.handle(
          _orderNumberMeta,
          orderNumber.isAcceptableOrUnknown(
              data['order_number']!, _orderNumberMeta));
    } else if (isInserting) {
      context.missing(_orderNumberMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('order_date')) {
      context.handle(_orderDateMeta,
          orderDate.isAcceptableOrUnknown(data['order_date']!, _orderDateMeta));
    } else if (isInserting) {
      context.missing(_orderDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('requires_approval')) {
      context.handle(
          _requiresApprovalMeta,
          requiresApproval.isAcceptableOrUnknown(
              data['requires_approval']!, _requiresApprovalMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SalesOrderEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalesOrderEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_number'])!,
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name'])!,
      orderDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}order_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      requiresApproval: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}requires_approval'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SalesOrderEntriesTable createAlias(String alias) {
    return $SalesOrderEntriesTable(attachedDatabase, alias);
  }
}

class SalesOrderEntry extends DataClass implements Insertable<SalesOrderEntry> {
  final int id;
  final String orderNumber;
  final String customerName;
  final DateTime orderDate;
  final String status;
  final bool requiresApproval;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SalesOrderEntry(
      {required this.id,
      required this.orderNumber,
      required this.customerName,
      required this.orderDate,
      required this.status,
      required this.requiresApproval,
      this.notes,
      required this.createdBy,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_number'] = Variable<String>(orderNumber);
    map['customer_name'] = Variable<String>(customerName);
    map['order_date'] = Variable<DateTime>(orderDate);
    map['status'] = Variable<String>(status);
    map['requires_approval'] = Variable<bool>(requiresApproval);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SalesOrderEntriesCompanion toCompanion(bool nullToAbsent) {
    return SalesOrderEntriesCompanion(
      id: Value(id),
      orderNumber: Value(orderNumber),
      customerName: Value(customerName),
      orderDate: Value(orderDate),
      status: Value(status),
      requiresApproval: Value(requiresApproval),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SalesOrderEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalesOrderEntry(
      id: serializer.fromJson<int>(json['id']),
      orderNumber: serializer.fromJson<String>(json['orderNumber']),
      customerName: serializer.fromJson<String>(json['customerName']),
      orderDate: serializer.fromJson<DateTime>(json['orderDate']),
      status: serializer.fromJson<String>(json['status']),
      requiresApproval: serializer.fromJson<bool>(json['requiresApproval']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderNumber': serializer.toJson<String>(orderNumber),
      'customerName': serializer.toJson<String>(customerName),
      'orderDate': serializer.toJson<DateTime>(orderDate),
      'status': serializer.toJson<String>(status),
      'requiresApproval': serializer.toJson<bool>(requiresApproval),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SalesOrderEntry copyWith(
          {int? id,
          String? orderNumber,
          String? customerName,
          DateTime? orderDate,
          String? status,
          bool? requiresApproval,
          Value<String?> notes = const Value.absent(),
          String? createdBy,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SalesOrderEntry(
        id: id ?? this.id,
        orderNumber: orderNumber ?? this.orderNumber,
        customerName: customerName ?? this.customerName,
        orderDate: orderDate ?? this.orderDate,
        status: status ?? this.status,
        requiresApproval: requiresApproval ?? this.requiresApproval,
        notes: notes.present ? notes.value : this.notes,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SalesOrderEntry copyWithCompanion(SalesOrderEntriesCompanion data) {
    return SalesOrderEntry(
      id: data.id.present ? data.id.value : this.id,
      orderNumber:
          data.orderNumber.present ? data.orderNumber.value : this.orderNumber,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      orderDate: data.orderDate.present ? data.orderDate.value : this.orderDate,
      status: data.status.present ? data.status.value : this.status,
      requiresApproval: data.requiresApproval.present
          ? data.requiresApproval.value
          : this.requiresApproval,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalesOrderEntry(')
          ..write('id: $id, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('customerName: $customerName, ')
          ..write('orderDate: $orderDate, ')
          ..write('status: $status, ')
          ..write('requiresApproval: $requiresApproval, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, orderNumber, customerName, orderDate,
      status, requiresApproval, notes, createdBy, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalesOrderEntry &&
          other.id == this.id &&
          other.orderNumber == this.orderNumber &&
          other.customerName == this.customerName &&
          other.orderDate == this.orderDate &&
          other.status == this.status &&
          other.requiresApproval == this.requiresApproval &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SalesOrderEntriesCompanion extends UpdateCompanion<SalesOrderEntry> {
  final Value<int> id;
  final Value<String> orderNumber;
  final Value<String> customerName;
  final Value<DateTime> orderDate;
  final Value<String> status;
  final Value<bool> requiresApproval;
  final Value<String?> notes;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SalesOrderEntriesCompanion({
    this.id = const Value.absent(),
    this.orderNumber = const Value.absent(),
    this.customerName = const Value.absent(),
    this.orderDate = const Value.absent(),
    this.status = const Value.absent(),
    this.requiresApproval = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SalesOrderEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String orderNumber,
    required String customerName,
    required DateTime orderDate,
    required String status,
    this.requiresApproval = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : orderNumber = Value(orderNumber),
        customerName = Value(customerName),
        orderDate = Value(orderDate),
        status = Value(status),
        createdBy = Value(createdBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SalesOrderEntry> custom({
    Expression<int>? id,
    Expression<String>? orderNumber,
    Expression<String>? customerName,
    Expression<DateTime>? orderDate,
    Expression<String>? status,
    Expression<bool>? requiresApproval,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderNumber != null) 'order_number': orderNumber,
      if (customerName != null) 'customer_name': customerName,
      if (orderDate != null) 'order_date': orderDate,
      if (status != null) 'status': status,
      if (requiresApproval != null) 'requires_approval': requiresApproval,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SalesOrderEntriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? orderNumber,
      Value<String>? customerName,
      Value<DateTime>? orderDate,
      Value<String>? status,
      Value<bool>? requiresApproval,
      Value<String?>? notes,
      Value<String>? createdBy,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return SalesOrderEntriesCompanion(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderNumber.present) {
      map['order_number'] = Variable<String>(orderNumber.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (orderDate.present) {
      map['order_date'] = Variable<DateTime>(orderDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (requiresApproval.present) {
      map['requires_approval'] = Variable<bool>(requiresApproval.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesOrderEntriesCompanion(')
          ..write('id: $id, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('customerName: $customerName, ')
          ..write('orderDate: $orderDate, ')
          ..write('status: $status, ')
          ..write('requiresApproval: $requiresApproval, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $OrderItemEntriesTable extends OrderItemEntries
    with TableInfo<$OrderItemEntriesTable, OrderItemEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderItemEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _orderTypeMeta =
      const VerificationMeta('orderType');
  @override
  late final GeneratedColumn<String> orderType = GeneratedColumn<String>(
      'order_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemNameMeta =
      const VerificationMeta('itemName');
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
      'item_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemSkuMeta =
      const VerificationMeta('itemSku');
  @override
  late final GeneratedColumn<String> itemSku = GeneratedColumn<String>(
      'item_sku', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, orderId, orderType, itemId, itemName, itemSku, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_item_entries';
  @override
  VerificationContext validateIntegrity(Insertable<OrderItemEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('order_type')) {
      context.handle(_orderTypeMeta,
          orderType.isAcceptableOrUnknown(data['order_type']!, _orderTypeMeta));
    } else if (isInserting) {
      context.missing(_orderTypeMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('item_name')) {
      context.handle(_itemNameMeta,
          itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta));
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('item_sku')) {
      context.handle(_itemSkuMeta,
          itemSku.isAcceptableOrUnknown(data['item_sku']!, _itemSkuMeta));
    } else if (isInserting) {
      context.missing(_itemSkuMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderItemEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderItemEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      orderType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_type'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      itemName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_name'])!,
      itemSku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_sku'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
    );
  }

  @override
  $OrderItemEntriesTable createAlias(String alias) {
    return $OrderItemEntriesTable(attachedDatabase, alias);
  }
}

class OrderItemEntry extends DataClass implements Insertable<OrderItemEntry> {
  final int id;
  final int orderId;
  final String orderType;
  final String itemId;
  final String itemName;
  final String itemSku;
  final int quantity;
  const OrderItemEntry(
      {required this.id,
      required this.orderId,
      required this.orderType,
      required this.itemId,
      required this.itemName,
      required this.itemSku,
      required this.quantity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<int>(orderId);
    map['order_type'] = Variable<String>(orderType);
    map['item_id'] = Variable<String>(itemId);
    map['item_name'] = Variable<String>(itemName);
    map['item_sku'] = Variable<String>(itemSku);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  OrderItemEntriesCompanion toCompanion(bool nullToAbsent) {
    return OrderItemEntriesCompanion(
      id: Value(id),
      orderId: Value(orderId),
      orderType: Value(orderType),
      itemId: Value(itemId),
      itemName: Value(itemName),
      itemSku: Value(itemSku),
      quantity: Value(quantity),
    );
  }

  factory OrderItemEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderItemEntry(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<int>(json['orderId']),
      orderType: serializer.fromJson<String>(json['orderType']),
      itemId: serializer.fromJson<String>(json['itemId']),
      itemName: serializer.fromJson<String>(json['itemName']),
      itemSku: serializer.fromJson<String>(json['itemSku']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<int>(orderId),
      'orderType': serializer.toJson<String>(orderType),
      'itemId': serializer.toJson<String>(itemId),
      'itemName': serializer.toJson<String>(itemName),
      'itemSku': serializer.toJson<String>(itemSku),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  OrderItemEntry copyWith(
          {int? id,
          int? orderId,
          String? orderType,
          String? itemId,
          String? itemName,
          String? itemSku,
          int? quantity}) =>
      OrderItemEntry(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        orderType: orderType ?? this.orderType,
        itemId: itemId ?? this.itemId,
        itemName: itemName ?? this.itemName,
        itemSku: itemSku ?? this.itemSku,
        quantity: quantity ?? this.quantity,
      );
  OrderItemEntry copyWithCompanion(OrderItemEntriesCompanion data) {
    return OrderItemEntry(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      orderType: data.orderType.present ? data.orderType.value : this.orderType,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      itemSku: data.itemSku.present ? data.itemSku.value : this.itemSku,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemEntry(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('orderType: $orderType, ')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('itemSku: $itemSku, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, orderId, orderType, itemId, itemName, itemSku, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderItemEntry &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.orderType == this.orderType &&
          other.itemId == this.itemId &&
          other.itemName == this.itemName &&
          other.itemSku == this.itemSku &&
          other.quantity == this.quantity);
}

class OrderItemEntriesCompanion extends UpdateCompanion<OrderItemEntry> {
  final Value<int> id;
  final Value<int> orderId;
  final Value<String> orderType;
  final Value<String> itemId;
  final Value<String> itemName;
  final Value<String> itemSku;
  final Value<int> quantity;
  const OrderItemEntriesCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.orderType = const Value.absent(),
    this.itemId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.itemSku = const Value.absent(),
    this.quantity = const Value.absent(),
  });
  OrderItemEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int orderId,
    required String orderType,
    required String itemId,
    required String itemName,
    required String itemSku,
    required int quantity,
  })  : orderId = Value(orderId),
        orderType = Value(orderType),
        itemId = Value(itemId),
        itemName = Value(itemName),
        itemSku = Value(itemSku),
        quantity = Value(quantity);
  static Insertable<OrderItemEntry> custom({
    Expression<int>? id,
    Expression<int>? orderId,
    Expression<String>? orderType,
    Expression<String>? itemId,
    Expression<String>? itemName,
    Expression<String>? itemSku,
    Expression<int>? quantity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (orderType != null) 'order_type': orderType,
      if (itemId != null) 'item_id': itemId,
      if (itemName != null) 'item_name': itemName,
      if (itemSku != null) 'item_sku': itemSku,
      if (quantity != null) 'quantity': quantity,
    });
  }

  OrderItemEntriesCompanion copyWith(
      {Value<int>? id,
      Value<int>? orderId,
      Value<String>? orderType,
      Value<String>? itemId,
      Value<String>? itemName,
      Value<String>? itemSku,
      Value<int>? quantity}) {
    return OrderItemEntriesCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      orderType: orderType ?? this.orderType,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemSku: itemSku ?? this.itemSku,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (orderType.present) {
      map['order_type'] = Variable<String>(orderType.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (itemSku.present) {
      map['item_sku'] = Variable<String>(itemSku.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemEntriesCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('orderType: $orderType, ')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('itemSku: $itemSku, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }
}

class $OrderStatusHistoryEntriesTable extends OrderStatusHistoryEntries
    with TableInfo<$OrderStatusHistoryEntriesTable, OrderStatusHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderStatusHistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _orderTypeMeta =
      const VerificationMeta('orderType');
  @override
  late final GeneratedColumn<String> orderType = GeneratedColumn<String>(
      'order_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _changedByMeta =
      const VerificationMeta('changedBy');
  @override
  late final GeneratedColumn<String> changedBy = GeneratedColumn<String>(
      'changed_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _changedAtMeta =
      const VerificationMeta('changedAt');
  @override
  late final GeneratedColumn<DateTime> changedAt = GeneratedColumn<DateTime>(
      'changed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, orderId, orderType, status, changedBy, changedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_status_history_entries';
  @override
  VerificationContext validateIntegrity(
      Insertable<OrderStatusHistoryEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('order_type')) {
      context.handle(_orderTypeMeta,
          orderType.isAcceptableOrUnknown(data['order_type']!, _orderTypeMeta));
    } else if (isInserting) {
      context.missing(_orderTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('changed_by')) {
      context.handle(_changedByMeta,
          changedBy.isAcceptableOrUnknown(data['changed_by']!, _changedByMeta));
    } else if (isInserting) {
      context.missing(_changedByMeta);
    }
    if (data.containsKey('changed_at')) {
      context.handle(_changedAtMeta,
          changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta));
    } else if (isInserting) {
      context.missing(_changedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderStatusHistoryEntry map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderStatusHistoryEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      orderType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      changedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}changed_by'])!,
      changedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}changed_at'])!,
    );
  }

  @override
  $OrderStatusHistoryEntriesTable createAlias(String alias) {
    return $OrderStatusHistoryEntriesTable(attachedDatabase, alias);
  }
}

class OrderStatusHistoryEntry extends DataClass
    implements Insertable<OrderStatusHistoryEntry> {
  final int id;
  final int orderId;
  final String orderType;
  final String status;
  final String changedBy;
  final DateTime changedAt;
  const OrderStatusHistoryEntry(
      {required this.id,
      required this.orderId,
      required this.orderType,
      required this.status,
      required this.changedBy,
      required this.changedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<int>(orderId);
    map['order_type'] = Variable<String>(orderType);
    map['status'] = Variable<String>(status);
    map['changed_by'] = Variable<String>(changedBy);
    map['changed_at'] = Variable<DateTime>(changedAt);
    return map;
  }

  OrderStatusHistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return OrderStatusHistoryEntriesCompanion(
      id: Value(id),
      orderId: Value(orderId),
      orderType: Value(orderType),
      status: Value(status),
      changedBy: Value(changedBy),
      changedAt: Value(changedAt),
    );
  }

  factory OrderStatusHistoryEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderStatusHistoryEntry(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<int>(json['orderId']),
      orderType: serializer.fromJson<String>(json['orderType']),
      status: serializer.fromJson<String>(json['status']),
      changedBy: serializer.fromJson<String>(json['changedBy']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<int>(orderId),
      'orderType': serializer.toJson<String>(orderType),
      'status': serializer.toJson<String>(status),
      'changedBy': serializer.toJson<String>(changedBy),
      'changedAt': serializer.toJson<DateTime>(changedAt),
    };
  }

  OrderStatusHistoryEntry copyWith(
          {int? id,
          int? orderId,
          String? orderType,
          String? status,
          String? changedBy,
          DateTime? changedAt}) =>
      OrderStatusHistoryEntry(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        orderType: orderType ?? this.orderType,
        status: status ?? this.status,
        changedBy: changedBy ?? this.changedBy,
        changedAt: changedAt ?? this.changedAt,
      );
  OrderStatusHistoryEntry copyWithCompanion(
      OrderStatusHistoryEntriesCompanion data) {
    return OrderStatusHistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      orderType: data.orderType.present ? data.orderType.value : this.orderType,
      status: data.status.present ? data.status.value : this.status,
      changedBy: data.changedBy.present ? data.changedBy.value : this.changedBy,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderStatusHistoryEntry(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('orderType: $orderType, ')
          ..write('status: $status, ')
          ..write('changedBy: $changedBy, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, orderId, orderType, status, changedBy, changedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderStatusHistoryEntry &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.orderType == this.orderType &&
          other.status == this.status &&
          other.changedBy == this.changedBy &&
          other.changedAt == this.changedAt);
}

class OrderStatusHistoryEntriesCompanion
    extends UpdateCompanion<OrderStatusHistoryEntry> {
  final Value<int> id;
  final Value<int> orderId;
  final Value<String> orderType;
  final Value<String> status;
  final Value<String> changedBy;
  final Value<DateTime> changedAt;
  const OrderStatusHistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.orderType = const Value.absent(),
    this.status = const Value.absent(),
    this.changedBy = const Value.absent(),
    this.changedAt = const Value.absent(),
  });
  OrderStatusHistoryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int orderId,
    required String orderType,
    required String status,
    required String changedBy,
    required DateTime changedAt,
  })  : orderId = Value(orderId),
        orderType = Value(orderType),
        status = Value(status),
        changedBy = Value(changedBy),
        changedAt = Value(changedAt);
  static Insertable<OrderStatusHistoryEntry> custom({
    Expression<int>? id,
    Expression<int>? orderId,
    Expression<String>? orderType,
    Expression<String>? status,
    Expression<String>? changedBy,
    Expression<DateTime>? changedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (orderType != null) 'order_type': orderType,
      if (status != null) 'status': status,
      if (changedBy != null) 'changed_by': changedBy,
      if (changedAt != null) 'changed_at': changedAt,
    });
  }

  OrderStatusHistoryEntriesCompanion copyWith(
      {Value<int>? id,
      Value<int>? orderId,
      Value<String>? orderType,
      Value<String>? status,
      Value<String>? changedBy,
      Value<DateTime>? changedAt}) {
    return OrderStatusHistoryEntriesCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      orderType: orderType ?? this.orderType,
      status: status ?? this.status,
      changedBy: changedBy ?? this.changedBy,
      changedAt: changedAt ?? this.changedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (orderType.present) {
      map['order_type'] = Variable<String>(orderType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (changedBy.present) {
      map['changed_by'] = Variable<String>(changedBy.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<DateTime>(changedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderStatusHistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('orderType: $orderType, ')
          ..write('status: $status, ')
          ..write('changedBy: $changedBy, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }
}

class $PurchaseOrdersTable extends PurchaseOrders
    with TableInfo<$PurchaseOrdersTable, PurchaseOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _poNumberMeta =
      const VerificationMeta('poNumber');
  @override
  late final GeneratedColumn<String> poNumber = GeneratedColumn<String>(
      'po_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _supplierMeta =
      const VerificationMeta('supplier');
  @override
  late final GeneratedColumn<String> supplier = GeneratedColumn<String>(
      'supplier', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _expectedDateMeta =
      const VerificationMeta('expectedDate');
  @override
  late final GeneratedColumn<DateTime> expectedDate = GeneratedColumn<DateTime>(
      'expected_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _receivedAtMeta =
      const VerificationMeta('receivedAt');
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
      'received_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, poNumber, supplier, status, dueDate, expectedDate, receivedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_orders';
  @override
  VerificationContext validateIntegrity(Insertable<PurchaseOrder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('po_number')) {
      context.handle(_poNumberMeta,
          poNumber.isAcceptableOrUnknown(data['po_number']!, _poNumberMeta));
    } else if (isInserting) {
      context.missing(_poNumberMeta);
    }
    if (data.containsKey('supplier')) {
      context.handle(_supplierMeta,
          supplier.isAcceptableOrUnknown(data['supplier']!, _supplierMeta));
    } else if (isInserting) {
      context.missing(_supplierMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('expected_date')) {
      context.handle(
          _expectedDateMeta,
          expectedDate.isAcceptableOrUnknown(
              data['expected_date']!, _expectedDateMeta));
    } else if (isInserting) {
      context.missing(_expectedDateMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
          _receivedAtMeta,
          receivedAt.isAcceptableOrUnknown(
              data['received_at']!, _receivedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseOrder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      poNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}po_number'])!,
      supplier: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      expectedDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}expected_date'])!,
      receivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}received_at']),
    );
  }

  @override
  $PurchaseOrdersTable createAlias(String alias) {
    return $PurchaseOrdersTable(attachedDatabase, alias);
  }
}

class PurchaseOrder extends DataClass implements Insertable<PurchaseOrder> {
  final String id;
  final String poNumber;
  final String supplier;
  final String status;
  final DateTime? dueDate;
  final DateTime expectedDate;
  final DateTime? receivedAt;
  const PurchaseOrder(
      {required this.id,
      required this.poNumber,
      required this.supplier,
      required this.status,
      this.dueDate,
      required this.expectedDate,
      this.receivedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['po_number'] = Variable<String>(poNumber);
    map['supplier'] = Variable<String>(supplier);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['expected_date'] = Variable<DateTime>(expectedDate);
    if (!nullToAbsent || receivedAt != null) {
      map['received_at'] = Variable<DateTime>(receivedAt);
    }
    return map;
  }

  PurchaseOrdersCompanion toCompanion(bool nullToAbsent) {
    return PurchaseOrdersCompanion(
      id: Value(id),
      poNumber: Value(poNumber),
      supplier: Value(supplier),
      status: Value(status),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      expectedDate: Value(expectedDate),
      receivedAt: receivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAt),
    );
  }

  factory PurchaseOrder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseOrder(
      id: serializer.fromJson<String>(json['id']),
      poNumber: serializer.fromJson<String>(json['poNumber']),
      supplier: serializer.fromJson<String>(json['supplier']),
      status: serializer.fromJson<String>(json['status']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      expectedDate: serializer.fromJson<DateTime>(json['expectedDate']),
      receivedAt: serializer.fromJson<DateTime?>(json['receivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'poNumber': serializer.toJson<String>(poNumber),
      'supplier': serializer.toJson<String>(supplier),
      'status': serializer.toJson<String>(status),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'expectedDate': serializer.toJson<DateTime>(expectedDate),
      'receivedAt': serializer.toJson<DateTime?>(receivedAt),
    };
  }

  PurchaseOrder copyWith(
          {String? id,
          String? poNumber,
          String? supplier,
          String? status,
          Value<DateTime?> dueDate = const Value.absent(),
          DateTime? expectedDate,
          Value<DateTime?> receivedAt = const Value.absent()}) =>
      PurchaseOrder(
        id: id ?? this.id,
        poNumber: poNumber ?? this.poNumber,
        supplier: supplier ?? this.supplier,
        status: status ?? this.status,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        expectedDate: expectedDate ?? this.expectedDate,
        receivedAt: receivedAt.present ? receivedAt.value : this.receivedAt,
      );
  PurchaseOrder copyWithCompanion(PurchaseOrdersCompanion data) {
    return PurchaseOrder(
      id: data.id.present ? data.id.value : this.id,
      poNumber: data.poNumber.present ? data.poNumber.value : this.poNumber,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      status: data.status.present ? data.status.value : this.status,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      expectedDate: data.expectedDate.present
          ? data.expectedDate.value
          : this.expectedDate,
      receivedAt:
          data.receivedAt.present ? data.receivedAt.value : this.receivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseOrder(')
          ..write('id: $id, ')
          ..write('poNumber: $poNumber, ')
          ..write('supplier: $supplier, ')
          ..write('status: $status, ')
          ..write('dueDate: $dueDate, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, poNumber, supplier, status, dueDate, expectedDate, receivedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseOrder &&
          other.id == this.id &&
          other.poNumber == this.poNumber &&
          other.supplier == this.supplier &&
          other.status == this.status &&
          other.dueDate == this.dueDate &&
          other.expectedDate == this.expectedDate &&
          other.receivedAt == this.receivedAt);
}

class PurchaseOrdersCompanion extends UpdateCompanion<PurchaseOrder> {
  final Value<String> id;
  final Value<String> poNumber;
  final Value<String> supplier;
  final Value<String> status;
  final Value<DateTime?> dueDate;
  final Value<DateTime> expectedDate;
  final Value<DateTime?> receivedAt;
  final Value<int> rowid;
  const PurchaseOrdersCompanion({
    this.id = const Value.absent(),
    this.poNumber = const Value.absent(),
    this.supplier = const Value.absent(),
    this.status = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.expectedDate = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseOrdersCompanion.insert({
    required String id,
    required String poNumber,
    required String supplier,
    required String status,
    this.dueDate = const Value.absent(),
    required DateTime expectedDate,
    this.receivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        poNumber = Value(poNumber),
        supplier = Value(supplier),
        status = Value(status),
        expectedDate = Value(expectedDate);
  static Insertable<PurchaseOrder> custom({
    Expression<String>? id,
    Expression<String>? poNumber,
    Expression<String>? supplier,
    Expression<String>? status,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? expectedDate,
    Expression<DateTime>? receivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (poNumber != null) 'po_number': poNumber,
      if (supplier != null) 'supplier': supplier,
      if (status != null) 'status': status,
      if (dueDate != null) 'due_date': dueDate,
      if (expectedDate != null) 'expected_date': expectedDate,
      if (receivedAt != null) 'received_at': receivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseOrdersCompanion copyWith(
      {Value<String>? id,
      Value<String>? poNumber,
      Value<String>? supplier,
      Value<String>? status,
      Value<DateTime?>? dueDate,
      Value<DateTime>? expectedDate,
      Value<DateTime?>? receivedAt,
      Value<int>? rowid}) {
    return PurchaseOrdersCompanion(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      supplier: supplier ?? this.supplier,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      expectedDate: expectedDate ?? this.expectedDate,
      receivedAt: receivedAt ?? this.receivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (poNumber.present) {
      map['po_number'] = Variable<String>(poNumber.value);
    }
    if (supplier.present) {
      map['supplier'] = Variable<String>(supplier.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (expectedDate.present) {
      map['expected_date'] = Variable<DateTime>(expectedDate.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseOrdersCompanion(')
          ..write('id: $id, ')
          ..write('poNumber: $poNumber, ')
          ..write('supplier: $supplier, ')
          ..write('status: $status, ')
          ..write('dueDate: $dueDate, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PoLineItemsTable extends PoLineItems
    with TableInfo<$PoLineItemsTable, PoLineItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PoLineItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _poIdMeta = const VerificationMeta('poId');
  @override
  late final GeneratedColumn<String> poId = GeneratedColumn<String>(
      'po_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemCodeMeta =
      const VerificationMeta('itemCode');
  @override
  late final GeneratedColumn<String> itemCode = GeneratedColumn<String>(
      'item_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemNameMeta =
      const VerificationMeta('itemName');
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
      'item_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _expectedQtyMeta =
      const VerificationMeta('expectedQty');
  @override
  late final GeneratedColumn<int> expectedQty = GeneratedColumn<int>(
      'expected_qty', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _receivedQtyMeta =
      const VerificationMeta('receivedQty');
  @override
  late final GeneratedColumn<int> receivedQty = GeneratedColumn<int>(
      'received_qty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _flaggedMeta =
      const VerificationMeta('flagged');
  @override
  late final GeneratedColumn<bool> flagged = GeneratedColumn<bool>(
      'flagged', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("flagged" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _flagReasonMeta =
      const VerificationMeta('flagReason');
  @override
  late final GeneratedColumn<String> flagReason = GeneratedColumn<String>(
      'flag_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        poId,
        itemCode,
        itemName,
        expectedQty,
        receivedQty,
        flagged,
        flagReason,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'po_line_items';
  @override
  VerificationContext validateIntegrity(Insertable<PoLineItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('po_id')) {
      context.handle(
          _poIdMeta, poId.isAcceptableOrUnknown(data['po_id']!, _poIdMeta));
    } else if (isInserting) {
      context.missing(_poIdMeta);
    }
    if (data.containsKey('item_code')) {
      context.handle(_itemCodeMeta,
          itemCode.isAcceptableOrUnknown(data['item_code']!, _itemCodeMeta));
    } else if (isInserting) {
      context.missing(_itemCodeMeta);
    }
    if (data.containsKey('item_name')) {
      context.handle(_itemNameMeta,
          itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta));
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('expected_qty')) {
      context.handle(
          _expectedQtyMeta,
          expectedQty.isAcceptableOrUnknown(
              data['expected_qty']!, _expectedQtyMeta));
    } else if (isInserting) {
      context.missing(_expectedQtyMeta);
    }
    if (data.containsKey('received_qty')) {
      context.handle(
          _receivedQtyMeta,
          receivedQty.isAcceptableOrUnknown(
              data['received_qty']!, _receivedQtyMeta));
    }
    if (data.containsKey('flagged')) {
      context.handle(_flaggedMeta,
          flagged.isAcceptableOrUnknown(data['flagged']!, _flaggedMeta));
    }
    if (data.containsKey('flag_reason')) {
      context.handle(
          _flagReasonMeta,
          flagReason.isAcceptableOrUnknown(
              data['flag_reason']!, _flagReasonMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PoLineItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PoLineItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      poId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}po_id'])!,
      itemCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_code'])!,
      itemName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_name'])!,
      expectedQty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expected_qty'])!,
      receivedQty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}received_qty'])!,
      flagged: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}flagged'])!,
      flagReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}flag_reason']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $PoLineItemsTable createAlias(String alias) {
    return $PoLineItemsTable(attachedDatabase, alias);
  }
}

class PoLineItem extends DataClass implements Insertable<PoLineItem> {
  final String id;
  final String poId;
  final String itemCode;
  final String itemName;
  final int expectedQty;
  final int receivedQty;
  final bool flagged;
  final String? flagReason;
  final String status;
  const PoLineItem(
      {required this.id,
      required this.poId,
      required this.itemCode,
      required this.itemName,
      required this.expectedQty,
      required this.receivedQty,
      required this.flagged,
      this.flagReason,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['po_id'] = Variable<String>(poId);
    map['item_code'] = Variable<String>(itemCode);
    map['item_name'] = Variable<String>(itemName);
    map['expected_qty'] = Variable<int>(expectedQty);
    map['received_qty'] = Variable<int>(receivedQty);
    map['flagged'] = Variable<bool>(flagged);
    if (!nullToAbsent || flagReason != null) {
      map['flag_reason'] = Variable<String>(flagReason);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  PoLineItemsCompanion toCompanion(bool nullToAbsent) {
    return PoLineItemsCompanion(
      id: Value(id),
      poId: Value(poId),
      itemCode: Value(itemCode),
      itemName: Value(itemName),
      expectedQty: Value(expectedQty),
      receivedQty: Value(receivedQty),
      flagged: Value(flagged),
      flagReason: flagReason == null && nullToAbsent
          ? const Value.absent()
          : Value(flagReason),
      status: Value(status),
    );
  }

  factory PoLineItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PoLineItem(
      id: serializer.fromJson<String>(json['id']),
      poId: serializer.fromJson<String>(json['poId']),
      itemCode: serializer.fromJson<String>(json['itemCode']),
      itemName: serializer.fromJson<String>(json['itemName']),
      expectedQty: serializer.fromJson<int>(json['expectedQty']),
      receivedQty: serializer.fromJson<int>(json['receivedQty']),
      flagged: serializer.fromJson<bool>(json['flagged']),
      flagReason: serializer.fromJson<String?>(json['flagReason']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'poId': serializer.toJson<String>(poId),
      'itemCode': serializer.toJson<String>(itemCode),
      'itemName': serializer.toJson<String>(itemName),
      'expectedQty': serializer.toJson<int>(expectedQty),
      'receivedQty': serializer.toJson<int>(receivedQty),
      'flagged': serializer.toJson<bool>(flagged),
      'flagReason': serializer.toJson<String?>(flagReason),
      'status': serializer.toJson<String>(status),
    };
  }

  PoLineItem copyWith(
          {String? id,
          String? poId,
          String? itemCode,
          String? itemName,
          int? expectedQty,
          int? receivedQty,
          bool? flagged,
          Value<String?> flagReason = const Value.absent(),
          String? status}) =>
      PoLineItem(
        id: id ?? this.id,
        poId: poId ?? this.poId,
        itemCode: itemCode ?? this.itemCode,
        itemName: itemName ?? this.itemName,
        expectedQty: expectedQty ?? this.expectedQty,
        receivedQty: receivedQty ?? this.receivedQty,
        flagged: flagged ?? this.flagged,
        flagReason: flagReason.present ? flagReason.value : this.flagReason,
        status: status ?? this.status,
      );
  PoLineItem copyWithCompanion(PoLineItemsCompanion data) {
    return PoLineItem(
      id: data.id.present ? data.id.value : this.id,
      poId: data.poId.present ? data.poId.value : this.poId,
      itemCode: data.itemCode.present ? data.itemCode.value : this.itemCode,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      expectedQty:
          data.expectedQty.present ? data.expectedQty.value : this.expectedQty,
      receivedQty:
          data.receivedQty.present ? data.receivedQty.value : this.receivedQty,
      flagged: data.flagged.present ? data.flagged.value : this.flagged,
      flagReason:
          data.flagReason.present ? data.flagReason.value : this.flagReason,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PoLineItem(')
          ..write('id: $id, ')
          ..write('poId: $poId, ')
          ..write('itemCode: $itemCode, ')
          ..write('itemName: $itemName, ')
          ..write('expectedQty: $expectedQty, ')
          ..write('receivedQty: $receivedQty, ')
          ..write('flagged: $flagged, ')
          ..write('flagReason: $flagReason, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, poId, itemCode, itemName, expectedQty,
      receivedQty, flagged, flagReason, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PoLineItem &&
          other.id == this.id &&
          other.poId == this.poId &&
          other.itemCode == this.itemCode &&
          other.itemName == this.itemName &&
          other.expectedQty == this.expectedQty &&
          other.receivedQty == this.receivedQty &&
          other.flagged == this.flagged &&
          other.flagReason == this.flagReason &&
          other.status == this.status);
}

class PoLineItemsCompanion extends UpdateCompanion<PoLineItem> {
  final Value<String> id;
  final Value<String> poId;
  final Value<String> itemCode;
  final Value<String> itemName;
  final Value<int> expectedQty;
  final Value<int> receivedQty;
  final Value<bool> flagged;
  final Value<String?> flagReason;
  final Value<String> status;
  final Value<int> rowid;
  const PoLineItemsCompanion({
    this.id = const Value.absent(),
    this.poId = const Value.absent(),
    this.itemCode = const Value.absent(),
    this.itemName = const Value.absent(),
    this.expectedQty = const Value.absent(),
    this.receivedQty = const Value.absent(),
    this.flagged = const Value.absent(),
    this.flagReason = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PoLineItemsCompanion.insert({
    required String id,
    required String poId,
    required String itemCode,
    required String itemName,
    required int expectedQty,
    this.receivedQty = const Value.absent(),
    this.flagged = const Value.absent(),
    this.flagReason = const Value.absent(),
    required String status,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        poId = Value(poId),
        itemCode = Value(itemCode),
        itemName = Value(itemName),
        expectedQty = Value(expectedQty),
        status = Value(status);
  static Insertable<PoLineItem> custom({
    Expression<String>? id,
    Expression<String>? poId,
    Expression<String>? itemCode,
    Expression<String>? itemName,
    Expression<int>? expectedQty,
    Expression<int>? receivedQty,
    Expression<bool>? flagged,
    Expression<String>? flagReason,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (poId != null) 'po_id': poId,
      if (itemCode != null) 'item_code': itemCode,
      if (itemName != null) 'item_name': itemName,
      if (expectedQty != null) 'expected_qty': expectedQty,
      if (receivedQty != null) 'received_qty': receivedQty,
      if (flagged != null) 'flagged': flagged,
      if (flagReason != null) 'flag_reason': flagReason,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PoLineItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? poId,
      Value<String>? itemCode,
      Value<String>? itemName,
      Value<int>? expectedQty,
      Value<int>? receivedQty,
      Value<bool>? flagged,
      Value<String?>? flagReason,
      Value<String>? status,
      Value<int>? rowid}) {
    return PoLineItemsCompanion(
      id: id ?? this.id,
      poId: poId ?? this.poId,
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      expectedQty: expectedQty ?? this.expectedQty,
      receivedQty: receivedQty ?? this.receivedQty,
      flagged: flagged ?? this.flagged,
      flagReason: flagReason ?? this.flagReason,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (poId.present) {
      map['po_id'] = Variable<String>(poId.value);
    }
    if (itemCode.present) {
      map['item_code'] = Variable<String>(itemCode.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (expectedQty.present) {
      map['expected_qty'] = Variable<int>(expectedQty.value);
    }
    if (receivedQty.present) {
      map['received_qty'] = Variable<int>(receivedQty.value);
    }
    if (flagged.present) {
      map['flagged'] = Variable<bool>(flagged.value);
    }
    if (flagReason.present) {
      map['flag_reason'] = Variable<String>(flagReason.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PoLineItemsCompanion(')
          ..write('id: $id, ')
          ..write('poId: $poId, ')
          ..write('itemCode: $itemCode, ')
          ..write('itemName: $itemName, ')
          ..write('expectedQty: $expectedQty, ')
          ..write('receivedQty: $receivedQty, ')
          ..write('flagged: $flagged, ')
          ..write('flagReason: $flagReason, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _operationTypeMeta =
      const VerificationMeta('operationType');
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
      'operation_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceIdMeta =
      const VerificationMeta('referenceId');
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
      'reference_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _queuedAtMeta =
      const VerificationMeta('queuedAt');
  @override
  late final GeneratedColumn<DateTime> queuedAt = GeneratedColumn<DateTime>(
      'queued_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        operationType,
        referenceId,
        payload,
        queuedAt,
        synced,
        syncedAt,
        idempotencyKey,
        status,
        attempts,
        lastError,
        warehouseId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation_type')) {
      context.handle(
          _operationTypeMeta,
          operationType.isAcceptableOrUnknown(
              data['operation_type']!, _operationTypeMeta));
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('reference_id')) {
      context.handle(
          _referenceIdMeta,
          referenceId.isAcceptableOrUnknown(
              data['reference_id']!, _referenceIdMeta));
    } else if (isInserting) {
      context.missing(_referenceIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('queued_at')) {
      context.handle(_queuedAtMeta,
          queuedAt.isAcceptableOrUnknown(data['queued_at']!, _queuedAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      operationType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation_type'])!,
      referenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      queuedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}queued_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      idempotencyKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}idempotency_key']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id']),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String operationType;
  final String referenceId;
  final String payload;
  final DateTime queuedAt;
  final bool synced;
  final DateTime? syncedAt;

  /// Sent as Idempotency-Key, unchanged on every retry of this command.
  final String? idempotencyKey;

  /// pending · synced · conflicted (the server answered 409) · failed (any other refusal) · dismissed
  final String status;
  final int attempts;

  /// The server's problem details for a conflicted or failed command, as JSON.
  final String? lastError;
  final String? warehouseId;
  const SyncQueueData(
      {required this.id,
      required this.operationType,
      required this.referenceId,
      required this.payload,
      required this.queuedAt,
      required this.synced,
      this.syncedAt,
      this.idempotencyKey,
      required this.status,
      required this.attempts,
      this.lastError,
      this.warehouseId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation_type'] = Variable<String>(operationType);
    map['reference_id'] = Variable<String>(referenceId);
    map['payload'] = Variable<String>(payload);
    map['queued_at'] = Variable<DateTime>(queuedAt);
    map['synced'] = Variable<bool>(synced);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    if (!nullToAbsent || idempotencyKey != null) {
      map['idempotency_key'] = Variable<String>(idempotencyKey);
    }
    map['status'] = Variable<String>(status);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || warehouseId != null) {
      map['warehouse_id'] = Variable<String>(warehouseId);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      operationType: Value(operationType),
      referenceId: Value(referenceId),
      payload: Value(payload),
      queuedAt: Value(queuedAt),
      synced: Value(synced),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      idempotencyKey: idempotencyKey == null && nullToAbsent
          ? const Value.absent()
          : Value(idempotencyKey),
      status: Value(status),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      warehouseId: warehouseId == null && nullToAbsent
          ? const Value.absent()
          : Value(warehouseId),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      operationType: serializer.fromJson<String>(json['operationType']),
      referenceId: serializer.fromJson<String>(json['referenceId']),
      payload: serializer.fromJson<String>(json['payload']),
      queuedAt: serializer.fromJson<DateTime>(json['queuedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      idempotencyKey: serializer.fromJson<String?>(json['idempotencyKey']),
      status: serializer.fromJson<String>(json['status']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      warehouseId: serializer.fromJson<String?>(json['warehouseId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operationType': serializer.toJson<String>(operationType),
      'referenceId': serializer.toJson<String>(referenceId),
      'payload': serializer.toJson<String>(payload),
      'queuedAt': serializer.toJson<DateTime>(queuedAt),
      'synced': serializer.toJson<bool>(synced),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'idempotencyKey': serializer.toJson<String?>(idempotencyKey),
      'status': serializer.toJson<String>(status),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
      'warehouseId': serializer.toJson<String?>(warehouseId),
    };
  }

  SyncQueueData copyWith(
          {int? id,
          String? operationType,
          String? referenceId,
          String? payload,
          DateTime? queuedAt,
          bool? synced,
          Value<DateTime?> syncedAt = const Value.absent(),
          Value<String?> idempotencyKey = const Value.absent(),
          String? status,
          int? attempts,
          Value<String?> lastError = const Value.absent(),
          Value<String?> warehouseId = const Value.absent()}) =>
      SyncQueueData(
        id: id ?? this.id,
        operationType: operationType ?? this.operationType,
        referenceId: referenceId ?? this.referenceId,
        payload: payload ?? this.payload,
        queuedAt: queuedAt ?? this.queuedAt,
        synced: synced ?? this.synced,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        idempotencyKey:
            idempotencyKey.present ? idempotencyKey.value : this.idempotencyKey,
        status: status ?? this.status,
        attempts: attempts ?? this.attempts,
        lastError: lastError.present ? lastError.value : this.lastError,
        warehouseId: warehouseId.present ? warehouseId.value : this.warehouseId,
      );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      referenceId:
          data.referenceId.present ? data.referenceId.value : this.referenceId,
      payload: data.payload.present ? data.payload.value : this.payload,
      queuedAt: data.queuedAt.present ? data.queuedAt.value : this.queuedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('operationType: $operationType, ')
          ..write('referenceId: $referenceId, ')
          ..write('payload: $payload, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('synced: $synced, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('warehouseId: $warehouseId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      operationType,
      referenceId,
      payload,
      queuedAt,
      synced,
      syncedAt,
      idempotencyKey,
      status,
      attempts,
      lastError,
      warehouseId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.operationType == this.operationType &&
          other.referenceId == this.referenceId &&
          other.payload == this.payload &&
          other.queuedAt == this.queuedAt &&
          other.synced == this.synced &&
          other.syncedAt == this.syncedAt &&
          other.idempotencyKey == this.idempotencyKey &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.warehouseId == this.warehouseId);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> operationType;
  final Value<String> referenceId;
  final Value<String> payload;
  final Value<DateTime> queuedAt;
  final Value<bool> synced;
  final Value<DateTime?> syncedAt;
  final Value<String?> idempotencyKey;
  final Value<String> status;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<String?> warehouseId;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.operationType = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.payload = const Value.absent(),
    this.queuedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.warehouseId = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String operationType,
    required String referenceId,
    required String payload,
    this.queuedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.warehouseId = const Value.absent(),
  })  : operationType = Value(operationType),
        referenceId = Value(referenceId),
        payload = Value(payload);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? operationType,
    Expression<String>? referenceId,
    Expression<String>? payload,
    Expression<DateTime>? queuedAt,
    Expression<bool>? synced,
    Expression<DateTime>? syncedAt,
    Expression<String>? idempotencyKey,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<String>? warehouseId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationType != null) 'operation_type': operationType,
      if (referenceId != null) 'reference_id': referenceId,
      if (payload != null) 'payload': payload,
      if (queuedAt != null) 'queued_at': queuedAt,
      if (synced != null) 'synced': synced,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (warehouseId != null) 'warehouse_id': warehouseId,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? operationType,
      Value<String>? referenceId,
      Value<String>? payload,
      Value<DateTime>? queuedAt,
      Value<bool>? synced,
      Value<DateTime?>? syncedAt,
      Value<String?>? idempotencyKey,
      Value<String>? status,
      Value<int>? attempts,
      Value<String?>? lastError,
      Value<String?>? warehouseId}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      referenceId: referenceId ?? this.referenceId,
      payload: payload ?? this.payload,
      queuedAt: queuedAt ?? this.queuedAt,
      synced: synced ?? this.synced,
      syncedAt: syncedAt ?? this.syncedAt,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      warehouseId: warehouseId ?? this.warehouseId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (queuedAt.present) {
      map['queued_at'] = Variable<DateTime>(queuedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('operationType: $operationType, ')
          ..write('referenceId: $referenceId, ')
          ..write('payload: $payload, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('synced: $synced, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('warehouseId: $warehouseId')
          ..write(')'))
        .toString();
  }
}

class $CatalogItemsTable extends CatalogItems
    with TableInfo<$CatalogItemsTable, CatalogItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _uomMeta = const VerificationMeta('uom');
  @override
  late final GeneratedColumn<String> uom = GeneratedColumn<String>(
      'uom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [id, sku, name, uom, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_items';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('uom')) {
      context.handle(
          _uomMeta, uom.isAcceptableOrUnknown(data['uom']!, _uomMeta));
    } else if (isInserting) {
      context.missing(_uomMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      uom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uom'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $CatalogItemsTable createAlias(String alias) {
    return $CatalogItemsTable(attachedDatabase, alias);
  }
}

class CatalogItemRow extends DataClass implements Insertable<CatalogItemRow> {
  final String id;
  final String sku;
  final String name;
  final String uom;
  final bool isActive;
  const CatalogItemRow(
      {required this.id,
      required this.sku,
      required this.name,
      required this.uom,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sku'] = Variable<String>(sku);
    map['name'] = Variable<String>(name);
    map['uom'] = Variable<String>(uom);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CatalogItemsCompanion toCompanion(bool nullToAbsent) {
    return CatalogItemsCompanion(
      id: Value(id),
      sku: Value(sku),
      name: Value(name),
      uom: Value(uom),
      isActive: Value(isActive),
    );
  }

  factory CatalogItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogItemRow(
      id: serializer.fromJson<String>(json['id']),
      sku: serializer.fromJson<String>(json['sku']),
      name: serializer.fromJson<String>(json['name']),
      uom: serializer.fromJson<String>(json['uom']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sku': serializer.toJson<String>(sku),
      'name': serializer.toJson<String>(name),
      'uom': serializer.toJson<String>(uom),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  CatalogItemRow copyWith(
          {String? id,
          String? sku,
          String? name,
          String? uom,
          bool? isActive}) =>
      CatalogItemRow(
        id: id ?? this.id,
        sku: sku ?? this.sku,
        name: name ?? this.name,
        uom: uom ?? this.uom,
        isActive: isActive ?? this.isActive,
      );
  CatalogItemRow copyWithCompanion(CatalogItemsCompanion data) {
    return CatalogItemRow(
      id: data.id.present ? data.id.value : this.id,
      sku: data.sku.present ? data.sku.value : this.sku,
      name: data.name.present ? data.name.value : this.name,
      uom: data.uom.present ? data.uom.value : this.uom,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemRow(')
          ..write('id: $id, ')
          ..write('sku: $sku, ')
          ..write('name: $name, ')
          ..write('uom: $uom, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sku, name, uom, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogItemRow &&
          other.id == this.id &&
          other.sku == this.sku &&
          other.name == this.name &&
          other.uom == this.uom &&
          other.isActive == this.isActive);
}

class CatalogItemsCompanion extends UpdateCompanion<CatalogItemRow> {
  final Value<String> id;
  final Value<String> sku;
  final Value<String> name;
  final Value<String> uom;
  final Value<bool> isActive;
  final Value<int> rowid;
  const CatalogItemsCompanion({
    this.id = const Value.absent(),
    this.sku = const Value.absent(),
    this.name = const Value.absent(),
    this.uom = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogItemsCompanion.insert({
    required String id,
    required String sku,
    required String name,
    required String uom,
    required bool isActive,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sku = Value(sku),
        name = Value(name),
        uom = Value(uom),
        isActive = Value(isActive);
  static Insertable<CatalogItemRow> custom({
    Expression<String>? id,
    Expression<String>? sku,
    Expression<String>? name,
    Expression<String>? uom,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sku != null) 'sku': sku,
      if (name != null) 'name': name,
      if (uom != null) 'uom': uom,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sku,
      Value<String>? name,
      Value<String>? uom,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return CatalogItemsCompanion(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      uom: uom ?? this.uom,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (uom.present) {
      map['uom'] = Variable<String>(uom.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemsCompanion(')
          ..write('id: $id, ')
          ..write('sku: $sku, ')
          ..write('name: $name, ')
          ..write('uom: $uom, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogBarcodesTable extends CatalogBarcodes
    with TableInfo<$CatalogBarcodesTable, CatalogBarcodeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogBarcodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, itemId, code];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_barcodes';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogBarcodeRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogBarcodeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogBarcodeRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
    );
  }

  @override
  $CatalogBarcodesTable createAlias(String alias) {
    return $CatalogBarcodesTable(attachedDatabase, alias);
  }
}

class CatalogBarcodeRow extends DataClass
    implements Insertable<CatalogBarcodeRow> {
  final String id;
  final String itemId;
  final String code;
  const CatalogBarcodeRow(
      {required this.id, required this.itemId, required this.code});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['code'] = Variable<String>(code);
    return map;
  }

  CatalogBarcodesCompanion toCompanion(bool nullToAbsent) {
    return CatalogBarcodesCompanion(
      id: Value(id),
      itemId: Value(itemId),
      code: Value(code),
    );
  }

  factory CatalogBarcodeRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogBarcodeRow(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      code: serializer.fromJson<String>(json['code']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'code': serializer.toJson<String>(code),
    };
  }

  CatalogBarcodeRow copyWith({String? id, String? itemId, String? code}) =>
      CatalogBarcodeRow(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        code: code ?? this.code,
      );
  CatalogBarcodeRow copyWithCompanion(CatalogBarcodesCompanion data) {
    return CatalogBarcodeRow(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      code: data.code.present ? data.code.value : this.code,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogBarcodeRow(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('code: $code')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, itemId, code);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogBarcodeRow &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.code == this.code);
}

class CatalogBarcodesCompanion extends UpdateCompanion<CatalogBarcodeRow> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> code;
  final Value<int> rowid;
  const CatalogBarcodesCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.code = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogBarcodesCompanion.insert({
    required String id,
    required String itemId,
    required String code,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        code = Value(code);
  static Insertable<CatalogBarcodeRow> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? code,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (code != null) 'code': code,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogBarcodesCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<String>? code,
      Value<int>? rowid}) {
    return CatalogBarcodesCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      code: code ?? this.code,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogBarcodesCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('code: $code, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WarehouseLocationsTable extends WarehouseLocations
    with TableInfo<$WarehouseLocationsTable, WarehouseLocationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WarehouseLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, warehouseId, code, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'warehouse_locations';
  @override
  VerificationContext validateIntegrity(
      Insertable<WarehouseLocationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    } else if (isInserting) {
      context.missing(_warehouseIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WarehouseLocationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WarehouseLocationRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
    );
  }

  @override
  $WarehouseLocationsTable createAlias(String alias) {
    return $WarehouseLocationsTable(attachedDatabase, alias);
  }
}

class WarehouseLocationRow extends DataClass
    implements Insertable<WarehouseLocationRow> {
  final String id;
  final String warehouseId;
  final String code;
  final String type;
  const WarehouseLocationRow(
      {required this.id,
      required this.warehouseId,
      required this.code,
      required this.type});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['warehouse_id'] = Variable<String>(warehouseId);
    map['code'] = Variable<String>(code);
    map['type'] = Variable<String>(type);
    return map;
  }

  WarehouseLocationsCompanion toCompanion(bool nullToAbsent) {
    return WarehouseLocationsCompanion(
      id: Value(id),
      warehouseId: Value(warehouseId),
      code: Value(code),
      type: Value(type),
    );
  }

  factory WarehouseLocationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WarehouseLocationRow(
      id: serializer.fromJson<String>(json['id']),
      warehouseId: serializer.fromJson<String>(json['warehouseId']),
      code: serializer.fromJson<String>(json['code']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'warehouseId': serializer.toJson<String>(warehouseId),
      'code': serializer.toJson<String>(code),
      'type': serializer.toJson<String>(type),
    };
  }

  WarehouseLocationRow copyWith(
          {String? id, String? warehouseId, String? code, String? type}) =>
      WarehouseLocationRow(
        id: id ?? this.id,
        warehouseId: warehouseId ?? this.warehouseId,
        code: code ?? this.code,
        type: type ?? this.type,
      );
  WarehouseLocationRow copyWithCompanion(WarehouseLocationsCompanion data) {
    return WarehouseLocationRow(
      id: data.id.present ? data.id.value : this.id,
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      code: data.code.present ? data.code.value : this.code,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WarehouseLocationRow(')
          ..write('id: $id, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('code: $code, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, warehouseId, code, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WarehouseLocationRow &&
          other.id == this.id &&
          other.warehouseId == this.warehouseId &&
          other.code == this.code &&
          other.type == this.type);
}

class WarehouseLocationsCompanion
    extends UpdateCompanion<WarehouseLocationRow> {
  final Value<String> id;
  final Value<String> warehouseId;
  final Value<String> code;
  final Value<String> type;
  final Value<int> rowid;
  const WarehouseLocationsCompanion({
    this.id = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.code = const Value.absent(),
    this.type = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WarehouseLocationsCompanion.insert({
    required String id,
    required String warehouseId,
    required String code,
    required String type,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        warehouseId = Value(warehouseId),
        code = Value(code),
        type = Value(type);
  static Insertable<WarehouseLocationRow> custom({
    Expression<String>? id,
    Expression<String>? warehouseId,
    Expression<String>? code,
    Expression<String>? type,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (code != null) 'code': code,
      if (type != null) 'type': type,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WarehouseLocationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? warehouseId,
      Value<String>? code,
      Value<String>? type,
      Value<int>? rowid}) {
    return WarehouseLocationsCompanion(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      code: code ?? this.code,
      type: type ?? this.type,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WarehouseLocationsCompanion(')
          ..write('id: $id, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('code: $code, ')
          ..write('type: $type, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemoteCountSessionsTable extends RemoteCountSessions
    with TableInfo<$RemoteCountSessionsTable, RemoteCountSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemoteCountSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdByUserIdMeta =
      const VerificationMeta('createdByUserId');
  @override
  late final GeneratedColumn<String> createdByUserId = GeneratedColumn<String>(
      'created_by_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _submittedAtMeta =
      const VerificationMeta('submittedAt');
  @override
  late final GeneratedColumn<DateTime> submittedAt = GeneratedColumn<DateTime>(
      'submitted_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _reviewedAtMeta =
      const VerificationMeta('reviewedAt');
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
      'reviewed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _rejectReasonMeta =
      const VerificationMeta('rejectReason');
  @override
  late final GeneratedColumn<String> rejectReason = GeneratedColumn<String>(
      'reject_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        warehouseId,
        createdByUserId,
        label,
        status,
        submittedAt,
        reviewedAt,
        rejectReason
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remote_count_sessions';
  @override
  VerificationContext validateIntegrity(
      Insertable<RemoteCountSessionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    } else if (isInserting) {
      context.missing(_warehouseIdMeta);
    }
    if (data.containsKey('created_by_user_id')) {
      context.handle(
          _createdByUserIdMeta,
          createdByUserId.isAcceptableOrUnknown(
              data['created_by_user_id']!, _createdByUserIdMeta));
    } else if (isInserting) {
      context.missing(_createdByUserIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
          _submittedAtMeta,
          submittedAt.isAcceptableOrUnknown(
              data['submitted_at']!, _submittedAtMeta));
    } else if (isInserting) {
      context.missing(_submittedAtMeta);
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
          _reviewedAtMeta,
          reviewedAt.isAcceptableOrUnknown(
              data['reviewed_at']!, _reviewedAtMeta));
    }
    if (data.containsKey('reject_reason')) {
      context.handle(
          _rejectReasonMeta,
          rejectReason.isAcceptableOrUnknown(
              data['reject_reason']!, _rejectReasonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RemoteCountSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemoteCountSessionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id'])!,
      createdByUserId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}created_by_user_id'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      submittedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}submitted_at'])!,
      reviewedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}reviewed_at']),
      rejectReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reject_reason']),
    );
  }

  @override
  $RemoteCountSessionsTable createAlias(String alias) {
    return $RemoteCountSessionsTable(attachedDatabase, alias);
  }
}

class RemoteCountSessionRow extends DataClass
    implements Insertable<RemoteCountSessionRow> {
  final String id;
  final String warehouseId;
  final String createdByUserId;
  final String? label;
  final String status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? rejectReason;
  const RemoteCountSessionRow(
      {required this.id,
      required this.warehouseId,
      required this.createdByUserId,
      this.label,
      required this.status,
      required this.submittedAt,
      this.reviewedAt,
      this.rejectReason});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['warehouse_id'] = Variable<String>(warehouseId);
    map['created_by_user_id'] = Variable<String>(createdByUserId);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['status'] = Variable<String>(status);
    map['submitted_at'] = Variable<DateTime>(submittedAt);
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    }
    if (!nullToAbsent || rejectReason != null) {
      map['reject_reason'] = Variable<String>(rejectReason);
    }
    return map;
  }

  RemoteCountSessionsCompanion toCompanion(bool nullToAbsent) {
    return RemoteCountSessionsCompanion(
      id: Value(id),
      warehouseId: Value(warehouseId),
      createdByUserId: Value(createdByUserId),
      label:
          label == null && nullToAbsent ? const Value.absent() : Value(label),
      status: Value(status),
      submittedAt: Value(submittedAt),
      reviewedAt: reviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedAt),
      rejectReason: rejectReason == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectReason),
    );
  }

  factory RemoteCountSessionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemoteCountSessionRow(
      id: serializer.fromJson<String>(json['id']),
      warehouseId: serializer.fromJson<String>(json['warehouseId']),
      createdByUserId: serializer.fromJson<String>(json['createdByUserId']),
      label: serializer.fromJson<String?>(json['label']),
      status: serializer.fromJson<String>(json['status']),
      submittedAt: serializer.fromJson<DateTime>(json['submittedAt']),
      reviewedAt: serializer.fromJson<DateTime?>(json['reviewedAt']),
      rejectReason: serializer.fromJson<String?>(json['rejectReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'warehouseId': serializer.toJson<String>(warehouseId),
      'createdByUserId': serializer.toJson<String>(createdByUserId),
      'label': serializer.toJson<String?>(label),
      'status': serializer.toJson<String>(status),
      'submittedAt': serializer.toJson<DateTime>(submittedAt),
      'reviewedAt': serializer.toJson<DateTime?>(reviewedAt),
      'rejectReason': serializer.toJson<String?>(rejectReason),
    };
  }

  RemoteCountSessionRow copyWith(
          {String? id,
          String? warehouseId,
          String? createdByUserId,
          Value<String?> label = const Value.absent(),
          String? status,
          DateTime? submittedAt,
          Value<DateTime?> reviewedAt = const Value.absent(),
          Value<String?> rejectReason = const Value.absent()}) =>
      RemoteCountSessionRow(
        id: id ?? this.id,
        warehouseId: warehouseId ?? this.warehouseId,
        createdByUserId: createdByUserId ?? this.createdByUserId,
        label: label.present ? label.value : this.label,
        status: status ?? this.status,
        submittedAt: submittedAt ?? this.submittedAt,
        reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
        rejectReason:
            rejectReason.present ? rejectReason.value : this.rejectReason,
      );
  RemoteCountSessionRow copyWithCompanion(RemoteCountSessionsCompanion data) {
    return RemoteCountSessionRow(
      id: data.id.present ? data.id.value : this.id,
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      createdByUserId: data.createdByUserId.present
          ? data.createdByUserId.value
          : this.createdByUserId,
      label: data.label.present ? data.label.value : this.label,
      status: data.status.present ? data.status.value : this.status,
      submittedAt:
          data.submittedAt.present ? data.submittedAt.value : this.submittedAt,
      reviewedAt:
          data.reviewedAt.present ? data.reviewedAt.value : this.reviewedAt,
      rejectReason: data.rejectReason.present
          ? data.rejectReason.value
          : this.rejectReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemoteCountSessionRow(')
          ..write('id: $id, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('label: $label, ')
          ..write('status: $status, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('rejectReason: $rejectReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, warehouseId, createdByUserId, label,
      status, submittedAt, reviewedAt, rejectReason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemoteCountSessionRow &&
          other.id == this.id &&
          other.warehouseId == this.warehouseId &&
          other.createdByUserId == this.createdByUserId &&
          other.label == this.label &&
          other.status == this.status &&
          other.submittedAt == this.submittedAt &&
          other.reviewedAt == this.reviewedAt &&
          other.rejectReason == this.rejectReason);
}

class RemoteCountSessionsCompanion
    extends UpdateCompanion<RemoteCountSessionRow> {
  final Value<String> id;
  final Value<String> warehouseId;
  final Value<String> createdByUserId;
  final Value<String?> label;
  final Value<String> status;
  final Value<DateTime> submittedAt;
  final Value<DateTime?> reviewedAt;
  final Value<String?> rejectReason;
  final Value<int> rowid;
  const RemoteCountSessionsCompanion({
    this.id = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.createdByUserId = const Value.absent(),
    this.label = const Value.absent(),
    this.status = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.rejectReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemoteCountSessionsCompanion.insert({
    required String id,
    required String warehouseId,
    required String createdByUserId,
    this.label = const Value.absent(),
    required String status,
    required DateTime submittedAt,
    this.reviewedAt = const Value.absent(),
    this.rejectReason = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        warehouseId = Value(warehouseId),
        createdByUserId = Value(createdByUserId),
        status = Value(status),
        submittedAt = Value(submittedAt);
  static Insertable<RemoteCountSessionRow> custom({
    Expression<String>? id,
    Expression<String>? warehouseId,
    Expression<String>? createdByUserId,
    Expression<String>? label,
    Expression<String>? status,
    Expression<DateTime>? submittedAt,
    Expression<DateTime>? reviewedAt,
    Expression<String>? rejectReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (createdByUserId != null) 'created_by_user_id': createdByUserId,
      if (label != null) 'label': label,
      if (status != null) 'status': status,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (rejectReason != null) 'reject_reason': rejectReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemoteCountSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? warehouseId,
      Value<String>? createdByUserId,
      Value<String?>? label,
      Value<String>? status,
      Value<DateTime>? submittedAt,
      Value<DateTime?>? reviewedAt,
      Value<String?>? rejectReason,
      Value<int>? rowid}) {
    return RemoteCountSessionsCompanion(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      label: label ?? this.label,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectReason: rejectReason ?? this.rejectReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (createdByUserId.present) {
      map['created_by_user_id'] = Variable<String>(createdByUserId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<DateTime>(submittedAt.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (rejectReason.present) {
      map['reject_reason'] = Variable<String>(rejectReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemoteCountSessionsCompanion(')
          ..write('id: $id, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('label: $label, ')
          ..write('status: $status, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('rejectReason: $rejectReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemoteCountLinesTable extends RemoteCountLines
    with TableInfo<$RemoteCountLinesTable, RemoteCountLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemoteCountLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationIdMeta =
      const VerificationMeta('locationId');
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
      'location_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _countedMeta =
      const VerificationMeta('counted');
  @override
  late final GeneratedColumn<double> counted = GeneratedColumn<double>(
      'counted', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _systemAtSubmitMeta =
      const VerificationMeta('systemAtSubmit');
  @override
  late final GeneratedColumn<double> systemAtSubmit = GeneratedColumn<double>(
      'system_at_submit', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _adjustmentMeta =
      const VerificationMeta('adjustment');
  @override
  late final GeneratedColumn<double> adjustment = GeneratedColumn<double>(
      'adjustment', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sessionId, itemId, locationId, counted, systemAtSubmit, adjustment];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remote_count_lines';
  @override
  VerificationContext validateIntegrity(Insertable<RemoteCountLineRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('location_id')) {
      context.handle(
          _locationIdMeta,
          locationId.isAcceptableOrUnknown(
              data['location_id']!, _locationIdMeta));
    } else if (isInserting) {
      context.missing(_locationIdMeta);
    }
    if (data.containsKey('counted')) {
      context.handle(_countedMeta,
          counted.isAcceptableOrUnknown(data['counted']!, _countedMeta));
    } else if (isInserting) {
      context.missing(_countedMeta);
    }
    if (data.containsKey('system_at_submit')) {
      context.handle(
          _systemAtSubmitMeta,
          systemAtSubmit.isAcceptableOrUnknown(
              data['system_at_submit']!, _systemAtSubmitMeta));
    } else if (isInserting) {
      context.missing(_systemAtSubmitMeta);
    }
    if (data.containsKey('adjustment')) {
      context.handle(
          _adjustmentMeta,
          adjustment.isAcceptableOrUnknown(
              data['adjustment']!, _adjustmentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RemoteCountLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemoteCountLineRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      locationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_id'])!,
      counted: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}counted'])!,
      systemAtSubmit: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}system_at_submit'])!,
      adjustment: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}adjustment']),
    );
  }

  @override
  $RemoteCountLinesTable createAlias(String alias) {
    return $RemoteCountLinesTable(attachedDatabase, alias);
  }
}

class RemoteCountLineRow extends DataClass
    implements Insertable<RemoteCountLineRow> {
  final String id;
  final String sessionId;
  final String itemId;
  final String locationId;
  final double counted;
  final double systemAtSubmit;
  final double? adjustment;
  const RemoteCountLineRow(
      {required this.id,
      required this.sessionId,
      required this.itemId,
      required this.locationId,
      required this.counted,
      required this.systemAtSubmit,
      this.adjustment});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['item_id'] = Variable<String>(itemId);
    map['location_id'] = Variable<String>(locationId);
    map['counted'] = Variable<double>(counted);
    map['system_at_submit'] = Variable<double>(systemAtSubmit);
    if (!nullToAbsent || adjustment != null) {
      map['adjustment'] = Variable<double>(adjustment);
    }
    return map;
  }

  RemoteCountLinesCompanion toCompanion(bool nullToAbsent) {
    return RemoteCountLinesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      itemId: Value(itemId),
      locationId: Value(locationId),
      counted: Value(counted),
      systemAtSubmit: Value(systemAtSubmit),
      adjustment: adjustment == null && nullToAbsent
          ? const Value.absent()
          : Value(adjustment),
    );
  }

  factory RemoteCountLineRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemoteCountLineRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      locationId: serializer.fromJson<String>(json['locationId']),
      counted: serializer.fromJson<double>(json['counted']),
      systemAtSubmit: serializer.fromJson<double>(json['systemAtSubmit']),
      adjustment: serializer.fromJson<double?>(json['adjustment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'itemId': serializer.toJson<String>(itemId),
      'locationId': serializer.toJson<String>(locationId),
      'counted': serializer.toJson<double>(counted),
      'systemAtSubmit': serializer.toJson<double>(systemAtSubmit),
      'adjustment': serializer.toJson<double?>(adjustment),
    };
  }

  RemoteCountLineRow copyWith(
          {String? id,
          String? sessionId,
          String? itemId,
          String? locationId,
          double? counted,
          double? systemAtSubmit,
          Value<double?> adjustment = const Value.absent()}) =>
      RemoteCountLineRow(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        itemId: itemId ?? this.itemId,
        locationId: locationId ?? this.locationId,
        counted: counted ?? this.counted,
        systemAtSubmit: systemAtSubmit ?? this.systemAtSubmit,
        adjustment: adjustment.present ? adjustment.value : this.adjustment,
      );
  RemoteCountLineRow copyWithCompanion(RemoteCountLinesCompanion data) {
    return RemoteCountLineRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      locationId:
          data.locationId.present ? data.locationId.value : this.locationId,
      counted: data.counted.present ? data.counted.value : this.counted,
      systemAtSubmit: data.systemAtSubmit.present
          ? data.systemAtSubmit.value
          : this.systemAtSubmit,
      adjustment:
          data.adjustment.present ? data.adjustment.value : this.adjustment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemoteCountLineRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('itemId: $itemId, ')
          ..write('locationId: $locationId, ')
          ..write('counted: $counted, ')
          ..write('systemAtSubmit: $systemAtSubmit, ')
          ..write('adjustment: $adjustment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, sessionId, itemId, locationId, counted, systemAtSubmit, adjustment);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemoteCountLineRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.itemId == this.itemId &&
          other.locationId == this.locationId &&
          other.counted == this.counted &&
          other.systemAtSubmit == this.systemAtSubmit &&
          other.adjustment == this.adjustment);
}

class RemoteCountLinesCompanion extends UpdateCompanion<RemoteCountLineRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> itemId;
  final Value<String> locationId;
  final Value<double> counted;
  final Value<double> systemAtSubmit;
  final Value<double?> adjustment;
  final Value<int> rowid;
  const RemoteCountLinesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.locationId = const Value.absent(),
    this.counted = const Value.absent(),
    this.systemAtSubmit = const Value.absent(),
    this.adjustment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemoteCountLinesCompanion.insert({
    required String id,
    required String sessionId,
    required String itemId,
    required String locationId,
    required double counted,
    required double systemAtSubmit,
    this.adjustment = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        itemId = Value(itemId),
        locationId = Value(locationId),
        counted = Value(counted),
        systemAtSubmit = Value(systemAtSubmit);
  static Insertable<RemoteCountLineRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? itemId,
    Expression<String>? locationId,
    Expression<double>? counted,
    Expression<double>? systemAtSubmit,
    Expression<double>? adjustment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (itemId != null) 'item_id': itemId,
      if (locationId != null) 'location_id': locationId,
      if (counted != null) 'counted': counted,
      if (systemAtSubmit != null) 'system_at_submit': systemAtSubmit,
      if (adjustment != null) 'adjustment': adjustment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemoteCountLinesCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<String>? itemId,
      Value<String>? locationId,
      Value<double>? counted,
      Value<double>? systemAtSubmit,
      Value<double?>? adjustment,
      Value<int>? rowid}) {
    return RemoteCountLinesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      itemId: itemId ?? this.itemId,
      locationId: locationId ?? this.locationId,
      counted: counted ?? this.counted,
      systemAtSubmit: systemAtSubmit ?? this.systemAtSubmit,
      adjustment: adjustment ?? this.adjustment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (counted.present) {
      map['counted'] = Variable<double>(counted.value);
    }
    if (systemAtSubmit.present) {
      map['system_at_submit'] = Variable<double>(systemAtSubmit.value);
    }
    if (adjustment.present) {
      map['adjustment'] = Variable<double>(adjustment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemoteCountLinesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('itemId: $itemId, ')
          ..write('locationId: $locationId, ')
          ..write('counted: $counted, ')
          ..write('systemAtSubmit: $systemAtSubmit, ')
          ..write('adjustment: $adjustment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<int> cursor = GeneratedColumn<int>(
      'cursor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _mirrorVersionMeta =
      const VerificationMeta('mirrorVersion');
  @override
  late final GeneratedColumn<int> mirrorVersion = GeneratedColumn<int>(
      'mirror_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _caughtUpThroughMeta =
      const VerificationMeta('caughtUpThrough');
  @override
  late final GeneratedColumn<int> caughtUpThrough = GeneratedColumn<int>(
      'caught_up_through', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [warehouseId, cursor, mirrorVersion, caughtUpThrough];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(Insertable<SyncCursorRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    } else if (isInserting) {
      context.missing(_warehouseIdMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(_cursorMeta,
          cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta));
    } else if (isInserting) {
      context.missing(_cursorMeta);
    }
    if (data.containsKey('mirror_version')) {
      context.handle(
          _mirrorVersionMeta,
          mirrorVersion.isAcceptableOrUnknown(
              data['mirror_version']!, _mirrorVersionMeta));
    }
    if (data.containsKey('caught_up_through')) {
      context.handle(
          _caughtUpThroughMeta,
          caughtUpThrough.isAcceptableOrUnknown(
              data['caught_up_through']!, _caughtUpThroughMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {warehouseId};
  @override
  SyncCursorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursorRow(
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id'])!,
      cursor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cursor'])!,
      mirrorVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mirror_version'])!,
      caughtUpThrough: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}caught_up_through'])!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursorRow extends DataClass implements Insertable<SyncCursorRow> {
  final String warehouseId;
  final int cursor;

  /// The kMirrorVersion this cursor was saved under; an older one means "read again from the start".
  final int mirrorVersion;

  /// The last sync_queue id already sent when the latest complete pull began: what those commands did is in the
  /// copy. A command sent after it may not be yet.
  final int caughtUpThrough;
  const SyncCursorRow(
      {required this.warehouseId,
      required this.cursor,
      required this.mirrorVersion,
      required this.caughtUpThrough});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['warehouse_id'] = Variable<String>(warehouseId);
    map['cursor'] = Variable<int>(cursor);
    map['mirror_version'] = Variable<int>(mirrorVersion);
    map['caught_up_through'] = Variable<int>(caughtUpThrough);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      warehouseId: Value(warehouseId),
      cursor: Value(cursor),
      mirrorVersion: Value(mirrorVersion),
      caughtUpThrough: Value(caughtUpThrough),
    );
  }

  factory SyncCursorRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursorRow(
      warehouseId: serializer.fromJson<String>(json['warehouseId']),
      cursor: serializer.fromJson<int>(json['cursor']),
      mirrorVersion: serializer.fromJson<int>(json['mirrorVersion']),
      caughtUpThrough: serializer.fromJson<int>(json['caughtUpThrough']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'warehouseId': serializer.toJson<String>(warehouseId),
      'cursor': serializer.toJson<int>(cursor),
      'mirrorVersion': serializer.toJson<int>(mirrorVersion),
      'caughtUpThrough': serializer.toJson<int>(caughtUpThrough),
    };
  }

  SyncCursorRow copyWith(
          {String? warehouseId,
          int? cursor,
          int? mirrorVersion,
          int? caughtUpThrough}) =>
      SyncCursorRow(
        warehouseId: warehouseId ?? this.warehouseId,
        cursor: cursor ?? this.cursor,
        mirrorVersion: mirrorVersion ?? this.mirrorVersion,
        caughtUpThrough: caughtUpThrough ?? this.caughtUpThrough,
      );
  SyncCursorRow copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursorRow(
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      mirrorVersion: data.mirrorVersion.present
          ? data.mirrorVersion.value
          : this.mirrorVersion,
      caughtUpThrough: data.caughtUpThrough.present
          ? data.caughtUpThrough.value
          : this.caughtUpThrough,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorRow(')
          ..write('warehouseId: $warehouseId, ')
          ..write('cursor: $cursor, ')
          ..write('mirrorVersion: $mirrorVersion, ')
          ..write('caughtUpThrough: $caughtUpThrough')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(warehouseId, cursor, mirrorVersion, caughtUpThrough);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursorRow &&
          other.warehouseId == this.warehouseId &&
          other.cursor == this.cursor &&
          other.mirrorVersion == this.mirrorVersion &&
          other.caughtUpThrough == this.caughtUpThrough);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursorRow> {
  final Value<String> warehouseId;
  final Value<int> cursor;
  final Value<int> mirrorVersion;
  final Value<int> caughtUpThrough;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.warehouseId = const Value.absent(),
    this.cursor = const Value.absent(),
    this.mirrorVersion = const Value.absent(),
    this.caughtUpThrough = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String warehouseId,
    required int cursor,
    this.mirrorVersion = const Value.absent(),
    this.caughtUpThrough = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : warehouseId = Value(warehouseId),
        cursor = Value(cursor);
  static Insertable<SyncCursorRow> custom({
    Expression<String>? warehouseId,
    Expression<int>? cursor,
    Expression<int>? mirrorVersion,
    Expression<int>? caughtUpThrough,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (cursor != null) 'cursor': cursor,
      if (mirrorVersion != null) 'mirror_version': mirrorVersion,
      if (caughtUpThrough != null) 'caught_up_through': caughtUpThrough,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith(
      {Value<String>? warehouseId,
      Value<int>? cursor,
      Value<int>? mirrorVersion,
      Value<int>? caughtUpThrough,
      Value<int>? rowid}) {
    return SyncCursorsCompanion(
      warehouseId: warehouseId ?? this.warehouseId,
      cursor: cursor ?? this.cursor,
      mirrorVersion: mirrorVersion ?? this.mirrorVersion,
      caughtUpThrough: caughtUpThrough ?? this.caughtUpThrough,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<int>(cursor.value);
    }
    if (mirrorVersion.present) {
      map['mirror_version'] = Variable<int>(mirrorVersion.value);
    }
    if (caughtUpThrough.present) {
      map['caught_up_through'] = Variable<int>(caughtUpThrough.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('warehouseId: $warehouseId, ')
          ..write('cursor: $cursor, ')
          ..write('mirrorVersion: $mirrorVersion, ')
          ..write('caughtUpThrough: $caughtUpThrough, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemotePurchaseOrdersTable extends RemotePurchaseOrders
    with TableInfo<$RemotePurchaseOrdersTable, RemotePurchaseOrderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemotePurchaseOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
      'number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _supplierMeta =
      const VerificationMeta('supplier');
  @override
  late final GeneratedColumn<String> supplier = GeneratedColumn<String>(
      'supplier', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _expectedDateMeta =
      const VerificationMeta('expectedDate');
  @override
  late final GeneratedColumn<DateTime> expectedDate = GeneratedColumn<DateTime>(
      'expected_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, warehouseId, number, supplier, expectedDate, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remote_purchase_orders';
  @override
  VerificationContext validateIntegrity(
      Insertable<RemotePurchaseOrderRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    } else if (isInserting) {
      context.missing(_warehouseIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('supplier')) {
      context.handle(_supplierMeta,
          supplier.isAcceptableOrUnknown(data['supplier']!, _supplierMeta));
    } else if (isInserting) {
      context.missing(_supplierMeta);
    }
    if (data.containsKey('expected_date')) {
      context.handle(
          _expectedDateMeta,
          expectedDate.isAcceptableOrUnknown(
              data['expected_date']!, _expectedDateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RemotePurchaseOrderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemotePurchaseOrderRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id'])!,
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}number'])!,
      supplier: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier'])!,
      expectedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expected_date']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $RemotePurchaseOrdersTable createAlias(String alias) {
    return $RemotePurchaseOrdersTable(attachedDatabase, alias);
  }
}

class RemotePurchaseOrderRow extends DataClass
    implements Insertable<RemotePurchaseOrderRow> {
  final String id;
  final String warehouseId;
  final String number;
  final String supplier;
  final DateTime? expectedDate;
  final String status;
  const RemotePurchaseOrderRow(
      {required this.id,
      required this.warehouseId,
      required this.number,
      required this.supplier,
      this.expectedDate,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['warehouse_id'] = Variable<String>(warehouseId);
    map['number'] = Variable<String>(number);
    map['supplier'] = Variable<String>(supplier);
    if (!nullToAbsent || expectedDate != null) {
      map['expected_date'] = Variable<DateTime>(expectedDate);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  RemotePurchaseOrdersCompanion toCompanion(bool nullToAbsent) {
    return RemotePurchaseOrdersCompanion(
      id: Value(id),
      warehouseId: Value(warehouseId),
      number: Value(number),
      supplier: Value(supplier),
      expectedDate: expectedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedDate),
      status: Value(status),
    );
  }

  factory RemotePurchaseOrderRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemotePurchaseOrderRow(
      id: serializer.fromJson<String>(json['id']),
      warehouseId: serializer.fromJson<String>(json['warehouseId']),
      number: serializer.fromJson<String>(json['number']),
      supplier: serializer.fromJson<String>(json['supplier']),
      expectedDate: serializer.fromJson<DateTime?>(json['expectedDate']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'warehouseId': serializer.toJson<String>(warehouseId),
      'number': serializer.toJson<String>(number),
      'supplier': serializer.toJson<String>(supplier),
      'expectedDate': serializer.toJson<DateTime?>(expectedDate),
      'status': serializer.toJson<String>(status),
    };
  }

  RemotePurchaseOrderRow copyWith(
          {String? id,
          String? warehouseId,
          String? number,
          String? supplier,
          Value<DateTime?> expectedDate = const Value.absent(),
          String? status}) =>
      RemotePurchaseOrderRow(
        id: id ?? this.id,
        warehouseId: warehouseId ?? this.warehouseId,
        number: number ?? this.number,
        supplier: supplier ?? this.supplier,
        expectedDate:
            expectedDate.present ? expectedDate.value : this.expectedDate,
        status: status ?? this.status,
      );
  RemotePurchaseOrderRow copyWithCompanion(RemotePurchaseOrdersCompanion data) {
    return RemotePurchaseOrderRow(
      id: data.id.present ? data.id.value : this.id,
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      number: data.number.present ? data.number.value : this.number,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      expectedDate: data.expectedDate.present
          ? data.expectedDate.value
          : this.expectedDate,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemotePurchaseOrderRow(')
          ..write('id: $id, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('number: $number, ')
          ..write('supplier: $supplier, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, warehouseId, number, supplier, expectedDate, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemotePurchaseOrderRow &&
          other.id == this.id &&
          other.warehouseId == this.warehouseId &&
          other.number == this.number &&
          other.supplier == this.supplier &&
          other.expectedDate == this.expectedDate &&
          other.status == this.status);
}

class RemotePurchaseOrdersCompanion
    extends UpdateCompanion<RemotePurchaseOrderRow> {
  final Value<String> id;
  final Value<String> warehouseId;
  final Value<String> number;
  final Value<String> supplier;
  final Value<DateTime?> expectedDate;
  final Value<String> status;
  final Value<int> rowid;
  const RemotePurchaseOrdersCompanion({
    this.id = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.number = const Value.absent(),
    this.supplier = const Value.absent(),
    this.expectedDate = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemotePurchaseOrdersCompanion.insert({
    required String id,
    required String warehouseId,
    required String number,
    required String supplier,
    this.expectedDate = const Value.absent(),
    required String status,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        warehouseId = Value(warehouseId),
        number = Value(number),
        supplier = Value(supplier),
        status = Value(status);
  static Insertable<RemotePurchaseOrderRow> custom({
    Expression<String>? id,
    Expression<String>? warehouseId,
    Expression<String>? number,
    Expression<String>? supplier,
    Expression<DateTime>? expectedDate,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (number != null) 'number': number,
      if (supplier != null) 'supplier': supplier,
      if (expectedDate != null) 'expected_date': expectedDate,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemotePurchaseOrdersCompanion copyWith(
      {Value<String>? id,
      Value<String>? warehouseId,
      Value<String>? number,
      Value<String>? supplier,
      Value<DateTime?>? expectedDate,
      Value<String>? status,
      Value<int>? rowid}) {
    return RemotePurchaseOrdersCompanion(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      number: number ?? this.number,
      supplier: supplier ?? this.supplier,
      expectedDate: expectedDate ?? this.expectedDate,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (supplier.present) {
      map['supplier'] = Variable<String>(supplier.value);
    }
    if (expectedDate.present) {
      map['expected_date'] = Variable<DateTime>(expectedDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemotePurchaseOrdersCompanion(')
          ..write('id: $id, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('number: $number, ')
          ..write('supplier: $supplier, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemotePoLinesTable extends RemotePoLines
    with TableInfo<$RemotePoLinesTable, RemotePoLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemotePoLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purchaseOrderIdMeta =
      const VerificationMeta('purchaseOrderId');
  @override
  late final GeneratedColumn<String> purchaseOrderId = GeneratedColumn<String>(
      'purchase_order_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lineNoMeta = const VerificationMeta('lineNo');
  @override
  late final GeneratedColumn<int> lineNo = GeneratedColumn<int>(
      'line_no', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderedMeta =
      const VerificationMeta('ordered');
  @override
  late final GeneratedColumn<double> ordered = GeneratedColumn<double>(
      'ordered', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _receivedMeta =
      const VerificationMeta('received');
  @override
  late final GeneratedColumn<double> received = GeneratedColumn<double>(
      'received', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, purchaseOrderId, lineNo, itemId, ordered, received];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remote_po_lines';
  @override
  VerificationContext validateIntegrity(Insertable<RemotePoLineRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_order_id')) {
      context.handle(
          _purchaseOrderIdMeta,
          purchaseOrderId.isAcceptableOrUnknown(
              data['purchase_order_id']!, _purchaseOrderIdMeta));
    } else if (isInserting) {
      context.missing(_purchaseOrderIdMeta);
    }
    if (data.containsKey('line_no')) {
      context.handle(_lineNoMeta,
          lineNo.isAcceptableOrUnknown(data['line_no']!, _lineNoMeta));
    } else if (isInserting) {
      context.missing(_lineNoMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('ordered')) {
      context.handle(_orderedMeta,
          ordered.isAcceptableOrUnknown(data['ordered']!, _orderedMeta));
    } else if (isInserting) {
      context.missing(_orderedMeta);
    }
    if (data.containsKey('received')) {
      context.handle(_receivedMeta,
          received.isAcceptableOrUnknown(data['received']!, _receivedMeta));
    } else if (isInserting) {
      context.missing(_receivedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RemotePoLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemotePoLineRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      purchaseOrderId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}purchase_order_id'])!,
      lineNo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}line_no'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      ordered: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ordered'])!,
      received: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}received'])!,
    );
  }

  @override
  $RemotePoLinesTable createAlias(String alias) {
    return $RemotePoLinesTable(attachedDatabase, alias);
  }
}

class RemotePoLineRow extends DataClass implements Insertable<RemotePoLineRow> {
  final String id;
  final String purchaseOrderId;
  final int lineNo;
  final String itemId;
  final double ordered;
  final double received;
  const RemotePoLineRow(
      {required this.id,
      required this.purchaseOrderId,
      required this.lineNo,
      required this.itemId,
      required this.ordered,
      required this.received});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_order_id'] = Variable<String>(purchaseOrderId);
    map['line_no'] = Variable<int>(lineNo);
    map['item_id'] = Variable<String>(itemId);
    map['ordered'] = Variable<double>(ordered);
    map['received'] = Variable<double>(received);
    return map;
  }

  RemotePoLinesCompanion toCompanion(bool nullToAbsent) {
    return RemotePoLinesCompanion(
      id: Value(id),
      purchaseOrderId: Value(purchaseOrderId),
      lineNo: Value(lineNo),
      itemId: Value(itemId),
      ordered: Value(ordered),
      received: Value(received),
    );
  }

  factory RemotePoLineRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemotePoLineRow(
      id: serializer.fromJson<String>(json['id']),
      purchaseOrderId: serializer.fromJson<String>(json['purchaseOrderId']),
      lineNo: serializer.fromJson<int>(json['lineNo']),
      itemId: serializer.fromJson<String>(json['itemId']),
      ordered: serializer.fromJson<double>(json['ordered']),
      received: serializer.fromJson<double>(json['received']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchaseOrderId': serializer.toJson<String>(purchaseOrderId),
      'lineNo': serializer.toJson<int>(lineNo),
      'itemId': serializer.toJson<String>(itemId),
      'ordered': serializer.toJson<double>(ordered),
      'received': serializer.toJson<double>(received),
    };
  }

  RemotePoLineRow copyWith(
          {String? id,
          String? purchaseOrderId,
          int? lineNo,
          String? itemId,
          double? ordered,
          double? received}) =>
      RemotePoLineRow(
        id: id ?? this.id,
        purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
        lineNo: lineNo ?? this.lineNo,
        itemId: itemId ?? this.itemId,
        ordered: ordered ?? this.ordered,
        received: received ?? this.received,
      );
  RemotePoLineRow copyWithCompanion(RemotePoLinesCompanion data) {
    return RemotePoLineRow(
      id: data.id.present ? data.id.value : this.id,
      purchaseOrderId: data.purchaseOrderId.present
          ? data.purchaseOrderId.value
          : this.purchaseOrderId,
      lineNo: data.lineNo.present ? data.lineNo.value : this.lineNo,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      ordered: data.ordered.present ? data.ordered.value : this.ordered,
      received: data.received.present ? data.received.value : this.received,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemotePoLineRow(')
          ..write('id: $id, ')
          ..write('purchaseOrderId: $purchaseOrderId, ')
          ..write('lineNo: $lineNo, ')
          ..write('itemId: $itemId, ')
          ..write('ordered: $ordered, ')
          ..write('received: $received')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, purchaseOrderId, lineNo, itemId, ordered, received);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemotePoLineRow &&
          other.id == this.id &&
          other.purchaseOrderId == this.purchaseOrderId &&
          other.lineNo == this.lineNo &&
          other.itemId == this.itemId &&
          other.ordered == this.ordered &&
          other.received == this.received);
}

class RemotePoLinesCompanion extends UpdateCompanion<RemotePoLineRow> {
  final Value<String> id;
  final Value<String> purchaseOrderId;
  final Value<int> lineNo;
  final Value<String> itemId;
  final Value<double> ordered;
  final Value<double> received;
  final Value<int> rowid;
  const RemotePoLinesCompanion({
    this.id = const Value.absent(),
    this.purchaseOrderId = const Value.absent(),
    this.lineNo = const Value.absent(),
    this.itemId = const Value.absent(),
    this.ordered = const Value.absent(),
    this.received = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemotePoLinesCompanion.insert({
    required String id,
    required String purchaseOrderId,
    required int lineNo,
    required String itemId,
    required double ordered,
    required double received,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        purchaseOrderId = Value(purchaseOrderId),
        lineNo = Value(lineNo),
        itemId = Value(itemId),
        ordered = Value(ordered),
        received = Value(received);
  static Insertable<RemotePoLineRow> custom({
    Expression<String>? id,
    Expression<String>? purchaseOrderId,
    Expression<int>? lineNo,
    Expression<String>? itemId,
    Expression<double>? ordered,
    Expression<double>? received,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseOrderId != null) 'purchase_order_id': purchaseOrderId,
      if (lineNo != null) 'line_no': lineNo,
      if (itemId != null) 'item_id': itemId,
      if (ordered != null) 'ordered': ordered,
      if (received != null) 'received': received,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemotePoLinesCompanion copyWith(
      {Value<String>? id,
      Value<String>? purchaseOrderId,
      Value<int>? lineNo,
      Value<String>? itemId,
      Value<double>? ordered,
      Value<double>? received,
      Value<int>? rowid}) {
    return RemotePoLinesCompanion(
      id: id ?? this.id,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      lineNo: lineNo ?? this.lineNo,
      itemId: itemId ?? this.itemId,
      ordered: ordered ?? this.ordered,
      received: received ?? this.received,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (purchaseOrderId.present) {
      map['purchase_order_id'] = Variable<String>(purchaseOrderId.value);
    }
    if (lineNo.present) {
      map['line_no'] = Variable<int>(lineNo.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (ordered.present) {
      map['ordered'] = Variable<double>(ordered.value);
    }
    if (received.present) {
      map['received'] = Variable<double>(received.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemotePoLinesCompanion(')
          ..write('id: $id, ')
          ..write('purchaseOrderId: $purchaseOrderId, ')
          ..write('lineNo: $lineNo, ')
          ..write('itemId: $itemId, ')
          ..write('ordered: $ordered, ')
          ..write('received: $received, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemoteOrdersTable extends RemoteOrders
    with TableInfo<$RemoteOrdersTable, RemoteOrderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemoteOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
      'number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _destinationMeta =
      const VerificationMeta('destination');
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
      'destination', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _orderDateMeta =
      const VerificationMeta('orderDate');
  @override
  late final GeneratedColumn<DateTime> orderDate = GeneratedColumn<DateTime>(
      'order_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _requiresApprovalMeta =
      const VerificationMeta('requiresApproval');
  @override
  late final GeneratedColumn<bool> requiresApproval = GeneratedColumn<bool>(
      'requires_approval', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("requires_approval" IN (0, 1))'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByNameMeta =
      const VerificationMeta('createdByName');
  @override
  late final GeneratedColumn<String> createdByName = GeneratedColumn<String>(
      'created_by_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusHistoryMeta =
      const VerificationMeta('statusHistory');
  @override
  late final GeneratedColumn<String> statusHistory = GeneratedColumn<String>(
      'status_history', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        warehouseId,
        kind,
        number,
        destination,
        customerName,
        orderDate,
        status,
        requiresApproval,
        notes,
        createdByName,
        createdAt,
        statusHistory
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remote_orders';
  @override
  VerificationContext validateIntegrity(Insertable<RemoteOrderRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    } else if (isInserting) {
      context.missing(_warehouseIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('destination')) {
      context.handle(
          _destinationMeta,
          destination.isAcceptableOrUnknown(
              data['destination']!, _destinationMeta));
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    }
    if (data.containsKey('order_date')) {
      context.handle(_orderDateMeta,
          orderDate.isAcceptableOrUnknown(data['order_date']!, _orderDateMeta));
    } else if (isInserting) {
      context.missing(_orderDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('requires_approval')) {
      context.handle(
          _requiresApprovalMeta,
          requiresApproval.isAcceptableOrUnknown(
              data['requires_approval']!, _requiresApprovalMeta));
    } else if (isInserting) {
      context.missing(_requiresApprovalMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_by_name')) {
      context.handle(
          _createdByNameMeta,
          createdByName.isAcceptableOrUnknown(
              data['created_by_name']!, _createdByNameMeta));
    } else if (isInserting) {
      context.missing(_createdByNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('status_history')) {
      context.handle(
          _statusHistoryMeta,
          statusHistory.isAcceptableOrUnknown(
              data['status_history']!, _statusHistoryMeta));
    } else if (isInserting) {
      context.missing(_statusHistoryMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RemoteOrderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemoteOrderRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}number'])!,
      destination: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}destination']),
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name']),
      orderDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}order_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      requiresApproval: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}requires_approval'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdByName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}created_by_name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      statusHistory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status_history'])!,
    );
  }

  @override
  $RemoteOrdersTable createAlias(String alias) {
    return $RemoteOrdersTable(attachedDatabase, alias);
  }
}

class RemoteOrderRow extends DataClass implements Insertable<RemoteOrderRow> {
  final String id;
  final String warehouseId;
  final String kind;
  final String number;
  final String? destination;
  final String? customerName;
  final DateTime orderDate;
  final String status;
  final bool requiresApproval;
  final String? notes;
  final String createdByName;
  final DateTime createdAt;

  /// JSON: [{status, changedByName, changedAt}], oldest first.
  final String statusHistory;
  const RemoteOrderRow(
      {required this.id,
      required this.warehouseId,
      required this.kind,
      required this.number,
      this.destination,
      this.customerName,
      required this.orderDate,
      required this.status,
      required this.requiresApproval,
      this.notes,
      required this.createdByName,
      required this.createdAt,
      required this.statusHistory});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['warehouse_id'] = Variable<String>(warehouseId);
    map['kind'] = Variable<String>(kind);
    map['number'] = Variable<String>(number);
    if (!nullToAbsent || destination != null) {
      map['destination'] = Variable<String>(destination);
    }
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    map['order_date'] = Variable<DateTime>(orderDate);
    map['status'] = Variable<String>(status);
    map['requires_approval'] = Variable<bool>(requiresApproval);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by_name'] = Variable<String>(createdByName);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['status_history'] = Variable<String>(statusHistory);
    return map;
  }

  RemoteOrdersCompanion toCompanion(bool nullToAbsent) {
    return RemoteOrdersCompanion(
      id: Value(id),
      warehouseId: Value(warehouseId),
      kind: Value(kind),
      number: Value(number),
      destination: destination == null && nullToAbsent
          ? const Value.absent()
          : Value(destination),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      orderDate: Value(orderDate),
      status: Value(status),
      requiresApproval: Value(requiresApproval),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdByName: Value(createdByName),
      createdAt: Value(createdAt),
      statusHistory: Value(statusHistory),
    );
  }

  factory RemoteOrderRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemoteOrderRow(
      id: serializer.fromJson<String>(json['id']),
      warehouseId: serializer.fromJson<String>(json['warehouseId']),
      kind: serializer.fromJson<String>(json['kind']),
      number: serializer.fromJson<String>(json['number']),
      destination: serializer.fromJson<String?>(json['destination']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      orderDate: serializer.fromJson<DateTime>(json['orderDate']),
      status: serializer.fromJson<String>(json['status']),
      requiresApproval: serializer.fromJson<bool>(json['requiresApproval']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdByName: serializer.fromJson<String>(json['createdByName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      statusHistory: serializer.fromJson<String>(json['statusHistory']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'warehouseId': serializer.toJson<String>(warehouseId),
      'kind': serializer.toJson<String>(kind),
      'number': serializer.toJson<String>(number),
      'destination': serializer.toJson<String?>(destination),
      'customerName': serializer.toJson<String?>(customerName),
      'orderDate': serializer.toJson<DateTime>(orderDate),
      'status': serializer.toJson<String>(status),
      'requiresApproval': serializer.toJson<bool>(requiresApproval),
      'notes': serializer.toJson<String?>(notes),
      'createdByName': serializer.toJson<String>(createdByName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'statusHistory': serializer.toJson<String>(statusHistory),
    };
  }

  RemoteOrderRow copyWith(
          {String? id,
          String? warehouseId,
          String? kind,
          String? number,
          Value<String?> destination = const Value.absent(),
          Value<String?> customerName = const Value.absent(),
          DateTime? orderDate,
          String? status,
          bool? requiresApproval,
          Value<String?> notes = const Value.absent(),
          String? createdByName,
          DateTime? createdAt,
          String? statusHistory}) =>
      RemoteOrderRow(
        id: id ?? this.id,
        warehouseId: warehouseId ?? this.warehouseId,
        kind: kind ?? this.kind,
        number: number ?? this.number,
        destination: destination.present ? destination.value : this.destination,
        customerName:
            customerName.present ? customerName.value : this.customerName,
        orderDate: orderDate ?? this.orderDate,
        status: status ?? this.status,
        requiresApproval: requiresApproval ?? this.requiresApproval,
        notes: notes.present ? notes.value : this.notes,
        createdByName: createdByName ?? this.createdByName,
        createdAt: createdAt ?? this.createdAt,
        statusHistory: statusHistory ?? this.statusHistory,
      );
  RemoteOrderRow copyWithCompanion(RemoteOrdersCompanion data) {
    return RemoteOrderRow(
      id: data.id.present ? data.id.value : this.id,
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      kind: data.kind.present ? data.kind.value : this.kind,
      number: data.number.present ? data.number.value : this.number,
      destination:
          data.destination.present ? data.destination.value : this.destination,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      orderDate: data.orderDate.present ? data.orderDate.value : this.orderDate,
      status: data.status.present ? data.status.value : this.status,
      requiresApproval: data.requiresApproval.present
          ? data.requiresApproval.value
          : this.requiresApproval,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdByName: data.createdByName.present
          ? data.createdByName.value
          : this.createdByName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      statusHistory: data.statusHistory.present
          ? data.statusHistory.value
          : this.statusHistory,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemoteOrderRow(')
          ..write('id: $id, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('kind: $kind, ')
          ..write('number: $number, ')
          ..write('destination: $destination, ')
          ..write('customerName: $customerName, ')
          ..write('orderDate: $orderDate, ')
          ..write('status: $status, ')
          ..write('requiresApproval: $requiresApproval, ')
          ..write('notes: $notes, ')
          ..write('createdByName: $createdByName, ')
          ..write('createdAt: $createdAt, ')
          ..write('statusHistory: $statusHistory')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      warehouseId,
      kind,
      number,
      destination,
      customerName,
      orderDate,
      status,
      requiresApproval,
      notes,
      createdByName,
      createdAt,
      statusHistory);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemoteOrderRow &&
          other.id == this.id &&
          other.warehouseId == this.warehouseId &&
          other.kind == this.kind &&
          other.number == this.number &&
          other.destination == this.destination &&
          other.customerName == this.customerName &&
          other.orderDate == this.orderDate &&
          other.status == this.status &&
          other.requiresApproval == this.requiresApproval &&
          other.notes == this.notes &&
          other.createdByName == this.createdByName &&
          other.createdAt == this.createdAt &&
          other.statusHistory == this.statusHistory);
}

class RemoteOrdersCompanion extends UpdateCompanion<RemoteOrderRow> {
  final Value<String> id;
  final Value<String> warehouseId;
  final Value<String> kind;
  final Value<String> number;
  final Value<String?> destination;
  final Value<String?> customerName;
  final Value<DateTime> orderDate;
  final Value<String> status;
  final Value<bool> requiresApproval;
  final Value<String?> notes;
  final Value<String> createdByName;
  final Value<DateTime> createdAt;
  final Value<String> statusHistory;
  final Value<int> rowid;
  const RemoteOrdersCompanion({
    this.id = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.kind = const Value.absent(),
    this.number = const Value.absent(),
    this.destination = const Value.absent(),
    this.customerName = const Value.absent(),
    this.orderDate = const Value.absent(),
    this.status = const Value.absent(),
    this.requiresApproval = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdByName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.statusHistory = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemoteOrdersCompanion.insert({
    required String id,
    required String warehouseId,
    required String kind,
    required String number,
    this.destination = const Value.absent(),
    this.customerName = const Value.absent(),
    required DateTime orderDate,
    required String status,
    required bool requiresApproval,
    this.notes = const Value.absent(),
    required String createdByName,
    required DateTime createdAt,
    required String statusHistory,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        warehouseId = Value(warehouseId),
        kind = Value(kind),
        number = Value(number),
        orderDate = Value(orderDate),
        status = Value(status),
        requiresApproval = Value(requiresApproval),
        createdByName = Value(createdByName),
        createdAt = Value(createdAt),
        statusHistory = Value(statusHistory);
  static Insertable<RemoteOrderRow> custom({
    Expression<String>? id,
    Expression<String>? warehouseId,
    Expression<String>? kind,
    Expression<String>? number,
    Expression<String>? destination,
    Expression<String>? customerName,
    Expression<DateTime>? orderDate,
    Expression<String>? status,
    Expression<bool>? requiresApproval,
    Expression<String>? notes,
    Expression<String>? createdByName,
    Expression<DateTime>? createdAt,
    Expression<String>? statusHistory,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (kind != null) 'kind': kind,
      if (number != null) 'number': number,
      if (destination != null) 'destination': destination,
      if (customerName != null) 'customer_name': customerName,
      if (orderDate != null) 'order_date': orderDate,
      if (status != null) 'status': status,
      if (requiresApproval != null) 'requires_approval': requiresApproval,
      if (notes != null) 'notes': notes,
      if (createdByName != null) 'created_by_name': createdByName,
      if (createdAt != null) 'created_at': createdAt,
      if (statusHistory != null) 'status_history': statusHistory,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemoteOrdersCompanion copyWith(
      {Value<String>? id,
      Value<String>? warehouseId,
      Value<String>? kind,
      Value<String>? number,
      Value<String?>? destination,
      Value<String?>? customerName,
      Value<DateTime>? orderDate,
      Value<String>? status,
      Value<bool>? requiresApproval,
      Value<String?>? notes,
      Value<String>? createdByName,
      Value<DateTime>? createdAt,
      Value<String>? statusHistory,
      Value<int>? rowid}) {
    return RemoteOrdersCompanion(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      kind: kind ?? this.kind,
      number: number ?? this.number,
      destination: destination ?? this.destination,
      customerName: customerName ?? this.customerName,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      notes: notes ?? this.notes,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      statusHistory: statusHistory ?? this.statusHistory,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (orderDate.present) {
      map['order_date'] = Variable<DateTime>(orderDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (requiresApproval.present) {
      map['requires_approval'] = Variable<bool>(requiresApproval.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdByName.present) {
      map['created_by_name'] = Variable<String>(createdByName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (statusHistory.present) {
      map['status_history'] = Variable<String>(statusHistory.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemoteOrdersCompanion(')
          ..write('id: $id, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('kind: $kind, ')
          ..write('number: $number, ')
          ..write('destination: $destination, ')
          ..write('customerName: $customerName, ')
          ..write('orderDate: $orderDate, ')
          ..write('status: $status, ')
          ..write('requiresApproval: $requiresApproval, ')
          ..write('notes: $notes, ')
          ..write('createdByName: $createdByName, ')
          ..write('createdAt: $createdAt, ')
          ..write('statusHistory: $statusHistory, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemoteOrderLinesTable extends RemoteOrderLines
    with TableInfo<$RemoteOrderLinesTable, RemoteOrderLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemoteOrderLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
      'order_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationIdMeta =
      const VerificationMeta('locationId');
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
      'location_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, orderId, itemId, locationId, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remote_order_lines';
  @override
  VerificationContext validateIntegrity(Insertable<RemoteOrderLineRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('location_id')) {
      context.handle(
          _locationIdMeta,
          locationId.isAcceptableOrUnknown(
              data['location_id']!, _locationIdMeta));
    } else if (isInserting) {
      context.missing(_locationIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RemoteOrderLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemoteOrderLineRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      locationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
    );
  }

  @override
  $RemoteOrderLinesTable createAlias(String alias) {
    return $RemoteOrderLinesTable(attachedDatabase, alias);
  }
}

class RemoteOrderLineRow extends DataClass
    implements Insertable<RemoteOrderLineRow> {
  final String id;
  final String orderId;
  final String itemId;
  final String locationId;
  final double quantity;
  const RemoteOrderLineRow(
      {required this.id,
      required this.orderId,
      required this.itemId,
      required this.locationId,
      required this.quantity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['order_id'] = Variable<String>(orderId);
    map['item_id'] = Variable<String>(itemId);
    map['location_id'] = Variable<String>(locationId);
    map['quantity'] = Variable<double>(quantity);
    return map;
  }

  RemoteOrderLinesCompanion toCompanion(bool nullToAbsent) {
    return RemoteOrderLinesCompanion(
      id: Value(id),
      orderId: Value(orderId),
      itemId: Value(itemId),
      locationId: Value(locationId),
      quantity: Value(quantity),
    );
  }

  factory RemoteOrderLineRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemoteOrderLineRow(
      id: serializer.fromJson<String>(json['id']),
      orderId: serializer.fromJson<String>(json['orderId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      locationId: serializer.fromJson<String>(json['locationId']),
      quantity: serializer.fromJson<double>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orderId': serializer.toJson<String>(orderId),
      'itemId': serializer.toJson<String>(itemId),
      'locationId': serializer.toJson<String>(locationId),
      'quantity': serializer.toJson<double>(quantity),
    };
  }

  RemoteOrderLineRow copyWith(
          {String? id,
          String? orderId,
          String? itemId,
          String? locationId,
          double? quantity}) =>
      RemoteOrderLineRow(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        itemId: itemId ?? this.itemId,
        locationId: locationId ?? this.locationId,
        quantity: quantity ?? this.quantity,
      );
  RemoteOrderLineRow copyWithCompanion(RemoteOrderLinesCompanion data) {
    return RemoteOrderLineRow(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      locationId:
          data.locationId.present ? data.locationId.value : this.locationId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemoteOrderLineRow(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('itemId: $itemId, ')
          ..write('locationId: $locationId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, orderId, itemId, locationId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemoteOrderLineRow &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.itemId == this.itemId &&
          other.locationId == this.locationId &&
          other.quantity == this.quantity);
}

class RemoteOrderLinesCompanion extends UpdateCompanion<RemoteOrderLineRow> {
  final Value<String> id;
  final Value<String> orderId;
  final Value<String> itemId;
  final Value<String> locationId;
  final Value<double> quantity;
  final Value<int> rowid;
  const RemoteOrderLinesCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.locationId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemoteOrderLinesCompanion.insert({
    required String id,
    required String orderId,
    required String itemId,
    required String locationId,
    required double quantity,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        orderId = Value(orderId),
        itemId = Value(itemId),
        locationId = Value(locationId),
        quantity = Value(quantity);
  static Insertable<RemoteOrderLineRow> custom({
    Expression<String>? id,
    Expression<String>? orderId,
    Expression<String>? itemId,
    Expression<String>? locationId,
    Expression<double>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (itemId != null) 'item_id': itemId,
      if (locationId != null) 'location_id': locationId,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemoteOrderLinesCompanion copyWith(
      {Value<String>? id,
      Value<String>? orderId,
      Value<String>? itemId,
      Value<String>? locationId,
      Value<double>? quantity,
      Value<int>? rowid}) {
    return RemoteOrderLinesCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      itemId: itemId ?? this.itemId,
      locationId: locationId ?? this.locationId,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemoteOrderLinesCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('itemId: $itemId, ')
          ..write('locationId: $locationId, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemoteTasksTable extends RemoteTasks
    with TableInfo<$RemoteTasksTable, RemoteTaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemoteTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationIdMeta =
      const VerificationMeta('locationId');
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
      'location_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _assigneeUserIdMeta =
      const VerificationMeta('assigneeUserId');
  @override
  late final GeneratedColumn<String> assigneeUserId = GeneratedColumn<String>(
      'assignee_user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
      'due_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdByUserIdMeta =
      const VerificationMeta('createdByUserId');
  @override
  late final GeneratedColumn<String> createdByUserId = GeneratedColumn<String>(
      'created_by_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        warehouseId,
        title,
        type,
        locationId,
        assigneeUserId,
        status,
        dueAt,
        createdByUserId,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remote_tasks';
  @override
  VerificationContext validateIntegrity(Insertable<RemoteTaskRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    } else if (isInserting) {
      context.missing(_warehouseIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('location_id')) {
      context.handle(
          _locationIdMeta,
          locationId.isAcceptableOrUnknown(
              data['location_id']!, _locationIdMeta));
    }
    if (data.containsKey('assignee_user_id')) {
      context.handle(
          _assigneeUserIdMeta,
          assigneeUserId.isAcceptableOrUnknown(
              data['assignee_user_id']!, _assigneeUserIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
          _dueAtMeta, dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta));
    }
    if (data.containsKey('created_by_user_id')) {
      context.handle(
          _createdByUserIdMeta,
          createdByUserId.isAcceptableOrUnknown(
              data['created_by_user_id']!, _createdByUserIdMeta));
    } else if (isInserting) {
      context.missing(_createdByUserIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RemoteTaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemoteTaskRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      locationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_id']),
      assigneeUserId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}assignee_user_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      dueAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_at']),
      createdByUserId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}created_by_user_id'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $RemoteTasksTable createAlias(String alias) {
    return $RemoteTasksTable(attachedDatabase, alias);
  }
}

class RemoteTaskRow extends DataClass implements Insertable<RemoteTaskRow> {
  final String id;
  final String warehouseId;
  final String title;
  final String type;
  final String? locationId;
  final String? assigneeUserId;
  final String status;
  final DateTime? dueAt;
  final String createdByUserId;
  final DateTime? completedAt;
  const RemoteTaskRow(
      {required this.id,
      required this.warehouseId,
      required this.title,
      required this.type,
      this.locationId,
      this.assigneeUserId,
      required this.status,
      this.dueAt,
      required this.createdByUserId,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['warehouse_id'] = Variable<String>(warehouseId);
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<String>(locationId);
    }
    if (!nullToAbsent || assigneeUserId != null) {
      map['assignee_user_id'] = Variable<String>(assigneeUserId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    map['created_by_user_id'] = Variable<String>(createdByUserId);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  RemoteTasksCompanion toCompanion(bool nullToAbsent) {
    return RemoteTasksCompanion(
      id: Value(id),
      warehouseId: Value(warehouseId),
      title: Value(title),
      type: Value(type),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
      assigneeUserId: assigneeUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(assigneeUserId),
      status: Value(status),
      dueAt:
          dueAt == null && nullToAbsent ? const Value.absent() : Value(dueAt),
      createdByUserId: Value(createdByUserId),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory RemoteTaskRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemoteTaskRow(
      id: serializer.fromJson<String>(json['id']),
      warehouseId: serializer.fromJson<String>(json['warehouseId']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<String>(json['type']),
      locationId: serializer.fromJson<String?>(json['locationId']),
      assigneeUserId: serializer.fromJson<String?>(json['assigneeUserId']),
      status: serializer.fromJson<String>(json['status']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      createdByUserId: serializer.fromJson<String>(json['createdByUserId']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'warehouseId': serializer.toJson<String>(warehouseId),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(type),
      'locationId': serializer.toJson<String?>(locationId),
      'assigneeUserId': serializer.toJson<String?>(assigneeUserId),
      'status': serializer.toJson<String>(status),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'createdByUserId': serializer.toJson<String>(createdByUserId),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  RemoteTaskRow copyWith(
          {String? id,
          String? warehouseId,
          String? title,
          String? type,
          Value<String?> locationId = const Value.absent(),
          Value<String?> assigneeUserId = const Value.absent(),
          String? status,
          Value<DateTime?> dueAt = const Value.absent(),
          String? createdByUserId,
          Value<DateTime?> completedAt = const Value.absent()}) =>
      RemoteTaskRow(
        id: id ?? this.id,
        warehouseId: warehouseId ?? this.warehouseId,
        title: title ?? this.title,
        type: type ?? this.type,
        locationId: locationId.present ? locationId.value : this.locationId,
        assigneeUserId:
            assigneeUserId.present ? assigneeUserId.value : this.assigneeUserId,
        status: status ?? this.status,
        dueAt: dueAt.present ? dueAt.value : this.dueAt,
        createdByUserId: createdByUserId ?? this.createdByUserId,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  RemoteTaskRow copyWithCompanion(RemoteTasksCompanion data) {
    return RemoteTaskRow(
      id: data.id.present ? data.id.value : this.id,
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      locationId:
          data.locationId.present ? data.locationId.value : this.locationId,
      assigneeUserId: data.assigneeUserId.present
          ? data.assigneeUserId.value
          : this.assigneeUserId,
      status: data.status.present ? data.status.value : this.status,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      createdByUserId: data.createdByUserId.present
          ? data.createdByUserId.value
          : this.createdByUserId,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemoteTaskRow(')
          ..write('id: $id, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('locationId: $locationId, ')
          ..write('assigneeUserId: $assigneeUserId, ')
          ..write('status: $status, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, warehouseId, title, type, locationId,
      assigneeUserId, status, dueAt, createdByUserId, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemoteTaskRow &&
          other.id == this.id &&
          other.warehouseId == this.warehouseId &&
          other.title == this.title &&
          other.type == this.type &&
          other.locationId == this.locationId &&
          other.assigneeUserId == this.assigneeUserId &&
          other.status == this.status &&
          other.dueAt == this.dueAt &&
          other.createdByUserId == this.createdByUserId &&
          other.completedAt == this.completedAt);
}

class RemoteTasksCompanion extends UpdateCompanion<RemoteTaskRow> {
  final Value<String> id;
  final Value<String> warehouseId;
  final Value<String> title;
  final Value<String> type;
  final Value<String?> locationId;
  final Value<String?> assigneeUserId;
  final Value<String> status;
  final Value<DateTime?> dueAt;
  final Value<String> createdByUserId;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const RemoteTasksCompanion({
    this.id = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.locationId = const Value.absent(),
    this.assigneeUserId = const Value.absent(),
    this.status = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.createdByUserId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemoteTasksCompanion.insert({
    required String id,
    required String warehouseId,
    required String title,
    required String type,
    this.locationId = const Value.absent(),
    this.assigneeUserId = const Value.absent(),
    required String status,
    this.dueAt = const Value.absent(),
    required String createdByUserId,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        warehouseId = Value(warehouseId),
        title = Value(title),
        type = Value(type),
        status = Value(status),
        createdByUserId = Value(createdByUserId);
  static Insertable<RemoteTaskRow> custom({
    Expression<String>? id,
    Expression<String>? warehouseId,
    Expression<String>? title,
    Expression<String>? type,
    Expression<String>? locationId,
    Expression<String>? assigneeUserId,
    Expression<String>? status,
    Expression<DateTime>? dueAt,
    Expression<String>? createdByUserId,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (locationId != null) 'location_id': locationId,
      if (assigneeUserId != null) 'assignee_user_id': assigneeUserId,
      if (status != null) 'status': status,
      if (dueAt != null) 'due_at': dueAt,
      if (createdByUserId != null) 'created_by_user_id': createdByUserId,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemoteTasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? warehouseId,
      Value<String>? title,
      Value<String>? type,
      Value<String?>? locationId,
      Value<String?>? assigneeUserId,
      Value<String>? status,
      Value<DateTime?>? dueAt,
      Value<String>? createdByUserId,
      Value<DateTime?>? completedAt,
      Value<int>? rowid}) {
    return RemoteTasksCompanion(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      title: title ?? this.title,
      type: type ?? this.type,
      locationId: locationId ?? this.locationId,
      assigneeUserId: assigneeUserId ?? this.assigneeUserId,
      status: status ?? this.status,
      dueAt: dueAt ?? this.dueAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (assigneeUserId.present) {
      map['assignee_user_id'] = Variable<String>(assigneeUserId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (createdByUserId.present) {
      map['created_by_user_id'] = Variable<String>(createdByUserId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemoteTasksCompanion(')
          ..write('id: $id, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('locationId: $locationId, ')
          ..write('assigneeUserId: $assigneeUserId, ')
          ..write('status: $status, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemoteAlertsTable extends RemoteAlerts
    with TableInfo<$RemoteAlertsTable, RemoteAlertRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemoteAlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
      'read_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, warehouseId, type, title, body, payload, createdAt, readAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remote_alerts';
  @override
  VerificationContext validateIntegrity(Insertable<RemoteAlertRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(_readAtMeta,
          readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RemoteAlertRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemoteAlertRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      readAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}read_at']),
    );
  }

  @override
  $RemoteAlertsTable createAlias(String alias) {
    return $RemoteAlertsTable(attachedDatabase, alias);
  }
}

class RemoteAlertRow extends DataClass implements Insertable<RemoteAlertRow> {
  final String id;
  final String? warehouseId;
  final String type;
  final String title;
  final String body;
  final String? payload;
  final DateTime createdAt;
  final DateTime? readAt;
  const RemoteAlertRow(
      {required this.id,
      this.warehouseId,
      required this.type,
      required this.title,
      required this.body,
      this.payload,
      required this.createdAt,
      this.readAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || warehouseId != null) {
      map['warehouse_id'] = Variable<String>(warehouseId);
    }
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    return map;
  }

  RemoteAlertsCompanion toCompanion(bool nullToAbsent) {
    return RemoteAlertsCompanion(
      id: Value(id),
      warehouseId: warehouseId == null && nullToAbsent
          ? const Value.absent()
          : Value(warehouseId),
      type: Value(type),
      title: Value(title),
      body: Value(body),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      createdAt: Value(createdAt),
      readAt:
          readAt == null && nullToAbsent ? const Value.absent() : Value(readAt),
    );
  }

  factory RemoteAlertRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemoteAlertRow(
      id: serializer.fromJson<String>(json['id']),
      warehouseId: serializer.fromJson<String?>(json['warehouseId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      payload: serializer.fromJson<String?>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'warehouseId': serializer.toJson<String?>(warehouseId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'payload': serializer.toJson<String?>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'readAt': serializer.toJson<DateTime?>(readAt),
    };
  }

  RemoteAlertRow copyWith(
          {String? id,
          Value<String?> warehouseId = const Value.absent(),
          String? type,
          String? title,
          String? body,
          Value<String?> payload = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> readAt = const Value.absent()}) =>
      RemoteAlertRow(
        id: id ?? this.id,
        warehouseId: warehouseId.present ? warehouseId.value : this.warehouseId,
        type: type ?? this.type,
        title: title ?? this.title,
        body: body ?? this.body,
        payload: payload.present ? payload.value : this.payload,
        createdAt: createdAt ?? this.createdAt,
        readAt: readAt.present ? readAt.value : this.readAt,
      );
  RemoteAlertRow copyWithCompanion(RemoteAlertsCompanion data) {
    return RemoteAlertRow(
      id: data.id.present ? data.id.value : this.id,
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemoteAlertRow(')
          ..write('id: $id, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, warehouseId, type, title, body, payload, createdAt, readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemoteAlertRow &&
          other.id == this.id &&
          other.warehouseId == this.warehouseId &&
          other.type == this.type &&
          other.title == this.title &&
          other.body == this.body &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.readAt == this.readAt);
}

class RemoteAlertsCompanion extends UpdateCompanion<RemoteAlertRow> {
  final Value<String> id;
  final Value<String?> warehouseId;
  final Value<String> type;
  final Value<String> title;
  final Value<String> body;
  final Value<String?> payload;
  final Value<DateTime> createdAt;
  final Value<DateTime?> readAt;
  final Value<int> rowid;
  const RemoteAlertsCompanion({
    this.id = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemoteAlertsCompanion.insert({
    required String id,
    this.warehouseId = const Value.absent(),
    required String type,
    required String title,
    required String body,
    this.payload = const Value.absent(),
    required DateTime createdAt,
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        title = Value(title),
        body = Value(body),
        createdAt = Value(createdAt);
  static Insertable<RemoteAlertRow> custom({
    Expression<String>? id,
    Expression<String>? warehouseId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? readAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemoteAlertsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? warehouseId,
      Value<String>? type,
      Value<String>? title,
      Value<String>? body,
      Value<String?>? payload,
      Value<DateTime>? createdAt,
      Value<DateTime?>? readAt,
      Value<int>? rowid}) {
    return RemoteAlertsCompanion(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemoteAlertsCompanion(')
          ..write('id: $id, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('readAt: $readAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WarehouseMembersTable extends WarehouseMembers
    with TableInfo<$WarehouseMembersTable, WarehouseMemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WarehouseMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns =>
      [warehouseId, userId, displayName, role, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'warehouse_members';
  @override
  VerificationContext validateIntegrity(Insertable<WarehouseMemberRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    } else if (isInserting) {
      context.missing(_warehouseIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {warehouseId, userId};
  @override
  WarehouseMemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WarehouseMemberRow(
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $WarehouseMembersTable createAlias(String alias) {
    return $WarehouseMembersTable(attachedDatabase, alias);
  }
}

class WarehouseMemberRow extends DataClass
    implements Insertable<WarehouseMemberRow> {
  final String warehouseId;
  final String userId;
  final String displayName;
  final String role;
  final bool isActive;
  const WarehouseMemberRow(
      {required this.warehouseId,
      required this.userId,
      required this.displayName,
      required this.role,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['warehouse_id'] = Variable<String>(warehouseId);
    map['user_id'] = Variable<String>(userId);
    map['display_name'] = Variable<String>(displayName);
    map['role'] = Variable<String>(role);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  WarehouseMembersCompanion toCompanion(bool nullToAbsent) {
    return WarehouseMembersCompanion(
      warehouseId: Value(warehouseId),
      userId: Value(userId),
      displayName: Value(displayName),
      role: Value(role),
      isActive: Value(isActive),
    );
  }

  factory WarehouseMemberRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WarehouseMemberRow(
      warehouseId: serializer.fromJson<String>(json['warehouseId']),
      userId: serializer.fromJson<String>(json['userId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      role: serializer.fromJson<String>(json['role']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'warehouseId': serializer.toJson<String>(warehouseId),
      'userId': serializer.toJson<String>(userId),
      'displayName': serializer.toJson<String>(displayName),
      'role': serializer.toJson<String>(role),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  WarehouseMemberRow copyWith(
          {String? warehouseId,
          String? userId,
          String? displayName,
          String? role,
          bool? isActive}) =>
      WarehouseMemberRow(
        warehouseId: warehouseId ?? this.warehouseId,
        userId: userId ?? this.userId,
        displayName: displayName ?? this.displayName,
        role: role ?? this.role,
        isActive: isActive ?? this.isActive,
      );
  WarehouseMemberRow copyWithCompanion(WarehouseMembersCompanion data) {
    return WarehouseMemberRow(
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      role: data.role.present ? data.role.value : this.role,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WarehouseMemberRow(')
          ..write('warehouseId: $warehouseId, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(warehouseId, userId, displayName, role, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WarehouseMemberRow &&
          other.warehouseId == this.warehouseId &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.role == this.role &&
          other.isActive == this.isActive);
}

class WarehouseMembersCompanion extends UpdateCompanion<WarehouseMemberRow> {
  final Value<String> warehouseId;
  final Value<String> userId;
  final Value<String> displayName;
  final Value<String> role;
  final Value<bool> isActive;
  final Value<int> rowid;
  const WarehouseMembersCompanion({
    this.warehouseId = const Value.absent(),
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WarehouseMembersCompanion.insert({
    required String warehouseId,
    required String userId,
    required String displayName,
    required String role,
    required bool isActive,
    this.rowid = const Value.absent(),
  })  : warehouseId = Value(warehouseId),
        userId = Value(userId),
        displayName = Value(displayName),
        role = Value(role),
        isActive = Value(isActive);
  static Insertable<WarehouseMemberRow> custom({
    Expression<String>? warehouseId,
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<String>? role,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WarehouseMembersCompanion copyWith(
      {Value<String>? warehouseId,
      Value<String>? userId,
      Value<String>? displayName,
      Value<String>? role,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return WarehouseMembersCompanion(
      warehouseId: warehouseId ?? this.warehouseId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WarehouseMembersCompanion(')
          ..write('warehouseId: $warehouseId, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserSessionsTable userSessions = $UserSessionsTable(this);
  late final $CountSessionsTable countSessions = $CountSessionsTable(this);
  late final $CountItemsTable countItems = $CountItemsTable(this);
  late final $LocationEntriesTable locationEntries =
      $LocationEntriesTable(this);
  late final $DeliveryOrderEntriesTable deliveryOrderEntries =
      $DeliveryOrderEntriesTable(this);
  late final $SalesOrderEntriesTable salesOrderEntries =
      $SalesOrderEntriesTable(this);
  late final $OrderItemEntriesTable orderItemEntries =
      $OrderItemEntriesTable(this);
  late final $OrderStatusHistoryEntriesTable orderStatusHistoryEntries =
      $OrderStatusHistoryEntriesTable(this);
  late final $PurchaseOrdersTable purchaseOrders = $PurchaseOrdersTable(this);
  late final $PoLineItemsTable poLineItems = $PoLineItemsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $CatalogItemsTable catalogItems = $CatalogItemsTable(this);
  late final $CatalogBarcodesTable catalogBarcodes =
      $CatalogBarcodesTable(this);
  late final $WarehouseLocationsTable warehouseLocations =
      $WarehouseLocationsTable(this);
  late final $RemoteCountSessionsTable remoteCountSessions =
      $RemoteCountSessionsTable(this);
  late final $RemoteCountLinesTable remoteCountLines =
      $RemoteCountLinesTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $RemotePurchaseOrdersTable remotePurchaseOrders =
      $RemotePurchaseOrdersTable(this);
  late final $RemotePoLinesTable remotePoLines = $RemotePoLinesTable(this);
  late final $RemoteOrdersTable remoteOrders = $RemoteOrdersTable(this);
  late final $RemoteOrderLinesTable remoteOrderLines =
      $RemoteOrderLinesTable(this);
  late final $RemoteTasksTable remoteTasks = $RemoteTasksTable(this);
  late final $RemoteAlertsTable remoteAlerts = $RemoteAlertsTable(this);
  late final $WarehouseMembersTable warehouseMembers =
      $WarehouseMembersTable(this);
  late final CountSessionDao countSessionDao =
      CountSessionDao(this as AppDatabase);
  late final OrdersDao ordersDao = OrdersDao(this as AppDatabase);
  late final ReceivingDao receivingDao = ReceivingDao(this as AppDatabase);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  late final ServerMirrorDao serverMirrorDao =
      ServerMirrorDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        userSessions,
        countSessions,
        countItems,
        locationEntries,
        deliveryOrderEntries,
        salesOrderEntries,
        orderItemEntries,
        orderStatusHistoryEntries,
        purchaseOrders,
        poLineItems,
        syncQueue,
        catalogItems,
        catalogBarcodes,
        warehouseLocations,
        remoteCountSessions,
        remoteCountLines,
        syncCursors,
        remotePurchaseOrders,
        remotePoLines,
        remoteOrders,
        remoteOrderLines,
        remoteTasks,
        remoteAlerts,
        warehouseMembers
      ];
}

typedef $$UserSessionsTableCreateCompanionBuilder = UserSessionsCompanion
    Function({
  required String userId,
  required String token,
  required String role,
  required String name,
  required String email,
  required String site,
  Value<DateTime> storedAt,
  Value<int> rowid,
});
typedef $$UserSessionsTableUpdateCompanionBuilder = UserSessionsCompanion
    Function({
  Value<String> userId,
  Value<String> token,
  Value<String> role,
  Value<String> name,
  Value<String> email,
  Value<String> site,
  Value<DateTime> storedAt,
  Value<int> rowid,
});

class $$UserSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSessionsTable> {
  $$UserSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get site => $composableBuilder(
      column: $table.site, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get storedAt => $composableBuilder(
      column: $table.storedAt, builder: (column) => ColumnFilters(column));
}

class $$UserSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSessionsTable> {
  $$UserSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get site => $composableBuilder(
      column: $table.site, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get storedAt => $composableBuilder(
      column: $table.storedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSessionsTable> {
  $$UserSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get site =>
      $composableBuilder(column: $table.site, builder: (column) => column);

  GeneratedColumn<DateTime> get storedAt =>
      $composableBuilder(column: $table.storedAt, builder: (column) => column);
}

class $$UserSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserSessionsTable,
    UserSession,
    $$UserSessionsTableFilterComposer,
    $$UserSessionsTableOrderingComposer,
    $$UserSessionsTableAnnotationComposer,
    $$UserSessionsTableCreateCompanionBuilder,
    $$UserSessionsTableUpdateCompanionBuilder,
    (
      UserSession,
      BaseReferences<_$AppDatabase, $UserSessionsTable, UserSession>
    ),
    UserSession,
    PrefetchHooks Function()> {
  $$UserSessionsTableTableManager(_$AppDatabase db, $UserSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<String> token = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> site = const Value.absent(),
            Value<DateTime> storedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSessionsCompanion(
            userId: userId,
            token: token,
            role: role,
            name: name,
            email: email,
            site: site,
            storedAt: storedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            required String token,
            required String role,
            required String name,
            required String email,
            required String site,
            Value<DateTime> storedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSessionsCompanion.insert(
            userId: userId,
            token: token,
            role: role,
            name: name,
            email: email,
            site: site,
            storedAt: storedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserSessionsTable,
    UserSession,
    $$UserSessionsTableFilterComposer,
    $$UserSessionsTableOrderingComposer,
    $$UserSessionsTableAnnotationComposer,
    $$UserSessionsTableCreateCompanionBuilder,
    $$UserSessionsTableUpdateCompanionBuilder,
    (
      UserSession,
      BaseReferences<_$AppDatabase, $UserSessionsTable, UserSession>
    ),
    UserSession,
    PrefetchHooks Function()>;
typedef $$CountSessionsTableCreateCompanionBuilder = CountSessionsCompanion
    Function({
  required String id,
  required String location,
  Value<String?> label,
  required String status,
  required DateTime startedAt,
  Value<DateTime?> submittedAt,
  Value<String?> locationId,
  Value<String?> assignedWorkerId,
  Value<DateTime?> deadline,
  Value<String?> zoneAisle,
  Value<int> rowid,
});
typedef $$CountSessionsTableUpdateCompanionBuilder = CountSessionsCompanion
    Function({
  Value<String> id,
  Value<String> location,
  Value<String?> label,
  Value<String> status,
  Value<DateTime> startedAt,
  Value<DateTime?> submittedAt,
  Value<String?> locationId,
  Value<String?> assignedWorkerId,
  Value<DateTime?> deadline,
  Value<String?> zoneAisle,
  Value<int> rowid,
});

class $$CountSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $CountSessionsTable> {
  $$CountSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assignedWorkerId => $composableBuilder(
      column: $table.assignedWorkerId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get zoneAisle => $composableBuilder(
      column: $table.zoneAisle, builder: (column) => ColumnFilters(column));
}

class $$CountSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CountSessionsTable> {
  $$CountSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assignedWorkerId => $composableBuilder(
      column: $table.assignedWorkerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get zoneAisle => $composableBuilder(
      column: $table.zoneAisle, builder: (column) => ColumnOrderings(column));
}

class $$CountSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountSessionsTable> {
  $$CountSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => column);

  GeneratedColumn<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => column);

  GeneratedColumn<String> get assignedWorkerId => $composableBuilder(
      column: $table.assignedWorkerId, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get zoneAisle =>
      $composableBuilder(column: $table.zoneAisle, builder: (column) => column);
}

class $$CountSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CountSessionsTable,
    CountSession,
    $$CountSessionsTableFilterComposer,
    $$CountSessionsTableOrderingComposer,
    $$CountSessionsTableAnnotationComposer,
    $$CountSessionsTableCreateCompanionBuilder,
    $$CountSessionsTableUpdateCompanionBuilder,
    (
      CountSession,
      BaseReferences<_$AppDatabase, $CountSessionsTable, CountSession>
    ),
    CountSession,
    PrefetchHooks Function()> {
  $$CountSessionsTableTableManager(_$AppDatabase db, $CountSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<String?> label = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> submittedAt = const Value.absent(),
            Value<String?> locationId = const Value.absent(),
            Value<String?> assignedWorkerId = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<String?> zoneAisle = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CountSessionsCompanion(
            id: id,
            location: location,
            label: label,
            status: status,
            startedAt: startedAt,
            submittedAt: submittedAt,
            locationId: locationId,
            assignedWorkerId: assignedWorkerId,
            deadline: deadline,
            zoneAisle: zoneAisle,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String location,
            Value<String?> label = const Value.absent(),
            required String status,
            required DateTime startedAt,
            Value<DateTime?> submittedAt = const Value.absent(),
            Value<String?> locationId = const Value.absent(),
            Value<String?> assignedWorkerId = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<String?> zoneAisle = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CountSessionsCompanion.insert(
            id: id,
            location: location,
            label: label,
            status: status,
            startedAt: startedAt,
            submittedAt: submittedAt,
            locationId: locationId,
            assignedWorkerId: assignedWorkerId,
            deadline: deadline,
            zoneAisle: zoneAisle,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CountSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CountSessionsTable,
    CountSession,
    $$CountSessionsTableFilterComposer,
    $$CountSessionsTableOrderingComposer,
    $$CountSessionsTableAnnotationComposer,
    $$CountSessionsTableCreateCompanionBuilder,
    $$CountSessionsTableUpdateCompanionBuilder,
    (
      CountSession,
      BaseReferences<_$AppDatabase, $CountSessionsTable, CountSession>
    ),
    CountSession,
    PrefetchHooks Function()>;
typedef $$CountItemsTableCreateCompanionBuilder = CountItemsCompanion Function({
  required String id,
  required String sessionId,
  required String itemCode,
  required String itemName,
  Value<String?> itemId,
  required int expectedQty,
  required int actualQty,
  Value<String> entryMethod,
  Value<bool> skipped,
  Value<int> rowid,
});
typedef $$CountItemsTableUpdateCompanionBuilder = CountItemsCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> itemCode,
  Value<String> itemName,
  Value<String?> itemId,
  Value<int> expectedQty,
  Value<int> actualQty,
  Value<String> entryMethod,
  Value<bool> skipped,
  Value<int> rowid,
});

class $$CountItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CountItemsTable> {
  $$CountItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemCode => $composableBuilder(
      column: $table.itemCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expectedQty => $composableBuilder(
      column: $table.expectedQty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get actualQty => $composableBuilder(
      column: $table.actualQty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryMethod => $composableBuilder(
      column: $table.entryMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get skipped => $composableBuilder(
      column: $table.skipped, builder: (column) => ColumnFilters(column));
}

class $$CountItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CountItemsTable> {
  $$CountItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemCode => $composableBuilder(
      column: $table.itemCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expectedQty => $composableBuilder(
      column: $table.expectedQty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get actualQty => $composableBuilder(
      column: $table.actualQty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryMethod => $composableBuilder(
      column: $table.entryMethod, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get skipped => $composableBuilder(
      column: $table.skipped, builder: (column) => ColumnOrderings(column));
}

class $$CountItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountItemsTable> {
  $$CountItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get itemCode =>
      $composableBuilder(column: $table.itemCode, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get expectedQty => $composableBuilder(
      column: $table.expectedQty, builder: (column) => column);

  GeneratedColumn<int> get actualQty =>
      $composableBuilder(column: $table.actualQty, builder: (column) => column);

  GeneratedColumn<String> get entryMethod => $composableBuilder(
      column: $table.entryMethod, builder: (column) => column);

  GeneratedColumn<bool> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => column);
}

class $$CountItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CountItemsTable,
    CountItem,
    $$CountItemsTableFilterComposer,
    $$CountItemsTableOrderingComposer,
    $$CountItemsTableAnnotationComposer,
    $$CountItemsTableCreateCompanionBuilder,
    $$CountItemsTableUpdateCompanionBuilder,
    (CountItem, BaseReferences<_$AppDatabase, $CountItemsTable, CountItem>),
    CountItem,
    PrefetchHooks Function()> {
  $$CountItemsTableTableManager(_$AppDatabase db, $CountItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> itemCode = const Value.absent(),
            Value<String> itemName = const Value.absent(),
            Value<String?> itemId = const Value.absent(),
            Value<int> expectedQty = const Value.absent(),
            Value<int> actualQty = const Value.absent(),
            Value<String> entryMethod = const Value.absent(),
            Value<bool> skipped = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CountItemsCompanion(
            id: id,
            sessionId: sessionId,
            itemCode: itemCode,
            itemName: itemName,
            itemId: itemId,
            expectedQty: expectedQty,
            actualQty: actualQty,
            entryMethod: entryMethod,
            skipped: skipped,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sessionId,
            required String itemCode,
            required String itemName,
            Value<String?> itemId = const Value.absent(),
            required int expectedQty,
            required int actualQty,
            Value<String> entryMethod = const Value.absent(),
            Value<bool> skipped = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CountItemsCompanion.insert(
            id: id,
            sessionId: sessionId,
            itemCode: itemCode,
            itemName: itemName,
            itemId: itemId,
            expectedQty: expectedQty,
            actualQty: actualQty,
            entryMethod: entryMethod,
            skipped: skipped,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CountItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CountItemsTable,
    CountItem,
    $$CountItemsTableFilterComposer,
    $$CountItemsTableOrderingComposer,
    $$CountItemsTableAnnotationComposer,
    $$CountItemsTableCreateCompanionBuilder,
    $$CountItemsTableUpdateCompanionBuilder,
    (CountItem, BaseReferences<_$AppDatabase, $CountItemsTable, CountItem>),
    CountItem,
    PrefetchHooks Function()>;
typedef $$LocationEntriesTableCreateCompanionBuilder = LocationEntriesCompanion
    Function({
  Value<int> id,
  required String name,
  required String type,
});
typedef $$LocationEntriesTableUpdateCompanionBuilder = LocationEntriesCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> type,
});

class $$LocationEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocationEntriesTable> {
  $$LocationEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));
}

class $$LocationEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationEntriesTable> {
  $$LocationEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));
}

class $$LocationEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationEntriesTable> {
  $$LocationEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$LocationEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocationEntriesTable,
    LocationEntry,
    $$LocationEntriesTableFilterComposer,
    $$LocationEntriesTableOrderingComposer,
    $$LocationEntriesTableAnnotationComposer,
    $$LocationEntriesTableCreateCompanionBuilder,
    $$LocationEntriesTableUpdateCompanionBuilder,
    (
      LocationEntry,
      BaseReferences<_$AppDatabase, $LocationEntriesTable, LocationEntry>
    ),
    LocationEntry,
    PrefetchHooks Function()> {
  $$LocationEntriesTableTableManager(
      _$AppDatabase db, $LocationEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
          }) =>
              LocationEntriesCompanion(
            id: id,
            name: name,
            type: type,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String type,
          }) =>
              LocationEntriesCompanion.insert(
            id: id,
            name: name,
            type: type,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocationEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocationEntriesTable,
    LocationEntry,
    $$LocationEntriesTableFilterComposer,
    $$LocationEntriesTableOrderingComposer,
    $$LocationEntriesTableAnnotationComposer,
    $$LocationEntriesTableCreateCompanionBuilder,
    $$LocationEntriesTableUpdateCompanionBuilder,
    (
      LocationEntry,
      BaseReferences<_$AppDatabase, $LocationEntriesTable, LocationEntry>
    ),
    LocationEntry,
    PrefetchHooks Function()>;
typedef $$DeliveryOrderEntriesTableCreateCompanionBuilder
    = DeliveryOrderEntriesCompanion Function({
  Value<int> id,
  required String orderNumber,
  required int fromLocationId,
  required int toLocationId,
  required DateTime deliveryDate,
  required String status,
  Value<bool> requiresApproval,
  Value<String?> notes,
  required String createdBy,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$DeliveryOrderEntriesTableUpdateCompanionBuilder
    = DeliveryOrderEntriesCompanion Function({
  Value<int> id,
  Value<String> orderNumber,
  Value<int> fromLocationId,
  Value<int> toLocationId,
  Value<DateTime> deliveryDate,
  Value<String> status,
  Value<bool> requiresApproval,
  Value<String?> notes,
  Value<String> createdBy,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$DeliveryOrderEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DeliveryOrderEntriesTable> {
  $$DeliveryOrderEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderNumber => $composableBuilder(
      column: $table.orderNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fromLocationId => $composableBuilder(
      column: $table.fromLocationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get toLocationId => $composableBuilder(
      column: $table.toLocationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deliveryDate => $composableBuilder(
      column: $table.deliveryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get requiresApproval => $composableBuilder(
      column: $table.requiresApproval,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DeliveryOrderEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DeliveryOrderEntriesTable> {
  $$DeliveryOrderEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderNumber => $composableBuilder(
      column: $table.orderNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fromLocationId => $composableBuilder(
      column: $table.fromLocationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get toLocationId => $composableBuilder(
      column: $table.toLocationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deliveryDate => $composableBuilder(
      column: $table.deliveryDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get requiresApproval => $composableBuilder(
      column: $table.requiresApproval,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DeliveryOrderEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeliveryOrderEntriesTable> {
  $$DeliveryOrderEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderNumber => $composableBuilder(
      column: $table.orderNumber, builder: (column) => column);

  GeneratedColumn<int> get fromLocationId => $composableBuilder(
      column: $table.fromLocationId, builder: (column) => column);

  GeneratedColumn<int> get toLocationId => $composableBuilder(
      column: $table.toLocationId, builder: (column) => column);

  GeneratedColumn<DateTime> get deliveryDate => $composableBuilder(
      column: $table.deliveryDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get requiresApproval => $composableBuilder(
      column: $table.requiresApproval, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DeliveryOrderEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeliveryOrderEntriesTable,
    DeliveryOrderEntry,
    $$DeliveryOrderEntriesTableFilterComposer,
    $$DeliveryOrderEntriesTableOrderingComposer,
    $$DeliveryOrderEntriesTableAnnotationComposer,
    $$DeliveryOrderEntriesTableCreateCompanionBuilder,
    $$DeliveryOrderEntriesTableUpdateCompanionBuilder,
    (
      DeliveryOrderEntry,
      BaseReferences<_$AppDatabase, $DeliveryOrderEntriesTable,
          DeliveryOrderEntry>
    ),
    DeliveryOrderEntry,
    PrefetchHooks Function()> {
  $$DeliveryOrderEntriesTableTableManager(
      _$AppDatabase db, $DeliveryOrderEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeliveryOrderEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeliveryOrderEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeliveryOrderEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> orderNumber = const Value.absent(),
            Value<int> fromLocationId = const Value.absent(),
            Value<int> toLocationId = const Value.absent(),
            Value<DateTime> deliveryDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> requiresApproval = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DeliveryOrderEntriesCompanion(
            id: id,
            orderNumber: orderNumber,
            fromLocationId: fromLocationId,
            toLocationId: toLocationId,
            deliveryDate: deliveryDate,
            status: status,
            requiresApproval: requiresApproval,
            notes: notes,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String orderNumber,
            required int fromLocationId,
            required int toLocationId,
            required DateTime deliveryDate,
            required String status,
            Value<bool> requiresApproval = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required String createdBy,
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              DeliveryOrderEntriesCompanion.insert(
            id: id,
            orderNumber: orderNumber,
            fromLocationId: fromLocationId,
            toLocationId: toLocationId,
            deliveryDate: deliveryDate,
            status: status,
            requiresApproval: requiresApproval,
            notes: notes,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DeliveryOrderEntriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $DeliveryOrderEntriesTable,
        DeliveryOrderEntry,
        $$DeliveryOrderEntriesTableFilterComposer,
        $$DeliveryOrderEntriesTableOrderingComposer,
        $$DeliveryOrderEntriesTableAnnotationComposer,
        $$DeliveryOrderEntriesTableCreateCompanionBuilder,
        $$DeliveryOrderEntriesTableUpdateCompanionBuilder,
        (
          DeliveryOrderEntry,
          BaseReferences<_$AppDatabase, $DeliveryOrderEntriesTable,
              DeliveryOrderEntry>
        ),
        DeliveryOrderEntry,
        PrefetchHooks Function()>;
typedef $$SalesOrderEntriesTableCreateCompanionBuilder
    = SalesOrderEntriesCompanion Function({
  Value<int> id,
  required String orderNumber,
  required String customerName,
  required DateTime orderDate,
  required String status,
  Value<bool> requiresApproval,
  Value<String?> notes,
  required String createdBy,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$SalesOrderEntriesTableUpdateCompanionBuilder
    = SalesOrderEntriesCompanion Function({
  Value<int> id,
  Value<String> orderNumber,
  Value<String> customerName,
  Value<DateTime> orderDate,
  Value<String> status,
  Value<bool> requiresApproval,
  Value<String?> notes,
  Value<String> createdBy,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$SalesOrderEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SalesOrderEntriesTable> {
  $$SalesOrderEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderNumber => $composableBuilder(
      column: $table.orderNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get orderDate => $composableBuilder(
      column: $table.orderDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get requiresApproval => $composableBuilder(
      column: $table.requiresApproval,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SalesOrderEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesOrderEntriesTable> {
  $$SalesOrderEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderNumber => $composableBuilder(
      column: $table.orderNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get orderDate => $composableBuilder(
      column: $table.orderDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get requiresApproval => $composableBuilder(
      column: $table.requiresApproval,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SalesOrderEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesOrderEntriesTable> {
  $$SalesOrderEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderNumber => $composableBuilder(
      column: $table.orderNumber, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<DateTime> get orderDate =>
      $composableBuilder(column: $table.orderDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get requiresApproval => $composableBuilder(
      column: $table.requiresApproval, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SalesOrderEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SalesOrderEntriesTable,
    SalesOrderEntry,
    $$SalesOrderEntriesTableFilterComposer,
    $$SalesOrderEntriesTableOrderingComposer,
    $$SalesOrderEntriesTableAnnotationComposer,
    $$SalesOrderEntriesTableCreateCompanionBuilder,
    $$SalesOrderEntriesTableUpdateCompanionBuilder,
    (
      SalesOrderEntry,
      BaseReferences<_$AppDatabase, $SalesOrderEntriesTable, SalesOrderEntry>
    ),
    SalesOrderEntry,
    PrefetchHooks Function()> {
  $$SalesOrderEntriesTableTableManager(
      _$AppDatabase db, $SalesOrderEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesOrderEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesOrderEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesOrderEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> orderNumber = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<DateTime> orderDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> requiresApproval = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SalesOrderEntriesCompanion(
            id: id,
            orderNumber: orderNumber,
            customerName: customerName,
            orderDate: orderDate,
            status: status,
            requiresApproval: requiresApproval,
            notes: notes,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String orderNumber,
            required String customerName,
            required DateTime orderDate,
            required String status,
            Value<bool> requiresApproval = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required String createdBy,
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              SalesOrderEntriesCompanion.insert(
            id: id,
            orderNumber: orderNumber,
            customerName: customerName,
            orderDate: orderDate,
            status: status,
            requiresApproval: requiresApproval,
            notes: notes,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SalesOrderEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SalesOrderEntriesTable,
    SalesOrderEntry,
    $$SalesOrderEntriesTableFilterComposer,
    $$SalesOrderEntriesTableOrderingComposer,
    $$SalesOrderEntriesTableAnnotationComposer,
    $$SalesOrderEntriesTableCreateCompanionBuilder,
    $$SalesOrderEntriesTableUpdateCompanionBuilder,
    (
      SalesOrderEntry,
      BaseReferences<_$AppDatabase, $SalesOrderEntriesTable, SalesOrderEntry>
    ),
    SalesOrderEntry,
    PrefetchHooks Function()>;
typedef $$OrderItemEntriesTableCreateCompanionBuilder
    = OrderItemEntriesCompanion Function({
  Value<int> id,
  required int orderId,
  required String orderType,
  required String itemId,
  required String itemName,
  required String itemSku,
  required int quantity,
});
typedef $$OrderItemEntriesTableUpdateCompanionBuilder
    = OrderItemEntriesCompanion Function({
  Value<int> id,
  Value<int> orderId,
  Value<String> orderType,
  Value<String> itemId,
  Value<String> itemName,
  Value<String> itemSku,
  Value<int> quantity,
});

class $$OrderItemEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OrderItemEntriesTable> {
  $$OrderItemEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderType => $composableBuilder(
      column: $table.orderType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemSku => $composableBuilder(
      column: $table.itemSku, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));
}

class $$OrderItemEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderItemEntriesTable> {
  $$OrderItemEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderType => $composableBuilder(
      column: $table.orderType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemSku => $composableBuilder(
      column: $table.itemSku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));
}

class $$OrderItemEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderItemEntriesTable> {
  $$OrderItemEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get orderType =>
      $composableBuilder(column: $table.orderType, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<String> get itemSku =>
      $composableBuilder(column: $table.itemSku, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$OrderItemEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrderItemEntriesTable,
    OrderItemEntry,
    $$OrderItemEntriesTableFilterComposer,
    $$OrderItemEntriesTableOrderingComposer,
    $$OrderItemEntriesTableAnnotationComposer,
    $$OrderItemEntriesTableCreateCompanionBuilder,
    $$OrderItemEntriesTableUpdateCompanionBuilder,
    (
      OrderItemEntry,
      BaseReferences<_$AppDatabase, $OrderItemEntriesTable, OrderItemEntry>
    ),
    OrderItemEntry,
    PrefetchHooks Function()> {
  $$OrderItemEntriesTableTableManager(
      _$AppDatabase db, $OrderItemEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderItemEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderItemEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderItemEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> orderId = const Value.absent(),
            Value<String> orderType = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String> itemName = const Value.absent(),
            Value<String> itemSku = const Value.absent(),
            Value<int> quantity = const Value.absent(),
          }) =>
              OrderItemEntriesCompanion(
            id: id,
            orderId: orderId,
            orderType: orderType,
            itemId: itemId,
            itemName: itemName,
            itemSku: itemSku,
            quantity: quantity,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int orderId,
            required String orderType,
            required String itemId,
            required String itemName,
            required String itemSku,
            required int quantity,
          }) =>
              OrderItemEntriesCompanion.insert(
            id: id,
            orderId: orderId,
            orderType: orderType,
            itemId: itemId,
            itemName: itemName,
            itemSku: itemSku,
            quantity: quantity,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrderItemEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrderItemEntriesTable,
    OrderItemEntry,
    $$OrderItemEntriesTableFilterComposer,
    $$OrderItemEntriesTableOrderingComposer,
    $$OrderItemEntriesTableAnnotationComposer,
    $$OrderItemEntriesTableCreateCompanionBuilder,
    $$OrderItemEntriesTableUpdateCompanionBuilder,
    (
      OrderItemEntry,
      BaseReferences<_$AppDatabase, $OrderItemEntriesTable, OrderItemEntry>
    ),
    OrderItemEntry,
    PrefetchHooks Function()>;
typedef $$OrderStatusHistoryEntriesTableCreateCompanionBuilder
    = OrderStatusHistoryEntriesCompanion Function({
  Value<int> id,
  required int orderId,
  required String orderType,
  required String status,
  required String changedBy,
  required DateTime changedAt,
});
typedef $$OrderStatusHistoryEntriesTableUpdateCompanionBuilder
    = OrderStatusHistoryEntriesCompanion Function({
  Value<int> id,
  Value<int> orderId,
  Value<String> orderType,
  Value<String> status,
  Value<String> changedBy,
  Value<DateTime> changedAt,
});

class $$OrderStatusHistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OrderStatusHistoryEntriesTable> {
  $$OrderStatusHistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderType => $composableBuilder(
      column: $table.orderType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get changedBy => $composableBuilder(
      column: $table.changedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get changedAt => $composableBuilder(
      column: $table.changedAt, builder: (column) => ColumnFilters(column));
}

class $$OrderStatusHistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderStatusHistoryEntriesTable> {
  $$OrderStatusHistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderType => $composableBuilder(
      column: $table.orderType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get changedBy => $composableBuilder(
      column: $table.changedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get changedAt => $composableBuilder(
      column: $table.changedAt, builder: (column) => ColumnOrderings(column));
}

class $$OrderStatusHistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderStatusHistoryEntriesTable> {
  $$OrderStatusHistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get orderType =>
      $composableBuilder(column: $table.orderType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get changedBy =>
      $composableBuilder(column: $table.changedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);
}

class $$OrderStatusHistoryEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrderStatusHistoryEntriesTable,
    OrderStatusHistoryEntry,
    $$OrderStatusHistoryEntriesTableFilterComposer,
    $$OrderStatusHistoryEntriesTableOrderingComposer,
    $$OrderStatusHistoryEntriesTableAnnotationComposer,
    $$OrderStatusHistoryEntriesTableCreateCompanionBuilder,
    $$OrderStatusHistoryEntriesTableUpdateCompanionBuilder,
    (
      OrderStatusHistoryEntry,
      BaseReferences<_$AppDatabase, $OrderStatusHistoryEntriesTable,
          OrderStatusHistoryEntry>
    ),
    OrderStatusHistoryEntry,
    PrefetchHooks Function()> {
  $$OrderStatusHistoryEntriesTableTableManager(
      _$AppDatabase db, $OrderStatusHistoryEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderStatusHistoryEntriesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderStatusHistoryEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderStatusHistoryEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> orderId = const Value.absent(),
            Value<String> orderType = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> changedBy = const Value.absent(),
            Value<DateTime> changedAt = const Value.absent(),
          }) =>
              OrderStatusHistoryEntriesCompanion(
            id: id,
            orderId: orderId,
            orderType: orderType,
            status: status,
            changedBy: changedBy,
            changedAt: changedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int orderId,
            required String orderType,
            required String status,
            required String changedBy,
            required DateTime changedAt,
          }) =>
              OrderStatusHistoryEntriesCompanion.insert(
            id: id,
            orderId: orderId,
            orderType: orderType,
            status: status,
            changedBy: changedBy,
            changedAt: changedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrderStatusHistoryEntriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $OrderStatusHistoryEntriesTable,
        OrderStatusHistoryEntry,
        $$OrderStatusHistoryEntriesTableFilterComposer,
        $$OrderStatusHistoryEntriesTableOrderingComposer,
        $$OrderStatusHistoryEntriesTableAnnotationComposer,
        $$OrderStatusHistoryEntriesTableCreateCompanionBuilder,
        $$OrderStatusHistoryEntriesTableUpdateCompanionBuilder,
        (
          OrderStatusHistoryEntry,
          BaseReferences<_$AppDatabase, $OrderStatusHistoryEntriesTable,
              OrderStatusHistoryEntry>
        ),
        OrderStatusHistoryEntry,
        PrefetchHooks Function()>;
typedef $$PurchaseOrdersTableCreateCompanionBuilder = PurchaseOrdersCompanion
    Function({
  required String id,
  required String poNumber,
  required String supplier,
  required String status,
  Value<DateTime?> dueDate,
  required DateTime expectedDate,
  Value<DateTime?> receivedAt,
  Value<int> rowid,
});
typedef $$PurchaseOrdersTableUpdateCompanionBuilder = PurchaseOrdersCompanion
    Function({
  Value<String> id,
  Value<String> poNumber,
  Value<String> supplier,
  Value<String> status,
  Value<DateTime?> dueDate,
  Value<DateTime> expectedDate,
  Value<DateTime?> receivedAt,
  Value<int> rowid,
});

class $$PurchaseOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseOrdersTable> {
  $$PurchaseOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get poNumber => $composableBuilder(
      column: $table.poNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplier => $composableBuilder(
      column: $table.supplier, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expectedDate => $composableBuilder(
      column: $table.expectedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
      column: $table.receivedAt, builder: (column) => ColumnFilters(column));
}

class $$PurchaseOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseOrdersTable> {
  $$PurchaseOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get poNumber => $composableBuilder(
      column: $table.poNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplier => $composableBuilder(
      column: $table.supplier, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expectedDate => $composableBuilder(
      column: $table.expectedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
      column: $table.receivedAt, builder: (column) => ColumnOrderings(column));
}

class $$PurchaseOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseOrdersTable> {
  $$PurchaseOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get poNumber =>
      $composableBuilder(column: $table.poNumber, builder: (column) => column);

  GeneratedColumn<String> get supplier =>
      $composableBuilder(column: $table.supplier, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get expectedDate => $composableBuilder(
      column: $table.expectedDate, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
      column: $table.receivedAt, builder: (column) => column);
}

class $$PurchaseOrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PurchaseOrdersTable,
    PurchaseOrder,
    $$PurchaseOrdersTableFilterComposer,
    $$PurchaseOrdersTableOrderingComposer,
    $$PurchaseOrdersTableAnnotationComposer,
    $$PurchaseOrdersTableCreateCompanionBuilder,
    $$PurchaseOrdersTableUpdateCompanionBuilder,
    (
      PurchaseOrder,
      BaseReferences<_$AppDatabase, $PurchaseOrdersTable, PurchaseOrder>
    ),
    PurchaseOrder,
    PrefetchHooks Function()> {
  $$PurchaseOrdersTableTableManager(
      _$AppDatabase db, $PurchaseOrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> poNumber = const Value.absent(),
            Value<String> supplier = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime> expectedDate = const Value.absent(),
            Value<DateTime?> receivedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchaseOrdersCompanion(
            id: id,
            poNumber: poNumber,
            supplier: supplier,
            status: status,
            dueDate: dueDate,
            expectedDate: expectedDate,
            receivedAt: receivedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String poNumber,
            required String supplier,
            required String status,
            Value<DateTime?> dueDate = const Value.absent(),
            required DateTime expectedDate,
            Value<DateTime?> receivedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchaseOrdersCompanion.insert(
            id: id,
            poNumber: poNumber,
            supplier: supplier,
            status: status,
            dueDate: dueDate,
            expectedDate: expectedDate,
            receivedAt: receivedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PurchaseOrdersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PurchaseOrdersTable,
    PurchaseOrder,
    $$PurchaseOrdersTableFilterComposer,
    $$PurchaseOrdersTableOrderingComposer,
    $$PurchaseOrdersTableAnnotationComposer,
    $$PurchaseOrdersTableCreateCompanionBuilder,
    $$PurchaseOrdersTableUpdateCompanionBuilder,
    (
      PurchaseOrder,
      BaseReferences<_$AppDatabase, $PurchaseOrdersTable, PurchaseOrder>
    ),
    PurchaseOrder,
    PrefetchHooks Function()>;
typedef $$PoLineItemsTableCreateCompanionBuilder = PoLineItemsCompanion
    Function({
  required String id,
  required String poId,
  required String itemCode,
  required String itemName,
  required int expectedQty,
  Value<int> receivedQty,
  Value<bool> flagged,
  Value<String?> flagReason,
  required String status,
  Value<int> rowid,
});
typedef $$PoLineItemsTableUpdateCompanionBuilder = PoLineItemsCompanion
    Function({
  Value<String> id,
  Value<String> poId,
  Value<String> itemCode,
  Value<String> itemName,
  Value<int> expectedQty,
  Value<int> receivedQty,
  Value<bool> flagged,
  Value<String?> flagReason,
  Value<String> status,
  Value<int> rowid,
});

class $$PoLineItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PoLineItemsTable> {
  $$PoLineItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get poId => $composableBuilder(
      column: $table.poId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemCode => $composableBuilder(
      column: $table.itemCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expectedQty => $composableBuilder(
      column: $table.expectedQty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get receivedQty => $composableBuilder(
      column: $table.receivedQty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get flagged => $composableBuilder(
      column: $table.flagged, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get flagReason => $composableBuilder(
      column: $table.flagReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$PoLineItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PoLineItemsTable> {
  $$PoLineItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get poId => $composableBuilder(
      column: $table.poId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemCode => $composableBuilder(
      column: $table.itemCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expectedQty => $composableBuilder(
      column: $table.expectedQty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get receivedQty => $composableBuilder(
      column: $table.receivedQty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get flagged => $composableBuilder(
      column: $table.flagged, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get flagReason => $composableBuilder(
      column: $table.flagReason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$PoLineItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PoLineItemsTable> {
  $$PoLineItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get poId =>
      $composableBuilder(column: $table.poId, builder: (column) => column);

  GeneratedColumn<String> get itemCode =>
      $composableBuilder(column: $table.itemCode, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<int> get expectedQty => $composableBuilder(
      column: $table.expectedQty, builder: (column) => column);

  GeneratedColumn<int> get receivedQty => $composableBuilder(
      column: $table.receivedQty, builder: (column) => column);

  GeneratedColumn<bool> get flagged =>
      $composableBuilder(column: $table.flagged, builder: (column) => column);

  GeneratedColumn<String> get flagReason => $composableBuilder(
      column: $table.flagReason, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$PoLineItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PoLineItemsTable,
    PoLineItem,
    $$PoLineItemsTableFilterComposer,
    $$PoLineItemsTableOrderingComposer,
    $$PoLineItemsTableAnnotationComposer,
    $$PoLineItemsTableCreateCompanionBuilder,
    $$PoLineItemsTableUpdateCompanionBuilder,
    (PoLineItem, BaseReferences<_$AppDatabase, $PoLineItemsTable, PoLineItem>),
    PoLineItem,
    PrefetchHooks Function()> {
  $$PoLineItemsTableTableManager(_$AppDatabase db, $PoLineItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PoLineItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PoLineItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PoLineItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> poId = const Value.absent(),
            Value<String> itemCode = const Value.absent(),
            Value<String> itemName = const Value.absent(),
            Value<int> expectedQty = const Value.absent(),
            Value<int> receivedQty = const Value.absent(),
            Value<bool> flagged = const Value.absent(),
            Value<String?> flagReason = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PoLineItemsCompanion(
            id: id,
            poId: poId,
            itemCode: itemCode,
            itemName: itemName,
            expectedQty: expectedQty,
            receivedQty: receivedQty,
            flagged: flagged,
            flagReason: flagReason,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String poId,
            required String itemCode,
            required String itemName,
            required int expectedQty,
            Value<int> receivedQty = const Value.absent(),
            Value<bool> flagged = const Value.absent(),
            Value<String?> flagReason = const Value.absent(),
            required String status,
            Value<int> rowid = const Value.absent(),
          }) =>
              PoLineItemsCompanion.insert(
            id: id,
            poId: poId,
            itemCode: itemCode,
            itemName: itemName,
            expectedQty: expectedQty,
            receivedQty: receivedQty,
            flagged: flagged,
            flagReason: flagReason,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PoLineItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PoLineItemsTable,
    PoLineItem,
    $$PoLineItemsTableFilterComposer,
    $$PoLineItemsTableOrderingComposer,
    $$PoLineItemsTableAnnotationComposer,
    $$PoLineItemsTableCreateCompanionBuilder,
    $$PoLineItemsTableUpdateCompanionBuilder,
    (PoLineItem, BaseReferences<_$AppDatabase, $PoLineItemsTable, PoLineItem>),
    PoLineItem,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String operationType,
  required String referenceId,
  required String payload,
  Value<DateTime> queuedAt,
  Value<bool> synced,
  Value<DateTime?> syncedAt,
  Value<String?> idempotencyKey,
  Value<String> status,
  Value<int> attempts,
  Value<String?> lastError,
  Value<String?> warehouseId,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> operationType,
  Value<String> referenceId,
  Value<String> payload,
  Value<DateTime> queuedAt,
  Value<bool> synced,
  Value<DateTime?> syncedAt,
  Value<String?> idempotencyKey,
  Value<String> status,
  Value<int> attempts,
  Value<String?> lastError,
  Value<String?> warehouseId,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operationType => $composableBuilder(
      column: $table.operationType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get queuedAt => $composableBuilder(
      column: $table.queuedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operationType => $composableBuilder(
      column: $table.operationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get queuedAt => $composableBuilder(
      column: $table.queuedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
      column: $table.operationType, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get queuedAt =>
      $composableBuilder(column: $table.queuedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> operationType = const Value.absent(),
            Value<String> referenceId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> queuedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<String?> idempotencyKey = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<String?> warehouseId = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            operationType: operationType,
            referenceId: referenceId,
            payload: payload,
            queuedAt: queuedAt,
            synced: synced,
            syncedAt: syncedAt,
            idempotencyKey: idempotencyKey,
            status: status,
            attempts: attempts,
            lastError: lastError,
            warehouseId: warehouseId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String operationType,
            required String referenceId,
            required String payload,
            Value<DateTime> queuedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<String?> idempotencyKey = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<String?> warehouseId = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            operationType: operationType,
            referenceId: referenceId,
            payload: payload,
            queuedAt: queuedAt,
            synced: synced,
            syncedAt: syncedAt,
            idempotencyKey: idempotencyKey,
            status: status,
            attempts: attempts,
            lastError: lastError,
            warehouseId: warehouseId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()>;
typedef $$CatalogItemsTableCreateCompanionBuilder = CatalogItemsCompanion
    Function({
  required String id,
  required String sku,
  required String name,
  required String uom,
  required bool isActive,
  Value<int> rowid,
});
typedef $$CatalogItemsTableUpdateCompanionBuilder = CatalogItemsCompanion
    Function({
  Value<String> id,
  Value<String> sku,
  Value<String> name,
  Value<String> uom,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$CatalogItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uom => $composableBuilder(
      column: $table.uom, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$CatalogItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uom => $composableBuilder(
      column: $table.uom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$CatalogItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get uom =>
      $composableBuilder(column: $table.uom, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$CatalogItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CatalogItemsTable,
    CatalogItemRow,
    $$CatalogItemsTableFilterComposer,
    $$CatalogItemsTableOrderingComposer,
    $$CatalogItemsTableAnnotationComposer,
    $$CatalogItemsTableCreateCompanionBuilder,
    $$CatalogItemsTableUpdateCompanionBuilder,
    (
      CatalogItemRow,
      BaseReferences<_$AppDatabase, $CatalogItemsTable, CatalogItemRow>
    ),
    CatalogItemRow,
    PrefetchHooks Function()> {
  $$CatalogItemsTableTableManager(_$AppDatabase db, $CatalogItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sku = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> uom = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogItemsCompanion(
            id: id,
            sku: sku,
            name: name,
            uom: uom,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sku,
            required String name,
            required String uom,
            required bool isActive,
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogItemsCompanion.insert(
            id: id,
            sku: sku,
            name: name,
            uom: uom,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CatalogItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CatalogItemsTable,
    CatalogItemRow,
    $$CatalogItemsTableFilterComposer,
    $$CatalogItemsTableOrderingComposer,
    $$CatalogItemsTableAnnotationComposer,
    $$CatalogItemsTableCreateCompanionBuilder,
    $$CatalogItemsTableUpdateCompanionBuilder,
    (
      CatalogItemRow,
      BaseReferences<_$AppDatabase, $CatalogItemsTable, CatalogItemRow>
    ),
    CatalogItemRow,
    PrefetchHooks Function()>;
typedef $$CatalogBarcodesTableCreateCompanionBuilder = CatalogBarcodesCompanion
    Function({
  required String id,
  required String itemId,
  required String code,
  Value<int> rowid,
});
typedef $$CatalogBarcodesTableUpdateCompanionBuilder = CatalogBarcodesCompanion
    Function({
  Value<String> id,
  Value<String> itemId,
  Value<String> code,
  Value<int> rowid,
});

class $$CatalogBarcodesTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogBarcodesTable> {
  $$CatalogBarcodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));
}

class $$CatalogBarcodesTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogBarcodesTable> {
  $$CatalogBarcodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));
}

class $$CatalogBarcodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogBarcodesTable> {
  $$CatalogBarcodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);
}

class $$CatalogBarcodesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CatalogBarcodesTable,
    CatalogBarcodeRow,
    $$CatalogBarcodesTableFilterComposer,
    $$CatalogBarcodesTableOrderingComposer,
    $$CatalogBarcodesTableAnnotationComposer,
    $$CatalogBarcodesTableCreateCompanionBuilder,
    $$CatalogBarcodesTableUpdateCompanionBuilder,
    (
      CatalogBarcodeRow,
      BaseReferences<_$AppDatabase, $CatalogBarcodesTable, CatalogBarcodeRow>
    ),
    CatalogBarcodeRow,
    PrefetchHooks Function()> {
  $$CatalogBarcodesTableTableManager(
      _$AppDatabase db, $CatalogBarcodesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogBarcodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogBarcodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogBarcodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogBarcodesCompanion(
            id: id,
            itemId: itemId,
            code: code,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            required String code,
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogBarcodesCompanion.insert(
            id: id,
            itemId: itemId,
            code: code,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CatalogBarcodesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CatalogBarcodesTable,
    CatalogBarcodeRow,
    $$CatalogBarcodesTableFilterComposer,
    $$CatalogBarcodesTableOrderingComposer,
    $$CatalogBarcodesTableAnnotationComposer,
    $$CatalogBarcodesTableCreateCompanionBuilder,
    $$CatalogBarcodesTableUpdateCompanionBuilder,
    (
      CatalogBarcodeRow,
      BaseReferences<_$AppDatabase, $CatalogBarcodesTable, CatalogBarcodeRow>
    ),
    CatalogBarcodeRow,
    PrefetchHooks Function()>;
typedef $$WarehouseLocationsTableCreateCompanionBuilder
    = WarehouseLocationsCompanion Function({
  required String id,
  required String warehouseId,
  required String code,
  required String type,
  Value<int> rowid,
});
typedef $$WarehouseLocationsTableUpdateCompanionBuilder
    = WarehouseLocationsCompanion Function({
  Value<String> id,
  Value<String> warehouseId,
  Value<String> code,
  Value<String> type,
  Value<int> rowid,
});

class $$WarehouseLocationsTableFilterComposer
    extends Composer<_$AppDatabase, $WarehouseLocationsTable> {
  $$WarehouseLocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));
}

class $$WarehouseLocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $WarehouseLocationsTable> {
  $$WarehouseLocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));
}

class $$WarehouseLocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WarehouseLocationsTable> {
  $$WarehouseLocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$WarehouseLocationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WarehouseLocationsTable,
    WarehouseLocationRow,
    $$WarehouseLocationsTableFilterComposer,
    $$WarehouseLocationsTableOrderingComposer,
    $$WarehouseLocationsTableAnnotationComposer,
    $$WarehouseLocationsTableCreateCompanionBuilder,
    $$WarehouseLocationsTableUpdateCompanionBuilder,
    (
      WarehouseLocationRow,
      BaseReferences<_$AppDatabase, $WarehouseLocationsTable,
          WarehouseLocationRow>
    ),
    WarehouseLocationRow,
    PrefetchHooks Function()> {
  $$WarehouseLocationsTableTableManager(
      _$AppDatabase db, $WarehouseLocationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WarehouseLocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WarehouseLocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WarehouseLocationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> warehouseId = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WarehouseLocationsCompanion(
            id: id,
            warehouseId: warehouseId,
            code: code,
            type: type,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String warehouseId,
            required String code,
            required String type,
            Value<int> rowid = const Value.absent(),
          }) =>
              WarehouseLocationsCompanion.insert(
            id: id,
            warehouseId: warehouseId,
            code: code,
            type: type,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WarehouseLocationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WarehouseLocationsTable,
    WarehouseLocationRow,
    $$WarehouseLocationsTableFilterComposer,
    $$WarehouseLocationsTableOrderingComposer,
    $$WarehouseLocationsTableAnnotationComposer,
    $$WarehouseLocationsTableCreateCompanionBuilder,
    $$WarehouseLocationsTableUpdateCompanionBuilder,
    (
      WarehouseLocationRow,
      BaseReferences<_$AppDatabase, $WarehouseLocationsTable,
          WarehouseLocationRow>
    ),
    WarehouseLocationRow,
    PrefetchHooks Function()>;
typedef $$RemoteCountSessionsTableCreateCompanionBuilder
    = RemoteCountSessionsCompanion Function({
  required String id,
  required String warehouseId,
  required String createdByUserId,
  Value<String?> label,
  required String status,
  required DateTime submittedAt,
  Value<DateTime?> reviewedAt,
  Value<String?> rejectReason,
  Value<int> rowid,
});
typedef $$RemoteCountSessionsTableUpdateCompanionBuilder
    = RemoteCountSessionsCompanion Function({
  Value<String> id,
  Value<String> warehouseId,
  Value<String> createdByUserId,
  Value<String?> label,
  Value<String> status,
  Value<DateTime> submittedAt,
  Value<DateTime?> reviewedAt,
  Value<String?> rejectReason,
  Value<int> rowid,
});

class $$RemoteCountSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $RemoteCountSessionsTable> {
  $$RemoteCountSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdByUserId => $composableBuilder(
      column: $table.createdByUserId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rejectReason => $composableBuilder(
      column: $table.rejectReason, builder: (column) => ColumnFilters(column));
}

class $$RemoteCountSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RemoteCountSessionsTable> {
  $$RemoteCountSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdByUserId => $composableBuilder(
      column: $table.createdByUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rejectReason => $composableBuilder(
      column: $table.rejectReason,
      builder: (column) => ColumnOrderings(column));
}

class $$RemoteCountSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemoteCountSessionsTable> {
  $$RemoteCountSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => column);

  GeneratedColumn<String> get createdByUserId => $composableBuilder(
      column: $table.createdByUserId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => column);

  GeneratedColumn<String> get rejectReason => $composableBuilder(
      column: $table.rejectReason, builder: (column) => column);
}

class $$RemoteCountSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemoteCountSessionsTable,
    RemoteCountSessionRow,
    $$RemoteCountSessionsTableFilterComposer,
    $$RemoteCountSessionsTableOrderingComposer,
    $$RemoteCountSessionsTableAnnotationComposer,
    $$RemoteCountSessionsTableCreateCompanionBuilder,
    $$RemoteCountSessionsTableUpdateCompanionBuilder,
    (
      RemoteCountSessionRow,
      BaseReferences<_$AppDatabase, $RemoteCountSessionsTable,
          RemoteCountSessionRow>
    ),
    RemoteCountSessionRow,
    PrefetchHooks Function()> {
  $$RemoteCountSessionsTableTableManager(
      _$AppDatabase db, $RemoteCountSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemoteCountSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemoteCountSessionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemoteCountSessionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> warehouseId = const Value.absent(),
            Value<String> createdByUserId = const Value.absent(),
            Value<String?> label = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> submittedAt = const Value.absent(),
            Value<DateTime?> reviewedAt = const Value.absent(),
            Value<String?> rejectReason = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemoteCountSessionsCompanion(
            id: id,
            warehouseId: warehouseId,
            createdByUserId: createdByUserId,
            label: label,
            status: status,
            submittedAt: submittedAt,
            reviewedAt: reviewedAt,
            rejectReason: rejectReason,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String warehouseId,
            required String createdByUserId,
            Value<String?> label = const Value.absent(),
            required String status,
            required DateTime submittedAt,
            Value<DateTime?> reviewedAt = const Value.absent(),
            Value<String?> rejectReason = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemoteCountSessionsCompanion.insert(
            id: id,
            warehouseId: warehouseId,
            createdByUserId: createdByUserId,
            label: label,
            status: status,
            submittedAt: submittedAt,
            reviewedAt: reviewedAt,
            rejectReason: rejectReason,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RemoteCountSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemoteCountSessionsTable,
    RemoteCountSessionRow,
    $$RemoteCountSessionsTableFilterComposer,
    $$RemoteCountSessionsTableOrderingComposer,
    $$RemoteCountSessionsTableAnnotationComposer,
    $$RemoteCountSessionsTableCreateCompanionBuilder,
    $$RemoteCountSessionsTableUpdateCompanionBuilder,
    (
      RemoteCountSessionRow,
      BaseReferences<_$AppDatabase, $RemoteCountSessionsTable,
          RemoteCountSessionRow>
    ),
    RemoteCountSessionRow,
    PrefetchHooks Function()>;
typedef $$RemoteCountLinesTableCreateCompanionBuilder
    = RemoteCountLinesCompanion Function({
  required String id,
  required String sessionId,
  required String itemId,
  required String locationId,
  required double counted,
  required double systemAtSubmit,
  Value<double?> adjustment,
  Value<int> rowid,
});
typedef $$RemoteCountLinesTableUpdateCompanionBuilder
    = RemoteCountLinesCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> itemId,
  Value<String> locationId,
  Value<double> counted,
  Value<double> systemAtSubmit,
  Value<double?> adjustment,
  Value<int> rowid,
});

class $$RemoteCountLinesTableFilterComposer
    extends Composer<_$AppDatabase, $RemoteCountLinesTable> {
  $$RemoteCountLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get counted => $composableBuilder(
      column: $table.counted, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get systemAtSubmit => $composableBuilder(
      column: $table.systemAtSubmit,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get adjustment => $composableBuilder(
      column: $table.adjustment, builder: (column) => ColumnFilters(column));
}

class $$RemoteCountLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $RemoteCountLinesTable> {
  $$RemoteCountLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get counted => $composableBuilder(
      column: $table.counted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get systemAtSubmit => $composableBuilder(
      column: $table.systemAtSubmit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get adjustment => $composableBuilder(
      column: $table.adjustment, builder: (column) => ColumnOrderings(column));
}

class $$RemoteCountLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemoteCountLinesTable> {
  $$RemoteCountLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => column);

  GeneratedColumn<double> get counted =>
      $composableBuilder(column: $table.counted, builder: (column) => column);

  GeneratedColumn<double> get systemAtSubmit => $composableBuilder(
      column: $table.systemAtSubmit, builder: (column) => column);

  GeneratedColumn<double> get adjustment => $composableBuilder(
      column: $table.adjustment, builder: (column) => column);
}

class $$RemoteCountLinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemoteCountLinesTable,
    RemoteCountLineRow,
    $$RemoteCountLinesTableFilterComposer,
    $$RemoteCountLinesTableOrderingComposer,
    $$RemoteCountLinesTableAnnotationComposer,
    $$RemoteCountLinesTableCreateCompanionBuilder,
    $$RemoteCountLinesTableUpdateCompanionBuilder,
    (
      RemoteCountLineRow,
      BaseReferences<_$AppDatabase, $RemoteCountLinesTable, RemoteCountLineRow>
    ),
    RemoteCountLineRow,
    PrefetchHooks Function()> {
  $$RemoteCountLinesTableTableManager(
      _$AppDatabase db, $RemoteCountLinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemoteCountLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemoteCountLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemoteCountLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String> locationId = const Value.absent(),
            Value<double> counted = const Value.absent(),
            Value<double> systemAtSubmit = const Value.absent(),
            Value<double?> adjustment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemoteCountLinesCompanion(
            id: id,
            sessionId: sessionId,
            itemId: itemId,
            locationId: locationId,
            counted: counted,
            systemAtSubmit: systemAtSubmit,
            adjustment: adjustment,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sessionId,
            required String itemId,
            required String locationId,
            required double counted,
            required double systemAtSubmit,
            Value<double?> adjustment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemoteCountLinesCompanion.insert(
            id: id,
            sessionId: sessionId,
            itemId: itemId,
            locationId: locationId,
            counted: counted,
            systemAtSubmit: systemAtSubmit,
            adjustment: adjustment,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RemoteCountLinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemoteCountLinesTable,
    RemoteCountLineRow,
    $$RemoteCountLinesTableFilterComposer,
    $$RemoteCountLinesTableOrderingComposer,
    $$RemoteCountLinesTableAnnotationComposer,
    $$RemoteCountLinesTableCreateCompanionBuilder,
    $$RemoteCountLinesTableUpdateCompanionBuilder,
    (
      RemoteCountLineRow,
      BaseReferences<_$AppDatabase, $RemoteCountLinesTable, RemoteCountLineRow>
    ),
    RemoteCountLineRow,
    PrefetchHooks Function()>;
typedef $$SyncCursorsTableCreateCompanionBuilder = SyncCursorsCompanion
    Function({
  required String warehouseId,
  required int cursor,
  Value<int> mirrorVersion,
  Value<int> caughtUpThrough,
  Value<int> rowid,
});
typedef $$SyncCursorsTableUpdateCompanionBuilder = SyncCursorsCompanion
    Function({
  Value<String> warehouseId,
  Value<int> cursor,
  Value<int> mirrorVersion,
  Value<int> caughtUpThrough,
  Value<int> rowid,
});

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cursor => $composableBuilder(
      column: $table.cursor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mirrorVersion => $composableBuilder(
      column: $table.mirrorVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get caughtUpThrough => $composableBuilder(
      column: $table.caughtUpThrough,
      builder: (column) => ColumnFilters(column));
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cursor => $composableBuilder(
      column: $table.cursor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mirrorVersion => $composableBuilder(
      column: $table.mirrorVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get caughtUpThrough => $composableBuilder(
      column: $table.caughtUpThrough,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => column);

  GeneratedColumn<int> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<int> get mirrorVersion => $composableBuilder(
      column: $table.mirrorVersion, builder: (column) => column);

  GeneratedColumn<int> get caughtUpThrough => $composableBuilder(
      column: $table.caughtUpThrough, builder: (column) => column);
}

class $$SyncCursorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncCursorsTable,
    SyncCursorRow,
    $$SyncCursorsTableFilterComposer,
    $$SyncCursorsTableOrderingComposer,
    $$SyncCursorsTableAnnotationComposer,
    $$SyncCursorsTableCreateCompanionBuilder,
    $$SyncCursorsTableUpdateCompanionBuilder,
    (
      SyncCursorRow,
      BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursorRow>
    ),
    SyncCursorRow,
    PrefetchHooks Function()> {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> warehouseId = const Value.absent(),
            Value<int> cursor = const Value.absent(),
            Value<int> mirrorVersion = const Value.absent(),
            Value<int> caughtUpThrough = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncCursorsCompanion(
            warehouseId: warehouseId,
            cursor: cursor,
            mirrorVersion: mirrorVersion,
            caughtUpThrough: caughtUpThrough,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String warehouseId,
            required int cursor,
            Value<int> mirrorVersion = const Value.absent(),
            Value<int> caughtUpThrough = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncCursorsCompanion.insert(
            warehouseId: warehouseId,
            cursor: cursor,
            mirrorVersion: mirrorVersion,
            caughtUpThrough: caughtUpThrough,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncCursorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncCursorsTable,
    SyncCursorRow,
    $$SyncCursorsTableFilterComposer,
    $$SyncCursorsTableOrderingComposer,
    $$SyncCursorsTableAnnotationComposer,
    $$SyncCursorsTableCreateCompanionBuilder,
    $$SyncCursorsTableUpdateCompanionBuilder,
    (
      SyncCursorRow,
      BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursorRow>
    ),
    SyncCursorRow,
    PrefetchHooks Function()>;
typedef $$RemotePurchaseOrdersTableCreateCompanionBuilder
    = RemotePurchaseOrdersCompanion Function({
  required String id,
  required String warehouseId,
  required String number,
  required String supplier,
  Value<DateTime?> expectedDate,
  required String status,
  Value<int> rowid,
});
typedef $$RemotePurchaseOrdersTableUpdateCompanionBuilder
    = RemotePurchaseOrdersCompanion Function({
  Value<String> id,
  Value<String> warehouseId,
  Value<String> number,
  Value<String> supplier,
  Value<DateTime?> expectedDate,
  Value<String> status,
  Value<int> rowid,
});

class $$RemotePurchaseOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $RemotePurchaseOrdersTable> {
  $$RemotePurchaseOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplier => $composableBuilder(
      column: $table.supplier, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expectedDate => $composableBuilder(
      column: $table.expectedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$RemotePurchaseOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemotePurchaseOrdersTable> {
  $$RemotePurchaseOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplier => $composableBuilder(
      column: $table.supplier, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expectedDate => $composableBuilder(
      column: $table.expectedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$RemotePurchaseOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemotePurchaseOrdersTable> {
  $$RemotePurchaseOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get supplier =>
      $composableBuilder(column: $table.supplier, builder: (column) => column);

  GeneratedColumn<DateTime> get expectedDate => $composableBuilder(
      column: $table.expectedDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$RemotePurchaseOrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemotePurchaseOrdersTable,
    RemotePurchaseOrderRow,
    $$RemotePurchaseOrdersTableFilterComposer,
    $$RemotePurchaseOrdersTableOrderingComposer,
    $$RemotePurchaseOrdersTableAnnotationComposer,
    $$RemotePurchaseOrdersTableCreateCompanionBuilder,
    $$RemotePurchaseOrdersTableUpdateCompanionBuilder,
    (
      RemotePurchaseOrderRow,
      BaseReferences<_$AppDatabase, $RemotePurchaseOrdersTable,
          RemotePurchaseOrderRow>
    ),
    RemotePurchaseOrderRow,
    PrefetchHooks Function()> {
  $$RemotePurchaseOrdersTableTableManager(
      _$AppDatabase db, $RemotePurchaseOrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemotePurchaseOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemotePurchaseOrdersTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemotePurchaseOrdersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> warehouseId = const Value.absent(),
            Value<String> number = const Value.absent(),
            Value<String> supplier = const Value.absent(),
            Value<DateTime?> expectedDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemotePurchaseOrdersCompanion(
            id: id,
            warehouseId: warehouseId,
            number: number,
            supplier: supplier,
            expectedDate: expectedDate,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String warehouseId,
            required String number,
            required String supplier,
            Value<DateTime?> expectedDate = const Value.absent(),
            required String status,
            Value<int> rowid = const Value.absent(),
          }) =>
              RemotePurchaseOrdersCompanion.insert(
            id: id,
            warehouseId: warehouseId,
            number: number,
            supplier: supplier,
            expectedDate: expectedDate,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RemotePurchaseOrdersTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $RemotePurchaseOrdersTable,
        RemotePurchaseOrderRow,
        $$RemotePurchaseOrdersTableFilterComposer,
        $$RemotePurchaseOrdersTableOrderingComposer,
        $$RemotePurchaseOrdersTableAnnotationComposer,
        $$RemotePurchaseOrdersTableCreateCompanionBuilder,
        $$RemotePurchaseOrdersTableUpdateCompanionBuilder,
        (
          RemotePurchaseOrderRow,
          BaseReferences<_$AppDatabase, $RemotePurchaseOrdersTable,
              RemotePurchaseOrderRow>
        ),
        RemotePurchaseOrderRow,
        PrefetchHooks Function()>;
typedef $$RemotePoLinesTableCreateCompanionBuilder = RemotePoLinesCompanion
    Function({
  required String id,
  required String purchaseOrderId,
  required int lineNo,
  required String itemId,
  required double ordered,
  required double received,
  Value<int> rowid,
});
typedef $$RemotePoLinesTableUpdateCompanionBuilder = RemotePoLinesCompanion
    Function({
  Value<String> id,
  Value<String> purchaseOrderId,
  Value<int> lineNo,
  Value<String> itemId,
  Value<double> ordered,
  Value<double> received,
  Value<int> rowid,
});

class $$RemotePoLinesTableFilterComposer
    extends Composer<_$AppDatabase, $RemotePoLinesTable> {
  $$RemotePoLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purchaseOrderId => $composableBuilder(
      column: $table.purchaseOrderId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineNo => $composableBuilder(
      column: $table.lineNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get ordered => $composableBuilder(
      column: $table.ordered, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get received => $composableBuilder(
      column: $table.received, builder: (column) => ColumnFilters(column));
}

class $$RemotePoLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $RemotePoLinesTable> {
  $$RemotePoLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchaseOrderId => $composableBuilder(
      column: $table.purchaseOrderId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineNo => $composableBuilder(
      column: $table.lineNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get ordered => $composableBuilder(
      column: $table.ordered, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get received => $composableBuilder(
      column: $table.received, builder: (column) => ColumnOrderings(column));
}

class $$RemotePoLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemotePoLinesTable> {
  $$RemotePoLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get purchaseOrderId => $composableBuilder(
      column: $table.purchaseOrderId, builder: (column) => column);

  GeneratedColumn<int> get lineNo =>
      $composableBuilder(column: $table.lineNo, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<double> get ordered =>
      $composableBuilder(column: $table.ordered, builder: (column) => column);

  GeneratedColumn<double> get received =>
      $composableBuilder(column: $table.received, builder: (column) => column);
}

class $$RemotePoLinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemotePoLinesTable,
    RemotePoLineRow,
    $$RemotePoLinesTableFilterComposer,
    $$RemotePoLinesTableOrderingComposer,
    $$RemotePoLinesTableAnnotationComposer,
    $$RemotePoLinesTableCreateCompanionBuilder,
    $$RemotePoLinesTableUpdateCompanionBuilder,
    (
      RemotePoLineRow,
      BaseReferences<_$AppDatabase, $RemotePoLinesTable, RemotePoLineRow>
    ),
    RemotePoLineRow,
    PrefetchHooks Function()> {
  $$RemotePoLinesTableTableManager(_$AppDatabase db, $RemotePoLinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemotePoLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemotePoLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemotePoLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> purchaseOrderId = const Value.absent(),
            Value<int> lineNo = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<double> ordered = const Value.absent(),
            Value<double> received = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemotePoLinesCompanion(
            id: id,
            purchaseOrderId: purchaseOrderId,
            lineNo: lineNo,
            itemId: itemId,
            ordered: ordered,
            received: received,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String purchaseOrderId,
            required int lineNo,
            required String itemId,
            required double ordered,
            required double received,
            Value<int> rowid = const Value.absent(),
          }) =>
              RemotePoLinesCompanion.insert(
            id: id,
            purchaseOrderId: purchaseOrderId,
            lineNo: lineNo,
            itemId: itemId,
            ordered: ordered,
            received: received,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RemotePoLinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemotePoLinesTable,
    RemotePoLineRow,
    $$RemotePoLinesTableFilterComposer,
    $$RemotePoLinesTableOrderingComposer,
    $$RemotePoLinesTableAnnotationComposer,
    $$RemotePoLinesTableCreateCompanionBuilder,
    $$RemotePoLinesTableUpdateCompanionBuilder,
    (
      RemotePoLineRow,
      BaseReferences<_$AppDatabase, $RemotePoLinesTable, RemotePoLineRow>
    ),
    RemotePoLineRow,
    PrefetchHooks Function()>;
typedef $$RemoteOrdersTableCreateCompanionBuilder = RemoteOrdersCompanion
    Function({
  required String id,
  required String warehouseId,
  required String kind,
  required String number,
  Value<String?> destination,
  Value<String?> customerName,
  required DateTime orderDate,
  required String status,
  required bool requiresApproval,
  Value<String?> notes,
  required String createdByName,
  required DateTime createdAt,
  required String statusHistory,
  Value<int> rowid,
});
typedef $$RemoteOrdersTableUpdateCompanionBuilder = RemoteOrdersCompanion
    Function({
  Value<String> id,
  Value<String> warehouseId,
  Value<String> kind,
  Value<String> number,
  Value<String?> destination,
  Value<String?> customerName,
  Value<DateTime> orderDate,
  Value<String> status,
  Value<bool> requiresApproval,
  Value<String?> notes,
  Value<String> createdByName,
  Value<DateTime> createdAt,
  Value<String> statusHistory,
  Value<int> rowid,
});

class $$RemoteOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $RemoteOrdersTable> {
  $$RemoteOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get orderDate => $composableBuilder(
      column: $table.orderDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get requiresApproval => $composableBuilder(
      column: $table.requiresApproval,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdByName => $composableBuilder(
      column: $table.createdByName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statusHistory => $composableBuilder(
      column: $table.statusHistory, builder: (column) => ColumnFilters(column));
}

class $$RemoteOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemoteOrdersTable> {
  $$RemoteOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get orderDate => $composableBuilder(
      column: $table.orderDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get requiresApproval => $composableBuilder(
      column: $table.requiresApproval,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdByName => $composableBuilder(
      column: $table.createdByName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statusHistory => $composableBuilder(
      column: $table.statusHistory,
      builder: (column) => ColumnOrderings(column));
}

class $$RemoteOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemoteOrdersTable> {
  $$RemoteOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<DateTime> get orderDate =>
      $composableBuilder(column: $table.orderDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get requiresApproval => $composableBuilder(
      column: $table.requiresApproval, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdByName => $composableBuilder(
      column: $table.createdByName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get statusHistory => $composableBuilder(
      column: $table.statusHistory, builder: (column) => column);
}

class $$RemoteOrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemoteOrdersTable,
    RemoteOrderRow,
    $$RemoteOrdersTableFilterComposer,
    $$RemoteOrdersTableOrderingComposer,
    $$RemoteOrdersTableAnnotationComposer,
    $$RemoteOrdersTableCreateCompanionBuilder,
    $$RemoteOrdersTableUpdateCompanionBuilder,
    (
      RemoteOrderRow,
      BaseReferences<_$AppDatabase, $RemoteOrdersTable, RemoteOrderRow>
    ),
    RemoteOrderRow,
    PrefetchHooks Function()> {
  $$RemoteOrdersTableTableManager(_$AppDatabase db, $RemoteOrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemoteOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemoteOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemoteOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> warehouseId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> number = const Value.absent(),
            Value<String?> destination = const Value.absent(),
            Value<String?> customerName = const Value.absent(),
            Value<DateTime> orderDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> requiresApproval = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> createdByName = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> statusHistory = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemoteOrdersCompanion(
            id: id,
            warehouseId: warehouseId,
            kind: kind,
            number: number,
            destination: destination,
            customerName: customerName,
            orderDate: orderDate,
            status: status,
            requiresApproval: requiresApproval,
            notes: notes,
            createdByName: createdByName,
            createdAt: createdAt,
            statusHistory: statusHistory,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String warehouseId,
            required String kind,
            required String number,
            Value<String?> destination = const Value.absent(),
            Value<String?> customerName = const Value.absent(),
            required DateTime orderDate,
            required String status,
            required bool requiresApproval,
            Value<String?> notes = const Value.absent(),
            required String createdByName,
            required DateTime createdAt,
            required String statusHistory,
            Value<int> rowid = const Value.absent(),
          }) =>
              RemoteOrdersCompanion.insert(
            id: id,
            warehouseId: warehouseId,
            kind: kind,
            number: number,
            destination: destination,
            customerName: customerName,
            orderDate: orderDate,
            status: status,
            requiresApproval: requiresApproval,
            notes: notes,
            createdByName: createdByName,
            createdAt: createdAt,
            statusHistory: statusHistory,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RemoteOrdersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemoteOrdersTable,
    RemoteOrderRow,
    $$RemoteOrdersTableFilterComposer,
    $$RemoteOrdersTableOrderingComposer,
    $$RemoteOrdersTableAnnotationComposer,
    $$RemoteOrdersTableCreateCompanionBuilder,
    $$RemoteOrdersTableUpdateCompanionBuilder,
    (
      RemoteOrderRow,
      BaseReferences<_$AppDatabase, $RemoteOrdersTable, RemoteOrderRow>
    ),
    RemoteOrderRow,
    PrefetchHooks Function()>;
typedef $$RemoteOrderLinesTableCreateCompanionBuilder
    = RemoteOrderLinesCompanion Function({
  required String id,
  required String orderId,
  required String itemId,
  required String locationId,
  required double quantity,
  Value<int> rowid,
});
typedef $$RemoteOrderLinesTableUpdateCompanionBuilder
    = RemoteOrderLinesCompanion Function({
  Value<String> id,
  Value<String> orderId,
  Value<String> itemId,
  Value<String> locationId,
  Value<double> quantity,
  Value<int> rowid,
});

class $$RemoteOrderLinesTableFilterComposer
    extends Composer<_$AppDatabase, $RemoteOrderLinesTable> {
  $$RemoteOrderLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));
}

class $$RemoteOrderLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $RemoteOrderLinesTable> {
  $$RemoteOrderLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));
}

class $$RemoteOrderLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemoteOrderLinesTable> {
  $$RemoteOrderLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$RemoteOrderLinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemoteOrderLinesTable,
    RemoteOrderLineRow,
    $$RemoteOrderLinesTableFilterComposer,
    $$RemoteOrderLinesTableOrderingComposer,
    $$RemoteOrderLinesTableAnnotationComposer,
    $$RemoteOrderLinesTableCreateCompanionBuilder,
    $$RemoteOrderLinesTableUpdateCompanionBuilder,
    (
      RemoteOrderLineRow,
      BaseReferences<_$AppDatabase, $RemoteOrderLinesTable, RemoteOrderLineRow>
    ),
    RemoteOrderLineRow,
    PrefetchHooks Function()> {
  $$RemoteOrderLinesTableTableManager(
      _$AppDatabase db, $RemoteOrderLinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemoteOrderLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemoteOrderLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemoteOrderLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> orderId = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String> locationId = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemoteOrderLinesCompanion(
            id: id,
            orderId: orderId,
            itemId: itemId,
            locationId: locationId,
            quantity: quantity,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String orderId,
            required String itemId,
            required String locationId,
            required double quantity,
            Value<int> rowid = const Value.absent(),
          }) =>
              RemoteOrderLinesCompanion.insert(
            id: id,
            orderId: orderId,
            itemId: itemId,
            locationId: locationId,
            quantity: quantity,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RemoteOrderLinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemoteOrderLinesTable,
    RemoteOrderLineRow,
    $$RemoteOrderLinesTableFilterComposer,
    $$RemoteOrderLinesTableOrderingComposer,
    $$RemoteOrderLinesTableAnnotationComposer,
    $$RemoteOrderLinesTableCreateCompanionBuilder,
    $$RemoteOrderLinesTableUpdateCompanionBuilder,
    (
      RemoteOrderLineRow,
      BaseReferences<_$AppDatabase, $RemoteOrderLinesTable, RemoteOrderLineRow>
    ),
    RemoteOrderLineRow,
    PrefetchHooks Function()>;
typedef $$RemoteTasksTableCreateCompanionBuilder = RemoteTasksCompanion
    Function({
  required String id,
  required String warehouseId,
  required String title,
  required String type,
  Value<String?> locationId,
  Value<String?> assigneeUserId,
  required String status,
  Value<DateTime?> dueAt,
  required String createdByUserId,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$RemoteTasksTableUpdateCompanionBuilder = RemoteTasksCompanion
    Function({
  Value<String> id,
  Value<String> warehouseId,
  Value<String> title,
  Value<String> type,
  Value<String?> locationId,
  Value<String?> assigneeUserId,
  Value<String> status,
  Value<DateTime?> dueAt,
  Value<String> createdByUserId,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

class $$RemoteTasksTableFilterComposer
    extends Composer<_$AppDatabase, $RemoteTasksTable> {
  $$RemoteTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assigneeUserId => $composableBuilder(
      column: $table.assigneeUserId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdByUserId => $composableBuilder(
      column: $table.createdByUserId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$RemoteTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $RemoteTasksTable> {
  $$RemoteTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assigneeUserId => $composableBuilder(
      column: $table.assigneeUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdByUserId => $composableBuilder(
      column: $table.createdByUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$RemoteTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemoteTasksTable> {
  $$RemoteTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => column);

  GeneratedColumn<String> get assigneeUserId => $composableBuilder(
      column: $table.assigneeUserId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<String> get createdByUserId => $composableBuilder(
      column: $table.createdByUserId, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$RemoteTasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemoteTasksTable,
    RemoteTaskRow,
    $$RemoteTasksTableFilterComposer,
    $$RemoteTasksTableOrderingComposer,
    $$RemoteTasksTableAnnotationComposer,
    $$RemoteTasksTableCreateCompanionBuilder,
    $$RemoteTasksTableUpdateCompanionBuilder,
    (
      RemoteTaskRow,
      BaseReferences<_$AppDatabase, $RemoteTasksTable, RemoteTaskRow>
    ),
    RemoteTaskRow,
    PrefetchHooks Function()> {
  $$RemoteTasksTableTableManager(_$AppDatabase db, $RemoteTasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemoteTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemoteTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemoteTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> warehouseId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> locationId = const Value.absent(),
            Value<String?> assigneeUserId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> dueAt = const Value.absent(),
            Value<String> createdByUserId = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemoteTasksCompanion(
            id: id,
            warehouseId: warehouseId,
            title: title,
            type: type,
            locationId: locationId,
            assigneeUserId: assigneeUserId,
            status: status,
            dueAt: dueAt,
            createdByUserId: createdByUserId,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String warehouseId,
            required String title,
            required String type,
            Value<String?> locationId = const Value.absent(),
            Value<String?> assigneeUserId = const Value.absent(),
            required String status,
            Value<DateTime?> dueAt = const Value.absent(),
            required String createdByUserId,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemoteTasksCompanion.insert(
            id: id,
            warehouseId: warehouseId,
            title: title,
            type: type,
            locationId: locationId,
            assigneeUserId: assigneeUserId,
            status: status,
            dueAt: dueAt,
            createdByUserId: createdByUserId,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RemoteTasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemoteTasksTable,
    RemoteTaskRow,
    $$RemoteTasksTableFilterComposer,
    $$RemoteTasksTableOrderingComposer,
    $$RemoteTasksTableAnnotationComposer,
    $$RemoteTasksTableCreateCompanionBuilder,
    $$RemoteTasksTableUpdateCompanionBuilder,
    (
      RemoteTaskRow,
      BaseReferences<_$AppDatabase, $RemoteTasksTable, RemoteTaskRow>
    ),
    RemoteTaskRow,
    PrefetchHooks Function()>;
typedef $$RemoteAlertsTableCreateCompanionBuilder = RemoteAlertsCompanion
    Function({
  required String id,
  Value<String?> warehouseId,
  required String type,
  required String title,
  required String body,
  Value<String?> payload,
  required DateTime createdAt,
  Value<DateTime?> readAt,
  Value<int> rowid,
});
typedef $$RemoteAlertsTableUpdateCompanionBuilder = RemoteAlertsCompanion
    Function({
  Value<String> id,
  Value<String?> warehouseId,
  Value<String> type,
  Value<String> title,
  Value<String> body,
  Value<String?> payload,
  Value<DateTime> createdAt,
  Value<DateTime?> readAt,
  Value<int> rowid,
});

class $$RemoteAlertsTableFilterComposer
    extends Composer<_$AppDatabase, $RemoteAlertsTable> {
  $$RemoteAlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnFilters(column));
}

class $$RemoteAlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $RemoteAlertsTable> {
  $$RemoteAlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnOrderings(column));
}

class $$RemoteAlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemoteAlertsTable> {
  $$RemoteAlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);
}

class $$RemoteAlertsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemoteAlertsTable,
    RemoteAlertRow,
    $$RemoteAlertsTableFilterComposer,
    $$RemoteAlertsTableOrderingComposer,
    $$RemoteAlertsTableAnnotationComposer,
    $$RemoteAlertsTableCreateCompanionBuilder,
    $$RemoteAlertsTableUpdateCompanionBuilder,
    (
      RemoteAlertRow,
      BaseReferences<_$AppDatabase, $RemoteAlertsTable, RemoteAlertRow>
    ),
    RemoteAlertRow,
    PrefetchHooks Function()> {
  $$RemoteAlertsTableTableManager(_$AppDatabase db, $RemoteAlertsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemoteAlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemoteAlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemoteAlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> warehouseId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<String?> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> readAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemoteAlertsCompanion(
            id: id,
            warehouseId: warehouseId,
            type: type,
            title: title,
            body: body,
            payload: payload,
            createdAt: createdAt,
            readAt: readAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> warehouseId = const Value.absent(),
            required String type,
            required String title,
            required String body,
            Value<String?> payload = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> readAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemoteAlertsCompanion.insert(
            id: id,
            warehouseId: warehouseId,
            type: type,
            title: title,
            body: body,
            payload: payload,
            createdAt: createdAt,
            readAt: readAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RemoteAlertsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemoteAlertsTable,
    RemoteAlertRow,
    $$RemoteAlertsTableFilterComposer,
    $$RemoteAlertsTableOrderingComposer,
    $$RemoteAlertsTableAnnotationComposer,
    $$RemoteAlertsTableCreateCompanionBuilder,
    $$RemoteAlertsTableUpdateCompanionBuilder,
    (
      RemoteAlertRow,
      BaseReferences<_$AppDatabase, $RemoteAlertsTable, RemoteAlertRow>
    ),
    RemoteAlertRow,
    PrefetchHooks Function()>;
typedef $$WarehouseMembersTableCreateCompanionBuilder
    = WarehouseMembersCompanion Function({
  required String warehouseId,
  required String userId,
  required String displayName,
  required String role,
  required bool isActive,
  Value<int> rowid,
});
typedef $$WarehouseMembersTableUpdateCompanionBuilder
    = WarehouseMembersCompanion Function({
  Value<String> warehouseId,
  Value<String> userId,
  Value<String> displayName,
  Value<String> role,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$WarehouseMembersTableFilterComposer
    extends Composer<_$AppDatabase, $WarehouseMembersTable> {
  $$WarehouseMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$WarehouseMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $WarehouseMembersTable> {
  $$WarehouseMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$WarehouseMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $WarehouseMembersTable> {
  $$WarehouseMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$WarehouseMembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WarehouseMembersTable,
    WarehouseMemberRow,
    $$WarehouseMembersTableFilterComposer,
    $$WarehouseMembersTableOrderingComposer,
    $$WarehouseMembersTableAnnotationComposer,
    $$WarehouseMembersTableCreateCompanionBuilder,
    $$WarehouseMembersTableUpdateCompanionBuilder,
    (
      WarehouseMemberRow,
      BaseReferences<_$AppDatabase, $WarehouseMembersTable, WarehouseMemberRow>
    ),
    WarehouseMemberRow,
    PrefetchHooks Function()> {
  $$WarehouseMembersTableTableManager(
      _$AppDatabase db, $WarehouseMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WarehouseMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WarehouseMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WarehouseMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> warehouseId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WarehouseMembersCompanion(
            warehouseId: warehouseId,
            userId: userId,
            displayName: displayName,
            role: role,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String warehouseId,
            required String userId,
            required String displayName,
            required String role,
            required bool isActive,
            Value<int> rowid = const Value.absent(),
          }) =>
              WarehouseMembersCompanion.insert(
            warehouseId: warehouseId,
            userId: userId,
            displayName: displayName,
            role: role,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WarehouseMembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WarehouseMembersTable,
    WarehouseMemberRow,
    $$WarehouseMembersTableFilterComposer,
    $$WarehouseMembersTableOrderingComposer,
    $$WarehouseMembersTableAnnotationComposer,
    $$WarehouseMembersTableCreateCompanionBuilder,
    $$WarehouseMembersTableUpdateCompanionBuilder,
    (
      WarehouseMemberRow,
      BaseReferences<_$AppDatabase, $WarehouseMembersTable, WarehouseMemberRow>
    ),
    WarehouseMemberRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserSessionsTableTableManager get userSessions =>
      $$UserSessionsTableTableManager(_db, _db.userSessions);
  $$CountSessionsTableTableManager get countSessions =>
      $$CountSessionsTableTableManager(_db, _db.countSessions);
  $$CountItemsTableTableManager get countItems =>
      $$CountItemsTableTableManager(_db, _db.countItems);
  $$LocationEntriesTableTableManager get locationEntries =>
      $$LocationEntriesTableTableManager(_db, _db.locationEntries);
  $$DeliveryOrderEntriesTableTableManager get deliveryOrderEntries =>
      $$DeliveryOrderEntriesTableTableManager(_db, _db.deliveryOrderEntries);
  $$SalesOrderEntriesTableTableManager get salesOrderEntries =>
      $$SalesOrderEntriesTableTableManager(_db, _db.salesOrderEntries);
  $$OrderItemEntriesTableTableManager get orderItemEntries =>
      $$OrderItemEntriesTableTableManager(_db, _db.orderItemEntries);
  $$OrderStatusHistoryEntriesTableTableManager get orderStatusHistoryEntries =>
      $$OrderStatusHistoryEntriesTableTableManager(
          _db, _db.orderStatusHistoryEntries);
  $$PurchaseOrdersTableTableManager get purchaseOrders =>
      $$PurchaseOrdersTableTableManager(_db, _db.purchaseOrders);
  $$PoLineItemsTableTableManager get poLineItems =>
      $$PoLineItemsTableTableManager(_db, _db.poLineItems);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$CatalogItemsTableTableManager get catalogItems =>
      $$CatalogItemsTableTableManager(_db, _db.catalogItems);
  $$CatalogBarcodesTableTableManager get catalogBarcodes =>
      $$CatalogBarcodesTableTableManager(_db, _db.catalogBarcodes);
  $$WarehouseLocationsTableTableManager get warehouseLocations =>
      $$WarehouseLocationsTableTableManager(_db, _db.warehouseLocations);
  $$RemoteCountSessionsTableTableManager get remoteCountSessions =>
      $$RemoteCountSessionsTableTableManager(_db, _db.remoteCountSessions);
  $$RemoteCountLinesTableTableManager get remoteCountLines =>
      $$RemoteCountLinesTableTableManager(_db, _db.remoteCountLines);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$RemotePurchaseOrdersTableTableManager get remotePurchaseOrders =>
      $$RemotePurchaseOrdersTableTableManager(_db, _db.remotePurchaseOrders);
  $$RemotePoLinesTableTableManager get remotePoLines =>
      $$RemotePoLinesTableTableManager(_db, _db.remotePoLines);
  $$RemoteOrdersTableTableManager get remoteOrders =>
      $$RemoteOrdersTableTableManager(_db, _db.remoteOrders);
  $$RemoteOrderLinesTableTableManager get remoteOrderLines =>
      $$RemoteOrderLinesTableTableManager(_db, _db.remoteOrderLines);
  $$RemoteTasksTableTableManager get remoteTasks =>
      $$RemoteTasksTableTableManager(_db, _db.remoteTasks);
  $$RemoteAlertsTableTableManager get remoteAlerts =>
      $$RemoteAlertsTableTableManager(_db, _db.remoteAlerts);
  $$WarehouseMembersTableTableManager get warehouseMembers =>
      $$WarehouseMembersTableTableManager(_db, _db.warehouseMembers);
}
