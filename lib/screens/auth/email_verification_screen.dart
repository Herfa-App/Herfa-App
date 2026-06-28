import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../customer/customer_home_screen.dart';

/// Screen 5 — Email Verification Screen (تأكيد البريد الإلكتروني)
/// Analysis:
/// - Light background
/// - Top header: back arrow (→), title "تأكيد البريد الإلكتروني"
/// - Illustration: white rounded card with envelope icon, orange badge
/// - Title "تأكد من بريدك الإلكتروني"
/// - Subtitle paragraph
/// - "إعادة إرسال الرابط" primary button
/// - "تغيير البريد الإلكتروني" link row
/// - 3 dots indicator at bottom
class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // ── Header ──
              _buildHeader(context),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // ── Mail Illustration ──
                      _buildMailIllustration(),

                      const SizedBox(height: 48),

                      // ── Title ──
                      Text(
                        'تأكد من بريدك\nالإلكتروني',
                        style: AppTextStyles.displayMedium.copyWith(
                          fontSize: 28,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // ── Subtitle ──
                      Text(
                        'تم إرسال رابط التحقق إلى بريدك الإلكتروني.\nيرجى الضغط على الرابط في الرسالة لتفعيل حسابك.',
                        style: AppTextStyles.bodyLarge,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),

                      // ── Resend button ──
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CustomerHomeScreen()),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              'إعادة إرسال الرابط',
                              style: AppTextStyles.labelLarge,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Change email row ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'تغيير البريد الإلكتروني',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'لم تصلك الرسالة؟',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // ── Page indicator dots ──
                      _buildDots(),

                      const SizedBox(height: 40),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_forward,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
          Text(
            'تأكيد البريد الإلكتروني',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 22),
        ],
      ),
    );
  }

  Widget _buildMailIllustration() {
    return Center(
      child: SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          children: [
            // Beige/cream background shape
            Positioned(
              right: 0,
              top: 20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            // White card with envelope
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDE4F8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.email_rounded,
                      color: AppColors.primary,
                      size: 38,
                    ),
                  ),
                ),
              ),
            ),

            // Orange notification badge
            Positioned(
              top: 22,
              right: 16,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications,
                  color: AppColors.textWhite,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(false),
        const SizedBox(width: 6),
        _dot(true),
        const SizedBox(width: 6),
        _dot(false),
      ],
    );
  }

  Widget _dot(bool active) {
    return Container(
      width: active ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.accent : AppColors.textLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
