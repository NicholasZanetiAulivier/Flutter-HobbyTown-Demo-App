import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hobby_town_demo/models/address.dart';
import 'package:hobby_town_demo/models/item.dart';
import 'package:hobby_town_demo/screens/checkout_screen.dart';
import 'package:hobby_town_demo/screens/contact_screen.dart';
import 'package:hobby_town_demo/screens/order_tracking_screen.dart';

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
  static const successSoft = Color(0xFFDCF7E5);
  static const successInk = Color(0xFF15803D);
}

String _dateTime(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.day} ${months[d.month - 1]} ${d.year}, '
      '${two(d.hour)}.${two(d.minute)}';
}

class OrderDetailScreenImpl extends StatelessWidget {
  final Order order;

  /// Shown as the black primary button, only for shipped orders.
  final VoidCallback? onTrackOrder;

  /// Shown as the outlined secondary button ("Butuh Bantuan?").
  final VoidCallback? onContactSupport;

  const OrderDetailScreenImpl({
    super.key,
    required this.order,
    this.onTrackOrder,
    this.onContactSupport,
  });

  Future<void> _copyTracking(BuildContext context) async {
    final number = order.trackingNumber;
    if (number == null) return;
    await Clipboard.setData(ClipboardData(text: number));
    if (!context.mounted) return;
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
    final showTrack =
        order.status == OrderStatus.shipping && onTrackOrder != null;
    final showSupport = onContactSupport != null;

    return ColoredBox(
      color: _C.bg,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _HeaderCard(order: order),
                const SizedBox(height: 20),
                _AddressCard(address: order.address),
                const SizedBox(height: 20),
                _ItemsCard(items: order.itemList),
                const SizedBox(height: 20),
                _ShippingCard(
                  order: order,
                  onCopy: () => _copyTracking(context),
                ),
                const SizedBox(height: 20),
                _PaymentCard(order: order),
              ],
            ),
          ),
          if (showTrack || showSupport)
            _BottomBar(
              showTrack: showTrack,
              onTrackOrder: onTrackOrder,
              onContactSupport: onContactSupport,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared card shell + title
// ---------------------------------------------------------------------------
class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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

const _titleStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w800,
  color: _C.ink,
);

// ---------------------------------------------------------------------------
// Header: order number, status, date
// ---------------------------------------------------------------------------
class _HeaderCard extends StatelessWidget {
  final Order order;

