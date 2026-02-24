import 'package:family_tracker/core/provider/supabase_provider.dart';
import 'package:family_tracker/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateFamilyPage extends ConsumerStatefulWidget {
  const CreateFamilyPage({super.key});

  @override
  ConsumerState<CreateFamilyPage> createState() => _CreateFamilyPageState();
}

class _CreateFamilyPageState extends ConsumerState<CreateFamilyPage> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _inviteCode;

  Future<void> _createFamily() async {
    setState(() => _isLoading = true);
    final client = ref.read(supabaseProvider);
    final user = client.auth.currentUser!;

    final code = _generateInviteCode(); // например 6 символов

    // Создаём семью
    final familyResponse = await client.from('families').insert({
      'name': _nameController.text,
      'invite_code': code,
    }).select().single();

    final familyId = familyResponse['id'];

    // Добавляем создателя в members
    await client.from('family_members').insert({
      'user_id': user.id,
      'family_id': familyId,
      'role': 1,
    });

    setState(() {
      _inviteCode = code;
      _isLoading = false;
    });
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[(DateTime.now().millisecondsSinceEpoch + index) % chars.length])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    if (_inviteCode != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Семья создана!'),
              Text('Пригласите членов семьи с кодом: $_inviteCode'),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage())
                  );
                },
                child: const Text('Перейти в семью'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Создать семью')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Название семьи'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _createFamily,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Создать'),
            ),
          ],
        ),
      ),
    );
  }
}
