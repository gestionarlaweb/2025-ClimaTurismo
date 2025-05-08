import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../styles/app_styles.dart';
import '../services/data_service.dart';
import '../widgets/weather_card.dart';
import '../widgets/recommendation_tile.dart';
import '../utils/api_constants.dart';

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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final city = Provider.of<LocationProvider>(context, listen: false).city;

    try {
      final data = await DataService.fetchWeatherAndPlaces(city);
      setState(() {
        forecast = data['forecast'] as List<String>;
        recommendations = data['recommendations'] as List<Map<String, String>>;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error al obtener datos.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final city = Provider.of<LocationProvider>(context).city;

    return Scaffold(
      appBar: AppBar(title: Text('Clima en $city')),
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

                    final dateMatch = RegExp(
                      r'\d{2}/\d{2}/\d{4}',
                    ).firstMatch(text);
                    final rawDate =
                        dateMatch != null
                            ? DateTime.parse(
                              dateMatch.group(0)!.split('/').reversed.join('-'),
                            )
                            : DateTime.now();
                    final dayName = _getDayName(rawDate.weekday);
                    final weatherIcon = _getWeatherIcon(text);

                    return WeatherCard(
                      text: "$dayName, $text",
                      index: index,
                      rawDate: rawDate,
                      icon: weatherIcon,
                    );
                  }),
                  const SizedBox(height: 20),
                  const Text(
                    'Donde comer o dormir:',
                    style: AppStyles.sectionTitle,
                  ),
                  ...recommendations.map(
                    (item) => RecommendationTile(
                      name: item['name'] ?? '',
                      type: item['type'] ?? '',
                      lat: item['lat'] ?? '',
                      lon: item['lon'] ?? '',
                      mapsUrl: ApiConstants.googleMapsUrl(
                        item['lat'] ?? '',
                        item['lon'] ?? '',
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  String _getDayName(int weekday) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return days[(weekday - 1) % 7];
  }

  IconData _getWeatherIcon(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('lluvia')) {
      return Icons.umbrella;
    } else if (lower.contains('nublado') || lower.contains('nube')) {
      return Icons.cloud;
    } else {
      return Icons.wb_sunny;
    }
  }
}
