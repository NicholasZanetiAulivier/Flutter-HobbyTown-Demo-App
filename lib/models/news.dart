class News {
  final String id;
  final String heroImageUrl;
  final String category;
  final String title;
  final String authorName;
  final String authorAvatarUrl;
  final DateTime publishedAt;
  final int readMinutes;
  final String contentHtml;

  const News({
    required this.id,
    required this.heroImageUrl,
    required this.category,
    required this.title,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.publishedAt,
    required this.readMinutes,
    required this.contentHtml,
  });
}
