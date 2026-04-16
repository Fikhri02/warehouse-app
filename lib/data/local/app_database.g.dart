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

class $AlertsTable extends Alerts with TableInfo<$AlertsTable, Alert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, title, body, createdAt, isRead];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alerts';
  @override
  VerificationContext validateIntegrity(Insertable<Alert> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Alert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Alert(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
    );
  }

  @override
  $AlertsTable createAlias(String alias) {
    return $AlertsTable(attachedDatabase, alias);
  }
}

class Alert extends DataClass implements Insertable<Alert> {
  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  const Alert(
      {required this.id,
      required this.type,
      required this.title,
      required this.body,
      required this.createdAt,
      required this.isRead});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_read'] = Variable<bool>(isRead);
    return map;
  }

  AlertsCompanion toCompanion(bool nullToAbsent) {
    return AlertsCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      body: Value(body),
      createdAt: Value(createdAt),
      isRead: Value(isRead),
    );
  }

  factory Alert.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Alert(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isRead': serializer.toJson<bool>(isRead),
    };
  }

  Alert copyWith(
          {String? id,
          String? type,
          String? title,
          String? body,
          DateTime? createdAt,
          bool? isRead}) =>
      Alert(
        id: id ?? this.id,
        type: type ?? this.type,
        title: title ?? this.title,
        body: body ?? this.body,
        createdAt: createdAt ?? this.createdAt,
        isRead: isRead ?? this.isRead,
      );
  Alert copyWithCompanion(AlertsCompanion data) {
    return Alert(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Alert(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, title, body, createdAt, isRead);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Alert &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.isRead == this.isRead);
}

class AlertsCompanion extends UpdateCompanion<Alert> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> title;
  final Value<String> body;
  final Value<DateTime> createdAt;
  final Value<bool> isRead;
  final Value<int> rowid;
  const AlertsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertsCompanion.insert({
    required String id,
    required String type,
    required String title,
    required String body,
    required DateTime createdAt,
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        title = Value(title),
        body = Value(body),
        createdAt = Value(createdAt);
  static Insertable<Alert> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
    Expression<bool>? isRead,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (isRead != null) 'is_read': isRead,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? title,
      Value<String>? body,
      Value<DateTime>? createdAt,
      Value<bool>? isRead,
      Value<int>? rowid}) {
    return AlertsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StaffTasksTable extends StaffTasks
    with TableInfo<$StaffTasksTable, StaffTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
      'due_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assignedToMeta =
      const VerificationMeta('assignedTo');
  @override
  late final GeneratedColumn<String> assignedTo = GeneratedColumn<String>(
      'assigned_to', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, location, dueAt, status, assignedTo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff_tasks';
  @override
  VerificationContext validateIntegrity(Insertable<StaffTask> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
          _dueAtMeta, dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta));
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('assigned_to')) {
      context.handle(
          _assignedToMeta,
          assignedTo.isAcceptableOrUnknown(
              data['assigned_to']!, _assignedToMeta));
    } else if (isInserting) {
      context.missing(_assignedToMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StaffTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffTask(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
      dueAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      assignedTo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assigned_to'])!,
    );
  }

  @override
  $StaffTasksTable createAlias(String alias) {
    return $StaffTasksTable(attachedDatabase, alias);
  }
}

