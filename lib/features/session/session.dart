import 'package:family_tracker/model/family_member.dart';
import 'package:family_tracker/model/family.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionData {
  final User user;
  final FamilyMember? member; 
  final FamilyModel? family;
  final int? myMemberId;

  SessionData({
    required this.user,
    this.member,  
    this.family,
    this.myMemberId,
  });
}
