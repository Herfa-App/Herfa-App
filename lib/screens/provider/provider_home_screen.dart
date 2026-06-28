import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shared_widgets.dart';
import '../shared/chat_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});
  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  bool _isAvailable = false; // toggle متاح/مشغول
  int _selectedNavIndex = 0; // طلباتي

  void _onNavTap(int i) {
    if (i == _selectedNavIndex) return;
    setState(() => _selectedNavIndex = i);
    if (i == 2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ChatScreen()))
          .then((_) => setState(() => _selectedNavIndex = 0));
    } else {
      setState(() => _selectedNavIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const HerfaDrawer(),
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(children: [
                    const SizedBox(height: 16),
                    _buildWorkStatusCard(),
                    const SizedBox(height: 14),
                    _buildMapSection(),
                    const SizedBox(height: 18),
                    SectionHeader(
                        title: 'طلبات قريبة مني',
                        actionLabel: 'تصفح الكل ›',
                        onAction: () {}),
                    const SizedBox(height: 12),
                    _buildRequestCard(
                      distance: '1.2 كم',
                      title: 'إصلاح تسرب مياه في المطبخ',
                      description: 'يوجد تسرب تحت المغسلة يحتاج إلى فحص...',
                      tags: const ['عاجل', 'سباكة'],
                      icon: Icons.plumbing_outlined,
                      iconBg: const Color(0xFFFFF0E0),
                      iconColor: AppColors.accent,
                    ),
                    const SizedBox(height: 12),
                    _buildRequestCard(
                      distance: '2.5 كم',
                      title: 'تغيير لوحة التوزيع الكهربائية',
                      description: 'تحديث قواطع الكهرباء للفيلا بالكامل...',
                      tags: const ['فيلا', 'كهرباء'],
                      icon: Icons.electrical_services_outlined,
                      iconBg: const Color(0xFFFEEDEB),
                      iconColor: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    _buildRequestCard(
                      distance: '0.8 كم',
                      title: 'دهان غرفة معيشة',
                      description: 'عمل دهان جدران وسقف لغرفة معيشة...',
                      tags: const ['اليوم', 'دهانات'],
                      icon: Icons.format_paint_outlined,
                      iconBg: const Color(0xFFF0F0FF),
                      iconColor: const Color(0xFF6C63FF),
                    ),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: AppColors.backgroundWhite,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16, right: 16, bottom: 8),
      child: Row(children: [
        Builder(
          builder: (ctx) => GestureDetector(
            onTap: () => Scaffold.of(ctx).openDrawer(),
            child: const Icon(Icons.menu, color: AppColors.primary),
          ),
        ),
        const Spacer(),
        Text('حرفة', style: AppTextStyles.brandTitle.copyWith(fontSize: 22)),
        const Spacer(),
        Container(
          width: 38, height: 38,
          decoration: const BoxDecoration(
              color: Color(0xFF3A3A3A), shape: BoxShape.circle),
          child: const Icon(Icons.person, color: AppColors.textWhite, size: 20),
        ),
      ]),
    );
  }

  Widget _buildWorkStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Toggle switch
          GestureDetector(
            onTap: () => setState(() => _isAvailable = !_isAvailable),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 130,
              height: 38,
              decoration: BoxDecoration(
                color: _isAvailable ? AppColors.success : AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  alignment: _isAvailable
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 65, height: 34,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(18)),
                    child: Center(
                      child: Text(
                        _isAvailable ? 'متاح' : 'مشغول',
                        style: GoogleFonts.cairo(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: _isAvailable
                                ? AppColors.success
                                : AppColors.primary),
                      ),
                    ),
                  ),
                ),
                // Other label
                Align(
                  alignment: _isAvailable
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      _isAvailable ? 'مشغول' : 'متاح',
                      style: GoogleFonts.cairo(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: AppColors.textWhite.withOpacity(0.8)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('حالة العمل', style: AppTextStyles.titleMedium),
            Text('حدد توفرك لاستقبال الطلبات',
                style: AppTextStyles.bodySmall,
                textDirection: TextDirection.rtl),
          ]),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      width: double.infinity, height: 220,
      decoration: BoxDecoration(
          color: const Color(0xFF6DBFBE),
          borderRadius: BorderRadius.circular(16)),
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CustomPaint(
              size: const Size(double.infinity, 220),
              painter: _WorldMapPainter()),
        ),
        Positioned(
          top: 12, left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.location_on,
                  color: AppColors.textWhite, size: 14),
              const SizedBox(width: 4),
              Text('موقعك الحالي',
                  style: GoogleFonts.cairo(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: AppColors.textWhite)),
            ]),
          ),
        ),
        Positioned(
          bottom: 10, right: 10, left: 10,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text('كثافة الطلبات مرتفعة',
                          style: AppTextStyles.titleSmall,
                          textDirection: TextDirection.rtl),
                      const SizedBox(width: 6),
                      Container(
                          width: 10, height: 10,
                          decoration: const BoxDecoration(
                              color: AppColors.accent, shape: BoxShape.circle)),
                    ]),
                    const SizedBox(height: 3),
                    Text('حي العليا والملز يشهدان طلباً متزايداً الآن',
                        style: AppTextStyles.bodySmall,
                        textDirection: TextDirection.rtl),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildRequestCard({
    required String distance, required String title,
    required String description, required List<String> tags,
    required IconData icon, required Color iconBg, required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Flexible(
                child: Text(title,
                    style: AppTextStyles.titleSmall
                        .copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                    textDirection: TextDirection.rtl),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(distance,
                    style: GoogleFonts.cairo(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: AppColors.accent)),
              ),
            ]),
            const SizedBox(height: 4),
            Text(description,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
                textDirection: TextDirection.rtl),
            const SizedBox(height: 10),
            Row(children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border)),
                  child: Text('عرض التفاصيل',
                      style: AppTextStyles.labelMedium
                          .copyWith(fontSize: 12)),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: tags.map((t) => Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.tagBg,
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(t,
                      style: GoogleFonts.cairo(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                )).toList(),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _buildBottomNav() {
    // Ordered RTL: طلباتي | الرئيسية | الرسائل | حسابي
    const items = [
      BottomNavItem(icon: Icons.receipt_long_outlined, label: 'طلباتي'),
      BottomNavItem(icon: Icons.home_outlined,         label: 'الرئيسية'),
      BottomNavItem(icon: Icons.chat_bubble_outline,   label: 'الرسائل'),
      BottomNavItem(icon: Icons.person_outline,        label: 'حسابي'),
    ];
    return HerfaBottomNav(
      currentIndex: _selectedNavIndex,
      items: items,
      onTap: _onNavTap,
    );
  }
}

