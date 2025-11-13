import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPoint {
  final LatLng position;      // The point’s coordinates (latitude + longitude)
  final String name;          // The title of the point
  final String description;   // A text description shown in the dialog
  final String? image;        // Optional image URL (nullable)

  MapPoint({
    required this.position,
    required this.name,
    required this.description,
    this.image,
  });
}
