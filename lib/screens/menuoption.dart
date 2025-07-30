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
import 'mapscreen.dart';

class CulturalEventsScreen extends StatefulWidget {
  static const String routeName = '/menuoption';

  const CulturalEventsScreen({Key? key}) : super(key: key);

  @override
  State<CulturalEventsScreen> createState() => _CulturalEventsScreenState();
}

class _CulturalEventsScreenState extends State<CulturalEventsScreen> {
  int selectedCategoryId = 0;
  late HomeOptionProvider homeOptionProvider;

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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 5,
        title: Text(
          "Places & More",
          style: TextStyle(color: Colors.white, fontFamily: bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () async {
 HomePageState.Token.isNotEmpty
                ? Navigator.push(
                  context,
                  createSlideRoute(const ProfileScreen()),
                )
                : ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Do Login First')));
          },
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.white),
            onPressed: _showCategoryBottomSheet,
          ),
           HomePageState.Token.isNotEmpty
              ? IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  Utility(context).saveToken("");

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
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Consumer<HomeOptionProvider>(
                  builder: (context, value, child) {
                    final filteredPlaces =
                        selectedCategoryId == 0
                            ? value.placeList
                            : value.placeList
                                .where(
                                  (place) =>
                                      place.categoryId == selectedCategoryId,
                                )
                                .toList();

                    if (filteredPlaces.isEmpty) {
                      return const Center(child: Text("No places found"));
                    }

                    return ListView.builder(
                      itemCount: filteredPlaces.length,
                      itemBuilder: (context, index) {
                        final event = filteredPlaces[index];
                        final highlightInfo = parseHighlightInfo(
                          event.highlightInfo,
                        );
                        final elevation =
                            highlightInfo.isNotEmpty
                                ? highlightInfo[0].values.last.toString()
                                : "N/A";

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => DetailScreen(
                                      filteredPlaces[index].id.toString(),
                                      filteredPlaces[index],
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
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
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
                                                  (_, __, ___) => Image.asset(
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
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Name: ${event.placeName}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${highlightInfo[0].values.first.toString()}: $elevation",
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

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final categories = homeOptionProvider.categoryList;
        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return ListTile(
              title: Text(cat.name ?? "Unnamed Category"),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedCategoryId = cat.id ?? 0;
                });
                homeOptionProvider.fetchPlacesByCategory(
                  context,
                  false,
                  categoryId: selectedCategoryId,
                );
              },
            );
          },
        );
      },
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
