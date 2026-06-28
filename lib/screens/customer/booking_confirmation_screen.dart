import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Screen 13 — Booking Confirmation Screen (تأكيد الحجز)
/// Analysis:
/// - Header: back arrow (→), "تأكيد الحجز" title in blue
/// - Service card: category tag, service name, provider name, image
/// - Dark blue date card: calendar icon, "الموعد المحدد", date, time
/// - Location row: pin icon, address, "تعديل" link
/// - Promo code section: orange "تطبيق" button, input field, success message
/// - Payment method: radio + "الدفع عند الاستلام"
/// - "تأكيد الحجز" CTA button with bolt icon
/// - Price breakdown: original, discount, total
class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends State<BookingConfirmationScreen> {
  bool _promoApplied = true;
  bool _cashOnDelivery = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Service card
                      _buildServiceCard(),
                      const SizedBox(height: 14),

                      // Date card
                      _buildDateCard(),
                      const SizedBox(height: 14),

                      // Location
                      _buildLocationRow(),
                      const SizedBox(height: 14),

                      // Promo code
                      _buildPromoSection(),
                      const SizedBox(height: 14),

                      // Payment method
                      _buildPaymentMethod(),
                      const SizedBox(height: 20),

                      // Confirm button
                      _buildConfirmButton(context),
                      const SizedBox(height: 6),

                      Text(
                        'بالنقر على تأكيد الحجز، أنت توافق على شروط الخدمة وسياسة الإلغاء',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      // Price breakdown
                      _buildPriceBreakdown(),

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
            child: const Icon(Icons.arrow_forward,
                color: AppColors.textPrimary, size: 22),
          ),
          Text(
            'تأكيد الحجز',
            style: AppTextStyles.headlineSmall
                .copyWith(color: AppColors.primary),
          ),
          const SizedBox(width: 22),
        ],
      ),
    );
  }

  Widget _buildServiceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.carpenter,
                size: 36, color: Colors.white38),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'نجارة احترافية',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'صيانة وتجديد أثاث\nخشبي',
                  style: AppTextStyles.headlineSmall,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('أحمد محمد', style: AppTextStyles.bodySmall),
                    const SizedBox(width: 4),
                    const Icon(Icons.person_outline,
                        size: 12, color: AppColors.textLight),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.calendar_today,
              color: AppColors.textWhite, size: 22),
          const SizedBox(height: 8),
          Text(
            'الموعد المحدد',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: AppColors.textWhite.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '14 أكتوبر',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textWhite,
            ),
          ),
          Text(
            '10:00 صباحاً',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textWhite.withOpacity(0.85),
            ),
          ),
        ],
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
            child: Text(
              'تعديل',
              style: AppTextStyles.accentLink,
            ),
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('موقع التنفيذ', style: AppTextStyles.titleSmall),
                  Text(
                    'حي الأرجس، الرياض، السعودية',
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
                child: const Icon(Icons.location_on_outlined,
                    color: AppColors.primary, size: 20),
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
              // Apply button
              GestureDetector(
                onTap: () =>
                    setState(() => _promoApplied = !_promoApplied),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'تطبيق',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Code input
              Expanded(
                child: TextField(
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'أدخل الكود هنا',
                    hintStyle: AppTextStyles.hintStyle,
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          if (_promoApplied) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'تم تطبيق خصم 10% (HERFA10)',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 16),
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
                  onChanged: (v) =>
                      setState(() => _cashOnDelivery = v ?? true),
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
                        child: const Icon(Icons.payments_outlined,
                            color: AppColors.textSecondary, size: 20),
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

  Widget _buildConfirmButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
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
            const Icon(Icons.bolt,
                color: AppColors.textWhite, size: 20),
            const SizedBox(width: 8),
            Text('تأكيد الحجز', style: AppTextStyles.labelLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Column(
      children: [
        _priceRow('تريب (الخدمة، المستلزمات 15%)', '75.0 ر.س'),
        const SizedBox(height: 8),
        _priceRow('خصم (10%)', '-25.00 ر.س',
            valueColor: AppColors.success),
        const Divider(color: AppColors.border, height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '262.50 ر.س',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            Text('الإجمالي الكلي',
                style: AppTextStyles.headlineSmall),
          ],
        ),
      ],
    );
  }

  Widget _priceRow(String label, String value,
      {Color? valueColor}) {
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
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
            textDirection: TextDirection.rtl),
      ],
    );
  }
}
