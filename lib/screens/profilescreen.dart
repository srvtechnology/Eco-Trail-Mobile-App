import 'package:ecotrail/screens/signin.dart';
import 'package:ecotrail/screens/webviewscreen.dart';
import 'package:ecotrail/util/profileheader.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../util/Constants.dart';
import '../util/client.dart';
import '../util/ecotrailheader.dart';
import '../util/utility.dart';

class ProfileScreen extends StatefulWidget {
  static String routename = "/profile";

  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final double radius = 100;
  String name = "";
  String email = "";

  void getUserInfo() async {
    name = await Utility(context).getName() ?? "";
    email = await Utility(context).getEmail() ?? "";
    print(name);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 5,

        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontFamily: bold),
        ),
      ),
      body: Stack(
        children: [
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ProfileHeader(name),
                          const SizedBox(height: 10),
                          Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 30,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email - ${email ?? 'No Email'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'User Name - ${name ?? ' User'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Note:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                  Text(
                                    "Please contact your administrator to change email or password.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 0,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 15.0,
                                right: 5,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Privacy Policy',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.blue,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const WebViewScreen("http://druknyofoundation.org/public/privacy","Privacy Policy"),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                          Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 0,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 15.0,
                                right: 5,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Delete Account',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.blue,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const WebViewScreen("http://druknyofoundation.org/public/delete-account","Delete Account"),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                          Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 0,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 15.0,
                                right: 5,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'LOGOUT',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.blue,
                                      size: 18,
                                    ),
                                    onPressed: () async{
                                      Utility(context).saveToken("");
                                      await Utility(context).saveEmail("");
                                      await Utility(context).saveName("");

                                      Navigator.push(context, createSlideRoute(SigninScreen()));

                                      bool success = await APIService.logout(context);
                                      if (success) {
                                        Navigator.push(context, createSlideRoute(SigninScreen()));
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Logout failed')),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Route createSlideRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // from right to left
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  void openPrivacyPolicy() async {
    final url = Uri.parse('http://druknyofoundation.org/public/privacy1');

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // opens in browser
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
