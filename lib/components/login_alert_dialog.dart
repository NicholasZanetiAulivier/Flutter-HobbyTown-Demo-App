import 'package:flutter/material.dart';

/// Content for a dialog shown when a logged-out user taps the Cart button.
///
/// Use it as the content of an [AlertDialog]:
///
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => AlertDialog(
///     backgroundColor: Colors.white,
///     surfaceTintColor: Colors.transparent,
///     shape: RoundedRectangleBorder(
///       borderRadius: BorderRadius.circular(28),
///     ),
///     contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
///     content: LoginRequiredDialogContent(
///       onLogin: () {
///         Navigator.of(context).pop();
///         // navigate to the login screen
///       },
///     ),
///   ),
/// );
/// ```
///
/// [LoginAlertDialog.show] wraps exactly this for convenience.
class LoginAlertDialog extends StatelessWidget {
  const LoginAlertDialog({
    super.key,
    this.onLogin,
    this.onRegister,
    this.onDismiss,
  });

  /// Tapped on "Masuk". The dialog is not closed automatically, so pop it
  /// yourself before navigating.
  final VoidCallback? onLogin;

  /// When provided, a "Belum punya akun? Daftar" link is shown.
  final VoidCallback? onRegister;

  /// Tapped on "Nanti Saja". Defaults to closing the dialog.
  final VoidCallback? onDismiss;

  static const Color _pink = Color(0xFFFF3D7F);
  static const Color _ink = Color(0xFF14121A);
  static const Color _muted = Color(0xFF6E6B78);
  static const Color _border = Color(0xFFE4E2EC);

  /// Convenience wrapper that shows the content inside a styled
  /// [AlertDialog].
  static Future<T?> show<T>(
    BuildContext context, {
    VoidCallback? onLogin,
    VoidCallback? onRegister,
  }) {
    return showDialog<T>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        content: LoginAlertDialog(onLogin: onLogin, onRegister: onRegister),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SizedBox(
              width: 112,
              height: 112,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE9E2FB), Color(0xFFFFE3EE)],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 46,
                          color: Color(0xFF2A1B3D),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: 2,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: _pink,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33FF3D7F),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Masuk dulu, yuk',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keranjang hanya bisa dibuka setelah kamu masuk ke akunmu. '
            'Belanjaan favoritmu menunggu!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: _muted, height: 1.45),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: onLogin,
              style: FilledButton.styleFrom(
                backgroundColor: _ink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Masuk'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: onDismiss ?? () => Navigator.of(context).maybePop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: _ink,
                side: const BorderSide(color: _border, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Nanti Saja'),
            ),
          ),
          if (onRegister != null) ...[
            const SizedBox(height: 14),
            Center(
              child: GestureDetector(
                onTap: onRegister,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text.rich(
                    TextSpan(
                      text: 'Belum punya akun? ',
                      style: TextStyle(fontSize: 12.5, color: _muted),
                      children: [
                        TextSpan(
                          text: 'Daftar',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _pink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
