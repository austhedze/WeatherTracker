

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_models.dart';

// Service to fetch weather data from OpenWeatherMap API
class WeatherService {
  static const String apiKey = '9ce2336ea646f55d61cbb029a0e27694';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Get current weather by city name
  Future<WeatherData> getCurrentWeather(String cityName) async {
    final response = await http.get(
      Uri.parse('$baseUrl/weather?q=$cityName&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  /// Get current weather by coordinates
  Future<WeatherData> getWeatherByCoordinates(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  /// Get 5-day forecast by coordinates
  /// Groups forecast data by day and returns min/max temperatures
  Future<List<ForecastDay>> getFiveDayForecast(double lat, double lon) async {
    final url = Uri.parse(
      '$baseUrl/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List forecasts = data['list'];

      // Group forecasts by date
      Map<String, List<dynamic>> grouped = {};

      for (var entry in forecasts) {
        String date = DateTime.fromMillisecondsSinceEpoch(
          entry['dt'] * 1000,
          isUtc: true,
        ).toLocal().toString().split(' ')[0];

        grouped.putIfAbsent(date, () => []).add(entry);
      }

      // Calculate min/max for each day
      List<ForecastDay> result = [];

      grouped.forEach((date, entries) {
        double minTemp = entries
            .map((e) => e['main']['temp_min'].toDouble())
            .reduce((a, b) => a < b ? a : b);
        double maxTemp = entries
            .map((e) => e['main']['temp_max'].toDouble())
            .reduce((a, b) => a > b ? a : b);

        var first = entries.first;
        result.add(
          ForecastDay(
            date: DateTime.parse(date),
            minTemp: minTemp,
            maxTemp: maxTemp,
            description: first['weather'][0]['description'],
            icon: first['weather'][0]['icon'],
            conditionId: first['weather'][0]['id'],
          ),
        );
      });

      // Limit to 5 days
      return result.take(5).toList();
    } else {
      throw Exception('Failed to load forecast');
    }
  }

  /// Alternative method name for backward compatibility
  @Deprecated('Use getWeatherByCoordinates instead')
  Future<WeatherData> getWeatherByLocation(double lat, double lon) async {
    return getWeatherByCoordinates(lat, lon);
  }

  /// Alternative method for 7-day forecast (returns 5 days due to API limitations)
  @Deprecated('Use getFiveDayForecast instead')
  Future<List<ForecastDay>> getSevenDayForecast(double lat, double lon) async {
    return getFiveDayForecast(lat, lon);
  }
}