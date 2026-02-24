import 'package:flutter/material.dart';
import 'create_family_page.dart';
import 'join_family_page.dart';

class FamilyChoicePage extends StatelessWidget {
  const FamilyChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Присоединиться к семье')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateFamilyPage()),
                  );
                },
                child: const Text('Создать новую семью'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JoinFamilyPage()),
                  );
                },
                child: const Text('Присоединиться по коду'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
