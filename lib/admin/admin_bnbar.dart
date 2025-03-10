import 'package:flutter/material.dart';

class AdminBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const AdminBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  _AdminBottomNavBarState createState() => _AdminBottomNavBarState();
}

class _AdminBottomNavBarState extends State<AdminBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Color(0xFF347928),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(color: Color(0xFF347928)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color:
                      widget.selectedIndex == 0
                          ? Color(0xFFFCCD2A)
                          : const Color(0xFFFFFBE6),
                ),
                onPressed: () => widget.onItemTapped(0),
              ),
              IconButton(
                icon: Icon(
                  Icons.bar_chart,
                  color:
                      widget.selectedIndex == 1
                          ? Color(0xFFFCCD2A)
                          : const Color(0xFFFFFBE6),
                ),
                onPressed: () => widget.onItemTapped(1),
              ),
              IconButton(
                icon: Icon(
                  Icons.grass,
                  color:
                      widget.selectedIndex == 2
                          ? Color(0xFFFCCD2A)
                          : const Color(0xFFFFFBE6),
                ),
                onPressed: () => widget.onItemTapped(2),
              ),
              IconButton(
                icon: Icon(
                  Icons.people,
                  color:
                      widget.selectedIndex == 3
                          ? Color(0xFFFCCD2A)
                          : const Color(0xFFFFFBE6),
                ),
                onPressed: () => widget.onItemTapped(3),
              ),
              IconButton(
                icon: Icon(
                  Icons.person,
                  color:
                      widget.selectedIndex == 4
                          ? Color(0xFFFCCD2A)
                          : const Color(0xFFFFFBE6),
                ),
                onPressed: () => widget.onItemTapped(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
