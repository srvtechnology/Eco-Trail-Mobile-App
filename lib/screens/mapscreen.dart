import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../model/mapmodel.dart';

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
  List<MapPoint> _mapPoints = [];

  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    if (widget.listcoordinate.isNotEmpty) {
      try {
        _mapPoints = parseMapPoints(widget.listcoordinate);
      } catch (_) {
        _mapPoints = [];
      }
    }
    _determinePosition();
  }

  // ✅ Parse single or double-encoded coordinate data
  List<MapPoint> parseMapPoints(String encoded) {
    try {
      dynamic decoded = json.decode(encoded);
      if (decoded is String) decoded = json.decode(decoded);

      if (decoded is List) {
        return decoded.map<MapPoint>((item) {
          final lat =
              (item['lat'] is num)
                  ? item['lat'].toDouble()
                  : double.tryParse(item['lat'].toString()) ?? 0.0;
          final lng =
              (item['lng'] is num)
                  ? item['lng'].toDouble()
                  : double.tryParse(item['lng'].toString()) ?? 0.0;

          return MapPoint(
            position: LatLng(lat, lng),
            name: item['name']?.toString() ?? "Unnamed Point",
            description:
                item['description']?.toString() ?? "No description available",
            image: "http://druknyofoundation.org/public/storage/${item['image']?.toString()}",
          );
        }).toList();
      }

      print("⚠️ Unexpected structure for encoded coordinates");
      return [];
    } catch (e) {
      print("❌ Error parsing map points: $e");
      return [];
    }
  }

  // ✅ Get current position
  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
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
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );

      if (_mapPoints.isNotEmpty) {
        _addStaticMarkers();
        _drawStaticRoute();
      } else {
        _drawRouteToDestination(LatLng(widget.lat, widget.long));
      }
    });
  }

  // ✅ Add markers for static route points
  void _addStaticMarkers() {
    for (int i = 0; i < _mapPoints.length; i++) {
      final point = _mapPoints[i];
      _markers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: point.position,
          infoWindow: InfoWindow(
            title: point.name,
            onTap: () {
              _showInfoDialog(point);
            },
          ),
        ),
      );
    }
  }

  // ✅ Draw static route polyline
  void _drawStaticRoute() {
    final points = _mapPoints.map((p) => p.position).toList();
    if (points.isNotEmpty) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('static_route'),
          color: Colors.blue,
          width: 5,
          points: points,
        ),
      );
    }
  }

  // ✅ Dialog for marker info
  void _showInfoDialog(MapPoint point) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (point.image != null &&
                  point.image!.isNotEmpty &&
                  point.image != "null")
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    "${point.image}",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                    errorBuilder:
                        (_, __, ___) => Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      point.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Dynamic route (if static route not available)
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

  // ✅ Fetch directions from Google API
  Future<List<LatLng>> _getRouteCoordinates(
    LatLng origin,
    LatLng destination,
  ) async {
    const String apiKey =
        'AIzaSyB-ocv6g9BGI80S68ok6Cjjp2xvLqcLEs4'; // Replace with your actual key
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

  // ✅ Decode Google Polyline
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
      _currentMapType =
          _currentMapType == MapType.normal
              ? MapType.satellite
              : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EcoTrail Map")),
      body:
          (_currentLocation == null)
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target:
                          _mapPoints.isNotEmpty
                              ? _mapPoints.first.position
                              : (_currentLocation ??
                                  LatLng(widget.lat, widget.long)),
                      zoom: 14.0,
                    ),
                    onMapCreated: (controller) => _mapController = controller,
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
