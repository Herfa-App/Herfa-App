import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shared_widgets.dart';
import '../customer/booking_confirmation_screen.dart';

/// Screen 12 — Provider Detailed Profile (أحمد محمد)
/// Analysis:
/// - Camera icon top-left, "حرفة ≡" top-right
/// - Banner image (wood planks)
/// - Avatar overlapping banner with orange verified badge
/// - "موثق" green tag, Provider name bold, specialty, location, stars, review count
/// - "حجز موعد" + chat button row
/// - Achievement cards: الأفضل تقييماً, خبير معتمد, 450+ مهمة
/// - "آراء العملاء" section: 2 review cards with avatars, stars, text
/// - "معرض الأعمال" 2x3 grid + "شاهد المزيد" card
/// - "إحصائيات الأداء" section: progress bars
/// - "التخصصات" chips
/// - Orange card "هوية موثقة"
/// - Bottom nav: 5 items
class ProviderDetailedProfileScreen extends StatelessWidget {
  const ProviderDetailedProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HerfaDrawer(),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: SingleChildScrollView(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    // Banner + avatar
                    _buildBannerSection(),

                    // Provider info
                    _buildProviderInfo(context),

                    const SizedBox(height: 16),

                    // Achievements
                    _buildAchievements(),

                    const SizedBox(height: 16),

                    // Reviews
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildReviewsSection(),
                    ),

                    const SizedBox(height: 16),

