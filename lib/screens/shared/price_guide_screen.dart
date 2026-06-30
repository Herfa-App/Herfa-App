import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shared_widgets.dart';

class PriceGuideScreen extends StatefulWidget {
  const PriceGuideScreen({super.key});
  @override
  State<PriceGuideScreen> createState() => _PriceGuideScreenState();
}

class _PriceGuideScreenState extends State<PriceGuideScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['الكل', 'صيانة', 'تأسيس', 'تركيب'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const HerfaDrawer(),
      body: Column(children: [
        _buildAppBar(context),
        Expanded(
          child: SingleChildScrollView(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildHeroCard(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: 14),
                _buildFilterChips(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(children: [
                    _buildServiceCard(
                      badge: 'أكثر طلباً', badgeColor: AppColors.accent,
                      icon: Icons.plumbing_outlined,
                      iconBg: const Color(0xFFFFF0E0), iconColor: AppColors.accent,
                      title: 'خدمات السباكة',
                      items: const [
                        _PriceRow('تغيير مشور', '١٠ - ٢٠ ج.م'),
                        _PriceRow('أسلك دوش', '١٥ - ٣٥ ج.م'),
                        _PriceRow('تركيب طفم حمام', '٨٠ - ١٥٠ ج.م'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildServiceCard(
                      icon: Icons.carpenter_outlined,
                      iconBg: const Color(0xFFEEF0F8), iconColor: AppColors.primary,
                      title: 'خدمات النجارة',
                      items: const [
                        _PriceRow('تركيب كابون باب', '١٠ - ٣٠ ج.م'),
                        _PriceRow('تفكيك/تركيب سرير', '٢٠ - ٤٠ ج.م'),
                        _PriceRow('إصلاح مفصلات دواليب', '١٠ - ٢٥ ج.م'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildServiceCard(
                      badge: 'مخاطرة عالية', badgeColor: AppColors.error,
                      icon: Icons.electrical_services_outlined,
                      iconBg: const Color(0xFFFEEDEB), iconColor: AppColors.error,
                      title: 'خدمات الكهرباء',
                      items: const [
                        _PriceRow('تركيب لمبة', '٢٠ - ٥٠ ج.م'),
                        _PriceRow('تغيير مفاتيح كهرباء', '٥٠ - ١٠٠ ج.م'),
                        _PriceRow('صيانة لوحة توزيع', '٤٠ - ٨٠ ج.م'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildServiceCard(
                      icon: Icons.format_paint_outlined,
                      iconBg: const Color(0xFFF0F0FF),
                      iconColor: const Color(0xFF6C63FF),
                      title: 'خدمات النقاشة والدهانات',
                      items: const [
                        _PriceRow('دهان غرفة (وجه واحد)', '٨٠ - ١٢٠ ج.م'),
                        _PriceRow('سحب معجون (متر مربع)', '٤٠ - ٧٠ ج.م'),
                        _PriceRow('عزل أسطح ورطوبة', '١٥٠ - ٣٠٠ ج.م'),
                        _PriceRow('إصلاح قروق وتشققات', '٣٠ - ٦٠ ج.م'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCtaCard(),
                    const SizedBox(height: 16),
                    _buildNotesCard(),
                    const SizedBox(height: 20),
                  ]),
                ),
              ]),
            ),
          ),
        ),
        _buildBottomNav(context),
      ]),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: AppColors.backgroundWhite,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16, right: 16, bottom: 8),
      child: Row(children: [
        Text('دليل الأسعار',
            style: AppTextStyles.headlineSmall
                .copyWith(color: AppColors.primary)),
        const Spacer(),
        Text('حرفة', style: AppTextStyles.brandTitle.copyWith(fontSize: 20)),
        const SizedBox(width: 4),
        Builder(
          builder: (ctx) => GestureDetector(
            onTap: () => Scaffold.of(ctx).openDrawer(),
            child: const Icon(Icons.menu, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.camera_alt_outlined, color: AppColors.textSecondary),
      ]),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
      child: Stack(children: [
        Positioned(left: -20, bottom: -20,
          child: Container(width: 100, height: 100,
            decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06)))),
        Positioned(left: 20, top: -10,
          child: Container(width: 60, height: 60,
            decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06)))),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('شفافية الأسعار\nتهمنا',
              style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w800,
                  color: AppColors.textWhite, height: 1.3),
              textDirection: TextDirection.rtl),
          const SizedBox(height: 8),
          Text(
            'نقدم لك دليلاً محدثاً لمتوسط أسعار الخدمات الحرفيين في السوق المصري.',
            style: GoogleFonts.cairo(fontSize: 12,
                color: AppColors.textWhite.withOpacity(0.8), height: 1.5),
            textDirection: TextDirection.rtl,
          ),
        ]),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Row(children: [
        const Padding(padding: EdgeInsets.only(left: 12),
            child: Icon(Icons.search, color: AppColors.textLight, size: 20)),
        Expanded(
          child: TextField(
            textAlign: TextAlign.right, textDirection: TextDirection.rtl,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'ابحث عن خدمة (سباكة، نجارة...)',
              hintStyle: AppTextStyles.hintStyle,
              border: InputBorder.none, enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              filled: false,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _filters.asMap().entries.map((e) {
          final sel = e.key == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: sel ? AppColors.primary : AppColors.border),
                ),
                child: Text(e.value,
                    style: GoogleFonts.cairo(fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel ? AppColors.textWhite : AppColors.textPrimary)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildServiceCard({
    String? badge, Color? badgeColor,
    required IconData icon, required Color iconBg, required Color iconColor,
    required String title, required List<_PriceRow> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (badgeColor ?? AppColors.accent).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: (badgeColor ?? AppColors.accent).withOpacity(0.3)),
              ),
              child: Text(badge, style: GoogleFonts.cairo(fontSize: 11,
                  fontWeight: FontWeight.w700, color: badgeColor ?? AppColors.accent)),
            )
          else const SizedBox.shrink(),
          Container(width: 42, height: 42,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 22)),
        ]),
        const SizedBox(height: 10),
        Text(title, style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),
        ...items.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(r.price, style: AppTextStyles.titleSmall
                .copyWith(color: AppColors.primary),
                textDirection: TextDirection.rtl),
            Text(r.service, style: AppTextStyles.bodyMedium,
                textDirection: TextDirection.rtl),
          ]),
        )),
      ]),
    );
  }

  Widget _buildCtaCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.accent, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        const Icon(Icons.verified_outlined, color: AppColors.textWhite, size: 32),
        const SizedBox(height: 10),
        Text('احصل على تسعير دقيق',
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800,
                color: AppColors.textWhite)),
        const SizedBox(height: 6),
        Text('اطلب الخدمة الآن وسيقدم الحرفيون عروض أسعار خلال دقائق',
            style: GoogleFonts.cairo(fontSize: 12,
                color: AppColors.textWhite.withOpacity(0.85), height: 1.5),
            textAlign: TextAlign.center, textDirection: TextDirection.rtl),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            decoration: BoxDecoration(
                color: const Color(0xFFB8750A),
                borderRadius: BorderRadius.circular(10)),
            child: Text('اطلب حالياً',
                style: GoogleFonts.cairo(fontSize: 15,
                    fontWeight: FontWeight.w700, color: AppColors.textWhite)),
          ),
        ),
      ]),
    );
  }

  Widget _buildNotesCard() {
    const notes = [
      'هذه الأسعار لا تشمل تكلفة قطع الغيار.',
      'تختلف الأسعار حسب الخدمة والمنطقة الجغرافية.',
      'يتم الاتفاق النهائي مع الحرفي قبل بدء العمل.',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('ملاحظات هامة', style: AppTextStyles.titleMedium),
          const SizedBox(width: 6),
          const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 18),
        ]),
        const SizedBox(height: 10),
        ...notes.map((n) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Text(n,
                  style: AppTextStyles.bodySmall.copyWith(height: 1.5),
                  textDirection: TextDirection.rtl, textAlign: TextAlign.right),
            ),
            const SizedBox(width: 6),
            Text('•', style: TextStyle(color: AppColors.textSecondary)),
          ]),
        )),
      ]),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    // ✅ Same order as CustomerHomeScreen: [الملف | محادثة | الحجوزات | الأسعار | الرئيسية]
    const items = [
      BottomNavItem(icon: Icons.person_outline,           label: 'الملف'),
      BottomNavItem(icon: Icons.chat_bubble_outline,      label: 'محادثة'),
      BottomNavItem(icon: Icons.calendar_today_outlined,  label: 'الحجوزات'),
      BottomNavItem(icon: Icons.receipt_long,             label: 'الأسعار'),
      BottomNavItem(icon: Icons.home_outlined,            label: 'الرئيسية'),
    ];
    return HerfaBottomNav(
      currentIndex: 3, // الأسعار active
      items: items,
      onTap: (i) {
        switch (i) {
          case 0:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/chat');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/bookings');
            break;
          case 3:
            break; // already here
          case 4:
            Navigator.pushReplacementNamed(context, '/home');
            break;
        }
      },
    );
  }
}

class _PriceRow {
  final String service;
  final String price;
  const _PriceRow(this.service, this.price);
}
