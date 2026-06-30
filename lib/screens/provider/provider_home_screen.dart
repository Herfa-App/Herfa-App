import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/services/supabase_service.dart';
import '../shared/chat_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});
  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  bool _isAvailable = false; // toggle متاح/مشغول
  int _selectedNavIndex = 0; // طلباتي
  List<Map<String, dynamic>> _bookings = [];
  bool _loadingBookings = false;

  @override
  void initState() {
    super.initState();
    _fetchAvailability();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _loadingBookings = true);
    try {
      final list = await SupabaseService.instance.getBookings();
      setState(() {
        _bookings = list;
      });
    } catch (_) {}
    finally {
      if (mounted) {
        setState(() => _loadingBookings = false);
      }
    }
  }

  void _showQuoteDialog(String bookingId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('تقديم عرض سعر للعميل', style: AppTextStyles.headlineSmall),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('أدخل قيمة تقديرية للعمل المطلوب:', style: AppTextStyles.bodySmall),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'السعر المقترح (ج.م)',
                  hintText: 'مثال: 150',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final price = double.tryParse(controller.text.trim());
                if (price != null && price > 0) {
                  Navigator.pop(ctx);
                  setState(() => _loadingBookings = true);
                  try {
                    await SupabaseService.instance.quoteBookingPrice(
                      bookingId: bookingId,
                      price: price,
                    );
                    await SupabaseService.instance.updateBookingStatus(
                      bookingId: bookingId,
                      newStatus: 'accepted',
                    );
                    _fetchBookings();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('فشل تقديم السعر: ${e.toString()}', textAlign: TextAlign.right)),
                    );
                  }
                }
              },
              child: const Text('إرسال عرض السعر والموافقة'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchAvailability() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final res = await Supabase.instance.client
            .from('providers')
            .select('is_available')
            .eq('id', user.id)
            .maybeSingle();
        if (res != null && mounted) {
          setState(() {
            _isAvailable = res['is_available'] ?? false;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _toggleAvailability() async {
    final newValue = !_isAvailable;
    setState(() => _isAvailable = newValue);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('providers')
            .update({'is_available': newValue})
            .eq('id', user.id);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isAvailable = !newValue);
      }
    }
  }

  String _selectedStatusTab = 'all';

  void _onNavTap(int i) {
    if (i == _selectedNavIndex) return;
    if (i == 3) {
      Navigator.pushReplacementNamed(context, '/profile');
    } else if (i == 2) {
      Navigator.pushReplacementNamed(context, '/chat');
    } else {
      setState(() => _selectedNavIndex = i);
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
                        actionLabel: 'تحديث الحجوزات',
                        onAction: _fetchBookings),
                    const SizedBox(height: 12),
                    _buildStatusFilterTabs(),
                    const SizedBox(height: 14),
                    if (_loadingBookings)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (filteredBookings.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'لا توجد طلبات واردة حالياً تطابق الفلتر',
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          final b = filteredBookings[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => _showRequestDetailsSheet(b),
                              child: _buildDynamicRequestCard(b),
                            ),
                          );
                        },
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

  Widget _buildStatusFilterTabs() {
    final tabs = [
      {'key': 'all', 'label': 'الكل'},
      {'key': 'pending', 'label': 'قيد الانتظار'},
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

  void _showRequestDetailsSheet(Map<String, dynamic> b) {
    final bookingId = b['id'] ?? '';
    final status = b['status'] ?? 'pending';
    final desc = b['description'] ?? '';
    final clientName = b['customer']?['full_name'] ?? 'عميل حرفة';
    final price = b['total_price'] != null ? '${(b['total_price'] as num).toStringAsFixed(0)} ج.م' : 'بانتظار تسعيرك';
    final dateStr = b['booking_date'];
    final address = b['location_address'] ?? 'غير محدد';
    final customerId = b['customer_id'];

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
    String statusText = 'قيد الانتظار';
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
                  Text('تفاصيل طلب الخدمة', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
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
              _detailRow(Icons.person_outline, 'اسم العميل', clientName),
              _detailRow(Icons.calendar_today_outlined, 'الموعد المقترح', formattedDate),
              _detailRow(Icons.location_on_outlined, 'موقع العمل', address),
              _detailRow(Icons.monetization_on_outlined, 'السعر المعروض', price),
              const SizedBox(height: 12),
              Text('وصف المشكلة / الخدمة المطلوبة:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
                  if (status == 'pending') ...[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showQuoteDialog(bookingId);
                        },
                        child: Text('قبول وتقديم سعر', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          setState(() => _loadingBookings = true);
                          try {
                            await SupabaseService.instance.updateBookingStatus(bookingId: bookingId, newStatus: 'rejected');
                            _fetchBookings();
                          } catch (_) {
                            setState(() => _loadingBookings = false);
                          }
                        },
                        child: Text('رفض الطلب', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ] else if (status == 'accepted') ...[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          setState(() => _loadingBookings = true);
                          try {
                            await SupabaseService.instance.updateBookingStatus(bookingId: bookingId, newStatus: 'completed');
                            _fetchBookings();
                          } catch (_) {
                            setState(() => _loadingBookings = false);
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
                          'target_user_id': customerId,
                          'target_name': clientName,
                        });
                      },
                      label: Text('مراسلة العميل', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
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
            onTap: _toggleAvailability,
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

  Widget _buildDynamicRequestCard(Map<String, dynamic> b) {
    final bookingId = b['id'] ?? '';
    final status = b['status'] ?? 'pending';
    final desc = b['description'] ?? '';
    final clientName = b['customer']?['full_name'] ?? 'عميل حرفة';
    final price = b['total_price'] != null ? '${(b['total_price'] as num).toStringAsFixed(0)} ج.م' : 'بانتظار عرض السعر';
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
    String statusText = 'قيد الانتظار';
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(clientName,
              style: AppTextStyles.titleSmall
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: statusColor.withOpacity(0.3))),
            child: Text(statusText,
                style: GoogleFonts.cairo(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: statusColor)),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.access_time, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Text(formattedDate, style: AppTextStyles.bodySmall),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.monetization_on_outlined, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text('السعر: $price',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 10),
        Text('تفاصيل الطلب:',
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(desc,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 12),
        if (status == 'pending')
          Row(children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onPressed: () => _showQuoteDialog(bookingId),
                child: Text('تقديم تسعير وقبول', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onPressed: () async {
                  setState(() => _loadingBookings = true);
                  try {
                    await SupabaseService.instance.updateBookingStatus(bookingId: bookingId, newStatus: 'rejected');
                    _fetchBookings();
                  } catch (_) {
                    setState(() => _loadingBookings = false);
                  }
                },
                child: Text('رفض الطلب', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ])
        else if (status == 'accepted')
          Row(children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onPressed: () async {
                  setState(() => _loadingBookings = true);
                  try {
                    await SupabaseService.instance.updateBookingStatus(bookingId: bookingId, newStatus: 'completed');
                    _fetchBookings();
                  } catch (_) {
                    setState(() => _loadingBookings = false);
                  }
                },
                child: Text('تأكيد إتمام العمل', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
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
