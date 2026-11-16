import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hobby_town_demo/components/labeled_field.dart';
import 'package:hobby_town_demo/components/pin_point_card.dart';
import 'package:hobby_town_demo/components/section_dart.dart';
import 'package:hobby_town_demo/constants/colors.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key, this.onSave});

  /// Called only after the form has passed validation.
  final VoidCallback? onSave;

  @override
  State<AddressScreen> createState() => _AddressScreenState();

  static String? Function(String?) _required(String message) {
    return (value) => (value ?? '').trim().isEmpty ? message : null;
  }
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
        color: BG,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          // Bottom padding leaves room for the floating navigation bar.
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Alamat',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: INK,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Isi detail alamat agar pesananmu sampai dengan tepat.',
                  style: TextStyle(fontSize: 13, color: MUTED, height: 1.4),
                ),
                const SizedBox(height: 20),
                SectionCard(
                  title: 'Data Penerima',
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: LabeledField(
                            label: 'Nama Depan',
                            hint: 'Naya',
                            controller: firstNameController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            validator: AddressScreen._required(
                              'Nama depan wajib diisi',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LabeledField(
                            label: 'Nama Belakang',
                            hint: 'Putri',
                            controller: lastNameController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            validator: AddressScreen._required(
                              'Nama belakang wajib diisi',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LabeledField(
                      label: 'Nomor Telepon',
                      hint: '0812 3456 7890',
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.phone_outlined,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                        LengthLimitingTextInputFormatter(16),
                      ],
                      validator: (value) {
                        final digits = (value ?? '').replaceAll(
                          RegExp(r'\D'),
                          '',
                        );
                        if (digits.isEmpty) return 'Nomor telepon wajib diisi';
                        if (digits.length < 9)
                          return 'Nomor telepon tidak valid';
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SectionCard(
                  title: 'Alamat Pengiriman',
                  children: [
                    LabeledField(
                      label: 'Alamat Lengkap',
                      hint: 'Nama jalan, nomor rumah, RT/RW, kelurahan, kecamatan',
                      controller: addressController,
                      maxLines: 4,
                      keyboardType: TextInputType.streetAddress,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) return 'Alamat lengkap wajib diisi';
                        if (text.length < 10) return 'Alamat terlalu singkat';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    LabeledField(
                      label: 'Kode Pos',
                      hint: '12345',
                      controller: postcodeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.markunread_mailbox_outlined,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) return 'Kode pos wajib diisi';
                        if (text.length != 5) return 'Kode pos harus 5 digit';
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                PinPointCard(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: () {
                      final valid = true;
                      if (!valid) return;

                      widget.onSave?.call();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: PINK,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    child: const Text('Simpan Alamat'),
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
