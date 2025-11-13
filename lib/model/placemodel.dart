import 'dart:convert';

import 'package:ecotrail/screens/homescreen.dart';

class PlaceModel {
  PlaceModel({
    required this.status,
    required this.data,
  });

  final String? status;
  final List<Datum> data;

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final nestedData = json["data"];
    final placeList = nestedData is List
        ? nestedData.map((x) => Datum.fromJson(x)).toList()
        : <Datum>[];

    return PlaceModel(
      status: json["status"],
      data: placeList,
    );
  }
}

class Datum {
  Datum({
    required this.id,
    required this.placeName,
    required this.description,
    required this.categoryId,
    required this.latitude,
    required this.longitude,
    required this.googleMapsLink,
    required this.fullAddress,
    required this.featuredImage,
    required this.galleryImages,
    required this.highlightInfo,
    required this.latlong_info,
    required this.aboutInfo,
    required this.createdAt,
    required this.updatedAt,
    required this.catDetails,
  });

  final int? id;
  final String? placeName;
  final String? description;
  final int? categoryId;
  final String? latitude;
  final String? longitude;
  final dynamic googleMapsLink;
  final String? fullAddress;
  final String? featuredImage;
  final List<String> galleryImages;
  final String? highlightInfo;
  final String? latlong_info;
  final String? aboutInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CatDetails? catDetails;

  factory Datum.fromJson(Map<String, dynamic> json) {
    List<String> parsedGallery = [];
    try {
      parsedGallery = List<String>.from(jsonDecode(json["gallery_images"] ?? "[]"));
    } catch (_) {}

    List<TInfo> parsedHighlight = [];
    try {
      parsedHighlight = List<TInfo>.from(jsonDecode(json["highlight_info"] ?? "[]").map((x) => TInfo.fromJson(x)));
    } catch (_) {}

    return Datum(
      id: json["id"],
      placeName: json["place_name"],
      description: json["description"],
      categoryId: json["category_id"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      googleMapsLink: json["google_maps_link"],
      fullAddress: json["full_address"],
      featuredImage: json["featured_image"],
      galleryImages: parsedGallery,
      highlightInfo: json["highlight_info"],
      latlong_info: json["latlong_info"],
      aboutInfo:  json["about_info"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      catDetails: json["cat_details"] == null ? null : CatDetails.fromJson(json["cat_details"]),
    );
  }
}

class TInfo {
  TInfo({
    required this.title,
    required this.detail,
  });

  final String? title;
  final String? detail;

  factory TInfo.fromJson(Map<String, dynamic> json) {
    return TInfo(
      title: json["title"],
      detail: json["detail"],
    );
  }
}

class CatDetails {
  CatDetails({
    required this.id,
    required this.name,
    required this.longDescription,
    required this.shortDescription,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String? name;
  final String? longDescription;
  final String? shortDescription;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CatDetails.fromJson(Map<String, dynamic> json) {
    return CatDetails(
      id: json["id"],
      name: json["name"],
      longDescription: json["long_description"],
      shortDescription: json["short_description"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
    );
  }
}
