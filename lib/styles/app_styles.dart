import 'package:flutter/material.dart';

class AppStyles {
  static const sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    decoration: TextDecoration.underline,
  );

  static const forecastText = TextStyle(fontSize: 16, color: Colors.black87);

  static const placeName = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static const placeCategory = TextStyle(fontSize: 14, color: Colors.grey);

  static const cardBox = BoxDecoration(
    color: Color(0xFFF1F5FB),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  static const contentPadding = EdgeInsets.all(8);

  // ignore: prefer_typing_uninitialized_variables
  static var inputLabel;

  // ignore: prefer_typing_uninitialized_variables
  static var inputBorder;

  // ignore: prefer_typing_uninitialized_variables
  static var elevatedButton;
}
