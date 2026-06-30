import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import "../../core/widgets/shared_widgets.dart";
import '../customer/customer_map_providers_screen.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  int _selectedSort = 0;
  double _minPrice = 150;
  double _maxPrice = 800;
  int _selectedSpec = 3;
  int _selectedDistance = 1;

  final List<String> _sortOptions = [
    'الأقرب فالأبعد', 'الأكثر خبرة', 'الأعلى تقييماً', 'المتاح حالياً',
  ];
  final List<IconData> _sortIcons = [
    Icons.location_on_outlined,
    Icons.workspace_premium_outlined,
    Icons.star_outline,
    Icons.access_time_outlined,
  ];
  final List<String> _specs = ['تكييف', 'نجارة', 'سباكة', 'كهرباء', 'دهانات'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary.withOpacity(0.15),
      drawer: const HerfaDrawer(),
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() {
                              _selectedSort = 0;
                              _minPrice = 150;
                              _maxPrice = 800;
                              _selectedSpec = 3;
                              _selectedDistance = 1;
                            }),
                            child: Text('إعادة ضبط',
                                style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary)),
                          ),
                          Text('تصفية النتائج',
                              style: AppTextStyles.headlineMedium),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSectionLabel('ترتيب حسب'),
                      const SizedBox(height: 12),
                      _buildSortGrid(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_minPrice.toInt()} - ${_maxPrice.toInt()}',
                            style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent),
                          ),
                          Text('نطاق السعر (جنيه)',
                              style: AppTextStyles.titleSmall),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildPriceSlider(),
                      const SizedBox(height: 24),
                      _buildSectionLabel('التخصص المطلوب'),
                      const SizedBox(height: 12),
                      _buildSpecChips(),
                      const SizedBox(height: 24),
                      _buildSectionLabel('المسافة القصوى'),
                      const SizedBox(height: 12),
                      _buildDistanceChips(),
                      const SizedBox(height: 28),
                      GestureDetector(
                        onTap: () {
                          final selectedCategoryLabel = _specs[_selectedSpec];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: RouteSettings(
                                arguments: {
                                  'category': selectedCategoryLabel,
                                  'sort': _selectedSort,
                                  'minPrice': _minPrice,
                                  'maxPrice': _maxPrice,
                                  'distance': _selectedDistance,
                                },
                              ),
                              builder: (_) => const CustomerMapProvidersScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14)),
                          child: Center(
                            child: Text('عرض النتائج',
                                style: AppTextStyles.labelLarge),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: const Color(0xFF1A2B4A),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 8, left: 16, right: 16,
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: const BoxDecoration(
                color: AppColors.backgroundGrey, shape: BoxShape.circle),
            child: const Icon(Icons.person,
                color: AppColors.textSecondary, size: 22),
          ),
          const Spacer(),
          Text('حرفة',
              style: AppTextStyles.brandTitle
                  .copyWith(fontSize: 22, color: AppColors.backgroundWhite)),
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

  Widget _buildSectionLabel(String text) => Align(
        alignment: Alignment.centerRight,
        child: Text(text, style: AppTextStyles.titleMedium),
      );

  Widget _buildSortGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.8,
      children: _sortOptions.asMap().entries.map((e) {
        final isSelected = e.key == _selectedSort;
        return GestureDetector(
          onTap: () => setState(() => _selectedSort = e.key),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.08)
                  : AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 1.5 : 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(e.value,
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary),
                    textDirection: TextDirection.rtl),
                const SizedBox(width: 6),
                Icon(_sortIcons[e.key],
                    size: 16,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceSlider() {
    return Column(
      children: [
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 50, max: 2000,
          onChanged: (v) =>
              setState(() { _minPrice = v.start; _maxPrice = v.end; }),
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('200+',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textLight)),
            Text('50',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textLight)),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecChips() {
    return Wrap(
      spacing: 8, runSpacing: 8,
      textDirection: TextDirection.rtl,
      children: _specs.asMap().entries.map((e) {
        final isSelected = e.key == _selectedSpec;
        return GestureDetector(
          onTap: () => setState(() => _selectedSpec = e.key),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent : AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check,
                      color: AppColors.textWhite, size: 14),
                  const SizedBox(width: 4),
                ],
                Text(e.value,
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.textWhite
                            : AppColors.textPrimary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDistanceChips() {
    final labels = ['20+ كم', '10 كم', '5 كم'];
    return Row(
      children: labels.asMap().entries.map((e) {
        final isSelected = e.key == _selectedDistance;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: e.key == 2 ? 0 : 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedDistance = e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.06)
                      : AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1),
                ),
                child: Center(
                  child: Text(e.value,
                      style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary)),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    // ✅ RTL order, no textDirection on Row
    final items = [
      {'icon': Icons.person_outline,   'label': 'حسابي'},
      {'icon': Icons.chat_bubble_outline, 'label': 'المحادثات'},
      {'icon': Icons.handyman_outlined, 'label': 'طلباتي'},
      {'icon': Icons.home_outlined,    'label': 'الرئيسية'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((e) {
              final isActive = e.key == 3;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(e.value['icon'] as IconData,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textLight,
                      size: 22),
                  const SizedBox(height: 4),
                  Text(e.value['label'] as String,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textLight,
                          fontSize: 11),
                      textDirection: TextDirection.rtl),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
