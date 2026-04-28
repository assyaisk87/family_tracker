class AuthUser {
  final String id;
  final String email;
  final String? familyId;

  AuthUser({required this.id, required this.email, this.familyId});

  String get username => email.split('@').first;
  //ulan@mail.com => ulan , mail.com => ulan
}