class LoginModel {
  String? token;
  User? user;
  String? message;

  LoginModel({this.token, this.user, this.message});

  LoginModel.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  Null? emailVerifiedAt;
  String? userType;
  String? createdAt;
  String? updatedAt;
  String? otp;
  Null? otpExpiresAt;
  String? lastActivityAt;
  int? roleId;

  User(
      {this.id,
        this.name,
        this.email,
        this.emailVerifiedAt,
        this.userType,
        this.createdAt,
        this.updatedAt,
        this.otp,
        this.otpExpiresAt,
        this.lastActivityAt,
        this.roleId});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    userType = json['user_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    otp = json['otp'];
    otpExpiresAt = json['otp_expires_at'];
    lastActivityAt = json['last_activity_at'];
    roleId = json['role_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['user_type'] = this.userType;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['otp'] = this.otp;
    data['otp_expires_at'] = this.otpExpiresAt;
    data['last_activity_at'] = this.lastActivityAt;
    data['role_id'] = this.roleId;
    return data;
  }
}