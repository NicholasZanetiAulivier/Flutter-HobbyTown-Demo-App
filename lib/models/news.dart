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

  factory fromJson(Map<String, Object?> jsonPart) {
    return News(
      id: jsonPart["title"] as String,
      heroImageUrl: jsonPart["image_banner"] as String,
      publishedAt: DateTime.parse(jsonPart["created_at"] as String),
      category: jsonPart["slug_category"] as String,
      title: jsonPart["title"] as String,
      authorName: jsonPart["author"] as String,
      authorAvatarUrl: "",
      readMinutes: 6,
      contentHtml: '''<h2>Lorem ipsum dolor sit amet</h2>

      <p>
        Lorem ipsum dolor sit amet, <strong>consectetur adipiscing elit</strong>, sed do
    eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim
    veniam, quis nostrud <em>exercitation ullamco</em> laboris nisi ut aliquip ex ea
    commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit
    esse cillum dolore eu fugiat nulla pariatur.
    </p>

    <p>
    Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia
    deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus
    error sit voluptatem accusantium doloremque laudantium, totam rem aperiam,
    eaque ipsa quae ab illo inventore veritatis et <u>quasi architecto beatae vitae
    dicta sunt</u> explicabo.
    </p>

    <img
    src="https://picsum.photos/seed/matsuri-street/1200/750"
    alt="Suasana jalan dengan lampion"
    style="width:100%; border-radius:16px;"
    />

    <p>
    Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed
    quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.
    Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, <a
    href="https://example.com/lorem-ipsum">consectetur adipisci velit</a>, sed quia
    non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam
    quaerat voluptatem.
    </p>

    <p>
    Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit
    laboriosam, nisi ut aliquid ex ea commodi consequatur. Quis autem vel eum iure
    reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur,
    vel illum qui dolorem eum fugiat quo voluptas nulla pariatur. Harga lama
    <del>Rp 350.000</del> kini menjadi <ins>Rp 289.000</ins>, dan stok
    tersisa <mark>24 buah</mark> saja.
    </p>

    <blockquote>
    At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis
    praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias
    excepturi sint occaecati cupiditate non provident.
    </blockquote>

    <p>
    Similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et
    dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio<sup>1</sup>.
    Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit
    quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est,
    omnis dolor repellendus. Gunakan kode <code>MHTSTICKER</code> saat membayar
    untuk bonus stiker edisi terbatas.
    </p>

    <img
    src="https://picsum.photos/seed/lantern-festival/1200/750"
    alt="Lampion festival di malam hari"
    style="width:100%; border-radius:16px;"
    />

    <p>
    Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe
    eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque
    earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus
    maiores alias consequatur aut perferendis doloribus asperiores repellat. Air
    mineral ditulis H<sub>2</sub>O, sedangkan luas area acara sekitar 120 m<sup>2</sup>.
        </p>

        <p>
        <small>Foto: ilustrasi placeholder. Jadwal dapat berubah sewaktu-waktu tanpa
    pemberitahuan sebelumnya.</small>
    </p>
        ''',
    );
  }
}
