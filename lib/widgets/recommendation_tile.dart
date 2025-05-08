import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../styles/app_styles.dart';
import '../utils/api_constants.dart';

class RecommendationTile extends StatelessWidget {
  final String name;
  final String type;
  final String lat;
  final String lon;
  final String mapsUrl;

  const RecommendationTile({
    super.key,
    required this.name,
    required this.type,
    required this.lat,
    required this.lon,
    required this.mapsUrl,
  });

  void _openMap(BuildContext context) async {
    final uri = Uri.parse(ApiConstants.googleMapsUrl(lat, lon));
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
    return ListTile(
      leading: IconButton(
        icon: const Icon(Icons.place, color: Colors.blueAccent),
        onPressed: () => _openMap(context),
      ),
      title: Text(name, style: AppStyles.placeName),
      subtitle: Text(type, style: AppStyles.placeCategory),
    );
  }
}
