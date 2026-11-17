import 'package:flutter/material.dart';
import 'package:hobby_town_demo/utils/utils.dart';

import '../models/item.dart';

class ProductDetailScreen extends StatefulWidget {
  final Item item;

  const ProductDetailScreen({super.key, required this.item});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // ---- Design tokens ------------------------------------------------------
  static const Color _pink = Color(0xFFFF4D8D);
  static const Color _pinkSoft = Color(0xFFFFE1EC);
  static const Color _pinkText = Color(0xFFE0245E);
  static const Color _greenSoft = Color(0xFFDDF5E6);
  static const Color _greenText = Color(0xFF1E8E4E);
  static const Color _ink = Color(0xFF111111);
  static const Color _muted = Color(0xFF6B6B6B);
  static const Color _heroBackground = Color(0xFFC9C2E3);
  static const Color _disabledFill = Color(0xFFE9E7EF);

  // ---- Data not present in the Item model (replace with real data) --------
  static const List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];
  static const List<String> _outOfStockSizes = ['XXL'];
  static const int _stock = 24;
  static const double _rating = 4.9;
  static const int _reviewCount = 48;
  static const int _soldCount = 120;

  // ---- State --------------------------------------------------------------
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _selectedSizeIndex = 2; // "L"
  bool _isFavorite = false;

  /// The model has a single image; extend this list when more are available.
  List<String> get _images => [widget.item.imageUrl];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ---- Actions ------------------------------------------------------------
  void _onBackPressed() {
    Navigator.of(context).maybePop();
  }

  void _onSharePressed() {
    _showMessage('Membagikan ${widget.item.name}');
  }

  void _onFavoritePressed() {
    setState(() => _isFavorite = !_isFavorite);
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _onSizeSelected(int index) {
    if (_outOfStockSizes.contains(_sizes[index])) {
      _showMessage('Ukuran ${_sizes[index]} sedang habis');
      return;
    }
    setState(() => _selectedSizeIndex = index);
  }

  void _onSizeGuidePressed() {
    _showMessage('Panduan ukuran');
  }

  void _onAskWhatsAppPressed() {
    // TODO: open WhatsApp (e.g. with url_launcher) using the store's number.
    _showMessage('Membuka WhatsApp untuk ${widget.item.name}');
  }

  void _onAddToCartPressed() {
    _showMessage(
      '${widget.item.name} (${_sizes[_selectedSizeIndex]}) ditambahkan ke keranjang',
    );
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  // ---- Build --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildHero(), _buildPageIndicator(), _buildInfo()],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHero() {
    final topInset = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 238 + topInset,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: _heroBackground,
              padding: EdgeInsets.only(top: topInset),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _images.length,
                onPageChanged: _onPageChanged,
                itemBuilder: _buildImagePage,
              ),
            ),
          ),
          Positioned(
            top: topInset + 12,
            left: 16,
            child: _circleButton(
              icon: Icons.arrow_back,
              onPressed: _onBackPressed,
              tooltip: 'Kembali',
            ),
          ),
          Positioned(
            top: topInset + 12,
            right: 16,
            child: Row(
              children: [
                _circleButton(
                  icon: Icons.share_outlined,
                  onPressed: _onSharePressed,
                  tooltip: 'Bagikan',
                ),
                const SizedBox(width: 8),
                _circleButton(
                  icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                  iconColor: _isFavorite ? _pink : _ink,
                  onPressed: _onFavoritePressed,
                  tooltip: 'Favorit',
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentPage + 1}/${_images.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePage(BuildContext context, int index) {
    return Image.network(
      _images[index],
      fit: BoxFit.cover,
      loadingBuilder: _buildImageLoading,
      errorBuilder: _buildImageError,
    );
  }

  Widget _buildImageLoading(
    BuildContext context,
    Widget child,
    ImageChunkEvent? progress,
  ) {
    if (progress == null) return child;
    return const Center(
      child: CircularProgressIndicator(strokeWidth: 2, color: _pink),
    );
  }

  Widget _buildImageError(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return const Center(
      child: Icon(Icons.broken_image_outlined, size: 48, color: _muted),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color iconColor = _ink,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, size: 20, color: iconColor),
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildPageIndicator() {
    final dots = <Widget>[];
    for (var i = 0; i < _images.length; i++) {
      final active = i == _currentPage;
      dots.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 6),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? _pink : const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(children: dots),
    );
  }

  Widget _buildInfo() {
    final item = widget.item;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _tag(item.category, _pinkSoft, _pinkText),
              const SizedBox(width: 8),
              _tag('Stok $_stock', _greenSoft, _greenText),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 24,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            intToRupiah(item.price),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: _muted),
              const SizedBox(width: 4),
              Text(
                '$_rating ($_reviewCount ulasan) \u00b7 $_soldCount terjual',
                style: const TextStyle(fontSize: 12, color: _muted),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ukuran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              InkWell(
                onTap: _onSizeGuidePressed,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Panduan Ukuran',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _pink,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildSizeSelector(),
        ],
      ),
    );
  }

  Widget _tag(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }

  /// A single ToggleButtons receives the tapped index, so no per-chip
  /// closures are needed: taps are handled by [_onSizeSelected].
  Widget _buildSizeSelector() {
    final selection = <bool>[];
    final chips = <Widget>[];
    for (var i = 0; i < _sizes.length; i++) {
      final size = _sizes[i];
      final selected = i == _selectedSizeIndex;
      final disabled = _outOfStockSizes.contains(size);
      selection.add(selected);
      chips.add(
        Container(
          width: 44,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? _ink
                : disabled
                ? _disabledFill
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? _ink
                  : disabled
                  ? _disabledFill
                  : const Color(0xFFDADADA),
            ),
          ),
          child: Text(
            size,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected
                  ? Colors.white
                  : disabled
                  ? const Color(0xFFB5B2BF)
                  : _ink,
              decoration: disabled
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        ),
      );
    }

    return ToggleButtons(
      isSelected: selection,
      onPressed: _onSizeSelected,
      renderBorder: false,
      fillColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      constraints: const BoxConstraints(minWidth: 52, minHeight: 40),
      children: [
        for (final chip in chips)
          Padding(padding: const EdgeInsets.only(right: 8), child: chip),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEFEFEF))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _onAskWhatsAppPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: _ink,
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: _ink, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Tanya WhatsApp'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _onAddToCartPressed,
              style: FilledButton.styleFrom(
                backgroundColor: _ink,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Tambah ke Keranjang'),
            ),
          ),
        ],
      ),
    );
  }
}
