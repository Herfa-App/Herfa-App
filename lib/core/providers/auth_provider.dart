import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, needsVerification, loading }

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;
  
  AuthStatus _status = AuthStatus.uninitialized;
  User? _user;
  Map<String, dynamic>? _userProfile;
  String? _currentUserPhone;

  AuthStatus get status => _status;
  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get currentUserPhone => _currentUserPhone;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _user = _supabaseService.client.auth.currentUser;
    if (_user != null) {
      _checkVerificationState(_supabaseService.client.auth.currentSession);
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }

    _supabaseService.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          _user = session?.user;
          await _checkVerificationState(session);
          break;
        case AuthChangeEvent.signedOut:
        case AuthChangeEvent.userDeleted:
          _user = null;
          _userProfile = null;
          _currentUserPhone = null;
          _status = AuthStatus.unauthenticated;
          notifyListeners();
          break;
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          _user = session?.user;
          if (_user != null) {
            await _fetchUserProfileAndPhone();
          }
          break;
        default:
          break;
      }
    });
  }

  Future<void> _checkVerificationState(Session? session) async {
    if (session == null || session.user.emailConfirmedAt == null) {
      _status = AuthStatus.needsVerification;
    } else {
      _status = AuthStatus.authenticated;
      await _fetchUserProfileAndPhone();
    }
    notifyListeners();
  }

  Future<void> _fetchUserProfileAndPhone() async {
    if (_user == null) return;
    try {
      _userProfile = await _supabaseService.getProfile(_user!.id);
      _currentUserPhone = await _supabaseService.getContactInfo(_user!.id);
    } catch (_) {
      // Handle silently or log
    }
  }

  // Reload user data manually to force-check verification state
  Future<void> checkVerificationStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final response = await _supabaseService.client.auth.getUser();
      _user = response.user;
      if (_user != null && _user!.emailConfirmedAt != null) {
        _status = AuthStatus.authenticated;
        await _fetchUserProfileAndPhone();
      } else {
        _status = AuthStatus.needsVerification;
      }
    } catch (_) {
      _status = AuthStatus.needsVerification;
    }
    notifyListeners();
  }

  // ── Auth Actions ──────────────────────────────────────────────────────────

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _supabaseService.signIn(email: email, password: password);
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String city,
    required String role,
    String? skills,
    String? bio,
    int? experienceYears,
    double? hourlyRate,
    double? latitude,
    double? longitude,
  }) async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _supabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        city: city,
        role: role,
        skills: skills,
        bio: bio,
        experienceYears: experienceYears,
        hourlyRate: hourlyRate,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _supabaseService.signOut();
  }
}
