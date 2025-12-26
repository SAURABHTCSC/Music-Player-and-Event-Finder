import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: isDark ? Colors.red[300] : Colors.red,
      unselectedItemColor: Colors.grey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: isDark ? Colors.red[300] : Colors.red),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.theaters),
          label: 'Shows',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.library_music),
          label: 'Library',
        ),
      ],
      onTap: (index) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coming Soon')),
        );
      },
    );
  }
}
