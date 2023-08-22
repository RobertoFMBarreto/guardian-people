const String tableUser = 'user';

class UserFields {
  static const String id = '_id';
  static const String uid = 'uid';
  static const String name = 'name';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String isAdmin = 'is_admin';
}

class User {
  final int? id;
  final String uid;
  final String name;
  final String email;
  final int phone;
  final bool isAdmin;
  const User({
    this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.isAdmin,
    required this.phone,
  });

  User copy({
    int? id,
    String? uid,
    String? name,
    String? email,
    int? phone,
    bool? isAdmin,
  }) =>
      User(
        id: id ?? this.id,
        uid: uid ?? this.uid,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        isAdmin: isAdmin ?? this.isAdmin,
      );

  Map<String, Object?> toJson() => {
        UserFields.uid: uid,
        UserFields.name: name,
        UserFields.email: email,
        UserFields.phone: phone,
        UserFields.isAdmin: isAdmin ? 1 : 0,
      };

  static User fromJson(Map<String, Object?> json) => User(
        uid: json[UserFields.uid] as String,
        name: json[UserFields.name] as String,
        email: json[UserFields.email] as String,
        isAdmin: json[UserFields.isAdmin] == 1,
        phone: json[UserFields.phone] as int,
      );
}
