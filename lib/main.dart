import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/customer/booking_confirmation_screen.dart';
import 'screens/customer/filter_screen.dart';
import 'screens/customer/map_request_screen.dart';
import 'screens/customer/provider_profile_screen.dart';
import 'screens/provider/provider_home_screen.dart';
import 'screens/provider/provider_setup_screen.dart';
import 'screens/shared/chat_screen.dart';
import 'screens/shared/price_guide_screen.dart';
import 'screens/shared/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const HerfaApp());
}

class HerfaApp extends StatelessWidget {
  const HerfaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حرفة',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,

      // ── Named routes so Drawer can navigate anywhere ──────────────────
      initialRoute: '/splash',
      routes: {
        '/splash':    (_) => const SplashScreen(),
        '/login':     (_) => const LoginScreen(),
        '/role':      (_) => const RoleSelectionScreen(),
        '/register':  (_) => const RegisterScreen(),
        '/verify':    (_) => const EmailVerificationScreen(),
        '/home':      (_) => const CustomerHomeScreen(),
        '/prices':    (_) => const PriceGuideScreen(),
        '/bookings':  (_) => const BookingConfirmationScreen(),
        '/chat':      (_) => const ChatScreen(),
        '/profile':   (_) => const ProfileScreen(),
        '/filter':    (_) => const FilterScreen(),
        '/map':       (_) => const MapRequestScreen(),
        '/provider':  (_) => const ProviderProfileScreen(),
        '/pro-home':  (_) => const ProviderHomeScreen(),
        '/pro-setup': (_) => const ProviderSetupScreen(),
        '/requests':  (_) => const ProviderHomeScreen(), // طلباتي
      },

      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
    );
  }
}
