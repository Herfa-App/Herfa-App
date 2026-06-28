import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shared_widgets.dart';
import '../shared/chat_screen.dart';
import '../customer/booking_confirmation_screen.dart';

/// Screen 15 — Provider Profile Screen (أحمد النجار)
/// Analysis:
/// - AppBar: hamburger left, "حرفة" center, avatar right
/// - Hero banner image (woodworker photo) with overlay badges:
///   - Green "موثق خبير" badge, "سعر عادل" badge, "نظيف" tag
///   - Provider name overlay at bottom
/// - 3 stat chips: 10 years, 120+ projects, Pro badge
/// - "نبذة احترافية" card with bio text
/// - "معرض الأعمال" section with "عرض الكل" link, 2x2 image grid
/// - "المهارات والاحترافية" chip section
/// - Fixed bottom bar: "اتصال" (blue) + "دردشة" (orange) buttons
class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HerfaDrawer(),
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  // AppBar
                  _buildAppBar(context),

                  // Hero banner
                  _buildHeroBanner(),

                  const SizedBox(height: 16),

                  // Stats row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildStatsRow(),
                  ),

                  const SizedBox(height: 16),

                  // Bio card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildBioCard(),
                  ),

                  const SizedBox(height: 16),

                  // Portfolio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildPortfolioSection(),
                  ),

                  const SizedBox(height: 16),

                  // Skills
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSkillsSection(),
                  ),

                  // Space for fixed bottom bar
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),

          // Fixed bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(context),
          ),
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
          Builder(
              builder: (ctx) => GestureDetector(
                onTap: () => Scaffold.of(ctx).openDrawer(),
                child: const Icon(Icons.menu, color: AppColors.primary),
              ),
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
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.backgroundGrey,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person,
                color: AppColors.textSecondary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Stack(
      children: [
        // Banner image placeholder
        Container(
          width: double.infinity,
          height: 220,
          color: const Color(0xFF8B6914),
          child: const Icon(Icons.carpenter,
              size: 80, color: Colors.white24),
        ),

        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.primaryDark.withOpacity(0.85),
                ],
              ),
            ),
          ),
        ),

        // Top badges
        Positioned(
          top: 12,
          right: 12,
          child: Row(
            children: [
              _bannerBadge('موثق خبير ✓', AppColors.success),
              const SizedBox(width: 6),
              _bannerBadge('سعر عادل', AppColors.primaryLight),
              const SizedBox(width: 6),
              _bannerBadge('نظيف', AppColors.textWhite,
                  textColor: AppColors.textPrimary),
            ],
          ),
        ),

        // Bottom provider name
        Positioned(
          bottom: 12,
          right: 12,
          left: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'أحمد النجار',
                style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textWhite,
                ),
              ),
              Text(
                'خبير النجارة والديكور الخشبي العصري',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.textWhite.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bannerBadge(String text, Color bg,
      {Color textColor = AppColors.textWhite}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            icon: Icons.calendar_today_outlined,
            iconColor: AppColors.accent,
            value: '10',
            label: 'سنوات خبرة',
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          _StatItem(
            icon: Icons.handyman_outlined,
            iconColor: AppColors.primary,
            value: '120+',
            label: 'عمل مكتمل',
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          _StatItem(
            icon: Icons.verified_outlined,
            iconColor: AppColors.primary,
            value: 'برو',
            label: 'موثق بالكامل',
          ),
        ],
      ),
    );
  }

  Widget _buildBioCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('نبذة احترافية', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 10),
          Text(
            'أمتلك خبرة واسعة تمكنني في تحويل المساحات العادية إلى قطع فنية خشبية. متخصص في تنفيذ التصاميم المودرن، تركيب المطابخ الفاخرة، وترميم الأخشاب الأثرية بدقة متناهية وسرعة في الإنجاز.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {},
              child: Text(
                'عرض الكل',
                style: AppTextStyles.accentLink,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('معرض الأعمال', style: AppTextStyles.headlineSmall),
                Text(
                  'مشاهدة أحدث المشاريع المنفذة',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.0,
          children: [
            _portfolioItem(const Color(0xFF8B4513)),
            _portfolioItem(const Color(0xFF5C3317)),
            _portfolioItem(const Color(0xFFD2691E)),
            _portfolioItem(const Color(0xFFCD853F)),
          ],
        ),
      ],
    );
  }

  Widget _portfolioItem(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.carpenter,
          size: 40, color: Colors.white38),
    );
  }

  Widget _buildSkillsSection() {
    final skills = ['نجارة موبيليا', 'تركيب مطابخ', 'صيانة أبواب'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('المهارات والاحترافية', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            textDirection: TextDirection.rtl,
            children: skills
                .map(
                  (s) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.tagBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          s,
                          style: AppTextStyles.labelMedium,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.carpenter_outlined,
                            size: 14, color: AppColors.primary),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ChatScreen())),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_outline,
                        color: AppColors.textWhite, size: 18),
                    const SizedBox(width: 8),
                    Text('دردشة', style: AppTextStyles.labelLarge),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone_outlined,
                        color: AppColors.textWhite, size: 18),
                    const SizedBox(width: 8),
                    Text('اتصال', style: AppTextStyles.labelLarge),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
        ),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
