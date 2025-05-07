// location_provider.dart
import 'package:flutter/material.dart';

class LocationProvider extends ChangeNotifier {
  String _city = '';

  String get city => _city;

  void setCity(String value) {
    _city = value;
    notifyListeners();
  }
}
