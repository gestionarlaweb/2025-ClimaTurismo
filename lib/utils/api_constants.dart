class ApiConstants {
  static const String geoBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String foursquareBaseUrl =
      'https://api.foursquare.com/v3/places/search';

  static const String restaurantCategory = '13065'; // Restaurantes
  static const String hotelCategory = '19014'; // Alojamiento

  static const String foursquareApiKey =
      'fsq3iZPlS7grPpoTC2jeY8OLqrvHfwIou61bMJAjfVP+6wI=';

  static String foursquarePlacesUrl(String lat, String lon) {
    return '$foursquareBaseUrl?ll=$lat,$lon';
  }

  static String googleMapsUrl(String lat, String lon) =>
      'https://www.google.com/maps/search/?api=1&query=$lat,$lon';

  static String getWeatherDescription(int code) {
    if (code == 0) return 'Despejado';
    if ([1, 2].contains(code)) return 'Parcialmente nublado';
    if (code == 3) return 'Nublado';
    if ([45, 48].contains(code)) return 'Niebla';
    if ([51, 53, 55, 61, 63, 65, 80, 81, 82].contains(code)) return 'Lluvia';
    if ([71, 73, 75, 85, 86].contains(code)) return 'Nieve';
    if ([95, 96, 99].contains(code)) return 'Tormenta';
    return 'Desconocido';
  }
}
