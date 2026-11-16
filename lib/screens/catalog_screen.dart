import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_town_demo/constants/colors.dart';
import 'package:hobby_town_demo/models/item.dart';
import 'package:hobby_town_demo/providers/catalog_provider.dart';
import 'package:hobby_town_demo/utils/utils.dart';

enum CatalogSort { popular, newest, cheapest }

class CatalogFilter {
  const CatalogFilter({
    this.category,
    this.anime,
    this.minPrice,
    this.maxPrice,
    this.size,
    this.sort = CatalogSort.popular,
  });

  final String? category;
  final String? anime;
  final int? minPrice;
  final int? maxPrice;
  final String? size;
  final CatalogSort sort;

  bool get hasAdvancedFilters =>
      anime != null ||
      minPrice != null ||
      maxPrice != null ||
      size != null ||
      sort != CatalogSort.popular;

  CatalogFilter withCategory(String? value) => CatalogFilter(
    category: value,
    anime: anime,
    minPrice: minPrice,
    maxPrice: maxPrice,
    size: size,
    sort: sort,
  );

  CatalogFilter withSort(CatalogSort value) => CatalogFilter(
    category: category,
    anime: anime,
    minPrice: minPrice,
    maxPrice: maxPrice,
    size: size,
    sort: value,
  );
}

bool _matchesFilter(Item item, CatalogFilter f) {
  if (f.category != null && item.category != f.category) return false;
  // Items have no anime attribute, so the anime is matched against the name.
  if (f.anime != null &&
      !item.name.toLowerCase().contains(f.anime!.toLowerCase())) {
    return false;
  }
  if (f.minPrice != null && item.price < f.minPrice!) return false;
  if (f.maxPrice != null && item.price > f.maxPrice!) return false;
  return true;
}

String _dots(int value) => value.toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => '.',
);

String _sortLabel(CatalogSort sort) {
  switch (sort) {
    case CatalogSort.popular:
      return 'Terpopuler';
    case CatalogSort.newest:
      return 'Terbaru';
    case CatalogSort.cheapest:
      return 'Termurah';
  }
}

