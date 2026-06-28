import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shared_widgets.dart';
import '../provider/provider_home_screen.dart';

/// Screen 6 — Provider Profile Setup Screen
/// Analysis:
/// - AppBar: avatar (female) left, "حرفة" center-right, hamburger right
/// - Hero card (light grey): "انضم إلينا" orange tag, large heading, subtitle, tools icon
/// - "نوع الحرفة" dropdown: "اختر حرفتك الأساسية"
/// - "سنوات الخبرة" input with diploma icon, placeholder "مثال: 5"
/// - "معرض الأعمال" upload card: camera+ icon, title, subtitle
/// - 3 portfolio image thumbnails (2 with images, 1 empty placeholder)
/// - "حفظ وإتمام التسجيل" CTA button
/// - "بالنقر على حفظ، أنت توافق على شروط الانضمام لشركاء حرفة" link
/// - Progress bar at bottom: "اكتمل الملف بنسبة 65%"
/// - Bottom nav: الرئيسية, طلباتي, المحادثات, حسابي
class ProviderSetupScreen extends StatefulWidget {
  const ProviderSetupScreen({super.key});

  @override
  State<ProviderSetupScreen> createState() => _ProviderSetupScreenState();
}

class _ProviderSetupScreenState extends State<ProviderSetupScreen> {
  String? _selectedCraft;
  int _selectedNavIndex = 3; // حسابي active

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HerfaDrawer(),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(context),

          Expanded(
            child: SingleChildScrollView(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Hero card
                      _buildHeroCard(),
                      const SizedBox(height: 20),

                      // Craft type
                      _buildSectionLabel('نوع الحرفة'),
                      const SizedBox(height: 8),
                      _buildCraftDropdown(),
                      const SizedBox(height: 16),

                      // Experience years
                      _buildSectionLabel('سنوات الخبرة'),
                      const SizedBox(height: 8),
                      _buildExperienceField(),
                      const SizedBox(height: 16),

                      // Portfolio
                      _buildSectionLabel('معرض الأعمال'),
                      const SizedBox(height: 8),
                      _buildPortfolioUpload(),
                      const SizedBox(height: 12),
                      _buildPortfolioThumbnails(),
                      const SizedBox(height: 20),

                      // Save button
                      _buildSaveButton(context),
                      const SizedBox(height: 10),

                      // Terms link
                      Center(
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            'بالنقر على حفظ، أنت توافق على شروط الانضمام لشركاء حرفة',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Progress bar
                      _buildProgressBar(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom nav
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
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: Row(
        children: [
          // Female avatar
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

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Right side text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // "انضم إلينا" tag
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'انضم إلينا',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'مرحباً بكفي عالم\nالحرفيين المتميزين',
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontSize: 20,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                Text(
                  'أكمل ملفك الشخصي لتبدأ باستقبال طلبات العملاء في منطقتك. نحن نقدر مهاراتك.',
                  style: AppTextStyles.bodySmall.copyWith(height: 1.5),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Tool icon box
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.handyman,
              color: AppColors.primary,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(text, style: AppTextStyles.titleSmall),
    );
  }

  Widget _buildCraftDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCraft,
          hint: Text(
            'اختر حرفتك الأساسية',
            style: AppTextStyles.hintStyle,
            textDirection: TextDirection.rtl,
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textLight),
          alignment: Alignment.centerRight,
          items: const [
            DropdownMenuItem(
                value: 'plumbing',
                child: Text('سباكة', textDirection: TextDirection.rtl)),
            DropdownMenuItem(
                value: 'carpentry',
                child: Text('نجارة', textDirection: TextDirection.rtl)),
            DropdownMenuItem(
                value: 'electricity',
                child: Text('كهرباء', textDirection: TextDirection.rtl)),
            DropdownMenuItem(
                value: 'painting',
                child: Text('دهانات', textDirection: TextDirection.rtl)),
            DropdownMenuItem(
                value: 'hvac',
                child: Text('تكييف', textDirection: TextDirection.rtl)),
          ],
          onChanged: (v) => setState(() => _selectedCraft = v),
        ),
      ),
    );
  }

  Widget _buildExperienceField() {
    return TextField(
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      keyboardType: TextInputType.number,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'مثال: 5',
        hintStyle: AppTextStyles.hintStyle,
        suffixIcon: const Icon(
          Icons.school_outlined,
          color: AppColors.textLight,
          size: 20,
        ),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPortfolioUpload() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.textSecondary,
              size: 36,
            ),
            const SizedBox(height: 10),
            Text(
              'رفع صور معرض الأعمال',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'أضف أفضل 5 أعمال قمت بإنجازها مؤخراً',
              style: AppTextStyles.bodySmall,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioThumbnails() {
    return Row(
      children: [
        // Empty placeholder
        Expanded(
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.image_outlined,
                color: AppColors.textLight, size: 24),
          ),
        ),
        const SizedBox(width: 8),
        // Image placeholder 1
        Expanded(
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFD0D0D0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_drink_outlined,
                size: 30, color: Colors.white54),
          ),
        ),
        const SizedBox(width: 8),
        // Image placeholder 2
        Expanded(
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFBBBBBB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                size: 30, color: Colors.white54),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProviderHomeScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text('حفظ وإتمام التسجيل',
              style: AppTextStyles.labelLarge),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'اكتمل الملف بنسبة 65%',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.primary),
                textDirection: TextDirection.rtl,
              ),
              const Icon(Icons.check_circle_outline,
                  color: AppColors.primary, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.65,
              backgroundColor: AppColors.backgroundGrey,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.person_outline, 'label': 'حسابي'},
      {'icon': Icons.chat_bubble_outline, 'label': 'المحادثات'},
      {'icon': Icons.handyman_outlined, 'label': 'طلباتي'},
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
            children: items.asMap().entries.map((e) {
              final isActive = e.key == _selectedNavIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedNavIndex = e.key),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(e.value['icon'] as IconData,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textLight,
                        size: 22),
                    const SizedBox(height: 4),
                    Text(
                      e.value['label'] as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textLight,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                        fontSize: 11,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
