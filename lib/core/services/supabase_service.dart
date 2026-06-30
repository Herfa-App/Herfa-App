import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._privateConstructor();
  static final SupabaseService instance = SupabaseService._privateConstructor();

  final SupabaseClient client = Supabase.instance.client;

  // ── Authentication ─────────────────────────────────────────────────────────

  Future<AuthResponse> signUp({
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
    final metaData = {
      'full_name': fullName,
      'phone': phone,
      'city': city,
      'role': role,
    };

    if (role == 'provider') {
      if (skills != null) metaData['skills'] = skills;
      if (bio != null) metaData['bio'] = bio;
      if (experienceYears != null) metaData['experience_years'] = experienceYears.toString();
      if (hourlyRate != null) metaData['hourly_rate'] = hourlyRate.toString();
      if (latitude != null) metaData['latitude'] = latitude.toString();
      if (longitude != null) metaData['longitude'] = longitude.toString();
    }

    return await client.auth.signUp(
      email: email,
      password: password,
      data: metaData,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'herfa://login-callback',
    );
  }

  // ── Profiles & Contact Info ───────────────────────────────────────────────

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final res = await client
        .from('profiles')
        .select('id, full_name, city, role, avatar_url')
        .eq('id', userId)
        .maybeSingle();
    return res;
  }

  Future<String?> getContactInfo(String targetUserId) async {
    try {
      final res = await client.rpc('get_contact_info', params: {
        'target_user_id': targetUserId,
      });
      return res as String?;
    } catch (_) {
      return null;
    }
  }

  // ── Provider Spatial Directory ────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getNearbyProviders({
    required double userLat,
    required double userLng,
    double maxDistanceKm = 50.0,
  }) async {
    final res = await client.rpc('get_nearby_providers', params: {
      'user_lat': userLat,
      'user_lng': userLng,
      'max_distance_km': maxDistanceKm,
    });
    if (res == null) return [];
    return List<Map<String, dynamic>>.from(res as List);
  }

  // ── Bookings ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getBookings() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    final res = await client
        .from('bookings')
        .select('*, customer:profiles!bookings_customer_id_fkey(full_name), provider:profiles!bookings_provider_id_fkey(full_name)')
        .order('booking_date', ascending: false);
    
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> createBooking({
    required String providerId,
    required String description,
    required DateTime bookingDate,
    double? totalPrice,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final Map<String, dynamic> payload = {
      'customer_id': user.id,
      'provider_id': providerId,
      'description': description,
      'booking_date': bookingDate.toIso8601String(),
    };

    if (totalPrice != null) {
      payload['total_price'] = totalPrice;
    }

    await client.from('bookings').insert(payload);
  }

  // Edit booking payload (explicit whitelist to avoid CLS status/price update errors)
  Future<void> updateBookingDetails({
    required String bookingId,
    required String description,
    required DateTime bookingDate,
  }) async {
    final whitelistedPayload = {
      'description': description,
      'booking_date': bookingDate.toIso8601String(),
    };

    await client
        .from('bookings')
        .update(whitelistedPayload)
        .eq('id', bookingId);
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String newStatus,
  }) async {
    await client.rpc('update_booking_status', params: {
      'booking_id': bookingId,
      'new_status': newStatus,
    });
  }

  Future<void> quoteBookingPrice({
    required String bookingId,
    required double price,
  }) async {
    await client.rpc('quote_booking_price', params: {
      'booking_id': bookingId,
      'price': price,
    });
  }

  // ── Chat & Realtime Messaging ─────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> streamMessages(String conversationId) {
    return client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
  }

  Future<void> sendMessage({
    required String receiverId,
    required String text,
    String type = 'text',
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await client.from('messages').insert({
      'sender_id': user.id,
      'receiver_id': receiverId,
      'text': text,
      'type': type,
      // Note: conversation_id is auto-generated by the DB trigger
    });
  }

  // ── Storage uploads ───────────────────────────────────────────────────────

  Future<String?> uploadAvatar(String filePath, List<int> fileBytes) async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final path = '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.png';
    await client.storage.from('avatars').uploadBinary(
          path,
          Uint8List.fromList(fileBytes),
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

    final publicUrl = client.storage.from('avatars').getPublicUrl(path);
    
    // Update profile url
    await client.from('profiles').update({'avatar_url': publicUrl}).eq('id', user.id);
    return publicUrl;
  }
}