class StaffTask extends DataClass implements Insertable<StaffTask> {
  final String id;
  final String type;
  final String location;
  final DateTime dueAt;
  final String status;
  final String assignedTo;
  const StaffTask(
      {required this.id,
      required this.type,
      required this.location,
      required this.dueAt,
      required this.status,
      required this.assignedTo});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['location'] = Variable<String>(location);
    map['due_at'] = Variable<DateTime>(dueAt);
    map['status'] = Variable<String>(status);
    map['assigned_to'] = Variable<String>(assignedTo);
    return map;
  }

  StaffTasksCompanion toCompanion(bool nullToAbsent) {
    return StaffTasksCompanion(
      id: Value(id),
      type: Value(type),
      location: Value(location),
      dueAt: Value(dueAt),
      status: Value(status),
      assignedTo: Value(assignedTo),
    );
  }

  factory StaffTask.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffTask(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      location: serializer.fromJson<String>(json['location']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      status: serializer.fromJson<String>(json['status']),
      assignedTo: serializer.fromJson<String>(json['assignedTo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'location': serializer.toJson<String>(location),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'status': serializer.toJson<String>(status),
      'assignedTo': serializer.toJson<String>(assignedTo),
    };
  }

  StaffTask copyWith(
          {String? id,
          String? type,
          String? location,
          DateTime? dueAt,
          String? status,
          String? assignedTo}) =>
      StaffTask(
        id: id ?? this.id,
        type: type ?? this.type,
        location: location ?? this.location,
        dueAt: dueAt ?? this.dueAt,
        status: status ?? this.status,
        assignedTo: assignedTo ?? this.assignedTo,
      );
  StaffTask copyWithCompanion(StaffTasksCompanion data) {
    return StaffTask(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      location: data.location.present ? data.location.value : this.location,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      status: data.status.present ? data.status.value : this.status,
      assignedTo:
          data.assignedTo.present ? data.assignedTo.value : this.assignedTo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffTask(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('location: $location, ')
          ..write('dueAt: $dueAt, ')
          ..write('status: $status, ')
          ..write('assignedTo: $assignedTo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, location, dueAt, status, assignedTo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffTask &&
          other.id == this.id &&
          other.type == this.type &&
          other.location == this.location &&
          other.dueAt == this.dueAt &&
          other.status == this.status &&
          other.assignedTo == this.assignedTo);
}

class StaffTasksCompanion extends UpdateCompanion<StaffTask> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> location;
  final Value<DateTime> dueAt;
  final Value<String> status;
  final Value<String> assignedTo;
  final Value<int> rowid;
  const StaffTasksCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.location = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.status = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StaffTasksCompanion.insert({
    required String id,
    required String type,
    required String location,
    required DateTime dueAt,
    required String status,
    required String assignedTo,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        location = Value(location),
        dueAt = Value(dueAt),
        status = Value(status),
        assignedTo = Value(assignedTo);
  static Insertable<StaffTask> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? location,
    Expression<DateTime>? dueAt,
    Expression<String>? status,
    Expression<String>? assignedTo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (location != null) 'location': location,
      if (dueAt != null) 'due_at': dueAt,
      if (status != null) 'status': status,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StaffTasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? location,
      Value<DateTime>? dueAt,
      Value<String>? status,
      Value<String>? assignedTo,
      Value<int>? rowid}) {
    return StaffTasksCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      location: location ?? this.location,
      dueAt: dueAt ?? this.dueAt,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (assignedTo.present) {
      map['assigned_to'] = Variable<String>(assignedTo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffTasksCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('location: $location, ')
          ..write('dueAt: $dueAt, ')
          ..write('status: $status, ')
          ..write('assignedTo: $assignedTo, ')
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, location, label, status, startedAt, submittedAt];
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
  const CountSession(
      {required this.id,
      required this.location,
      this.label,
      required this.status,
      required this.startedAt,
      this.submittedAt});
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
    };
  }

  CountSession copyWith(
          {String? id,
          String? location,
          Value<String?> label = const Value.absent(),
          String? status,
          DateTime? startedAt,
          Value<DateTime?> submittedAt = const Value.absent()}) =>
      CountSession(
        id: id ?? this.id,
        location: location ?? this.location,
        label: label.present ? label.value : this.label,
        status: status ?? this.status,
        startedAt: startedAt ?? this.startedAt,
        submittedAt: submittedAt.present ? submittedAt.value : this.submittedAt,
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
          ..write('submittedAt: $submittedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, location, label, status, startedAt, submittedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CountSession &&
          other.id == this.id &&
          other.location == this.location &&
          other.label == this.label &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.submittedAt == this.submittedAt);
}

class CountSessionsCompanion extends UpdateCompanion<CountSession> {
  final Value<String> id;
  final Value<String> location;
  final Value<String?> label;
  final Value<String> status;
  final Value<DateTime> startedAt;
  final Value<DateTime?> submittedAt;
  final Value<int> rowid;
  const CountSessionsCompanion({
    this.id = const Value.absent(),
    this.location = const Value.absent(),
    this.label = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountSessionsCompanion.insert({
    required String id,
    required String location,
    this.label = const Value.absent(),
    required String status,
    required DateTime startedAt,
    this.submittedAt = const Value.absent(),
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
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (location != null) 'location': location,
      if (label != null) 'label': label,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (submittedAt != null) 'submitted_at': submittedAt,
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
      Value<int>? rowid}) {
    return CountSessionsCompanion(
      id: id ?? this.id,
      location: location ?? this.location,
      label: label ?? this.label,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      submittedAt: submittedAt ?? this.submittedAt,
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
  final int expectedQty;
  final int actualQty;
  final String entryMethod;
  final bool skipped;
  const CountItem(
      {required this.id,
      required this.sessionId,
      required this.itemCode,
      required this.itemName,
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
          int? expectedQty,
          int? actualQty,
          String? entryMethod,
          bool? skipped}) =>
      CountItem(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        itemCode: itemCode ?? this.itemCode,
        itemName: itemName ?? this.itemName,
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
          ..write('expectedQty: $expectedQty, ')
          ..write('actualQty: $actualQty, ')
          ..write('entryMethod: $entryMethod, ')
          ..write('skipped: $skipped')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, itemCode, itemName,
      expectedQty, actualQty, entryMethod, skipped);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CountItem &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.itemCode == this.itemCode &&
          other.itemName == this.itemName &&
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
          ..write('expectedQty: $expectedQty, ')
          ..write('actualQty: $actualQty, ')
          ..write('entryMethod: $entryMethod, ')
          ..write('skipped: $skipped, ')
          ..write('rowid: $rowid')
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
      [id, poNumber, supplier, status, expectedDate, receivedAt];
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
  final DateTime expectedDate;
  final DateTime? receivedAt;
  const PurchaseOrder(
      {required this.id,
      required this.poNumber,
      required this.supplier,
      required this.status,
      required this.expectedDate,
      this.receivedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['po_number'] = Variable<String>(poNumber);
    map['supplier'] = Variable<String>(supplier);
    map['status'] = Variable<String>(status);
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
      'expectedDate': serializer.toJson<DateTime>(expectedDate),
      'receivedAt': serializer.toJson<DateTime?>(receivedAt),
    };
  }

  PurchaseOrder copyWith(
          {String? id,
          String? poNumber,
          String? supplier,
          String? status,
          DateTime? expectedDate,
          Value<DateTime?> receivedAt = const Value.absent()}) =>
      PurchaseOrder(
        id: id ?? this.id,
        poNumber: poNumber ?? this.poNumber,
        supplier: supplier ?? this.supplier,
        status: status ?? this.status,
        expectedDate: expectedDate ?? this.expectedDate,
        receivedAt: receivedAt.present ? receivedAt.value : this.receivedAt,
      );
  PurchaseOrder copyWithCompanion(PurchaseOrdersCompanion data) {
    return PurchaseOrder(
      id: data.id.present ? data.id.value : this.id,
      poNumber: data.poNumber.present ? data.poNumber.value : this.poNumber,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      status: data.status.present ? data.status.value : this.status,
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
          ..write('expectedDate: $expectedDate, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, poNumber, supplier, status, expectedDate, receivedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseOrder &&
          other.id == this.id &&
          other.poNumber == this.poNumber &&
          other.supplier == this.supplier &&
          other.status == this.status &&
          other.expectedDate == this.expectedDate &&
          other.receivedAt == this.receivedAt);
}

class PurchaseOrdersCompanion extends UpdateCompanion<PurchaseOrder> {
  final Value<String> id;
  final Value<String> poNumber;
  final Value<String> supplier;
  final Value<String> status;
  final Value<DateTime> expectedDate;
  final Value<DateTime?> receivedAt;
  final Value<int> rowid;
  const PurchaseOrdersCompanion({
    this.id = const Value.absent(),
    this.poNumber = const Value.absent(),
    this.supplier = const Value.absent(),
    this.status = const Value.absent(),
    this.expectedDate = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseOrdersCompanion.insert({
    required String id,
    required String poNumber,
    required String supplier,
    required String status,
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
    Expression<DateTime>? expectedDate,
    Expression<DateTime>? receivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (poNumber != null) 'po_number': poNumber,
      if (supplier != null) 'supplier': supplier,
      if (status != null) 'status': status,
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
      Value<DateTime>? expectedDate,
      Value<DateTime?>? receivedAt,
      Value<int>? rowid}) {
    return PurchaseOrdersCompanion(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      supplier: supplier ?? this.supplier,
      status: status ?? this.status,
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, poId, itemCode, itemName, expectedQty, receivedQty, flagged, status];
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
  final String status;
  const PoLineItem(
      {required this.id,
      required this.poId,
      required this.itemCode,
      required this.itemName,
      required this.expectedQty,
      required this.receivedQty,
      required this.flagged,
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
          String? status}) =>
      PoLineItem(
        id: id ?? this.id,
        poId: poId ?? this.poId,
        itemCode: itemCode ?? this.itemCode,
        itemName: itemName ?? this.itemName,
        expectedQty: expectedQty ?? this.expectedQty,
        receivedQty: receivedQty ?? this.receivedQty,
        flagged: flagged ?? this.flagged,
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
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, poId, itemCode, itemName, expectedQty, receivedQty, flagged, status);
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, operationType, referenceId, payload, queuedAt, synced, syncedAt];
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
  const SyncQueueData(
      {required this.id,
      required this.operationType,
      required this.referenceId,
      required this.payload,
      required this.queuedAt,
      required this.synced,
      this.syncedAt});
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
    };
  }

  SyncQueueData copyWith(
          {int? id,
          String? operationType,
          String? referenceId,
          String? payload,
          DateTime? queuedAt,
          bool? synced,
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      SyncQueueData(
        id: id ?? this.id,
        operationType: operationType ?? this.operationType,
        referenceId: referenceId ?? this.referenceId,
        payload: payload ?? this.payload,
        queuedAt: queuedAt ?? this.queuedAt,
        synced: synced ?? this.synced,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
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
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, operationType, referenceId, payload, queuedAt, synced, syncedAt);
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
          other.syncedAt == this.syncedAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> operationType;
  final Value<String> referenceId;
  final Value<String> payload;
  final Value<DateTime> queuedAt;
  final Value<bool> synced;
  final Value<DateTime?> syncedAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.operationType = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.payload = const Value.absent(),
    this.queuedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String operationType,
    required String referenceId,
    required String payload,
    this.queuedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
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
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationType != null) 'operation_type': operationType,
      if (referenceId != null) 'reference_id': referenceId,
      if (payload != null) 'payload': payload,
      if (queuedAt != null) 'queued_at': queuedAt,
      if (synced != null) 'synced': synced,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? operationType,
      Value<String>? referenceId,
      Value<String>? payload,
      Value<DateTime>? queuedAt,
      Value<bool>? synced,
      Value<DateTime?>? syncedAt}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      referenceId: referenceId ?? this.referenceId,
      payload: payload ?? this.payload,
      queuedAt: queuedAt ?? this.queuedAt,
      synced: synced ?? this.synced,
      syncedAt: syncedAt ?? this.syncedAt,
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
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserSessionsTable userSessions = $UserSessionsTable(this);
  late final $AlertsTable alerts = $AlertsTable(this);
  late final $StaffTasksTable staffTasks = $StaffTasksTable(this);
  late final $CountSessionsTable countSessions = $CountSessionsTable(this);
  late final $CountItemsTable countItems = $CountItemsTable(this);
  late final $PurchaseOrdersTable purchaseOrders = $PurchaseOrdersTable(this);
  late final $PoLineItemsTable poLineItems = $PoLineItemsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final AlertsDao alertsDao = AlertsDao(this as AppDatabase);
  late final TasksDao tasksDao = TasksDao(this as AppDatabase);
  late final CountSessionDao countSessionDao =
      CountSessionDao(this as AppDatabase);
  late final ReceivingDao receivingDao = ReceivingDao(this as AppDatabase);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        userSessions,
        alerts,
        staffTasks,
        countSessions,
        countItems,
        purchaseOrders,
        poLineItems,
        syncQueue
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
typedef $$AlertsTableCreateCompanionBuilder = AlertsCompanion Function({
  required String id,
  required String type,
  required String title,
  required String body,
  required DateTime createdAt,
  Value<bool> isRead,
  Value<int> rowid,
});
typedef $$AlertsTableUpdateCompanionBuilder = AlertsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> title,
  Value<String> body,
  Value<DateTime> createdAt,
  Value<bool> isRead,
  Value<int> rowid,
});

class $$AlertsTableFilterComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));
}

class $$AlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));
}

class $$AlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);
}

class $$AlertsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AlertsTable,
    Alert,
    $$AlertsTableFilterComposer,
    $$AlertsTableOrderingComposer,
    $$AlertsTableAnnotationComposer,
    $$AlertsTableCreateCompanionBuilder,
    $$AlertsTableUpdateCompanionBuilder,
    (Alert, BaseReferences<_$AppDatabase, $AlertsTable, Alert>),
    Alert,
    PrefetchHooks Function()> {
  $$AlertsTableTableManager(_$AppDatabase db, $AlertsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlertsCompanion(
            id: id,
            type: type,
            title: title,
            body: body,
            createdAt: createdAt,
            isRead: isRead,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required String title,
            required String body,
            required DateTime createdAt,
            Value<bool> isRead = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlertsCompanion.insert(
            id: id,
            type: type,
            title: title,
            body: body,
            createdAt: createdAt,
            isRead: isRead,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AlertsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AlertsTable,
    Alert,
    $$AlertsTableFilterComposer,
    $$AlertsTableOrderingComposer,
    $$AlertsTableAnnotationComposer,
    $$AlertsTableCreateCompanionBuilder,
    $$AlertsTableUpdateCompanionBuilder,
    (Alert, BaseReferences<_$AppDatabase, $AlertsTable, Alert>),
    Alert,
    PrefetchHooks Function()>;
typedef $$StaffTasksTableCreateCompanionBuilder = StaffTasksCompanion Function({
  required String id,
  required String type,
  required String location,
  required DateTime dueAt,
  required String status,
  required String assignedTo,
  Value<int> rowid,
});
typedef $$StaffTasksTableUpdateCompanionBuilder = StaffTasksCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> location,
  Value<DateTime> dueAt,
  Value<String> status,
  Value<String> assignedTo,
  Value<int> rowid,
});

class $$StaffTasksTableFilterComposer
    extends Composer<_$AppDatabase, $StaffTasksTable> {
  $$StaffTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assignedTo => $composableBuilder(
      column: $table.assignedTo, builder: (column) => ColumnFilters(column));
}

class $$StaffTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffTasksTable> {
  $$StaffTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assignedTo => $composableBuilder(
      column: $table.assignedTo, builder: (column) => ColumnOrderings(column));
}

class $$StaffTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffTasksTable> {
  $$StaffTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get assignedTo => $composableBuilder(
      column: $table.assignedTo, builder: (column) => column);
}

class $$StaffTasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StaffTasksTable,
    StaffTask,
    $$StaffTasksTableFilterComposer,
    $$StaffTasksTableOrderingComposer,
    $$StaffTasksTableAnnotationComposer,
    $$StaffTasksTableCreateCompanionBuilder,
    $$StaffTasksTableUpdateCompanionBuilder,
    (StaffTask, BaseReferences<_$AppDatabase, $StaffTasksTable, StaffTask>),
    StaffTask,
    PrefetchHooks Function()> {
  $$StaffTasksTableTableManager(_$AppDatabase db, $StaffTasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<DateTime> dueAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> assignedTo = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StaffTasksCompanion(
            id: id,
            type: type,
            location: location,
            dueAt: dueAt,
            status: status,
            assignedTo: assignedTo,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required String location,
            required DateTime dueAt,
            required String status,
            required String assignedTo,
            Value<int> rowid = const Value.absent(),
          }) =>
              StaffTasksCompanion.insert(
            id: id,
            type: type,
            location: location,
            dueAt: dueAt,
            status: status,
            assignedTo: assignedTo,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StaffTasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StaffTasksTable,
    StaffTask,
    $$StaffTasksTableFilterComposer,
    $$StaffTasksTableOrderingComposer,
    $$StaffTasksTableAnnotationComposer,
    $$StaffTasksTableCreateCompanionBuilder,
    $$StaffTasksTableUpdateCompanionBuilder,
    (StaffTask, BaseReferences<_$AppDatabase, $StaffTasksTable, StaffTask>),
    StaffTask,
    PrefetchHooks Function()>;
typedef $$CountSessionsTableCreateCompanionBuilder = CountSessionsCompanion
    Function({
  required String id,
  required String location,
  Value<String?> label,
  required String status,
  required DateTime startedAt,
  Value<DateTime?> submittedAt,
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
            Value<int> rowid = const Value.absent(),
          }) =>
              CountSessionsCompanion(
            id: id,
            location: location,
            label: label,
            status: status,
            startedAt: startedAt,
            submittedAt: submittedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String location,
            Value<String?> label = const Value.absent(),
            required String status,
            required DateTime startedAt,
            Value<DateTime?> submittedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CountSessionsCompanion.insert(
            id: id,
            location: location,
            label: label,
            status: status,
            startedAt: startedAt,
            submittedAt: submittedAt,
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
typedef $$PurchaseOrdersTableCreateCompanionBuilder = PurchaseOrdersCompanion
    Function({
  required String id,
  required String poNumber,
  required String supplier,
  required String status,
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
            Value<DateTime> expectedDate = const Value.absent(),
            Value<DateTime?> receivedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchaseOrdersCompanion(
            id: id,
            poNumber: poNumber,
            supplier: supplier,
            status: status,
            expectedDate: expectedDate,
            receivedAt: receivedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String poNumber,
            required String supplier,
            required String status,
            required DateTime expectedDate,
            Value<DateTime?> receivedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchaseOrdersCompanion.insert(
            id: id,
            poNumber: poNumber,
            supplier: supplier,
            status: status,
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
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> operationType,
  Value<String> referenceId,
  Value<String> payload,
  Value<DateTime> queuedAt,
  Value<bool> synced,
  Value<DateTime?> syncedAt,
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
          }) =>
              SyncQueueCompanion(
            id: id,
            operationType: operationType,
            referenceId: referenceId,
            payload: payload,
            queuedAt: queuedAt,
            synced: synced,
            syncedAt: syncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String operationType,
            required String referenceId,
            required String payload,
            Value<DateTime> queuedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            operationType: operationType,
            referenceId: referenceId,
            payload: payload,
            queuedAt: queuedAt,
            synced: synced,
            syncedAt: syncedAt,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserSessionsTableTableManager get userSessions =>
      $$UserSessionsTableTableManager(_db, _db.userSessions);
  $$AlertsTableTableManager get alerts =>
      $$AlertsTableTableManager(_db, _db.alerts);
  $$StaffTasksTableTableManager get staffTasks =>
      $$StaffTasksTableTableManager(_db, _db.staffTasks);
  $$CountSessionsTableTableManager get countSessions =>
      $$CountSessionsTableTableManager(_db, _db.countSessions);
  $$CountItemsTableTableManager get countItems =>
      $$CountItemsTableTableManager(_db, _db.countItems);
  $$PurchaseOrdersTableTableManager get purchaseOrders =>
      $$PurchaseOrdersTableTableManager(_db, _db.purchaseOrders);
  $$PoLineItemsTableTableManager get poLineItems =>
      $$PoLineItemsTableTableManager(_db, _db.poLineItems);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
