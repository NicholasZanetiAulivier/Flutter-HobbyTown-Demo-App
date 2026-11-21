import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_town_demo/constants/colors.dart';
import 'package:hobby_town_demo/providers/auth_provider.dart';
import 'package:hobby_town_demo/screens/address_screen.dart';
import 'package:hobby_town_demo/screens/contact_screen.dart';
import 'package:hobby_town_demo/screens/history_screen.dart';

import '../components/membership_banner.dart';
import '../components/menu_card.dart';
import '../components/profile_header.dart';
import '../models/menu_item_data.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
    this.avatar,
    this.onEditProfile,
    this.onWishlist,
    this.onNotifications,
  });

  final ImageProvider? avatar;
  final VoidCallback? onEditProfile;
  final VoidCallback? onWishlist;
  final VoidCallback? onNotifications;

  void onAbout(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ContactScreen()));
  }

  void onAddress(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AddressScreen()));
  }

  void onOrders(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => HistoryScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String name = ref.watch(usernameProvider);
    String email = ref.watch(emailProvider);
    return ColoredBox(
      color: BG,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 64),
            ProfileHeader(
              name: name,
              email: email,
              avatar: avatar,
              onEditProfile: onEditProfile,
            ),
            const SizedBox(height: 24),
            const MembershipBanner(),
            const SizedBox(height: 24),
            MenuCard(
              items: [
                MenuItemData(
                  icon: Icons.inventory_2_outlined,
                  title: 'Pesanan Saya',
                  subtitle: '1 pesanan dalam perjalanan',
                  onTap: () => onOrders(context),
                ),
                MenuItemData(
                  icon: Icons.location_on_outlined,
                  title: 'Alamat',
                  subtitle: 'Kelola alamat pengiriman',
                  onTap: () {
                    onAddress(context);
                  },
                ),
                MenuItemData(
                  icon: Icons.favorite_border_rounded,
                  title: 'Wishlist',
                  subtitle: 'Lihat produk yang ingin dibeli',
                  onTap: onWishlist,
                ),
                // MenuItemData(
                //   icon: Icons.notifications_none_rounded,
                //   title: 'Notifikasi',
                //   subtitle: 'Kabar pesanan dan promo',
                //   onTap: onNotifications,
                // ),
              ],
            ),
            const SizedBox(height: 20),
            MenuCard(
              items: [
                MenuItemData(
                  icon: Icons.info_outline_rounded,
                  title: 'Tentang MyHobbyTown',
                  subtitle: 'Teman hobi kamu · Sejak 2003',
                  onTap: () {
                    onAbout(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
