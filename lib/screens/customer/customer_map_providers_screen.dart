import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shared_widgets.dart';
import '../customer/provider_profile_screen.dart';
import '../shared/chat_screen.dart';
import '../customer/booking_confirmation_screen.dart';

/// Screen 10 — Customer Map Providers Screen (Map with provider card)
/// Analysis:
/// - AppBar: avatar + "حرفة" + menu
/// - Search bar with filter icon (dark blue) + text + search icon
/// - Category pills: سباكة(selected), نجارة, كهرباء
/// - Map background (greyscale city) with two provider pin markers (tools icon)
/// - Bottom drawer card:
///   - Rating badge "4.9 ★"
///   - Provider avatar (rounded)
///   - "ممتاز" amber badge
///   - Provider name (bold), specialty, rating
///   - "متاح الآن" green dot + "2.5 كم" location
///   - 3 action buttons: حجز موعد (navy), مراسلة (outlined), location target (brown circle)
/// - Bottom nav: الرئيسية(active), طلباتي, الرسائل(badge), حسابي
class CustomerMapProvidersScreen extends StatefulWidget {
  const CustomerMapProvidersScreen({super.key});

  @override
  State<CustomerMapProvidersScreen> createState() =>
      _CustomerMapProvidersScreenState();
}

class _CustomerMapProvidersScreenState
    extends State<CustomerMapProvidersScreen> {
  int _selectedCategory = 0;
  final List<String> _categories = ['سباكة', 'نجارة', 'كهرباء'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HerfaDrawer(),
      backgroundColor: AppColors.backgroundWhite,
      body: Column(
        children: [
          // AppBar
          _buildAppBar(context),

          Expanded(
            child: Stack(
              children: [
                // Map background
                Positioned.fill(
                  child: _buildMapBackground(),
                ),

                // Search + categories
                Positioned(
                  top: 10,
                  left: 12,
                  right: 12,
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 10),
                      _buildCategoryPills(),
                    ],
                  ),
                ),

                // Map pins
                Positioned(
                  top: 140,
                  left: 100,
                  child: _buildMapPin(),
                ),
                Positioned(
                  top: 220,
                  left: 200,
                  child: _buildMapPin(size: 44),
                ),

                // Provider bottom card
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildProviderCard(context),
                ),
              ],
            ),
          ),

          // Bottom nav
          _buildBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: AppColors.backgroundWhite,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
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

  Widget _buildMapBackground() {
    return Container(
      color: const Color(0xFFBDBDBD),
      child: Opacity(
        opacity: 0.7,
        child: Image.network(
          'https://via.placeholder.com/400x600',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFCCCCCC),
            child: CustomPaint(
              painter: _CityMapPainter(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
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
          // Search icon
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Icon(Icons.search,
                color: AppColors.textLight, size: 20),
          ),

          // Text field
          Expanded(
            child: Text(
              'ابحث عن حرفي في منطقتك...',
              style: AppTextStyles.hintStyle,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),

          // Filter button
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune,
                color: AppColors.textWhite, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPills() {
    return Row(
      textDirection: TextDirection.rtl,
      children: _categories.asMap().entries.map((e) {
        final isSelected = e.key == _selectedCategory;
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedCategory = e.key),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.06),
                    blurRadius: 6,
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    e.value,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.textWhite
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.handyman,
                    size: 14,
                    color: isSelected
                        ? AppColors.textWhite
                        : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMapPin({double size = 38}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: const Icon(Icons.handyman,
              color: AppColors.textWhite, size: 18),
        ),
        Container(
          width: 2,
          height: 16,
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildProviderCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Provider info row
            Row(
              children: [
                // Left: rating
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.accent.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star,
                          color: AppColors.starColor, size: 14),
                      const SizedBox(width: 3),
                      Text('4.9',
                          style: AppTextStyles.titleSmall
                              .copyWith(color: AppColors.textPrimary)),
                    ],
                  ),
                ),

                const Spacer(),

                // Center: info
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'احمد الفارس',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'خبيرفي نجارة الأثاث الحديث والكلاسيك بخبرة ١٠ سنوات',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '2.5 كم',
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(width: 3),
                          const Icon(Icons.location_on_outlined,
                              size: 12,
                              color: AppColors.textLight),
                          const SizedBox(width: 8),
                          const Text('●',
                              style: TextStyle(
                                  color: AppColors.greenAvailable,
                                  fontSize: 10)),
                          const SizedBox(width: 3),
                          Text(
                            'متاح الآن',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.greenAvailable,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Right: avatar
                Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person,
                          size: 40, color: AppColors.textLight),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'ممتاز',
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Action buttons
            Row(
              children: [
                // Location target button
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5E3C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.my_location,
                        color: AppColors.textWhite, size: 22),
                  ),
                ),

                const SizedBox(width: 10),

                // Message button
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ChatScreen()),
                    ),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.message_outlined,
                              color: AppColors.textPrimary, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'مراسلة',
                            style: AppTextStyles.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Book button
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const BookingConfirmationScreen()),
                    ),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today,
                              color: AppColors.textWhite, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'حجز موعد',
                            style: AppTextStyles.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.map_outlined, 'الرئيسية', true),
              _navItem(Icons.receipt_long_outlined, 'طلباتي', false),
              _navItemWithBadge(
                  Icons.chat_bubble_outline, 'الرسائل', false),
              _navItem(Icons.person_outline, 'حسابي', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            color: active ? AppColors.primary : AppColors.textLight,
            size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: active ? AppColors.primary : AppColors.textLight,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            fontSize: 11,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  Widget _navItemWithBadge(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon,
                color: active ? AppColors.primary : AppColors.textLight,
                size: 22),
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: active ? AppColors.primary : AppColors.textLight,
            fontSize: 11,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}

class _CityMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFB0B0B0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), roadPaint);
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), roadPaint);
    }

    final buildingPaint = Paint()
      ..color = const Color(0xFF999999)
      ..style = PaintingStyle.fill;

    final buildings = [
      Rect.fromLTWH(10, 20, 30, 40),
      Rect.fromLTWH(60, 10, 20, 35),
      Rect.fromLTWH(110, 25, 35, 30),
      Rect.fromLTWH(160, 15, 25, 45),
      Rect.fromLTWH(200, 30, 30, 25),
    ];
    for (final b in buildings) {
      canvas.drawRect(b, buildingPaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
