import 'package:flutter/material.dart';
import 'package:ripengo/admin/admin_statistics.dart';
import 'package:ripengo/login_page.dart';
import 'package:ripengo/user/user_home.dart';
import 'dart:ui'; // Import for ImageFilter
import 'admin_bnbar.dart';
import 'admin_tips.dart';
import 'admin_umngmnt.dart';
import 'adminprofile.dart';

// Modify the AdminDashboard class to accept userRole and userData
class AdminDashboard extends StatefulWidget {
  final int userRole;
  final Map<String, dynamic> userData; // Add userData to store admin info

  const AdminDashboard({
    Key? key,
    required this.userRole,
    required this.userData,
  }) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  // Modify _widgetOptions to use the userRole and userData
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    print('Admin Role: ${widget.userRole}'); // Debug print
    print('Admin Data: ${widget.userData}'); // Debug print

    _widgetOptions = <Widget>[
      HomePage(),
      StatisticsPage(),
      AdminTipsPage(),
      UserManagementPage(),
      AdminProfilePage(
        userRole: widget.userRole,
        userData: widget.userData, // Pass the original data structure
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Logout'),
            content: Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Logout'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE6),

      body: _widgetOptions.elementAt(_selectedIndex),

      bottomNavigationBar: AdminBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE6),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0), // Set the height of the AppBar
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF347928),
          centerTitle: true,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeaderSection(),
                AdminHomeBody(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class AdminHomeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE6),
      body: Center(child: Text('Admin Home Page')),
    );
  }
}
