
import 'package:ecotrail/screens/signin.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../util/Constants.dart';
import '../util/ecotrailheader.dart';
import '../util/utility.dart';
import 'homescreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late var token;
  bool isLogin = false;

  @override
  void initState() {
    super.initState();
    getToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await Utility(context).getLogedin();
    setState(() {
      isLogin = isLoggedIn != null && isLoggedIn.isNotEmpty;
    });
  }

  void getToken() async {
    token = await Utility(context).getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset('assets/splash_image.png', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header always on top
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: EcoTrailHeader(),
                ),

                // Centered "Foundation and Partnership"
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Foundation and Partnership',
                            style: TextStyle(
                              fontSize: 16,
                              shadows: [
                                Shadow(blurRadius: 8, color: Colors.black45),
                              ],
                              fontWeight: FontWeight.w600,
                              fontFamily: semiBold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Revived in partnership with ASIA, Co-financed by the Autonomous Province of Bolzano',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              shadows: [
                                Shadow(blurRadius: 8, color: Colors.black45),
                              ],
                              color: Colors.white,
                              fontFamily: lightItalic,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom pinned section
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 24,
                    left: 24,
                    right: 24,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Connecting',
                        style: TextStyle(
                          color: Colors.white,
                          shadows: [
                            Shadow(blurRadius: 8, color: Colors.black45),
                          ],
                          fontWeight: FontWeight.w600,
                          fontFamily: bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _dot(),
                          _divider(),
                          _dot(),
                          _divider(),
                          _dot(),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Ngang Lhakhang', style: _locationStyle()),
                          Text('Ogyen Choling', style: _locationStyle()),
                          Flexible(
                            child: Text(
                              'Sumthrang Samdrup\nChodzong',
                              style: _locationStyle(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),
                      GestureDetector(
                        onTap: () async {
                          final token = await Utility(context).getToken();
                          if (token == null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => SigninScreen()),
                            );
                          } else {
                            token.isNotEmpty
                                ? Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => HomePage()),
                                )
                                : Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SigninScreen(),
                                  ),
                                );
                          }

                          // token==""? :Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(builder: (_) => HomePage()),
                          // );
                        },
                        child: Image.asset(
                          'assets/starttrail_button.png',
                          width: 240,
                          height: 60,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    ),
  );

  Widget _divider() =>
      const Expanded(child: Divider(color: Colors.white70, thickness: 1));

  TextStyle _locationStyle() => TextStyle(
    fontSize: 10,
    color: Colors.white,
    fontFamily: lightItalic,
    shadows: [Shadow(blurRadius: 8, color: Colors.black45)],
    fontWeight: FontWeight.w400,
  );
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white54
          ..strokeWidth = 1.5;
    double dashHeight = 5, dashSpace = 3, startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
