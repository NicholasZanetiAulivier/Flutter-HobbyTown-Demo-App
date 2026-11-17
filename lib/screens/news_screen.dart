import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hobby_town_demo/components/top_app_bar.dart';
import 'package:hobby_town_demo/models/news.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsScreenImpl extends StatelessWidget {
  final News article;

  const NewsScreenImpl({super.key, required this.article});

  static const Color _ink = Color(0xFF111111);
  static const Color _body = Color(0xFF4A4A4A);
  static const Color _muted = Color(0xFF6B6B6B);
  static const Color _background = Color(0xFFF7F6F9);
  static const Color _chipFill = Color(0xFFECE6FA);
  static const Color _chipText = Color(0xFF6B4FC4);
  static const Color _link = Color(0xFFE0245E);

  static const List<String> _months = [
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

  String _formatDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  void _handleLinkTap(
    String? url,
    Map<String, String> attributes,
    dynamic element,
  ) {
    if (url == null) return;
    onLinkTap.call(url);
  }

  Future<void> onLinkTap(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _background,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: 32 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryChip(),
                  const SizedBox(height: 16),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 18),
                  _buildAuthorRow(),
                  const SizedBox(height: 20),
                  _buildContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Image.network(
        article.heroImageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const ColoredBox(
            color: Color(0xFFE9E7EF),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) => const ColoredBox(
          color: Color(0xFFE9E7EF),
          child: Center(
            child: Icon(Icons.broken_image_outlined, size: 40, color: _muted),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _chipFill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        article.category,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _chipText,
        ),
      ),
    );
  }

  Widget _buildAuthorRow() {
    return Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: 40,
            height: 40,
            child: Image.network(
              article.authorAvatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: Color(0xFFE9E7EF),
                child: Icon(Icons.person, size: 40, color: _muted),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.authorName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                  fontFamily: "PlusJakartaSans",
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_formatDate(article.publishedAt)} \u00b7 ${article.readMinutes} menit baca',
                style: const TextStyle(
                  fontSize: 11,
                  color: _muted,
                  fontFamily: "PlusJakartaSans",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Html(
      data: article.contentHtml,
      onLinkTap: _handleLinkTap,
      style: {
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(14),
          lineHeight: const LineHeight(1.65),
          color: _body,
        ),
        'p': Style(margin: Margins.only(bottom: 16)),
        'h2': Style(
          fontSize: FontSize(18),
          fontWeight: FontWeight.w800,
          color: _ink,
          margin: Margins.only(top: 8, bottom: 10),
        ),
        'h3': Style(
          fontSize: FontSize(16),
          fontWeight: FontWeight.w700,
          color: _ink,
          margin: Margins.only(top: 8, bottom: 8),
        ),
        'a': Style(
          color: _link,
          textDecoration: TextDecoration.none,
          fontWeight: FontWeight.w600,
        ),
        'blockquote': Style(
          margin: Margins.symmetric(vertical: 12),
          padding: HtmlPaddings.only(left: 14),
          border: const Border(left: BorderSide(color: _link, width: 3)),
          color: _muted,
        ),
        'img': Style(margin: Margins.symmetric(vertical: 8)),
      },
    );
  }
}

class NewsScreen extends StatelessWidget {
  final News article;

  const new({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: TopAppBarContent(
          titleText: "Berita",
          shouldShowBackButton: true,
        ),
      ),
      body: NewsScreenImpl(article: article),
    );
  }
}
