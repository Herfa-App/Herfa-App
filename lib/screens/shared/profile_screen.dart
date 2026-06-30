import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  Map<String, dynamic>? _providerDetails;
  bool _loadingProvider = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.userProfile?['role'] == 'provider') {
        _fetchProviderDetails();
      }
    });
  }

  Future<void> _fetchProviderDetails() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    if (!mounted) return;
    setState(() => _loadingProvider = true);
    try {
      final details = await SupabaseService.instance.getProviderProfile(user.id);
      if (mounted) {
        setState(() {
          _providerDetails = details;
        });
      }
    } catch (_) {}
    finally {
      if (mounted) {
        setState(() => _loadingProvider = false);
      }
    }
  }

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
          _buildAppBar(context, fullName, phone, city),
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
                    if (profile?['role'] == 'provider') ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildProviderInfoCard(),
                      ),
                    ],
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

  Widget _buildAppBar(BuildContext context, String fullName, String phone, String city) {
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
            onTap: () => _showEditProfileDialog(fullName, phone, city),
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
                ),
                child: ClipOval(
                  child: avatarUrl != null
                      ? Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.person, size: 50, color: AppColors.textLight),
                        )
                      : const Icon(Icons.person, size: 50, color: AppColors.textLight),
                ),
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

  void _showEditProfileDialog(String currentName, String currentPhone, String currentCity) {
    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone == 'لا يوجد' ? '' : currentPhone);
    final cityController = TextEditingController(text: currentCity == 'غير محدد' ? '' : currentCity);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('تعديل البيانات الشخصية', style: AppTextStyles.headlineSmall),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'المدينة'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () async {
                  setDialogState(() => isSaving = true);
                  try {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user != null) {
                      await Supabase.instance.client.from('profiles').update({
                        'full_name': nameController.text.trim(),
                        'city': cityController.text.trim(),
                      }).eq('id', user.id);
                      
                      try {
                        final newPhone = phoneController.text.trim();
                        if (newPhone.isNotEmpty) {
                          await Supabase.instance.client.auth.updateUser(
                            UserAttributes(phone: newPhone),
                          );
                        }
                      } catch (_) {}
                      
                      if (mounted) {
                        await context.read<AuthProvider>().refreshProfile();
                      }
                    }
                    Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تحديث البيانات بنجاح', textAlign: TextAlign.right)),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('حدث خطأ: ${e.toString()}', textAlign: TextAlign.right)),
                      );
                    }
                  } finally {
                    setDialogState(() => isSaving = false);
                  }
                },
                child: isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('حفظ'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderInfoCard() {
    if (_loadingProvider) {
      return Container(
        height: 100,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    final skills = _providerDetails?['skills'] ?? 'لم يتم التحديد';
    final bio = _providerDetails?['bio'] ?? 'لم يتم التحديد';
    final hourlyRate = _providerDetails?['hourly_rate']?.toString() ?? '0';
    final experience = _providerDetails?['experience_years']?.toString() ?? '0';

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _showEditProviderDetailsDialog(skills, bio, hourlyRate, experience),
                  child: Text('تعديل البيانات المهنية', style: AppTextStyles.accentLink),
                ),
                Text('بيانات الحرفي والمهنة', style: AppTextStyles.headlineSmall),
              ],
            ),
          ),
          _divider(),
          _infoTile(
            icon: Icons.handyman_outlined,
            label: 'التخصصات والمهارات',
            value: skills,
          ),
          _divider(),
          _infoTile(
            icon: Icons.description_outlined,
            label: 'نبذة تعريفية (Bio)',
            value: bio,
          ),
          _divider(),
          _infoTile(
            icon: Icons.monetization_on_outlined,
            label: 'سعر الساعة ج.م',
            value: '$hourlyRate جنيه',
          ),
          _divider(),
          _infoTile(
            icon: Icons.calendar_today_outlined,
            label: 'سنوات الخبرة',
            value: '$experience سنة',
          ),
        ],
      ),
    );
  }

  void _showEditProviderDetailsDialog(String currentSkills, String currentBio, String currentRate, String currentExp) {
    final skillsCtrl = TextEditingController(text: currentSkills == 'لم يتم التحديد' ? '' : currentSkills);
    final bioCtrl = TextEditingController(text: currentBio == 'لم يتم التحديد' ? '' : currentBio);
    final rateCtrl = TextEditingController(text: currentRate);
    final expCtrl = TextEditingController(text: currentExp);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('تعديل البيانات المهنية', style: AppTextStyles.headlineSmall),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: skillsCtrl,
                    decoration: const InputDecoration(labelText: 'التخصصات والمهارات (مثال: سباكة، تسليك)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bioCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'نبذة تعريفية عنك وعن خبراتك'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rateCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'سعر الساعة التقديري (جنيه)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: expCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'سنوات الخبرة'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () async {
                  setDialogState(() => isSaving = true);
                  try {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user != null) {
                      await SupabaseService.instance.updateProviderProfile(
                        providerId: user.id,
                        skills: skillsCtrl.text.trim(),
                        bio: bioCtrl.text.trim(),
                        experienceYears: int.tryParse(expCtrl.text.trim()) ?? 0,
                        hourlyRate: double.tryParse(rateCtrl.text.trim()) ?? 0.0,
                      );
                      await _fetchProviderDetails();
                    }
                    Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تحديث البيانات المهنية بنجاح', textAlign: TextAlign.right)),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('حدث خطأ: ${e.toString()}', textAlign: TextAlign.right)),
                      );
                    }
                  } finally {
                    setDialogState(() => isSaving = false);
                  }
                },
                child: isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('حفظ'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
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
          Navigator.pushReplacementNamed(context, '/requests');
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
