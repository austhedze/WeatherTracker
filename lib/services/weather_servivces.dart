import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_models.dart';

// Service to fetch weather data from OpenWeatherMap API
class WeatherService {
  static const String apiKey = '9ce2336ea646f55d61cbb029a0e27694';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

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


// Assuming the JSON structure from OpenWeatherMap's forecast API

  Future<List<ForecastDay>> getSevenDayForecast(double lat, double lon) async {
  final response = await http.get(
    Uri.parse('$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&cnt=7'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    List<ForecastDay> forecast = [];
    for (var item in data['list']) {
      forecast.add(ForecastDay.fromJson(item));
    }
    return forecast;
  } else {
    throw Exception('Failed to load forecast data');
  }
}


  Future<WeatherData> getWeatherByLocation(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}