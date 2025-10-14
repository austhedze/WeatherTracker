// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:xam_ap/pages/home_page.dart';
// import 'package:xam_ap/pages/login_page.dart';

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // Show loading indicator while checking auth state
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//               ),
//             ),
//           );
//         }

//         // Show login if not authenticated
//         if (!snapshot.hasData) {
//           return const LoginScreen();
//         }

//         // Show home screen if authenticated
//         return const HomeScreen();
//       },
//     );
//   }
// }