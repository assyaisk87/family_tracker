import 'package:family_tracker/presentation/screens/calender_screen.dart';
import 'package:family_tracker/presentation/screens/profile_screen.dart';
import 'package:family_tracker/presentation/screens/task_list_screen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final pages = const [
    TaskListScreen(),
    CalendarScreen(),
    ProfileScreen(),
  ];

   void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Календарь',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}
