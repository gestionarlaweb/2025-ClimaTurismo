// location_input_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../screens/results_screen.dart';
import '../styles/app_styles.dart';

class LocationInputScreen extends StatefulWidget {
  const LocationInputScreen({super.key});

  @override
  State<LocationInputScreen> createState() => _LocationInputScreenState();
}

class _LocationInputScreenState extends State<LocationInputScreen> {
  final TextEditingController _controller = TextEditingController();

  void _submitLocation() {
    final city = _controller.text.trim();
    if (city.isNotEmpty) {
      Provider.of<LocationProvider>(context, listen: false).setCity(city);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ResultsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '¿Dónde estás o a dónde vas?',
          style: AppStyles.sectionTitle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Ciudad o lugar',
                labelStyle: AppStyles.inputLabel,
                border: AppStyles.inputBorder,
                focusedBorder: AppStyles.inputBorder,
              ),
              onSubmitted: (_) => _submitLocation(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitLocation,
              style: AppStyles.elevatedButton,
              child: const Text(
                'Buscar clima y recomendaciones',
                style: AppStyles.forecastText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
