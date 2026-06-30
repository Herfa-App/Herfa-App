import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/services/supabase_service.dart';

class CustomerBookingsListScreen extends StatefulWidget {
  const CustomerBookingsListScreen({super.key});

  @override
  State<CustomerBookingsListScreen> createState() => _CustomerBookingsListScreenState();
}

class _CustomerBookingsListScreenState extends State<CustomerBookingsListScreen> {
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = false;
  int _navIndex = 2; // الحجوزات active
  String _selectedStatusTab = 'all';

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(icon: Icons.person_outline,           label: 'الملف'),
    BottomNavItem(icon: Icons.chat_bubble_outline,      label: 'محادثة'),
    BottomNavItem(icon: Icons.calendar_today,           label: 'الحجوزات'),
    BottomNavItem(icon: Icons.receipt_long_outlined,    label: 'الأسعار'),
    BottomNavItem(icon: Icons.home_outlined,            label: 'الرئيسية'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final list = await SupabaseService.instance.getBookings();
      if (mounted) {
        setState(() {
          _bookings = list;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _onNavTap(int i) {
    if (i == _navIndex) return;
    setState(() => _navIndex = i);
    switch (i) {
      case 0:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/chat');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/prices');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/home');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings = _bookings.where((b) {
      if (_selectedStatusTab == 'all') return true;
      return b['status'] == _selectedStatusTab;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const HerfaDrawer(),
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchBookings,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'طلبات الصيانة الخاصة بك',
                          style: AppTextStyles.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        _buildStatusFilterTabs(),
                        const SizedBox(height: 14),
                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (filteredBookings.isEmpty)
                          _buildEmptyState()
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredBookings.length,
                            itemBuilder: (context, index) {
                              final b = filteredBookings[index];
                              return GestureDetector(
                                onTap: () => _showBookingDetailsSheet(b),
                                child: _buildBookingCard(b),
                              );
                            },
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
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

  Widget _buildStatusFilterTabs() {
    final tabs = [
      {'key': 'all', 'label': 'الكل'},
      {'key': 'pending', 'label': 'قيد المراجعة'},
      {'key': 'accepted', 'label': 'قيد التنفيذ'},
      {'key': 'completed', 'label': 'مكتمل'},
      {'key': 'rejected', 'label': 'مرفوض'},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: tabs.map((t) {
          final isSel = _selectedStatusTab == t['key'];
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(t['label']!, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: isSel ? Colors.white : AppColors.textPrimary)),
              selected: isSel,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.backgroundGrey,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedStatusTab = t['key']!);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showBookingDetailsSheet(Map<String, dynamic> b) {
    final status = b['status'] ?? 'pending';
    final desc = b['description'] ?? '';
    final rate = b['total_price'] != null ? '${(b['total_price'] as num).toStringAsFixed(0)} ج.م' : 'بانتظار تسعير الحرفي';
    final providerName = b['provider']?['full_name'] ?? 'حرفي حرفة';
    final dateStr = b['booking_date'];
    final address = b['location_address'] ?? 'غير محدد';
    final providerId = b['provider_id'];

    String formattedDate = '';
    if (dateStr != null) {
      try {
        final date = DateTime.parse(dateStr);
        formattedDate = DateFormat('dd MMMM yyyy - hh:mm a', 'ar').format(date);
      } catch (_) {
        formattedDate = dateStr;
      }
    }

    Color statusColor = AppColors.primary;
    String statusText = 'قيد المراجعة';
    if (status == 'accepted') {
      statusColor = AppColors.success;
      statusText = 'مقبول - قيد التنفيذ';
    } else if (status == 'rejected') {
      statusColor = AppColors.error;
      statusText = 'مرفوض';
    } else if (status == 'completed') {
      statusColor = Colors.green;
      statusText = 'مكتمل ✓';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('تفاصيل الحجز', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(statusText, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _detailRow(Icons.person_outline, 'اسم الحرفي', providerName),
              _detailRow(Icons.calendar_today_outlined, 'موعد الحجز', formattedDate),
              _detailRow(Icons.location_on_outlined, 'موقع التنفيذ', address),
              _detailRow(Icons.monetization_on_outlined, 'القيمة الإجمالية', rate),
              const SizedBox(height: 12),
              Text('وصف المشكلة / الطلب:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(desc, style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (status == 'accepted') ...[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          setState(() => _loading = true);
                          try {
                            await SupabaseService.instance.updateBookingStatus(bookingId: b['id'], newStatus: 'completed');
                            _fetchBookings();
                          } catch (e) {
                            setState(() => _loading = false);
                          }
                        },
                        child: Text('تأكيد إتمام العمل', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamed(context, '/chat', arguments: {
                          'target_user_id': providerId,
                          'target_name': providerName,
                        });
                      },
                      label: Text('مراسلة الحرفي', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('$label: ', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          Expanded(child: Text(value, style: GoogleFonts.cairo(color: AppColors.textPrimary))),
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
          const SizedBox(width: 48), // Spacer to balance menu button
          const Spacer(),
          Text(
            'طلباتي',
            style: AppTextStyles.brandTitle.copyWith(fontSize: 22),
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(
            'لا توجد حجوزات نشطة حالياً',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بتصفح الحرفيين القريبين واحجز موعد صيانة الآن.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> b) {
    final status = b['status'] ?? 'pending';
    final desc = b['description'] ?? '';
    final rate = b['total_price'] != null ? '${(b['total_price'] as num).toStringAsFixed(0)} ج.م' : 'بانتظار تسعير الحرفي';
    final providerName = b['provider']?['full_name'] ?? 'حرفي حرفة';
    final dateStr = b['booking_date'];
    
    String formattedDate = '';
    if (dateStr != null) {
      try {
        final date = DateTime.parse(dateStr);
        formattedDate = DateFormat('dd MMMM yyyy - hh:mm a', 'ar').format(date);
      } catch (_) {
        formattedDate = dateStr;
      }
    }

    Color statusColor = AppColors.primary;
    String statusText = 'قيد المراجعة';
    if (status == 'accepted') {
      statusColor = AppColors.success;
      statusText = 'مقبول - قيد التنفيذ';
    } else if (status == 'rejected') {
      statusColor = AppColors.error;
      statusText = 'مرفوض';
    } else if (status == 'completed') {
      statusColor = Colors.green;
      statusText = 'مكتمل ✓';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                providerName,
                style: AppTextStyles.titleSmall.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: AppColors.textLight),
              const SizedBox(width: 6),
              Text(
                formattedDate,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.monetization_on_outlined, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'عرض السعر: $rate',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),
          Text(
            'تفاصيل المشكلة:',
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: AppTextStyles.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
