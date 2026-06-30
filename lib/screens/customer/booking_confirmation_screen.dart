import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/supabase_service.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _promoApplied = true;
  bool _cashOnDelivery = true;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 2));

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (pickedDate == null) return;

    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (pickedTime == null) return;

    setState(() {
      _selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _handleConfirmBooking(Map<String, dynamic> provider) async {
    setState(() => _isLoading = true);
    
    final hourlyRate = provider['hourly_rate'] != null ? (provider['hourly_rate'] as num).toDouble() : 150.0;
    final basePrice = hourlyRate * 2.0; // Estimate 2 hours
    final discount = _promoApplied ? basePrice * 0.10 : 0.0;
    final finalPrice = basePrice - discount;

    try {
      await SupabaseService.instance.createBooking(
        providerId: provider['id'],
        description: 'طلب خدمة صيانة منزلية - ${provider['skills'] ?? 'عامة'}',
        bookingDate: _selectedDate,
        totalPrice: finalPrice,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('نجاح الحجز', style: AppTextStyles.headlineSmall),
              content: const Text('تم تقديم الحجز بنجاح! وسيقوم الحرفي بمراجعة وتأكيد الموعد قريباً.', style: TextStyle(fontSize: 14)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx); // pop dialog
                    Navigator.pop(context); // pop confirmation screen
                  },
                  child: Text('موافق', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تقديم الحجز: ${e.toString()}', textAlign: TextAlign.right)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (provider == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(child: Text('لا توجد تفاصيل للحرفي المختار.')),
      );
    }

    final name = provider['full_name'] ?? 'حرفي حرفة';
    final skills = provider['skills'] ?? 'نجارة احترافية';
    final bio = provider['bio'] ?? 'خبير صيانة وحرف يدوية ممتازة في مصر';
    final hourlyRate = provider['hourly_rate'] != null ? (provider['hourly_rate'] as num).toDouble() : 150.0;
    
    final basePrice = hourlyRate * 2.0; // Estimate 2 hours
    final discount = _promoApplied ? basePrice * 0.10 : 0.0;
    final finalPrice = basePrice - discount;

    final dateFormatted = DateFormat('dd MMMM', 'ar').format(_selectedDate);
    final timeFormatted = DateFormat('hh:mm a', 'ar').format(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildServiceCard(name, skills, bio, provider['avatar_url']),
                      const SizedBox(height: 14),
                      _buildDateCard(dateFormatted, timeFormatted),
                      const SizedBox(height: 14),
                      _buildLocationRow(),
                      const SizedBox(height: 14),
                      _buildPromoSection(),
                      const SizedBox(height: 14),
                      _buildPaymentMethod(),
                      const SizedBox(height: 20),
                      
                      // Confirm button
                      GestureDetector(
                        onTap: _isLoading ? null : () => _handleConfirmBooking(provider),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isLoading)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: AppColors.textWhite, strokeWidth: 2),
                                )
                              else ...[
                                const Icon(Icons.bolt, color: AppColors.textWhite, size: 20),
                                const SizedBox(width: 8),
                                Text('تأكيد الحجز', style: AppTextStyles.labelLarge),
                              ]
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'بالنقر على تأكيد الحجز، أنت توافق على شروط الخدمة وسياسة الإلغاء',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _buildPriceBreakdown(basePrice, discount, finalPrice),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_forward, color: AppColors.textPrimary, size: 22),
          ),
          Text(
            'تأكيد الحجز',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
          ),
          const SizedBox(width: 22),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String name, String skills, String bio, String? avatarUrl) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(12),
              image: avatarUrl != null ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover) : null,
            ),
            child: avatarUrl == null ? const Icon(Icons.carpenter, size: 36, color: Colors.white38) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    skills,
                    style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.accent),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  bio,
                  style: AppTextStyles.headlineSmall.copyWith(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(name, style: AppTextStyles.bodySmall),
                    const SizedBox(width: 4),
                    const Icon(Icons.person_outline, size: 12, color: AppColors.textLight),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(String date, String time) {
    return GestureDetector(
      onTap: _pickDateTime,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.textWhite, size: 22),
            const SizedBox(height: 8),
            Text(
              'الموعد المحدد (اضغط للتعديل)',
              style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textWhite.withOpacity(0.75)),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textWhite),
            ),
            Text(
              time,
              style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textWhite.withOpacity(0.85)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {},
            child: Text('تعديل', style: AppTextStyles.accentLink),
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('موقع التنفيذ', style: AppTextStyles.titleSmall),
                  Text(
                    'حي الأرجس، القاهرة، مصر',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('كود الخصم', style: AppTextStyles.titleSmall),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _promoApplied = !_promoApplied),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'تطبيق',
                    style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textWhite),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'أدخل الكود هنا',
                    hintStyle: AppTextStyles.hintStyle,
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          if (_promoApplied) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'تم تطبيق خصم 10% (HERFA10)',
                    style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('طريقة الدفع', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _cashOnDelivery = true),
            child: Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _cashOnDelivery,
                  onChanged: (v) => setState(() => _cashOnDelivery = v ?? true),
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'الدفع عند الاستلام',
                        style: AppTextStyles.titleSmall,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.payments_outlined, color: AppColors.textSecondary, size: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(double base, double discount, double total) {
    return Column(
      children: [
        _priceRow('تقديري (ساعتين عمل)', '${base.toStringAsFixed(2)} ج.م'),
        const SizedBox(height: 8),
        if (_promoApplied) ...[
          _priceRow('خصم كود الترويجي (10%)', '-${discount.toStringAsFixed(2)} ج.م', valueColor: AppColors.success),
          const SizedBox(height: 8),
        ],
        const Divider(color: AppColors.border, height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${total.toStringAsFixed(2)} ج.م',
              style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            Text('الإجمالي الكلي', style: AppTextStyles.headlineSmall),
          ],
        ),
      ],
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor ?? AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}
