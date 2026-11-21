import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hobby_town_demo/components/top_app_bar.dart';
import 'package:hobby_town_demo/models/address.dart';
import 'package:hobby_town_demo/providers/address_provider.dart';

class _C {
  static const Color pink = Color(0xFFFF3D7F);
  static const Color pinkSoft = Color(0xFFFFE3EC);
  static const Color red = Color(0xFFE5484D);
  static const Color redSoft = Color(0xFFFDECEC);
  static const Color ink = Color(0xFF14121A);
  static const Color muted = Color(0xFF6E6B78);
  static const Color hint = Color(0xFFA29FAD);
  static const Color bg = Color(0xFFF7F6FB);
  static const Color field = Color(0xFFF3F2F7);
  static const Color border = Color(0xFFE4E2EC);
  static const Color lavender = Color(0xFFEDE6FA);
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(24),
  boxShadow: const [
    BoxShadow(color: Color(0x0F1B1530), blurRadius: 20, offset: Offset(0, 6)),
  ],
);

class AddressPage extends ConsumerStatefulWidget {
  const AddressPage({super.key, this.onChanged});

  final ValueChanged<List<ShippingAddress>>? onChanged;

  @override
  ConsumerState<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends ConsumerState<AddressPage> {
  late List<ShippingAddress> _addresses;

  void _notify() => widget.onChanged?.call(List.unmodifiable(_addresses));

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openForm({ShippingAddress? existing}) async {
    final result = await showModalBottomSheet<ShippingAddress>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => _AddressFormSheet(existing: existing),
    );
    if (result == null || !mounted) return;

    setState(() {
      final index = _addresses.indexWhere((a) => a.id == result.id);
      if (index >= 0) {
        _addresses = List.of(_addresses)..[index] = result;
      } else {
        _addresses = [result, ..._addresses];
      }
      ref.read(addressProvider.notifier).state = _addresses;
    });
    _notify();
    _toast(existing == null ? 'Alamat ditambahkan' : 'Alamat diperbarui');
  }

