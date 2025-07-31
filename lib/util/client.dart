import 'package:ecotrail/model/loginmodel.dart';
import 'package:ecotrail/model/loginrequestmodel.dart';
import 'package:ecotrail/model/signupRequestmodel.dart';
import 'package:ecotrail/model/signupmodel.dart';
import 'package:ecotrail/util/Constants.dart';
import 'package:ecotrail/util/apiconstant.dart';
import 'package:ecotrail/util/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

import '../model/categorymodel.dart';
import '../model/otpverifymodel.dart';
import 'constants.dart';

class APIService {
  Utility utility;
  var baseUrl = "http://druknyofoundation.org/public/api";

  APIService(this.utility);

  // Login authentication
  Future<SignUpModel> Signup(SignupRequestModel requestModel) async {
    try {
      final client = http.Client();

      final url = Uri.parse("$baseUrl${Api.SIGNUP}");
      final request = http.Request('POST', url);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(requestModel.toJson());

      print("Sending signup request to: $url");
      print("Request body: ${request.body}");

      final streamedResponse = await client.send(request);

      print("Received streamed response with status: ${streamedResponse.statusCode}");

      final responseBody = await streamedResponse.stream.bytesToString();

      print("Response body: $responseBody");

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        final jsonMap = json.decode(responseBody);
        return SignUpModel.fromJson(jsonMap);
      } else {
        final jsonMap = json.decode(responseBody);
        return SignUpModel(
          message: jsonMap['message'] ?? 'Signup failed',
          user: null,
        );
      }
    } catch (e, stacktrace) {
      print("🔥 Signup Error: $e");
      print("📍 Stacktrace:\n$stacktrace");

      return SignUpModel(
        message: "Something went wrong. Please try again.",
        user: null,
      );
    }

  }

  static Future<bool> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await Utility(context).getToken();

      if (token == null) return false;

      final response = await http.post(
        Uri.parse("http://druknyofoundation.org/public/api/logout"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove("access_token");
        return true;
      } else {
        print("Logout failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Logout error: $e");
      return false;
    }
  }


  Future<LoginModel> myLogin(LoginRequestModel requestModel) async {
    final headers = {'Content-Type': 'application/json'};
    final baseUrl = "http://druknyofoundation.org/public/api";
    final url = Uri.parse("$baseUrl/login");
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(requestModel.toJson()),
    );

    print("Login Response (${response.statusCode}): ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonMap = json.decode(response.body);
      return LoginModel.fromJson(jsonMap);
    } else {
      final jsonMap = json.decode(response.body);
      return LoginModel(
        message: jsonMap['message'] ?? 'Login failed. Please try again.',
        user: null,
      );
    }
  }

  // Assuming baseUrl and Api.LOGIN are defined here
  Future<LoginModel> login(LoginRequestModel requestModel) async {
    final url = Uri.parse("$baseUrl${Api.LOGIN}");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestModel.toJson(), // this must return Map<String, String>
      );
      print("Login Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonMap = json.decode(response.body);

        if(jsonMap["message"].toString().contains("OTP has been sent to your email. Please verify.")){

          return LoginModel(
            message: jsonMap['message'] ?? 'invailed username or password',
            user: null,
          );
        } else {
          return LoginModel.fromJson(jsonMap);
        }
      }
       else {
        final jsonMap = json.decode(response.body);
        return LoginModel(
          message: jsonMap['message'] ?? 'Login failed. Please try again.',
          user: null,
        );
      }
    } catch (e) {
      print("Login error: $e");
      return LoginModel(
        message: 'An error occurred. Please try again.',
        user: null,
      );
    }
  }

  //otp verification...
  Future<OtpVerifyModel> verifyOtp(String email, String otp) async {
    final headers = {'Content-Type': 'application/json'};

    final url = Uri.parse("$baseUrl${Api.VERIFYOTP}");
    final body = jsonEncode({"email": email, "otp": otp});

    final response = await http.post(url, headers: headers, body: body);
    print("OTP Verify Response (${response.statusCode}): ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return OtpVerifyModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("OTP verification failed: ${response.body}");
    }
  }

  Future<CategoryModel> fetchCategoryList(String token) async {
    final url = Uri.parse(
      "http://druknyofoundation.org/public/api/space-categories",
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body);
      return CategoryModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to load categories. Code: ${response.statusCode}',
      );
    }
  }

  Future<dynamic> fetchData(String? token) async {
    final headers = {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final url = Uri.parse("$baseUrl${Api.CATEGORY}");
    print("GET Request: $url");

    try {
      final response = await http.get(url, headers: headers);
      print("GET Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(
          "Failed to fetch data: ${response.statusCode} ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("GET request error: $e");
    }
  }
}
