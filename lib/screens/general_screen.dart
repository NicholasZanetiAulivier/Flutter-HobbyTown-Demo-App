import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_town_demo/models/news.dart';
import 'package:hobby_town_demo/providers/catalog_provider.dart';
import 'package:hobby_town_demo/screens/news_screen.dart';

String _formatDate(DateTime d) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

String _meta(News a) =>
    '${_formatDate(a.publishedAt)} · ${a.readMinutes} menit baca';

class _C {
  static const Color pink = Color(0xFFFF3D7F);
  static const Color ink = Color(0xFF14121A);
  static const Color muted = Color(0xFF6E6B78);
  static const Color bg = Color(0xFFF7F6FB);
  static const Color border = Color(0xFFE4E2EC);
  static const Color lavender = Color(0xFFEDE6FA);
  static const Color placeholder = Color(0xFFE6E3EE);
}

class GeneralScreen extends ConsumerStatefulWidget {
  const GeneralScreen({super.key, this.categories});

  final List<String>? categories;

  @override
  ConsumerState<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends ConsumerState<GeneralScreen> {
  String? _category;

  late News featured;

  late List<News> articles;

  void onArticleTap(News news) {
    if (!mounted) return;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => NewsScreen(article: news)));
  }

  @override
  void initState() {
    super.initState();
    articles = ref.watch(newsSelector);
    featured = articles[0];
  }

  List<String> get _categories =>
      widget.categories ?? articles.map((a) => a.category).toSet().toList();

  @override
  Widget build(BuildContext context) {
    final showFeatured = _category == null || featured.category == _category;
    final list = articles
        .where((a) => _category == null || a.category == _category)
        .toList();

    return ColoredBox(
      color: _C.bg,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        // Bottom padding leaves room for the floating navigation bar.
        padding: const EdgeInsets.fromLTRB(20, 64, 20, 120),
        children: [
          const Text(
            'Sedikit Jepang, banyak inspirasi.',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _C.ink,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Semua',
                  selected: _category == null,
                  onTap: () => setState(() => _category = null),
                ),
                for (final c in _categories) ...[
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: c,
                    selected: _category == c,
                    onTap: () => setState(() => _category = c),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (showFeatured)
            _FeaturedCard(
              article: featured,
              onTap: () => onArticleTap(featured),
            ),
          if (list.isNotEmpty) ...[
            SizedBox(height: showFeatured ? 28 : 4),
            const Text(
              'Bacaan Terbaru',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _C.ink,
              ),
            ),
            const SizedBox(height: 16),
            for (final article in list) ...[
              _ArticleTile(
                article: article,
                onTap: () => onArticleTap(article),
              ),
              const SizedBox(height: 20),
            ],
          ] else if (!showFeatured)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  'Belum ada bacaan di kategori ini.',
                  style: TextStyle(fontSize: 13, color: _C.muted),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
          color: selected ? _C.ink : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? _C.ink : _C.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : _C.ink,
          ),
        ),
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage(this.url);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const ColoredBox(color: _C.placeholder),
      errorBuilder: (context, error, stack) => const ColoredBox(
        color: _C.placeholder,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFFA29FAD),
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.article, required this.onTap});

  final News article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: _NetworkImage(article.heroImageUrl),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _C.lavender,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              article.category,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2A1B3D),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            article.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _C.ink,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _meta(article),
            style: const TextStyle(fontSize: 11.5, color: _C.muted),
          ),
        ],
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.article, required this.onTap});

  final News article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: _NetworkImage(article.heroImageUrl),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.category,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _C.pink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  article.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _C.ink,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _meta(article),
                  style: const TextStyle(fontSize: 10.5, color: _C.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
