import 'package:flutter/material.dart';

class BookCover extends StatelessWidget {
  const BookCover({super.key, required this.imageUrl, required this.title, required this.color});
  final String imageUrl;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _fallbackCover();
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _fallbackCover(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }

  Widget _fallbackCover() {
    return Container(
      color: color.withAlpha(50),
      alignment: Alignment.center,
      child: Text(
        title.isNotEmpty ? title.substring(0, 1) : '?',
        style: TextStyle(
          fontSize: 32,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Color parseHexColor(String hex) {
  final clean = hex.replaceAll('#', '');
  final value = int.tryParse(clean, radix: 16);
  if (value == null) return const Color(0xFF9B5A24);
  return Color(0xFF000000 | value);
}
