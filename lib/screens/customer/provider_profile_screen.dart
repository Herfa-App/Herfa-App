import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shared_widgets.dart';
import 'portfolio_gallery_screen.dart';
import '../../core/services/supabase_service.dart';

/// Screen 15 — Provider Profile Screen (Dynamic details)
class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  Future<void> _handleCall(BuildContext context, String providerId) async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      final phone = await SupabaseService.instance.getContactInfo(providerId);
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading dialog
      }
      
      if (phone != null && phone.isNotEmpty) {
        if (!context.mounted) return;
        // Show contact info dialog
        showDialog(
          context: context,
          builder: (ctx) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('بيانات الاتصال', style: AppTextStyles.headlineSmall),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('رقم الهاتف الخاص بالحرفي للاتصال المباشر:', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 14),
                  SelectableText(
                    phone,
                    style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: phone));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ رقم الهاتف إلى الحافظة', textAlign: TextAlign.right)),
                    );
                  },
                  child: Text('نسخ الرقم', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.accent)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('إغلاق', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        );
      } else {
        if (!context.mounted) return;
        // Show privacy lock dialog
        showDialog(
          context: context,
          builder: (ctx) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('تنبيه الخصوصية', style: AppTextStyles.headlineSmall),
              content: Text(
                'رقم الهاتف غير متاح حالياً. يظهر رقم الهاتف للحرفي فقط بعد قبول طلب الحجز الخاص بك حفاظاً على الخصوصية والأمان.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.right,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('موافق', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء جلب البيانات: ${e.toString()}', textAlign: TextAlign.right)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final name = provider['full_name'] ?? 'حرفي حرفة';
    final skills = provider['skills'] ?? 'عامة';
    final bio = provider['bio'] ?? '';
    final experience = provider['experience_years']?.toString() ?? '0';
    final rating = provider['rating'] != null ? (provider['rating'] as num).toStringAsFixed(1) : '5.0';
    final ratingNum = provider['rating'] != null ? (provider['rating'] as num).toDouble() : 5.0;
    final avatarUrl = provider['avatar_url'];
    final hourlyRate = provider['hourly_rate'] != null ? (provider['hourly_rate'] as num).toStringAsFixed(0) : '0';
    final hourlyRateNum = provider['hourly_rate'] != null ? (provider['hourly_rate'] as num).toDouble() : 0.0;
    final isAvailable = provider['is_available'] == true;
    final portfolioImages = _buildPortfolioUrls(skills, provider['portfolio_images']);

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
                  _buildHeroBanner(avatarUrl, name, skills, ratingNum, hourlyRateNum, isAvailable),

                  const SizedBox(height: 16),

                  // Stats row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildStatsRow(experience, rating, hourlyRate),
                  ),

                  const SizedBox(height: 16),

                  // Bio card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildBioCard(bio),
                  ),

                  const SizedBox(height: 16),

                  // Portfolio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildPortfolioSection(context, name, skills, portfolioImages),
                  ),

                  const SizedBox(height: 16),

                  // Skills
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSkillsSection(skills),
                  ),

                  // Space for fixed bottom bar
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Fixed bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(context, provider),
          ),
        ],
      ),
    );
  }

  static List<String> _buildPortfolioUrls(String skills, dynamic dbImages) {
    if (dbImages != null) {
      final list = (dbImages as List).cast<String>();
      if (list.isNotEmpty) return list;
    }
    if (skills.contains('سباكة')) {
      return [
        'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
        'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=400',
        'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400',
      ];
    } else if (skills.contains('كهرباء')) {
      return [
        'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400',
        'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400',
        'https://images.unsplash.com/photo-1517420704952-d9f39e95b43e?w=400',
        'https://images.unsplash.com/photo-1534482421-64566f976cfa?w=400',
      ];
    } else if (skills.contains('نجارة') || skills.contains('أثاث')) {
      return [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
        'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400',
        'https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=400',
        'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=400',
      ];
    } else if (skills.contains('دهان') || skills.contains('دهانات')) {
      return [
        'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=400',
        'https://images.unsplash.com/photo-1597076545399-91a3ff0e71b3?w=400',
        'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=400',
        'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400',
      ];
    } else if (skills.contains('تكييف')) {
      return [
        'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=400',
        'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=400',
        'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400',
        'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400',
      ];
    }
    return [
      'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
      'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400',
      'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400',
      'https://images.unsplash.com/photo-1517420704952-d9f39e95b43e?w=400',
    ];
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
            child: const Icon(Icons.person, color: AppColors.textSecondary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(String? avatarUrl, String name, String skills, double ratingNum, double hourlyRateNum, bool isAvailable) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 220,
          decoration: const BoxDecoration(color: Color(0xFF8B6914)),
          child: avatarUrl != null
              ? Image.network(avatarUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, size: 80, color: Colors.white24))
              : const Icon(Icons.person, size: 80, color: Colors.white24),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.primaryDark.withOpacity(0.85)],
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Row(
            children: [
              if (ratingNum >= 4.5) _bannerBadge('موثق خبير ✓', AppColors.success),
              if (ratingNum >= 4.5) const SizedBox(width: 6),
              if (hourlyRateNum <= 150) _bannerBadge('سعر عادل', AppColors.primaryLight),
              if (hourlyRateNum <= 150) const SizedBox(width: 6),
              if (isAvailable) _bannerBadge('متاح حالياً', AppColors.textWhite, textColor: AppColors.textPrimary),
            ],
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          left: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                name,
                style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textWhite),
              ),
              Text(
                'حرفي متخصص في $skills بمصر',
                style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textWhite.withOpacity(0.85)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bannerBadge(String text, Color bg, {Color textColor = AppColors.textWhite}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700, color: textColor),
      ),
    );
  }

  Widget _buildStatsRow(String experience, String rating, String hourlyRate) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(icon: Icons.calendar_today_outlined, iconColor: AppColors.accent, value: '$experience سنوات', label: 'خبرة عملية'),
          Container(width: 1, height: 40, color: AppColors.border),
          _StatItem(icon: Icons.star_outline, iconColor: AppColors.primary, value: rating, label: 'تقييم الحرفي'),
          Container(width: 1, height: 40, color: AppColors.border),
          _StatItem(icon: Icons.monetization_on_outlined, iconColor: AppColors.primary, value: '$hourlyRate ج.م', label: 'سعر الساعة'),
        ],
      ),
    );
  }

  Widget _buildBioCard(String bio) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('نبذة تعريفية', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 10),
          Text(bio.isNotEmpty ? bio : 'لا توجد تفاصيل إضافية مضافة في السيرة الذاتية حالياً.', style: AppTextStyles.bodyMedium, textAlign: TextAlign.right),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection(BuildContext context, String name, String skills, List<String> images) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PortfolioGalleryScreen(),
                    settings: RouteSettings(arguments: {
                      'images': images,
                      'provider_name': name,
                    }),
                  ),
                );
              },
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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
          ),
          itemCount: images.take(4).length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PortfolioGalleryScreen(),
                    settings: RouteSettings(arguments: {
                      'images': images,
                      'provider_name': name,
                    }),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B4513).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.handyman_outlined, size: 40, color: Colors.white60),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSkillsSection(String skills) {
    final list = skills.split(RegExp('[،,]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (list.isEmpty) list.add('صيانة عامة');

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
            children: list
                .map(
                  (s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                        const Icon(Icons.check_circle, size: 14, color: AppColors.primary),
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

  Widget _buildBottomBar(BuildContext context, Map<String, dynamic> provider) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
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
          // Chat Button
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                '/chat',
                arguments: {
                  'target_user_id': provider['id'],
                  'target_name': provider['full_name'],
                },
              ),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_outline, color: AppColors.textWhite, size: 16),
                    const SizedBox(width: 6),
                    Text('دردشة', style: AppTextStyles.labelMedium),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Call Button
          Expanded(
            child: GestureDetector(
              onTap: () => _handleCall(context, provider['id']),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone_outlined, color: AppColors.textWhite, size: 16),
                    const SizedBox(width: 6),
                    Text('اتصال', style: AppTextStyles.labelMedium),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Book Button
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                '/bookings',
                arguments: provider,
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
                    const Icon(Icons.calendar_today_outlined, color: AppColors.textWhite, size: 16),
                    const SizedBox(width: 6),
                    Text('احجز الآن', style: AppTextStyles.labelLarge),
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
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(fontSize: 16),
        ),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
