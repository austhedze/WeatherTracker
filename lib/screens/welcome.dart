import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Track Weather Anywhere',
      'subtitle': 'Get accurate weather forecasts for any location worldwide',
      'icon': Icons.public,
      'color': Colors.blue,
    },
    {
      'title': '7-Day Forecast',
      'subtitle': 'Plan your week with detailed weather predictions',
      'icon': Icons.calendar_today,
      'color': Colors.green,
    },
    {
      'title': 'Save Favorite Locations',
      'subtitle': 'Quickly access weather for your most visited places',
      'icon': Icons.favorite,
      'color': Colors.red,
    },
    {
      'title': 'Real-time Updates',
      'subtitle': 'Stay informed with live weather data and alerts',
      'icon': Icons.notifications_active,
      'color': Colors.amber,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 16.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      'Skip',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              // Page View
              Expanded(
                flex: 3,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingData.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_onboardingData[index]);
                  },
                ),
              ),

              // Dots Indicator
              _buildDotsIndicator(),

              // Get Started Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                width: double.infinity,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        Navigator.pushNamed(context, '/register');
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      _currentPage == _onboardingData.length - 1 
                          ? 'Get Started' 
                          : 'Next',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Already have account
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.poppins(
                          color: Colors.blue.shade300,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Icon
            ScaleTransition(
              scale: _animation.drive(
                Tween<double>(begin: 0.9, end: 1.1),
              ),
              child: FadeTransition(
                opacity: _animation.drive(
                  Tween<double>(begin: 0.8, end: 1.0),
                ),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: data['color'].withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: data['color'].withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    data['icon'],
                    color: data['color'],
                    size: 60,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                data['title'],
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                data['subtitle'],
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_onboardingData.length, (index) {
          final isActive = _currentPage == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 20 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive 
                  ? Colors.blue.shade400 
                  : Colors.white.withOpacity(0.4),
            ),
          );
        }),
      ),
    );
  }
}