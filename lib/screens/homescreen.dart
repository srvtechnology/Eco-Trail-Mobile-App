
import 'package:ecotrail/screens/searchoption.dart';
import 'package:flutter/material.dart';

import '../util/utility.dart';
import 'homeoption.dart';
import 'mapoption.dart';
import 'menuoption.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/homescreen';

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static String Token="";

  final List<BottomNavigationBarItem> _items = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
    BottomNavigationBarItem(icon: Icon(Icons.location_pin), label: 'Map'),
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async{
    Token= (await Utility(context).getToken())!;
    setState(() {

    });
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomeOption();
      case 1:
        return  CulturalEventsScreen();
      case 2:
        return const Searchoption();
      case 3:
        return const MapScreenOption();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: _items,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
