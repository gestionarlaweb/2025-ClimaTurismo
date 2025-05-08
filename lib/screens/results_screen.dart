// results_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../styles/app_styles.dart';
import 'package:url_launcher/url_launcher.dart';

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
        "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=auto",
      );
      final weatherRes = await http.get(weatherUrl);
      final weatherData = json.decode(weatherRes.body);

      final days = weatherData['daily']['time'] as List;
      final maxTemps = weatherData['daily']['temperature_2m_max'] as List;
      final minTemps = weatherData['daily']['temperature_2m_min'] as List;
      final weatherCodes = weatherData['daily']['weathercode'] as List;

      String getWeatherIcon(int code) {
        if ([0].contains(code)) return '☀️';
        if ([1, 2, 3].contains(code)) return '⛅';
        if ([45, 48].contains(code)) return '🌫️';
        if ([51, 53, 55, 61, 63, 65, 80, 81, 82].contains(code)) return '🌧️';
        if ([71, 73, 75, 85, 86].contains(code)) return '❄️';
        if ([95, 96, 99].contains(code)) return '⛈️';
        return '❓';
      }

      List<String> tempForecast = [];
      for (int i = 0; i < days.length; i++) {
        final icon = getWeatherIcon(weatherCodes[i]);
        final rawDate = DateTime.parse(days[i]);
        const weekdayNames = [
          'Lunes',
          'Martes',
          'Miércoles',
          'Jueves',
          'Viernes',
          'Sábado',
          'Domingo',
        ];
        final weekday = weekdayNames[rawDate.weekday - 1];
        final formattedDate =
            "$weekday ${rawDate.day.toString().padLeft(2, '0')}/${rawDate.month.toString().padLeft(2, '0')}/${rawDate.year}";
        tempForecast.add(
          "$formattedDate: $icon Min ${minTemps[i]}°C / Max ${maxTemps[i]}°C",
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
        final categories = place['categories'] as List<dynamic>;
        final category = categories.isNotEmpty ? categories[0]['name'] : 'Otro';
        final location = place['geocodes']['main'];
        final lat = location['latitude'].toString();
        final lon = location['longitude'].toString();
        categorizedRecommendations.add({
          'name': name,
          'type': category,
          'lat': lat,
          'lon': lon,
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
    }
  }

  void _openMap(String lat, String lon, String title) async {
    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lon",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el mapa.')),
      );
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
                  const Text('Clima semanal:', style: AppStyles.sectionTitle),
                  const SizedBox(height: 10),
                  ...forecast.asMap().entries.map((entry) {
                    final index = entry.key;
                    final text = entry.value;
                    final dateString = text.split(':')[0];
                    final dayParts = dateString.split(' ');
                    final dateParts =
                        dayParts.length > 1 ? dayParts[1].split('/') : [];
                    final rawDate =
                        dateParts.length == 3
                            ? DateTime.parse(
                              "${dateParts[2]}-${dateParts[1]}-${dateParts[0]}",
                            )
                            : DateTime.now();
                    return Card(
                      color:
                          rawDate.weekday == 6 || rawDate.weekday == 7
                              ? Colors.orange.shade50
                              : index == 0
                              ? Colors.blue.shade50
                              : null,
                      child: Padding(
                        padding: AppStyles.contentPadding,
                        child: Text(
                          text,
                          style:
                              index == 0
                                  ? AppStyles.sectionTitle.copyWith(
                                    fontSize: 16,
                                  )
                                  : AppStyles.forecastText.copyWith(
                                    fontSize: 12,
                                  ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  const Text(
                    'Recomendaciones para comer y dormir:',
                    style: AppStyles.sectionTitle,
                  ),
                  ...recommendations.map(
                    (item) => ListTile(
                      leading: IconButton(
                        icon: const Icon(Icons.place, color: Colors.blueAccent),
                        onPressed:
                            () => _openMap(
                              item['lat']!,
                              item['lon']!,
                              item['name']!,
                            ),
                      ),
                      title: Text(
                        item['name'] ?? '',
                        style: AppStyles.placeName,
                      ),
                      subtitle: Text(
                        item['type'] ?? '',
                        style: AppStyles.placeCategory,
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
