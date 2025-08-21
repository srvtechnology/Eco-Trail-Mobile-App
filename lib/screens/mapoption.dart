import 'dart:convert';
import 'package:ecotrail/model/routpoint.dart';
import 'package:ecotrail/screens/profilescreen.dart';
import 'package:ecotrail/screens/signin.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import '../util/client.dart';
import '../util/utility.dart';
import 'homescreen.dart';

class MapScreenOption extends StatefulWidget {
  static const String routeName = '/mapoption';

  const MapScreenOption({super.key});

  @override
  State<MapScreenOption> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreenOption> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<RoutePoint> _staticRoute = [];
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMapData();
    });
  }

  Future<void> _loadMapData() async {
    await _getCurrentLocation();
    await _fetchMarkersFromAPI();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever)
        return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentLocation = LatLng(position.latitude, position.longitude);

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("current_location"),
          position: _currentLocation!,
          infoWindow: const InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    });
  }

  Future<void> _fetchMarkersFromAPI() async {
    try {
      final token = await Utility(context).getToken();

      final response = await http.get(
        token != null
            ? Uri.parse(
              "http://druknyofoundation.org/public/api/get-all-latlong",
            )
            : Uri.parse(
              "http://druknyofoundation.org/public/api/guest-get-all-latlong",
            ),
        headers: {
          "Authorization": "Bearer ${token ?? ""}",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];

        for (int i = 0; i < data.length; i++) {
          final lat = double.tryParse(data[i]['latitude'] ?? '') ?? 0.0;
          final long = double.tryParse(data[i]['longitude'] ?? '') ?? 0.0;
          final placeName = data[i]['place_name'] ?? "Unknown";
          var latlnginfo = data[i]['latlong_info'];

          _markers.add(
            Marker(
              markerId: MarkerId('marker_$i'),
              position: LatLng(lat, long),
              infoWindow: InfoWindow(title: placeName),
              onTap: () {
                if (latlnginfo == null) {
                  latlnginfo = "[{\"lat\":27.493193005811459528331397450529038906097412109375,\"lng\":90.915133165359492295465315692126750946044921875,\"name\":\"Pema Lingpa's parents\",\"description\":\"Pema Lingpa's parents were Lama D\öndrup Zangpo of the Ny\ö clan and Drogmo Pema Drolma. His father was from Sumtrang, according to The Treasury of Lives. Pema Lingpa was born in 1450 in Chel, part of the Bumthang region of Bhutan. His mother was believed to possess the signs of a dakini, according to the Tibetan Buddhist Encyclopedia. \",\"image\":\"uploads\\/latlong_images\\/bmKaJWw8Atehlsw3ubFGgZw3Daq9TkXtEYrCVrBN.jpg\"},{\"lat\":27.49311686832669465729850344359874725341796875,\"lng\":90.917881810690914790029637515544891357421875,\"name\":\"\",\"description\":\"\",\"image\":\"null\"},{\"lat\":27.492393559595331709033416700549423694610595703125,\"lng\":90.918804490592037836904637515544891357421875,\"name\":\"\",\"description\":\"\",\"image\":\"null\"},{\"lat\":27.4914989343279785316553898155689239501953125,\"lng\":90.9202667819968866069757496006786823272705078125,\"name\":\"\",\"description\":\"\",\"image\":\"null\"},{\"lat\":27.4936117610365045038633979856967926025390625,\"lng\":90.9204813587180780132257496006786823272705078125,\"name\":\"\",\"description\":\"\",\"image\":\"null\"},{\"lat\":27.4949060852984104030838352628052234649658203125,\"lng\":90.9201702224723504741632496006786823272705078125,\"name\":\"\",\"description\":\"\",\"image\":\"null\"},{\"lat\":27.49584826765381961877210414968430995941162109375,\"lng\":90.9210714447013543804132496006786823272705078125,\"name\":\"\",\"description\":\"\",\"image\":\"null\"},{\"lat\":27.49910301738079709821249707601964473724365234375,\"lng\":90.9217795478812860210382496006786823272705078125,\"name\":\"\",\"description\":\"\",\"image\":\"null\"},{\"lat\":27.500041138081623870448311208747327327728271484375,\"lng\":90.923025744620844079690868966281414031982421875,\"name\":\"\",\"description\":\"\",\"image\":\"null\"},{\"lat\":27.511899954584833949411404319107532501220703125,\"lng\":90.9192668017091847332267207093536853790283203125,\"name\":\"\",\"description\":\"\",\"image\":\"null\"},{\"lat\":27.51496473239340190275470376946032047271728515625,\"lng\":90.9076951555821182182626216672360897064208984375,\"name\":\"\",\"description\":\"\",\"image\":\"null\"}]";
                }
                _staticRoute = parseLatLngListFromEncoded(latlnginfo);
                _drawRouteFromStaticList();
              },
            ),
          );
        }

        setState(() {});
      } else {
        debugPrint("Failed to fetch marker data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching marker data: $e");
    }
  }

  void _drawRouteFromStaticList() {
    if (_staticRoute.isEmpty) return;

    setState(() {
      _polylines.clear();
      _markers.clear();

      // Draw the polyline
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('static_route'),
          width: 5,
          color: Colors.blue,
          points: _staticRoute.map((p) => LatLng(p.lat, p.lng)).toList(),
        ),
      );

      // Add markers for each point
      for (int i = 0; i < _staticRoute.length; i++) {
        final point = _staticRoute[i];
        _markers.add(
          Marker(
            markerId: MarkerId('route_point_$i'),
            position: LatLng(point.lat, point.lng),
            infoWindow: InfoWindow(
              title: point.name?.isNotEmpty == true ? point.name : 'Point $i',
            ),
            onTap: () {
              // Show description + image in a dialog
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(
                    point.name?.isNotEmpty == true ? point.name! : 'Point $i',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (point.image != null &&
                            point.image!.isNotEmpty &&
                            point.image != "null")
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Image.network(
                              "http://druknyofoundation.org/public/storage/${point.image!}",                              errorBuilder: (context, error, stackTrace) =>
                              const Text("Image failed to load"),
                            ),
                          ),
                        Text(point.description ?? 'No description available'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Close"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }
    });
  }


  List<RoutePoint> parseLatLngListFromEncoded(String encoded) {
    dynamic firstDecode = json.decode(encoded);

    if (firstDecode is String) {
      // Handles double-encoded JSON
      firstDecode = json.decode(firstDecode);
    }

    final List<dynamic> jsonList = firstDecode;
    return jsonList.map<RoutePoint>((item) => RoutePoint.fromJson(item)).toList();
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType =
          _currentMapType == MapType.normal
              ? MapType.satellite
              : MapType.normal;
    });
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
        title: const Text("EcoTrail Map"),
        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.black),
          onPressed: () {
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
                icon: const Icon(Icons.logout, color: Colors.black),
                onPressed: () async {
                  Utility(context).saveToken("");
                  HomePageState.Token="";
                  await Utility(context).saveEmail("");
                  await Utility(context).saveName("");
                  Navigator.pushReplacement(
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
      body:
          (_currentLocation == null)
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation!,
                      zoom: 13.0,
                    ),
                    onMapCreated: (controller) => _mapController = controller,
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    mapType: _currentMapType,
                  ),
                  Positioned(
                    top: 55,
                    right: 5,
                    child: FloatingActionButton(
                      mini: true,
                      tooltip: "Toggle Satellite View",
                      backgroundColor: Colors.black87,
                      child: const Icon(Icons.layers, color: Colors.white),
                      onPressed: _toggleMapType,
                    ),
                  ),
                ],
              ),
    );
  }
}
