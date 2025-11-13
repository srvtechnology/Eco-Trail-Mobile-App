import 'dart:convert';

import 'package:flutter/material.dart';

import '../model/signupRequestmodel.dart';
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
      try {
        // Case 1: Successful signup
        if (value.message != null && value.message != "Validation error") {
          callback(successData: value.message, errorMessage: null);
        }
        // Case 2: Validation error
        else if (value.message == "Validation error") {
          String errorMessage = extractFirstErrorMessage(value.errors);
          callback(successData: null, errorMessage: errorMessage);
        }
        // Case 3: Other unknown failures
        else {
          callback(successData: null, errorMessage: "Signup failed.");
        }
      } catch (e) {
        callback(successData: null, errorMessage: "Error handling response: $e");
      }
    }).catchError((e) {
      callback(successData: null, errorMessage: "Something went wrong: $e");
    });



  }
  String extractFirstErrorMessage(dynamic errors) {
    try {
      if (errors is String) {
        final decoded = json.decode(errors);
        errors = decoded is String ? json.decode(decoded) : decoded;
      }

      if (errors is Map<String, dynamic>) {
        for (var value in errors.values) {
          if (value is List && value.isNotEmpty) {
            return value.first.toString(); // ✅ e.g. "The email has already been taken."
          } else if (value is String) {
            return value;
          }
        }
      }
    } catch (e) {
      debugPrint("Error parsing validation message: $e");
    }

    return "Validation error occurred.";
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