  Future<void> _confirmDelete(ShippingAddress address) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Hapus alamat?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _C.ink,
          ),
        ),
        content: Text(
          'Alamat atas nama ${address.firstName} ${address.lastName} akan dihapus dari daftarmu.',
          style: const TextStyle(fontSize: 13.5, color: _C.muted, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: _C.ink),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: _C.red),
            child: const Text(
              'Hapus',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() {
      _addresses = _addresses.where((a) => a.id != address.id).toList();
      ref.read(addressProvider.notifier).state = _addresses;
    });
    _notify();
    _toast('Alamat dihapus');
  }

  @override
  void initState() {
    super.initState();
    _addresses = ref.watch(addressSelector);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _C.bg,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        // Bottom padding leaves room for the floating navigation bar.
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola alamat pengirimanmu.',
              style: TextStyle(fontSize: 14, color: _C.muted),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Tambah Alamat Baru'),
                style: FilledButton.styleFrom(
                  backgroundColor: _C.ink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            if (_addresses.isEmpty)
              const _EmptyState()
            else ...[
              Text(
                '${_addresses.length} alamat tersimpan',
                style: const TextStyle(fontSize: 12, color: _C.muted),
              ),
              const SizedBox(height: 12),
              for (final address in _addresses) ...[
                _AddressCard(
                  address: address,
                  onEdit: () => _openForm(existing: address),
                  onDelete: () => _confirmDelete(address),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List widgets
// ---------------------------------------------------------------------------

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  final ShippingAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: _C.pinkSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: _C.pink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _C.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address.phoneNo,
                      style: const TextStyle(fontSize: 12.5, color: _C.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            address.address,
            style: const TextStyle(
              fontSize: 12.5,
              color: _C.muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kode pos ${address.postCode}',
            style: const TextStyle(fontSize: 12.5, color: _C.muted),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _C.lavender,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.my_location_rounded,
                  size: 14,
                  color: Color(0xFF2A1B3D),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    address.lat != null
                        ? '${address.lat!.toStringAsFixed(6)}, '
                              '${address.lng!.toStringAsFixed(6)}'
                        : "",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2A1B3D),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Ubah',
                  foreground: _C.ink,
                  background: Colors.white,
                  borderColor: _C.border,
                  onTap: onEdit,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Hapus',
                  foreground: _C.red,
                  background: _C.redSoft,
                  borderColor: _C.redSoft,
                  onTap: onDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
    required this.borderColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: StadiumBorder(side: BorderSide(color: borderColor)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 42,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: foreground),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE9E2FB), Color(0xFFFFE3EE)],
                ),
              ),
              child: const Icon(
                Icons.location_off_outlined,
                size: 56,
                color: Color(0xFF2A1B3D),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum ada alamat',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _C.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan alamat agar pesananmu sampai dengan tepat.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: _C.muted, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressFormSheet extends StatefulWidget {
  const _AddressFormSheet({this.existing});

  final ShippingAddress? existing;

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late final TextEditingController _postcode;
  double? lat;
  double? lng;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    _firstName = TextEditingController(text: a?.firstName ?? '');
    _lastName = TextEditingController(text: a?.lastName ?? '');
    _address = TextEditingController(text: a?.address ?? '');
    _phone = TextEditingController(text: a?.phoneNo ?? '');
    _postcode = TextEditingController(text: a?.postCode ?? '');
    if (a != null) {
      lat = a.lat;
      lng = a.lng;
    }
  }

  Future<void> onPickLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }
    Position currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      lat = currentPosition.latitude;
      lng = currentPosition.longitude;
    });
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _address.dispose();
    _phone.dispose();
    _postcode.dispose();
    super.dispose();
  }

  void _save() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    Navigator.of(context).pop(
      ShippingAddress(
        id:
            widget.existing?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        address: _address.text.trim(),
        phoneNo: _phone.text.trim(),
        postCode: _postcode.text.trim(),
        lat: lat,
        lng: lng,
      ),
    );
  }

  String? Function(String?) _required(String message) =>
      (v) => (v ?? '').trim().isEmpty ? message : null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0DEE8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEdit ? 'Ubah Alamat' : 'Tambah Alamat',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _C.ink,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'Nama Depan',
                            hint: 'Naya',
                            controller: _firstName,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            validator: _required('Wajib diisi'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LabeledField(
                            label: 'Nama Belakang',
                            hint: 'Putri',
                            controller: _lastName,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            validator: _required('Wajib diisi'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Nomor Telepon',
                      hint: '0812 3456 7890',
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.phone_outlined,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                        LengthLimitingTextInputFormatter(16),
                      ],
                      validator: (v) {
                        final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                        if (digits.isEmpty) return 'Nomor telepon wajib diisi';
                        if (digits.length < 9)
                          return 'Nomor telepon tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Alamat Lengkap',
                      hint: 'Nama jalan, nomor rumah, RT/RW, kelurahan, kecamatan',
                      controller: _address,
                      maxLines: 4,
                      keyboardType: TextInputType.streetAddress,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return 'Alamat lengkap wajib diisi';
                        if (t.length < 10) return 'Alamat terlalu singkat';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Kode Pos',
                      hint: '12345',
                      controller: _postcode,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.markunread_mailbox_outlined,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return 'Kode pos wajib diisi';
                        if (t.length != 5) return 'Kode pos harus 5 digit';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _PinpointCard(
                      lat: lat,
                      lng: lng,
                      hasError: false,
                      onPick: onPickLocation,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: _C.ink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(_isEdit ? 'Simpan Perubahan' : 'Simpan Alamat'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinpointCard extends StatelessWidget {
  const _PinpointCard({
    required this.hasError,
    required this.onPick,
    this.lat,
    this.lng,
  });

  final double? lat;
  final double? lng;
  final bool hasError;
  final Future<void> Function() onPick;

  @override
  Widget build(BuildContext context) {
    final has = lat != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: hasError ? Border.all(color: _C.red, width: 1.4) : null,
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF15111A), Color(0xFF38234A)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _C.lavender,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pinpoint Lokasi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A1B3D),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0x1AFFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      has
                          ? Icons.location_on_rounded
                          : Icons.location_off_outlined,
                      color: has ? _C.pink : Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          has
                              ? 'Titik lokasi tersimpan'
                              : 'Belum ada titik lokasi',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          has
                              ? '${lat!.toStringAsFixed(6)}, '
                                    '${lng!.toStringAsFixed(6)}'
                              : 'Bantu kurir menemukan alamatmu dengan lebih mudah.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB9B4C6),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await onPick();
                    return;
                  },
                  icon: const Icon(Icons.my_location_rounded, size: 18),
                  label: Text(
                    has ? 'Ubah Titik Lokasi' : 'Tentukan Titik Lokasi',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white38,
                    side: const BorderSide(color: Color(0x59FFFFFF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError)
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 6),
            child: Text(
              'Titik lokasi wajib ditentukan',
              style: TextStyle(fontSize: 11.5, color: _C.red),
            ),
          ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.prefixIcon,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;
  final int maxLines;

  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: _C.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          minLines: maxLines,
          style: const TextStyle(fontSize: 14, color: _C.ink),
          cursorColor: _C.pink,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13.5, color: _C.hint),
            filled: true,
            fillColor: _C.field,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 20, color: _C.muted),
            errorStyle: const TextStyle(fontSize: 11.5),
            border: _border(Colors.transparent),
            enabledBorder: _border(Colors.transparent),
            focusedBorder: _border(_C.pink, 1.4),
            errorBorder: _border(_C.red),
            focusedErrorBorder: _border(_C.red, 1.4),
          ),
        ),
      ],
    );
  }
}

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: TopAppBarContent(
          titleText: "Kelola Alamat",
          shouldShowBackButton: true,
        ),
      ),
      body: AddressPage(),
    );
  }
}
