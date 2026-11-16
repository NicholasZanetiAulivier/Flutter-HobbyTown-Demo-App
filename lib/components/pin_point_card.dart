import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hobby_town_demo/constants/colors.dart';

class PinPointCard extends StatefulWidget {
  const PinPointCard();

  @override
  State<PinPointCard> createState() => _PinPointCardState();
}

class _PinPointCardState extends State<PinPointCard> {
  double? latitude;

  double? longitude;

  Future<void> getCurrentLocation() async {
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
      latitude = currentPosition.latitude;
      longitude = currentPosition.longitude;
    });
  }

  bool get _hasPinpoint => latitude != null && longitude != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE6FA),
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
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _hasPinpoint
                      ? Icons.location_on_rounded
                      : Icons.location_off_outlined,
                  color: _hasPinpoint ? PINK : Colors.white70,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasPinpoint
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
                      _hasPinpoint
                          ? '${latitude!.toStringAsFixed(6)}, '
                                '${longitude!.toStringAsFixed(6)}'
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
                await getCurrentLocation();
                debugPrint("${latitude}, ${longitude}");
              },
              icon: const Icon(Icons.my_location_rounded, size: 18),
              label: Text(
                _hasPinpoint ? 'Ubah Titik Lokasi' : 'Tentukan Titik Lokasi',
                style: Theme.of(context).textTheme.titleLarge!
                    .copyWith(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.35)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
