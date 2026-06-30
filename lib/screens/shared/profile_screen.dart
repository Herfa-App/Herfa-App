import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/supabase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsOn = true;
  bool _locationOn = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final profile = auth.userProfile;
    final phone = auth.currentUserPhone ?? 'لا يوجد';

    final fullName = profile?['full_name'] ?? user?.userMetadata?['full_name'] ?? 'مستخدم حرفة';
    final email = user?.email ?? '';
    final city = profile?['city'] ?? user?.userMetadata?['city'] ?? 'غير محدد';
    final avatarUrl = profile?['avatar_url'];

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
                child: Column(
                  children: [
                    _buildProfileHeader(fullName, email, avatarUrl),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildStatsRow(),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildInfoCard(fullName, phone, email, city),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSettingsCard(),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildLogoutButton(context),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomNav(context),
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
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit_outlined, color: AppColors.primary, size: 16),
                  const SizedBox(width: 4),
                  Text('تعديل',
                      style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text('ملفي الشخصي',
              style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary)),
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

  Widget _buildProfileHeader(String fullName, String email, String? avatarUrl) {
    return Container(
      width: double.infinity,
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundGrey,
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 3),
                  image: avatarUrl != null
                      ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 50, color: AppColors.textLight)
                    : null,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: GestureDetector(
                  onTap: () {}, // Handled by image upload service in future
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: AppColors.textWhite, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(fullName,
              style: AppTextStyles.headlineLarge.copyWith(fontSize: 22),
              textDirection: TextDirection.rtl),
          const SizedBox(height: 4),
          Text(email,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: AppColors.success, size: 14),
                const SizedBox(width: 4),
                Text('حساب موثق',
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatCell(value: '12', label: 'طلب منجز'),
          Container(width: 1, height: 40, color: AppColors.border),
          _StatCell(value: '4.8', label: 'تقييمي'),
          Container(width: 1, height: 40, color: AppColors.border),
          _StatCell(value: '3', label: 'حجوزات قادمة'),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String name, String phone, String email, String city) {
    String cityArabic = city;
    if (city == 'cairo') cityArabic = 'القاهرة';
    if (city == 'alex') cityArabic = 'الإسكندرية';
    if (city == 'portsaid') cityArabic = 'بورسعيد';
    if (city == 'giza') cityArabic = 'الجيزة';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _infoTile(
            icon: Icons.person_outline,
            label: 'الاسم بالكامل',
            value: name,
          ),
          _divider(),
          _infoTile(
            icon: Icons.phone_outlined,
            label: 'رقم الهاتف',
            value: phone,
          ),
          _divider(),
          _infoTile(
            icon: Icons.email_outlined,
            label: 'البريد الإلكتروني',
            value: email,
          ),
          _divider(),
          _infoTile(
            icon: Icons.location_city_outlined,
            label: 'المدينة',
            value: cityArabic,
          ),
        ],
      ),
    );
  }

  Widget _infoTile({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.chevron_left, color: AppColors.textLight, size: 20),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: AppTextStyles.titleSmall, textDirection: TextDirection.rtl),
              const SizedBox(height: 2),
              Text(label, style: AppTextStyles.bodySmall, textDirection: TextDirection.rtl),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16);

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text('الإعدادات', style: AppTextStyles.headlineSmall),
          ),
          _divider(),
          _toggleTile(
            icon: Icons.notifications_outlined,
            label: 'الإشعارات',
            value: _notificationsOn,
            onChanged: (v) => setState(() => _notificationsOn = v),
          ),
          _divider(),
          _toggleTile(
            icon: Icons.location_on_outlined,
            label: 'خدمات الموقع',
            value: _locationOn,
            onChanged: (v) => setState(() => _locationOn = v),
          ),
          _divider(),
          _settingsTile(
            icon: Icons.language_outlined,
            label: 'اللغة',
            trailing: 'العربية',
            onTap: () {},
          ),
          _divider(),
          _settingsTile(
            icon: Icons.privacy_tip_outlined,
            label: 'سياسة الخصوصية',
            onTap: () {},
          ),
          _divider(),
          _settingsTile(
            icon: Icons.description_outlined,
            label: 'شروط الخدمة',
            onTap: () {},
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
          const Spacer(),
          Text(label, style: AppTextStyles.titleSmall, textDirection: TextDirection.rtl),
          const SizedBox(width: 12),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String label,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailing != null) ...[
                  Text(trailing,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(width: 4),
                ],
                const Icon(Icons.chevron_left, color: AppColors.textLight, size: 20),
              ],
            ),
            const Spacer(),
            Text(label, style: AppTextStyles.titleSmall, textDirection: TextDirection.rtl),
            const SizedBox(width: 12),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('تسجيل الخروج', style: AppTextStyles.headlineSmall, textDirection: TextDirection.rtl),
              content: Text('هل أنت متأكد أنك تريد تسجيل الخروج؟', style: AppTextStyles.bodyMedium, textDirection: TextDirection.rtl),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('إلغاء',
                      style: GoogleFonts.cairo(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await context.read<AuthProvider>().logout();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                    }
                  },
                  child: Text('تسجيل الخروج',
                      style: GoogleFonts.cairo(color: AppColors.error, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'تسجيل الخروج',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return HerfaBottomNav(
      currentIndex: 0, // حسابي is index 0
      items: const [
        BottomNavItem(icon: Icons.person, label: 'الملف'),
        BottomNavItem(icon: Icons.chat_bubble_outline, label: 'محادثة'),
        BottomNavItem(icon: Icons.calendar_today_outlined, label: 'الحجوزات'),
        BottomNavItem(icon: Icons.receipt_long_outlined, label: 'الأسعار'),
        BottomNavItem(icon: Icons.home_outlined, label: 'الرئيسية'),
      ],
      onTap: (index) {
        if (index == 4) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/chat');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/bookings');
        } else if (index == 3) {
          Navigator.pushReplacementNamed(context, '/prices');
        }
      },
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