enum _Mode { history, results, empty }

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({
    super.key,
    this.categories,
    this.animeOptions = const [],
    this.trendingSearches = const [],
    this.tryTheseSearches = const [],
    this.recommendedItems,
    this.brandLogo,
    this.onItemTap,
    this.onFavoriteChanged,
    this.onAddToCart,
    this.onFilterChanged,
    this.onHistoryChanged,
  });

  final List<String>? categories;

  final List<String> animeOptions;

  final List<String> trendingSearches;

  final List<String> tryTheseSearches;

  final List<Item>? recommendedItems;

  final ImageProvider? brandLogo;

  final ValueChanged<Item>? onItemTap;
  final void Function(Item item, bool isFavorite)? onFavoriteChanged;
  final ValueChanged<Item>? onAddToCart;
  final ValueChanged<CatalogFilter>? onFilterChanged;
  final ValueChanged<List<String>>? onHistoryChanged;

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  late List<Item> items;
  late List<String> history;
  late Set<String> wishList;
  CatalogFilter _filter = const CatalogFilter();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuild);
    _focus.addListener(_rebuild);
    items = ref.watch(itemsProvider);
    history = ref.watch(historyProvider);
    wishList = ref.watch(wishProvider).map((e) => e.id).toSet();
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _focus.removeListener(_rebuild);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  List<String> get _categories =>
      widget.categories ?? items.map((e) => e.category).toSet().toList();

  int get _priceCeiling {
    var max = 0;
    for (final item in items) {
      if (item.price > max) max = item.price;
    }
    final rounded = ((max + 9999) ~/ 10000) * 10000;
    return rounded < 10000 ? 10000 : rounded;
  }

  /// Items matching the search query only (no filter).
  List<Item> get _searchMatches {
    final q = _controller.text.trim().toLowerCase();
    if (q.isEmpty) return items;
    final words = q.split(RegExp(r'\s+'));
    return items.where((item) {
      final haystack = '${item.name} ${item.category}'.toLowerCase();
      return words.every(haystack.contains);
    }).toList();
  }

  List<Item> get _results {
    final list = _searchMatches
        .where((i) => _matchesFilter(i, _filter))
        .toList();
    switch (_filter.sort) {
      case CatalogSort.popular:
        break; // keep the order supplied by the caller
      case CatalogSort.newest:
        list.sort((a, b) => b.released.compareTo(a.released));
        break;
      case CatalogSort.cheapest:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
    }
    return list;
  }

  void _submit(String raw) {
    final q = raw.trim();
    if (q.isEmpty) return;
    history
      ..removeWhere((e) => e.toLowerCase() == q.toLowerCase())
      ..insert(0, q);
    if (history.length > 10) history = history.sublist(0, 10);
    widget.onHistoryChanged?.call(List.of(history));
    _focus.unfocus();
    setState(() {});
  }

  void _applyQuery(String q) {
    _controller.value = TextEditingValue(
      text: q,
      selection: TextSelection.collapsed(offset: q.length),
    );
    _submit(q);
  }

  void _fillQuery(String q) {
    _controller.value = TextEditingValue(
      text: q,
      selection: TextSelection.collapsed(offset: q.length),
    );
    _focus.requestFocus();
  }

  void _clearHistory() {
    setState(() => history = []);
    widget.onHistoryChanged?.call(const []);
  }

  void _onClearField() {
    if (_controller.text.isNotEmpty) {
      _controller.clear();
      _focus.requestFocus();
    } else {
      _focus.unfocus();
    }
  }

  void _resetAll() {
    _controller.clear();
    _focus.unfocus();
    setState(() => _filter = const CatalogFilter());
    widget.onFilterChanged?.call(_filter);
  }

  void _setFilter(CatalogFilter value) {
    setState(() => _filter = value);
    widget.onFilterChanged?.call(value);
  }

  void _toggleFavorite(Item item) {
    final nowFavorite = !wishList.contains(item.id);
    setState(() {
      if (nowFavorite) {
        wishList.add(item.id);
      } else {
        wishList.remove(item.id);
      }
    });
    widget.onFavoriteChanged?.call(item, nowFavorite);
  }

  Future<void> _openFilter() async {
    final height = MediaQuery.of(context).size.height;
    final result = await showModalBottomSheet<CatalogFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      constraints: BoxConstraints(maxHeight: height * 0.86),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => _FilterSheet(
        initial: _filter,
        categories: _categories,
        animeOptions: widget.animeOptions,
        priceCeiling: _priceCeiling,
        searchMatches: _searchMatches,
      ),
    );
    if (result != null) _setFilter(result);
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();
    final results = _results;

    final _Mode mode;
    if (query.isEmpty && _focus.hasFocus) {
      mode = _Mode.history;
    } else if (results.isEmpty) {
      mode = _Mode.empty;
    } else {
      mode = _Mode.results;
    }

    Widget body;
    switch (mode) {
      case _Mode.history:
        body = _buildHistory();
        break;
      case _Mode.results:
        body = _buildResults(results);
        break;
      case _Mode.empty:
        body = _buildEmpty(query);
        break;
    }

    return ColoredBox(
      color: BG,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _SearchField(
              controller: _controller,
              focusNode: _focus,
              active: _focus.hasFocus || query.isNotEmpty,
              showClear: _focus.hasFocus || query.isNotEmpty,
              onSubmitted: _submit,
              onClear: _onClearField,
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _grid(List<Item> items, {double bottomPadding = 0}) {
    return _ProductGridSliver(
      items: items,
      favorites: wishList,
      bottomPadding: bottomPadding,
      onTap: (item) => widget.onItemTap?.call(item),
      onToggleFavorite: _toggleFavorite,
      onAddToCart: (item) => widget.onAddToCart?.call(item),
    );
  }

  Widget _buildResults(List<Item> results) {
    final categories = _categories;
    return CustomScrollView(
      key: const ValueKey('results'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      _PillChip(
                        label: 'Semua',
                        selected: _filter.category == null,
                        onTap: () => _setFilter(_filter.withCategory(null)),
                      ),
                      for (final c in categories) ...[
                        const SizedBox(width: 8),
                        _PillChip(
                          label: c,
                          selected: _filter.category == c,
                          onTap: () => _setFilter(_filter.withCategory(c)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${results.length} produk ditemukan',
                        style: const TextStyle(fontSize: 12, color: MUTED),
                      ),
                    ),
                    GestureDetector(
                      onTap: _openFilter,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(
                                  Icons.tune_rounded,
                                  size: 18,
                                  color: INK,
                                ),
                                if (_filter.hasAdvancedFilters)
                                  Positioned(
                                    top: -2,
                                    right: -3,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: PINK,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Filter',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: INK,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    PopupMenuButton<CatalogSort>(
                      tooltip: 'Urutkan',
                      padding: EdgeInsets.zero,
                      initialValue: _filter.sort,
                      onSelected: (s) => _setFilter(_filter.withSort(s)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      itemBuilder: (_) => [
                        for (final s in CatalogSort.values)
                          PopupMenuItem(
                            value: s,
                            child: Text(
                              _sortLabel(s),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: s == _filter.sort
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.swap_vert_rounded,
                          size: 20,
                          color: INK,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Bottom padding leaves room for the floating navigation bar.
        _grid(results, bottomPadding: 120),
      ],
    );
  }

  Widget _buildHistory() {
    final recommended = widget.recommendedItems ?? items.take(4).toList();
    return CustomScrollView(
      key: const ValueKey('history'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (history.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _SectionTitle('Pencarian Terakhir'),
                  GestureDetector(
                    onTap: _clearHistory,
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Hapus Semua',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: PINK,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              final entry = history[i];
              return InkWell(
                onTap: () => _applyQuery(entry),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history_rounded, size: 20, color: INK),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, color: INK),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _fillQuery(entry),
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.north_west_rounded,
                            size: 16,
                            color: MUTED,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: history.length),
          ),
        ],
        if (widget.trendingSearches.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('Lagi Dicari'),
                  const SizedBox(height: 14),
                  _SuggestionWrap(
                    labels: widget.trendingSearches,
                    onTap: _applyQuery,
                  ),
                ],
              ),
            ),
          ),
        if (recommended.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 28, 20, 16),
              child: _SectionTitle('Mungkin Kamu Suka'),
            ),
          ),
          _grid(recommended, bottomPadding: 120),
        ] else
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildEmpty(String query) {
    final message = query.isEmpty
        ? 'Tidak ada produk yang cocok dengan filter kamu. Coba ubah atau '
              'atur ulang filternya.'
        : 'Tidak ada hasil untuk “$query”. Coba kata kunci lain atau '
              'jelajahi koleksi kami.';
    return SingleChildScrollView(
      key: const ValueKey('empty'),
      physics: const BouncingScrollPhysics(),
      // Bottom padding leaves room for the floating navigation bar.
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: 156,
              height: 156,
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
                          Icons.search_off_rounded,
                          size: 60,
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
          ),
          const SizedBox(height: 26),
          const Center(
            child: Text(
              'Belum ketemu, nih',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: INK,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: MUTED,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: _resetAll,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Jelajahi Katalog'),
              style: FilledButton.styleFrom(
                backgroundColor: INK,
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
          if (widget.tryTheseSearches.isNotEmpty) ...[
            const SizedBox(height: 32),
            const _SectionTitle('Coba Cari Ini'),
            const SizedBox(height: 14),
            _SuggestionWrap(
              labels: widget.tryTheseSearches,
              onTap: _applyQuery,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: INK,
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.active,
    required this.showClear,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool active;
  final bool showClear;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: active ? PINK : const Color(0xFFEAE8F1),
          width: active ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 22, color: INK),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              cursorColor: PINK,
              style: const TextStyle(fontSize: 13.5, color: INK),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: focusNode.hasFocus
                    ? 'Cari anime, karakter, atau produk'
                    : 'Anime & cosplay',
                hintStyle: const TextStyle(fontSize: 13, color: MUTED),
              ),
            ),
          ),
          if (showClear)
            GestureDetector(
              onTap: onClear,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, size: 18, color: INK),
              ),
            ),
        ],
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? INK : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? INK : BORDER),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : INK,
          ),
        ),
      ),
    );
  }
}

