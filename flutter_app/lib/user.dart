class User {
  int? id;
  final String email;
  String? password;

  User({this.id, required this.email, this.password});

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map["id"],
        email: map["email"] ?? '',
        password: map["password"],
      );

  Map<String, dynamic> toMap() => {
        if (id != null) "id": id,
        "email": email,
        if (password != null) "password": password,
      };
}
