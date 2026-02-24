import 'package:family_tracker/core/provider/navigation_provider.dart';
import 'package:family_tracker/pages/tab/calendar_tab.dart';
import 'package:family_tracker/pages/tab/profile_tab.dart';
import 'package:family_tracker/pages/tab/tasks_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavProvider);

  final pages = const [
    Tasks(),
    Calendar(),
    Profile(),
  ];

    return Scaffold(      
      body: pages[selectedIndex],
    
       bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.read(bottomNavProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Календарь',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
    
  }
}
