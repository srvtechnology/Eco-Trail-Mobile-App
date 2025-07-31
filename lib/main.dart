import 'package:ecotrail/provider/homeoptionprovider.dart';
import 'package:ecotrail/provider/loginprovider.dart';
import 'package:ecotrail/provider/signupprovider.dart';
import 'package:ecotrail/screens/homeoption.dart';
import 'package:ecotrail/screens/homescreen.dart';
import 'package:ecotrail/screens/menuoption.dart';
import 'package:ecotrail/screens/searchoption.dart';
import 'package:ecotrail/screens/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SignUpProvider()),
      ChangeNotifierProvider(create: (_) => LoginProvider()),
      ChangeNotifierProvider(create: (_) => HomeOptionProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/homescreen': (context) => HomePage(),
        '/homescreen': (context) => HomeOption(),
        '/menuoption': (context) => CulturalEventsScreen(),
        '/searchoption': (context) => Searchoption(),
      },
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