class _SuggestionWrap extends StatelessWidget {
  const _SuggestionWrap({required this.labels, required this.onTap});

  final List<String> labels;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: [
        for (final label in labels)
          GestureDetector(
            onTap: () => onTap(label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: BORDER),
              ),
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, color: MUTED),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Product grid
// ---------------------------------------------------------------------------

class _ProductGridSliver extends StatelessWidget {
  const _ProductGridSliver({
    required this.items,
    required this.favorites,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onAddToCart,
    this.bottomPadding = 0,
  });

  final List<Item> items;
  final Set<String> favorites;
  final ValueChanged<Item> onTap;
  final ValueChanged<Item> onToggleFavorite;
  final ValueChanged<Item> onAddToCart;
  final double bottomPadding;

  static const double _imageRatio = 0.92; // width / height

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.crossAxisExtent - 40 - 12) / 2;
        return SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              mainAxisExtent: cardWidth / _imageRatio + 76,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = items[index];
              return _ProductCard(
                item: item,
                imageRatio: _imageRatio,
                isFavorite: favorites.contains(item.id),
                onTap: () => onTap(item),
                onToggleFavorite: () => onToggleFavorite(item),
                onAddToCart: () => onAddToCart(item),
              );
            }, childCount: items.length),
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.item,
    required this.imageRatio,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  final Item item;
  final double imageRatio;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: imageRatio,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : const ColoredBox(color: PLACEHOLDER),
                      errorBuilder: (context, error, stack) => const ColoredBox(
                        color: PLACEHOLDER,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: HINT,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _CircleButton(
                    size: 30,
                    color: Colors.white,
                    onTap: onToggleFavorite,
                    child: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 16,
                      color: isFavorite ? PINK : INK,
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: _CircleButton(
                    size: 34,
                    color: INK,
                    onTap: onAddToCart,
                    child: const Icon(
                      Icons.add_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: INK,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            intToRupiah(item.price),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: INK,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10.5, color: MUTED),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.size,
    required this.color,
    required this.onTap,
    required this.child,
  });

  final double size;
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bottom sheet
// ---------------------------------------------------------------------------

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.initial,
    required this.categories,
    required this.animeOptions,
    required this.priceCeiling,
    required this.searchMatches,
  });

  final CatalogFilter initial;
  final List<String> categories;
  final List<String> animeOptions;
  final int priceCeiling;
  final List<Item> searchMatches;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  static const List<String> _sizes = ['S', 'M', 'L', 'XL'];

  late String? _category;
  late String? _anime;
  late RangeValues _range;
  late String? _size;
  late CatalogSort _sort;
  late final TextEditingController _minCtl;
  late final TextEditingController _maxCtl;

  double get _ceiling => widget.priceCeiling.toDouble();

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _category = f.category;
    _anime = f.anime;
    _size = f.size;
    _sort = f.sort;
    _range = RangeValues(
      (f.minPrice ?? 0).toDouble().clamp(0, _ceiling).toDouble(),
      (f.maxPrice ?? widget.priceCeiling)
          .toDouble()
          .clamp(0, _ceiling)
          .toDouble(),
    );
    _minCtl = TextEditingController(text: _dots(_range.start.round()));
    _maxCtl = TextEditingController(text: _dots(_range.end.round()));
  }

  @override
  void dispose() {
    _minCtl.dispose();
    _maxCtl.dispose();
    super.dispose();
  }

  CatalogFilter get _draft => CatalogFilter(
    category: _category,
    anime: _anime,
    minPrice: _range.start.round() <= 0 ? null : _range.start.round(),
    maxPrice: _range.end.round() >= widget.priceCeiling
        ? null
        : _range.end.round(),
    size: _size,
    sort: _sort,
  );

  void _reset() {
    setState(() {
      _category = null;
      _anime = null;
      _size = null;
      _sort = CatalogSort.popular;
      _range = RangeValues(0, _ceiling);
      _minCtl.text = _dots(0);
      _maxCtl.text = _dots(widget.priceCeiling);
    });
  }

  void _onMinTyped(String text) {
    final v = int.tryParse(text.replaceAll('.', ''));
    if (v == null) return;
    final c = v.clamp(0, _range.end.round()).toDouble();
    setState(() => _range = RangeValues(c, _range.end));
  }

  void _onMaxTyped(String text) {
    final v = int.tryParse(text.replaceAll('.', ''));
    if (v == null) return;
    final c = v.clamp(_range.start.round(), widget.priceCeiling).toDouble();
    setState(() => _range = RangeValues(_range.start, c));
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft;
    final count = widget.searchMatches
        .where((i) => _matchesFilter(i, draft))
        .length;
    final divisions = widget.priceCeiling ~/ 10000;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0DEE8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Filter Produk',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: INK,
                        ),
                      ),
                      GestureDetector(
                        onTap: _reset,
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            'Atur Ulang',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: PINK,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const _SheetLabel('Kategori'),
                  _DropdownField(
                    allLabel: 'Semua kategori',
                    options: widget.categories,
                    value: _category,
                    onChanged: (v) => setState(() => _category = v),
                  ),
                  if (widget.animeOptions.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    const _SheetLabel('Anime'),
                    _DropdownField(
                      allLabel: 'Semua anime',
                      options: widget.animeOptions,
                      value: _anime,
                      onChanged: (v) => setState(() => _anime = v),
                    ),
                  ],
                  const SizedBox(height: 22),
                  const _SheetLabel('Rentang harga'),
                  Row(
                    children: [
                      Expanded(
                        child: _PriceBox(
                          controller: _minCtl,
                          onChanged: _onMinTyped,
                        ),
                      ),
                      const SizedBox(
                        width: 28,
                        child: Center(
                          child: Text(
                            '–',
                            style: TextStyle(color: MUTED, fontSize: 14),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _PriceBox(
                          controller: _maxCtl,
                          onChanged: _onMaxTyped,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      activeTrackColor: PINK,
                      inactiveTrackColor: PINK_SOFT,
                      thumbColor: PINK,
                      overlayColor: PINK.withValues(alpha: 0.12),
                      rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                    ),
                    child: RangeSlider(
                      values: _range,
                      min: 0,
                      max: _ceiling,
                      divisions: divisions > 0 ? divisions : null,
                      onChanged: (v) {
                        setState(() {
                          _range = v;
                          _minCtl.text = _dots(v.start.round());
                          _maxCtl.text = _dots(v.end.round());
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _SheetLabel('Ukuran'),
                  Row(
                    children: [
                      for (final s in _sizes) ...[
                        _SizeBox(
                          label: s,
                          selected: _size == s,
                          onTap: () =>
                              setState(() => _size = _size == s ? null : s),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 22),
                  const _SheetLabel('Urutkan'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in CatalogSort.values)
                        _PillChip(
                          label: _sortLabel(s),
                          selected: _sort == s,
                          onTap: () => setState(() => _sort = s),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_draft),
                style: FilledButton.styleFrom(
                  backgroundColor: INK,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text('Tampilkan $count Produk'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: INK,
        ),
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  const _PriceBox({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w),
    );
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        LengthLimitingTextInputFormatter(12),
      ],
      cursorColor: PINK,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: INK,
      ),
      decoration: InputDecoration(
        isDense: true,
        prefixText: 'Rp ',
        prefixStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: INK,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: border(BORDER),
        enabledBorder: border(BORDER),
        focusedBorder: border(PINK, 1.4),
      ),
    );
  }
}

class _SizeBox extends StatelessWidget {
  const _SizeBox({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? INK : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? INK : BORDER),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : INK,
          ),
        ),
      ),
    );
  }
}

/// Inline dropdown: a field that expands into a scrollable list of options.
/// A null value means "all" (no filter).
class _DropdownField extends StatefulWidget {
  const _DropdownField({
    required this.allLabel,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String allLabel;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  State<_DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<_DropdownField> {
  final ScrollController _scroll = ScrollController();
  bool _open = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _select(String? value) {
    widget.onChanged(value);
    setState(() => _open = false);
  }

  Widget _tile(String? value, String label) {
    final selected = widget.value == value;
    return InkWell(
      onTap: () => _select(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: INK,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_rounded, size: 18, color: PINK),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: FIELD,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _open ? PINK : Colors.transparent,
                width: 1.4,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.value ?? widget.allLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: widget.value == null
                          ? FontWeight.w500
                          : FontWeight.w700,
                      color: widget.value == null ? MUTED : INK,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: INK,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _open
              ? Container(
                  margin: const EdgeInsets.only(top: 8),
                  constraints: const BoxConstraints(maxHeight: 184),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: BORDER),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Scrollbar(
                      controller: _scroll,
                      thumbVisibility: true,
                      child: ListView(
                        controller: _scroll,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: [
                          _tile(null, widget.allLabel),
                          for (final option in widget.options)
                            _tile(option, option),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
