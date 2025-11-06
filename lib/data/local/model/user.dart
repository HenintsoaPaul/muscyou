class User {
  int? id;
  String username;
  String password;

  User({this.id, required this.username, required this.password});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'username': username,
      'password': password,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  User.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        username = map['username'],
        password = map['password'];
}
