import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_town_demo/components/top_app_bar.dart';
import 'package:hobby_town_demo/models/item.dart';
import 'package:hobby_town_demo/providers/catalog_provider.dart';
import 'package:hobby_town_demo/screens/order_details_screen.dart';
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

String _rupiah(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

String _shortDate(DateTime d) {
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
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

class OrderHistoryScreen extends ConsumerStatefulWidget {
  final OrderStatus? initialFilter;

  const OrderHistoryScreen({super.key, this.initialFilter});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  late OrderStatus? _filter = widget.initialFilter;
  late List<Order> orders;

  void onOrderTap(Order o) {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => OrderDetailScreen(order: o)),
    );
  }

  void onTrackOrder(Order o) {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => OrderTrackingScreen(order: o)),
    );
  }

  int _countFor(OrderStatus? status) => status == null
      ? orders.length
      : orders.where((o) => o.status == status).length;

  @override
  void initState() {
    super.initState();
    orders = ref.watch(orderSelector);
  }

  @override
  Widget build(BuildContext context) {
    // Newest first.
    final visible =
        orders.where((o) => _filter == null || o.status == _filter).toList()
          ..sort((a, b) => b.paidAt.compareTo(a.paidAt));

    return ColoredBox(
      color: _C.bg,
      child: Column(
        children: [
          const SizedBox(height: 12),
          _FilterBar(
            selected: _filter,
            countFor: _countFor,
            onSelected: (s) => setState(() => _filter = s),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: visible.isEmpty
                  ? _EmptyState(key: ValueKey(_filter), filter: _filter)
                  : ListView.separated(
                      key: ValueKey(_filter),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      itemCount: visible.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) => _OrderCard(
                        order: visible[i],
                        onTap: () => onOrderTap(visible[i]),
                        onTrack: () => onTrackOrder(visible[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chips
// ---------------------------------------------------------------------------
class _FilterBar extends StatelessWidget {
  final OrderStatus? selected;
  final int Function(OrderStatus?) countFor;
  final ValueChanged<OrderStatus?> onSelected;

  const _FilterBar({
    required this.selected,
    required this.countFor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final options = <OrderStatus?>[null, ...OrderStatus.values];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final option = options[i];
          final isSelected = option == selected;
          final label = option?.label ?? 'Semua';

          return GestureDetector(
            onTap: () => onSelected(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? _C.ink : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? _C.ink : _C.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : _C.ink,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${countFor(option)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white.withOpacity(0.7)
                          : _C.muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;
  final VoidCallback? onTrack;

  const _OrderCard({required this.order, this.onTap, this.onTrack});

  @override
  Widget build(BuildContext context) {
    final extra = order.itemCount - 1;

    return Material(
      color: _C.card,
      borderRadius: BorderRadius.circular(24),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
                  Flexible(
                    child: Text(
                      order.orderNo,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: _C.muted),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(status: order.status),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Thumbnail(url: order.imageUrl),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.firstItemName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _C.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.firstItemVariant,
                          style: const TextStyle(fontSize: 12, color: _C.muted),
                        ),
                        if (extra > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '+$extra produk lainnya',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _C.muted,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          _rupiah(order.total),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _C.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, thickness: 1, color: _C.border),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _shortDate(order.paidAt),
                    style: const TextStyle(fontSize: 12, color: _C.muted),
                  ),
                  if (order.status == OrderStatus.shipping)
                    _TrackButton(onPressed: onTrack)
                  else
                    GestureDetector(
                      onTap: onTap,
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Lihat Detail',
                          style: TextStyle(
                            color: _C.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
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

class _Thumbnail extends StatelessWidget {
  final String? url;

  const _Thumbnail({this.url});

  @override
  Widget build(BuildContext context) {
    const placeholder = Icon(Icons.checkroom, color: _C.muted, size: 32);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 76,
        height: 76,
        color: const Color(0xFFD9D4DE),
        child: url == null
            ? placeholder
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}

class _TrackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _TrackButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.local_shipping_outlined, size: 16),
        label: const Text(
          'Lacak Pesanan',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.ink,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  final OrderStatus? filter;

  const _EmptyState({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      null => 'Kamu belum punya pesanan.',
      OrderStatus.ready => 'Tidak ada pesanan yang menunggu dikemas.',
      OrderStatus.shipping => 'Tidak ada pesanan yang sedang dikirim.',
      OrderStatus.done => 'Belum ada pesanan yang tiba.',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_C.tagBg, _C.accentSoft],
                ),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 44,
                color: Color(0xFF2B1F4A),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum ada pesanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _C.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: _C.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: TopAppBarContent(
          titleText: "Pesanan Saya",
          shouldShowBackButton: true,
        ),
      ),
      body: OrderHistoryScreen(),
    );
  }
}
