// lib/utils/weather_icons.dart
String getWeatherIcon(int code) {
  if ([0].contains(code)) return '☀️'; // Soleado
  if ([1, 2, 3].contains(code)) return '⛅'; // Parcialmente nublado
  if ([45, 48].contains(code)) return '🌫️'; // Niebla
  if ([51, 53, 55, 61, 63, 65, 80, 81, 82].contains(code)) {
    return '🌧️'; // Lluvia
  }
  if ([71, 73, 75, 85, 86].contains(code)) return '❄️'; // Nieve
  if ([95, 96, 99].contains(code)) return '⛈️'; // Tormenta
  return '❓'; // Desconocido
}
