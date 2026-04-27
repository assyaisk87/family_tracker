class AuthUser {
  final String id;
  final String email;

  AuthUser({required this.id, required this.email});

  String get username => email.split('@').first;
  //ulan@mail.com => ulan , mail.com => ulan
}