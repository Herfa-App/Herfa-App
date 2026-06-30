import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/services/supabase_service.dart';
import 'booking_confirmation_screen.dart';

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
  double _userLat = 31.2653; // Default to Port Said coordinates (since user is there)
  double _userLng = 32.3019;
  late TransformationController _transformationController;

  final List<Map<String, dynamic>> _categories = const [
    {'label': 'دهانات',  'icon': Icons.format_paint_outlined},
    {'label': 'كهرباء',  'icon': Icons.electrical_services_outlined},
    {'label': 'سباكة',   'icon': Icons.plumbing_outlined},
    {'label': 'نجارة',   'icon': Icons.carpenter_outlined},
    {'label': 'تنظيف',   'icon': Icons.cleaning_services_outlined},
    {'label': 'تكييف',   'icon': Icons.ac_unit_outlined},
  ];

  List<Map<String, dynamic>> get _filteredProviders {
    final filterArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    String categoryLabel = _categories[_selectedCategory]['label'] ?? '';
    
    if (filterArgs != null && filterArgs.containsKey('category')) {
      final filterCat = filterArgs['category'] as String;
      final idx = _categories.indexWhere((c) => c['label'] == filterCat);
      if (idx != -1 && idx != _selectedCategory) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _selectedCategory = idx;
              filterArgs.remove('category');
            });
          }
        });
      }
    }

    var list = _nearbyProviders.where((p) {
      final skill = p['skills'] ?? '';
      return skill.toString().contains(categoryLabel);
    }).toList();

    if (filterArgs != null) {
      final minPrice = filterArgs['minPrice'] as double?;
      final maxPrice = filterArgs['maxPrice'] as double?;
      if (minPrice != null && maxPrice != null) {
        list = list.where((p) {
          final rate = double.tryParse(p['hourly_rate']?.toString() ?? '0') ?? 0.0;
          return rate >= minPrice && rate <= maxPrice;
        }).toList();
      }

      final distIndex = filterArgs['distance'] as int?;
      if (distIndex != null) {
        double maxDist = 999.0;
        if (distIndex == 1) maxDist = 10.0;
        else if (distIndex == 2) maxDist = 5.0;
        list = list.where((p) {
          final dist = double.tryParse(p['distance_km']?.toString() ?? '0') ?? 0.0;
          return dist <= maxDist;
        }).toList();
      }

      final sortIndex = filterArgs['sort'] as int?;
      if (sortIndex != null) {
        if (sortIndex == 0) {
          list.sort((a, b) => (a['distance_km'] ?? 0.0).compareTo(b['distance_km'] ?? 0.0));
        } else if (sortIndex == 1) {
          list.sort((a, b) => (b['experience_years'] ?? 0).compareTo(a['experience_years'] ?? 0));
        } else if (sortIndex == 2) {
          list.sort((a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0));
        } else if (sortIndex == 3) {
          list.sort((a, b) => (b['is_available'] == true ? 1 : 0).compareTo(a['is_available'] == true ? 1 : 0));
        }
      }
    }

    return list;
  }

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    // Center transformation matrix on the 1500x1500px map area
    _transformationController.value = Matrix4.translationValues(-560.0, -560.0, 1.0);
    _fetchLocationAndProviders();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
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

    // Read distance parameter from search filters
    double maxDist = 150.0; // default to 150 km to find nearby workers
    final filterArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (filterArgs != null) {
      final distIndex = filterArgs['distance'] as int?;
      if (distIndex != null) {
        if (distIndex == 1) maxDist = 10.0;
        else if (distIndex == 2) maxDist = 5.0;
        else maxDist = 350.0; // 20+ km
      }
    }

    try {
      final providers = await SupabaseService.instance.getNearbyProviders(
        userLat: _userLat,
        userLng: _userLng,
        maxDistanceKm: maxDist,
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
        _filteredProviders.isNotEmpty && _selectedProviderIndex < _filteredProviders.length
            ? _filteredProviders[_selectedProviderIndex]
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
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    maxScale: 3.0,
                    minScale: 0.5,
                    boundaryMargin: const EdgeInsets.all(1000),
                    child: Stack(
                      children: [
                        _buildMapBackground(),
                        if (!_loading)
                          ..._buildProviderPins(),
                      ],
                    ),
                  ),
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

                // Loading indicator
                if (_loading)
                  const Center(child: CircularProgressIndicator()),

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
    return SizedBox(
      width: 1500,
      height: 1500,
      child: CustomPaint(
        painter: _CityMapPainter(userLat: _userLat, userLng: _userLng),
        child: Container(),
      ),
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
              onTap: () => setState(() {
                _selectedCategory = e.key;
                _selectedProviderIndex = 0;
              }),
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
    final mapWidth = 1500.0;
    final mapHeight = 1500.0;

    final list = _filteredProviders;
    final centerLat = _userLat;
    final centerLng = _userLng;

    for (int i = 0; i < list.length; i++) {
      final p = list[i];
      final lat = double.tryParse(p['latitude']?.toString() ?? '') ?? centerLat;
      final lng = double.tryParse(p['longitude']?.toString() ?? '') ?? centerLng;

      // Coordinate offset projection (approx 1 degree = 6000 logical map pixels)
      final dLat = lat - centerLat;
      final dLng = lng - centerLng;

      double left = (mapWidth * 0.5) + (dLng * 8000.0);
      double top = (mapHeight * 0.5) - (dLat * 8000.0); // Y-axis is inverted

      left = left.clamp(60.0, mapWidth - 60.0);
      top = top.clamp(60.0, mapHeight - 60.0);

      final isSelected = _selectedProviderIndex == i;

      pins.add(
        Positioned(
          top: top - (isSelected ? 24 : 19),
          left: left - (isSelected ? 24 : 19),
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

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/provider', arguments: provider);
              },
              child: Row(
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
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: provider['avatar_url'] != null
                              ? Image.network(
                                  provider['avatar_url'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(Icons.person, size: 40, color: AppColors.textLight),
                                )
                              : const Icon(Icons.person, size: 40, color: AppColors.textLight),
                        ),
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
                          builder: (_) => BookingConfirmationScreen(),
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
                Navigator.pushReplacementNamed(context, '/requests');
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
  final double userLat;
  final double userLng;

  const _CityMapPainter({this.userLat = 31.2653, this.userLng = 32.3019});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ── Background (land colour)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFF0EDE6),
    );

    // ── Suez Canal / water strip (Port Said is at canal mouth)
    final waterPaint = Paint()..color = const Color(0xFF9EC8E8);
    canvas.drawRect(Rect.fromLTWH(cx + 220, 0, 90, size.height), waterPaint);
    // Mediterranean sea at top
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, cy - 300), Paint()..color = const Color(0xFF7FB8D8));
    // Beach / shoreline
    canvas.drawRect(Rect.fromLTWH(0, cy - 300, size.width, 20), Paint()..color = const Color(0xFFD4C89A));

    // ── Block builder helper
    void block(double x, double y, double w, double h, Color c) {
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h), const Radius.circular(4));
      canvas.drawRRect(rr, Paint()..color = c);
    }

    // ── City blocks (residential/commercial)
    const blockA = Color(0xFFD9D0C5);
    const blockB = Color(0xFFCFC6BC);
    const parkC  = Color(0xFFB8D8B0);

    // Grid of city blocks around centre
    for (int row = -4; row <= 4; row++) {
      for (int col = -6; col <= 6; col++) {
        final bx = cx + col * 110.0;
        final by = cy + row * 110.0;
        if (by < cy - 290) continue; // below sea
        if ((col == 2 || col == 3) && row.abs() < 4) continue; // leave canal open
        final isGreen = (row.abs() == 2 && col.abs() == 2);
        block(bx - 40, by - 40, 76, 76, isGreen ? parkC : (col.isOdd ? blockA : blockB));
      }
    }

    // ── Roads (border then fill)
    final borderP = Paint()
      ..color = const Color(0xFFB0A898)
      ..strokeWidth = 22
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final roadP = Paint()
      ..color = const Color(0xFFFFFDF8)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final mainRoadP = Paint()
      ..color = const Color(0xFFFFF8E8)
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final mainBorderP = Paint()
      ..color = const Color(0xFFE8C87A)
      ..strokeWidth = 28
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    void road(Offset a, Offset b, {bool main = false}) {
      canvas.drawLine(a, b, main ? mainBorderP : borderP);
      canvas.drawLine(a, b, main ? mainRoadP : roadP);
    }

    // Horizontal roads (grid)
    for (int r = -4; r <= 4; r++) {
      final y = cy + r * 110.0;
      if (y < cy - 285) continue;
      road(Offset(0, y), Offset(size.width, y), main: r == 0 || r == -2);
    }
    // Vertical roads (grid)
    for (int c = -6; c <= 6; c++) {
      final x = cx + c * 110.0;
      road(Offset(x, cy - 285), Offset(x, size.height), main: c == 0 || c == -3);
    }

    // ── User location indicator (blue pulsing circle)
    // User is always at canvas centre
    canvas.drawCircle(Offset(cx, cy), 24, Paint()..color = const Color(0x330A6EBD));
    canvas.drawCircle(Offset(cx, cy), 12, Paint()..color = const Color(0xFF1A7FCF));
    canvas.drawCircle(Offset(cx, cy), 7, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(cx, cy), 6,
      Paint()..color = const Color(0xFF1A7FCF),
    );

    // ── Port Said label
    final tp = TextPainter(
      text: const TextSpan(
        text: 'بورسعيد',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4A4040),
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy + 30));
  }

  @override
  bool shouldRepaint(covariant _CityMapPainter old) =>
      old.userLat != userLat || old.userLng != userLng;
}
