import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_town_demo/providers/auth_provider.dart';
import 'package:hobby_town_demo/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _pink = Color(0xFFFF4F8B);
const _ink = Color(0xFF0E0E12);
const _bg = Color(0xFFF8F8FA);
const _muted = Color(0xFF6B6776);
const _hint = Color(0xFF9A96A5);
const _border = Color(0xFFE8E6EE);

final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

void _applyOverlayStyle() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: _bg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

mixin _AuthRunner<T extends StatefulWidget> on State<T> {
  bool loading = false;

  Future<void> runAuth(VoidCallback onDone) async {
    if (loading) return;
    setState(() => loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => loading = false);
    onDone();
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with _AuthRunner {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final SharedPreferencesAsync sharedPreferences = SharedPreferencesAsync();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _applyOverlayStyle();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await sharedPreferences.getBool("isAuth") ?? false) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (_) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> onAuthenticated() async {
    await sharedPreferences.setBool("isAuth", true);
    await sharedPreferences.setString("username", _email.text.split("@")[0]);
    ref.read(isAuthProvider.notifier).state = true;
    ref.read(usernameProvider.notifier).state = _email.text.split("@")[0];
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomeScreen()),
      (_) => false,
    );
  }

  Future<void> onGuest() async {
    await sharedPreferences.remove("isAuth");
    await sharedPreferences.remove("username");
    ref.read(isAuthProvider.notifier).state = false;
    ref.read(usernameProvider.notifier).state = "";
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomeScreen()),
      (_) => false,
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      runAuth(onAuthenticated);
    }
  }

  void _google() {
    FocusScope.of(context).unfocus();
    // Stub: behaves exactly like the "Masuk" button's success path.
    runAuth(onAuthenticated);
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur lupa kata sandi segera hadir.')),
    );
  }

  void _goRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            RegisterScreen(onAuthenticated: onAuthenticated, onGuest: onGuest),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _BrandHeader(logoSize: 40, fontSize: 24),
                const SizedBox(height: 40),
                const _WelcomeChip('Selamat datang kembali'),
                const SizedBox(height: 14),
                const _Heading('Hobi seru menantimu.'),
                const SizedBox(height: 8),
                const _Subtitle('Masuk untuk melanjutkan koleksi impianmu.'),
                const SizedBox(height: 28),
                _AuthField(
                  label: 'Email',
                  hint: 'nama@email.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  icon: Icons.mail_outline_rounded,
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Email wajib diisi';
                    if (!_emailRegex.hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _AuthField(
                  label: 'Kata sandi',
                  hint: 'Masukkan kata sandi',
                  controller: _password,
                  obscure: _obscure,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Kata sandi wajib diisi'
                      : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: _pink,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Lupa kata sandi?',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _PrimaryButton(
                  label: 'Masuk',
                  loading: loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 18),
                const Center(
                  child: Text(
                    'atau lanjutkan dengan',
                    style: TextStyle(color: _muted, fontSize: 10.5),
                  ),
                ),
                const SizedBox(height: 16),
                _GoogleButton(onPressed: loading ? null : _google),
                const SizedBox(height: 14),
                Center(child: _GuestButton(onPressed: onGuest)),
                const SizedBox(height: 12),
                Center(
                  child: _SwitchLine(
                    question: 'Belum punya akun? ',
                    action: 'Daftar sekarang',
                    onTap: _goRegister,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Register ─────────────────────────

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.onAuthenticated,
    required this.onGuest,
  });

  /// Called after a successful registration / Google sign-up (stub).
  final VoidCallback onAuthenticated;

  /// Called on "Lanjut sebagai tamu".
  final VoidCallback onGuest;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with _AuthRunner {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _agreed = false;
  bool _showAgreeError = false;

  @override
  void initState() {
    super.initState();
    _applyOverlayStyle();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final formOk = _formKey.currentState!.validate();
    setState(() => _showAgreeError = !_agreed);
    if (formOk && _agreed) {
      runAuth(widget.onAuthenticated);
    }
  }

  void _google() {
    FocusScope.of(context).unfocus();
    // Stub: behaves exactly like the "Buat Akun" button's success path.
    runAuth(widget.onAuthenticated);
  }

  void _goLogin() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _BrandHeader(logoSize: 26, fontSize: 16),
                const SizedBox(height: 32),
                const _Heading('Jadi bagian dari cerita.'),
                const SizedBox(height: 8),
                const _Subtitle('Buat akun dan temukan dunia favoritmu.'),
                const SizedBox(height: 22),
                _AuthField(
                  label: 'Nama lengkap',
                  hint: 'Nama kamu',
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  icon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),
                _AuthField(
                  label: 'Email',
                  hint: 'nama@email.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  icon: Icons.mail_outline_rounded,
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Email wajib diisi';
                    if (!_emailRegex.hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _AuthField(
                  label: 'Kata sandi',
                  hint: 'Minimal 8 karakter',
                  controller: _password,
                  obscure: _obscure,
                  textInputAction: TextInputAction.done,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
                    if (v.length < 8) return 'Minimal 8 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _TermsRow(
                  checked: _agreed,
                  showError: _showAgreeError,
                  onChanged: (v) => setState(() {
                    _agreed = v;
                    if (v) _showAgreeError = false;
                  }),
                ),
                const SizedBox(height: 14),
                _PrimaryButton(
                  label: 'Buat Akun',
                  loading: loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'atau',
                    style: TextStyle(color: _muted, fontSize: 10.5),
                  ),
                ),
                const SizedBox(height: 12),
                _GoogleButton(onPressed: loading ? null : _google),
                const SizedBox(height: 14),
                Center(child: _GuestButton(onPressed: widget.onGuest)),
                const SizedBox(height: 12),
                Center(
                  child: _SwitchLine(
                    question: 'Sudah punya akun? ',
                    action: 'Masuk',
                    onTap: _goLogin,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Shared widgets ─────────────────────────

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.logoSize, required this.fontSize});

  final double logoSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          padding: EdgeInsets.all(logoSize * 0.08),
          decoration: BoxDecoration(
            color: _pink,
            borderRadius: BorderRadius.circular(logoSize * 0.3),
          ),
          child: Image.asset('resources/images/logo.png', fit: BoxFit.contain),
        ),
        SizedBox(width: logoSize * 0.2),
        Text(
          'myhobbytown.',
          style: TextStyle(
            color: _ink,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class _WelcomeChip extends StatelessWidget {
  const _WelcomeChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE6FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF2B1F45),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _ink,
        fontSize: 26,
        height: 1.2,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: _muted, fontSize: 12));
  }
}

/// Labeled text field. Pass [icon] for a fixed trailing icon, or
/// [onToggleObscure] to make it a password field with a show/hide toggle.
class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.hint,
    required this.controller,
    this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onSubmitted,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData? icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  OutlineInputBorder _outline(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    Widget? suffix;
    if (onToggleObscure != null) {
      suffix = IconButton(
        onPressed: onToggleObscure,
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 18,
          color: _ink,
        ),
      );
    } else if (icon != null) {
      suffix = Icon(icon, size: 18, color: _ink);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _ink,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          validator: validator,
          onFieldSubmitted: onSubmitted,
          style: const TextStyle(color: _ink, fontSize: 12),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _hint, fontSize: 12),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            suffixIcon: suffix,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            errorStyle: const TextStyle(fontSize: 10),
            enabledBorder: _outline(_border),
            focusedBorder: _outline(_ink),
            errorBorder: _outline(Colors.redAccent),
            focusedErrorBorder: _outline(Colors.redAccent),
          ),
        ),
      ],
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({
    required this.checked,
    required this.showError,
    required this.onChanged,
  });

  final bool checked;
  final bool showError;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final borderColor = showError ? Colors.redAccent : _pink;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(!checked),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: checked ? _pink.withOpacity(0.12) : Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: checked
                    ? const Icon(Icons.check_rounded, size: 13, color: _pink)
                    : null,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Saya menyetujui Syarat & Ketentuan serta Kebijakan Privasi MyHobbyTown.',
                  style: TextStyle(color: _muted, fontSize: 10, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        if (showError)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 28),
            child: Text(
              'Kamu perlu menyetujui syarat & ketentuan',
              style: TextStyle(color: Colors.redAccent, fontSize: 10),
            ),
          ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _ink,
          disabledBackgroundColor: _ink,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _ink,
          side: const BorderSide(color: _ink, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // Swap for your Google logo asset if you have one.
            Icon(Icons.public, size: 18),
            SizedBox(width: 8),
            Text(
              'Lanjut dengan Google',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestButton extends StatelessWidget {
  const _GuestButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: _ink,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: const Text(
        'Lanjut sebagai tamu',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SwitchLine extends StatelessWidget {
  const _SwitchLine({
    required this.question,
    required this.action,
    required this.onTap,
  });

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(question, style: const TextStyle(color: _muted, fontSize: 11)),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              action,
              style: const TextStyle(
                color: _pink,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
