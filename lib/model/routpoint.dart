class RoutePoint {
  final double lat;
  final double lng;
  final String? name;
  final String? description;
  final String? image;

  RoutePoint({
    required this.lat,
    required this.lng,
    this.name,
    this.description,
    this.image,
  });

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
    );
  }
}
