import 'package:flutter/material.dart';
import 'user_bottomnavbar.dart';
import 'dart:io';
import 'camera_screen.dart';
import 'user_expenses.dart'; // Corrected import
import 'user_home.dart';
import 'user_profile.dart'; // Ensure this file contains the UserProfilePage class
import 'user_tips.dart';

class MainScreen extends StatefulWidget {
  final int userRole;
  final Map<String, dynamic> userData;

  const MainScreen({
    super.key,
    required this.userRole,
    required this.userData,
  });

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 150),
      curve: Curves.easeInOut,
    );
  }

  void _showFruitSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      backgroundColor: Color.fromRGBO(24, 56, 18, 1),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select a Fruit",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 15),
              _buildFruitButtonWithImage(context, 'Banana', 'assets/banana.png'),
              _buildFruitButtonWithImage(context, 'Mango', 'assets/mango.png'),
              _buildFruitButtonWithImage(context, 'Papaya', 'assets/papaya.png'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFruitButtonWithImage(BuildContext context, String fruit, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () async {
          Navigator.pop(context);
          await _showBatchSelection(context, fruit);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFCCD2A),
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          textStyle: TextStyle(fontSize: 18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imagePath, width: 24, height: 24),
            SizedBox(width: 10),
            Text(fruit),
          ],
        ),
      ),
    );
  }

  Future<void> _showBatchSelection(BuildContext context, String fruit) async {
    final String fruitPath = "/storage/emulated/0/Pictures/RipeN-Go/$fruit/";
    final Directory fruitDir = Directory(fruitPath);

    if (!await fruitDir.exists()) {
      await fruitDir.create(recursive: true);
    }

    List<String> batches;
    try {
      batches = fruitDir
          .listSync()
          .where((entity) => entity is Directory)
          .map((dir) => dir.path.split('/').last)
          .toList();
    } catch (e) {
      print("Error listing directories in ${fruitDir.path}: $e");
      batches = [];
    }

    // Ensure "Batch 1" always appears on the top and every new batch appears below
    batches.sort((a, b) {
      if (a == "Batch 1") return -1;
      if (b == "Batch 1") return 1;
      return a.compareTo(b);
    });

    if (batches.isEmpty) {
      String newBatch = "$fruitPath/Batch 1";
      await Directory(newBatch).create();
      bool? refresh = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(fruit: fruit, batch: "Batch 1"),
        ),
      );

      if (refresh == true) {
        setState(() {
          _selectedIndex = 1; // Switch to Gallery tab
          _pageController.jumpToPage(1); // Ensure gallery updates
        });
      }

      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Batch for $fruit"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  int newBatchNumber = batches.length + 1;
                  String newBatch = "$fruitPath/Batch $newBatchNumber";
                  await Directory(newBatch).create();
                  bool? refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraScreen(fruit: fruit, batch: "Batch $newBatchNumber")),
                  );
                  if (refresh == true) {
                    setState(() {
                      _selectedIndex = 1;
                      _pageController.jumpToPage(1);
                    });
                  }

                },
                child: Text("Create New Batch"),
              ),
              SizedBox(height: 10),
              Text("Or select an existing batch:"),
              Column(
                children: batches.map((batch) {
                  return ListTile(
                    title: Text(batch),
                    onTap: () async {
                      Navigator.pop(context);
                      bool? refresh = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CameraScreen(fruit: fruit, batch: batch)),
                      );
                      if (refresh == true) {
                        setState(() {
                          _selectedIndex = 1;
                          _pageController.jumpToPage(1);
                        });
                      }

                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            HomePage(),
            ExpensesPage(key: ValueKey(_selectedIndex)), // Forces refresh
            TipsPage(),
            UserProfilePage(
              userRole: widget.userRole,
              userData: widget.userData,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
        floatingActionButton: SizedBox(
          width: 70,
          height: 70,
          child: FloatingActionButton(
            onPressed: () {
              _showFruitSelection(context);
            },
            elevation: 10.0,
            shape: CircleBorder(),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFCCD2A), Color(0xFF9D7E10)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Image.asset("assets/scanner_icon.png", width: 40, height: 40),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
