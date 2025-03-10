import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'user/user_dashboard.dart';
import 'login_page.dart';
import 'signup.dart';
import 'admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions(); // Request permissions
  runApp(const RipeNGoApp());
}

Future<void> _requestPermissions() async {
  await [
    Permission.camera,
    Permission.storage,
    Permission.audio,
  ].request();
}

class RipeNGoApp extends StatelessWidget {
  const RipeNGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF347928)),
      ),
      debugShowCheckedModeBanner: false,
      home: MainScreen(userRole: 0, userData: {}),
      routes: {
        '/admin_dashboard': (context) => AdminDashboard(userRole: 1, userData: {}),
        '/user_dashboard': (context) => MainScreen(userRole: 0, userData: {}),
        '/signup': (context) => SignUpScreen(),
      },
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
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                  },
                  child: Text("Create account", style: TextStyle(color: Color(0xFF347928))),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Dashboard')),
      body: Center(child: Text('Welcome to the User Dashboard')),
    );
  }
}
