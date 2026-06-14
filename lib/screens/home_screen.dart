import 'package:flutter/material.dart';
import 'package:lost_and_found/screens/found_page.dart';
import 'package:lost_and_found/screens/lost_page.dart';
import 'package:lost_and_found/screens/matches_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 1;
  List<Widget> pages = const [LostPage(), FoundPage(), MatchesScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        //this will help me keep the scrolled state , on moving between different pages
        index: currentPage,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedIconTheme: const IconThemeData(size: 35),
        unselectedIconTheme: const IconThemeData(size: 30),
        unselectedFontSize: 15,
        selectedFontSize: 18,
        onTap: (value) {
          setState(() {
            currentPage = value;
          });
        },
        selectedItemColor: Color(0xFF3E5974),
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.white,
        currentIndex: currentPage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Lost',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_red_eye_outlined),
            label: 'Found',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Matches',
          ),
        ],
      ),
    );
  }
}