  const _HeaderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return _Card(
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
              _StatusChip(status: order.status),
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
          const SizedBox(height: 6),
          Text(
            'Dipesan ${_dateTime(order.paidAt)}',
            style: const TextStyle(fontSize: 12, color: _C.muted),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      OrderStatus.ready => (_C.tagBg, _C.tagFg),
      OrderStatus.shipping => (_C.accentSoft, _C.accent),
      OrderStatus.done => (_C.successSoft, _C.successInk),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Address (read-only version of the checkout card)
// ---------------------------------------------------------------------------
class _AddressCard extends StatelessWidget {
  final ShippingAddress address;

  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Alamat Pengiriman', style: _titleStyle),
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
                      address.fullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _C.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      address.phoneNo,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _C.muted,
                        height: 1.4,
                      ),
                    ),
                    Text(
                      address.address,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _C.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Items
// ---------------------------------------------------------------------------
class _ItemsCard extends StatelessWidget {
  final List<CartEntry> items;

  const _ItemsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pesanan', style: _titleStyle),
          const SizedBox(height: 14),
          for (var i = 0; i < items.length; i++) ...[
            _ItemRow(item: items[i]),
            if (i != items.length - 1) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, thickness: 1, color: _C.border),
              const SizedBox(height: 14),
            ],
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final CartEntry item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    const placeholder = Icon(Icons.checkroom, color: _C.muted, size: 32);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 80,
                height: 80,
                color: const Color(0xFFD9D4DE),
                child: item.item.imageUrl == null
                    ? placeholder
                    : Image.network(
                        item.item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => placeholder,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.variant} · ${item.quantity} produk',
                    style: const TextStyle(fontSize: 12, color: _C.muted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.quantity} × ${formatRupiah(item.item.price)}',
                        style: const TextStyle(fontSize: 12, color: _C.muted),
                      ),
                      Text(
                        formatRupiah(item.lineTotal),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _C.ink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        // if (item. != null) ...[
        //   const SizedBox(height: 12),
        //   Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //     decoration: BoxDecoration(
        //       color: _C.accentSoft,
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     child: Text(
        //       item.bonus!,
        //       style: const TextStyle(
        //         fontSize: 12,
        //         fontWeight: FontWeight.w600,
        //         color: _C.accent,
        //       ),
        //     ),
        //   ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shipping: courier, estimate, tracking number
// ---------------------------------------------------------------------------
class _ShippingCard extends StatelessWidget {
  final Order order;
  final VoidCallback onCopy;

  const _ShippingCard({required this.order, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final tracking = order.trackingNumber;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pengiriman', style: _titleStyle),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: _C.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  size: 20,
                  color: _C.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.courier.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _C.ink,
                      ),
                    ),
                    if (order.arrivedAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _dateTime(order.arrivedAt),
                        style: const TextStyle(fontSize: 12, color: _C.muted),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _C.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nomor resi',
                        style: TextStyle(fontSize: 11, color: _C.muted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tracking ?? 'Belum tersedia',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: tracking == null ? _C.muted : _C.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                if (tracking != null)
                  IconButton(
                    onPressed: onCopy,
                    tooltip: 'Salin nomor resi',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.copy_outlined,
                      size: 20,
                      color: _C.ink,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Payment summary
// ---------------------------------------------------------------------------
class _PaymentCard extends StatelessWidget {
  final Order order;

  const _PaymentCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rincian Pembayaran', style: _titleStyle),
          const SizedBox(height: 14),
          _SummaryRow(label: 'Metode pembayaran', value: order.paymentMethod),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Subtotal produk',
            value: formatRupiah(order.total),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Ongkos kirim (${order.courier})',
            value: formatRupiah(order.courier.price),
          ),
          // if (order.discount > 0) ...[
          //   const SizedBox(height: 12),
          //   _SummaryRow(
          //     label: 'Diskon',
          //     value: '- ${formatRupiah(order.discount)}',
          //     valueColor: _C.successInk,
          //   ),
          // ],
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: _C.border),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _C.ink,
                ),
              ),
              Text(
                formatRupiah(order.total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _C.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor = _C.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: _C.muted),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom bar
// ---------------------------------------------------------------------------
class _BottomBar extends StatelessWidget {
  final bool showTrack;
  final VoidCallback? onTrackOrder;
  final VoidCallback? onContactSupport;

  const _BottomBar({
    required this.showTrack,
    this.onTrackOrder,
    this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    );

    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showTrack)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: onTrackOrder,
                    icon: const Icon(Icons.local_shipping_outlined, size: 20),
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
                      shape: shape,
                    ),
                  ),
                ),
              if (showTrack && onContactSupport != null)
                const SizedBox(height: 12),
              if (onContactSupport != null)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: onContactSupport,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _C.ink,
                      side: const BorderSide(color: _C.ink),
                      shape: shape,
                    ),
                    child: const Text(
                      'Butuh Bantuan?',
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Example usage (remove once wired into your router)
// ---------------------------------------------------------------------------
class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan'), centerTitle: true),
      body: OrderDetailScreenImpl(
        order: order,
        onTrackOrder: () {
          Navigator.of(context)
            ..pop()
            ..push(
              MaterialPageRoute(
                builder: (context) => OrderTrackingScreen(order: order),
              ),
            );
        },
        onContactSupport: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => ContactScreen()));
        },
      ),
    );
  }
}
