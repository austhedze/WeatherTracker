// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'screens/home_screen.dart';

// class WeatherTrackerApp extends StatelessWidget {
//   const WeatherTrackerApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Weather Tracker',
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.blue,
//           brightness: Brightness.dark,
//         ),
//         textTheme: GoogleFonts.poppinsTextTheme(
//           Theme.of(context).textTheme,
//         ),
//       ),
//       home: const HomeScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xam_ap/screens/login.dart';
import 'package:xam_ap/screens/register.dart';
import 'package:xam_ap/screens/welcome.dart';

import 'screens/home_screen.dart';


class WeatherTrackerApp extends StatelessWidget {
  const WeatherTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        
        return const WelcomeScreen();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can add a Lottie animation here
            const Icon(
              Icons.cloud,
              color: Colors.white,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'Weather Tracker',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}