import 'package:flutter/material.dart';
import 'package:hobby_town_demo/models/item.dart';
import 'package:hobby_town_demo/utils/utils.dart';

class _C {
  static const bg = Color(0xFFF7F7FA);
  static const card = Colors.white;
  static const accent = Color(0xFFF03E78);
  static const accentSoft = Color(0xFFFFE4EC);
  static const lavender = Color(0xFFEDE7FB);
  static const ink = Color(0xFF111114);
  static const muted = Color(0xFF6E6E78);
  static const success = Color(0xFF22C55E);
  static const successSoft = Color(0xFFDCF7E5);
  static const successInk = Color(0xFF15803D);
  static const illustration = Color(0xFF2B1F4A);
}

String _rupiah(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

class OrderSuccessScreen extends StatelessWidget {
  final Order order;

  void onTrackOrder() {}

  void onBackToHome() {}

  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBackToHome();
      },
      child: Scaffold(
        backgroundColor: _C.bg,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 44,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _SuccessIllustration(),
                      const SizedBox(height: 28),
                      const Text(
                        'Hore, pesananmu\nberhasil!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          color: _C.ink,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Pembayaran diterima. Kami segera menyiapkan '
                          'kebahagiaan kecil untukmu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: _C.muted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _OrderSummaryCard(order: order),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: onTrackOrder,
                          icon: const Icon(
                            Icons.inventory_2_outlined,
                            size: 20,
                          ),
                          label: const Text(
                            'Lacak Pesanan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.ink,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: onBackToHome,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _C.ink,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: _C.ink),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'Kembali ke Beranda',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Illustration: gradient disc, parcel icon, green check badge, pink accent
// ---------------------------------------------------------------------------
class _SuccessIllustration extends StatelessWidget {
  const _SuccessIllustration();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: t, child: child),
      ),
      child: SizedBox(
        width: 190,
        height: 190,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 172,
              height: 172,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_C.lavender, _C.accentSoft],
                ),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 84,
                color: _C.illustration,
              ),
            ),
            // Small pink square, top-left
            Positioned(
              top: 8,
              left: 10,
              child: Transform.rotate(
                angle: 0.35,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _C.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            // Green check badge, top-right
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: _C.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Order summary card
// ---------------------------------------------------------------------------
class _OrderSummaryCard extends StatelessWidget {
  final Order order;

  const _OrderSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nomor pesanan',
                style: TextStyle(fontSize: 12, color: _C.muted),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _C.successSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Dibayar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _C.successInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.orderNo,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _C.ink,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.paymentMethod} · ${shortDate(order.paidAt)}',
                style: const TextStyle(fontSize: 13, color: _C.muted),
              ),
              Text(
                _rupiah(order.total),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _C.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // for (final line in order.summaryLines)
          //   Padding(
          //     padding: const EdgeInsets.only(bottom: 2),
          //     child: Text(
          //       line,
          //       style: const TextStyle(
          //         fontSize: 12,
          //         height: 1.45,
          //         color: _C.muted,
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
