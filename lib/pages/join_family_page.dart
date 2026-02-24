import 'package:family_tracker/core/provider/supabase_provider.dart';
import 'package:family_tracker/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JoinFamilyPage extends ConsumerStatefulWidget {
  const JoinFamilyPage({super.key});

  @override
  ConsumerState<JoinFamilyPage> createState() => _JoinFamilyPageState();
}

class _JoinFamilyPageState extends ConsumerState<JoinFamilyPage> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _joinFamily() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final client = ref.read(supabaseProvider);
    final user = client.auth.currentUser!;

    final family = await client
        .from('families')
        .select()
        .eq('invite_code', _codeController.text)
        .maybeSingle();

    if (family == null) {
      setState(() {
        _error = 'Код не найден';
        _isLoading = false;
      });
      return;
    }

    final familyId = family['id'];

    await client.from('family_members').insert({
      'user_id': user.id,
      'family_id': familyId,
      'role': 0,
    });

    setState(() => _isLoading = false);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Присоединиться к семье')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Введите invite code'),
            ),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _joinFamily,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Присоединиться'),
            ),
          ],
        ),
      ),
    );
  }
}
