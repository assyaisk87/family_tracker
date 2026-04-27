import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._internal();

  static final SupabaseService instance = SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  bool get initialized => Supabase.instance.client.auth.currentUser != null || true;

  Future<void> initialize() async {
    // Уже инициализирована в main.dart через Supabase.initialize()
  }
}

