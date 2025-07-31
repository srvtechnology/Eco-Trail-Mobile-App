import 'package:flutter/material.dart';

import '../model/loginrequestmodel.dart';
import '../util/client.dart';
import '../util/utility.dart';

class LoginProvider with ChangeNotifier {
  bool _isApiCallProcess = false;

  bool get isApiCallProcess => _isApiCallProcess;

  void setApiCallProcess(bool isDone) {
    _isApiCallProcess = isDone;
    notifyListeners();
  }

  void callLogin(
    BuildContext context,
    String usertype,
    String email,
    String password,
    Function({String? successData, String? errorMessage}) callback,
  ) {
    APIService apiService = APIService(Utility(context));
    LoginRequestModel loginRequestModel = LoginRequestModel();
    loginRequestModel.usertype = usertype;
    loginRequestModel.password = password;
    loginRequestModel.email = email;

    apiService
        .login(loginRequestModel)
        .then((value) async {
          if (value.message ==
              "OTP has been sent to your email. Please verify.") {
            callback(successData: null, errorMessage: "Provided email or password is incorrect");
          } else if (value.message != null &&
              value.message != "Provided email or password is incorrect") {
            await Utility(context).saveToken(value?.token ?? "");
            await Utility(context).saveEmail(value.user?.email ?? "");
            await Utility(context).saveName(value.user?.name ?? "");
            callback(successData: value.message, errorMessage: null);
          } else {
            callback(successData: null, errorMessage: value.message);
          }
        })
        .catchError((e) {
          callback(successData: null, errorMessage: "Something went wrong: $e");
        });
  }

  void callOtpVerify(
    BuildContext context,
    String email,
    String otp,
    Function({String? successData, String? errorMessage}) callback,
  ) {
    final apiService = APIService(Utility(context));

    apiService
        .verifyOtp(email, otp)
        .then((value) async {
          if (value.token != null && value.user != null) {
            // Optionally save token or user details here
            await Utility(context).saveToken(value.token ?? "");

            await Utility(context).saveEmail(value.user?.email ?? "");
            await Utility(context).saveName(value.user?.name ?? "");

            await Utility(context).saveLogedin("yes" ?? "");
            callback(successData: "OTP Verified!", errorMessage: null);
          } else {
            callback(
              successData: null,
              errorMessage: "OTP verification failed.",
            );
          }
        })
        .catchError((e) {
          callback(successData: null, errorMessage: "Something went wrong: $e");
        });
  }
}
