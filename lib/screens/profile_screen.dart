import 'package:flutter/material.dart';
import 'package:hobby_town_demo/constants/colors.dart';
import 'package:hobby_town_demo/screens/address_screen.dart';

import '../components/membership_banner.dart';
import '../components/menu_card.dart';
import '../components/profile_header.dart';
import '../models/menu_item_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.name = 'Naya Putri',
    this.email = 'naya.putri@email.com',
    this.avatar,
    this.onEditProfile,
    this.onOrders,
    this.onWishlist,
    this.onNotifications,
    this.onAbout,
  });

  final String name;
  final String email;
  final ImageProvider? avatar;
  final VoidCallback? onEditProfile;
  final VoidCallback? onOrders;
  final VoidCallback? onWishlist;
  final VoidCallback? onNotifications;
  final VoidCallback? onAbout;

  void onAddress(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AddressScreen()));
  }

  @override
  Widget build(BuildContext context) {
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
                  onTap: onOrders,
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
                  subtitle: '4 produk favorit',
                  onTap: onWishlist,
                ),
                MenuItemData(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifikasi',
                  subtitle: 'Kabar pesanan dan promo',
                  onTap: onNotifications,
                ),
              ],
            ),
            const SizedBox(height: 20),
            MenuCard(
              items: [
                MenuItemData(
                  icon: Icons.info_outline_rounded,
                  title: 'Tentang MyHobbyTown',
                  subtitle: 'Teman hobi kamu · Sejak 2003',
                  onTap: onAbout,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
