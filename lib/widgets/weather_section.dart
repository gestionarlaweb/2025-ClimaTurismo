import 'package:flutter/material.dart';
import '../styles/app_styles.dart';

class WeatherSection extends StatelessWidget {
  final List<String> forecast;

  const WeatherSection({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Clima semanal:', style: AppStyles.sectionTitle),
        const SizedBox(height: 10),
        ...forecast.asMap().entries.map((entry) {
          final index = entry.key;
          final text = entry.value;
          final dateString = text.split(':')[0];
          final dayParts = dateString.split(' ');
          final dateParts = dayParts.length > 1 ? dayParts[1].split('/') : [];
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
                        ? AppStyles.sectionTitle.copyWith(fontSize: 16)
                        : AppStyles.forecastText.copyWith(fontSize: 12),
              ),
            ),
          );
        }),
      ],
    );
  }
}
