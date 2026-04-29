import 'package:family_tracker/domain/entities/user.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
    required this.isOwnProfile,
    this.onActionTap,
  });

  final User user;
  final bool isOwnProfile;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (user.avatarUrl.isNotEmpty)
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade900,
                backgroundImage: NetworkImage(user.avatarUrl)
              ),
              if (user.avatarUrl.isEmpty) CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue.shade200,
                          child: Text(
                            user.username.substring(0,2).toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
            ],
          ),
        ],
      ),
    );
  }
}
