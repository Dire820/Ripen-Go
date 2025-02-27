// filepath: /c:/Users/josia/Documents/Josiah/Flutter/capstone/ripen_go/lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'login.dart';
import 'signup.dart';
import 'firebase_options.dart' show DefaultFirebaseOptions;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const RipeNGoApp());
}

class RipeNGoApp extends StatelessWidget {
  const RipeNGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF347928)),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(color: Color(0xFF99B994)),
          labelStyle: const TextStyle(color: Color(0xFF99B994)),
        ),
        textTheme: const TextTheme().copyWith(
          bodySmall: const TextStyle(color: Color(0xFF347928)),
          bodyMedium: const TextStyle(color: Color(0xFF347928)),
          bodyLarge: const TextStyle(color: Color(0xFF347928)),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _checkRememberMe(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return snapshot.data == true ? MainScreen() : StartScreen();
          }
        },
      ),
    );
  }

  Future<bool> _checkRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('remember_me') ?? false;
  }
}

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo2.png', height: 150),
            SizedBox(height: 20),
            Text(
              "Explore the app",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF347928)),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Monitor your harvest with precision and take control of your fruit's ripeness and count, all in one place",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: 275,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: BorderSide(color: Color(0xFF347928)),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: Text("Sign In", style: TextStyle(color: Color(0xFF347928))),
              ),
            ),
            SizedBox(
              width: 275,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: BorderSide(color: Color(0xFF347928)),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
                },
                child: Text("Create account", style: TextStyle(color: Color(0xFF347928))),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}