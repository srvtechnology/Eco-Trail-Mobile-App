import 'dart:ui';

import 'package:ecotrail/screens/signin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/signupprovider.dart';
import '../util/Constants.dart';
import '../util/ecotrailheader.dart';
import '../util/prefkey.dart';
import '../util/utility.dart';
import 'homescreen.dart';

class SignupScreen extends StatefulWidget {
  static const String routeName = '/signup';
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  late Utility _utility;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late SignUpProvider signUpProvider;
  late SharedPreferences prefs;
  late PrefKeys prefKeys;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    signUpProvider = Provider.of<SignUpProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _utility = Utility(context);
    prefKeys = PrefKeys();
    SharedPreferences.getInstance().then((prefs) {


    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Consumer<SignUpProvider>(
        builder: (context, value, child) {
          return value.isApiCallProcess
              ? const Center(child: CircularProgressIndicator())
              : Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/splash_image.png', fit: BoxFit.cover),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(child: EcoTrailHeader()),
                              const SizedBox(height: 40),
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Full Name", style: _labelStyle()),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: _nameController,
                                      style: _inputStyle(),
                                      decoration: _inputDecoration(),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Please enter your full name';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    Text("Email", style: _labelStyle()),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: _emailController,
                                      style: _inputStyle(),
                                      decoration: _inputDecoration(),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                          return 'Enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    Text("Password", style: _labelStyle()),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      style: _inputStyle(),
                                      decoration: _inputDecoration(),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),

                                    Center(
                                      child: ElevatedButton(
                                        onPressed: doSignup,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.greenAccent[400],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          child: Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: kadawabold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      "Already Have an Account!",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: kadawaregular,
                                        fontSize: 13,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (_) => const SigninScreen()),
                                        );
                                      },
                                      child: const Text(
                                        "Signin",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontFamily: 'KadawaBold',
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.white,
                                          decorationThickness: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }



  TextStyle _labelStyle() => const TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontFamily: kadawabold,
    fontWeight: FontWeight.w500,
  );

  TextStyle _inputStyle() => const TextStyle(
    color: Colors.white,
    fontFamily: kadawabold,
    fontSize: 14,
  );

  InputDecoration _inputDecoration() => const InputDecoration(
    isDense: true,
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white70),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
    errorStyle: TextStyle(color: Colors.redAccent),
  );

  void doSignup() async {
    String username = _nameController.text.toString();
    String email = _emailController.text.toString();
    String password = _passwordController.text.toString();
    if (_utility.isVailed(username,password, email )) {
      signUpProvider.setApiCallProcess(true);
      signUpProvider.callSignup(context, username, email, password, ({
        errorMessage,
        successData,
      }) {
        if (errorMessage != null) {
          signUpProvider.setApiCallProcess(false);
          onError(errorMessage: errorMessage);
        } else {
          signUpProvider.setApiCallProcess(false);
          onSignupSuccess(successData,email,username);
        }
      });
    }
  }

  void onSignupSuccess(String? data,String? email,String? name) async {
    if (data != null && data.contains("OTP has been sent to your email. Please verify.")) {
      _utility.saveToken(data);

      await Utility(context).saveEmail(email!);
      await Utility(context).saveName(name!);

      await Utility(context).saveLogedin("yes" ?? "");
      _utility.showCustomSnackbar(
        "Signup successfull OTP has been sent to your email. Please verify.",
        Colors.green,
      );

      showDialog(
        context: context,
        builder: (context) {
          final otpController = TextEditingController();

          return AlertDialog(
            title: const Text("Verify OTP"),
            content: TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter OTP",
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                onPressed: () {
                  final otp = otpController.text.trim();
                  if (otp.isNotEmpty) {
                    Navigator.pop(context); // Close dialog
                    verifyOtp(otp,email!); // Call your OTP verify function
                  } else {
                    _utility.showCustomSnackbar("Please enter OTP", Colors.red);
                  }
                },
                child: const Text("Verify"),
              ),
            ],
          );
        },
      );
    } else {
      signUpProvider.setApiCallProcess(false);
    }
  }

  void onError({String? errorMessage}) {
    String snackbarMessage = errorMessage.toString();
    _utility.showCustomSnackbar(snackbarMessage, Colors.red);
  }



  void verifyOtp(String otp,String email) {
    signUpProvider.setApiCallProcess(true);
    signUpProvider.callOtpVerify(
      context,
      email,
      otp,
          ({
        successData,
        errorMessage,
      }) async {
        signUpProvider.setApiCallProcess(false);
        if (errorMessage != null) {
          _utility.showCustomSnackbar(errorMessage, Colors.red);
          signUpProvider.setApiCallProcess(false);
        } else {
          // OTP verified successfully
          _utility.showCustomSnackbar(successData ?? "OTP Verified!", Colors.green);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage()),
          );
        }
      },
    );
  }



}
