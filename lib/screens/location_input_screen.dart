// location_input_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import 'results_screen.dart';

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
      appBar: AppBar(title: const Text('¿Dónde estás o a dónde vas?')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Ciudad o lugar',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submitLocation(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitLocation,
              child: const Text('Buscar clima y recomendaciones'),
            ),
          ],
        ),
      ),
    );
  }
}
