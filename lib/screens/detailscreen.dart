import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../model/placemodel.dart';
import '../util/Constants.dart';
import 'mapscreen.dart';

class DetailScreen extends StatefulWidget {

  static const String routeName = '/detailscreen';
  final String id;
  final Datum datum;

  const DetailScreen(this.id, this.datum, {super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final PageController _pageController;
  late List<String> _imageList;
  List<Map<String, dynamic>> _aboutInfoList = [];
  List<Map<String, dynamic>> highlightedinfolist=[];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _imageList = parseGalleryImages(widget.datum.galleryImages);
    _aboutInfoList = parseAboutInfo(widget.datum.aboutInfo);
    highlightedinfolist=parseHighlightInfo(widget.datum.highlightInfo);
    print("$_imageList $_aboutInfoList $highlightedinfolist");
  }


  List<Map<String, dynamic>> parseHighlightInfo(String? rawHighlightInfo) {
    try {
      if (rawHighlightInfo == null) return [];

      // First decode: turns it into a valid JSON string
      final String firstDecoded = jsonDecode(rawHighlightInfo);

      // Second decode: turns the JSON string into a list of maps
      final List<dynamic> secondDecoded = jsonDecode(firstDecoded);

      return secondDecoded.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint("Error parsing highlight_info: $e");
      return [];
    }
  }

  List<Map<String, dynamic>> parseAboutInfo(String? rawAboutInfo) {
    try {
      if (rawAboutInfo == null) return [];

      final firstDecoded = jsonDecode(rawAboutInfo); // Remove outer quotes
      final List<dynamic> secondDecoded = jsonDecode(firstDecoded); // Actual JSON list

      return secondDecoded.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint("Error parsing about_info: $e");
      return [];
    }
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> parseGalleryImages(List<String> rawGallery) {
    return rawGallery.map((e) => "http://druknyofoundation.org/public/storage/$e").toList();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      width: double.infinity,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _imageList.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            _imageList[index],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: _imageList.length,
                        effect: const WormEffect(
                          dotColor: Colors.white70,
                          activeDotColor: Colors.greenAccent,
                          dotHeight: 8,
                          dotWidth: 8,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.greenAccent),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  widget.datum.latitude==null && widget.datum.longitude==null ? SizedBox():Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {

                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => MapScreen(double.parse(widget.datum.latitude!),double.parse(widget.datum.longitude!),widget.datum.latlong_info??"")));         },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 16,
                        child: Icon(Icons.location_pin,color: Colors.greenAccent,),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: highlightedinfolist.map((item) {
                  final title = item['title'] ?? '';
                  final detail = item['detail'] ?? '';
                  return InfoChip(label: title, value: detail);
                }).toList(),
              )
            ),
            const SizedBox(height: 20),
            // About Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: bold, fontSize: 18)),
                      const SizedBox(height: 8),

                      ..._aboutInfoList.map((item) {
                        final title = item['title'] ?? '';
                        final detail = item['detail'] ?? '';
                        return InfoText(label: title, value: detail);
                      }).toList(),

                      const SizedBox(height: 20),

                      const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      Html(
                        data: widget.datum.description ?? '',
                        style: {
                          'body': Style(
                            fontSize: FontSize(14),
                            color: Colors.black87,
                            margin: Margins.only(bottom: 20),
                          ),
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const InfoChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, // fixed width
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 100,
            child: GestureDetector(
              onTap: () {

                if(value.length>6){
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Full Text'),
                      content: Text(value),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                }

              },
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )

        ],
      ),
    );
  }
}



class InfoText extends StatelessWidget {
  final String label;
  final String value;

  const InfoText({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:',style: const TextStyle(fontWeight: FontWeight.w500,fontFamily: regular))),
          Expanded(child: Text(value,style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)),
        ],
      ),
    );
  }
}
