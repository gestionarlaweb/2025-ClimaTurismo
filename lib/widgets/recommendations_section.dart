import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../styles/app_styles.dart';
import '../utils/api_constants.dart';

class RecommendationsSection extends StatelessWidget {
  final List<Map<String, String>> recommendations;

  const RecommendationsSection({super.key, required this.recommendations});

  void _openMap(
    BuildContext context,
    String lat,
    String lon,
    String title,
  ) async {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    context,
                    item['lat']!,
                    item['lon']!,
                    item['name']!,
                  ),
            ),
            title: Text(item['name'] ?? '', style: AppStyles.placeName),
            subtitle: Text(item['type'] ?? '', style: AppStyles.placeCategory),
          ),
        ),
      ],
    );
  }
}
