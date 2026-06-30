import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/services/supabase_service.dart';
import '../customer/booking_confirmation_screen.dart';
import '../shared/chat_screen.dart';

class CustomerMapProvidersScreen extends StatefulWidget {
  const CustomerMapProvidersScreen({super.key});

  @override
  State<CustomerMapProvidersScreen> createState() => _CustomerMapProvidersScreenState();
}

class _CustomerMapProvidersScreenState extends State<CustomerMapProvidersScreen> {
  int _selectedCategory = 2; // سباكة is default active
  int _selectedProviderIndex = 0;
  
  List<Map<String, dynamic>> _nearbyProviders = [];
  bool _loading = false;
  double _userLat = 30.0444;
  double _userLng = 31.2357;

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
    _fetchLocationAndProviders();
  }

  Future<void> _fetchLocationAndProviders() async {
    setState(() => _loading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        _userLat = pos.latitude;
        _userLng = pos.longitude;
      }
    } catch (_) {}

    try {
      final providers = await SupabaseService.instance.getNearbyProviders(
        userLat: _userLat,
        userLng: _userLng,
      );
      setState(() {
        _nearbyProviders = providers;
        _selectedProviderIndex = 0;
      });
    } catch (_) {} finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? selectedProvider = 
        _nearbyProviders.isNotEmpty && _selectedProviderIndex < _nearbyProviders.length
            ? _nearbyProviders[_selectedProviderIndex]
            : null;

    return Scaffold(
      drawer: const HerfaDrawer(),
      backgroundColor: AppColors.backgroundWhite,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _buildMapBackground(),
                ),

                // Search + categories header
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

                // Map Pins
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else
                  ..._buildProviderPins(),

                // Provider bottom card
                if (selectedProvider != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildProviderCard(context, selectedProvider),
                  )
                else if (!_loading)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'لا يوجد حرفيين بالقرب منك حالياً',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
            child: const Icon(Icons.person, color: AppColors.textSecondary, size: 22),
          ),
          const Spacer(),
          Text('خريطة الحرفيين', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary)),
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
    return CustomPaint(
      painter: _CityMapPainter(),
      child: Container(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Icon(Icons.search, color: AppColors.textLight, size: 20),
          ),
          Expanded(
            child: Text(
              'بحث باسم الحرفي أو الخدمة...',
              style: AppTextStyles.hintStyle,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildCategoryPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: _categories.asMap().entries.map((e) {
          final sel = e.key == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(left: 6),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppColors.accent : AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      e.value['label'],
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel ? AppColors.textWhite : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(e.value['icon'], size: 14, color: sel ? AppColors.textWhite : AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildProviderPins() {
    List<Widget> pins = [];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    for (int i = 0; i < _nearbyProviders.length; i++) {
      // Create mock screen location coordinate offsets spread out from center
      double top = (screenHeight * 0.3) + (i * 75) % 250;
      double left = (screenWidth * 0.25) + (i * 95) % (screenWidth * 0.5);

      final isSelected = _selectedProviderIndex == i;

      pins.add(
        Positioned(
          top: top,
          left: left,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedProviderIndex = i;
              });
            },
            child: _buildMapPin(size: isSelected ? 48 : 38, active: isSelected),
          ),
        ),
      );
    }
    return pins;
  }

  Widget _buildMapPin({double size = 38, bool active = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.backgroundWhite,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
        border: Border.all(color: active ? AppColors.textWhite : AppColors.primary, width: 2),
      ),
      child: Center(
        child: Icon(
          Icons.handyman,
          color: active ? AppColors.textWhite : AppColors.primary,
          size: size * 0.5,
        ),
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, Map<String, dynamic> provider) {
    final distance = provider['distance_km'] != null ? (provider['distance_km'] as double).toStringAsFixed(1) : '2.5';
    final name = provider['full_name'] ?? 'حرفي';
    final bio = provider['bio'] ?? 'خبير صيانة وحرف يدوية ممتازة في مصر';
    final rating = provider['rating']?.toString() ?? '4.8';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, -4),
          )
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: AppColors.starColor, size: 14),
                      const SizedBox(width: 3),
                      Text(rating, style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimary)),
                    ],
                  ),
                ),

                const Spacer(),

                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        bio,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('$distance كم', style: AppTextStyles.bodySmall),
                          const SizedBox(width: 3),
                          const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textLight),
                          const SizedBox(width: 8),
                          const Text('●', style: TextStyle(color: AppColors.greenAvailable, fontSize: 10)),
                          const SizedBox(width: 3),
                          Text(
                            'متاح الآن',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.greenAvailable),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(12),
                        image: provider['avatar_url'] != null
                            ? DecorationImage(image: NetworkImage(provider['avatar_url']), fit: BoxFit.cover)
                            : null,
                      ),
                      child: provider['avatar_url'] == null
                          ? const Icon(Icons.person, size: 40, color: AppColors.textLight)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'ممتاز',
                            style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textWhite),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5E3C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.my_location, color: AppColors.textWhite, size: 22),
                  ),
                ),

                const SizedBox(width: 10),

                // Message button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/chat',
                        arguments: {
                          'target_user_id': provider['id'],
                          'target_name': name,
                        },
                      );
                    },
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
                          const Icon(Icons.message_outlined, color: AppColors.textPrimary, size: 18),
                          const SizedBox(width: 6),
                          Text('مراسلة', style: AppTextStyles.labelMedium),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BookingConfirmationScreen(),
                          settings: RouteSettings(arguments: provider),
                        ),
                      );
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.textWhite, size: 16),
                          const SizedBox(width: 6),
                          Text('حجز موعد', style: AppTextStyles.labelLarge),
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
              _navItem(Icons.map_outlined, 'الرئيسية', true, () {}),
              _navItem(Icons.receipt_long_outlined, 'طلباتي', false, () {
                Navigator.pushReplacementNamed(context, '/bookings');
              }),
              _navItemWithBadge(Icons.chat_bubble_outline, 'الرسائل', false, () {
                Navigator.pushReplacementNamed(context, '/chat');
              }),
              _navItem(Icons.person_outline, 'حسابي', false, () {
                Navigator.pushReplacementNamed(context, '/profile');
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? AppColors.primary : AppColors.textLight, size: 22),
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
      ),
    );
  }

  Widget _navItemWithBadge(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: active ? AppColors.primary : AppColors.textLight, size: 22),
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
      ),
    );
  }
}

class _CityMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFE8ECEF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final roadBorderPaint = Paint()
      ..color = const Color(0xFFD0D6DC)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke;

    // Draw simple grid map layout representing street lines
    void drawStreet(Offset p1, Offset p2) {
      canvas.drawLine(p1, p2, roadBorderPaint);
      canvas.drawLine(p1, p2, roadPaint);
    }

    drawStreet(Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.35));
    drawStreet(Offset(0, size.height * 0.65), Offset(size.width, size.height * 0.55));
    drawStreet(Offset(size.width * 0.3, 0), Offset(size.width * 0.4, size.height));
    drawStreet(Offset(size.width * 0.7, 0), Offset(size.width * 0.75, size.height));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
