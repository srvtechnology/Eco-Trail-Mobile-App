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

  const MapScreen(this.lat, this.long, this.listcoordinate, {Key? key}) : super(key: key);

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
    var rawData = widget.listcoordinate;
    if (rawData.isNotEmpty) {
      try {
        _staticRoute = parseLatLngListFromEncoded(rawData);
      } catch (_) {
        _staticRoute = [];
      }
    }
    _determinePosition();
  }

  List<LatLng> parseLatLngListFromEncoded(String encoded) {
    final decodedOnce = json.decode(encoded); // Removes the outer escaped string
    final List<dynamic> jsonList = json.decode(decodedOnce); // Actual list

    return jsonList.map<LatLng>((item) {
      return LatLng(item['lat'], item['lng']);
    }).toList();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
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
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );

      if (_staticRoute.isNotEmpty) {
        _addStaticMarkers();
        _drawStaticRoute();
      } else {
        _drawRouteToDestination(LatLng(widget.lat, widget.long));
      }
    });
  }

  void _addStaticMarkers() {
    for (int i = 0; i < _staticRoute.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: _staticRoute[i],
          infoWindow: InfoWindow(title: 'Point ${i + 1}'),
        ),
      );
    }
  }

  void _drawStaticRoute() {
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('static_route'),
        color: Colors.blue,
        width: 5,
        points: _staticRoute,
      ),
    );
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

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
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
                  : (_currentLocation ?? LatLng(widget.lat, widget.long)),
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