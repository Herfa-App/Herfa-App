import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─── Herfa Side Drawer ────────────────────────────────────────────────────────
// Uses ListView to avoid overflow on small screens
class HerfaDrawer extends StatelessWidget {
  const HerfaDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundWhite,
      child: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // ── Fixed header ────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                color: AppColors.primary,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أحمد محمد',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textWhite,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ahmed@herfa.com',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.textWhite.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.backgroundWhite.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: const Icon(Icons.person,
                          size: 32, color: AppColors.textWhite),
                    ),
                  ],
                ),
              ),

              // ── Scrollable menu items ────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  physics: const ClampingScrollPhysics(),
                  children: [
                    _DrawerItem(
                      icon: Icons.home_outlined,
                      label: 'الرئيسية',
                      onTap: () {
                        Navigator.pop(context);
                        // Already on home or navigate there
                        _navigateTo(context, '/home');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.receipt_long_outlined,
                      label: 'طلباتي',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(context, '/requests');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'الحجوزات',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(context, '/bookings');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.chat_bubble_outline,
                      label: 'المحادثات',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(context, '/chat');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.receipt_outlined,
                      label: 'دليل الأسعار',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(context, '/prices');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.person_outline,
                      label: 'ملفي الشخصي',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(context, '/profile');
                      },
                    ),

                    const Divider(
                        color: AppColors.border, height: 24,
                        indent: 16, endIndent: 16),

                    _DrawerItem(
                      icon: Icons.settings_outlined,
                      label: 'الإعدادات',
                      onTap: () => Navigator.pop(context),
                    ),
                    _DrawerItem(
                      icon: Icons.help_outline,
                      label: 'المساعدة والدعم',
                      onTap: () => Navigator.pop(context),
                    ),

                    const SizedBox(height: 16),

                    // ── Logout inside scrollable area ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: _LogoutButton(),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate using named-route-style logic via pushNamed or push
  static void _navigateTo(BuildContext context, String route) {
    // We'll resolve navigation inside the calling screen via a callback
    // For now, we push named routes that main.dart handles
    Navigator.pushNamed(context, route);
  }
}

// ─── Logout Button (standalone so Drawer doesn't overflow) ───────────────────
class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // close drawer first
        showDialog(
          context: context,
          builder: (_) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text('تسجيل الخروج',
                  style: GoogleFonts.cairo(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                  textDirection: TextDirection.rtl),
              content: Text('هل أنت متأكد أنك تريد تسجيل الخروج؟',
                  style: GoogleFonts.cairo(
                      fontSize: 14, color: AppColors.textSecondary),
                  textDirection: TextDirection.rtl),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('إلغاء',
                      style: GoogleFonts.cairo(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (_) => false);
                  },
                  child: Text('تسجيل الخروج',
                      style: GoogleFonts.cairo(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Text('تسجيل الخروج',
                style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error)),
          ],
        ),
      ),
    );
  }
}

// ─── Drawer Item ─────────────────────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary),
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: AppColors.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final double? width;
  final EdgeInsets? padding;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 14,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        padding: padding ??
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primary,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 8)],
            Text(label,
                style: AppTextStyles.labelLarge
                    .copyWith(color: textColor ?? AppColors.textWhite),
                textDirection: TextDirection.rtl),
          ],
        ),
      ),
    );
  }
}

// ─── Input Field ──────────────────────────────────────────────────────────────
class HerfaInputField extends StatelessWidget {
  final String? label;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;

  const HerfaInputField({
    super.key,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.titleSmall,
              textDirection: TextDirection.rtl),
          const SizedBox(height: 8),
        ],
        TextField(
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.hintStyle,
            hintTextDirection: TextDirection.rtl,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.inputFill,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ─── Bottom Navigation Bar ────────────────────────────────────────────────────
// FIX: No textDirection on the Row — order is controlled by the items list
class HerfaBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavItem> items;
  final ValueChanged<int>? onTap;

  const HerfaBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            // ✅ NO textDirection here — items list order controls visual order
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (idx) {
              final item = items[idx];
              final isSelected = idx == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap?.call(idx),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textLight,
                        size: 23,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textLight,
                        ),
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;
  const BottomNavItem({required this.icon, required this.label});
}

// ─── Star Rating ──────────────────────────────────────────────────────────────
class StarRating extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final bool showLabel;

  const StarRating({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 16,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Text(rating.toString(),
              style: AppTextStyles.titleSmall
                  .copyWith(color: AppColors.textPrimary)),
          const SizedBox(width: 4),
        ],
        ...List.generate(starCount, (i) {
          if (i < rating.floor()) {
            return Icon(Icons.star, color: AppColors.starColor, size: size);
          } else if (i < rating) {
            return Icon(Icons.star_half, color: AppColors.starColor, size: size);
          } else {
            return Icon(Icons.star_border, color: AppColors.starColor, size: size);
          }
        }),
      ],
    );
  }
}

// ─── Chip Tag ─────────────────────────────────────────────────────────────────
class ChipTag extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedBgColor;
  final IconData? icon;
  final VoidCallback? onTap;

  const ChipTag({
    super.key,
    required this.label,
    this.isSelected = false,
    this.selectedColor,
    this.unselectedColor,
    this.selectedBgColor,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? (selectedBgColor ?? AppColors.primary)
        : AppColors.backgroundWhite;
    final labelColor = isSelected
        ? (selectedColor ?? AppColors.textWhite)
        : (unselectedColor ?? AppColors.textPrimary);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: isSelected ? bgColor : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: AppTextStyles.labelMedium
                    .copyWith(color: labelColor),
                textDirection: TextDirection.rtl),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: labelColor),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headlineSmall),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!, style: AppTextStyles.accentLink),
          ),
      ],
    );
  }
}

// ─── Image Placeholder ────────────────────────────────────────────────────────
class ImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;
  final IconData? icon;

  const ImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: icon != null
          ? Icon(icon, color: AppColors.textLight, size: 28)
          : null,
    );
  }
}
