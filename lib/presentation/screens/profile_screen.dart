import 'package:family_tracker/domain/repositories/auth_repository.dart';
import 'package:family_tracker/locator.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
              IconButton(
                onPressed: () async {
                  locator<AuthRepository>().signOut();
                },
                icon: const Icon(Icons.logout,),
              ),
        ]
      ),
      body: const Center(
        child: Text('Profile'),
      ),
    );
  }
}