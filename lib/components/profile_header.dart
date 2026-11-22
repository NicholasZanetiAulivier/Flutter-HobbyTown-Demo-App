import 'package:flutter/material.dart';
import 'package:hobby_town_demo/constants/colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.name,
    required this.email,
    this.avatar,
    required this.isAuth,
    this.onEditProfile,
  });

  final String name;
  final String email;
  final bool isAuth;
  final ImageProvider? avatar;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 33,
          backgroundColor: const Color(0xFFE6E3EE),
          backgroundImage: avatar,
          child: avatar == null
              ? const Icon(Icons.person_rounded, size: 34, color: MUTED)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAuth ? name : "Guest",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: INK,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isAuth ? email : "Login terlebih dahulu",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: MUTED),
              ),
              const SizedBox(height: 4),
              // GestureDetector(
              //   onTap: onEditProfile,
              //   behavior: HitTestBehavior.opaque,
              //   child: const Padding(
              //     padding: EdgeInsets.symmetric(vertical: 2),
              //     child: Text(
              //       'Edit Profil',
              //       style: TextStyle(
              //         fontSize: 12,
              //         fontWeight: FontWeight.w600,
              //         color: PINK,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
