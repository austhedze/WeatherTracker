import 'package:flutter/material.dart';
import '../models/weather_models.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData weather;

  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Temperature and Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${weather.temperature.round()}°',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Image.network(
                'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                width: 80,
                height: 80,
              ),
            ],
          ),
          // Description
          Text(
            weather.description.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          // Weather Details
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildDetailCard('Feels Like', '${weather.feelsLike.round()}°', Icons.thermostat),
              _buildDetailCard('Humidity', '${weather.humidity.round()}%', Icons.water_drop),
              _buildDetailCard('Wind Speed', '${weather.windSpeed} m/s', Icons.air),
              _buildDetailCard('Condition', weather.description, Icons.cloud),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 24),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}