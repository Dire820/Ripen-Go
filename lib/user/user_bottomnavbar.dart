import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Color(0xFF347928),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF347928),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: selectedIndex == 0 ? Color(0xFFFCCD2A) : const Color(0xFFFFFBE6)),
                onPressed: () => onItemTapped(0),
              ),
                IconButton(
                icon: Icon(Icons.attach_money, color: selectedIndex == 1 ? Color(0xFFFCCD2A) : const Color(0xFFFFFBE6)),
                onPressed: () => onItemTapped(1),
                ),
              SizedBox(width: 90),
              IconButton(
                icon: Icon(Icons.grass, color: selectedIndex == 2 ? Color(0xFFFCCD2A) : const Color(0xFFFFFBE6)),
                onPressed: () => onItemTapped(2),
              ),
              IconButton(
                icon: Icon(Icons.person, color: selectedIndex == 3 ? Color(0xFFFCCD2A) : const Color(0xFFFFFBE6)),
                onPressed: () => onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}