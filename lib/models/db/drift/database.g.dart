// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UserTable extends User with TableInfo<$UserTable, UserData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
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
  static const VerificationMeta _isAdminMeta =
      const VerificationMeta('isAdmin');
  @override
  late final GeneratedColumn<bool> isAdmin = GeneratedColumn<bool>(
      'is_admin', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_admin" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [uid, name, email, phone, isAdmin];
  @override
  String get aliasedName => _alias ?? 'user';
  @override
  String get actualTableName => 'user';
  @override
  VerificationContext validateIntegrity(Insertable<UserData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
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
    if (data.containsKey('is_admin')) {
      context.handle(_isAdminMeta,
          isAdmin.isAcceptableOrUnknown(data['is_admin']!, _isAdminMeta));
    } else if (isInserting) {
      context.missing(_isAdminMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  UserData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserData(
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}phone'])!,
      isAdmin: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_admin'])!,
    );
  }

  @override
  $UserTable createAlias(String alias) {
    return $UserTable(attachedDatabase, alias);
  }
}

class UserData extends DataClass implements Insertable<UserData> {
  final String uid;
  final String name;
  final String email;
  final int phone;
  final bool isAdmin;
  const UserData(
      {required this.uid,
      required this.name,
      required this.email,
      required this.phone,
      required this.isAdmin});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['phone'] = Variable<int>(phone);
    map['is_admin'] = Variable<bool>(isAdmin);
    return map;
  }

  UserCompanion toCompanion(bool nullToAbsent) {
    return UserCompanion(
      uid: Value(uid),
      name: Value(name),
      email: Value(email),
      phone: Value(phone),
      isAdmin: Value(isAdmin),
    );
  }

  factory UserData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserData(
      uid: serializer.fromJson<String>(json['uid']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      phone: serializer.fromJson<int>(json['phone']),
      isAdmin: serializer.fromJson<bool>(json['isAdmin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'phone': serializer.toJson<int>(phone),
      'isAdmin': serializer.toJson<bool>(isAdmin),
    };
  }

  UserData copyWith(
          {String? uid,
          String? name,
          String? email,
          int? phone,
          bool? isAdmin}) =>
      UserData(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        isAdmin: isAdmin ?? this.isAdmin,
      );
  @override
  String toString() {
    return (StringBuffer('UserData(')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('isAdmin: $isAdmin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uid, name, email, phone, isAdmin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserData &&
          other.uid == this.uid &&
          other.name == this.name &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.isAdmin == this.isAdmin);
}

class UserCompanion extends UpdateCompanion<UserData> {
  final Value<String> uid;
  final Value<String> name;
  final Value<String> email;
  final Value<int> phone;
  final Value<bool> isAdmin;
  final Value<int> rowid;
  const UserCompanion({
    this.uid = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.isAdmin = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserCompanion.insert({
    required String uid,
    required String name,
    required String email,
    required int phone,
    required bool isAdmin,
    this.rowid = const Value.absent(),
  })  : uid = Value(uid),
        name = Value(name),
        email = Value(email),
        phone = Value(phone),
        isAdmin = Value(isAdmin);
  static Insertable<UserData> custom({
    Expression<String>? uid,
    Expression<String>? name,
    Expression<String>? email,
    Expression<int>? phone,
    Expression<bool>? isAdmin,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (isAdmin != null) 'is_admin': isAdmin,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserCompanion copyWith(
      {Value<String>? uid,
      Value<String>? name,
      Value<String>? email,
      Value<int>? phone,
      Value<bool>? isAdmin,
      Value<int>? rowid}) {
    return UserCompanion(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isAdmin: isAdmin ?? this.isAdmin,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
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
    if (isAdmin.present) {
      map['is_admin'] = Variable<bool>(isAdmin.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCompanion(')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('isAdmin: $isAdmin, ')
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
  static const VerificationMeta _fenceIdMeta =
      const VerificationMeta('fenceId');
  @override
  late final GeneratedColumn<String> fenceId = GeneratedColumn<String>(
      'fence_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  List<GeneratedColumn> get $columns => [fenceId, name, color];
  @override
  String get aliasedName => _alias ?? 'fence';
  @override
  String get actualTableName => 'fence';
  @override
  VerificationContext validateIntegrity(Insertable<FenceData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('fence_id')) {
      context.handle(_fenceIdMeta,
          fenceId.isAcceptableOrUnknown(data['fence_id']!, _fenceIdMeta));
    } else if (isInserting) {
      context.missing(_fenceIdMeta);
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
  Set<GeneratedColumn> get $primaryKey => {fenceId};
  @override
  FenceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FenceData(
      fenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fence_id'])!,
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
  final String fenceId;
  final String name;
  final String color;
  const FenceData(
      {required this.fenceId, required this.name, required this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['fence_id'] = Variable<String>(fenceId);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    return map;
  }

  FenceCompanion toCompanion(bool nullToAbsent) {
    return FenceCompanion(
      fenceId: Value(fenceId),
      name: Value(name),
      color: Value(color),
    );
  }

  factory FenceData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FenceData(
      fenceId: serializer.fromJson<String>(json['fenceId']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fenceId': serializer.toJson<String>(fenceId),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
    };
  }

  FenceData copyWith({String? fenceId, String? name, String? color}) =>
      FenceData(
        fenceId: fenceId ?? this.fenceId,
        name: name ?? this.name,
        color: color ?? this.color,
      );
  @override
  String toString() {
    return (StringBuffer('FenceData(')
          ..write('fenceId: $fenceId, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fenceId, name, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FenceData &&
          other.fenceId == this.fenceId &&
          other.name == this.name &&
          other.color == this.color);
}

class FenceCompanion extends UpdateCompanion<FenceData> {
  final Value<String> fenceId;
  final Value<String> name;
  final Value<String> color;
  final Value<int> rowid;
  const FenceCompanion({
    this.fenceId = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FenceCompanion.insert({
    required String fenceId,
    required String name,
    required String color,
    this.rowid = const Value.absent(),
  })  : fenceId = Value(fenceId),
        name = Value(name),
        color = Value(color);
  static Insertable<FenceData> custom({
    Expression<String>? fenceId,
    Expression<String>? name,
    Expression<String>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fenceId != null) 'fence_id': fenceId,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FenceCompanion copyWith(
      {Value<String>? fenceId,
      Value<String>? name,
      Value<String>? color,
      Value<int>? rowid}) {
    return FenceCompanion(
      fenceId: fenceId ?? this.fenceId,
      name: name ?? this.name,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fenceId.present) {
      map['fence_id'] = Variable<String>(fenceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FenceCompanion(')
          ..write('fenceId: $fenceId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
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
  static const VerificationMeta _fenceIdMeta =
      const VerificationMeta('fenceId');
  @override
  late final GeneratedColumn<String> fenceId = GeneratedColumn<String>(
      'fence_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES fence (fence_id)'));
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
  List<GeneratedColumn> get $columns => [fenceId, lat, lon];
  @override
  String get aliasedName => _alias ?? 'fence_points';
  @override
  String get actualTableName => 'fence_points';
  @override
  VerificationContext validateIntegrity(Insertable<FencePoint> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('fence_id')) {
      context.handle(_fenceIdMeta,
          fenceId.isAcceptableOrUnknown(data['fence_id']!, _fenceIdMeta));
    } else if (isInserting) {
      context.missing(_fenceIdMeta);
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
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  FencePoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FencePoint(
      fenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fence_id'])!,
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
  final String fenceId;
  final double lat;
  final double lon;
  const FencePoint(
      {required this.fenceId, required this.lat, required this.lon});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['fence_id'] = Variable<String>(fenceId);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    return map;
  }

  FencePointsCompanion toCompanion(bool nullToAbsent) {
    return FencePointsCompanion(
      fenceId: Value(fenceId),
      lat: Value(lat),
      lon: Value(lon),
    );
  }

  factory FencePoint.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FencePoint(
      fenceId: serializer.fromJson<String>(json['fenceId']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fenceId': serializer.toJson<String>(fenceId),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
    };
  }

  FencePoint copyWith({String? fenceId, double? lat, double? lon}) =>
      FencePoint(
        fenceId: fenceId ?? this.fenceId,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
      );
  @override
  String toString() {
    return (StringBuffer('FencePoint(')
          ..write('fenceId: $fenceId, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fenceId, lat, lon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FencePoint &&
          other.fenceId == this.fenceId &&
          other.lat == this.lat &&
          other.lon == this.lon);
}

class FencePointsCompanion extends UpdateCompanion<FencePoint> {
  final Value<String> fenceId;
  final Value<double> lat;
  final Value<double> lon;
  final Value<int> rowid;
  const FencePointsCompanion({
    this.fenceId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FencePointsCompanion.insert({
    required String fenceId,
    required double lat,
    required double lon,
    this.rowid = const Value.absent(),
  })  : fenceId = Value(fenceId),
        lat = Value(lat),
        lon = Value(lon);
  static Insertable<FencePoint> custom({
    Expression<String>? fenceId,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fenceId != null) 'fence_id': fenceId,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FencePointsCompanion copyWith(
      {Value<String>? fenceId,
      Value<double>? lat,
      Value<double>? lon,
      Value<int>? rowid}) {
    return FencePointsCompanion(
      fenceId: fenceId ?? this.fenceId,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fenceId.present) {
      map['fence_id'] = Variable<String>(fenceId.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FencePointsCompanion(')
          ..write('fenceId: $fenceId, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceTable extends Device with TableInfo<$DeviceTable, DeviceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES user (uid)'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imeiMeta = const VerificationMeta('imei');
  @override
  late final GeneratedColumn<String> imei = GeneratedColumn<String>(
      'imei', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
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
      [uid, deviceId, imei, color, name, isActive];
  @override
  String get aliasedName => _alias ?? 'device';
  @override
  String get actualTableName => 'device';
  @override
  VerificationContext validateIntegrity(Insertable<DeviceData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('imei')) {
      context.handle(
          _imeiMeta, imei.isAcceptableOrUnknown(data['imei']!, _imeiMeta));
    } else if (isInserting) {
      context.missing(_imeiMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
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
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  DeviceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceData(
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      imei: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}imei'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $DeviceTable createAlias(String alias) {
    return $DeviceTable(attachedDatabase, alias);
  }
}

class DeviceData extends DataClass implements Insertable<DeviceData> {
  final String uid;
  final String deviceId;
  final String imei;
  final String color;
  final String name;
  final bool isActive;
  const DeviceData(
      {required this.uid,
      required this.deviceId,
      required this.imei,
      required this.color,
      required this.name,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    map['device_id'] = Variable<String>(deviceId);
    map['imei'] = Variable<String>(imei);
    map['color'] = Variable<String>(color);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  DeviceCompanion toCompanion(bool nullToAbsent) {
    return DeviceCompanion(
      uid: Value(uid),
      deviceId: Value(deviceId),
      imei: Value(imei),
      color: Value(color),
      name: Value(name),
      isActive: Value(isActive),
    );
  }

  factory DeviceData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceData(
      uid: serializer.fromJson<String>(json['uid']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      imei: serializer.fromJson<String>(json['imei']),
      color: serializer.fromJson<String>(json['color']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'deviceId': serializer.toJson<String>(deviceId),
      'imei': serializer.toJson<String>(imei),
      'color': serializer.toJson<String>(color),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  DeviceData copyWith(
          {String? uid,
          String? deviceId,
          String? imei,
          String? color,
          String? name,
          bool? isActive}) =>
      DeviceData(
        uid: uid ?? this.uid,
        deviceId: deviceId ?? this.deviceId,
        imei: imei ?? this.imei,
        color: color ?? this.color,
        name: name ?? this.name,
        isActive: isActive ?? this.isActive,
      );
  @override
  String toString() {
    return (StringBuffer('DeviceData(')
          ..write('uid: $uid, ')
          ..write('deviceId: $deviceId, ')
          ..write('imei: $imei, ')
          ..write('color: $color, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uid, deviceId, imei, color, name, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceData &&
          other.uid == this.uid &&
          other.deviceId == this.deviceId &&
          other.imei == this.imei &&
          other.color == this.color &&
          other.name == this.name &&
          other.isActive == this.isActive);
}

class DeviceCompanion extends UpdateCompanion<DeviceData> {
  final Value<String> uid;
  final Value<String> deviceId;
  final Value<String> imei;
  final Value<String> color;
  final Value<String> name;
  final Value<bool> isActive;
  final Value<int> rowid;
  const DeviceCompanion({
    this.uid = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.imei = const Value.absent(),
    this.color = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceCompanion.insert({
    required String uid,
    required String deviceId,
    required String imei,
    required String color,
    required String name,
    required bool isActive,
    this.rowid = const Value.absent(),
  })  : uid = Value(uid),
        deviceId = Value(deviceId),
        imei = Value(imei),
        color = Value(color),
        name = Value(name),
        isActive = Value(isActive);
  static Insertable<DeviceData> custom({
    Expression<String>? uid,
    Expression<String>? deviceId,
    Expression<String>? imei,
    Expression<String>? color,
    Expression<String>? name,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (deviceId != null) 'device_id': deviceId,
      if (imei != null) 'imei': imei,
      if (color != null) 'color': color,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceCompanion copyWith(
      {Value<String>? uid,
      Value<String>? deviceId,
      Value<String>? imei,
      Value<String>? color,
      Value<String>? name,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return DeviceCompanion(
      uid: uid ?? this.uid,
      deviceId: deviceId ?? this.deviceId,
      imei: imei ?? this.imei,
      color: color ?? this.color,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (imei.present) {
      map['imei'] = Variable<String>(imei.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
    return (StringBuffer('DeviceCompanion(')
          ..write('uid: $uid, ')
          ..write('deviceId: $deviceId, ')
          ..write('imei: $imei, ')
          ..write('color: $color, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FenceDevicesTable extends FenceDevices
    with TableInfo<$FenceDevicesTable, FenceDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FenceDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fenceIdMeta =
      const VerificationMeta('fenceId');
  @override
  late final GeneratedColumn<String> fenceId = GeneratedColumn<String>(
      'fence_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES fence (fence_id)'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES device (device_id)'));
  @override
  List<GeneratedColumn> get $columns => [fenceId, deviceId];
  @override
  String get aliasedName => _alias ?? 'fence_devices';
  @override
  String get actualTableName => 'fence_devices';
  @override
  VerificationContext validateIntegrity(Insertable<FenceDevice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('fence_id')) {
      context.handle(_fenceIdMeta,
          fenceId.isAcceptableOrUnknown(data['fence_id']!, _fenceIdMeta));
    } else if (isInserting) {
      context.missing(_fenceIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fenceId, deviceId};
  @override
  FenceDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FenceDevice(
      fenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fence_id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
    );
  }

  @override
  $FenceDevicesTable createAlias(String alias) {
    return $FenceDevicesTable(attachedDatabase, alias);
  }
}

class FenceDevice extends DataClass implements Insertable<FenceDevice> {
  final String fenceId;
  final String deviceId;
  const FenceDevice({required this.fenceId, required this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['fence_id'] = Variable<String>(fenceId);
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  FenceDevicesCompanion toCompanion(bool nullToAbsent) {
    return FenceDevicesCompanion(
      fenceId: Value(fenceId),
      deviceId: Value(deviceId),
    );
  }

  factory FenceDevice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FenceDevice(
      fenceId: serializer.fromJson<String>(json['fenceId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fenceId': serializer.toJson<String>(fenceId),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  FenceDevice copyWith({String? fenceId, String? deviceId}) => FenceDevice(
        fenceId: fenceId ?? this.fenceId,
        deviceId: deviceId ?? this.deviceId,
      );
  @override
  String toString() {
    return (StringBuffer('FenceDevice(')
          ..write('fenceId: $fenceId, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fenceId, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FenceDevice &&
          other.fenceId == this.fenceId &&
          other.deviceId == this.deviceId);
}

class FenceDevicesCompanion extends UpdateCompanion<FenceDevice> {
  final Value<String> fenceId;
  final Value<String> deviceId;
  final Value<int> rowid;
  const FenceDevicesCompanion({
    this.fenceId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FenceDevicesCompanion.insert({
    required String fenceId,
    required String deviceId,
    this.rowid = const Value.absent(),
  })  : fenceId = Value(fenceId),
        deviceId = Value(deviceId);
  static Insertable<FenceDevice> custom({
    Expression<String>? fenceId,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fenceId != null) 'fence_id': fenceId,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FenceDevicesCompanion copyWith(
      {Value<String>? fenceId, Value<String>? deviceId, Value<int>? rowid}) {
    return FenceDevicesCompanion(
      fenceId: fenceId ?? this.fenceId,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fenceId.present) {
      map['fence_id'] = Variable<String>(fenceId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FenceDevicesCompanion(')
          ..write('fenceId: $fenceId, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceLocationsTable extends DeviceLocations
    with TableInfo<$DeviceLocationsTable, DeviceLocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceDataIdMeta =
      const VerificationMeta('deviceDataId');
  @override
  late final GeneratedColumn<String> deviceDataId = GeneratedColumn<String>(
      'device_data_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES device (device_id)'));
  static const VerificationMeta _dataUsageMeta =
      const VerificationMeta('dataUsage');
  @override
  late final GeneratedColumn<int> dataUsage = GeneratedColumn<int>(
      'data_usage', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _temperatureMeta =
      const VerificationMeta('temperature');
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
      'temperature', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _batteryMeta =
      const VerificationMeta('battery');
  @override
  late final GeneratedColumn<int> battery = GeneratedColumn<int>(
      'battery', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
  static const VerificationMeta _elevationMeta =
      const VerificationMeta('elevation');
  @override
  late final GeneratedColumn<double> elevation = GeneratedColumn<double>(
      'elevation', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _accuracyMeta =
      const VerificationMeta('accuracy');
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
      'accuracy', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        deviceDataId,
        deviceId,
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
  String get aliasedName => _alias ?? 'device_locations';
  @override
  String get actualTableName => 'device_locations';
  @override
  VerificationContext validateIntegrity(Insertable<DeviceLocation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_data_id')) {
      context.handle(
          _deviceDataIdMeta,
          deviceDataId.isAcceptableOrUnknown(
              data['device_data_id']!, _deviceDataIdMeta));
    } else if (isInserting) {
      context.missing(_deviceDataIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('data_usage')) {
      context.handle(_dataUsageMeta,
          dataUsage.isAcceptableOrUnknown(data['data_usage']!, _dataUsageMeta));
    } else if (isInserting) {
      context.missing(_dataUsageMeta);
    }
    if (data.containsKey('temperature')) {
      context.handle(
          _temperatureMeta,
          temperature.isAcceptableOrUnknown(
              data['temperature']!, _temperatureMeta));
    } else if (isInserting) {
      context.missing(_temperatureMeta);
    }
    if (data.containsKey('battery')) {
      context.handle(_batteryMeta,
          battery.isAcceptableOrUnknown(data['battery']!, _batteryMeta));
    } else if (isInserting) {
      context.missing(_batteryMeta);
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
    if (data.containsKey('elevation')) {
      context.handle(_elevationMeta,
          elevation.isAcceptableOrUnknown(data['elevation']!, _elevationMeta));
    } else if (isInserting) {
      context.missing(_elevationMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(_accuracyMeta,
          accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta));
    } else if (isInserting) {
      context.missing(_accuracyMeta);
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
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceDataId};
  @override
  DeviceLocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceLocation(
      deviceDataId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_data_id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      dataUsage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}data_usage'])!,
      temperature: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}temperature'])!,
      battery: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}battery'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lon: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lon'])!,
      elevation: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}elevation'])!,
      accuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accuracy'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
    );
  }

  @override
  $DeviceLocationsTable createAlias(String alias) {
    return $DeviceLocationsTable(attachedDatabase, alias);
  }
}

class DeviceLocation extends DataClass implements Insertable<DeviceLocation> {
  final String deviceDataId;
  final String deviceId;
  final int dataUsage;
  final double temperature;
  final int battery;
  final double lat;
  final double lon;
  final double elevation;
  final double accuracy;
  final DateTime date;
  final String state;
  const DeviceLocation(
      {required this.deviceDataId,
      required this.deviceId,
      required this.dataUsage,
      required this.temperature,
      required this.battery,
      required this.lat,
      required this.lon,
      required this.elevation,
      required this.accuracy,
      required this.date,
      required this.state});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_data_id'] = Variable<String>(deviceDataId);
    map['device_id'] = Variable<String>(deviceId);
    map['data_usage'] = Variable<int>(dataUsage);
    map['temperature'] = Variable<double>(temperature);
    map['battery'] = Variable<int>(battery);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    map['elevation'] = Variable<double>(elevation);
    map['accuracy'] = Variable<double>(accuracy);
    map['date'] = Variable<DateTime>(date);
    map['state'] = Variable<String>(state);
    return map;
  }

  DeviceLocationsCompanion toCompanion(bool nullToAbsent) {
    return DeviceLocationsCompanion(
      deviceDataId: Value(deviceDataId),
      deviceId: Value(deviceId),
      dataUsage: Value(dataUsage),
      temperature: Value(temperature),
      battery: Value(battery),
      lat: Value(lat),
      lon: Value(lon),
      elevation: Value(elevation),
      accuracy: Value(accuracy),
      date: Value(date),
      state: Value(state),
    );
  }

  factory DeviceLocation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceLocation(
      deviceDataId: serializer.fromJson<String>(json['deviceDataId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      dataUsage: serializer.fromJson<int>(json['dataUsage']),
      temperature: serializer.fromJson<double>(json['temperature']),
      battery: serializer.fromJson<int>(json['battery']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      elevation: serializer.fromJson<double>(json['elevation']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      date: serializer.fromJson<DateTime>(json['date']),
      state: serializer.fromJson<String>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceDataId': serializer.toJson<String>(deviceDataId),
      'deviceId': serializer.toJson<String>(deviceId),
      'dataUsage': serializer.toJson<int>(dataUsage),
      'temperature': serializer.toJson<double>(temperature),
      'battery': serializer.toJson<int>(battery),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'elevation': serializer.toJson<double>(elevation),
      'accuracy': serializer.toJson<double>(accuracy),
      'date': serializer.toJson<DateTime>(date),
      'state': serializer.toJson<String>(state),
    };
  }

  DeviceLocation copyWith(
          {String? deviceDataId,
          String? deviceId,
          int? dataUsage,
          double? temperature,
          int? battery,
          double? lat,
          double? lon,
          double? elevation,
          double? accuracy,
          DateTime? date,
          String? state}) =>
      DeviceLocation(
        deviceDataId: deviceDataId ?? this.deviceDataId,
        deviceId: deviceId ?? this.deviceId,
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
  @override
  String toString() {
    return (StringBuffer('DeviceLocation(')
          ..write('deviceDataId: $deviceDataId, ')
          ..write('deviceId: $deviceId, ')
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
  int get hashCode => Object.hash(deviceDataId, deviceId, dataUsage,
      temperature, battery, lat, lon, elevation, accuracy, date, state);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceLocation &&
          other.deviceDataId == this.deviceDataId &&
          other.deviceId == this.deviceId &&
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

class DeviceLocationsCompanion extends UpdateCompanion<DeviceLocation> {
  final Value<String> deviceDataId;
  final Value<String> deviceId;
  final Value<int> dataUsage;
  final Value<double> temperature;
  final Value<int> battery;
  final Value<double> lat;
  final Value<double> lon;
  final Value<double> elevation;
  final Value<double> accuracy;
  final Value<DateTime> date;
  final Value<String> state;
  final Value<int> rowid;
  const DeviceLocationsCompanion({
    this.deviceDataId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dataUsage = const Value.absent(),
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
  DeviceLocationsCompanion.insert({
    required String deviceDataId,
    required String deviceId,
    required int dataUsage,
    required double temperature,
    required int battery,
    required double lat,
    required double lon,
    required double elevation,
    required double accuracy,
    required DateTime date,
    required String state,
    this.rowid = const Value.absent(),
  })  : deviceDataId = Value(deviceDataId),
        deviceId = Value(deviceId),
        dataUsage = Value(dataUsage),
        temperature = Value(temperature),
        battery = Value(battery),
        lat = Value(lat),
        lon = Value(lon),
        elevation = Value(elevation),
        accuracy = Value(accuracy),
        date = Value(date),
        state = Value(state);
  static Insertable<DeviceLocation> custom({
    Expression<String>? deviceDataId,
    Expression<String>? deviceId,
    Expression<int>? dataUsage,
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
      if (deviceDataId != null) 'device_data_id': deviceDataId,
      if (deviceId != null) 'device_id': deviceId,
      if (dataUsage != null) 'data_usage': dataUsage,
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

  DeviceLocationsCompanion copyWith(
      {Value<String>? deviceDataId,
      Value<String>? deviceId,
      Value<int>? dataUsage,
      Value<double>? temperature,
      Value<int>? battery,
      Value<double>? lat,
      Value<double>? lon,
      Value<double>? elevation,
      Value<double>? accuracy,
      Value<DateTime>? date,
      Value<String>? state,
      Value<int>? rowid}) {
    return DeviceLocationsCompanion(
      deviceDataId: deviceDataId ?? this.deviceDataId,
      deviceId: deviceId ?? this.deviceId,
      dataUsage: dataUsage ?? this.dataUsage,
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
    if (deviceDataId.present) {
      map['device_data_id'] = Variable<String>(deviceDataId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceLocationsCompanion(')
          ..write('deviceDataId: $deviceDataId, ')
          ..write('deviceId: $deviceId, ')
          ..write('dataUsage: $dataUsage, ')
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

class $UserAlertTable extends UserAlert
    with TableInfo<$UserAlertTable, UserAlertData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserAlertTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _alertIdMeta =
      const VerificationMeta('alertId');
  @override
  late final GeneratedColumn<String> alertId = GeneratedColumn<String>(
      'alert_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
      [alertId, hasNotification, parameter, comparisson, value];
  @override
  String get aliasedName => _alias ?? 'user_alert';
  @override
  String get actualTableName => 'user_alert';
  @override
  VerificationContext validateIntegrity(Insertable<UserAlertData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('alert_id')) {
      context.handle(_alertIdMeta,
          alertId.isAcceptableOrUnknown(data['alert_id']!, _alertIdMeta));
    } else if (isInserting) {
      context.missing(_alertIdMeta);
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
  Set<GeneratedColumn> get $primaryKey => {alertId};
  @override
  UserAlertData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserAlertData(
      alertId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alert_id'])!,
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
  final String alertId;
  final bool hasNotification;
  final String parameter;
  final String comparisson;
  final double value;
  const UserAlertData(
      {required this.alertId,
      required this.hasNotification,
      required this.parameter,
      required this.comparisson,
      required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['alert_id'] = Variable<String>(alertId);
    map['has_notification'] = Variable<bool>(hasNotification);
    map['parameter'] = Variable<String>(parameter);
    map['comparisson'] = Variable<String>(comparisson);
    map['value'] = Variable<double>(value);
    return map;
  }

  UserAlertCompanion toCompanion(bool nullToAbsent) {
    return UserAlertCompanion(
      alertId: Value(alertId),
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
      alertId: serializer.fromJson<String>(json['alertId']),
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
      'alertId': serializer.toJson<String>(alertId),
      'hasNotification': serializer.toJson<bool>(hasNotification),
      'parameter': serializer.toJson<String>(parameter),
      'comparisson': serializer.toJson<String>(comparisson),
      'value': serializer.toJson<double>(value),
    };
  }

  UserAlertData copyWith(
          {String? alertId,
          bool? hasNotification,
          String? parameter,
          String? comparisson,
          double? value}) =>
      UserAlertData(
        alertId: alertId ?? this.alertId,
        hasNotification: hasNotification ?? this.hasNotification,
        parameter: parameter ?? this.parameter,
        comparisson: comparisson ?? this.comparisson,
        value: value ?? this.value,
      );
  @override
  String toString() {
    return (StringBuffer('UserAlertData(')
          ..write('alertId: $alertId, ')
          ..write('hasNotification: $hasNotification, ')
          ..write('parameter: $parameter, ')
          ..write('comparisson: $comparisson, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(alertId, hasNotification, parameter, comparisson, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserAlertData &&
          other.alertId == this.alertId &&
          other.hasNotification == this.hasNotification &&
          other.parameter == this.parameter &&
          other.comparisson == this.comparisson &&
          other.value == this.value);
}

class UserAlertCompanion extends UpdateCompanion<UserAlertData> {
  final Value<String> alertId;
  final Value<bool> hasNotification;
  final Value<String> parameter;
  final Value<String> comparisson;
  final Value<double> value;
  final Value<int> rowid;
  const UserAlertCompanion({
    this.alertId = const Value.absent(),
    this.hasNotification = const Value.absent(),
    this.parameter = const Value.absent(),
    this.comparisson = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserAlertCompanion.insert({
    required String alertId,
    required bool hasNotification,
    required String parameter,
    required String comparisson,
    required double value,
    this.rowid = const Value.absent(),
  })  : alertId = Value(alertId),
        hasNotification = Value(hasNotification),
        parameter = Value(parameter),
        comparisson = Value(comparisson),
        value = Value(value);
  static Insertable<UserAlertData> custom({
    Expression<String>? alertId,
    Expression<bool>? hasNotification,
    Expression<String>? parameter,
    Expression<String>? comparisson,
    Expression<double>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (alertId != null) 'alert_id': alertId,
      if (hasNotification != null) 'has_notification': hasNotification,
      if (parameter != null) 'parameter': parameter,
      if (comparisson != null) 'comparisson': comparisson,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserAlertCompanion copyWith(
      {Value<String>? alertId,
      Value<bool>? hasNotification,
      Value<String>? parameter,
      Value<String>? comparisson,
      Value<double>? value,
      Value<int>? rowid}) {
    return UserAlertCompanion(
      alertId: alertId ?? this.alertId,
      hasNotification: hasNotification ?? this.hasNotification,
      parameter: parameter ?? this.parameter,
      comparisson: comparisson ?? this.comparisson,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (alertId.present) {
      map['alert_id'] = Variable<String>(alertId.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserAlertCompanion(')
          ..write('alertId: $alertId, ')
          ..write('hasNotification: $hasNotification, ')
          ..write('parameter: $parameter, ')
          ..write('comparisson: $comparisson, ')
          ..write('value: $value, ')
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
  static const VerificationMeta _notificationIdMeta =
      const VerificationMeta('notificationId');
  @override
  late final GeneratedColumn<String> notificationId = GeneratedColumn<String>(
      'notification_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES device (device_id)'));
  static const VerificationMeta _alertIdMeta =
      const VerificationMeta('alertId');
  @override
  late final GeneratedColumn<String> alertId = GeneratedColumn<String>(
      'alert_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES user_alert (alert_id)'));
  @override
  List<GeneratedColumn> get $columns => [notificationId, deviceId, alertId];
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
    if (data.containsKey('notification_id')) {
      context.handle(
          _notificationIdMeta,
          notificationId.isAcceptableOrUnknown(
              data['notification_id']!, _notificationIdMeta));
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('alert_id')) {
      context.handle(_alertIdMeta,
          alertId.isAcceptableOrUnknown(data['alert_id']!, _alertIdMeta));
    } else if (isInserting) {
      context.missing(_alertIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {notificationId};
  @override
  AlertNotificationData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertNotificationData(
      notificationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}notification_id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      alertId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alert_id'])!,
    );
  }

  @override
  $AlertNotificationTable createAlias(String alias) {
    return $AlertNotificationTable(attachedDatabase, alias);
  }
}

class AlertNotificationData extends DataClass
    implements Insertable<AlertNotificationData> {
  final String notificationId;
  final String deviceId;
  final String alertId;
  const AlertNotificationData(
      {required this.notificationId,
      required this.deviceId,
      required this.alertId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['notification_id'] = Variable<String>(notificationId);
    map['device_id'] = Variable<String>(deviceId);
    map['alert_id'] = Variable<String>(alertId);
    return map;
  }

  AlertNotificationCompanion toCompanion(bool nullToAbsent) {
    return AlertNotificationCompanion(
      notificationId: Value(notificationId),
      deviceId: Value(deviceId),
      alertId: Value(alertId),
    );
  }

  factory AlertNotificationData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertNotificationData(
      notificationId: serializer.fromJson<String>(json['notificationId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      alertId: serializer.fromJson<String>(json['alertId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'notificationId': serializer.toJson<String>(notificationId),
      'deviceId': serializer.toJson<String>(deviceId),
      'alertId': serializer.toJson<String>(alertId),
    };
  }

  AlertNotificationData copyWith(
          {String? notificationId, String? deviceId, String? alertId}) =>
      AlertNotificationData(
        notificationId: notificationId ?? this.notificationId,
        deviceId: deviceId ?? this.deviceId,
        alertId: alertId ?? this.alertId,
      );
  @override
  String toString() {
    return (StringBuffer('AlertNotificationData(')
          ..write('notificationId: $notificationId, ')
          ..write('deviceId: $deviceId, ')
          ..write('alertId: $alertId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(notificationId, deviceId, alertId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertNotificationData &&
          other.notificationId == this.notificationId &&
          other.deviceId == this.deviceId &&
          other.alertId == this.alertId);
}

class AlertNotificationCompanion
    extends UpdateCompanion<AlertNotificationData> {
  final Value<String> notificationId;
  final Value<String> deviceId;
  final Value<String> alertId;
  final Value<int> rowid;
  const AlertNotificationCompanion({
    this.notificationId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.alertId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertNotificationCompanion.insert({
    required String notificationId,
    required String deviceId,
    required String alertId,
    this.rowid = const Value.absent(),
  })  : notificationId = Value(notificationId),
        deviceId = Value(deviceId),
        alertId = Value(alertId);
  static Insertable<AlertNotificationData> custom({
    Expression<String>? notificationId,
    Expression<String>? deviceId,
    Expression<String>? alertId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (notificationId != null) 'notification_id': notificationId,
      if (deviceId != null) 'device_id': deviceId,
      if (alertId != null) 'alert_id': alertId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertNotificationCompanion copyWith(
      {Value<String>? notificationId,
      Value<String>? deviceId,
      Value<String>? alertId,
      Value<int>? rowid}) {
    return AlertNotificationCompanion(
      notificationId: notificationId ?? this.notificationId,
      deviceId: deviceId ?? this.deviceId,
      alertId: alertId ?? this.alertId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (notificationId.present) {
      map['notification_id'] = Variable<String>(notificationId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (alertId.present) {
      map['alert_id'] = Variable<String>(alertId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertNotificationCompanion(')
          ..write('notificationId: $notificationId, ')
          ..write('deviceId: $deviceId, ')
          ..write('alertId: $alertId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlertDevicesTable extends AlertDevices
    with TableInfo<$AlertDevicesTable, AlertDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _alertDeviceIdMeta =
      const VerificationMeta('alertDeviceId');
  @override
  late final GeneratedColumn<String> alertDeviceId = GeneratedColumn<String>(
      'alert_device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES device (device_id)'));
  static const VerificationMeta _alertIdMeta =
      const VerificationMeta('alertId');
  @override
  late final GeneratedColumn<String> alertId = GeneratedColumn<String>(
      'alert_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES user_alert (alert_id)'));
  @override
  List<GeneratedColumn> get $columns => [alertDeviceId, deviceId, alertId];
  @override
  String get aliasedName => _alias ?? 'alert_devices';
  @override
  String get actualTableName => 'alert_devices';
  @override
  VerificationContext validateIntegrity(Insertable<AlertDevice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('alert_device_id')) {
      context.handle(
          _alertDeviceIdMeta,
          alertDeviceId.isAcceptableOrUnknown(
              data['alert_device_id']!, _alertDeviceIdMeta));
    } else if (isInserting) {
      context.missing(_alertDeviceIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('alert_id')) {
      context.handle(_alertIdMeta,
          alertId.isAcceptableOrUnknown(data['alert_id']!, _alertIdMeta));
    } else if (isInserting) {
      context.missing(_alertIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {alertDeviceId};
  @override
  AlertDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertDevice(
      alertDeviceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}alert_device_id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      alertId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alert_id'])!,
    );
  }

  @override
  $AlertDevicesTable createAlias(String alias) {
    return $AlertDevicesTable(attachedDatabase, alias);
  }
}

class AlertDevice extends DataClass implements Insertable<AlertDevice> {
  final String alertDeviceId;
  final String deviceId;
  final String alertId;
  const AlertDevice(
      {required this.alertDeviceId,
      required this.deviceId,
      required this.alertId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['alert_device_id'] = Variable<String>(alertDeviceId);
    map['device_id'] = Variable<String>(deviceId);
    map['alert_id'] = Variable<String>(alertId);
    return map;
  }

  AlertDevicesCompanion toCompanion(bool nullToAbsent) {
    return AlertDevicesCompanion(
      alertDeviceId: Value(alertDeviceId),
      deviceId: Value(deviceId),
      alertId: Value(alertId),
    );
  }

  factory AlertDevice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertDevice(
      alertDeviceId: serializer.fromJson<String>(json['alertDeviceId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      alertId: serializer.fromJson<String>(json['alertId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'alertDeviceId': serializer.toJson<String>(alertDeviceId),
      'deviceId': serializer.toJson<String>(deviceId),
      'alertId': serializer.toJson<String>(alertId),
    };
  }

  AlertDevice copyWith(
          {String? alertDeviceId, String? deviceId, String? alertId}) =>
      AlertDevice(
        alertDeviceId: alertDeviceId ?? this.alertDeviceId,
        deviceId: deviceId ?? this.deviceId,
        alertId: alertId ?? this.alertId,
      );
  @override
  String toString() {
    return (StringBuffer('AlertDevice(')
          ..write('alertDeviceId: $alertDeviceId, ')
          ..write('deviceId: $deviceId, ')
          ..write('alertId: $alertId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(alertDeviceId, deviceId, alertId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertDevice &&
          other.alertDeviceId == this.alertDeviceId &&
          other.deviceId == this.deviceId &&
          other.alertId == this.alertId);
}

class AlertDevicesCompanion extends UpdateCompanion<AlertDevice> {
  final Value<String> alertDeviceId;
  final Value<String> deviceId;
  final Value<String> alertId;
  final Value<int> rowid;
  const AlertDevicesCompanion({
    this.alertDeviceId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.alertId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertDevicesCompanion.insert({
    required String alertDeviceId,
    required String deviceId,
    required String alertId,
    this.rowid = const Value.absent(),
  })  : alertDeviceId = Value(alertDeviceId),
        deviceId = Value(deviceId),
        alertId = Value(alertId);
  static Insertable<AlertDevice> custom({
    Expression<String>? alertDeviceId,
    Expression<String>? deviceId,
    Expression<String>? alertId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (alertDeviceId != null) 'alert_device_id': alertDeviceId,
      if (deviceId != null) 'device_id': deviceId,
      if (alertId != null) 'alert_id': alertId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertDevicesCompanion copyWith(
      {Value<String>? alertDeviceId,
      Value<String>? deviceId,
      Value<String>? alertId,
      Value<int>? rowid}) {
    return AlertDevicesCompanion(
      alertDeviceId: alertDeviceId ?? this.alertDeviceId,
      deviceId: deviceId ?? this.deviceId,
      alertId: alertId ?? this.alertId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (alertDeviceId.present) {
      map['alert_device_id'] = Variable<String>(alertDeviceId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (alertId.present) {
      map['alert_id'] = Variable<String>(alertId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertDevicesCompanion(')
          ..write('alertDeviceId: $alertDeviceId, ')
          ..write('deviceId: $deviceId, ')
          ..write('alertId: $alertId, ')
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
  late final $DeviceTable device = $DeviceTable(this);
  late final $FenceDevicesTable fenceDevices = $FenceDevicesTable(this);
  late final $DeviceLocationsTable deviceLocations =
      $DeviceLocationsTable(this);
  late final $UserAlertTable userAlert = $UserAlertTable(this);
  late final $AlertNotificationTable alertNotification =
      $AlertNotificationTable(this);
  late final $AlertDevicesTable alertDevices = $AlertDevicesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        user,
        fence,
        fencePoints,
        device,
        fenceDevices,
        deviceLocations,
        userAlert,
        alertNotification,
        alertDevices
      ];
}
