import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

/// Screen 4 — Role Selection Screen (أهلاً بك، كيف تود استخدام حرفة؟)
/// Analysis:
/// - White background, centered content
/// - Top: "حرفة" text logo in navy
/// - Card with title, subtitle
/// - Two option cards: Customer (أنا طالب خدمة) + Provider (أنا مقدم خدمة)
/// - Each has icon circle, title, description, colored link
/// - Bottom: تسجيل الدخول link
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Top logo
                Text(
                  'حرفة',
                  style: AppTextStyles.brandTitle,
                  textDirection: TextDirection.rtl,
                ),

                const SizedBox(height: 16),

                // Main card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        'أهلاً بك، كيف تود\naستخدام حرفة؟',
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontSize: 22,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'اختر نوع الحساب الذي يناسب احتياجاتك لتبدأ في\nرحلتك معنا اليوم.',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 28),

                      // Customer option
                      _RoleCard(
                        iconBg: const Color(0xFFEEF0F8),
                        iconColor: AppColors.primary,
                        icon: Icons.person_outline,
                        title: 'أنا طالب خدمة',
                        description:
                            'ابحث عن أفضل المحترفين والمهنيين لتنفيذ مشاريعك وطلباتك المنزلية بكل سهولة وأمان.',
                        linkLabel: 'ابدأ كعميل ←',
                        linkColor: AppColors.primary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const RegisterScreen(isCustomer: true),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Provider option
                      _RoleCard(
                        iconBg: const Color(0xFFFFF0E0),
                        iconColor: AppColors.accent,
                        icon: Icons.handyman,
                        title: 'أنا مقدم خدمة',
                        description:
                            'اعرض مهاراتك، ابن سمعتك المهنية وضاعف دخلك من خلال الوصول لآلاف العملاء في منطقتك.',
                        linkLabel: 'ابدأ كمحترف ←',
                        linkColor: AppColors.accent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const RegisterScreen(isCustomer: false),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              );
                            },
                            child: Text(
                              'تسجيل الدخول',
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
                            'لديك حساب بالفعل؟',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String description;
  final String linkLabel;
  final Color linkColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.description,
    required this.linkLabel,
    required this.linkColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),

          const SizedBox(height: 14),

          Text(
            title,
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            description,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 14),

          GestureDetector(
            onTap: onTap,
            child: Text(
              linkLabel,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: linkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
