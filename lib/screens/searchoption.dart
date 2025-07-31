import 'dart:convert';
import 'package:ecotrail/screens/profilescreen.dart';
import 'package:ecotrail/screens/signin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/placemodel.dart';
import '../provider/homeoptionprovider.dart';
import '../util/Constants.dart';
import '../util/client.dart';
import '../util/utility.dart';
import 'detailscreen.dart';
import 'homescreen.dart';

class Searchoption extends StatefulWidget {
  static const String routeName = '/searchoption';

  const Searchoption({Key? key}) : super(key: key);

  @override
  State<Searchoption> createState() => _SearchoptionState();
}

class _SearchoptionState extends State<Searchoption> {
  int selectedCategoryId = 0;
  late HomeOptionProvider homeOptionProvider;
  List<Map<String, dynamic>> highlightedinfolist = [];
  List<Datum> _allPlaces = [];
  List<Datum> _filteredPlaces = [];
  final TextEditingController _searchController = TextEditingController();

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await homeOptionProvider.fetchCategories(context);
      await homeOptionProvider.fetchPlacesByCategory(
        context,
        false,
        categoryId: 0,
      );
      setState(() {
        _allPlaces = homeOptionProvider.placeList;
        _filteredPlaces = _allPlaces;
      });
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPlaces =
          _allPlaces
              .where(
                (place) =>
                    place.placeName?.toLowerCase().contains(query) ?? false,
              )
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 5,
        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () async {
            if (HomePageState.Token.isNotEmpty) {
              Navigator.push(context, createSlideRoute(const ProfileScreen()));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login to access account page')),
              );
              Navigator.pushReplacement(context, createSlideRoute(const SigninScreen()));
            }
          },
        ),

        actions: [
          HomePageState.Token.isNotEmpty
              ? IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  Utility(context).saveToken("");
                  HomePageState.Token="";
                  await Utility(context).saveEmail("");
                  await Utility(context).saveName("");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SigninScreen()),
                  );
                  bool success = await APIService.logout(context);
                  if (!success) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Logout failed')));
                  }
                },
              )
              : SizedBox(),
        ],
        title: const Text(
          "Search Places",
          style: TextStyle(color: Colors.white, fontFamily: bold),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Field
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

              // Place List
              Expanded(
                child:
                    _filteredPlaces.isEmpty
                        ? const Center(child: Text("No places found"))
                        : ListView.builder(
                          itemCount: _filteredPlaces.length,
                          itemBuilder: (context, index) {
                            final event = _filteredPlaces[index];
                            final highlightInfo = parseHighlightInfo(
                              event.highlightInfo,
                            );
                            final elevation =
                                highlightInfo.isNotEmpty
                                    ? highlightInfo.first.values.first
                                        .toString()
                                    : "N/A";

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => DetailScreen(
                                          _filteredPlaces[index].id.toString(),
                                          _filteredPlaces[index],
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Fixed height image
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      child: SizedBox(
                                        height: 180,
                                        width: double.infinity,
                                        child:
                                            event.featuredImage != null
                                                ? Image.network(
                                                  "http://druknyofoundation.org/public/storage/${event.featuredImage}",
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        _,
                                                        __,
                                                        ___,
                                                      ) => Image.asset(
                                                        'assets/placeholder.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                                )
                                                : Image.asset(
                                                  'assets/placeholder.png',
                                                  fit: BoxFit.cover,
                                                ),
                                      ),
                                    ),
                                    // Fixed layout padding
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Name: ${event.placeName ?? 'Unknown'}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Elevation: $elevation",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
}
