import 'dart:convert';
import 'package:ecotrail/screens/profilescreen.dart';
import 'package:ecotrail/screens/signin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/placemodel.dart';
import '../provider/homeoptionprovider.dart';
import '../screens/mapscreen.dart';
import '../screens/detailscreen.dart';
import '../util/client.dart';
import '../util/constants.dart';
import '../util/utility.dart';
import 'homescreen.dart';

class HomeOption extends StatefulWidget {
  static const String routeName = '/homeoption';

  const HomeOption({super.key});

  @override
  State<HomeOption> createState() => _HomeOptionState();
}

class _HomeOptionState extends State<HomeOption> {
  int selectedCategoryId = 0;
  late HomeOptionProvider homeOptionProvider;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  List<Map<String, dynamic>> highlightedinfolist = [];
  int visibleItemCount = 10;
  late String name;
  late String email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    homeOptionProvider = Provider.of<HomeOptionProvider>(
      context,
      listen: false,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeOptionProvider.fetchCategories(context);
      homeOptionProvider.fetchPlacesByCategory(context, false, categoryId: 0);
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        setState(() {
          visibleItemCount += 10;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //initData();
    });
  }


  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.black),
          onPressed: () async {


           if(HomePageState.Token.isNotEmpty){
             Navigator.push(
               context,
               createSlideRoute(const ProfileScreen()),
             );
           }else{
             ScaffoldMessenger.of(
               context,
             ).showSnackBar(const SnackBar(content: Text('Login to access account page')));
             Navigator.pushReplacement(
               context,
               createSlideRoute(const SigninScreen()),
             );
           }
          },
        ),
        actions: [
           HomePageState.Token.isNotEmpty? IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              Utility(context).saveToken("");
              await Utility(context).saveEmail("");
              await Utility(context).saveName("");
              HomePageState.Token="";
              Navigator.push(context, createSlideRoute(SigninScreen()));
              bool success = await APIService.logout(context);
              if (success) {
                Navigator.push(context, createSlideRoute(SigninScreen()));
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Logout failed')));
              }
            },
          ):SizedBox(),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Tang - Ura Sumthrang\nEco Cultural Trail',
                style: TextStyle(
                  fontSize: 26,
                  fontFamily: bold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Consumer<HomeOptionProvider>(
                builder: (context, value, child) {
                  return SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: value.categoryList.length,
                      itemBuilder: (_, index) {
                        final cat = value.categoryList[index];
                        final selected = selectedCategoryId == cat.id;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategoryId = cat.id ?? 0;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 40.0),
                            child: Text(
                              cat.name ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: bold,
                                color: selected ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<HomeOptionProvider>(
                  builder: (context, value, child) {
                    List<Datum> filteredPlaces =
                        selectedCategoryId == 0
                            ? value.placeList
                            : value.placeList
                                .where(
                                  (place) =>
                                      place.categoryId == selectedCategoryId,
                                )
                                .toList();

                    if (_searchQuery.isNotEmpty) {
                      filteredPlaces =
                          filteredPlaces
                              .where(
                                (place) => (place.placeName ?? '')
                                    .toLowerCase()
                                    .contains(_searchQuery),
                              )
                              .toList();
                    }

                    final limitedList =
                        filteredPlaces.take(visibleItemCount).toList();

                    if (limitedList.isEmpty) {
                      return const Center(child: Text("No places found"));
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: limitedList.length,
                      itemBuilder: (context, index) {
                        final place = limitedList[index];
                        highlightedinfolist = parseHighlightInfo(
                          place.highlightInfo,
                        );

                        String elevationText = '';
                        // if (highlightedinfolist.isNotEmpty && index < highlightedinfolist.length) {
                        final value =
                            "${highlightedinfolist[0].values.first} ${highlightedinfolist[0].values.last}";
                        elevationText =
                            "${value.toString().replaceAll(RegExp(r'^\(|\)\$'), '')}";
                        //}

                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: _buildLocationCard(
                            image:
                                place.featuredImage != null
                                    ? "http://druknyofoundation.org/public/storage/${place.featuredImage}"
                                    : 'assets/placeholder.png',
                            title: place.placeName ?? 'No Name',
                            elevation: elevationText,
                            badgeImage: 'assets/map_green.png',
                            id: place.id.toString(),
                            data: place,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> parseHighlightInfo(String? rawHighlightInfo) {
    try {
      if (rawHighlightInfo == null) return [];
      final String firstDecoded = jsonDecode(rawHighlightInfo);
      final List<dynamic> secondDecoded = jsonDecode(firstDecoded);
      return secondDecoded.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint("Error parsing highlight_info: $e");
      return [];
    }
  }

  Widget _buildLocationCard({
    required String image,
    required String title,
    required String elevation,
    required String badgeImage,
    required String id,
    required Datum data,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, createSlideRoute(DetailScreen(id, data)));
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(bottom: 30, right: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child:
                    image.startsWith('http')
                        ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Image.asset(
                                'assets/placeholder.png',
                                fit: BoxFit.cover,
                              ),
                        )
                        : Image.asset(image, fit: BoxFit.cover),
              ),
              data.latitude == null && data.longitude == null
                  ? const SizedBox()
                  : Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          createSlideRoute(
                            MapScreen(
                              double.parse(data.latitude!),
                              double.parse(data.longitude!),
                              data.latlong_info ?? "",
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 15,
                        child:  Icon(Icons.location_pin,color: Colors.greenAccent,),
                      ),
                    ),
                  ),
              Positioned(
                bottom: 20,
                left: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        shadows: [
                          Shadow(
                            offset: Offset(0.0, 0.0),
                            blurRadius: 5.0,
                            color: Colors.black54,
                          ),
                        ],
                        color: Colors.white,
                        fontFamily: bold,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      elevation.replaceAll(",", ":"),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        shadows: [
                          Shadow(
                            offset: Offset(0.0, 0.0),
                            blurRadius: 5.0,
                            color: Colors.black54,
                          ),
                        ],
                        color: Colors.white,
                        fontFamily: bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Custom Slide Page Transition
  Route createSlideRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // from right to left
        const end = Offset.zero;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
