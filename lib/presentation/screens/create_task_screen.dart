import 'package:flutter/material.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar(
        title: const Text('Создать задачу'),
      ),
      body: Center(
        child: Text('Здесь будет форма создания задачи'),
      ),
    );
  }
}