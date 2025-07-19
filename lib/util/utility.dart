import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:ecotrail/util/prefkey.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utility {
  BuildContext context;

  Utility(this.context);


  Future<void> saveLogedin(String driverToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefKeys().isLogin, driverToken);
  }


  Future<String?> getLogedin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKeys().isLogin);
  }


  Future<void> saveToken(String driverToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefKeys().driverToken, driverToken);
  }


  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKeys().driverToken);
  }

Future<void> saveEmail(String driverToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefKeys().email, driverToken);
  }


  Future<String?> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKeys().email);
  }


Future<void> saveName(String driverToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefKeys().name, driverToken);
  }


  Future<String?> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKeys().name);
  }


  Future<void> saveDriverId(String? id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefKeys().driverId, id!);
  }

  Future<int?> getDriverId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefKeys().driverId);
  }

  bool isVailed(String uname, String upass, String email) {
    if (uname.isEmpty) {
      showCustomSnackbar("Enter full name", Colors.red);
      return false;
    } else if (email.isEmpty) {
      showCustomSnackbar("Enter Email", Colors.red);
      return false;
    } else if (upass.isEmpty) {
      showCustomSnackbar("Enter Password", Colors.red);
      return false;
    } else if (upass.length < 8) {
      showCustomSnackbar("Password must be at least 8 characters.", Colors.red);
      return false;
    } else if (!RegExp(r'[A-Za-z]').hasMatch(upass)) {
      showCustomSnackbar("Password must contain at least one letter.", Colors.red);
      return false;
    } else if (!RegExp(r'[!@#\$&*~%^()_+=|<>?{}\[\]\/\\]').hasMatch(upass)) {
      showCustomSnackbar("Password must contain at least one symbol.", Colors.red);
      return false;
    } else {
      return true;
    }
  }


  bool isVailedLoginData( String upass, String email) {
   if (email.isEmpty) {
      showCustomSnackbar("Enter Email", Colors.red);
      return false;
    } else if (upass.isEmpty) {
      showCustomSnackbar("Enter Password", Colors.red);
      return false;
    } else if (upass.length < 8) {
      showCustomSnackbar("Password must be at least 8 characters.", Colors.red);
      return false;
    } else if (!RegExp(r'[A-Za-z]').hasMatch(upass)) {
      showCustomSnackbar("Password must contain at least one letter.", Colors.red);
      return false;
    } else if (!RegExp(r'[!@#\$&*~%^()_+=|<>?{}\[\]\/\\]').hasMatch(upass)) {
      showCustomSnackbar("Password must contain at least one symbol.", Colors.red);
      return false;
    } else {
      return true;
    }
  }

  void showCustomSnackbar(String message, Color barColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Wrap(
          children: [
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: barColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

}
