// data_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';

class DataService {
  static Future<Map<String, dynamic>> fetchWeatherAndPlaces(String city) async {
    final geoUrl = Uri.parse('${ApiConstants.geoBaseUrl}?name=$city&count=1');
    final geoRes = await http.get(geoUrl);
    final geoData = json.decode(geoRes.body);

    if (geoData['results'] == null || geoData['results'].isEmpty) {
      throw Exception('Ciudad no encontrada');
    }

    final lat = geoData['results'][0]['latitude'];
    final lon = geoData['results'][0]['longitude'];

    final weatherUrl = Uri.parse(
      '${ApiConstants.weatherBaseUrl}?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=auto',
    );
    final weatherRes = await http.get(weatherUrl);
    final weatherData = json.decode(weatherRes.body);

    final days = weatherData['daily']['time'] as List;
    final maxTemps = weatherData['daily']['temperature_2m_max'] as List;
    final minTemps = weatherData['daily']['temperature_2m_min'] as List;
    final weatherCodes = weatherData['daily']['weathercode'] as List;

    List<String> forecast = [];
    for (int i = 0; i < days.length; i++) {
      final date = DateTime.parse(days[i]);
      final formattedDate =
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
      final description = ApiConstants.getWeatherDescription(weatherCodes[i]);
      forecast.add(
        '$formattedDate: $description - Min ${minTemps[i]}°C / Max ${maxTemps[i]}°C',
      );
    }

    final placesUrl = Uri.parse(
      ApiConstants.foursquarePlacesUrl(lat.toString(), lon.toString()),
    );
    final placesRes = await http.get(
      placesUrl,
      headers: {'Authorization': ApiConstants.foursquareApiKey},
    );
    final placesData = json.decode(placesRes.body);

    List<Map<String, String>> recommendations = [];
    for (var place in placesData['results']) {
      final name = place['name'];
      final categories = place['categories'] as List<dynamic>;
      final category = categories.isNotEmpty ? categories[0]['name'] : 'Otro';
      final lat = place['geocodes']?['main']?['latitude']?.toString() ?? '';
      final lon = place['geocodes']?['main']?['longitude']?.toString() ?? '';
      recommendations.add({
        'name': name,
        'type': category,
        'lat': lat,
        'lon': lon,
      });
    }

    return {'forecast': forecast, 'recommendations': recommendations};
  }
}
