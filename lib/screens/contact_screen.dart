import 'package:flutter/material.dart';
import 'package:hobby_town_demo/components/top_app_bar.dart';
import 'package:hobby_town_demo/models/contacts.dart';

// ---------------------------------------------------------------------------
// Design tokens (same palette as the checkout screens)
// ---------------------------------------------------------------------------
class _C {
  static const bg = Color(0xFFF7F7FA);
  static const card = Colors.white;
  static const accent = Color(0xFFF03E78);
  static const accentSoft = Color(0xFFFFE4EC);
  static const ink = Color(0xFF111114);
  static const muted = Color(0xFF6E6E78);
  static const border = Color(0xFFE6E6EC);
  static const tagBg = Color(0xFFEDE7FB);
  static const tagFg = Color(0xFF3B2A78);
  static const whatsapp = Color(0xFF22C55E);
  static const heroStart = Color(0xFF111114);
  static const heroEnd = Color(0xFF3B2A5E);
}

class HelpContactScreen extends StatelessWidget {
  final ContactChannel admin;
  final ContactChannel shop;
  final StoreLocation location;
  final List<FaqItem> faqs;
  final String website;

  void onChatAdmin() {
    // TODO: open https://wa.me/6281510346306 (e.g. via url_launcher)
  }

  void onChatShop() {
    // TODO: open https://wa.me/6281510334337
  }

  void onOpenLocation() {
    // TODO: open the store location in Maps
  }

  void onFaqTap(int i) {
    // TODO: navigate to the FAQ entry at [index]
  }

  const HelpContactScreen({
    super.key,
    this.admin = const ContactChannel(
      title: 'WhatsApp Admin',
      phone: '+62815-10-346-306',
      description: 'Bantuan pesanan online, pembayaran, dan pengiriman.',
    ),
    this.shop = const ContactChannel(
      title: 'WhatsApp Shop',
      phone: '+62815-10-334-337',
      description: 'Tanya ketersediaan produk dan rencana kunjunganmu.',
    ),
    this.location = const StoreLocation(
      address: 'Ruko Mendrisio 3 Blok D/30 Gading Serpong Tangerang',
      note:
          'Hubungi WhatsApp Shop untuk memastikan jam kunjungan '
          'sebelum datang.',
    ),
    this.faqs = const [
      FaqItem(
        icon: Icons.straighten_outlined,
        question: 'Bagaimana memilih ukuran?',
      ),
      FaqItem(
        icon: Icons.local_shipping_outlined,
        question: 'Berapa lama pengiriman?',
      ),
      FaqItem(
        icon: Icons.inventory_2_outlined,
        question: 'Ada masalah dengan pesanan?',
      ),
    ],
    this.website = 'tokocosplay.myhobbytown.com',
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _C.bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const _HeroCard(),
          const SizedBox(height: 28),
          const _SectionTitle('Hubungi Kami'),
          const SizedBox(height: 14),
          _ContactCard(
            icon: Icons.chat_outlined,
            iconColor: _C.whatsapp,
            channel: admin,
            buttonLabel: 'Chat Admin',
            buttonIcon: Icons.chat_bubble_outline,
            filled: true,
            onPressed: onChatAdmin,
          ),
          const SizedBox(height: 16),
          _ContactCard(
            icon: Icons.storefront_outlined,
            iconColor: _C.accent,
            channel: shop,
            buttonLabel: 'Chat Toko',
            filled: false,
            onPressed: onChatShop,
          ),
          const SizedBox(height: 16),
          _LocationCard(location: location, onPressed: onOpenLocation),
          const SizedBox(height: 28),
          const _SectionTitle('Pertanyaan Umum'),
          const SizedBox(height: 14),
          _FaqCard(faqs: faqs, onTap: onFaqTap),
          const SizedBox(height: 32),
          _Footer(website: website),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared bits
// ---------------------------------------------------------------------------
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: _C.ink,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool filled;
  final VoidCallback? onPressed;

  const _PillButton({
    required this.label,
    required this.filled,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(26),
    );

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: filled
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.ink,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: shape,
              ),
              child: _content(text),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.ink,
                side: const BorderSide(color: _C.ink),
                shape: shape,
              ),
              child: _content(text),
            ),
    );
  }

  Widget _content(Widget text) {
    if (icon == null) return text;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 18), const SizedBox(width: 8), text],
    );
  }
}

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------
class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.heroStart, _C.heroEnd],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.forum_outlined, color: _C.accent, size: 34),
          SizedBox(height: 18),
          Text(
            'Ada yang bisa kami\nbantu?',
            style: TextStyle(
              fontSize: 26,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Dari ukuran cosplay sampai kabar paket,\nkami siap menemani.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Color(0xFFC9C4D8),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Contact card (WhatsApp Admin / WhatsApp Shop)
// ---------------------------------------------------------------------------
class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final ContactChannel channel;
  final String buttonLabel;
  final IconData? buttonIcon;
  final bool filled;
  final VoidCallback? onPressed;

  const _ContactCard({
    required this.icon,
    required this.iconColor,
    required this.channel,
    required this.buttonLabel,
    required this.filled,
    this.buttonIcon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _C.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      channel.phone,
                      style: const TextStyle(fontSize: 12, color: _C.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            channel.description,
            style: const TextStyle(fontSize: 12, height: 1.4, color: _C.muted),
          ),
          const SizedBox(height: 14),
          _PillButton(
            label: buttonLabel,
            icon: buttonIcon,
            filled: filled,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Location card
// ---------------------------------------------------------------------------
class _LocationCard extends StatelessWidget {
  final StoreLocation location;
  final VoidCallback? onPressed;

  const _LocationCard({required this.location, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mampir ke Toko',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _C.ink,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.location_on_outlined,
                  color: _C.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.address,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                        color: _C.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      location.note,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: _C.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _PillButton(
            label: 'Lihat Lokasi',
            icon: Icons.navigation_outlined,
            filled: false,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FAQ
// ---------------------------------------------------------------------------
class _FaqCard extends StatelessWidget {
  final List<FaqItem> faqs;
  final ValueChanged<int>? onTap;

  const _FaqCard({required this.faqs, this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < faqs.length; i++) ...[
            InkWell(
              onTap: onTap == null ? null : () => onTap!(i),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(faqs[i].icon, size: 20, color: _C.ink),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        faqs[i].question,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _C.ink,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 20, color: _C.muted),
                  ],
                ),
              ),
            ),
            if (i != faqs.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 18,
                endIndent: 18,
                color: _C.border,
              ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Footer
// ---------------------------------------------------------------------------
class _Footer extends StatelessWidget {
  final String website;

  const _Footer({required this.website});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _C.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'myhobbytown.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _C.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: _C.tagBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Sejak 2003',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _C.tagFg,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Teman tepercaya untuk anime, manga, cosplay, dan gaya hidup '
            'Jepang di Indonesia.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, height: 1.5, color: _C.muted),
          ),
        ),
        const SizedBox(height: 10),
        Text(website, style: const TextStyle(fontSize: 11, color: _C.muted)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Example usage (remove once wired into your router)
// ---------------------------------------------------------------------------
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: TopAppBarContent(
          titleText: "Bantuan & Kontak",
          shouldShowBackButton: true,
        ),
      ),
      body: HelpContactScreen(),
    );
  }
}
