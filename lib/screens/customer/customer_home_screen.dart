import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/services/supabase_service.dart';
import '../customer/filter_screen.dart';
import '../customer/provider_profile_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});
  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _navIndex = 0;
  int _selectedCategory = 2;
  
  List<Map<String, dynamic>> _nearbyProviders = [];
  bool _loadingProviders = false;

  static const List<BottomNavItem> _navItems = [
    BottomNavItem(icon: Icons.person_outline,           label: 'الملف'),
    BottomNavItem(icon: Icons.chat_bubble_outline,      label: 'محادثة'),
    BottomNavItem(icon: Icons.calendar_today_outlined,  label: 'الحجوزات'),
    BottomNavItem(icon: Icons.receipt_long_outlined,    label: 'الأسعار'),
    BottomNavItem(icon: Icons.home_outlined,            label: 'الرئيسية'),
  ];

  void _onNavTap(int i) {
    setState(() => _navIndex = i);
    switch (i) {
      case 0:
        Navigator.pushNamed(context, '/profile')
            .then((_) => setState(() => _navIndex = 4));
        break;
      case 1:
        Navigator.pushNamed(context, '/chat')
            .then((_) => setState(() => _navIndex = 4));
        break;
      case 2:
        Navigator.pushNamed(context, '/bookings')
            .then((_) => setState(() => _navIndex = 4));
        break;
      case 3:
        Navigator.pushNamed(context, '/prices')
            .then((_) => setState(() => _navIndex = 4));
        break;
      case 4:
        setState(() => _navIndex = 4);
        break;
    }
  }

  final List<Map<String, dynamic>> _categories = const [
    {'label': 'دهانات',  'icon': Icons.format_paint_outlined},
    {'label': 'كهرباء',  'icon': Icons.electrical_services_outlined},
    {'label': 'سباكة',   'icon': Icons.plumbing_outlined},
    {'label': 'نجارة',   'icon': Icons.carpenter_outlined},
    {'label': 'تنظيف',   'icon': Icons.cleaning_services_outlined},
    {'label': 'تكييف',   'icon': Icons.ac_unit_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _navIndex = 4;
    _fetchNearbyProviders();
  }

  Future<void> _fetchNearbyProviders() async {
    setState(() => _loadingProviders = true);
    try {
      double lat = 30.0444;
      double lng = 31.2357;

      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 4),
          );
          lat = pos.latitude;
          lng = pos.longitude;
        }
      } catch (_) {}

      final providers = await SupabaseService.instance.getNearbyProviders(
        userLat: lat,
        userLng: lng,
      );
      setState(() {
        _nearbyProviders = providers;
      });
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _loadingProviders = false);
      }
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ماذا تريد أن تنجز اليوم؟',
                            style: AppTextStyles.displayLarge
                                .copyWith(fontSize: 26, height: 1.3),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'ابحث عن أفضل الحرفيين في منطقتك بلمسة واحدة',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSearchBar(context),
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSuggestionsSection(context),
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildNearbyProvidersList(),
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildRecentSearches(),
                    ),
                    const SizedBox(height: 28),
                    _buildCategories(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          HerfaBottomNav(
            currentIndex: _navIndex,
            items: _navItems,
            onTap: _onNavTap,
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
        left: 16, right: 16, bottom: 8,
      ),
      child: Row(
        children: [
          const SizedBox(width: 48), // Balancing hamburger icon
          const Spacer(),
          Text('حرفة', style: AppTextStyles.brandTitle.copyWith(fontSize: 22)),
          const Spacer(),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/filter'),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 14),
              child: Icon(Icons.search, color: AppColors.textLight, size: 22),
            ),
            Expanded(
              child: Text('مثلاً: فني سـ...',
                  style: AppTextStyles.hintStyle,
                  textAlign: TextAlign.right),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('اقتراحات ذكية', style: AppTextStyles.headlineSmall),
          const SizedBox(width: 6),
          const Text('✨', style: TextStyle(fontSize: 18)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: _SuggestionCard(
              badge: 'الأكثر طلباً',
              title: 'فني كهرباء',
              height: 170,
              badgeColor: AppColors.accent,
              onTap: () => Navigator.pushNamed(context, '/provider'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SuggestionCard(
              badge: 'ممتاز للسباكة',
              title: 'صيانة سباكة',
              height: 170,
              badgeColor: AppColors.primaryLight,
              onTap: () => Navigator.pushNamed(context, '/provider'),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        _SuggestionCard(
          badge: 'جديد',
          title: 'صيانة مطابخ متكاملة',
          subtitle: 'تحديد وصيانة السباكة والرخام',
          height: 155,
          badgeColor: AppColors.success,
          isFullWidth: true,
          onTap: () => Navigator.pushNamed(context, '/provider'),
        ),
      ],
    );
  }

  Widget _buildNearbyProvidersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الحرفيين القريبين منك',
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: 12),
        if (_loadingProviders)
          const Center(child: CircularProgressIndicator())
        else if (_nearbyProviders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'لا يوجد حرفيين متاحين بالقرب منك حالياً',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _nearbyProviders.length,
            itemBuilder: (context, index) {
              final p = _nearbyProviders[index];
              final distance = p['distance_km'] != null ? (p['distance_km'] as double).toStringAsFixed(1) : '?';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Text(
                      '${distance} كم',
                      style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(p['full_name'] ?? 'حرفي', style: AppTextStyles.titleSmall),
                        Text(p['skills'] ?? 'عامة', style: AppTextStyles.bodySmall),
                      ],
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      backgroundImage: p['avatar_url'] != null ? NetworkImage(p['avatar_url']) : null,
                      child: p['avatar_url'] == null ? const Icon(Icons.person) : null,
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildRecentSearches() {
    final searches = [
      {'title': 'تصليح تسربات مياه',    'time': 'منذ يومين'},
      {'title': 'دهانات جدران داخلية',   'time': 'الأسبوع الماضي'},
      {'title': 'نجار تركيب غرف نوم',    'time': 'منذ 3 ساعات'},
    ];
    return Column(children: [
      SectionHeader(
          title: 'عمليات البحث الأخيرة',
          actionLabel: 'مسح الكل',
          onAction: () {}),
      const SizedBox(height: 12),
      ...searches.map((s) =>
          _RecentSearchRow(title: s['title']!, time: s['time']!)),
    ]);
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('تصفح الفئات', style: AppTextStyles.headlineSmall),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: _categories.asMap().entries.map((e) {
              final sel = e.key == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = e.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.accent : AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: sel ? AppColors.accent : AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(e.value['label'],
                            style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: sel
                                    ? AppColors.textWhite
                                    : AppColors.textPrimary)),
                        const SizedBox(width: 4),
                        Icon(e.value['icon'],
                            size: 15,
                            color: sel
                                ? AppColors.textWhite
                                : AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String badge;
  final String title;
  final String? subtitle;
  final double height;
  final Color badgeColor;
  final bool isFullWidth;
  final VoidCallback? onTap;

  const _SuggestionCard({
    required this.badge,
    required this.title,
    required this.height,
    required this.badgeColor,
    this.subtitle,
    this.isFullWidth = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: isFullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.35),
              AppColors.primaryDark.withOpacity(0.9),
            ],
          ),
        ),
        child: Stack(children: [
          Positioned(
            top: 10, right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: badgeColor, borderRadius: BorderRadius.circular(20)),
              child: Text(badge,
                  style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textWhite)),
            ),
          ),
          Positioned(
            bottom: 12, right: 12, left: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle != null) ...[
                  Text(subtitle!,
                      style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: AppColors.textWhite.withOpacity(0.8)),
                      textDirection: TextDirection.rtl),
                  const SizedBox(height: 2),
                ],
                Text(title,
                    style: GoogleFonts.cairo(
                        fontSize: isFullWidth ? 20 : 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite),
                    textDirection: TextDirection.rtl),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _RecentSearchRow extends StatelessWidget {
  final String title;
  final String time;
  const _RecentSearchRow({required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.arrow_back_ios, size: 14, color: AppColors.textLight),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(title, style: AppTextStyles.titleSmall,
              textDirection: TextDirection.rtl),
          Text(time, style: AppTextStyles.bodySmall,
              textDirection: TextDirection.rtl),
        ]),
        const SizedBox(width: 12),
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(
              color: AppColors.backgroundGrey, shape: BoxShape.circle),
          child: const Icon(Icons.history, color: AppColors.primary, size: 18),
        ),
      ]),
    );
  }
}
