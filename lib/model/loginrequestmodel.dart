class LoginRequestModel {
  String? usertype;
  String? password;
  String? email;

  LoginRequestModel({
    this.usertype,
    this.password,
    this.email,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'email': email?.trim(),
      'password': password?.trim(),
      'user_type': usertype?.trim(),
    };

    return map;
  }
}