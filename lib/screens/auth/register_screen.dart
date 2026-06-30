import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../auth/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final bool isCustomer;
  const RegisterScreen({super.key, this.isCustomer = true});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late bool _isCustomer;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _isCustomer = widget.isCustomer;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة', textAlign: TextAlign.right)),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب الموافقة على شروط الخدمة وسياسة الخصوصية', textAlign: TextAlign.right)),
      );
      return;
    }

    setState(() => _isLoading = true);

    double? latitude;
    double? longitude;

    if (!_isCustomer) {
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          latitude = position.latitude;
          longitude = position.longitude;
        }
      } catch (_) {
        // Fallback to Cairo coordinates on error/denial
        latitude = 30.0444;
        longitude = 31.2357;
      }
    }

    try {
      final auth = context.read<AuthProvider>();
      await auth.register(
        email: email,
        password: password,
        fullName: name,
        phone: phone,
        city: _selectedCity!,
        role: _isCustomer ? 'customer' : 'provider',
        latitude: latitude,
        longitude: longitude,
      );

      if (mounted) {
        // Navigate directly to home — email confirmation disabled
        final role = context.read<AuthProvider>().user?.userMetadata?['role'] ?? 'customer';
        if (role == 'provider') {
          Navigator.pushReplacementNamed(context, '/pro-home');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء التسجيل: ${e.toString()}', textAlign: TextAlign.right)),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                const SizedBox(height: 28),
                _buildBrandHeader(),
                const SizedBox(height: 20),

                // ── Register Card ──
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withOpacity(0.07),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Center(
                        child: Text(
                          'إنشاء حساب جديد',
                          style: AppTextStyles.headlineLarge,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTabSwitcher(),
                      const SizedBox(height: 20),

                      // Full name
                      _buildLabel('الاسم بالكامل'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        hint: 'أدخل اسمك الثلاثي',
                        icon: Icons.person_outline,
                        controller: _nameController,
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      _buildLabel('رقم الهاتف'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        hint: '01X XXXX XXXX',
                        icon: Icons.phone_outlined,
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildLabel('البريد الإلكتروني'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        hint: 'example@herfa.com',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      _buildLabel('كلمة السر'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),

                      // City dropdown
                      _buildLabel('المدينة'),
                      const SizedBox(height: 8),
                      _buildCityDropdown(),
                      const SizedBox(height: 16),

                      // Terms checkbox
                      _buildTermsRow(),
                      const SizedBox(height: 20),

                      // Create account button
                      GestureDetector(
                        onTap: _isLoading ? null : _handleRegister,
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
                                  child: CircularProgressIndicator(
                                    color: AppColors.textWhite,
                                    strokeWidth: 2,
                                  ),
                                )
                              else ...[
                                const Icon(Icons.arrow_back,
                                    color: AppColors.textWhite, size: 20),
                                const SizedBox(width: 8),
                                Text('إنشاء حساب',
                                    style: AppTextStyles.labelLarge),
                              ]
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Login link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
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
                                  color: AppColors.accent,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.accent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'لديك حساب بالفعل؟',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildTrustBadges(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Text(
          'Herfa',
          style: GoogleFonts.cairo(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          )
        ),
        const SizedBox(height: 4),
        Text(
          'سوق الحرفيين والمهنيين في مصر',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 10),
        Container(
          width: 240,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCustomer = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isCustomer
                      ? AppColors.backgroundWhite
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: !_isCustomer
                      ? [
                          BoxShadow(
                            color: AppColors.shadow.withOpacity(0.08),
                            blurRadius: 4,
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    'حرفي',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: !_isCustomer
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: !_isCustomer
                          ? AppColors.textPrimary
                          : AppColors.textLight,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCustomer = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isCustomer
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'عميل',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _isCustomer
                          ? AppColors.textWhite
                          : AppColors.textLight,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(text, style: AppTextStyles.titleSmall),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.hintStyle,
        hintTextDirection: TextDirection.rtl,
        suffixIcon: Icon(icon, color: AppColors.textLight, size: 20),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCity,
          hint: Text(
            'اختر مدينتك',
            style: AppTextStyles.hintStyle,
            textDirection: TextDirection.rtl,
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textLight),
          items: const [
            DropdownMenuItem(value: 'cairo', child: Text('القاهرة', textDirection: TextDirection.rtl)),
            DropdownMenuItem(value: 'alex', child: Text('الإسكندرية', textDirection: TextDirection.rtl)),
            DropdownMenuItem(value: 'portsaid', child: Text('بورسعيد', textDirection: TextDirection.rtl)),
            DropdownMenuItem(value: 'giza', child: Text('الجيزة', textDirection: TextDirection.rtl)),
          ],
          onChanged: (val) {
            setState(() {
              _selectedCity = val;
            });
          },
          alignment: Alignment.centerRight,
        ),
      ),
    );
  }

  Widget _buildTermsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
          activeColor: AppColors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: RichText(
              textDirection: TextDirection.rtl,
              text: TextSpan(
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'بإنشاء حساب، فأنت توافق على '),
                  TextSpan(
                    text: 'شروط الخدمة',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.accent,
                    ),
                  ),
                  const TextSpan(text: ' و '),
                  TextSpan(
                    text: 'سياسة الخصوصية',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.accent,
                    ),
                  ),
                  const TextSpan(text: ' الخاصة بـ Herfa.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBadges() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _TrustBadge(
            icon: Icons.shield_outlined,
            iconColor: AppColors.primary,
            iconBg: const Color(0xFFEEF0F8),
            title: 'حرفيين موثوقين',
            subtitle: 'فحص دقيق لكافة الهويات',
          ),
          const SizedBox(height: 16),
          _TrustBadge(
            icon: Icons.handyman,
            iconColor: AppColors.accent,
            iconBg: const Color(0xFFFFF0E0),
            title: 'أكثر من 50 مهنة',
            subtitle: 'من السباكة حتى البرمجة',
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.build,
              size: 48,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;

  const _TrustBadge({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              title,
              style: AppTextStyles.titleSmall,
              textDirection: TextDirection.rtl,
            ),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ],
    );
  }
}
