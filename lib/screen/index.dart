import 'package:flutter/material.dart';
import 'package:rsiap_dokter/config/config.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  int _selectedNavbar = 0;

  void _changeSelectedNavBar(int index) {
    setState(() {
      _selectedNavbar = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationItems[_selectedNavbar]['widget'] as Widget,
      bottomNavigationBar: BottomNavigationBar(
        // backgroundColor: Colors.transparent,
        currentIndex: _selectedNavbar,
        showUnselectedLabels: false,
        onTap: (index) {
          _changeSelectedNavBar(index);
        },
        items: navigationItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item['icon'] as IconData),
            label: item['label'] as String,
          );
        }).toList(),
      ),
    );
  }
}
