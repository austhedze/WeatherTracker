class WeatherData {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final double humidity;
  final double windSpeed;
  final double feelsLike;
  final int conditionId;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
    required this.conditionId,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      humidity: json['main']['humidity'].toDouble(),
      windSpeed: json['wind']['speed'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      conditionId: json['weather'][0]['id'],
    );
  }
}

class ForecastDay {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String icon;
  final int conditionId;

  ForecastDay({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.icon,
    required this.conditionId,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      minTemp: json['temp']['min'].toDouble(),
      maxTemp: json['temp']['max'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      conditionId: json['weather'][0]['id'],
    );
  }
}

class FavoriteCity {
  final String id;
  final String name;
  final int order;

  FavoriteCity({
    required this.id,
    required this.name,
    required this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'order': order,
    };
  }

  factory FavoriteCity.fromJson(Map<String, dynamic> json) {
    return FavoriteCity(
      id: json['id'],
      name: json['name'],
      order: json['order'],
    );
  }
}