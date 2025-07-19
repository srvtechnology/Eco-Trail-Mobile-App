import 'package:ecotrail/model/signupRequestmodel.dart';
import 'package:ecotrail/model/signupmodel.dart';
import 'package:flutter/material.dart';

import '../util/client.dart';
import '../util/utility.dart';

class SignUpProvider with ChangeNotifier {
  bool _checkedValue = false;
  bool _isApiCallProcess = false;
  bool _showHide = true;

  bool get checkedValue => _checkedValue;

  bool get isApiCallProcess => _isApiCallProcess;

  bool get showHide => _showHide;

  void setCheckValue(bool isChecked) {
    _checkedValue = isChecked;
    notifyListeners();
  }

  void setApiCallProcess(bool isDone) {
    _isApiCallProcess = isDone;
    notifyListeners();
  }

  void setShowHide(bool isShow) {
    _showHide = isShow;
    notifyListeners();
  }
  void callSignup(
      BuildContext context,
      String username,
      String email,
      String password,
      Function({String? successData, String? errorMessage}) callback,
      ) {
    APIService apiService = APIService(Utility(context));
    SignupRequestModel signupRequestModel = SignupRequestModel()
      ..username = username
      ..password = password
      ..email = email;

    apiService.Signup(signupRequestModel).then((value) {
      if (value.message != null && value.message != "Validation error") {
        callback(successData: value.message, errorMessage: null);
      } else if (value.message == "Validation error" && value.user != null) {
        String errorMessages = extractValidationMessages(value.user! as Map<String, dynamic>);
        callback(successData: null, errorMessage: errorMessages);
      } else {
        callback(successData: null, errorMessage: "Signup failed.");
      }
    }).catchError((e) {
      callback(successData: null, errorMessage: "Something went wrong: $e");
    });
  }


  String extractValidationMessages(Map<String, dynamic> errorMap) {
    List<String> messages = [];
    for (var entry in errorMap.entries) {
      if (entry.value is List) {
        for (var msg in entry.value) {
          messages.add(msg.toString());
        }
      }
    }
    return messages.join('\n');
  }

  void callOtpVerify(
      BuildContext context,
      String email,
      String otp,
      Function({String? successData, String? errorMessage}) callback,
      ) {
    final apiService = APIService(Utility(context));

    apiService.verifyOtp(email, otp).then((value) async{
      if (value.token != null && value.user != null) {
        // Optionally save token or user details here
        await Utility(context).saveToken(value.token ?? "");

        await Utility(context).saveEmail(value.user?.email ?? "");
        await Utility(context).saveName(value.user?.name ?? "");

        await Utility(context).saveLogedin("yes" ?? "");
        callback(successData: "OTP Verified!", errorMessage: null);
      } else {
        callback(successData: null, errorMessage: "OTP verification failed.");
      }
    }).catchError((e) {
      callback(successData: null, errorMessage: "Something went wrong: $e");
    });
  }

}