import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class LocationProvider extends ChangeNotifier {
  String _city = '';

  String get city => _city;

  void setCity(String value) {
    _city = value;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocationProvider(),
      child: MaterialApp(
        title: 'Clima Turismo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const LocationInputScreen(),
      ),
    );
  }
}

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

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  List<String> forecast = [];
  List<Map<String, String>> recommendations = [];
  bool isLoading = true;
  String error = '';

  final String foursquareApiKey =
      'fsq3iZPlS7grPpoTC2jeY8OLqrvHfwIou61bMJAjfVP+6wI=';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final city = Provider.of<LocationProvider>(context, listen: false).city;

    try {
      final geoUrl = Uri.parse(
        "https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1",
      );
      final geoRes = await http.get(geoUrl);
      final geoData = json.decode(geoRes.body);

      if (geoData['results'] == null || geoData['results'].isEmpty) {
        setState(() {
          error = 'Ciudad no encontrada.';
          isLoading = false;
        });
        return;
      }

      final lat = geoData['results'][0]['latitude'];
      final lon = geoData['results'][0]['longitude'];

      final weatherUrl = Uri.parse(
        "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min&timezone=auto",
      );
      final weatherRes = await http.get(weatherUrl);
      final weatherData = json.decode(weatherRes.body);

      final days = weatherData['daily']['time'] as List;
      final maxTemps = weatherData['daily']['temperature_2m_max'] as List;
      final minTemps = weatherData['daily']['temperature_2m_min'] as List;

      List<String> tempForecast = [];
      for (int i = 0; i < days.length; i++) {
        tempForecast.add(
          '${days[i]}: Min ${minTemps[i]}°C / Max ${maxTemps[i]}°C',
        );
      }

      final placesUrl = Uri.parse(
        "https://api.foursquare.com/v3/places/search?ll=$lat,$lon&categories=13065,19014&radius=1000&limit=10",
      );
      final placesRes = await http.get(
        placesUrl,
        headers: {'Authorization': foursquareApiKey},
      );

      final placesData = json.decode(placesRes.body);
      List<Map<String, String>> categorizedRecommendations = [];
      for (var place in placesData['results']) {
        final name = place['name'];
        final geocodes = place['geocodes']['main'];
        final lat = geocodes['latitude'];
        final lon = geocodes['longitude'];
        final categories = place['categories'] as List<dynamic>;
        final category = categories.isNotEmpty ? categories[0]['name'] : 'Otro';
        categorizedRecommendations.add({
          'name': name,
          'type': category,
          'lat': lat.toString(),
          'lon': lon.toString(),
        });
      }

      setState(() {
        forecast = tempForecast;
        recommendations = categorizedRecommendations;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error al obtener datos.';
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  Future<void> _openMap(String lat, String lon) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir el mapa';
    }
  }

  @override
  Widget build(BuildContext context) {
    final city = Provider.of<LocationProvider>(context).city;

    return Scaffold(
      appBar: AppBar(title: Text('Resultados para "$city"')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error.isNotEmpty
              ? Center(child: Text(error))
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Clima semanal:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...forecast.map(
                    (item) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(item),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Recomendaciones para comer y dormir:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...recommendations.map(
                    (item) => ListTile(
                      leading: IconButton(
                        icon: const Icon(Icons.place),
                        onPressed: () => _openMap(item['lat']!, item['lon']!),
                      ),
                      title: Text(item['name'] ?? ''),
                      subtitle: Text(item['type'] ?? ''),
                    ),
                  ),
                ],
              ),
    );
  }
}
