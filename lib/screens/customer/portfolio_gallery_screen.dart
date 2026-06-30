import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-screen portfolio gallery screen
/// Receives: { 'images': List<String>, 'provider_name': String }
class PortfolioGalleryScreen extends StatefulWidget {
  const PortfolioGalleryScreen({super.key});

  @override
  State<PortfolioGalleryScreen> createState() => _PortfolioGalleryScreenState();
}

class _PortfolioGalleryScreenState extends State<PortfolioGalleryScreen> {
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final images = (args?['images'] as List?)?.cast<String>() ?? [];
    final providerName = args?['provider_name'] as String? ?? 'الحرفي';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('معرض الأعمال', style: GoogleFonts.cairo(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            Text(providerName, style: GoogleFonts.cairo(color: Colors.white60, fontSize: 12)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('${images.length} صورة', style: GoogleFonts.cairo(color: Colors.white60, fontSize: 13))),
          ),
        ],
      ),
      body: _selectedIndex >= 0 ? _buildLightbox(images) : _buildGrid(images),
    );
  }

  Widget _buildGrid(List<String> images) {
    if (images.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.photo_library_outlined, size: 64, color: Colors.white30),
          const SizedBox(height: 12),
          Text('لا توجد صور في المعرض بعد', style: GoogleFonts.cairo(color: Colors.white54, fontSize: 15)),
        ]),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = index),
          child: Hero(
            tag: 'portfolio_$index',
            child: Image.network(images[index], fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.grey[850],
                child: const Icon(Icons.image_not_supported_outlined, color: Colors.white30, size: 32)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLightbox(List<String> images) {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = -1),
      child: Stack(children: [
        PageView.builder(
          controller: PageController(initialPage: _selectedIndex),
          itemCount: images.length,
          onPageChanged: (i) => setState(() => _selectedIndex = i),
          itemBuilder: (context, index) {
            return Center(
              child: Hero(
                tag: 'portfolio_$index',
                child: InteractiveViewer(
                  child: Image.network(images[index], fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const Icon(Icons.broken_image_outlined, color: Colors.white30, size: 80)),
                ),
              ),
            );
          },
        ),
        Positioned(top: 12, right: 12,
          child: GestureDetector(
            onTap: () => setState(() => _selectedIndex = -1),
            child: Container(width: 36, height: 36,
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 20)),
          ),
        ),
        Positioned(bottom: 20, left: 0, right: 0,
          child: Center(child: Text('${_selectedIndex + 1} / ${images.length}',
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14)))),
      ]),
    );
  }
}
