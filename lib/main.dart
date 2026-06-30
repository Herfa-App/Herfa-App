import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
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

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Initialize Supabase with publishable key and custom deep link callback scheme
  await Supabase.initialize(
    url: 'https://wapahlusiaqblvejxiqy.supabase.co',
    anonKey: 'sb_publishable_sb_24cFdnj_D0krmEH8yPw_-iIklV8U',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const HerfaApp(),
    ),
  );
}

class HerfaApp extends StatefulWidget {
  const HerfaApp({super.key});

  @override
  State<HerfaApp> createState() => _HerfaAppState();
}

class _HerfaAppState extends State<HerfaApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupDeepLinkListener();
  }

  void _setupDeepLinkListener() {
    // Listen to Auth State Changes to automatically handle verification redirects and sign-ins
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final event = data.event;

      if (event == AuthChangeEvent.signedIn && session != null) {
        if (session.user.emailConfirmedAt != null) {
          // Check role and redirect
          final role = session.user.userMetadata?['role'] ?? 'customer';
          if (role == 'provider') {
            _navigatorKey.currentState?.pushNamedAndRemoveUntil('/pro-home', (route) => false);
          } else {
            _navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
          }
        } else {
          _navigatorKey.currentState?.pushNamedAndRemoveUntil('/verify', (route) => false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حرفة',
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
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
        '/requests':  (_) => const ProviderHomeScreen(),
      },
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
    );
  }
}
