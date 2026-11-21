import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_town_demo/components/top_app_bar.dart';
import 'package:hobby_town_demo/models/address.dart';
import 'package:hobby_town_demo/models/item.dart';
import 'package:hobby_town_demo/providers/address_provider.dart';
import 'package:hobby_town_demo/providers/catalog_provider.dart';
import 'package:hobby_town_demo/services/globals_service.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// Design tokens
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
}

String formatRupiah(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

class CheckoutScreenImpl extends ConsumerStatefulWidget {
  final List<CartEntry> items;

  const CheckoutScreenImpl({super.key, required this.items});

  @override
  ConsumerState<CheckoutScreenImpl> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreenImpl> {
  late ShippingAddress? _address;
  late ShippingOption _shipping;
  late List<ShippingAddress> _addresses;
  late List<ShippingOption> shippingOptions;

  void onPlaceOrder() {
    Order newOrder = Order(
      itemList: widget.items,
      total: getTotal(),
      orderNo: Uuid().v4(),
      paidAt: DateTime.now(),
      paymentMethod: "placeholder",
      courier: _shipping,
      trackingNumber: Uuid().v1(),
      sentAt: DateTime.now().add(Duration(seconds: 30)),
      arrivedAt: DateTime.now().add(Duration(minutes: 1, seconds: 30)),
    );
    ref.read(cartProvider.notifier).state = [];
    ref.read(orderProvider.notifier).state.add(newOrder);
    Navigator.of(context)
      ..pop()
      ..pop();
  }

  int getTotal() {
    int total = 0;
    for (CartEntry i in widget.items) {
      total += i.lineTotal;
    }
    total += _shipping.price;
    return total;
  }

  @override
  void initState() {
    super.initState();
    _addresses = ref.watch(addressProvider);
    shippingOptions = GlobalsService.shippingOptions;
    _address = _addresses.firstOrNull;
    _shipping = shippingOptions.first;
  }

  Future<void> _changeAddress() async {
    final result = await showAddressSelectionSheet(
      context,
      addresses: _addresses,
      selectedId: _address!.id.toString(),
      onAddressAdded: (a) => setState(() => _addresses = [..._addresses, a]),
    );
    if (result != null && mounted) setState(() => _address = result);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _C.bg,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _AddressCard(address: _address, onChange: _changeAddress),
                const SizedBox(height: 20),
                ...widget.items.map(
                  (i) => _OrderCard(
                    item: i,
                    quantity: i.quantity,
                    onDecrement: i.quantity > 1
                        ? () => setState(() => i.quantity--)
                        : null,
                    onIncrement: () => setState(() => i.quantity++),
                  ),
                ),
                const SizedBox(height: 20),
                _ShippingCard(
                  options: shippingOptions,
                  selected: _shipping,
                  onSelected: (o) => setState(() => _shipping = o),
                ),
              ],
            ),
          ),
          _BottomBar(
            total: getTotal(),
            onPressed: () => onPlaceOrder(),
            disabled: _address == null,
          ),
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

TextStyle get _titleStyle =>
    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _C.ink);

class _AddressCard extends StatelessWidget {
  final ShippingAddress? address;
  final VoidCallback onChange;

