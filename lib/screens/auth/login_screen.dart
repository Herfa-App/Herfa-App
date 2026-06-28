import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shared_widgets.dart';
import '../auth/role_selection_screen.dart';
import '../auth/register_screen.dart';
import '../customer/customer_home_screen.dart';

/// Screen 2 — Login Screen (تسجيل الدخول)
/// Analysis:
/// - Light grey background (#F5F6FA)
/// - Top: tools icon in navy circle, "Herfa" bold, subtitle Arabic
/// - White card: title + subtitle, email field, password field w/ forgot link
/// - Dark blue CTA button, divider "أو عبر", Google button
/// - Bottom: "الدخول كزائر" link, register link
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // ── Brand Header ──────────────────────────────────────
                  _buildBrandHeader(),

                  const SizedBox(height: 28),

                  // ── Login Card ────────────────────────────────────────
                  _buildLoginCard(context),

                  const SizedBox(height: 20),

                  // ── Bottom links ──────────────────────────────────────
                  _buildBottomLinks(context),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        // Tools icon in navy circle
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.handyman,
            color: AppColors.textWhite,
            size: 34,
          ),
        ),
        const SizedBox(height: 14),

        // "Herfa" brand name
        Text(
          'Herfa',
          style: GoogleFonts.cairo(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: -0.5,
          )
        ),
        const SizedBox(height: 6),

        Text(
          'بوابة الحرفيين والمهنيين',
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Title
          Text(
            'تسجيل الدخول',
            style: AppTextStyles.headlineLarge,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          Text(
            'مرحبا بك مجدداً في حرفة',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.right,
          ),

          const SizedBox(height: 24),

          // Email field label
          Text(
            'البريد الإلكتروني',
            style: AppTextStyles.titleSmall,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),

          // Email input
          TextField(
            keyboardType: TextInputType.emailAddress,
            textAlign: TextAlign.right,
            textDirection: TextDirection.ltr,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'example@herfa.com',
              hintStyle: AppTextStyles.hintStyle,
              hintTextDirection: TextDirection.ltr,
              suffixIcon: const Icon(
                Icons.email_outlined,
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
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),

          const SizedBox(height: 20),

          // Password row: label + forgot
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {},
                child: Text(
                  'نسيت كلمة السر؟',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.accent,
                  ),
                ),
              ),
              Text(
                'كلمة السر',
                style: AppTextStyles.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Password input
          TextField(
            obscureText: _obscurePassword,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: AppTextStyles.hintStyle,
              suffixIcon: GestureDetector(
                onTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                child: Icon(
                  _obscurePassword ? Icons.lock_outline : Icons.lock_open,
                  color: AppColors.textLight,
                  size: 20,
                ),
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
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),

          const SizedBox(height: 24),

          // Login CTA button
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login,
                      color: AppColors.textWhite, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'تسجيل الدخول',
                    style: AppTextStyles.labelLarge,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Divider "أو عبر"
          Row(
            children: [
              Expanded(
                child: Divider(color: AppColors.border, thickness: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'أو عبر',
                  style: AppTextStyles.bodySmall,
                ),
              ),
              Expanded(
                child: Divider(color: AppColors.border, thickness: 1),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Google login button
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
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Login with Google',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Google icon placeholder
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.g_mobiledata,
                        size: 18, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomLinks(BuildContext context) {
    return Column(
      children: [
        // Guest link
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
            );
          },
          child: Text(
            'الدخول كزائر',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Register row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RoleSelectionScreen()),
                );
              },
              child: Text(
                'أنشئ حسابك الآن',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'ليس لديك حساب؟',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}
