import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hobby_town_demo/screens/home_screen.dart';
import 'package:hobby_town_demo/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pink = Color(0xFFFF4F8B);
  static const _ink = Color(0xFF0E0E12);
  static const _bg = Color(0xFFF8F8FA);
  static const _muted = Color(0xFF6B6776);

  SharedPreferencesAsync sharedPreferencesAsync = SharedPreferencesAsync();

  static const _titles = [
    'Satu tempat untuk\nsemua hobimu.',
    'Karakter favorit, jadi\nlebih dekat.',
    'Pesan gampang. Hati\npun tenang.',
  ];

  static const _descriptions = [
    'Anime, manga, cosplay, dan gaya hidup Jepang.\nSelamat datang di dunia MyHobbyTown!',
    'Jelajahi merchandise resmi berlisensi dan koleksi\ncosplay pilihan untuk ekspresi dirimu.',
    'Belanja langsung di aplikasi atau tanya via\nWhatsApp. Kami bantu dari pilih sampai tiba.',
  ];

  final _controller = PageController();
  int _index = 0;

  void onFinished() {
    sharedPreferencesAsync.setBool("onboarded", true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void onLogin() {
    sharedPreferencesAsync.setBool("onboarded", true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => LoginScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: _bg,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (await sharedPreferencesAsync.getBool("onboarded") ?? false) {
        onLogin();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == 2) {
      onFinished();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _back() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _index = i),
                  children: [
                    _OnboardingPage(
                      card: const _WelcomeCard(),
                      title: _titles[0],
                      description: _descriptions[0],
                      dots: _buildDots(),
                    ),
                    _OnboardingPage(
                      card: const _MerchCard(),
                      title: _titles[1],
                      description: _descriptions[1],
                      dots: _buildDots(),
                    ),
                    _OnboardingPage(
                      card: const _OrderCard(),
                      title: _titles[2],
                      description: _descriptions[2],
                      dots: _buildDots(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildPrimaryButton(),
              const SizedBox(height: 8),
              SizedBox(height: 44, child: Center(child: _buildSecondary())),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _pink,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Image.asset(
              'resources/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'myhobbytown.',
            style: TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onFinished,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Lewati',
                style: TextStyle(color: _muted, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      children: List.generate(3, (i) {
        final active = i == _index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 5),
          width: active ? 18 : 5,
          height: 5,
          decoration: BoxDecoration(
            color: active ? _pink : const Color(0xFFD9D6E0),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildPrimaryButton() {
    final label = _index == 2 ? 'Mulai Jelajahi' : 'Lanjut';
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _next,
        style: ElevatedButton.styleFrom(
          backgroundColor: _ink,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_forward, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondary() {
    const boldStyle = TextStyle(
      color: _ink,
      fontSize: 11,
      fontWeight: FontWeight.w700,
    );

    switch (_index) {
      case 0:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sudah punya akun? ',
              style: TextStyle(color: _muted, fontSize: 11),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onLogin,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Masuk', style: boldStyle),
              ),
            ),
          ],
        );
      case 1:
        return TextButton(
          onPressed: _back,
          child: const Text('Kembali', style: boldStyle),
        );
      default:
        return TextButton(
          onPressed: onLogin,
          child: const Text('Masuk ke Akun', style: boldStyle),
        );
    }
  }
}

/// Shared layout of one page: image card, dots, title, description.
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.card,
    required this.title,
    required this.description,
    required this.dots,
  });

  final Widget card;
  final String title;
  final String description;
  final Widget dots;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: card),
        const SizedBox(height: 18),
        dots,
        const SizedBox(height: 22),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0E0E12),
            fontSize: 24,
            height: 1.3,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(
            color: Color(0xFF6B6776),
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

/// Small rounded label used on the image cards.
class _Chip extends StatelessWidget {
  const _Chip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF2B1F45),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ───────────────────────── Page 1 ─────────────────────────

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('resources/images/onboarding_1.png', fit: BoxFit.cover),
          const Positioned(
            left: 12,
            bottom: 12,
            child: _Chip('Teman hobi sejak 2003'),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Page 2 ─────────────────────────

class _MerchCard extends StatelessWidget {
  const _MerchCard();

  Widget _tile(Color color, String asset, {EdgeInsets? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      padding: padding ?? const EdgeInsets.all(10),
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEDE6FF), Color(0xFFFFE1EE)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 11,
                  child: _tile(
                    const Color(0xFFE2E2F7),
                    'resources/images/onboarding_2_jacket.png',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 8,
                  child: Column(
                    children: [
                      Expanded(
                        child: _tile(
                          const Color(0xFFFBE6D3),
                          'resources/images/onboarding_2_keychain.png',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _tile(
                          const Color(0xFFE6DEEF),
                          'resources/images/onboarding_2_plush.png',
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const _Chip('Merchandise resmi & cosplay pilihan'),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}

// ───────────────────────── Page 3 ─────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECE7FF),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          // Product image
          Positioned.fill(
            bottom: 38,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDCDCE8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Image.asset(
                'resources/images/onboarding_3_jacket.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Chat bubble
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: Color(0xFF25D366),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin MyHobbyTown',
                          style: TextStyle(
                            color: Color(0xFF0E0E12),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Butuh bantuan ukuran? Kami siap bantu, ya! ✨',
                          style: TextStyle(
                            color: Color(0xFF6B6776),
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
