import 'dart:convert';
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
  List<LatLng> _staticRoute = [];
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
                  latlnginfo =
                      "\"[{\\\"lat\\\":27.54875757222691,\\\"lng\\\":90.7560361217041},{\\\"lat\\\":27.54875757222691,\\\"lng\\\":90.7571519206543},{\\\"lat\\\":27.548300977297572,\\\"lng\\\":90.75796731219482},{\\\"lat\\\":27.547425831710992,\\\"lng\\\":90.75796731219482}]\"";
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

  List<LatLng> parseLatLngListFromEncoded(String encoded) {
    final decodedOnce = json.decode(encoded); // Removes outer quotes
    final List<dynamic> jsonList = json.decode(decodedOnce); // Parses the array
    return jsonList
        .map<LatLng>((item) => LatLng(item['lat'], item['lng']))
        .toList();
  }

  void _drawRouteFromStaticList() {
    if (_staticRoute.isEmpty) return;

    setState(() {
      _polylines.clear();
      _markers.removeWhere((m) => m.markerId.value == 'route_end');

      _polylines.add(
        Polyline(
          polylineId: const PolylineId('static_route'),
          width: 5,
          color: Colors.blue,
          points: _staticRoute,
        ),
      );

      _markers.add(
        Marker(
          markerId: const MarkerId('route_end'),
          position: _staticRoute.last,
          infoWindow: const InfoWindow(title: "Route End"),
        ),
      );
    });
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
