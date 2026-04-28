import '../models/family_user_model.dart';
import 'supabase_service.dart';

class FamilyUsersRemoteDataSource {
  final SupabaseService supabaseService = SupabaseService.instance;

  Future<List<FamilyUserModel>> fetchFamilyUsers(int familyId) async {
    try {
      // Попытка загрузить из Supabase
      if (supabaseService.initialized) {
        final response = await supabaseService.client
            .from('family_members')
            .select('''*''')
            .eq('family_id', familyId);

        return (response as List)
            .map((familyUser) => _familyUserModelFromJson(familyUser))
            .toList();
      }
    } catch (e) {
      // Fallback на локальные данные
      print('Ошибка загрузки членов семьи из Supabase: $e');
    }

    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable([]);
  }

  // Утилиты для конвертации JSON
  FamilyUserModel _familyUserModelFromJson(Map<String, dynamic> json) {
    return FamilyUserModel(
      id: json['id'].toString(),
      familyId: json['family_id'].toString(),
      userId: json['user_id'].toString(),
      role: (json['role'] as bool? ?? false),
      displayName: json['display_name'] ?? 'Unknown',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }

  Map<String, dynamic> _familyUserModelToJson(FamilyUserModel familyUser) {
    return {
      'id': familyUser.id,
      'family_id': familyUser.familyId,
      'user_id': familyUser.userId,
      'role': familyUser.role,
      'display_name': familyUser.displayName,
      'avatar_url': familyUser.avatarUrl,
    };
  }
}
