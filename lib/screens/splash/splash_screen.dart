import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../auth/login_screen.dart';

/// Screen 1 — Splash Screen
/// Shows حرفة branding with location pin icon, tagline, and loading dots
/// Auto-navigates to LoginScreen after 2s
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.status == AuthStatus.authenticated && auth.user != null) {
        final role = auth.user!.userMetadata?['role'] ?? 'customer';
        if (role == 'provider') {
          Navigator.pushReplacementNamed(context, '/pro-home');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else if (auth.status == AuthStatus.needsVerification) {
        Navigator.pushReplacementNamed(context, '/verify');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Stack(
        children: [
          // Top-right gradient blob
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: size.width * 0.45,
              height: size.height * 0.25,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom-left gradient blob
          Positioned(
            bottom: size.height * 0.08,
            left: 0,
            child: Container(
              width: size.width * 0.4,
              height: size.height * 0.18,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content centered
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Location Pin Icon
                _buildLocationPin(),

                const SizedBox(height: 28),

                // App Name "حرفة"
                Text(
                  'حرفة',
                  style: GoogleFonts.cairo(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    height: 1,
                  ),
                  textDirection: TextDirection.rtl,
                ),

                const SizedBox(height: 12),

                // Tagline chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'صنايعي شاطر، بضغطة واحدة',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Loading dots
                _buildLoadingDots(),

                const SizedBox(height: 12),

                Text(
                  'جاري التحميل',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textLight,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPin() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.location_on,
            size: 80,
            color: AppColors.primary,
          ),
          Positioned(
            top: 16,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(0),
            const SizedBox(width: 6),
            _dot(1),
            const SizedBox(width: 6),
            _dot(2),
          ],
        );
      },
    );
  }

  Widget _dot(int index) {
    final delay = index * 0.3;
    final value = (_dotController.value - delay).clamp(0.0, 1.0);
    final opacity = (value < 0.5 ? value * 2 : (1 - value) * 2).clamp(0.3, 1.0);
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == 1
            ? AppColors.accent.withOpacity(opacity)
            : AppColors.primary.withOpacity(opacity),
      ),
    );
  }
}
