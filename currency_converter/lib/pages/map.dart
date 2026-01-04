import 'package:flutter/material.dart';
import 'package:currency_converter/pages/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Key _mapKey = UniqueKey();

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      // If user taps currently selected item, reset behavior for Map (index 0)
      if (index == 0) {
        setState(() {
          _mapKey = UniqueKey();
        });
      }
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      MapContent(key: _mapKey),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'Map' : 'Profile',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Profile',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}

class MapContent extends StatelessWidget {
  const MapContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace with the actual map widget. Using placeholder content here.
    return const Center(
      child: Text('Map page content'),
    );
  }
}