  const _AddressCard({required this.address, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Alamat Pengiriman', style: _titleStyle),
              GestureDetector(
                onTap: onChange,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Text(
                    'Ubah',
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            address == null
                                ? "Belum ada alamat"
                                : address!.address,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _C.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _LabelChip("Lokasi"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "",
                      style: const TextStyle(
                        fontSize: 13,
                        color: _C.muted,
                        height: 1.4,
                      ),
                    ),
                    Text(
                      "",
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

class _LabelChip extends StatelessWidget {
  final String text;

  const _LabelChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _C.tagBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _C.tagFg,
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final CartEntry item;
  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const _OrderCard({
    required this.item,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pesananmu', style: _titleStyle),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 100,
                  height: 96,
                  color: const Color(0xFFD9D4DE),
                  child: item.item.imageUrl == null
                      ? const Icon(Icons.checkroom, color: _C.muted, size: 40)
                      : Image.network(
                          item.item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.checkroom,
                            color: _C.muted,
                            size: 40,
                          ),
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
                      '${item.variant} · $quantity produk',
                      style: const TextStyle(fontSize: 12, color: _C.muted),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatRupiah(item.item.price),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _C.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _QuantityStepper(
                      quantity: quantity,
                      onDecrement: onDecrement,
                      onIncrement: onIncrement,
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

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(icon: Icons.remove, onTap: onDecrement),
          SizedBox(
            width: 32,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _C.ink,
              ),
            ),
          ),
          _StepButton(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(icon, size: 18, color: onTap == null ? _C.border : _C.ink),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shipping card
// ---------------------------------------------------------------------------
class _ShippingCard extends StatelessWidget {
  final List<ShippingOption> options;
  final ShippingOption selected;
  final ValueChanged<ShippingOption> onSelected;

  const _ShippingCard({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilih Pengiriman', style: _titleStyle),
          const SizedBox(height: 14),
          for (final o in options) ...[
            _SelectableTile(
              selected: o.id == selected.id,
              onTap: () => onSelected(o),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          o.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _C.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          o.eta,
                          style: const TextStyle(fontSize: 11, color: _C.muted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatRupiah(o.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _C.ink,
                    ),
                  ),
                ],
              ),
            ),
            if (o != options.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// Bordered tile with a leading radio indicator; highlighted when selected.
class _SelectableTile extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const _SelectableTile({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _C.accentSoft.withOpacity(0.35) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? _C.accent : _C.border,
              width: selected ? 1.2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _RadioDot(selected: selected),
              const SizedBox(width: 12),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;

  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? _C.accentSoft : Colors.transparent,
        border: Border.all(color: selected ? _C.accent : _C.muted, width: 1.6),
      ),
      child: selected
          ? const Icon(Icons.check, size: 14, color: _C.accent)
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom bar
// ---------------------------------------------------------------------------
class _BottomBar extends StatelessWidget {
  final int total;
  final VoidCallback onPressed;
  final bool disabled;

  const _BottomBar({
    required this.total,
    required this.onPressed,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: disabled ? () {} : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: disabled ? Colors.grey : _C.ink,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'Buat Pesanan · ${formatRupiah(total)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<ShippingAddress?> showAddressSelectionSheet(
  BuildContext context, {
  required List<ShippingAddress> addresses,
  required String selectedId,
  ValueChanged<ShippingAddress>? onAddressAdded,
}) {
  return showModalBottomSheet<ShippingAddress>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddressSelectionSheet(
      addresses: addresses,
      selectedId: selectedId,
      onAddressAdded: onAddressAdded,
    ),
  );
}

class _AddressSelectionSheet extends StatefulWidget {
  final List<ShippingAddress> addresses;
  final String selectedId;
  final ValueChanged<ShippingAddress>? onAddressAdded;

  const _AddressSelectionSheet({
    required this.addresses,
    required this.selectedId,
    this.onAddressAdded,
  });

  @override
  State<_AddressSelectionSheet> createState() => _AddressSelectionSheetState();
}

class _AddressSelectionSheetState extends State<_AddressSelectionSheet> {
  late List<ShippingAddress> _addresses = List.of(widget.addresses);
  late String _selectedId = widget.selectedId;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: _C.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(child: Text('Pilih Alamat', style: _titleStyle)),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: _C.ink),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                itemCount: _addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final a = _addresses[i];
                  return _SelectableTile(
                    selected: a.id == _selectedId,
                    onTap: () => setState(() => _selectedId = a.id),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                "${a.firstName} ${a.lastName}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _C.ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _LabelChip("Lokasi"),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          a.phoneNo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _C.muted,
                            height: 1.4,
                          ),
                        ),
                        Text(
                          a.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _C.muted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              color: Colors.white,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        final chosen = _addresses.firstWhere(
                          (a) => a.id == _selectedId,
                        );
                        Navigator.of(context).pop(chosen);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.ink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Gunakan Alamat Ini',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewAddressSheet extends StatefulWidget {
  const _NewAddressSheet();

  @override
  State<_NewAddressSheet> createState() => _NewAddressSheetState();
}

class _NewAddressSheetState extends State<_NewAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phoneNo = TextEditingController();
  final _address = TextEditingController();
  final _postCode = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phoneNo.dispose();
    _address.dispose();
    _postCode.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: _C.muted, fontSize: 13),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _C.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _C.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _C.accent),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
  );

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;

  String? _validatePostCode(String? v) {
    final text = v?.trim() ?? '';
    if (text.isEmpty) return 'Wajib diisi';
    if (!RegExp(r'^\d{5}$').hasMatch(text)) return 'Kode pos harus 5 digit';
    return null;
  }

  /// Accepts both "-6.30" and "-6,30".
  double? _parseCoord(String? v) =>
      double.tryParse((v ?? '').trim().replaceAll(',', '.'));

  String? Function(String?) _coordValidator(double min, double max) {
    return (v) {
      if (v == null || v.trim().isEmpty) return 'Wajib diisi';
      final value = _parseCoord(v);
      if (value == null) return 'Angka tidak valid';
      if (value < min || value > max) return 'Di luar rentang';
      return null;
    };
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      ShippingAddress(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        phoneNo: _phoneNo.text.trim(),
        address: _address.text.trim(),
        postCode: _postCode.text.trim(),
        lat: _parseCoord(_lat.text)!,
        lng: _parseCoord(_lng.text)!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const coordKeyboard = TextInputType.numberWithOptions(
      decimal: true,
      signed: true,
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: _C.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _C.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Tambah Alamat Baru', style: _titleStyle),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstName,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: _dec('Nama depan'),
                          validator: _required,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lastName,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: _dec('Nama belakang'),
                          validator: _required,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneNo,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: _dec('Nomor telepon'),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _address,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _dec('Alamat lengkap'),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _postCode,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    textInputAction: TextInputAction.next,
                    decoration: _dec('Kode pos').copyWith(counterText: ''),
                    validator: _validatePostCode,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _lat,
                          keyboardType: coordKeyboard,
                          textInputAction: TextInputAction.next,
                          decoration: _dec('Latitude'),
                          validator: _coordValidator(-90, 90),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lng,
                          keyboardType: coordKeyboard,
                          textInputAction: TextInputAction.done,
                          decoration: _dec('Longitude'),
                          validator: _coordValidator(-180, 180),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.ink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Simpan Alamat',
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
        ),
      ),
    );
  }
}

class CheckoutScreen extends StatelessWidget {
  final List<CartEntry> items;

  const new({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: TopAppBarContent(titleText: "Cart", shouldShowBackButton: true),
      ),
      body: CheckoutScreenImpl(items: items),
    );
  }
}
