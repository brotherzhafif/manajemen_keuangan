import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import the screen locations
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a base text theme to be used by GoogleFonts

    return MaterialApp(
      title: 'FinTracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Correctly apply the Poppins font without the problematic context call
        textTheme: GoogleFonts.poppinsTextTheme(
          Typography.englishLike2018.apply(fontSizeFactor: 1.0),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF47663C),
          primary: const Color(0xFF47663C),
        ),
      ),
      // Set the initial route and define all routes
      initialRoute: '/', // Mengubah rute awal ke halaman login
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => ProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
