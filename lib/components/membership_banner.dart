import 'package:flutter/material.dart';

class MembershipBanner extends StatelessWidget {
  const MembershipBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF15111A), Color(0xFF38234A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE6FA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Sahabat MyHobbyTown',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2A1B3D),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Hobi lebih seru bersama.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Terima kasih sudah jadi bagian dari cerita kami.',
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFFB9B4C6),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
