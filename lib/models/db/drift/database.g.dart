// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UserTable extends User with TableInfo<$UserTable, UserData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idUserMeta = const VerificationMeta('idUser');
  @override
  late final GeneratedColumn<String> idUser = GeneratedColumn<String>(
      'id_user', aliasedName, false,
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
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<int> phone = GeneratedColumn<int>(
      'phone', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isSuperuserMeta =
      const VerificationMeta('isSuperuser');
  @override
  late final GeneratedColumn<bool> isSuperuser = GeneratedColumn<bool>(
      'is_superuser', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_superuser" IN (0, 1))'));
  static const VerificationMeta _isProducerMeta =
      const VerificationMeta('isProducer');
  @override
  late final GeneratedColumn<bool> isProducer = GeneratedColumn<bool>(
      'is_producer', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_producer" IN (0, 1))'));
  static const VerificationMeta _isOverViewerMeta =
      const VerificationMeta('isOverViewer');
  @override
  late final GeneratedColumn<bool> isOverViewer = GeneratedColumn<bool>(
      'is_over_viewer', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_over_viewer" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns =>
      [idUser, name, email, phone, isSuperuser, isProducer, isOverViewer];
  @override
  String get aliasedName => _alias ?? 'user';
  @override
  String get actualTableName => 'user';
  @override
  VerificationContext validateIntegrity(Insertable<UserData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id_user')) {
      context.handle(_idUserMeta,
          idUser.isAcceptableOrUnknown(data['id_user']!, _idUserMeta));
    } else if (isInserting) {
      context.missing(_idUserMeta);
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
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('is_superuser')) {
      context.handle(
          _isSuperuserMeta,
          isSuperuser.isAcceptableOrUnknown(
              data['is_superuser']!, _isSuperuserMeta));
    } else if (isInserting) {
      context.missing(_isSuperuserMeta);
    }
    if (data.containsKey('is_producer')) {
      context.handle(
          _isProducerMeta,
          isProducer.isAcceptableOrUnknown(
              data['is_producer']!, _isProducerMeta));
    } else if (isInserting) {
      context.missing(_isProducerMeta);
    }
    if (data.containsKey('is_over_viewer')) {
      context.handle(
          _isOverViewerMeta,
          isOverViewer.isAcceptableOrUnknown(
              data['is_over_viewer']!, _isOverViewerMeta));
    } else if (isInserting) {
      context.missing(_isOverViewerMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idUser};
  @override
  UserData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserData(
      idUser: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_user'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}phone'])!,
      isSuperuser: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_superuser'])!,
      isProducer: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_producer'])!,
      isOverViewer: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_over_viewer'])!,
    );
  }

  @override
  $UserTable createAlias(String alias) {
    return $UserTable(attachedDatabase, alias);
  }
}

class UserData extends DataClass implements Insertable<UserData> {
  final String idUser;
  final String name;
  final String email;
  final int phone;
  final bool isSuperuser;
  final bool isProducer;
  final bool isOverViewer;
  const UserData(
      {required this.idUser,
      required this.name,
      required this.email,
      required this.phone,
      required this.isSuperuser,
      required this.isProducer,
      required this.isOverViewer});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_user'] = Variable<String>(idUser);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['phone'] = Variable<int>(phone);
    map['is_superuser'] = Variable<bool>(isSuperuser);
    map['is_producer'] = Variable<bool>(isProducer);
    map['is_over_viewer'] = Variable<bool>(isOverViewer);
    return map;
  }

  UserCompanion toCompanion(bool nullToAbsent) {
    return UserCompanion(
      idUser: Value(idUser),
      name: Value(name),
      email: Value(email),
      phone: Value(phone),
      isSuperuser: Value(isSuperuser),
      isProducer: Value(isProducer),
      isOverViewer: Value(isOverViewer),
    );
  }

  factory UserData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserData(
      idUser: serializer.fromJson<String>(json['idUser']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      phone: serializer.fromJson<int>(json['phone']),
      isSuperuser: serializer.fromJson<bool>(json['isSuperuser']),
      isProducer: serializer.fromJson<bool>(json['isProducer']),
      isOverViewer: serializer.fromJson<bool>(json['isOverViewer']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idUser': serializer.toJson<String>(idUser),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'phone': serializer.toJson<int>(phone),
      'isSuperuser': serializer.toJson<bool>(isSuperuser),
      'isProducer': serializer.toJson<bool>(isProducer),
      'isOverViewer': serializer.toJson<bool>(isOverViewer),
    };
  }

  UserData copyWith(
          {String? idUser,
          String? name,
          String? email,
          int? phone,
          bool? isSuperuser,
          bool? isProducer,
          bool? isOverViewer}) =>
      UserData(
        idUser: idUser ?? this.idUser,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        isSuperuser: isSuperuser ?? this.isSuperuser,
        isProducer: isProducer ?? this.isProducer,
        isOverViewer: isOverViewer ?? this.isOverViewer,
      );
  @override
  String toString() {
    return (StringBuffer('UserData(')
          ..write('idUser: $idUser, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('isSuperuser: $isSuperuser, ')
          ..write('isProducer: $isProducer, ')
          ..write('isOverViewer: $isOverViewer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      idUser, name, email, phone, isSuperuser, isProducer, isOverViewer);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserData &&
          other.idUser == this.idUser &&
          other.name == this.name &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.isSuperuser == this.isSuperuser &&
          other.isProducer == this.isProducer &&
          other.isOverViewer == this.isOverViewer);
}

class UserCompanion extends UpdateCompanion<UserData> {
  final Value<String> idUser;
  final Value<String> name;
  final Value<String> email;
  final Value<int> phone;
  final Value<bool> isSuperuser;
  final Value<bool> isProducer;
  final Value<bool> isOverViewer;
  final Value<int> rowid;
  const UserCompanion({
    this.idUser = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.isSuperuser = const Value.absent(),
    this.isProducer = const Value.absent(),
    this.isOverViewer = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserCompanion.insert({
    required String idUser,
    required String name,
    required String email,
    required int phone,
    required bool isSuperuser,
    required bool isProducer,
    required bool isOverViewer,
    this.rowid = const Value.absent(),
  })  : idUser = Value(idUser),
        name = Value(name),
        email = Value(email),
        phone = Value(phone),
        isSuperuser = Value(isSuperuser),
        isProducer = Value(isProducer),
        isOverViewer = Value(isOverViewer);
  static Insertable<UserData> custom({
    Expression<String>? idUser,
    Expression<String>? name,
    Expression<String>? email,
    Expression<int>? phone,
    Expression<bool>? isSuperuser,
    Expression<bool>? isProducer,
    Expression<bool>? isOverViewer,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idUser != null) 'id_user': idUser,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (isSuperuser != null) 'is_superuser': isSuperuser,
      if (isProducer != null) 'is_producer': isProducer,
      if (isOverViewer != null) 'is_over_viewer': isOverViewer,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserCompanion copyWith(
      {Value<String>? idUser,
      Value<String>? name,
      Value<String>? email,
      Value<int>? phone,
      Value<bool>? isSuperuser,
      Value<bool>? isProducer,
      Value<bool>? isOverViewer,
      Value<int>? rowid}) {
    return UserCompanion(
      idUser: idUser ?? this.idUser,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      isProducer: isProducer ?? this.isProducer,
      isOverViewer: isOverViewer ?? this.isOverViewer,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idUser.present) {
      map['id_user'] = Variable<String>(idUser.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<int>(phone.value);
    }
    if (isSuperuser.present) {
      map['is_superuser'] = Variable<bool>(isSuperuser.value);
    }
    if (isProducer.present) {
      map['is_producer'] = Variable<bool>(isProducer.value);
    }
    if (isOverViewer.present) {
      map['is_over_viewer'] = Variable<bool>(isOverViewer.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCompanion(')
          ..write('idUser: $idUser, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('isSuperuser: $isSuperuser, ')
          ..write('isProducer: $isProducer, ')
          ..write('isOverViewer: $isOverViewer, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FenceTable extends Fence with TableInfo<$FenceTable, FenceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FenceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idFenceMeta =
      const VerificationMeta('idFence');
  @override
  late final GeneratedColumn<String> idFence = GeneratedColumn<String>(
      'id_fence', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idUserMeta = const VerificationMeta('idUser');
  @override
  late final GeneratedColumn<String> idUser = GeneratedColumn<String>(
      'id_user', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES user (id_user)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isStayInsideMeta =
      const VerificationMeta('isStayInside');
  @override
  late final GeneratedColumn<bool> isStayInside = GeneratedColumn<bool>(
      'is_stay_inside', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_stay_inside" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns =>
      [idFence, idUser, name, color, isStayInside];
  @override
  String get aliasedName => _alias ?? 'fence';
  @override
  String get actualTableName => 'fence';
  @override
  VerificationContext validateIntegrity(Insertable<FenceData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id_fence')) {
      context.handle(_idFenceMeta,
          idFence.isAcceptableOrUnknown(data['id_fence']!, _idFenceMeta));
    } else if (isInserting) {
      context.missing(_idFenceMeta);
    }
    if (data.containsKey('id_user')) {
      context.handle(_idUserMeta,
          idUser.isAcceptableOrUnknown(data['id_user']!, _idUserMeta));
    } else if (isInserting) {
      context.missing(_idUserMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('is_stay_inside')) {
      context.handle(
          _isStayInsideMeta,
          isStayInside.isAcceptableOrUnknown(
              data['is_stay_inside']!, _isStayInsideMeta));
    } else if (isInserting) {
      context.missing(_isStayInsideMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idFence};
  @override
  FenceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FenceData(
      idFence: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_fence'])!,
      idUser: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_user'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      isStayInside: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_stay_inside'])!,
    );
  }

  @override
  $FenceTable createAlias(String alias) {
    return $FenceTable(attachedDatabase, alias);
  }
}

class FenceData extends DataClass implements Insertable<FenceData> {
  final String idFence;
  final String idUser;
  final String name;
  final String color;
  final bool isStayInside;
  const FenceData(
      {required this.idFence,
      required this.idUser,
      required this.name,
      required this.color,
      required this.isStayInside});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_fence'] = Variable<String>(idFence);
    map['id_user'] = Variable<String>(idUser);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['is_stay_inside'] = Variable<bool>(isStayInside);
    return map;
  }

  FenceCompanion toCompanion(bool nullToAbsent) {
    return FenceCompanion(
      idFence: Value(idFence),
      idUser: Value(idUser),
      name: Value(name),
      color: Value(color),
      isStayInside: Value(isStayInside),
    );
  }

  factory FenceData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FenceData(
      idFence: serializer.fromJson<String>(json['idFence']),
      idUser: serializer.fromJson<String>(json['idUser']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      isStayInside: serializer.fromJson<bool>(json['isStayInside']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idFence': serializer.toJson<String>(idFence),
      'idUser': serializer.toJson<String>(idUser),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'isStayInside': serializer.toJson<bool>(isStayInside),
    };
  }

  FenceData copyWith(
          {String? idFence,
          String? idUser,
          String? name,
          String? color,
          bool? isStayInside}) =>
      FenceData(
        idFence: idFence ?? this.idFence,
        idUser: idUser ?? this.idUser,
        name: name ?? this.name,
        color: color ?? this.color,
        isStayInside: isStayInside ?? this.isStayInside,
      );
  @override
  String toString() {
    return (StringBuffer('FenceData(')
          ..write('idFence: $idFence, ')
          ..write('idUser: $idUser, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('isStayInside: $isStayInside')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(idFence, idUser, name, color, isStayInside);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FenceData &&
          other.idFence == this.idFence &&
          other.idUser == this.idUser &&
          other.name == this.name &&
          other.color == this.color &&
          other.isStayInside == this.isStayInside);
}

class FenceCompanion extends UpdateCompanion<FenceData> {
  final Value<String> idFence;
  final Value<String> idUser;
  final Value<String> name;
  final Value<String> color;
  final Value<bool> isStayInside;
  final Value<int> rowid;
  const FenceCompanion({
    this.idFence = const Value.absent(),
    this.idUser = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.isStayInside = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FenceCompanion.insert({
    required String idFence,
    required String idUser,
    required String name,
    required String color,
    required bool isStayInside,
    this.rowid = const Value.absent(),
  })  : idFence = Value(idFence),
        idUser = Value(idUser),
        name = Value(name),
        color = Value(color),
        isStayInside = Value(isStayInside);
  static Insertable<FenceData> custom({
    Expression<String>? idFence,
    Expression<String>? idUser,
    Expression<String>? name,
    Expression<String>? color,
    Expression<bool>? isStayInside,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idFence != null) 'id_fence': idFence,
      if (idUser != null) 'id_user': idUser,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (isStayInside != null) 'is_stay_inside': isStayInside,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FenceCompanion copyWith(
      {Value<String>? idFence,
      Value<String>? idUser,
      Value<String>? name,
      Value<String>? color,
      Value<bool>? isStayInside,
      Value<int>? rowid}) {
    return FenceCompanion(
      idFence: idFence ?? this.idFence,
      idUser: idUser ?? this.idUser,
      name: name ?? this.name,
      color: color ?? this.color,
      isStayInside: isStayInside ?? this.isStayInside,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idFence.present) {
      map['id_fence'] = Variable<String>(idFence.value);
    }
    if (idUser.present) {
      map['id_user'] = Variable<String>(idUser.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (isStayInside.present) {
      map['is_stay_inside'] = Variable<bool>(isStayInside.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FenceCompanion(')
          ..write('idFence: $idFence, ')
          ..write('idUser: $idUser, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('isStayInside: $isStayInside, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FencePointsTable extends FencePoints
    with TableInfo<$FencePointsTable, FencePoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FencePointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idFencePointMeta =
      const VerificationMeta('idFencePoint');
  @override
  late final GeneratedColumn<String> idFencePoint = GeneratedColumn<String>(
      'id_fence_point', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idFenceMeta =
      const VerificationMeta('idFence');
  @override
  late final GeneratedColumn<String> idFence = GeneratedColumn<String>(
      'id_fence', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES fence (id_fence)'));
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
      'lon', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isCenterMeta =
      const VerificationMeta('isCenter');
  @override
  late final GeneratedColumn<bool> isCenter = GeneratedColumn<bool>(
      'is_center', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_center" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns =>
      [idFencePoint, idFence, lat, lon, isCenter];
  @override
  String get aliasedName => _alias ?? 'fence_points';
  @override
  String get actualTableName => 'fence_points';
  @override
  VerificationContext validateIntegrity(Insertable<FencePoint> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id_fence_point')) {
      context.handle(
          _idFencePointMeta,
          idFencePoint.isAcceptableOrUnknown(
              data['id_fence_point']!, _idFencePointMeta));
    } else if (isInserting) {
      context.missing(_idFencePointMeta);
    }
    if (data.containsKey('id_fence')) {
      context.handle(_idFenceMeta,
          idFence.isAcceptableOrUnknown(data['id_fence']!, _idFenceMeta));
    } else if (isInserting) {
      context.missing(_idFenceMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
          _lonMeta, lon.isAcceptableOrUnknown(data['lon']!, _lonMeta));
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('is_center')) {
      context.handle(_isCenterMeta,
          isCenter.isAcceptableOrUnknown(data['is_center']!, _isCenterMeta));
    } else if (isInserting) {
      context.missing(_isCenterMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idFencePoint};
  @override
  FencePoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FencePoint(
      idFencePoint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_fence_point'])!,
      idFence: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_fence'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lon: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lon'])!,
      isCenter: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_center'])!,
    );
  }

  @override
  $FencePointsTable createAlias(String alias) {
    return $FencePointsTable(attachedDatabase, alias);
  }
}

class FencePoint extends DataClass implements Insertable<FencePoint> {
  final String idFencePoint;
  final String idFence;
  final double lat;
  final double lon;
  final bool isCenter;
  const FencePoint(
      {required this.idFencePoint,
      required this.idFence,
      required this.lat,
      required this.lon,
      required this.isCenter});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_fence_point'] = Variable<String>(idFencePoint);
    map['id_fence'] = Variable<String>(idFence);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    map['is_center'] = Variable<bool>(isCenter);
    return map;
  }

  FencePointsCompanion toCompanion(bool nullToAbsent) {
    return FencePointsCompanion(
      idFencePoint: Value(idFencePoint),
      idFence: Value(idFence),
      lat: Value(lat),
      lon: Value(lon),
      isCenter: Value(isCenter),
    );
  }

  factory FencePoint.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FencePoint(
      idFencePoint: serializer.fromJson<String>(json['idFencePoint']),
      idFence: serializer.fromJson<String>(json['idFence']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      isCenter: serializer.fromJson<bool>(json['isCenter']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idFencePoint': serializer.toJson<String>(idFencePoint),
      'idFence': serializer.toJson<String>(idFence),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'isCenter': serializer.toJson<bool>(isCenter),
    };
  }

  FencePoint copyWith(
          {String? idFencePoint,
          String? idFence,
          double? lat,
          double? lon,
          bool? isCenter}) =>
      FencePoint(
        idFencePoint: idFencePoint ?? this.idFencePoint,
        idFence: idFence ?? this.idFence,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
        isCenter: isCenter ?? this.isCenter,
      );
  @override
  String toString() {
    return (StringBuffer('FencePoint(')
          ..write('idFencePoint: $idFencePoint, ')
          ..write('idFence: $idFence, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('isCenter: $isCenter')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(idFencePoint, idFence, lat, lon, isCenter);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FencePoint &&
          other.idFencePoint == this.idFencePoint &&
          other.idFence == this.idFence &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.isCenter == this.isCenter);
}

class FencePointsCompanion extends UpdateCompanion<FencePoint> {
  final Value<String> idFencePoint;
  final Value<String> idFence;
  final Value<double> lat;
  final Value<double> lon;
  final Value<bool> isCenter;
  final Value<int> rowid;
  const FencePointsCompanion({
    this.idFencePoint = const Value.absent(),
    this.idFence = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.isCenter = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FencePointsCompanion.insert({
    required String idFencePoint,
    required String idFence,
    required double lat,
    required double lon,
    required bool isCenter,
    this.rowid = const Value.absent(),
  })  : idFencePoint = Value(idFencePoint),
        idFence = Value(idFence),
        lat = Value(lat),
        lon = Value(lon),
        isCenter = Value(isCenter);
  static Insertable<FencePoint> custom({
    Expression<String>? idFencePoint,
    Expression<String>? idFence,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<bool>? isCenter,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idFencePoint != null) 'id_fence_point': idFencePoint,
      if (idFence != null) 'id_fence': idFence,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (isCenter != null) 'is_center': isCenter,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FencePointsCompanion copyWith(
      {Value<String>? idFencePoint,
      Value<String>? idFence,
      Value<double>? lat,
      Value<double>? lon,
      Value<bool>? isCenter,
      Value<int>? rowid}) {
    return FencePointsCompanion(
      idFencePoint: idFencePoint ?? this.idFencePoint,
      idFence: idFence ?? this.idFence,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      isCenter: isCenter ?? this.isCenter,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idFencePoint.present) {
      map['id_fence_point'] = Variable<String>(idFencePoint.value);
    }
    if (idFence.present) {
      map['id_fence'] = Variable<String>(idFence.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (isCenter.present) {
      map['is_center'] = Variable<bool>(isCenter.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FencePointsCompanion(')
          ..write('idFencePoint: $idFencePoint, ')
          ..write('idFence: $idFence, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('isCenter: $isCenter, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimalTable extends Animal with TableInfo<$AnimalTable, AnimalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idAnimalMeta =
      const VerificationMeta('idAnimal');
  @override
  late final GeneratedColumn<String> idAnimal = GeneratedColumn<String>(
      'id_animal', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idUserMeta = const VerificationMeta('idUser');
  @override
  late final GeneratedColumn<String> idUser = GeneratedColumn<String>(
      'id_user', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES user (id_user)'));
  static const VerificationMeta _animalIdentificationMeta =
      const VerificationMeta('animalIdentification');
  @override
  late final GeneratedColumn<String> animalIdentification =
      GeneratedColumn<String>('animal_identification', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _animalNameMeta =
      const VerificationMeta('animalName');
  @override
  late final GeneratedColumn<String> animalName = GeneratedColumn<String>(
      'animal_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _animalColorMeta =
      const VerificationMeta('animalColor');
  @override
  late final GeneratedColumn<String> animalColor = GeneratedColumn<String>(
      'animal_color', aliasedName, false,
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
  List<GeneratedColumn> get $columns => [
        idAnimal,
        idUser,
        animalIdentification,
        animalName,
        animalColor,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? 'animal';
  @override
  String get actualTableName => 'animal';
  @override
  VerificationContext validateIntegrity(Insertable<AnimalData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id_animal')) {
      context.handle(_idAnimalMeta,
          idAnimal.isAcceptableOrUnknown(data['id_animal']!, _idAnimalMeta));
    } else if (isInserting) {
      context.missing(_idAnimalMeta);
    }
    if (data.containsKey('id_user')) {
      context.handle(_idUserMeta,
          idUser.isAcceptableOrUnknown(data['id_user']!, _idUserMeta));
    } else if (isInserting) {
      context.missing(_idUserMeta);
    }
    if (data.containsKey('animal_identification')) {
      context.handle(
          _animalIdentificationMeta,
          animalIdentification.isAcceptableOrUnknown(
              data['animal_identification']!, _animalIdentificationMeta));
    } else if (isInserting) {
      context.missing(_animalIdentificationMeta);
    }
    if (data.containsKey('animal_name')) {
      context.handle(
          _animalNameMeta,
          animalName.isAcceptableOrUnknown(
              data['animal_name']!, _animalNameMeta));
    } else if (isInserting) {
      context.missing(_animalNameMeta);
    }
    if (data.containsKey('animal_color')) {
      context.handle(
          _animalColorMeta,
          animalColor.isAcceptableOrUnknown(
              data['animal_color']!, _animalColorMeta));
    } else if (isInserting) {
      context.missing(_animalColorMeta);
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
  Set<GeneratedColumn> get $primaryKey => {idAnimal};
  @override
  AnimalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalData(
      idAnimal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_animal'])!,
      idUser: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_user'])!,
      animalIdentification: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}animal_identification'])!,
      animalName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_name'])!,
      animalColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_color'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $AnimalTable createAlias(String alias) {
    return $AnimalTable(attachedDatabase, alias);
  }
}

class AnimalData extends DataClass implements Insertable<AnimalData> {
  final String idAnimal;
  final String idUser;
  final String animalIdentification;
  final String animalName;
  final String animalColor;
  final bool isActive;
  const AnimalData(
      {required this.idAnimal,
      required this.idUser,
      required this.animalIdentification,
      required this.animalName,
      required this.animalColor,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_animal'] = Variable<String>(idAnimal);
    map['id_user'] = Variable<String>(idUser);
    map['animal_identification'] = Variable<String>(animalIdentification);
    map['animal_name'] = Variable<String>(animalName);
    map['animal_color'] = Variable<String>(animalColor);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  AnimalCompanion toCompanion(bool nullToAbsent) {
    return AnimalCompanion(
      idAnimal: Value(idAnimal),
      idUser: Value(idUser),
      animalIdentification: Value(animalIdentification),
      animalName: Value(animalName),
      animalColor: Value(animalColor),
      isActive: Value(isActive),
    );
  }

  factory AnimalData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalData(
      idAnimal: serializer.fromJson<String>(json['idAnimal']),
      idUser: serializer.fromJson<String>(json['idUser']),
      animalIdentification:
          serializer.fromJson<String>(json['animalIdentification']),
      animalName: serializer.fromJson<String>(json['animalName']),
      animalColor: serializer.fromJson<String>(json['animalColor']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idAnimal': serializer.toJson<String>(idAnimal),
      'idUser': serializer.toJson<String>(idUser),
      'animalIdentification': serializer.toJson<String>(animalIdentification),
      'animalName': serializer.toJson<String>(animalName),
      'animalColor': serializer.toJson<String>(animalColor),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  AnimalData copyWith(
          {String? idAnimal,
          String? idUser,
          String? animalIdentification,
          String? animalName,
          String? animalColor,
          bool? isActive}) =>
      AnimalData(
        idAnimal: idAnimal ?? this.idAnimal,
        idUser: idUser ?? this.idUser,
        animalIdentification: animalIdentification ?? this.animalIdentification,
        animalName: animalName ?? this.animalName,
        animalColor: animalColor ?? this.animalColor,
        isActive: isActive ?? this.isActive,
      );
  @override
  String toString() {
    return (StringBuffer('AnimalData(')
          ..write('idAnimal: $idAnimal, ')
          ..write('idUser: $idUser, ')
          ..write('animalIdentification: $animalIdentification, ')
          ..write('animalName: $animalName, ')
          ..write('animalColor: $animalColor, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(idAnimal, idUser, animalIdentification,
      animalName, animalColor, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalData &&
          other.idAnimal == this.idAnimal &&
          other.idUser == this.idUser &&
          other.animalIdentification == this.animalIdentification &&
          other.animalName == this.animalName &&
          other.animalColor == this.animalColor &&
          other.isActive == this.isActive);
}

class AnimalCompanion extends UpdateCompanion<AnimalData> {
  final Value<String> idAnimal;
  final Value<String> idUser;
  final Value<String> animalIdentification;
  final Value<String> animalName;
  final Value<String> animalColor;
  final Value<bool> isActive;
  final Value<int> rowid;
  const AnimalCompanion({
    this.idAnimal = const Value.absent(),
    this.idUser = const Value.absent(),
    this.animalIdentification = const Value.absent(),
    this.animalName = const Value.absent(),
    this.animalColor = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalCompanion.insert({
    required String idAnimal,
    required String idUser,
    required String animalIdentification,
    required String animalName,
    required String animalColor,
    required bool isActive,
    this.rowid = const Value.absent(),
  })  : idAnimal = Value(idAnimal),
        idUser = Value(idUser),
        animalIdentification = Value(animalIdentification),
        animalName = Value(animalName),
        animalColor = Value(animalColor),
        isActive = Value(isActive);
  static Insertable<AnimalData> custom({
    Expression<String>? idAnimal,
    Expression<String>? idUser,
    Expression<String>? animalIdentification,
    Expression<String>? animalName,
    Expression<String>? animalColor,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idAnimal != null) 'id_animal': idAnimal,
      if (idUser != null) 'id_user': idUser,
      if (animalIdentification != null)
        'animal_identification': animalIdentification,
      if (animalName != null) 'animal_name': animalName,
      if (animalColor != null) 'animal_color': animalColor,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalCompanion copyWith(
      {Value<String>? idAnimal,
      Value<String>? idUser,
      Value<String>? animalIdentification,
      Value<String>? animalName,
      Value<String>? animalColor,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return AnimalCompanion(
      idAnimal: idAnimal ?? this.idAnimal,
      idUser: idUser ?? this.idUser,
      animalIdentification: animalIdentification ?? this.animalIdentification,
      animalName: animalName ?? this.animalName,
      animalColor: animalColor ?? this.animalColor,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idAnimal.present) {
      map['id_animal'] = Variable<String>(idAnimal.value);
    }
    if (idUser.present) {
      map['id_user'] = Variable<String>(idUser.value);
    }
    if (animalIdentification.present) {
      map['animal_identification'] =
          Variable<String>(animalIdentification.value);
    }
    if (animalName.present) {
      map['animal_name'] = Variable<String>(animalName.value);
    }
    if (animalColor.present) {
      map['animal_color'] = Variable<String>(animalColor.value);
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
    return (StringBuffer('AnimalCompanion(')
          ..write('idAnimal: $idAnimal, ')
          ..write('idUser: $idUser, ')
          ..write('animalIdentification: $animalIdentification, ')
          ..write('animalName: $animalName, ')
          ..write('animalColor: $animalColor, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FenceAnimalsTable extends FenceAnimals
    with TableInfo<$FenceAnimalsTable, FenceAnimal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FenceAnimalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idFenceMeta =
      const VerificationMeta('idFence');
  @override
  late final GeneratedColumn<String> idFence = GeneratedColumn<String>(
      'id_fence', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES fence (id_fence)'));
  static const VerificationMeta _idAnimalMeta =
      const VerificationMeta('idAnimal');
  @override
  late final GeneratedColumn<String> idAnimal = GeneratedColumn<String>(
      'id_animal', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES animal (id_animal)'));
  @override
  List<GeneratedColumn> get $columns => [idFence, idAnimal];
  @override
  String get aliasedName => _alias ?? 'fence_animals';
  @override
  String get actualTableName => 'fence_animals';
  @override
  VerificationContext validateIntegrity(Insertable<FenceAnimal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id_fence')) {
      context.handle(_idFenceMeta,
          idFence.isAcceptableOrUnknown(data['id_fence']!, _idFenceMeta));
    } else if (isInserting) {
      context.missing(_idFenceMeta);
    }
    if (data.containsKey('id_animal')) {
      context.handle(_idAnimalMeta,
          idAnimal.isAcceptableOrUnknown(data['id_animal']!, _idAnimalMeta));
    } else if (isInserting) {
      context.missing(_idAnimalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idFence, idAnimal};
  @override
  FenceAnimal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FenceAnimal(
      idFence: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_fence'])!,
      idAnimal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_animal'])!,
    );
  }

  @override
  $FenceAnimalsTable createAlias(String alias) {
    return $FenceAnimalsTable(attachedDatabase, alias);
  }
}

class FenceAnimal extends DataClass implements Insertable<FenceAnimal> {
  final String idFence;
  final String idAnimal;
  const FenceAnimal({required this.idFence, required this.idAnimal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_fence'] = Variable<String>(idFence);
    map['id_animal'] = Variable<String>(idAnimal);
    return map;
  }

  FenceAnimalsCompanion toCompanion(bool nullToAbsent) {
    return FenceAnimalsCompanion(
      idFence: Value(idFence),
      idAnimal: Value(idAnimal),
    );
  }

  factory FenceAnimal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FenceAnimal(
      idFence: serializer.fromJson<String>(json['idFence']),
      idAnimal: serializer.fromJson<String>(json['idAnimal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idFence': serializer.toJson<String>(idFence),
      'idAnimal': serializer.toJson<String>(idAnimal),
    };
  }

  FenceAnimal copyWith({String? idFence, String? idAnimal}) => FenceAnimal(
        idFence: idFence ?? this.idFence,
        idAnimal: idAnimal ?? this.idAnimal,
      );
  @override
  String toString() {
    return (StringBuffer('FenceAnimal(')
          ..write('idFence: $idFence, ')
          ..write('idAnimal: $idAnimal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(idFence, idAnimal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FenceAnimal &&
          other.idFence == this.idFence &&
          other.idAnimal == this.idAnimal);
}

class FenceAnimalsCompanion extends UpdateCompanion<FenceAnimal> {
  final Value<String> idFence;
  final Value<String> idAnimal;
  final Value<int> rowid;
  const FenceAnimalsCompanion({
    this.idFence = const Value.absent(),
    this.idAnimal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FenceAnimalsCompanion.insert({
    required String idFence,
    required String idAnimal,
    this.rowid = const Value.absent(),
  })  : idFence = Value(idFence),
        idAnimal = Value(idAnimal);
  static Insertable<FenceAnimal> custom({
    Expression<String>? idFence,
    Expression<String>? idAnimal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idFence != null) 'id_fence': idFence,
      if (idAnimal != null) 'id_animal': idAnimal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FenceAnimalsCompanion copyWith(
      {Value<String>? idFence, Value<String>? idAnimal, Value<int>? rowid}) {
    return FenceAnimalsCompanion(
      idFence: idFence ?? this.idFence,
      idAnimal: idAnimal ?? this.idAnimal,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idFence.present) {
      map['id_fence'] = Variable<String>(idFence.value);
    }
    if (idAnimal.present) {
      map['id_animal'] = Variable<String>(idAnimal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FenceAnimalsCompanion(')
          ..write('idFence: $idFence, ')
          ..write('idAnimal: $idAnimal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimalLocationsTable extends AnimalLocations
    with TableInfo<$AnimalLocationsTable, AnimalLocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _animalDataIdMeta =
      const VerificationMeta('animalDataId');
  @override
  late final GeneratedColumn<String> animalDataId = GeneratedColumn<String>(
      'animal_data_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idAnimalMeta =
      const VerificationMeta('idAnimal');
  @override
  late final GeneratedColumn<String> idAnimal = GeneratedColumn<String>(
      'id_animal', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES animal (id_animal)'));
  static const VerificationMeta _temperatureMeta =
      const VerificationMeta('temperature');
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
      'temperature', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _batteryMeta =
      const VerificationMeta('battery');
  @override
  late final GeneratedColumn<int> battery = GeneratedColumn<int>(
      'battery', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
      'lon', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _elevationMeta =
      const VerificationMeta('elevation');
  @override
  late final GeneratedColumn<double> elevation = GeneratedColumn<double>(
      'elevation', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _accuracyMeta =
      const VerificationMeta('accuracy');
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
      'accuracy', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        animalDataId,
        idAnimal,
        temperature,
        battery,
        lat,
        lon,
        elevation,
        accuracy,
        date,
        state
      ];
  @override
  String get aliasedName => _alias ?? 'animal_locations';
  @override
  String get actualTableName => 'animal_locations';
  @override
  VerificationContext validateIntegrity(Insertable<AnimalLocation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('animal_data_id')) {
      context.handle(
          _animalDataIdMeta,
          animalDataId.isAcceptableOrUnknown(
              data['animal_data_id']!, _animalDataIdMeta));
    } else if (isInserting) {
      context.missing(_animalDataIdMeta);
    }
    if (data.containsKey('id_animal')) {
      context.handle(_idAnimalMeta,
          idAnimal.isAcceptableOrUnknown(data['id_animal']!, _idAnimalMeta));
    }
    if (data.containsKey('temperature')) {
      context.handle(
          _temperatureMeta,
          temperature.isAcceptableOrUnknown(
              data['temperature']!, _temperatureMeta));
    }
    if (data.containsKey('battery')) {
      context.handle(_batteryMeta,
          battery.isAcceptableOrUnknown(data['battery']!, _batteryMeta));
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    }
    if (data.containsKey('lon')) {
      context.handle(
          _lonMeta, lon.isAcceptableOrUnknown(data['lon']!, _lonMeta));
    }
    if (data.containsKey('elevation')) {
      context.handle(_elevationMeta,
          elevation.isAcceptableOrUnknown(data['elevation']!, _elevationMeta));
    }
    if (data.containsKey('accuracy')) {
      context.handle(_accuracyMeta,
          accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {animalDataId};
  @override
  AnimalLocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalLocation(
      animalDataId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_data_id'])!,
      idAnimal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_animal']),
      temperature: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}temperature']),
      battery: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}battery']),
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat']),
      lon: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lon']),
      elevation: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}elevation']),
      accuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accuracy']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state']),
    );
  }

  @override
  $AnimalLocationsTable createAlias(String alias) {
    return $AnimalLocationsTable(attachedDatabase, alias);
  }
}

class AnimalLocation extends DataClass implements Insertable<AnimalLocation> {
  final String animalDataId;
  final String? idAnimal;
  final double? temperature;
  final int? battery;
  final double? lat;
  final double? lon;
  final double? elevation;
  final double? accuracy;
  final DateTime date;
  final String? state;
  const AnimalLocation(
      {required this.animalDataId,
      this.idAnimal,
      this.temperature,
      this.battery,
      this.lat,
      this.lon,
      this.elevation,
      this.accuracy,
      required this.date,
      this.state});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['animal_data_id'] = Variable<String>(animalDataId);
    if (!nullToAbsent || idAnimal != null) {
      map['id_animal'] = Variable<String>(idAnimal);
    }
    if (!nullToAbsent || temperature != null) {
      map['temperature'] = Variable<double>(temperature);
    }
    if (!nullToAbsent || battery != null) {
      map['battery'] = Variable<int>(battery);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lon != null) {
      map['lon'] = Variable<double>(lon);
    }
    if (!nullToAbsent || elevation != null) {
      map['elevation'] = Variable<double>(elevation);
    }
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<double>(accuracy);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    return map;
  }

  AnimalLocationsCompanion toCompanion(bool nullToAbsent) {
    return AnimalLocationsCompanion(
      animalDataId: Value(animalDataId),
      idAnimal: idAnimal == null && nullToAbsent
          ? const Value.absent()
          : Value(idAnimal),
      temperature: temperature == null && nullToAbsent
          ? const Value.absent()
          : Value(temperature),
      battery: battery == null && nullToAbsent
          ? const Value.absent()
          : Value(battery),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lon: lon == null && nullToAbsent ? const Value.absent() : Value(lon),
      elevation: elevation == null && nullToAbsent
          ? const Value.absent()
          : Value(elevation),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      date: Value(date),
      state:
          state == null && nullToAbsent ? const Value.absent() : Value(state),
    );
  }

  factory AnimalLocation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalLocation(
      animalDataId: serializer.fromJson<String>(json['animalDataId']),
      idAnimal: serializer.fromJson<String?>(json['idAnimal']),
      temperature: serializer.fromJson<double?>(json['temperature']),
      battery: serializer.fromJson<int?>(json['battery']),
      lat: serializer.fromJson<double?>(json['lat']),
      lon: serializer.fromJson<double?>(json['lon']),
      elevation: serializer.fromJson<double?>(json['elevation']),
      accuracy: serializer.fromJson<double?>(json['accuracy']),
      date: serializer.fromJson<DateTime>(json['date']),
      state: serializer.fromJson<String?>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'animalDataId': serializer.toJson<String>(animalDataId),
      'idAnimal': serializer.toJson<String?>(idAnimal),
      'temperature': serializer.toJson<double?>(temperature),
      'battery': serializer.toJson<int?>(battery),
      'lat': serializer.toJson<double?>(lat),
      'lon': serializer.toJson<double?>(lon),
      'elevation': serializer.toJson<double?>(elevation),
      'accuracy': serializer.toJson<double?>(accuracy),
      'date': serializer.toJson<DateTime>(date),
      'state': serializer.toJson<String?>(state),
    };
  }

  AnimalLocation copyWith(
          {String? animalDataId,
          Value<String?> idAnimal = const Value.absent(),
          Value<double?> temperature = const Value.absent(),
          Value<int?> battery = const Value.absent(),
          Value<double?> lat = const Value.absent(),
          Value<double?> lon = const Value.absent(),
          Value<double?> elevation = const Value.absent(),
          Value<double?> accuracy = const Value.absent(),
          DateTime? date,
          Value<String?> state = const Value.absent()}) =>
      AnimalLocation(
        animalDataId: animalDataId ?? this.animalDataId,
        idAnimal: idAnimal.present ? idAnimal.value : this.idAnimal,
        temperature: temperature.present ? temperature.value : this.temperature,
        battery: battery.present ? battery.value : this.battery,
        lat: lat.present ? lat.value : this.lat,
        lon: lon.present ? lon.value : this.lon,
        elevation: elevation.present ? elevation.value : this.elevation,
        accuracy: accuracy.present ? accuracy.value : this.accuracy,
        date: date ?? this.date,
        state: state.present ? state.value : this.state,
      );
  @override
  String toString() {
    return (StringBuffer('AnimalLocation(')
          ..write('animalDataId: $animalDataId, ')
          ..write('idAnimal: $idAnimal, ')
          ..write('temperature: $temperature, ')
          ..write('battery: $battery, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('elevation: $elevation, ')
          ..write('accuracy: $accuracy, ')
          ..write('date: $date, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(animalDataId, idAnimal, temperature, battery,
      lat, lon, elevation, accuracy, date, state);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalLocation &&
          other.animalDataId == this.animalDataId &&
          other.idAnimal == this.idAnimal &&
          other.temperature == this.temperature &&
          other.battery == this.battery &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.elevation == this.elevation &&
          other.accuracy == this.accuracy &&
          other.date == this.date &&
          other.state == this.state);
}

class AnimalLocationsCompanion extends UpdateCompanion<AnimalLocation> {
  final Value<String> animalDataId;
  final Value<String?> idAnimal;
  final Value<double?> temperature;
  final Value<int?> battery;
  final Value<double?> lat;
  final Value<double?> lon;
  final Value<double?> elevation;
  final Value<double?> accuracy;
  final Value<DateTime> date;
  final Value<String?> state;
  final Value<int> rowid;
  const AnimalLocationsCompanion({
    this.animalDataId = const Value.absent(),
    this.idAnimal = const Value.absent(),
    this.temperature = const Value.absent(),
    this.battery = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.elevation = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.date = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalLocationsCompanion.insert({
    required String animalDataId,
    this.idAnimal = const Value.absent(),
    this.temperature = const Value.absent(),
    this.battery = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.elevation = const Value.absent(),
    this.accuracy = const Value.absent(),
    required DateTime date,
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : animalDataId = Value(animalDataId),
        date = Value(date);
  static Insertable<AnimalLocation> custom({
    Expression<String>? animalDataId,
    Expression<String>? idAnimal,
    Expression<double>? temperature,
    Expression<int>? battery,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<double>? elevation,
    Expression<double>? accuracy,
    Expression<DateTime>? date,
    Expression<String>? state,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (animalDataId != null) 'animal_data_id': animalDataId,
      if (idAnimal != null) 'id_animal': idAnimal,
      if (temperature != null) 'temperature': temperature,
      if (battery != null) 'battery': battery,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (elevation != null) 'elevation': elevation,
      if (accuracy != null) 'accuracy': accuracy,
      if (date != null) 'date': date,
      if (state != null) 'state': state,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalLocationsCompanion copyWith(
      {Value<String>? animalDataId,
      Value<String?>? idAnimal,
      Value<double?>? temperature,
      Value<int?>? battery,
      Value<double?>? lat,
      Value<double?>? lon,
      Value<double?>? elevation,
      Value<double?>? accuracy,
      Value<DateTime>? date,
      Value<String?>? state,
      Value<int>? rowid}) {
    return AnimalLocationsCompanion(
      animalDataId: animalDataId ?? this.animalDataId,
      idAnimal: idAnimal ?? this.idAnimal,
      temperature: temperature ?? this.temperature,
      battery: battery ?? this.battery,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      elevation: elevation ?? this.elevation,
      accuracy: accuracy ?? this.accuracy,
      date: date ?? this.date,
      state: state ?? this.state,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (animalDataId.present) {
      map['animal_data_id'] = Variable<String>(animalDataId.value);
    }
    if (idAnimal.present) {
      map['id_animal'] = Variable<String>(idAnimal.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (battery.present) {
      map['battery'] = Variable<int>(battery.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (elevation.present) {
      map['elevation'] = Variable<double>(elevation.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalLocationsCompanion(')
          ..write('animalDataId: $animalDataId, ')
          ..write('idAnimal: $idAnimal, ')
          ..write('temperature: $temperature, ')
          ..write('battery: $battery, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('elevation: $elevation, ')
          ..write('accuracy: $accuracy, ')
          ..write('date: $date, ')
          ..write('state: $state, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SensorsTable extends Sensors with TableInfo<$SensorsTable, Sensor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SensorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idSensorMeta =
      const VerificationMeta('idSensor');
  @override
  late final GeneratedColumn<String> idSensor = GeneratedColumn<String>(
      'id_sensor', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sensorNameMeta =
      const VerificationMeta('sensorName');
  @override
  late final GeneratedColumn<String> sensorName = GeneratedColumn<String>(
      'sensor_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fullSensorNameMeta =
      const VerificationMeta('fullSensorName');
  @override
  late final GeneratedColumn<String> fullSensorName = GeneratedColumn<String>(
      'full_sensor_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _canAlertMeta =
      const VerificationMeta('canAlert');
  @override
  late final GeneratedColumn<bool> canAlert = GeneratedColumn<bool>(
      'can_alert', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("can_alert" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns =>
      [idSensor, sensorName, fullSensorName, canAlert];
  @override
  String get aliasedName => _alias ?? 'sensors';
  @override
  String get actualTableName => 'sensors';
  @override
  VerificationContext validateIntegrity(Insertable<Sensor> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id_sensor')) {
      context.handle(_idSensorMeta,
          idSensor.isAcceptableOrUnknown(data['id_sensor']!, _idSensorMeta));
    } else if (isInserting) {
      context.missing(_idSensorMeta);
    }
    if (data.containsKey('sensor_name')) {
      context.handle(
          _sensorNameMeta,
          sensorName.isAcceptableOrUnknown(
              data['sensor_name']!, _sensorNameMeta));
    } else if (isInserting) {
      context.missing(_sensorNameMeta);
    }
    if (data.containsKey('full_sensor_name')) {
      context.handle(
          _fullSensorNameMeta,
          fullSensorName.isAcceptableOrUnknown(
              data['full_sensor_name']!, _fullSensorNameMeta));
    } else if (isInserting) {
      context.missing(_fullSensorNameMeta);
    }
    if (data.containsKey('can_alert')) {
      context.handle(_canAlertMeta,
          canAlert.isAcceptableOrUnknown(data['can_alert']!, _canAlertMeta));
    } else if (isInserting) {
      context.missing(_canAlertMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idSensor};
  @override
  Sensor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sensor(
      idSensor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_sensor'])!,
      sensorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sensor_name'])!,
      fullSensorName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}full_sensor_name'])!,
      canAlert: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}can_alert'])!,
    );
  }

  @override
  $SensorsTable createAlias(String alias) {
    return $SensorsTable(attachedDatabase, alias);
  }
}

class Sensor extends DataClass implements Insertable<Sensor> {
  final String idSensor;
  final String sensorName;
  final String fullSensorName;
  final bool canAlert;
  const Sensor(
      {required this.idSensor,
      required this.sensorName,
      required this.fullSensorName,
      required this.canAlert});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_sensor'] = Variable<String>(idSensor);
    map['sensor_name'] = Variable<String>(sensorName);
    map['full_sensor_name'] = Variable<String>(fullSensorName);
    map['can_alert'] = Variable<bool>(canAlert);
    return map;
  }

  SensorsCompanion toCompanion(bool nullToAbsent) {
    return SensorsCompanion(
      idSensor: Value(idSensor),
      sensorName: Value(sensorName),
      fullSensorName: Value(fullSensorName),
      canAlert: Value(canAlert),
    );
  }

  factory Sensor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sensor(
      idSensor: serializer.fromJson<String>(json['idSensor']),
      sensorName: serializer.fromJson<String>(json['sensorName']),
      fullSensorName: serializer.fromJson<String>(json['fullSensorName']),
      canAlert: serializer.fromJson<bool>(json['canAlert']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idSensor': serializer.toJson<String>(idSensor),
      'sensorName': serializer.toJson<String>(sensorName),
      'fullSensorName': serializer.toJson<String>(fullSensorName),
      'canAlert': serializer.toJson<bool>(canAlert),
    };
  }

  Sensor copyWith(
          {String? idSensor,
          String? sensorName,
          String? fullSensorName,
          bool? canAlert}) =>
      Sensor(
        idSensor: idSensor ?? this.idSensor,
        sensorName: sensorName ?? this.sensorName,
        fullSensorName: fullSensorName ?? this.fullSensorName,
        canAlert: canAlert ?? this.canAlert,
      );
  @override
  String toString() {
    return (StringBuffer('Sensor(')
          ..write('idSensor: $idSensor, ')
          ..write('sensorName: $sensorName, ')
          ..write('fullSensorName: $fullSensorName, ')
          ..write('canAlert: $canAlert')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(idSensor, sensorName, fullSensorName, canAlert);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sensor &&
          other.idSensor == this.idSensor &&
          other.sensorName == this.sensorName &&
          other.fullSensorName == this.fullSensorName &&
          other.canAlert == this.canAlert);
}

class SensorsCompanion extends UpdateCompanion<Sensor> {
  final Value<String> idSensor;
  final Value<String> sensorName;
  final Value<String> fullSensorName;
  final Value<bool> canAlert;
  final Value<int> rowid;
  const SensorsCompanion({
    this.idSensor = const Value.absent(),
    this.sensorName = const Value.absent(),
    this.fullSensorName = const Value.absent(),
    this.canAlert = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SensorsCompanion.insert({
    required String idSensor,
    required String sensorName,
    required String fullSensorName,
    required bool canAlert,
    this.rowid = const Value.absent(),
  })  : idSensor = Value(idSensor),
        sensorName = Value(sensorName),
        fullSensorName = Value(fullSensorName),
        canAlert = Value(canAlert);
  static Insertable<Sensor> custom({
    Expression<String>? idSensor,
    Expression<String>? sensorName,
    Expression<String>? fullSensorName,
    Expression<bool>? canAlert,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idSensor != null) 'id_sensor': idSensor,
      if (sensorName != null) 'sensor_name': sensorName,
      if (fullSensorName != null) 'full_sensor_name': fullSensorName,
      if (canAlert != null) 'can_alert': canAlert,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SensorsCompanion copyWith(
      {Value<String>? idSensor,
      Value<String>? sensorName,
      Value<String>? fullSensorName,
      Value<bool>? canAlert,
      Value<int>? rowid}) {
    return SensorsCompanion(
      idSensor: idSensor ?? this.idSensor,
      sensorName: sensorName ?? this.sensorName,
      fullSensorName: fullSensorName ?? this.fullSensorName,
      canAlert: canAlert ?? this.canAlert,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idSensor.present) {
      map['id_sensor'] = Variable<String>(idSensor.value);
    }
    if (sensorName.present) {
      map['sensor_name'] = Variable<String>(sensorName.value);
    }
    if (fullSensorName.present) {
      map['full_sensor_name'] = Variable<String>(fullSensorName.value);
    }
    if (canAlert.present) {
      map['can_alert'] = Variable<bool>(canAlert.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SensorsCompanion(')
          ..write('idSensor: $idSensor, ')
          ..write('sensorName: $sensorName, ')
          ..write('fullSensorName: $fullSensorName, ')
          ..write('canAlert: $canAlert, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserAlertTable extends UserAlert
    with TableInfo<$UserAlertTable, UserAlertData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserAlertTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idAlertMeta =
      const VerificationMeta('idAlert');
  @override
  late final GeneratedColumn<String> idAlert = GeneratedColumn<String>(
      'id_alert', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _comparissonMeta =
      const VerificationMeta('comparisson');
  @override
  late final GeneratedColumn<String> comparisson = GeneratedColumn<String>(
      'comparisson', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conditionCompToMeta =
      const VerificationMeta('conditionCompTo');
  @override
  late final GeneratedColumn<String> conditionCompTo = GeneratedColumn<String>(
      'condition_comp_to', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hasNotificationMeta =
      const VerificationMeta('hasNotification');
  @override
  late final GeneratedColumn<bool> hasNotification = GeneratedColumn<bool>(
      'has_notification', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_notification" IN (0, 1))'));
  static const VerificationMeta _isTimedMeta =
      const VerificationMeta('isTimed');
  @override
  late final GeneratedColumn<bool> isTimed = GeneratedColumn<bool>(
      'is_timed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_timed" IN (0, 1))'));
  static const VerificationMeta _isStateParamMeta =
      const VerificationMeta('isStateParam');
  @override
  late final GeneratedColumn<bool> isStateParam = GeneratedColumn<bool>(
      'is_state_param', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_state_param" IN (0, 1))'));
  static const VerificationMeta _parameterMeta =
      const VerificationMeta('parameter');
  @override
  late final GeneratedColumn<String> parameter = GeneratedColumn<String>(
      'parameter', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sensors (id_sensor)'));
  @override
  List<GeneratedColumn> get $columns => [
        idAlert,
        comparisson,
        conditionCompTo,
        durationSeconds,
        hasNotification,
        isTimed,
        isStateParam,
        parameter
      ];
  @override
  String get aliasedName => _alias ?? 'user_alert';
  @override
  String get actualTableName => 'user_alert';
  @override
  VerificationContext validateIntegrity(Insertable<UserAlertData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id_alert')) {
      context.handle(_idAlertMeta,
          idAlert.isAcceptableOrUnknown(data['id_alert']!, _idAlertMeta));
    } else if (isInserting) {
      context.missing(_idAlertMeta);
    }
    if (data.containsKey('comparisson')) {
      context.handle(
          _comparissonMeta,
          comparisson.isAcceptableOrUnknown(
              data['comparisson']!, _comparissonMeta));
    } else if (isInserting) {
      context.missing(_comparissonMeta);
    }
    if (data.containsKey('condition_comp_to')) {
      context.handle(
          _conditionCompToMeta,
          conditionCompTo.isAcceptableOrUnknown(
              data['condition_comp_to']!, _conditionCompToMeta));
    } else if (isInserting) {
      context.missing(_conditionCompToMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('has_notification')) {
      context.handle(
          _hasNotificationMeta,
          hasNotification.isAcceptableOrUnknown(
              data['has_notification']!, _hasNotificationMeta));
    } else if (isInserting) {
      context.missing(_hasNotificationMeta);
    }
    if (data.containsKey('is_timed')) {
      context.handle(_isTimedMeta,
          isTimed.isAcceptableOrUnknown(data['is_timed']!, _isTimedMeta));
    } else if (isInserting) {
      context.missing(_isTimedMeta);
    }
    if (data.containsKey('is_state_param')) {
      context.handle(
          _isStateParamMeta,
          isStateParam.isAcceptableOrUnknown(
              data['is_state_param']!, _isStateParamMeta));
    } else if (isInserting) {
      context.missing(_isStateParamMeta);
    }
    if (data.containsKey('parameter')) {
      context.handle(_parameterMeta,
          parameter.isAcceptableOrUnknown(data['parameter']!, _parameterMeta));
    } else if (isInserting) {
      context.missing(_parameterMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idAlert};
  @override
  UserAlertData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserAlertData(
      idAlert: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_alert'])!,
      comparisson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comparisson'])!,
      conditionCompTo: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}condition_comp_to'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      hasNotification: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_notification'])!,
      isTimed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_timed'])!,
      isStateParam: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_state_param'])!,
      parameter: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parameter'])!,
    );
  }

  @override
  $UserAlertTable createAlias(String alias) {
    return $UserAlertTable(attachedDatabase, alias);
  }
}

class UserAlertData extends DataClass implements Insertable<UserAlertData> {
  final String idAlert;
  final String comparisson;
  final String conditionCompTo;
  final int durationSeconds;
  final bool hasNotification;
  final bool isTimed;
  final bool isStateParam;
  final String parameter;
  const UserAlertData(
      {required this.idAlert,
      required this.comparisson,
      required this.conditionCompTo,
      required this.durationSeconds,
      required this.hasNotification,
      required this.isTimed,
      required this.isStateParam,
      required this.parameter});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_alert'] = Variable<String>(idAlert);
    map['comparisson'] = Variable<String>(comparisson);
    map['condition_comp_to'] = Variable<String>(conditionCompTo);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['has_notification'] = Variable<bool>(hasNotification);
    map['is_timed'] = Variable<bool>(isTimed);
    map['is_state_param'] = Variable<bool>(isStateParam);
    map['parameter'] = Variable<String>(parameter);
    return map;
  }

  UserAlertCompanion toCompanion(bool nullToAbsent) {
    return UserAlertCompanion(
      idAlert: Value(idAlert),
      comparisson: Value(comparisson),
      conditionCompTo: Value(conditionCompTo),
      durationSeconds: Value(durationSeconds),
      hasNotification: Value(hasNotification),
      isTimed: Value(isTimed),
      isStateParam: Value(isStateParam),
      parameter: Value(parameter),
    );
  }

  factory UserAlertData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserAlertData(
      idAlert: serializer.fromJson<String>(json['idAlert']),
      comparisson: serializer.fromJson<String>(json['comparisson']),
      conditionCompTo: serializer.fromJson<String>(json['conditionCompTo']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      hasNotification: serializer.fromJson<bool>(json['hasNotification']),
      isTimed: serializer.fromJson<bool>(json['isTimed']),
      isStateParam: serializer.fromJson<bool>(json['isStateParam']),
      parameter: serializer.fromJson<String>(json['parameter']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idAlert': serializer.toJson<String>(idAlert),
      'comparisson': serializer.toJson<String>(comparisson),
      'conditionCompTo': serializer.toJson<String>(conditionCompTo),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'hasNotification': serializer.toJson<bool>(hasNotification),
      'isTimed': serializer.toJson<bool>(isTimed),
      'isStateParam': serializer.toJson<bool>(isStateParam),
      'parameter': serializer.toJson<String>(parameter),
    };
  }

  UserAlertData copyWith(
          {String? idAlert,
          String? comparisson,
          String? conditionCompTo,
          int? durationSeconds,
          bool? hasNotification,
          bool? isTimed,
          bool? isStateParam,
          String? parameter}) =>
      UserAlertData(
        idAlert: idAlert ?? this.idAlert,
        comparisson: comparisson ?? this.comparisson,
        conditionCompTo: conditionCompTo ?? this.conditionCompTo,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        hasNotification: hasNotification ?? this.hasNotification,
        isTimed: isTimed ?? this.isTimed,
        isStateParam: isStateParam ?? this.isStateParam,
        parameter: parameter ?? this.parameter,
      );
  @override
  String toString() {
    return (StringBuffer('UserAlertData(')
          ..write('idAlert: $idAlert, ')
          ..write('comparisson: $comparisson, ')
          ..write('conditionCompTo: $conditionCompTo, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('hasNotification: $hasNotification, ')
          ..write('isTimed: $isTimed, ')
          ..write('isStateParam: $isStateParam, ')
          ..write('parameter: $parameter')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(idAlert, comparisson, conditionCompTo,
      durationSeconds, hasNotification, isTimed, isStateParam, parameter);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserAlertData &&
          other.idAlert == this.idAlert &&
          other.comparisson == this.comparisson &&
          other.conditionCompTo == this.conditionCompTo &&
          other.durationSeconds == this.durationSeconds &&
          other.hasNotification == this.hasNotification &&
          other.isTimed == this.isTimed &&
          other.isStateParam == this.isStateParam &&
          other.parameter == this.parameter);
}

class UserAlertCompanion extends UpdateCompanion<UserAlertData> {
  final Value<String> idAlert;
  final Value<String> comparisson;
  final Value<String> conditionCompTo;
  final Value<int> durationSeconds;
  final Value<bool> hasNotification;
  final Value<bool> isTimed;
  final Value<bool> isStateParam;
  final Value<String> parameter;
  final Value<int> rowid;
  const UserAlertCompanion({
    this.idAlert = const Value.absent(),
    this.comparisson = const Value.absent(),
    this.conditionCompTo = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.hasNotification = const Value.absent(),
    this.isTimed = const Value.absent(),
    this.isStateParam = const Value.absent(),
    this.parameter = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserAlertCompanion.insert({
    required String idAlert,
    required String comparisson,
    required String conditionCompTo,
    required int durationSeconds,
    required bool hasNotification,
    required bool isTimed,
    required bool isStateParam,
    required String parameter,
    this.rowid = const Value.absent(),
  })  : idAlert = Value(idAlert),
        comparisson = Value(comparisson),
        conditionCompTo = Value(conditionCompTo),
        durationSeconds = Value(durationSeconds),
        hasNotification = Value(hasNotification),
        isTimed = Value(isTimed),
        isStateParam = Value(isStateParam),
        parameter = Value(parameter);
  static Insertable<UserAlertData> custom({
    Expression<String>? idAlert,
    Expression<String>? comparisson,
    Expression<String>? conditionCompTo,
    Expression<int>? durationSeconds,
    Expression<bool>? hasNotification,
    Expression<bool>? isTimed,
    Expression<bool>? isStateParam,
    Expression<String>? parameter,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idAlert != null) 'id_alert': idAlert,
      if (comparisson != null) 'comparisson': comparisson,
      if (conditionCompTo != null) 'condition_comp_to': conditionCompTo,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (hasNotification != null) 'has_notification': hasNotification,
      if (isTimed != null) 'is_timed': isTimed,
      if (isStateParam != null) 'is_state_param': isStateParam,
      if (parameter != null) 'parameter': parameter,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserAlertCompanion copyWith(
      {Value<String>? idAlert,
      Value<String>? comparisson,
      Value<String>? conditionCompTo,
      Value<int>? durationSeconds,
      Value<bool>? hasNotification,
      Value<bool>? isTimed,
      Value<bool>? isStateParam,
      Value<String>? parameter,
      Value<int>? rowid}) {
    return UserAlertCompanion(
      idAlert: idAlert ?? this.idAlert,
      comparisson: comparisson ?? this.comparisson,
      conditionCompTo: conditionCompTo ?? this.conditionCompTo,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      hasNotification: hasNotification ?? this.hasNotification,
      isTimed: isTimed ?? this.isTimed,
      isStateParam: isStateParam ?? this.isStateParam,
      parameter: parameter ?? this.parameter,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idAlert.present) {
      map['id_alert'] = Variable<String>(idAlert.value);
    }
    if (comparisson.present) {
      map['comparisson'] = Variable<String>(comparisson.value);
    }
    if (conditionCompTo.present) {
      map['condition_comp_to'] = Variable<String>(conditionCompTo.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (hasNotification.present) {
      map['has_notification'] = Variable<bool>(hasNotification.value);
    }
    if (isTimed.present) {
      map['is_timed'] = Variable<bool>(isTimed.value);
    }
    if (isStateParam.present) {
      map['is_state_param'] = Variable<bool>(isStateParam.value);
    }
    if (parameter.present) {
      map['parameter'] = Variable<String>(parameter.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserAlertCompanion(')
          ..write('idAlert: $idAlert, ')
          ..write('comparisson: $comparisson, ')
          ..write('conditionCompTo: $conditionCompTo, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('hasNotification: $hasNotification, ')
          ..write('isTimed: $isTimed, ')
          ..write('isStateParam: $isStateParam, ')
          ..write('parameter: $parameter, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlertNotificationTable extends AlertNotification
    with TableInfo<$AlertNotificationTable, AlertNotificationData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertNotificationTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idNotificationMeta =
      const VerificationMeta('idNotification');
  @override
  late final GeneratedColumn<String> idNotification = GeneratedColumn<String>(
      'id_notification', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idAnimalMeta =
      const VerificationMeta('idAnimal');
  @override
  late final GeneratedColumn<String> idAnimal = GeneratedColumn<String>(
      'id_animal', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES animal (id_animal)'));
  static const VerificationMeta _idAlertMeta =
      const VerificationMeta('idAlert');
  @override
  late final GeneratedColumn<String> idAlert = GeneratedColumn<String>(
      'id_alert', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES user_alert (id_alert)'));
  @override
  List<GeneratedColumn> get $columns => [idNotification, idAnimal, idAlert];
  @override
  String get aliasedName => _alias ?? 'alert_notification';
  @override
  String get actualTableName => 'alert_notification';
  @override
  VerificationContext validateIntegrity(
      Insertable<AlertNotificationData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id_notification')) {
      context.handle(
          _idNotificationMeta,
          idNotification.isAcceptableOrUnknown(
              data['id_notification']!, _idNotificationMeta));
    } else if (isInserting) {
      context.missing(_idNotificationMeta);
    }
    if (data.containsKey('id_animal')) {
      context.handle(_idAnimalMeta,
          idAnimal.isAcceptableOrUnknown(data['id_animal']!, _idAnimalMeta));
    } else if (isInserting) {
      context.missing(_idAnimalMeta);
    }
    if (data.containsKey('id_alert')) {
      context.handle(_idAlertMeta,
          idAlert.isAcceptableOrUnknown(data['id_alert']!, _idAlertMeta));
    } else if (isInserting) {
      context.missing(_idAlertMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idNotification};
  @override
  AlertNotificationData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertNotificationData(
      idNotification: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}id_notification'])!,
      idAnimal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_animal'])!,
      idAlert: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_alert'])!,
    );
  }

  @override
  $AlertNotificationTable createAlias(String alias) {
    return $AlertNotificationTable(attachedDatabase, alias);
  }
}

class AlertNotificationData extends DataClass
    implements Insertable<AlertNotificationData> {
  final String idNotification;
  final String idAnimal;
  final String idAlert;
  const AlertNotificationData(
      {required this.idNotification,
      required this.idAnimal,
      required this.idAlert});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_notification'] = Variable<String>(idNotification);
    map['id_animal'] = Variable<String>(idAnimal);
    map['id_alert'] = Variable<String>(idAlert);
    return map;
  }

  AlertNotificationCompanion toCompanion(bool nullToAbsent) {
    return AlertNotificationCompanion(
      idNotification: Value(idNotification),
      idAnimal: Value(idAnimal),
      idAlert: Value(idAlert),
    );
  }

  factory AlertNotificationData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertNotificationData(
      idNotification: serializer.fromJson<String>(json['idNotification']),
      idAnimal: serializer.fromJson<String>(json['idAnimal']),
      idAlert: serializer.fromJson<String>(json['idAlert']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idNotification': serializer.toJson<String>(idNotification),
      'idAnimal': serializer.toJson<String>(idAnimal),
      'idAlert': serializer.toJson<String>(idAlert),
    };
  }

  AlertNotificationData copyWith(
          {String? idNotification, String? idAnimal, String? idAlert}) =>
      AlertNotificationData(
        idNotification: idNotification ?? this.idNotification,
        idAnimal: idAnimal ?? this.idAnimal,
        idAlert: idAlert ?? this.idAlert,
      );
  @override
  String toString() {
    return (StringBuffer('AlertNotificationData(')
          ..write('idNotification: $idNotification, ')
          ..write('idAnimal: $idAnimal, ')
          ..write('idAlert: $idAlert')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(idNotification, idAnimal, idAlert);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertNotificationData &&
          other.idNotification == this.idNotification &&
          other.idAnimal == this.idAnimal &&
          other.idAlert == this.idAlert);
}

class AlertNotificationCompanion
    extends UpdateCompanion<AlertNotificationData> {
  final Value<String> idNotification;
  final Value<String> idAnimal;
  final Value<String> idAlert;
  final Value<int> rowid;
  const AlertNotificationCompanion({
    this.idNotification = const Value.absent(),
    this.idAnimal = const Value.absent(),
    this.idAlert = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertNotificationCompanion.insert({
    required String idNotification,
    required String idAnimal,
    required String idAlert,
    this.rowid = const Value.absent(),
  })  : idNotification = Value(idNotification),
        idAnimal = Value(idAnimal),
        idAlert = Value(idAlert);
  static Insertable<AlertNotificationData> custom({
    Expression<String>? idNotification,
    Expression<String>? idAnimal,
    Expression<String>? idAlert,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idNotification != null) 'id_notification': idNotification,
      if (idAnimal != null) 'id_animal': idAnimal,
      if (idAlert != null) 'id_alert': idAlert,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertNotificationCompanion copyWith(
      {Value<String>? idNotification,
      Value<String>? idAnimal,
      Value<String>? idAlert,
      Value<int>? rowid}) {
    return AlertNotificationCompanion(
      idNotification: idNotification ?? this.idNotification,
      idAnimal: idAnimal ?? this.idAnimal,
      idAlert: idAlert ?? this.idAlert,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idNotification.present) {
      map['id_notification'] = Variable<String>(idNotification.value);
    }
    if (idAnimal.present) {
      map['id_animal'] = Variable<String>(idAnimal.value);
    }
    if (idAlert.present) {
      map['id_alert'] = Variable<String>(idAlert.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertNotificationCompanion(')
          ..write('idNotification: $idNotification, ')
          ..write('idAnimal: $idAnimal, ')
          ..write('idAlert: $idAlert, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlertAnimalsTable extends AlertAnimals
    with TableInfo<$AlertAnimalsTable, AlertAnimal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertAnimalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idAnimalMeta =
      const VerificationMeta('idAnimal');
  @override
  late final GeneratedColumn<String> idAnimal = GeneratedColumn<String>(
      'id_animal', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES animal (id_animal)'));
  static const VerificationMeta _idAlertMeta =
      const VerificationMeta('idAlert');
  @override
  late final GeneratedColumn<String> idAlert = GeneratedColumn<String>(
      'id_alert', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES user_alert (id_alert)'));
  @override
  List<GeneratedColumn> get $columns => [idAnimal, idAlert];
  @override
  String get aliasedName => _alias ?? 'alert_animals';
  @override
  String get actualTableName => 'alert_animals';
  @override
  VerificationContext validateIntegrity(Insertable<AlertAnimal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id_animal')) {
      context.handle(_idAnimalMeta,
          idAnimal.isAcceptableOrUnknown(data['id_animal']!, _idAnimalMeta));
    } else if (isInserting) {
      context.missing(_idAnimalMeta);
    }
    if (data.containsKey('id_alert')) {
      context.handle(_idAlertMeta,
          idAlert.isAcceptableOrUnknown(data['id_alert']!, _idAlertMeta));
    } else if (isInserting) {
      context.missing(_idAlertMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idAnimal, idAlert};
  @override
  AlertAnimal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertAnimal(
      idAnimal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_animal'])!,
      idAlert: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_alert'])!,
    );
  }

  @override
  $AlertAnimalsTable createAlias(String alias) {
    return $AlertAnimalsTable(attachedDatabase, alias);
  }
}

class AlertAnimal extends DataClass implements Insertable<AlertAnimal> {
  final String idAnimal;
  final String idAlert;
  const AlertAnimal({required this.idAnimal, required this.idAlert});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_animal'] = Variable<String>(idAnimal);
    map['id_alert'] = Variable<String>(idAlert);
    return map;
  }

  AlertAnimalsCompanion toCompanion(bool nullToAbsent) {
    return AlertAnimalsCompanion(
      idAnimal: Value(idAnimal),
      idAlert: Value(idAlert),
    );
  }

  factory AlertAnimal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertAnimal(
      idAnimal: serializer.fromJson<String>(json['idAnimal']),
      idAlert: serializer.fromJson<String>(json['idAlert']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idAnimal': serializer.toJson<String>(idAnimal),
      'idAlert': serializer.toJson<String>(idAlert),
    };
  }

  AlertAnimal copyWith({String? idAnimal, String? idAlert}) => AlertAnimal(
        idAnimal: idAnimal ?? this.idAnimal,
        idAlert: idAlert ?? this.idAlert,
      );
  @override
  String toString() {
    return (StringBuffer('AlertAnimal(')
          ..write('idAnimal: $idAnimal, ')
          ..write('idAlert: $idAlert')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(idAnimal, idAlert);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertAnimal &&
          other.idAnimal == this.idAnimal &&
          other.idAlert == this.idAlert);
}

class AlertAnimalsCompanion extends UpdateCompanion<AlertAnimal> {
  final Value<String> idAnimal;
  final Value<String> idAlert;
  final Value<int> rowid;
  const AlertAnimalsCompanion({
    this.idAnimal = const Value.absent(),
    this.idAlert = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertAnimalsCompanion.insert({
    required String idAnimal,
    required String idAlert,
    this.rowid = const Value.absent(),
  })  : idAnimal = Value(idAnimal),
        idAlert = Value(idAlert);
  static Insertable<AlertAnimal> custom({
    Expression<String>? idAnimal,
    Expression<String>? idAlert,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idAnimal != null) 'id_animal': idAnimal,
      if (idAlert != null) 'id_alert': idAlert,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertAnimalsCompanion copyWith(
      {Value<String>? idAnimal, Value<String>? idAlert, Value<int>? rowid}) {
    return AlertAnimalsCompanion(
      idAnimal: idAnimal ?? this.idAnimal,
      idAlert: idAlert ?? this.idAlert,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idAnimal.present) {
      map['id_animal'] = Variable<String>(idAnimal.value);
    }
    if (idAlert.present) {
      map['id_alert'] = Variable<String>(idAlert.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertAnimalsCompanion(')
          ..write('idAnimal: $idAnimal, ')
          ..write('idAlert: $idAlert, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$GuardianDb extends GeneratedDatabase {
  _$GuardianDb(QueryExecutor e) : super(e);
  late final $UserTable user = $UserTable(this);
  late final $FenceTable fence = $FenceTable(this);
  late final $FencePointsTable fencePoints = $FencePointsTable(this);
  late final $AnimalTable animal = $AnimalTable(this);
  late final $FenceAnimalsTable fenceAnimals = $FenceAnimalsTable(this);
  late final $AnimalLocationsTable animalLocations =
      $AnimalLocationsTable(this);
  late final $SensorsTable sensors = $SensorsTable(this);
  late final $UserAlertTable userAlert = $UserAlertTable(this);
  late final $AlertNotificationTable alertNotification =
      $AlertNotificationTable(this);
  late final $AlertAnimalsTable alertAnimals = $AlertAnimalsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        user,
        fence,
        fencePoints,
        animal,
        fenceAnimals,
        animalLocations,
        sensors,
        userAlert,
        alertNotification,
        alertAnimals
      ];
}