                    // Portfolio
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildPortfolioSection(),
                    ),

                    const SizedBox(height: 16),

                    // Stats
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildStatsSection(),
                    ),

                    const SizedBox(height: 16),

                    // Specializations
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSpecializations(),
                    ),

                    const SizedBox(height: 16),

                    // Verified badge card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildVerifiedCard(),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
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
          const Icon(Icons.camera_alt_outlined,
              color: AppColors.textSecondary),
          const Spacer(),
          Text(
            'حرفة',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            )
          ),
          const SizedBox(width: 4),
          Builder(
              builder: (ctx) => GestureDetector(
                onTap: () => Scaffold.of(ctx).openDrawer(),
                child: const Icon(Icons.menu, color: AppColors.primary),
              ),
            ),
          const Spacer(),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildBannerSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Banner
        Container(
          width: double.infinity,
          height: 160,
          color: const Color(0xFF6B4F2A),
          child: const Icon(Icons.carpenter,
              size: 80, color: Colors.white12),
        ),

        // Avatar
        Positioned(
          bottom: -36,
          right: 20,
          child: Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.backgroundWhite, width: 3),
                ),
                child: const Icon(Icons.person,
                    size: 44, color: AppColors.textLight),
              ),
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,

                  ),
                  child: const Icon(Icons.check,
                      color: AppColors.textWhite, size: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderInfo(BuildContext context) {
    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.only(
          top: 44, left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Name + tag
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'موثق',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('أحمد محمد', style: AppTextStyles.headlineLarge),
            ],
          ),
          const SizedBox(height: 4),
          Text('نجار محترف • الرياض، السعودية',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('(128 تقييم)', style: AppTextStyles.bodySmall),
              const SizedBox(width: 4),
              const StarRating(rating: 4.9, size: 16),
              const SizedBox(width: 4),
              Text(
                '4.9',
                style: AppTextStyles.titleSmall
                    .copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.message_outlined,
                            size: 16, color: AppColors.textPrimary),
                        const SizedBox(width: 6),
                        Text('محادثة',
                            style: AppTextStyles.labelMedium),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
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
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today,
                            color: AppColors.textWhite, size: 16),
                        const SizedBox(width: 6),
                        Text('حجز موعد',
                            style: AppTextStyles.labelLarge),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          _AchievementRow(
            icon: Icons.emoji_events_outlined,
            iconBg: const Color(0xFFFFF3E0),
            iconColor: AppColors.accent,
            title: 'الأفضل تقييماً',
            subtitle: 'ضمن أعلى 5% في الرياض',
          ),
          Divider(color: AppColors.border, height: 24),
          _AchievementRow(
            icon: Icons.verified_outlined,
            iconBg: const Color(0xFFE8F0FE),
            iconColor: AppColors.primary,
            title: 'خبير معتمد',
            subtitle: '15 عاماً من الخبرة',
          ),
          Divider(color: AppColors.border, height: 24),
          _AchievementRow(
            icon: Icons.check_circle_outline,
            iconBg: const Color(0xFFE8F8F0),
            iconColor: AppColors.success,
            title: '450+ مهمة',
            subtitle: 'معدل إكمال 98%',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SectionHeader(
          title: 'آراء العملاء',
          actionLabel: 'عرض الكل',
        ),
        const SizedBox(height: 12),
        _ReviewCard(
          name: 'خالد العتيبي',
          time: 'قبل 3 أيام',
          rating: 5,
          review:
              'أحمد نجار محترف جداً. قام بتركيب دواليب المطبخ بدقة عالية وهي تعمل قياساً. أنصح بالتعامل معه بشدة لمصداقيته واحترامه للعمل.',
        ),
        const SizedBox(height: 10),
        _ReviewCard(
          name: 'سارة المنصور',
          time: 'قبل أسبوع',
          rating: 5,
          review:
              'عمل رائعي في إصلاح الأثاث القديم. التفاصيل كانت مذهلة والأسعار قياسية جداً مقارنة بالجودة.',
        ),
      ],
    );
  }

  Widget _buildPortfolioSection() {
    final colors = [
      const Color(0xFF8B4513),
      const Color(0xFF5C3317),
      const Color(0xFFD2691E),
      const Color(0xFFCD853F),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('معرض الأعمال', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: [
            ...colors.map((c) => Container(
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.carpenter,
                      size: 40, color: Colors.white24),
                )),
            // "شاهد المزيد" card
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_library_outlined,
                      size: 28, color: AppColors.textSecondary),
                  const SizedBox(height: 6),
                  Text('شاهد المزيد',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.bar_chart_outlined,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('إحصائيات الأداء',
                  style: AppTextStyles.headlineSmall),
            ],
          ),
          const SizedBox(height: 14),
          _StatBar(
            label: 'سرعة الرد',
            rightLabel: 'ساعة واحدة',
            value: 0.9,
          ),
          const SizedBox(height: 10),
          _StatBar(
            label: 'الالتزام بالمواعيد',
            rightLabel: '95%',
            value: 0.95,
          ),
          const SizedBox(height: 10),
          _StatBar(
            label: 'جودة العمل',
            rightLabel: '98%',
            value: 0.98,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializations() {
    final specs = ['أثاث مودرن', 'ترميم', 'نجارة أبواب', 'ديكورات خشبية'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('التخصصات', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            textDirection: TextDirection.rtl,
            children: specs
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.tagBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(s,
                          style: AppTextStyles.labelMedium,
                          textDirection: TextDirection.rtl),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'هوية موثقة',
                      style: AppTextStyles.titleMedium
                          .copyWith(color: AppColors.accent),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified,
                        color: AppColors.accent, size: 18),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'تم التحقق من الوثائق الرسمية والخبرة العملية من قِبَل فريق حرفة',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.person_outline, 'label': 'الملف'},
      {'icon': Icons.chat_bubble_outline, 'label': 'المحادثة'},
      {'icon': Icons.receipt_long_outlined, 'label': 'الطلبات'},
      {'icon': Icons.receipt_outlined, 'label': 'الأسعار'},
      {'icon': Icons.home_outlined, 'label': 'الرئيسية'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item['icon'] as IconData,
                      color: AppColors.textLight, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    item['label'] as String,
                    style: AppTextStyles.bodySmall
                        .copyWith(fontSize: 11),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Review Card ──────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final String name;
  final String time;
  final int rating;
  final String review;

  const _ReviewCard({
    required this.name,
    required this.time,
    required this.rating,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(name, style: AppTextStyles.titleSmall),
                  Text(time, style: AppTextStyles.bodySmall),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundGrey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person,
                    size: 22, color: AppColors.textLight),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StarRating(rating: rating.toDouble(), size: 14),
          const SizedBox(height: 6),
          Text(
            review,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

// ── Stat Progress Bar ────────────────────────────────────────────────────────
class _StatBar extends StatelessWidget {
  final String label;
  final String rightLabel;
  final double value;

  const _StatBar(
      {required this.label,
      required this.rightLabel,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(rightLabel, style: AppTextStyles.bodySmall),
            Text(label, style: AppTextStyles.labelMedium),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.backgroundGrey,
            color: AppColors.primary,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

// ── Achievement Row ──────────────────────────────────────────────────────────
class _AchievementRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _AchievementRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(title, style: AppTextStyles.titleSmall),
            Text(subtitle, style: AppTextStyles.bodySmall),
          ],
        ),
        const Spacer(),
        Container(
          width: 40,
          height: 40,
          decoration:
              BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ],
    );
  }
}
