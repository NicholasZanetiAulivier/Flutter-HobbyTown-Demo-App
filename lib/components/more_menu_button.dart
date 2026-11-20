import 'package:flutter/material.dart';

enum _MoreMenuAction { login, logout }

class MoreMenuButton extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback? onLogin;
  final VoidCallback? onLogout;

  const MoreMenuButton({
    super.key,
    required this.isLoggedIn,
    this.onLogin,
    this.onLogout,
  });

  static const Color _ink = Color(0xFF111111);
  static const Color _danger = Color(0xFFE0245E);

  void _onSelected(_MoreMenuAction action) {
    switch (action) {
      case _MoreMenuAction.login:
        onLogin?.call();
      case _MoreMenuAction.logout:
        onLogout?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MoreMenuAction>(
      tooltip: 'Menu',
      // Drops the menu just below the button, aligned to its right edge,
      // so it reads as expanding out of the button.
      offset: const Offset(0, 48),
      position: PopupMenuPosition.under,
      elevation: 8,
      shadowColor: Colors.black26,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      constraints: const BoxConstraints(minWidth: 168),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: _onSelected,
      itemBuilder: _buildItems,
      child: const CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        child: Icon(Icons.more_horiz, size: 20, color: _ink),
      ),
    );
  }

  List<PopupMenuEntry<_MoreMenuAction>> _buildItems(BuildContext context) {
    if (isLoggedIn) {
      return const [
        PopupMenuItem<_MoreMenuAction>(
          value: _MoreMenuAction.logout,
          child: _MenuRow(icon: Icons.logout, label: 'Keluar', color: _danger),
        ),
      ];
    }
    return const [
      PopupMenuItem<_MoreMenuAction>(
        value: _MoreMenuAction.login,
        child: _MenuRow(icon: Icons.login, label: 'Masuk', color: _ink),
      ),
    ];
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Usage in an app bar:
//
// AppBar(
//   actions: [
//     Padding(
//       padding: const EdgeInsets.only(right: 16),
//       child: MoreMenuButton(
//         isLoggedIn: authState.isLoggedIn,
//         onLogin: authState.goToLogin,
//         onLogout: authState.logout,
//       ),
//     ),
//   ],
// )
