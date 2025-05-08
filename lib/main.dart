// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/location_provider.dart';
import 'screens/location_input_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocationProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Clima Turismo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const LocationInputScreen(),
      ),
    );
  }
}
