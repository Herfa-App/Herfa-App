import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shared_widgets.dart';
import '../customer/customer_home_screen.dart';

/// Screen 8 — Map Request Screen (اطلب خدمة الآن)
/// Analysis:
/// - AppBar: avatar left, "حرفة" center, hamburger right
/// - Full screen grey map background (placeholder)
/// - Search bar overlay with location pin icon + text
/// - Bottom sheet / panel:
///   - "متاح الآن" badge (orange) + "اطلب خدمة الآن" title
///   - Multiline textarea "اوصف لنا المشكلة..." with char counter
///   - "إضافة صورة" button (outlined)
///   - "نشر الطلب للحرفيين القريبين" CTA (navy)
/// - Bottom nav: الرئيسية active
class MapRequestScreen extends StatelessWidget {
  const MapRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HerfaDrawer(),
      backgroundColor: AppColors.backgroundWhite,
      body: Stack(
        children: [
          // ── Map Background ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: const Color(0xFFD8D8D8),
              child: CustomPaint(
                painter: _MapPatternPainter(),
              ),
            ),
          ),

          // ── App Bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildAppBar(context),
          ),

          // ── Search Bar ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 16,
            right: 16,
            child: _buildSearchBar(),
          ),

          // ── Bottom panel ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withOpacity(0.96),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.06),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person,
                color: AppColors.textSecondary, size: 22),
          ),
          const Spacer(),
          Text(
            'حرفة',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            )
          ),
          const Spacer(),
          Builder(
              builder: (ctx) => GestureDetector(
                onTap: () => Scaffold.of(ctx).openDrawer(),
                child: const Icon(Icons.menu, color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 12,
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search,
              color: AppColors.textLight, size: 20),
          Expanded(
            child: Text(
              'ابحث عن موقع الخدمة...',
              style: AppTextStyles.hintStyle,
              textAlign: TextAlign.right,
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.my_location,
              color: AppColors.primary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 70,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // "متاح الآن" badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.accent.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt,
                          color: AppColors.accent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'متاح الآن',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  'اطلب خدمة الآن',
                  style: AppTextStyles.headlineSmall,
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Description textarea
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(12),
              child: Stack(
                children: [
                  TextField(
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: 5,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'اوصف لنا المشكلة...',
                      hintStyle: AppTextStyles.hintStyle,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      fillColor: Colors.transparent,
                      filled: false,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Text(
                      '0/200',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Add image button
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt_outlined,
                        color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'إضافة صورة',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Publish button
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_outlined,
                        color: AppColors.textWhite, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'نشر الطلب للحرفيين القريبين',
                      style: AppTextStyles.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple map grid painter
class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Draw grid lines to simulate map
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw some curved "road" lines
    final roadPaint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.25, size.width, size.height * 0.35);
    canvas.drawPath(path1, roadPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.5, size.width * 0.3, size.height);
    canvas.drawPath(path2, roadPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