class _WorldMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final heat = Paint()
      ..shader = RadialGradient(colors: [
        const Color(0xFFF5A623).withOpacity(0.55),
        Colors.transparent,
      ]).createShader(Rect.fromCenter(
          center: Offset(size.width * 0.55, size.height * 0.42),
          width: 200, height: 200));
    canvas.drawCircle(
        Offset(size.width * 0.55, size.height * 0.42), 100, heat);

    final land = Paint()
      ..color = const Color(0xFF4AACAB)
      ..style = PaintingStyle.fill;

    void blob(List<Offset> pts) {
      final p = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < pts.length - 1; i++) {
        p.quadraticBezierTo(
            pts[i].dx, pts[i].dy, pts[i + 1].dx, pts[i + 1].dy);
      }
      p.close();
      canvas.drawPath(p, land);
    }

    blob([
      Offset(size.width * .05, size.height * .3),
      Offset(size.width * .1,  size.height * .15),
      Offset(size.width * .25, size.height * .2),
      Offset(size.width * .3,  size.height * .4),
      Offset(size.width * .2,  size.height * .55),
      Offset(size.width * .05, size.height * .3),
    ]);
    blob([
      Offset(size.width * .4,  size.height * .1),
      Offset(size.width * .6,  size.height * .05),
      Offset(size.width * .7,  size.height * .2),
      Offset(size.width * .75, size.height * .45),
      Offset(size.width * .6,  size.height * .65),
      Offset(size.width * .35, size.height * .45),
      Offset(size.width * .4,  size.height * .1),
    ]);
    blob([
      Offset(size.width * .8,  size.height * .2),
      Offset(size.width * .95, size.height * .25),
      Offset(size.width * .98, size.height * .5),
      Offset(size.width * .9,  size.height * .65),
      Offset(size.width * .8,  size.height * .55),
      Offset(size.width * .8,  size.height * .2),
    ]);
  }
  @override bool shouldRepaint(_) => false;
}
