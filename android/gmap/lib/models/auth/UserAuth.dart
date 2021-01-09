class UserAuth {
  final String username;
  final String fullname;
  final String token;
  final String expires;

  UserAuth({this.username, this.fullname, this.token, this.expires});
  factory UserAuth.fromJson(Map<String, dynamic> json) {
    print(json);
    return UserAuth(
      username: json['user'],
      fullname: json['fullname'],
      token: json['token'],
      expires: json['expire'],
    );
  }
}
