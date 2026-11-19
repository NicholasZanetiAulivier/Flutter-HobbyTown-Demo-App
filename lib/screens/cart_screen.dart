import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_town_demo/components/top_app_bar.dart';
import 'package:hobby_town_demo/models/item.dart';
import 'package:hobby_town_demo/providers/catalog_provider.dart';
import 'package:hobby_town_demo/screens/checkout_screen.dart';

class CartScreenImpl extends ConsumerStatefulWidget {
  const CartScreenImpl({super.key});

  @override
  ConsumerState<CartScreenImpl> createState() => CartScreenStateImpl();
}

class CartScreenStateImpl extends ConsumerState<CartScreenImpl> {
  static const Color _pink = Color(0xFFFF4D8D);
  static const Color _pinkSoft = Color(0xFFFFE1EC);
  static const Color _ink = Color(0xFF111111);
  static const Color _muted = Color(0xFF6B6B6B);
  static const Color _background = Color(0xFFF7F6F9);
  static const Color _lavender = Color(0xFFC9C2E3);

  late final List<CartEntry> entries;

  /// Discount in rupiah applied to the subtotal.
  final int discount = 0;

  /// Subtotal needed to unlock the free gift banner.
  final int giftThreshold = 175000;
  final String giftTitle = 'Yey, kamu dapat #MHTlimitedSticker!';

  void onSelectAllChanged(bool b) {}

  void onQuantityChanged(CartEntry entry, int quantity) {}

  void onRemoveItem(CartEntry c) {}

  void onApplyVoucher(String s) {}

  void onCheckout(List<CartEntry> carts) {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutScreenImpl(
          items: carts.where((element) => element.selected).toList(),
        ),
      ),
    );
  }

  final TextEditingController _voucherController = TextEditingController();

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  // ---- Derived values -----------------------------------------------------
  List<CartEntry> get _selectedEntries =>
      entries.where((e) => e.selected).toList();

  int get _subtotal => _selectedEntries.fold(0, (sum, e) => sum + e.lineTotal);

  int get _total {
    final value = _subtotal - discount;
    return value < 0 ? 0 : value;
  }

  bool get _allSelected =>
      entries.isNotEmpty && entries.every((e) => e.selected);

  String _formatPrice(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }

  // ---- Actions ------------------------------------------------------------
  void _toggleSelectAll() {
    onSelectAllChanged(!_allSelected);
  }

  void _applyVoucher() {
    final code = _voucherController.text.trim();
    if (code.isEmpty) return;
    FocusScope.of(context).unfocus();
    onApplyVoucher(code);
  }

  void _checkout() {
    onCheckout(_selectedEntries);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    entries = ref.watch(cartSelector);
  }

  // ---- Build --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _background,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _buildSelectAllRow(),
                const SizedBox(height: 12),
                for (final entry in entries) _buildCartItem(entry),
                if (entries.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  const Text(
                    'Geser ke kiri untuk menghapus produk',
                    style: TextStyle(fontSize: 11, color: _muted),
                  ),
                  const SizedBox(height: 16),
                  _buildGiftBanner(),
                ],
                const SizedBox(height: 20),
                _buildVoucher(),
                const SizedBox(height: 20),
                _buildSummary(),
              ],
            ),
          ),
          _buildCheckoutBar(),
        ],
      ),
    );
  }

  Widget _buildSelectAllRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: _toggleSelectAll,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _allSelected
                      ? Icons.check_circle_outline
                      : Icons.circle_outlined,
                  size: 20,
                  color: _pink,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pilih semua (${_selectedEntries.length})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(
          '${entries.length} produk',
          style: const TextStyle(fontSize: 12, color: _muted),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey('${entry.item.id}-${entry.size}-${entry.variant}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onRemoveItem?.call(entry),
        background: const SizedBox.shrink(),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: _pinkSoft,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, color: _pink),
              SizedBox(height: 4),
              Text(
                'Hapus',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _pink,
                ),
              ),
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 76,
                  height: 76,
                  color: _lavender,
                  child: Image.network(
                    entry.item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image_outlined, color: _muted),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.variant} \u00b7 ${entry.size} \u00b7 ${entry.quantity} produk',
                      style: const TextStyle(fontSize: 11, color: _muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(entry.item.price),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStepper(entry),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper(CartEntry entry) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDADADA)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperButton(
            icon: Icons.remove,
            enabled: entry.quantity > 1,
            onPressed: () => onQuantityChanged?.call(entry, entry.quantity - 1),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${entry.quantity}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          _stepperButton(
            icon: Icons.add,
            enabled: true,
            onPressed: () => onQuantityChanged?.call(entry, entry.quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _stepperButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return InkResponse(
      onTap: enabled ? onPressed : null,
      radius: 18,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? _ink : const Color(0xFFB5B5B5),
        ),
      ),
    );
  }

  Widget _buildGiftBanner() {
    final threshold = giftThreshold;
    final progress = threshold <= 0
        ? 1.0
        : (_subtotal / threshold).clamp(0.0, 1.0);
    final unlocked = progress >= 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.card_giftcard, color: _pink, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unlocked
                          ? giftTitle
                          : 'Belanja ${_formatPrice(threshold - _subtotal)} lagi untuk hadiah',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatPrice(_subtotal)} / ${_formatPrice(threshold)}',
                      style: const TextStyle(fontSize: 11, color: _muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: _pink,
              backgroundColor: _pinkSoft,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Hadiah ditambahkan otomatis, selama persediaan ada.',
            style: TextStyle(fontSize: 11, color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucher() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Punya voucher?',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _voucherController,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => _applyVoucher(),
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Masukkan kode',
                  hintStyle: const TextStyle(fontSize: 13, color: _muted),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: _applyVoucher,
              style: OutlinedButton.styleFrom(
                foregroundColor: _ink,
                minimumSize: const Size(88, 50),
                side: const BorderSide(color: _ink, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Pakai'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan belanja',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(height: 14),
          _summaryRow(
            'Subtotal (${_selectedEntries.length} produk)',
            _formatPrice(_subtotal),
          ),
          const SizedBox(height: 10),
          _summaryRow(
            'Diskon',
            discount > 0 ? '-${_formatPrice(discount)}' : _formatPrice(0),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEFEFEF)),
          ),
          _summaryRow('Total', _formatPrice(_total), bold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: bold ? _ink : _muted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            color: _ink,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar() {
    final canCheckout = _selectedEntries.isNotEmpty;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEFEFEF))),
      ),
      child: FilledButton.icon(
        onPressed: canCheckout ? _checkout : null,
        icon: const Icon(Icons.arrow_forward, size: 18),
        label: Text('Checkout \u00b7 ${_formatPrice(_total)}'),
        style: FilledButton.styleFrom(
          backgroundColor: _ink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFCFCFD4),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: TopAppBarContent(titleText: "Cart", shouldShowBackButton: true),
      ),
      body: CartScreenImpl(),
    );
  }
}
