import 'package:flutter/material.dart';
import '../styles/app_styles.dart';

class WeatherCard extends StatelessWidget {
  final String text;
  final int index;
  final DateTime rawDate;
  final IconData icon;

  const WeatherCard({
    super.key,
    required this.text,
    required this.index,
    required this.rawDate,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWeekend =
        rawDate.weekday == DateTime.saturday ||
        rawDate.weekday == DateTime.sunday;
    final bool isToday = index == 0;

    return Card(
      color:
          isWeekend
              ? Colors.orange.shade50
              : isToday
              ? Colors.blue.shade50
              : null,
      child: Padding(
        padding: AppStyles.contentPadding,
        child: Row(
          children: [
            Icon(icon, color: Colors.blueGrey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style:
                    isToday ? AppStyles.sectionTitle : AppStyles.forecastText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
