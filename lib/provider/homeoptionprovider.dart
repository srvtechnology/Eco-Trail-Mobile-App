import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/categorymodel.dart';
import '../model/placemodel.dart';
import '../util/constants.dart';  // for token utilities if needed
import '../util/utility.dart';   // for getToken

class HomeOptionProvider extends ChangeNotifier {
  bool _isApiCallProcess = false;
  bool get isApiCallProcess => _isApiCallProcess;
  List<Data> _categoryList = [];
  List<Data> get categoryList => _categoryList;

  List<Datum> _placeList = [];
  List<Datum> get placeList => _placeList;


  set placeList(List<Datum> value) {
    _placeList = value;
  }

  void setApiCallProcess(bool isDone) {
    _isApiCallProcess = isDone;
    notifyListeners();
  }
  Future<void> fetchCategories(BuildContext context) async {
    setApiCallProcess(true);

    final token = await Utility(context).getToken(); // if you use auth token
    final url = Uri.parse('http://druknyofoundation.org/public/api/space-categories');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // include if required
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final categoryModel = CategoryModel.fromJson(jsonResponse);

        _categoryList = [
          Data(
            id: 0,
            name: "All",
            shortDescription: "All Categories",
            longDescription: "",
          ),
          ...?categoryModel.data,
        ];
       // _categoryList = categoryModel.data ?? [];
      } else {
        debugPrint("Failed to fetch categories: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }

    setApiCallProcess(false);
  }
  Future<void> fetchPlacesByCategory(BuildContext context, bool isHome,{int? categoryId}) async {
    setApiCallProcess(true);
    final token = await Utility(context).getToken();

    // Build URI with 'all=true' and optional 'category_id'
    final Uri uri = Uri.parse("http://druknyofoundation.org/public/api/eco-trail/main-spaces")
        .replace(queryParameters: {
      isHome ? "":'all': 'true',
      if (categoryId != null && categoryId != 0) 'category_id': categoryId.toString(),
    });
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final placeModel = PlaceModel.fromJson(jsonBody);
        placeList = placeModel.data;
      } else {
        debugPrint("Failed to fetch places. Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error during fetchPlacesByCategory: $e");
    }

    setApiCallProcess(false);
    notifyListeners();
  }


}
