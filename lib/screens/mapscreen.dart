import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  static const String routeName = '/mapoption';
  final double lat;
  final double long;
  final String listcoordinate;

  const MapScreen(this.lat, this.long, this.listcoordinate, {Key? key})
      : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _staticRoute = [];

  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    if (widget.listcoordinate.isNotEmpty) {
      try {
        _addCustomMarkers(widget.listcoordinate);
        _staticRoute = _parseLatLngList(widget.listcoordinate);
        if (_staticRoute.isNotEmpty) {
          _addStaticMarkers();
          _drawStaticRoute();
        } else {
          _drawRouteToDestination(LatLng(widget.lat, widget.long));
        }
      } catch (_) {
        _staticRoute = [];
      }
    }
    _determinePosition();
  }


  /// Parse LatLng only (for drawing polyline/zoom)
  List<LatLng> _parseLatLngList(String encoded) {
    final List<dynamic> jsonList = json.decode(encoded);
    return jsonList
        .map((item) => LatLng(item['lat'], item['lng']))
        .toList();
  }

  /// Add Markers with dialog on tap
  void _addCustomMarkers(String encoded) {
    final List<dynamic> jsonList = json.decode(encoded);

    for (int i = 0; i < jsonList.length; i++) {
      final item = jsonList[i];
      final LatLng position = LatLng(item['lat'], item['lng']);
      final String title =
      (item['name'] as String).isNotEmpty ? item['name'] : "Point ${i + 1}";
      final String description = item['description'] ?? "";
      final String imageUrl = "http://druknyofoundation.org/public/storage/${item['image']}" ?? "";

      _markers.add(
        Marker(
          markerId: MarkerId('marker_$i'),
          position: position,
          onTap: () {
            _showLocationDialog(title, description, imageUrl);
          },
        ),
      );

      if (_staticRoute.isNotEmpty) {
        _addStaticMarkers();
        _drawStaticRoute();
      } else {
        _drawRouteToDestination(LatLng(widget.lat, widget.long));
      }
    }
  }

  void _drawStaticRoute() {
    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('static_route'),
          color: Colors.blue,
          width: 5,
          points: _staticRoute,
        ),
      );
    });
  }

  void _addStaticMarkers() {
    setState(() {
      for (int i = 0; i < _staticRoute.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId('stop_$i'),
            position: _staticRoute[i],
            infoWindow: InfoWindow(title: 'Point ${i + 1}'),
          ),
        );
      }
    });
  }


  Future<void> _drawRouteToDestination(LatLng destination) async {
    if (_currentLocation == null) return;

    final points = await _getRouteCoordinates(_currentLocation!, destination);

    if (points.isNotEmpty) {
      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('dynamic_route'),
            width: 5,
            color: Colors.blue,
            points: points,
          ),
        );
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: destination,
            infoWindow: const InfoWindow(title: 'Destination'),
          ),
        );
      });
    }
  }

  Future<List<LatLng>> _getRouteCoordinates(LatLng origin, LatLng destination) async {
    const String apiKey = 'AIzaSyB-ocv6g9BGI80S68ok6Cjjp2xvLqcLEs4'; // Replace with your actual key
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final jsonResponse = json.decode(response.body);

    if (jsonResponse['status'] == 'OK') {
      final encoded = jsonResponse['routes'][0]['overview_polyline']['points'];
      return _decodePolyline(encoded);
    } else {
      print('Directions API Error: ${jsonResponse['status']}');
      return [];
    }
  }


  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }


  // Show dialog with image + description...
  void _showLocationDialog(String title, String description, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if (imageUrl.isNotEmpty && imageUrl != "null")
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Text("Image not available"));
                      },
                    ),
                  ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      description.isNotEmpty ? description : "No description available",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Get current location...
  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentLocation = LatLng(position.latitude, position.longitude);

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure),
        ),
      );
    });
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Map - Static/Dynamic Route")),
      body: (_currentLocation == null)
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _staticRoute.isNotEmpty
                  ? _staticRoute.first
                  : (_currentLocation ??
                  LatLng(widget.lat, widget.long)),
              zoom: 15.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            mapType: _currentMapType,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
            polylines: _polylines,
          ),
          Positioned(
            top: 55,
            right: 5,
            child: FloatingActionButton(
              onPressed: _toggleMapType,
              child: const Icon(Icons.layers),
              backgroundColor: Colors.black,
              mini: true,
              tooltip: 'Toggle Map Type',
            ),
          ),
        ],
      ),
    );
  }
}
