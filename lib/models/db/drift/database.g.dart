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
  late final GeneratedColumn<BigInt> idUser = GeneratedColumn<BigInt>(
      'id_user', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: false);
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
  @override
  List<GeneratedColumn> get $columns =>
      [idUser, name, email, phone, isSuperuser, isProducer];
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idUser};
  @override
  UserData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserData(
      idUser: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id_user'])!,
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
    );
  }

  @override
  $UserTable createAlias(String alias) {
    return $UserTable(attachedDatabase, alias);
  }
}

class UserData extends DataClass implements Insertable<UserData> {
  final BigInt idUser;
  final String name;
  final String email;
  final int phone;
  final bool isSuperuser;
  final bool isProducer;
  const UserData(
      {required this.idUser,
      required this.name,
      required this.email,
      required this.phone,
      required this.isSuperuser,
      required this.isProducer});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_user'] = Variable<BigInt>(idUser);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['phone'] = Variable<int>(phone);
    map['is_superuser'] = Variable<bool>(isSuperuser);
    map['is_producer'] = Variable<bool>(isProducer);
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
    );
  }

  factory UserData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserData(
      idUser: serializer.fromJson<BigInt>(json['idUser']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      phone: serializer.fromJson<int>(json['phone']),
      isSuperuser: serializer.fromJson<bool>(json['isSuperuser']),
      isProducer: serializer.fromJson<bool>(json['isProducer']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idUser': serializer.toJson<BigInt>(idUser),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'phone': serializer.toJson<int>(phone),
      'isSuperuser': serializer.toJson<bool>(isSuperuser),
      'isProducer': serializer.toJson<bool>(isProducer),
    };
  }

  UserData copyWith(
          {BigInt? idUser,
          String? name,
          String? email,
          int? phone,
          bool? isSuperuser,
          bool? isProducer}) =>
      UserData(
        idUser: idUser ?? this.idUser,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        isSuperuser: isSuperuser ?? this.isSuperuser,
        isProducer: isProducer ?? this.isProducer,
      );
  @override
  String toString() {
    return (StringBuffer('UserData(')
          ..write('idUser: $idUser, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('isSuperuser: $isSuperuser, ')
          ..write('isProducer: $isProducer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(idUser, name, email, phone, isSuperuser, isProducer);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserData &&
          other.idUser == this.idUser &&
          other.name == this.name &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.isSuperuser == this.isSuperuser &&
          other.isProducer == this.isProducer);
}

class UserCompanion extends UpdateCompanion<UserData> {
  final Value<BigInt> idUser;
  final Value<String> name;
  final Value<String> email;
  final Value<int> phone;
  final Value<bool> isSuperuser;
  final Value<bool> isProducer;
  const UserCompanion({
    this.idUser = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.isSuperuser = const Value.absent(),
    this.isProducer = const Value.absent(),
  });
  UserCompanion.insert({
    this.idUser = const Value.absent(),
    required String name,
    required String email,
    required int phone,
    required bool isSuperuser,
    required bool isProducer,
  })  : name = Value(name),
        email = Value(email),
        phone = Value(phone),
        isSuperuser = Value(isSuperuser),
        isProducer = Value(isProducer);
  static Insertable<UserData> custom({
    Expression<BigInt>? idUser,
    Expression<String>? name,
    Expression<String>? email,
    Expression<int>? phone,
    Expression<bool>? isSuperuser,
    Expression<bool>? isProducer,
  }) {
    return RawValuesInsertable({
      if (idUser != null) 'id_user': idUser,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (isSuperuser != null) 'is_superuser': isSuperuser,
      if (isProducer != null) 'is_producer': isProducer,
    });
  }

  UserCompanion copyWith(
      {Value<BigInt>? idUser,
      Value<String>? name,
      Value<String>? email,
      Value<int>? phone,
      Value<bool>? isSuperuser,
      Value<bool>? isProducer}) {
    return UserCompanion(
      idUser: idUser ?? this.idUser,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      isProducer: isProducer ?? this.isProducer,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idUser.present) {
      map['id_user'] = Variable<BigInt>(idUser.value);
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
          ..write('isProducer: $isProducer')
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
  late final GeneratedColumn<BigInt> idFence = GeneratedColumn<BigInt>(
      'id_fence', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: false);
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
  @override
  List<GeneratedColumn> get $columns => [idFence, name, color];
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idFence};
  @override
  FenceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FenceData(
      idFence: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id_fence'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
    );
  }

  @override
  $FenceTable createAlias(String alias) {
    return $FenceTable(attachedDatabase, alias);
  }
}

class FenceData extends DataClass implements Insertable<FenceData> {
  final BigInt idFence;
  final String name;
  final String color;
  const FenceData(
      {required this.idFence, required this.name, required this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_fence'] = Variable<BigInt>(idFence);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    return map;
  }

  FenceCompanion toCompanion(bool nullToAbsent) {
    return FenceCompanion(
      idFence: Value(idFence),
      name: Value(name),
      color: Value(color),
    );
  }

  factory FenceData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FenceData(
      idFence: serializer.fromJson<BigInt>(json['idFence']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idFence': serializer.toJson<BigInt>(idFence),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
    };
  }

  FenceData copyWith({BigInt? idFence, String? name, String? color}) =>
      FenceData(
        idFence: idFence ?? this.idFence,
        name: name ?? this.name,
        color: color ?? this.color,
      );
  @override
  String toString() {
    return (StringBuffer('FenceData(')
          ..write('idFence: $idFence, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(idFence, name, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FenceData &&
          other.idFence == this.idFence &&
          other.name == this.name &&
          other.color == this.color);
}

class FenceCompanion extends UpdateCompanion<FenceData> {
  final Value<BigInt> idFence;
  final Value<String> name;
  final Value<String> color;
  const FenceCompanion({
    this.idFence = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
  });
  FenceCompanion.insert({
    this.idFence = const Value.absent(),
    required String name,
    required String color,
  })  : name = Value(name),
        color = Value(color);
  static Insertable<FenceData> custom({
    Expression<BigInt>? idFence,
    Expression<String>? name,
    Expression<String>? color,
  }) {
    return RawValuesInsertable({
      if (idFence != null) 'id_fence': idFence,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
    });
  }

  FenceCompanion copyWith(
      {Value<BigInt>? idFence, Value<String>? name, Value<String>? color}) {
    return FenceCompanion(
      idFence: idFence ?? this.idFence,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idFence.present) {
      map['id_fence'] = Variable<BigInt>(idFence.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FenceCompanion(')
          ..write('idFence: $idFence, ')
          ..write('name: $name, ')
          ..write('color: $color')
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
  late final GeneratedColumn<BigInt> idFencePoint = GeneratedColumn<BigInt>(
      'id_fence_point', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: false);
  static const VerificationMeta _idFenceMeta =
      const VerificationMeta('idFence');
  @override
  late final GeneratedColumn<BigInt> idFence = GeneratedColumn<BigInt>(
      'id_fence', aliasedName, false,
      type: DriftSqlType.bigInt,
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
  @override
  List<GeneratedColumn> get $columns => [idFencePoint, idFence, lat, lon];
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idFencePoint};
  @override
  FencePoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FencePoint(
      idFencePoint: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id_fence_point'])!,
      idFence: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id_fence'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lon: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lon'])!,
    );
  }

  @override
  $FencePointsTable createAlias(String alias) {
    return $FencePointsTable(attachedDatabase, alias);
  }
}

class FencePoint extends DataClass implements Insertable<FencePoint> {
  final BigInt idFencePoint;
  final BigInt idFence;
  final double lat;
  final double lon;
  const FencePoint(
      {required this.idFencePoint,
      required this.idFence,
      required this.lat,
      required this.lon});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_fence_point'] = Variable<BigInt>(idFencePoint);
    map['id_fence'] = Variable<BigInt>(idFence);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    return map;
  }

  FencePointsCompanion toCompanion(bool nullToAbsent) {
    return FencePointsCompanion(
      idFencePoint: Value(idFencePoint),
      idFence: Value(idFence),
      lat: Value(lat),
      lon: Value(lon),
    );
  }

  factory FencePoint.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FencePoint(
      idFencePoint: serializer.fromJson<BigInt>(json['idFencePoint']),
      idFence: serializer.fromJson<BigInt>(json['idFence']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idFencePoint': serializer.toJson<BigInt>(idFencePoint),
      'idFence': serializer.toJson<BigInt>(idFence),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
    };
  }

  FencePoint copyWith(
          {BigInt? idFencePoint, BigInt? idFence, double? lat, double? lon}) =>
      FencePoint(
        idFencePoint: idFencePoint ?? this.idFencePoint,
        idFence: idFence ?? this.idFence,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
      );
  @override
  String toString() {
    return (StringBuffer('FencePoint(')
          ..write('idFencePoint: $idFencePoint, ')
          ..write('idFence: $idFence, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(idFencePoint, idFence, lat, lon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FencePoint &&
          other.idFencePoint == this.idFencePoint &&
          other.idFence == this.idFence &&
          other.lat == this.lat &&
          other.lon == this.lon);
}

class FencePointsCompanion extends UpdateCompanion<FencePoint> {
  final Value<BigInt> idFencePoint;
  final Value<BigInt> idFence;
  final Value<double> lat;
  final Value<double> lon;
  const FencePointsCompanion({
    this.idFencePoint = const Value.absent(),
    this.idFence = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
  });
  FencePointsCompanion.insert({
    this.idFencePoint = const Value.absent(),
    required BigInt idFence,
    required double lat,
    required double lon,
  })  : idFence = Value(idFence),
        lat = Value(lat),
        lon = Value(lon);
  static Insertable<FencePoint> custom({
    Expression<BigInt>? idFencePoint,
    Expression<BigInt>? idFence,
    Expression<double>? lat,
    Expression<double>? lon,
  }) {
    return RawValuesInsertable({
      if (idFencePoint != null) 'id_fence_point': idFencePoint,
      if (idFence != null) 'id_fence': idFence,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
    });
  }

  FencePointsCompanion copyWith(
      {Value<BigInt>? idFencePoint,
      Value<BigInt>? idFence,
      Value<double>? lat,
      Value<double>? lon}) {
    return FencePointsCompanion(
      idFencePoint: idFencePoint ?? this.idFencePoint,
      idFence: idFence ?? this.idFence,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idFencePoint.present) {
      map['id_fence_point'] = Variable<BigInt>(idFencePoint.value);
    }
    if (idFence.present) {
      map['id_fence'] = Variable<BigInt>(idFence.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FencePointsCompanion(')
          ..write('idFencePoint: $idFencePoint, ')
          ..write('idFence: $idFence, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon')
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
  late final GeneratedColumn<BigInt> idAnimal = GeneratedColumn<BigInt>(
      'id_animal', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: false);
  static const VerificationMeta _idUserMeta = const VerificationMeta('idUser');
  @override
  late final GeneratedColumn<BigInt> idUser = GeneratedColumn<BigInt>(
      'id_user', aliasedName, false,
      type: DriftSqlType.bigInt,
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
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id_animal'])!,
      idUser: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id_user'])!,
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
  final BigInt idAnimal;
  final BigInt idUser;
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
    map['id_animal'] = Variable<BigInt>(idAnimal);
    map['id_user'] = Variable<BigInt>(idUser);
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
      idAnimal: serializer.fromJson<BigInt>(json['idAnimal']),
      idUser: serializer.fromJson<BigInt>(json['idUser']),
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
      'idAnimal': serializer.toJson<BigInt>(idAnimal),
      'idUser': serializer.toJson<BigInt>(idUser),
      'animalIdentification': serializer.toJson<String>(animalIdentification),
      'animalName': serializer.toJson<String>(animalName),
      'animalColor': serializer.toJson<String>(animalColor),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  AnimalData copyWith(
          {BigInt? idAnimal,
          BigInt? idUser,
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
  final Value<BigInt> idAnimal;
  final Value<BigInt> idUser;
  final Value<String> animalIdentification;
  final Value<String> animalName;
  final Value<String> animalColor;
  final Value<bool> isActive;
  const AnimalCompanion({
    this.idAnimal = const Value.absent(),
    this.idUser = const Value.absent(),
    this.animalIdentification = const Value.absent(),
    this.animalName = const Value.absent(),
    this.animalColor = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  AnimalCompanion.insert({
    this.idAnimal = const Value.absent(),
    required BigInt idUser,
    required String animalIdentification,
    required String animalName,
    required String animalColor,
    required bool isActive,
  })  : idUser = Value(idUser),
        animalIdentification = Value(animalIdentification),
        animalName = Value(animalName),
        animalColor = Value(animalColor),
        isActive = Value(isActive);
  static Insertable<AnimalData> custom({
    Expression<BigInt>? idAnimal,
    Expression<BigInt>? idUser,
    Expression<String>? animalIdentification,
    Expression<String>? animalName,
    Expression<String>? animalColor,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (idAnimal != null) 'id_animal': idAnimal,
      if (idUser != null) 'id_user': idUser,
      if (animalIdentification != null)
        'animal_identification': animalIdentification,
      if (animalName != null) 'animal_name': animalName,
      if (animalColor != null) 'animal_color': animalColor,
      if (isActive != null) 'is_active': isActive,
    });
  }

  AnimalCompanion copyWith(
      {Value<BigInt>? idAnimal,
      Value<BigInt>? idUser,
      Value<String>? animalIdentification,
      Value<String>? animalName,
      Value<String>? animalColor,
      Value<bool>? isActive}) {
    return AnimalCompanion(
      idAnimal: idAnimal ?? this.idAnimal,
      idUser: idUser ?? this.idUser,
      animalIdentification: animalIdentification ?? this.animalIdentification,
      animalName: animalName ?? this.animalName,
      animalColor: animalColor ?? this.animalColor,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idAnimal.present) {
      map['id_animal'] = Variable<BigInt>(idAnimal.value);
    }
    if (idUser.present) {
      map['id_user'] = Variable<BigInt>(idUser.value);
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
          ..write('isActive: $isActive')
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
  late final GeneratedColumn<BigInt> idFence = GeneratedColumn<BigInt>(
      'id_fence', aliasedName, false,
      type: DriftSqlType.bigInt,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES fence (id_fence)'));
  static const VerificationMeta _idAnimalMeta =
      const VerificationMeta('idAnimal');
  @override
  late final GeneratedColumn<BigInt> idAnimal = GeneratedColumn<BigInt>(
      'id_animal', aliasedName, false,
      type: DriftSqlType.bigInt,
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
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id_fence'])!,
      idAnimal: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id_animal'])!,
    );
  }

  @override
  $FenceAnimalsTable createAlias(String alias) {
    return $FenceAnimalsTable(attachedDatabase, alias);
  }
}

class FenceAnimal extends DataClass implements Insertable<FenceAnimal> {
  final BigInt idFence;
  final BigInt idAnimal;
  const FenceAnimal({required this.idFence, required this.idAnimal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_fence'] = Variable<BigInt>(idFence);
    map['id_animal'] = Variable<BigInt>(idAnimal);
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
      idFence: serializer.fromJson<BigInt>(json['idFence']),
      idAnimal: serializer.fromJson<BigInt>(json['idAnimal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idFence': serializer.toJson<BigInt>(idFence),
      'idAnimal': serializer.toJson<BigInt>(idAnimal),
    };
  }

  FenceAnimal copyWith({BigInt? idFence, BigInt? idAnimal}) => FenceAnimal(
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
  final Value<BigInt> idFence;
  final Value<BigInt> idAnimal;
  final Value<int> rowid;
  const FenceAnimalsCompanion({
    this.idFence = const Value.absent(),
    this.idAnimal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FenceAnimalsCompanion.insert({
    required BigInt idFence,
    required BigInt idAnimal,
    this.rowid = const Value.absent(),
  })  : idFence = Value(idFence),
        idAnimal = Value(idAnimal);
  static Insertable<FenceAnimal> custom({
    Expression<BigInt>? idFence,
    Expression<BigInt>? idAnimal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idFence != null) 'id_fence': idFence,
      if (idAnimal != null) 'id_animal': idAnimal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FenceAnimalsCompanion copyWith(
      {Value<BigInt>? idFence, Value<BigInt>? idAnimal, Value<int>? rowid}) {
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
      map['id_fence'] = Variable<BigInt>(idFence.value);
    }
    if (idAnimal.present) {
      map['id_animal'] = Variable<BigInt>(idAnimal.value);
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
  late final GeneratedColumn<BigInt> animalDataId = GeneratedColumn<BigInt>(
      'animal_data_id', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: false);
  static const VerificationMeta _idAnimalMeta =
      const VerificationMeta('idAnimal');
  @override
  late final GeneratedColumn<BigInt> idAnimal = GeneratedColumn<BigInt>(
      'id_animal', aliasedName, true,
      type: DriftSqlType.bigInt,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES animal (id_animal)'));
  static const VerificationMeta _dataUsageMeta =
      const VerificationMeta('dataUsage');
  @override
  late final GeneratedColumn<int> dataUsage = GeneratedColumn<int>(
      'data_usage', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
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
        dataUsage,
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
    }
    if (data.containsKey('id_animal')) {
      context.handle(_idAnimalMeta,
          idAnimal.isAcceptableOrUnknown(data['id_animal']!, _idAnimalMeta));
    }
    if (data.containsKey('data_usage')) {
      context.handle(_dataUsageMeta,
          dataUsage.isAcceptableOrUnknown(data['data_usage']!, _dataUsageMeta));
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
          .read(DriftSqlType.bigInt, data['${effectivePrefix}animal_data_id'])!,
      idAnimal: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id_animal']),
      dataUsage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}data_usage']),
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
  final BigInt animalDataId;
  final BigInt? idAnimal;
  final int? dataUsage;
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
      this.dataUsage,
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
    map['animal_data_id'] = Variable<BigInt>(animalDataId);
    if (!nullToAbsent || idAnimal != null) {
      map['id_animal'] = Variable<BigInt>(idAnimal);
    }
    if (!nullToAbsent || dataUsage != null) {
      map['data_usage'] = Variable<int>(dataUsage);
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
      dataUsage: dataUsage == null && nullToAbsent
          ? const Value.absent()
          : Value(dataUsage),
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
      animalDataId: serializer.fromJson<BigInt>(json['animalDataId']),
      idAnimal: serializer.fromJson<BigInt?>(json['idAnimal']),
      dataUsage: serializer.fromJson<int?>(json['dataUsage']),
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
      'animalDataId': serializer.toJson<BigInt>(animalDataId),
      'idAnimal': serializer.toJson<BigInt?>(idAnimal),
      'dataUsage': serializer.toJson<int?>(dataUsage),
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
          {BigInt? animalDataId,
          Value<BigInt?> idAnimal = const Value.absent(),
          Value<int?> dataUsage = const Value.absent(),
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
        dataUsage: dataUsage.present ? dataUsage.value : this.dataUsage,
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
          ..write('dataUsage: $dataUsage, ')
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
  int get hashCode => Object.hash(animalDataId, idAnimal, dataUsage,
      temperature, battery, lat, lon, elevation, accuracy, date, state);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalLocation &&
          other.animalDataId == this.animalDataId &&
          other.idAnimal == this.idAnimal &&
          other.dataUsage == this.dataUsage &&
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
  final Value<BigInt> animalDataId;
  final Value<BigInt?> idAnimal;
  final Value<int?> dataUsage;
  final Value<double?> temperature;
  final Value<int?> battery;
  final Value<double?> lat;
  final Value<double?> lon;
  final Value<double?> elevation;
  final Value<double?> accuracy;
  final Value<DateTime> date;
  final Value<String?> state;
  const AnimalLocationsCompanion({
    this.animalDataId = const Value.absent(),
    this.idAnimal = const Value.absent(),
    this.dataUsage = const Value.absent(),
    this.temperature = const Value.absent(),
    this.battery = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.elevation = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.date = const Value.absent(),
    this.state = const Value.absent(),
  });
  AnimalLocationsCompanion.insert({
    this.animalDataId = const Value.absent(),
    this.idAnimal = const Value.absent(),
    this.dataUsage = const Value.absent(),
    this.temperature = const Value.absent(),
    this.battery = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.elevation = const Value.absent(),
    this.accuracy = const Value.absent(),
    required DateTime date,
    this.state = const Value.absent(),
  }) : date = Value(date);
  static Insertable<AnimalLocation> custom({
    Expression<BigInt>? animalDataId,
    Expression<BigInt>? idAnimal,
    Expression<int>? dataUsage,
    Expression<double>? temperature,
    Expression<int>? battery,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<double>? elevation,
    Expression<double>? accuracy,
    Expression<DateTime>? date,
    Expression<String>? state,
  }) {
    return RawValuesInsertable({
      if (animalDataId != null) 'animal_data_id': animalDataId,
      if (idAnimal != null) 'id_animal': idAnimal,
      if (dataUsage != null) 'data_usage': dataUsage,
      if (temperature != null) 'temperature': temperature,
      if (battery != null) 'battery': battery,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (elevation != null) 'elevation': elevation,
      if (accuracy != null) 'accuracy': accuracy,
      if (date != null) 'date': date,
      if (state != null) 'state': state,
    });
  }

  AnimalLocationsCompanion copyWith(
      {Value<BigInt>? animalDataId,
      Value<BigInt?>? idAnimal,
      Value<int?>? dataUsage,
      Value<double?>? temperature,
      Value<int?>? battery,
      Value<double?>? lat,
      Value<double?>? lon,
      Value<double?>? elevation,
      Value<double?>? accuracy,
      Value<DateTime>? date,
      Value<String?>? state}) {
    return AnimalLocationsCompanion(
      animalDataId: animalDataId ?? this.animalDataId,
      idAnimal: idAnimal ?? this.idAnimal,
      dataUsage: dataUsage ?? this.dataUsage,
      temperature: temperature ?? this.temperature,
      battery: battery ?? this.battery,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      elevation: elevation ?? this.elevation,
      accuracy: accuracy ?? this.accuracy,
      date: date ?? this.date,
      state: state ?? this.state,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (animalDataId.present) {
      map['animal_data_id'] = Variable<BigInt>(animalDataId.value);
    }
    if (idAnimal.present) {
      map['id_animal'] = Variable<BigInt>(idAnimal.value);
    }
    if (dataUsage.present) {
      map['data_usage'] = Variable<int>(dataUsage.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalLocationsCompanion(')
          ..write('animalDataId: $animalDataId, ')
          ..write('idAnimal: $idAnimal, ')
          ..write('dataUsage: $dataUsage, ')
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
  late final GeneratedColumn<BigInt> idAlert = GeneratedColumn<BigInt>(
      'id_alert', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: false);
  static const VerificationMeta _hasNotificationMeta =
      const VerificationMeta('hasNotification');
  @override
  late final GeneratedColumn<bool> hasNotification = GeneratedColumn<bool>(
      'has_notification', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_notification" IN (0, 1))'));
  static const VerificationMeta _parameterMeta =
      const VerificationMeta('parameter');
  @override
  late final GeneratedColumn<String> parameter = GeneratedColumn<String>(
      'parameter', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _comparissonMeta =
      const VerificationMeta('comparisson');
  @override
  late final GeneratedColumn<String> comparisson = GeneratedColumn<String>(
      'comparisson', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
      'value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [idAlert, hasNotification, parameter, comparisson, value];
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
    }
    if (data.containsKey('has_notification')) {
      context.handle(
          _hasNotificationMeta,
          hasNotification.isAcceptableOrUnknown(
              data['has_notification']!, _hasNotificationMeta));
    } else if (isInserting) {
      context.missing(_hasNotificationMeta);
    }
    if (data.containsKey('parameter')) {
      context.handle(_parameterMeta,
          parameter.isAcceptableOrUnknown(data['parameter']!, _parameterMeta));
    } else if (isInserting) {
      context.missing(_parameterMeta);
    }
    if (data.containsKey('comparisson')) {
      context.handle(
          _comparissonMeta,
          comparisson.isAcceptableOrUnknown(
              data['comparisson']!, _comparissonMeta));
    } else if (isInserting) {
      context.missing(_comparissonMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
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
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id_alert'])!,
      hasNotification: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_notification'])!,
      parameter: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parameter'])!,
      comparisson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comparisson'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $UserAlertTable createAlias(String alias) {
    return $UserAlertTable(attachedDatabase, alias);
  }
}

class UserAlertData extends DataClass implements Insertable<UserAlertData> {
  final BigInt idAlert;
  final bool hasNotification;
  final String parameter;
  final String comparisson;
  final double value;
  const UserAlertData(
      {required this.idAlert,
      required this.hasNotification,
      required this.parameter,
      required this.comparisson,
      required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_alert'] = Variable<BigInt>(idAlert);
    map['has_notification'] = Variable<bool>(hasNotification);
    map['parameter'] = Variable<String>(parameter);
    map['comparisson'] = Variable<String>(comparisson);
    map['value'] = Variable<double>(value);
    return map;
  }

  UserAlertCompanion toCompanion(bool nullToAbsent) {
    return UserAlertCompanion(
      idAlert: Value(idAlert),
      hasNotification: Value(hasNotification),
      parameter: Value(parameter),
      comparisson: Value(comparisson),
      value: Value(value),
    );
  }

  factory UserAlertData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserAlertData(
      idAlert: serializer.fromJson<BigInt>(json['idAlert']),
      hasNotification: serializer.fromJson<bool>(json['hasNotification']),
      parameter: serializer.fromJson<String>(json['parameter']),
      comparisson: serializer.fromJson<String>(json['comparisson']),
      value: serializer.fromJson<double>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idAlert': serializer.toJson<BigInt>(idAlert),
      'hasNotification': serializer.toJson<bool>(hasNotification),
      'parameter': serializer.toJson<String>(parameter),
      'comparisson': serializer.toJson<String>(comparisson),
      'value': serializer.toJson<double>(value),
    };
  }

  UserAlertData copyWith(
          {BigInt? idAlert,
          bool? hasNotification,
          String? parameter,
          String? comparisson,
          double? value}) =>
      UserAlertData(
        idAlert: idAlert ?? this.idAlert,
        hasNotification: hasNotification ?? this.hasNotification,
        parameter: parameter ?? this.parameter,
        comparisson: comparisson ?? this.comparisson,
        value: value ?? this.value,
      );
  @override
  String toString() {
    return (StringBuffer('UserAlertData(')
          ..write('idAlert: $idAlert, ')
          ..write('hasNotification: $hasNotification, ')
          ..write('parameter: $parameter, ')
          ..write('comparisson: $comparisson, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(idAlert, hasNotification, parameter, comparisson, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserAlertData &&
          other.idAlert == this.idAlert &&
          other.hasNotification == this.hasNotification &&
          other.parameter == this.parameter &&
          other.comparisson == this.comparisson &&
          other.value == this.value);
}

class UserAlertCompanion extends UpdateCompanion<UserAlertData> {
  final Value<BigInt> idAlert;
  final Value<bool> hasNotification;
  final Value<String> parameter;
  final Value<String> comparisson;
  final Value<double> value;
  const UserAlertCompanion({
    this.idAlert = const Value.absent(),
    this.hasNotification = const Value.absent(),
    this.parameter = const Value.absent(),
    this.comparisson = const Value.absent(),
    this.value = const Value.absent(),
  });
  UserAlertCompanion.insert({
    this.idAlert = const Value.absent(),
    required bool hasNotification,
    required String parameter,
    required String comparisson,
    required double value,
  })  : hasNotification = Value(hasNotification),
        parameter = Value(parameter),
        comparisson = Value(comparisson),
        value = Value(value);
  static Insertable<UserAlertData> custom({
    Expression<BigInt>? idAlert,
    Expression<bool>? hasNotification,
    Expression<String>? parameter,
    Expression<String>? comparisson,
    Expression<double>? value,
  }) {
    return RawValuesInsertable({
      if (idAlert != null) 'id_alert': idAlert,
      if (hasNotification != null) 'has_notification': hasNotification,
      if (parameter != null) 'parameter': parameter,
      if (comparisson != null) 'comparisson': comparisson,
      if (value != null) 'value': value,
    });
  }

  UserAlertCompanion copyWith(
      {Value<BigInt>? idAlert,
      Value<bool>? hasNotification,
      Value<String>? parameter,
      Value<String>? comparisson,
      Value<double>? value}) {
    return UserAlertCompanion(
      idAlert: idAlert ?? this.idAlert,
      hasNotification: hasNotification ?? this.hasNotification,
      parameter: parameter ?? this.parameter,
      comparisson: comparisson ?? this.comparisson,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idAlert.present) {
      map['id_alert'] = Variable<BigInt>(idAlert.value);
    }
    if (hasNotification.present) {
      map['has_notification'] = Variable<bool>(hasNotification.value);
    }
    if (parameter.present) {
      map['parameter'] = Variable<String>(parameter.value);
    }
    if (comparisson.present) {
      map['comparisson'] = Variable<String>(comparisson.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserAlertCompanion(')
          ..write('idAlert: $idAlert, ')
          ..write('hasNotification: $hasNotification, ')
          ..write('parameter: $parameter, ')
          ..write('comparisson: $comparisson, ')
          ..write('value: $value')
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
  late final GeneratedColumn<BigInt> idNotification = GeneratedColumn<BigInt>(
      'id_notification', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: false);
  static const VerificationMeta _idAnimalMeta =
      const VerificationMeta('idAnimal');
  @override
  late final GeneratedColumn<BigInt> idAnimal = GeneratedColumn<BigInt>(
      'id_animal', aliasedName, false,
      type: DriftSqlType.bigInt,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES animal (id_animal)'));
  static const VerificationMeta _idAlertMeta =
      const VerificationMeta('idAlert');
  @override
  late final GeneratedColumn<BigInt> idAlert = GeneratedColumn<BigInt>(
      'id_alert', aliasedName, false,
      type: DriftSqlType.bigInt,
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
          DriftSqlType.bigInt, data['${effectivePrefix}id_notification'])!,
      idAnimal: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id_animal'])!,
      idAlert: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id_alert'])!,
    );
  }

  @override
  $AlertNotificationTable createAlias(String alias) {
    return $AlertNotificationTable(attachedDatabase, alias);
  }
}

class AlertNotificationData extends DataClass
    implements Insertable<AlertNotificationData> {
  final BigInt idNotification;
  final BigInt idAnimal;
  final BigInt idAlert;
  const AlertNotificationData(
      {required this.idNotification,
      required this.idAnimal,
      required this.idAlert});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_notification'] = Variable<BigInt>(idNotification);
    map['id_animal'] = Variable<BigInt>(idAnimal);
    map['id_alert'] = Variable<BigInt>(idAlert);
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
      idNotification: serializer.fromJson<BigInt>(json['idNotification']),
      idAnimal: serializer.fromJson<BigInt>(json['idAnimal']),
      idAlert: serializer.fromJson<BigInt>(json['idAlert']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idNotification': serializer.toJson<BigInt>(idNotification),
      'idAnimal': serializer.toJson<BigInt>(idAnimal),
      'idAlert': serializer.toJson<BigInt>(idAlert),
    };
  }

  AlertNotificationData copyWith(
          {BigInt? idNotification, BigInt? idAnimal, BigInt? idAlert}) =>
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
  final Value<BigInt> idNotification;
  final Value<BigInt> idAnimal;
  final Value<BigInt> idAlert;
  const AlertNotificationCompanion({
    this.idNotification = const Value.absent(),
    this.idAnimal = const Value.absent(),
    this.idAlert = const Value.absent(),
  });
  AlertNotificationCompanion.insert({
    this.idNotification = const Value.absent(),
    required BigInt idAnimal,
    required BigInt idAlert,
  })  : idAnimal = Value(idAnimal),
        idAlert = Value(idAlert);
  static Insertable<AlertNotificationData> custom({
    Expression<BigInt>? idNotification,
    Expression<BigInt>? idAnimal,
    Expression<BigInt>? idAlert,
  }) {
    return RawValuesInsertable({
      if (idNotification != null) 'id_notification': idNotification,
      if (idAnimal != null) 'id_animal': idAnimal,
      if (idAlert != null) 'id_alert': idAlert,
    });
  }

  AlertNotificationCompanion copyWith(
      {Value<BigInt>? idNotification,
      Value<BigInt>? idAnimal,
      Value<BigInt>? idAlert}) {
    return AlertNotificationCompanion(
      idNotification: idNotification ?? this.idNotification,
      idAnimal: idAnimal ?? this.idAnimal,
      idAlert: idAlert ?? this.idAlert,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idNotification.present) {
      map['id_notification'] = Variable<BigInt>(idNotification.value);
    }
    if (idAnimal.present) {
      map['id_animal'] = Variable<BigInt>(idAnimal.value);
    }
    if (idAlert.present) {
      map['id_alert'] = Variable<BigInt>(idAlert.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertNotificationCompanion(')
          ..write('idNotification: $idNotification, ')
          ..write('idAnimal: $idAnimal, ')
          ..write('idAlert: $idAlert')
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
  late final GeneratedColumn<BigInt> idAnimal = GeneratedColumn<BigInt>(
      'id_animal', aliasedName, false,
      type: DriftSqlType.bigInt,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES animal (id_animal)'));
  static const VerificationMeta _idAlertMeta =
      const VerificationMeta('idAlert');
  @override
  late final GeneratedColumn<BigInt> idAlert = GeneratedColumn<BigInt>(
      'id_alert', aliasedName, false,
      type: DriftSqlType.bigInt,
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
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id_animal'])!,
      idAlert: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id_alert'])!,
    );
  }

  @override
  $AlertAnimalsTable createAlias(String alias) {
    return $AlertAnimalsTable(attachedDatabase, alias);
  }
}

class AlertAnimal extends DataClass implements Insertable<AlertAnimal> {
  final BigInt idAnimal;
  final BigInt idAlert;
  const AlertAnimal({required this.idAnimal, required this.idAlert});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_animal'] = Variable<BigInt>(idAnimal);
    map['id_alert'] = Variable<BigInt>(idAlert);
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
      idAnimal: serializer.fromJson<BigInt>(json['idAnimal']),
      idAlert: serializer.fromJson<BigInt>(json['idAlert']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idAnimal': serializer.toJson<BigInt>(idAnimal),
      'idAlert': serializer.toJson<BigInt>(idAlert),
    };
  }

  AlertAnimal copyWith({BigInt? idAnimal, BigInt? idAlert}) => AlertAnimal(
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
  final Value<BigInt> idAnimal;
  final Value<BigInt> idAlert;
  final Value<int> rowid;
  const AlertAnimalsCompanion({
    this.idAnimal = const Value.absent(),
    this.idAlert = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertAnimalsCompanion.insert({
    required BigInt idAnimal,
    required BigInt idAlert,
    this.rowid = const Value.absent(),
  })  : idAnimal = Value(idAnimal),
        idAlert = Value(idAlert);
  static Insertable<AlertAnimal> custom({
    Expression<BigInt>? idAnimal,
    Expression<BigInt>? idAlert,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idAnimal != null) 'id_animal': idAnimal,
      if (idAlert != null) 'id_alert': idAlert,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertAnimalsCompanion copyWith(
      {Value<BigInt>? idAnimal, Value<BigInt>? idAlert, Value<int>? rowid}) {
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
      map['id_animal'] = Variable<BigInt>(idAnimal.value);
    }
    if (idAlert.present) {
      map['id_alert'] = Variable<BigInt>(idAlert.value);
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
        userAlert,
        alertNotification,
        alertAnimals
      ];
}
