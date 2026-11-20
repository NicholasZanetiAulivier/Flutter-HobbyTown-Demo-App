import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_town_demo/components/filter_chip.dart';
import 'package:hobby_town_demo/components/product_card.dart';
import 'package:hobby_town_demo/constants/colors.dart';
import 'package:hobby_town_demo/providers/catalog_provider.dart';

import '../models/item.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({
    super.key,
    this.filter = WishlistFilter.all,
    this.brandLogo,
    this.onFilterChanged,
    this.onEdit,
    this.onItemTap,
    this.onRemoveFavorite,
    this.onAddToCart,
    this.onStartShopping,
  });

  final WishlistFilter filter;
  final ImageProvider? brandLogo;
  final ValueChanged<WishlistFilter>? onFilterChanged;
  final VoidCallback? onEdit;
  final ValueChanged<Item>? onItemTap;
  final ValueChanged<Item>? onRemoveFavorite;
  final ValueChanged<Item>? onAddToCart;
  final VoidCallback? onStartShopping;

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistPageState();
}

class _WishlistPageState extends ConsumerState<WishlistScreen> {
  late List<Item> items;

  @override
  void initState() {
    super.initState();
    items = ref.watch(wishSelector).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BG,
      child: items.length == 0 ? _buildEmptyState() : _buildFilledState(),
    );
  }

  Widget _buildFilledState() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Simpan dulu, bawa pulang nanti.',
                  style: TextStyle(fontSize: 14, color: MUTED),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      FilterChipWrapper(
                        label: 'Semua (${items.length})',
                        selected: widget.filter == WishlistFilter.all,
                        onTap: () =>
                            widget.onFilterChanged?.call(WishlistFilter.all),
                      ),
                      const SizedBox(width: 8),
                      FilterChipWrapper(
                        label: 'Tersedia',
                        selected: widget.filter == WishlistFilter.available,
                        onTap: () => widget.onFilterChanged?.call(
                          WishlistFilter.available,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilterChipWrapper(
                        label: 'Promo',
                        selected: widget.filter == WishlistFilter.promo,
                        onTap: () =>
                            widget.onFilterChanged?.call(WishlistFilter.promo),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${items.length} produk tersimpan',
                      style: const TextStyle(fontSize: 12, color: MUTED),
                    ),
                    GestureDetector(
                      onTap: widget.onEdit,
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: MUTED,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
        if (items.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48, horizontal: 20),
              child: Center(
                child: Text(
                  'Belum ada produk di kategori ini.',
                  style: TextStyle(fontSize: 13, color: MUTED),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            // Bottom padding leaves room for the floating navigation bar.
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.64,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = items[index];
                return ProductCard(
                  item: item,
                  onTap: () => widget.onItemTap?.call(item),
                  onRemoveFavorite: () => widget.onRemoveFavorite?.call(item),
                  onAddToCart: () => widget.onAddToCart?.call(item),
                );
              }, childCount: items.length),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      // Bottom padding leaves room for the floating navigation bar.
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 120),
      child: Column(
        children: [
          SizedBox(
            width: 170,
            height: 170,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE9E2FB), Color(0xFFFFE3EE)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 64,
                        color: Color(0xFF2A1B3D),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -2,
                  right: -8,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A1B1530),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                      image: widget.brandLogo == null
                          ? null
                          : DecorationImage(
                              image: widget.brandLogo!,
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: widget.brandLogo == null
                        ? const Icon(
                            Icons.storefront_rounded,
                            size: 18,
                            color: PINK,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Simpan yang kamu suka',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: INK,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ketuk ikon hati pada produk favorit. Semua incaranmu akan '
            'tersimpan di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: MUTED, height: 1.45),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: widget.onStartShopping,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Mulai Belanja'),
              style: FilledButton.styleFrom(
                backgroundColor: INK,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
