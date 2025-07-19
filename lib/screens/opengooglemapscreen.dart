import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenGoogleMapScreen extends StatelessWidget {

  static const String routeName = '/googlemapscreen';
  final String latitude ;
  final String longitude ;

  const OpenGoogleMapScreen(this.latitude,this.longitude,{super.key});

  Future<void> _openGoogleMap(double lat, double lng) async {
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Open Google Map")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _openGoogleMap(double.parse(latitude), double.parse(longitude)),
          child: const Text("Show Location in Google Maps"),
        ),
      ),
    );
  }
}
