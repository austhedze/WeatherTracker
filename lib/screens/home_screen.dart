import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:xam_ap/models/weather_models.dart';
import 'package:xam_ap/services/location_services.dart';
import 'package:xam_ap/services/weather_servivces.dart';
import 'package:xam_ap/widgets/forcast_list.dart';
import 'package:xam_ap/widgets/weather_card.dart';
import 'package:xam_ap/services/firebase_service.dart';
import 'package:xam_ap/widgets/favorite_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  WeatherData? _currentWeather;
  List<ForecastDay> _forecast = [];
  bool _isLoading = false;
  String _errorMessage = '';

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _getCurrentLocationWeather();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // for seven-day forecast
  Future<List<ForecastDay>> get7DayForecast(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=YOUR_API_KEY',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<ForecastDay> forecastList = [];

      for (var i = 0; i < data['list'].length; i += 8) {
        // every 8th = ~1 day
        var day = data['list'][i];
        forecastList.add(
          ForecastDay(
            date: DateTime.parse(day['dt_txt']),
            minTemp: day['main']['temp_min'].toDouble(),
            maxTemp: day['main']['temp_max'].toDouble(),
            description: day['weather'][0]['description'],
            icon: day['weather'][0]['icon'],
            conditionId: day['weather'][0]['id'],
          ),
        );
      }

      return forecastList;
    } else {
      throw Exception('Failed to load forecast');
    }
  }

  Future<void> _getCurrentLocationWeather() async {
    debugPrint(" Starting location fetch...");
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint(" Service enabled: $serviceEnabled");

      if (!serviceEnabled) {
        debugPrint(" Location service disabled");
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint("📋 Current permission: $permission");

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint("📋 After request: $permission");
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint(" Permission denied forever");
        await Geolocator.openAppSettings();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      debugPrint(" Got location: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      debugPrint(" Error: $e");
    }
  }

  Future<void> _searchWeather(String cityName) async {
    if (cityName.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final weather = await _weatherService.getCurrentWeather(cityName);
      setState(() {
        _currentWeather = weather;
      });
      _getForecast();
    } catch (e) {
      setState(() {
        _errorMessage = 'City not found. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _searchController.clear();
    }
  }

  Future<void> _getForecast() async {
    if (_currentWeather == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Use actual coordinates from the current weather data
      final forecast = await _weatherService.getSevenDayForecast(
        _currentWeather!.latitude,
        _currentWeather!.longitude,
      );

      setState(() {
        _forecast = forecast;
      });
    } catch (e) {
      debugPrint("❌ Failed to fetch forecast: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _getWeatherIcon(int conditionId) {
    IconData icon;
    Color color;

    if (conditionId < 300) {
      // Thunderstorm
      icon = Icons.thunderstorm;
      color = Colors.deepPurple;
    } else if (conditionId < 400) {
      // Drizzle
      icon = Icons.grain;
      color = Colors.blueGrey;
    } else if (conditionId < 600) {
      // Rain
      icon = Icons.beach_access;
      color = Colors.blue;
    } else if (conditionId < 700) {
      // Snow
      icon = Icons.ac_unit;
      color = Colors.lightBlue;
    } else if (conditionId < 800) {
      // Atmosphere (Fog, Mist, etc.)
      icon = Icons.blur_on;
      color = Colors.grey;
    } else if (conditionId == 800) {
      // Clear
      icon = Icons.wb_sunny;
      color = Colors.amber;
    } else if (conditionId < 900) {
      // Clouds
      icon = Icons.cloud;
      color = Colors.grey;
    } else {
      // Default
      icon = Icons.help_outline;
      color = Colors.white;
    }

    return RotationTransition(
      turns: _animation,
      child: ScaleTransition(
        scale: _animation.drive(Tween<double>(begin: 0.8, end: 1.2)),
        child: FadeTransition(
          opacity: _animation.drive(Tween<double>(begin: 0.6, end: 1.0)),
          child: Icon(icon, color: color, size: 60),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: FavoriteDrawer(
        firebaseService: _firebaseService,
        onCitySelected: _searchWeather,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade800,
              Colors.black,
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar with improved text visibility
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final opacity =
                      (constraints.maxHeight - kToolbarHeight) /
                      (140 - kToolbarHeight);
                  return Stack(
                    children: [
                      // Background with gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.blue.shade900.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // Weather Icon
                      if (_currentWeather != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: _getWeatherIcon(
                              _currentWeather!.conditionId,
                            ),
                          ),
                        ),

                      // Title with better visibility
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            _currentWeather?.cityName ?? 'Weather Tracker',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _getCurrentLocationWeather,
                ),
              ],
            ),

            // Main Content
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 20),

                      // Loading State
                      if (_isLoading) _buildLoadingIndicator(),

                      // Error State
                      if (_errorMessage.isNotEmpty) _buildErrorWidget(),

                      // Weather Content
                      if (_currentWeather != null && !_isLoading) ...[
                        // Current Weather Card
                        WeatherCard(weather: _currentWeather!),
                        const SizedBox(height: 24),

                        // 7-Day Forecast
                        if (_forecast.isNotEmpty)
                          ForecastList(forecast: _forecast),
                      ] else if (!_isLoading && _errorMessage.isEmpty) ...[
                        // Empty State
                        _buildEmptyState(),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search city...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
          suffixIcon: IconButton(
            icon: Icon(
              CupertinoIcons.paperplane,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: () => _searchWeather(_searchController.text),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
        style: const TextStyle(color: Colors.white),
        onSubmitted: _searchWeather,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          LoadingAnimationWidget.twistingDots(
            leftDotColor: Colors.white,
            rightDotColor: Colors.blue.shade300,
            size: 80,
          ),
          const SizedBox(height: 20),
          Text(
            'Loading weather data...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          RotationTransition(
            turns: _animation,
            child: const Icon(
              Icons.location_searching,
              color: Colors.white54,
              size: 80,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Search for a city or allow location access',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Get started by searching above',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
