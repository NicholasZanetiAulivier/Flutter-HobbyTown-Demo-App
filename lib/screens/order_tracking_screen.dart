import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hobby_town_demo/components/top_app_bar.dart';
import 'package:hobby_town_demo/models/item.dart';
import 'package:hobby_town_demo/utils/utils.dart';

class _C {
  static const bg = Color(0xFFF7F7FA);
  static const card = Colors.white;
  static const accent = Color(0xFFF03E78);
  static const ink = Color(0xFF111114);
  static const muted = Color(0xFF6E6E78);
  static const border = Color(0xFFE6E6EC);
  static const tagBg = Color(0xFFEDE7FB);
  static const tagFg = Color(0xFF3B2A78);
  static const success = Color(0xFF22C55E);
  static const heroStart = Color(0xFF111114);
  static const heroEnd = Color(0xFF3B2A5E);
}

class OrderTrackingPart extends StatelessWidget {
  final Order data;

  final VoidCallback? onCopied;

  const OrderTrackingPart({super.key, required this.data, this.onCopied});

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: data.trackingNumber));
    if (!context.mounted) return;
    if (onCopied != null) {
      onCopied!();
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Nomor resi disalin'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _C.bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _HeroCard(data: data),
          const SizedBox(height: 20),
          _ShipmentCard(data: data, onCopy: () => _copy(context)),
          const SizedBox(height: 20),
          _TimelineCard(data: data),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared card shell
// ---------------------------------------------------------------------------
class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

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
      child: child,
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Order data;

  const _HeroCard({required this.data});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.local_shipping_outlined,
                color: _C.accent,
                size: 32,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _C.tagBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  data.arrivedAt.isAfter(DateTime.now())
                      ? (data.sentAt.isAfter(DateTime.now())
                            ? "Dibayar"
                            : "Dikirim")
                      : "Selesai",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _C.tagFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            "Barangmu sedang menuju rumah",
            style: const TextStyle(
              fontSize: 24,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "Estimasi tiba: 5-6 hari",
            style: const TextStyle(fontSize: 12, color: Color(0xFFC9C4D8)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shipment info (order number, courier, tracking number + copy)
// ---------------------------------------------------------------------------
class _ShipmentCard extends StatelessWidget {
  final Order data;
  final VoidCallback onCopy;

  const _ShipmentCard({required this.data, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.orderNo,
                  style: const TextStyle(fontSize: 12, color: _C.muted),
                ),
                const SizedBox(height: 14),
                Text(
                  data.courier.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.trackingNumber,
                  style: const TextStyle(fontSize: 12, color: _C.muted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCopy,
            tooltip: 'Salin nomor resi',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.copy_outlined, size: 20, color: _C.ink),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final Order data;

  const _TimelineCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perjalanan Pesanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _C.ink,
            ),
          ),
          const SizedBox(height: 20),
          _TimelineRow(
            title: "Dibayar",
            step: OrderStatus.ready,
            isLast: false,
            connectorDone: data.paidAt.isBefore(DateTime.now()),
            upcoming: false,
            date: data.paidAt,
          ),
          _TimelineRow(
            title: "Dikirim",
            step: OrderStatus.shipping,
            isLast: false,
            connectorDone: data.sentAt.isBefore(DateTime.now()),
            upcoming: data.paidAt.isAfter(DateTime.now()),
            date: data.sentAt,
          ),
          _TimelineRow(
            title: "Selesai",
            step: OrderStatus.done,
            isLast: true,
            connectorDone: data.arrivedAt.isBefore(DateTime.now()),
            upcoming: data.arrivedAt.isAfter(DateTime.now()),
            date: data.arrivedAt,
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final OrderStatus step;
  final bool isLast;
  final bool upcoming;
  final bool connectorDone;
  final DateTime date;
  final String title;

  const _TimelineRow({
    required this.step,
    required this.isLast,
    required this.connectorDone,
    required this.date,
    required this.title,
    required this.upcoming,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                _StepIndicator(
                  isDone: date.isBefore(DateTime.now()),
                  upcoming: upcoming,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: connectorDone ? _C.success : _C.border,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: upcoming ? _C.muted : _C.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.isBefore(DateTime.now())
                        ? shortDate(date)
                        : "Menunggu paket ${step == OrderStatus.ready ? "dibayar" : (step == OrderStatus.shipping ? "dikirim" : "sampai")}",
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: _C.muted,
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

class _StepIndicator extends StatelessWidget {
  final bool upcoming;
  final bool isDone;

  const _StepIndicator({required this.upcoming, required this.isDone});

  @override
  Widget build(BuildContext context) {
    if (upcoming) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _C.border, width: 1.6),
        ),
      );
    } else if (isDone) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _C.success.withOpacity(0.12),
          border: Border.all(color: _C.success, width: 1.6),
        ),
        child: const Icon(Icons.check, size: 14, color: _C.success),
      );
    } else {
      return const SizedBox(
        width: 24,
        height: 24,
        child: Icon(Icons.local_shipping, size: 22, color: _C.accent),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Example usage (remove once wired into your router)
// ---------------------------------------------------------------------------
class OrderTrackingScreen extends StatelessWidget {
  final Order order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: TopAppBarContent(titleText: "Cart", shouldShowBackButton: true),
      ),
      body: OrderTrackingPart(data: order),
    );
  }
}
