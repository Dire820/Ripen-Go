import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'bottomnavbar.dart';
import 'gallery.dart';
import 'profile.dart';
import 'tips.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final ImagePicker _picker = ImagePicker();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // Handle the captured image
      print('Image path: ${image.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
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
            GalleryPage(),
            TipsPage(),
            ProfilePage(),
            // Add more pages here
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
            onPressed: _openCamera,
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                HomeBody(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeHeaderSection extends StatelessWidget {
  const HomeHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/Untitled-1.png"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.35), BlendMode.darken),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Image.asset("assets/logo2.png", height: 80),
              Positioned(
                left: 0,
                top: 0,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Image.asset("assets/logo2.png", height: 80, color: Colors.black.withOpacity(0.5)),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: Image.asset("assets/logo2.png", height: 80,),
              ),
            ],
          ),
          SizedBox(width: 20),
          Text(
            "RipeN-Go",
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(151, 237, 0, 1),
              shadows: [
                Shadow(
                  offset: Offset(0, 3),
                  blurRadius: 5.0,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  List<XFile?> selectedImages = [];
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImages.add(image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
        children: [
          selectedImages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color:Color(0xFF347928),
                        size: 100,
                      ),
                      SizedBox(height: 20),
                      Text("No Recent File", style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF347928),
                          foregroundColor: const Color(0xFFFFFBE6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 5,
                        ),
                        child: Text("Scan a Fruit"),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
                  children: [
                    Text(
                      "Recent",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: selectedImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Color(0xFF347928)),
                          ),
                          child: Image.file(File(selectedImages[index]!.path), fit: BoxFit.cover),
                        );
                      },
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}