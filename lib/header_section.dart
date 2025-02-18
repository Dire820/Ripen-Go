import 'package:flutter/material.dart';
import 'dart:ui';

class HeaderSection extends StatelessWidget {
  final String title;

  const HeaderSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0), // Reduced padding
      decoration: BoxDecoration(
        color: Color(0xFF347928), // Same color as the appbar
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align to the left
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Image.asset("../assets/logo2.png", height: 40), // Reduced height
              Positioned(
                left: 0,
                top: 0,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5), // Reduced blur
                  child: Image.asset("../assets/logo2.png", height: 40, color: Colors.black.withOpacity(0.5)), // Reduced height
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: Image.asset("../assets/logo2.png", height: 40), // Reduced height
              ),
            ],
          ),
          SizedBox(width: 10), // Reduced spacing
          Text(
            title,
            style: TextStyle(
              fontSize: 17.5, // Reduced font size
              fontWeight: FontWeight.bold,
              color: Color(0xFFFCCD2A),
              shadows: [
                Shadow(
                  offset: Offset(0, 1.5), // Reduced offset
                  blurRadius: 2.5, // Reduced blur radius
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