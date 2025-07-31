
import 'package:ecotrail/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/loginprovider.dart';
import '../util/Constants.dart';
import '../util/ecotrailheader.dart';
import '../util/utility.dart';
import 'homescreen.dart';

class SigninScreen extends StatefulWidget {
  static const String routeName = '/signin';

  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late LoginProvider loginProvider;
  late Utility _utility;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _utility = Utility(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loginProvider = Provider.of<LoginProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Consumer<LoginProvider>(
        builder: (context, value, child) {
          return value.isApiCallProcess
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/splash_image.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                children: [
                                  EcoTrailHeader(),

                                  const SizedBox(height: 40),
                                  // Form section
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Email", style: _labelStyle()),
                                      const SizedBox(height: 4),
                                      TextFormField(
                                        controller: _emailController,
                                        style: _inputStyle(),
                                        decoration: _inputDecoration(),
                                      ),
                                      const SizedBox(height: 20),
                                      Text("Password", style: _labelStyle()),
                                      const SizedBox(height: 4),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: true,
                                        style: _inputStyle(),
                                        decoration: _inputDecoration(),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed: doLogin,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.greenAccent[400],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 12,
                                              ),
                                              child: Text(
                                                'Sign in',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: kadawabold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {},
                                            child: const Text(
                                              'Forgot password?',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: kadawaregular,
                                                fontSize: 13,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),


                                      const SizedBox(height: 30),
                                      Center(
                                        child: Text(
                                          "Don’t have an account!",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: kadawaregular,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),

                                      Center(
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => const SignupScreen(),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            "Create new account.",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontFamily: 'KadawaBold',
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                              TextDecoration.underline,
                                              decorationColor: Colors.white,
                                              decorationThickness: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 35),

                                    ],
                                  ),
                                  const Spacer(),
                                  // Signup section
                                  Column(
                                    children: [

                                      TextButton(
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero, // Remove internal padding
                                          minimumSize: Size(0, 0),  // Optional: remove min size restrictions
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Tighter touch area
                                        ),

                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => HomePage(),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 30.0),
                                          child: const Text(
                                            "Skip For Now",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontFamily: 'KadawaBold',
                                              decoration:
                                              TextDecoration.underline,
                                              decorationColor: Colors.white,
                                              decorationThickness: 1.5,
                                            ),
                                          ),
                                        ),

                                      ),
                                    ],
                                  ),
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

  void doLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (_utility.isVailedLoginData(password, email)) {
      loginProvider.setApiCallProcess(true);
      loginProvider.callLogin(context, "user", email, password, ({
        successData,
        errorMessage,
      }) {
        loginProvider.setApiCallProcess(false);
        if (errorMessage != null) {
          _utility.showCustomSnackbar(errorMessage, Colors.red);
        } else {
          _utility.showCustomSnackbar(successData ?? "Logged in", Colors.green);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage()),
          );
        }
      });
    }
  }

  void onLoginSuccess() async {
    _utility.showCustomSnackbar("Login successfully", Colors.green);
  }

  void onError({String? errorMessage}) {
    String snackbarMessage = errorMessage.toString();
    _utility.showCustomSnackbar(snackbarMessage, Colors.red);
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
  );
}

//showDialog(
//         context: context,
//         builder: (context) {
//           final otpController = TextEditingController();
//
//           return AlertDialog(
//             title: const Text("Verify OTP"),
//             content: TextField(
//               controller: otpController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 hintText: "Enter OTP",
//               ),
//             ),
//             actions: [
//               TextButton(
//                 child: const Text("Cancel"),
//                 onPressed: () => Navigator.pop(context),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   final otp = otpController.text.trim();
//                   if (otp.isNotEmpty) {
//                     Navigator.pop(context); // Close dialog
//                     verifyOtp(otp,email!); // Call your OTP verify function
//                   } else {
//                     _utility.showCustomSnackbar("Please enter OTP", Colors.red);
//                   }
//                 },
//                 child: const Text("Verify"),
//               ),
//             ],
//           );
//         },
//       );
