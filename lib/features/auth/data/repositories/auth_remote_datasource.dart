import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../datasources/driver_profile_model.dart';

abstract class AuthRemoteDataSource {
  Future<DriverProfileModel> signIn(String email, String password);
  Future<DriverProfileModel> signUp(String email, String password, Map<String, dynamic> metadata);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<DriverProfileModel?> getCurrentDriver();
  Future<void> updateDriverStatus(String status);
  Stream<AuthState> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<DriverProfileModel> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AppAuthException('No se pudo autenticar el usuario');
      }

      // Fetch driver profile and verify role
      final profile = await _fetchDriverProfile(user.id);
      return profile;
    } on AppAuthException {
      rethrow;
    } on AppRoleException {
      rethrow;
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        throw const AppAuthException(AppStrings.loginError);
      }
      throw AppAuthException(e.message);
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }

  @override
  Future<DriverProfileModel> signUp(
      String email, String password, Map<String, dynamic> metadata) async {
    // Las cuentas de repartidor se crean desde el panel de ACME.
    throw const AppAuthException(AppStrings.accountsCreatedByAcme);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw const AppAuthException('No se pudo enviar el correo de recuperación');
    }
  }

  @override
  Future<DriverProfileModel?> getCurrentDriver() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      return await _fetchDriverProfile(user.id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateDriverStatus(String status) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      await _client
          .from(AppConstants.driversTable)
          .update({'status': status})
          .eq('user_id', user.id);
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }

  Future<DriverProfileModel> _fetchDriverProfile(String userId) async {
    // Es repartidor quien tiene ficha en drivers (la crea el panel de ACME).
    final driverData = await _client
        .from(AppConstants.driversTable)
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (driverData == null) {
      await _client.auth.signOut();
      throw const AppRoleException(AppStrings.roleError);
    }

    final profileData = await _client
        .from(AppConstants.profilesTable)
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    // Merge profile + driver data
    final merged = {
      ...?profileData,
      ...driverData,
      'id': userId,
      'user_id': userId,
      'email': _client.auth.currentUser?.email ?? profileData?['email'] ?? '',
    };

    return DriverProfileModel.fromJson(merged);
  }
}
