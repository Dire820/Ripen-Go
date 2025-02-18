import 'package:flutter/material.dart';
import 'header_section.dart'; // Import HeaderSection

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
          elevation: 0,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderSection(title: "Profile"), // Use HeaderSection with title
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
                    children: [
                      // Empty body
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}