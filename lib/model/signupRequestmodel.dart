class SignupRequestModel {
  String? username;
  String? password;
  String? email;

  SignupRequestModel({
    this.username,
    this.password,
    this.email,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'name': username?.trim(),
      'password': password?.trim(),
      'email': email?.trim(),
    };

    return map;
  }
}