import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  bool _isChecking = false;
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyOTP(String email, String token) async {
    setState(() => _isChecking = true);
    try {
      final auth = context.read<AuthProvider>();
      await auth.verifyOTP(email: email, token: token);
      if (mounted) {
        final role = auth.user?.userMetadata?['role'] ?? 'customer';
        if (role == 'provider') {
          Navigator.pushNamedAndRemoveUntil(context, '/pro-setup', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التحقق من الرمز: ${e.toString()}', textAlign: TextAlign.right)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _handleResend(String email) async {
    setState(() => _isResending = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: 'herfa://login-callback',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إعادة إرسال رابط التحقق بنجاح', textAlign: TextAlign.right)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إرسال الرابط: ${e.toString()}', textAlign: TextAlign.right)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _handleCheckStatus() async {
    final auth = context.read<AuthProvider>();
    final email = auth.tempEmail ?? auth.user?.email ?? '';
    final code = _otpController.text.trim();

    if (code.length == 6) {
      await _handleVerifyOTP(email, code);
      return;
    }

    setState(() => _isChecking = true);
    try {
      await auth.checkVerificationStatus();

      if (mounted) {
        if (auth.status == AuthStatus.authenticated && auth.user != null) {
          final role = auth.user!.userMetadata?['role'] ?? 'customer';
          if (role == 'provider') {
            Navigator.pushNamedAndRemoveUntil(context, '/pro-setup', (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('البريد الإلكتروني لم يتم تأكيده بعد. يرجى مراجعة بريدك.', textAlign: TextAlign.right)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء التحقق: ${e.toString()}', textAlign: TextAlign.right)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final routeEmail = ModalRoute.of(context)?.settings.arguments as String?;
    final email = routeEmail ?? auth.tempEmail ?? auth.user?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      _buildMailIllustration(),
                      const SizedBox(height: 48),

                      Text(
                        'تأكد من بريدك\nالإلكتروني',
                        style: AppTextStyles.displayMedium.copyWith(
                          fontSize: 28,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'تم إرسال رابط التحقق إلى:\n$email\nيرجى الضغط على الرابط لتفعيل حسابك.',
                        style: AppTextStyles.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text('أو أدخل رمز التحقق المكون من 6 أرقام:', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 12),
                      _buildPinField(),
                      const SizedBox(height: 32),

                      // Check verification status button
                      GestureDetector(
                        onTap: _isChecking ? null : _handleCheckStatus,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: _isChecking
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: AppColors.textWhite, strokeWidth: 2),
                                  )
                                : Text(
                                    'تحقق من التفعيل والدخول',
                                    style: AppTextStyles.labelLarge,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Resend link button
                      GestureDetector(
                        onTap: (_isResending || email.isEmpty) ? null : () => _handleResend(email),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundGrey,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Center(
                            child: _isResending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                                  )
                                : Text(
                                    'إعادة إرسال الرابط',
                                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Change email / Go back
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              auth.logout();
                              Navigator.pop(context);
                            },
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
            onTap: () {
              context.read<AuthProvider>().logout();
              Navigator.pop(context);
            },
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

  Widget _buildPinField() {
    return TextField(
      controller: _otpController,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 6,
      style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
      decoration: InputDecoration(
        hintText: '000000',
        hintStyle: GoogleFonts.cairo(fontSize: 22, color: AppColors.textLight, letterSpacing: 8),
        counterText: '',
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
