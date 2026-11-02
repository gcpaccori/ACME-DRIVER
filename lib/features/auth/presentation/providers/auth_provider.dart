import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/driver_profile_model.dart';
import '../../domain/entities/driver_profile.dart';
import '../../data/repositories/auth_remote_datasource.dart';
import '../../../../shared/providers/supabase_provider.dart';

// ── Data source provider ────────────────────────────────────
final authDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
});

// ── Auth state provider ─────────────────────────────────────
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authDataSourceProvider).authStateChanges;
});

// ── Current driver provider ──────────────────────────────────
final currentDriverProvider = StateNotifierProvider<AuthNotifier, AsyncValue<DriverProfileModel?>>((ref) {
  return AuthNotifier(ref.watch(authDataSourceProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<DriverProfileModel?>> {
  final AuthRemoteDataSource _dataSource;

  AuthNotifier(this._dataSource) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final driver = await _dataSource.getCurrentDriver();
    state = AsyncValue.data(driver);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final driver = await _dataSource.signIn(email, password);
      state = AsyncValue.data(driver);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signUp(
      String email, String password, Map<String, dynamic> metadata) async {
    state = const AsyncValue.loading();
    try {
      final driver = await _dataSource.signUp(email, password, metadata);
      state = AsyncValue.data(driver);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    // Sale de turno mientras la sesion sigue viva; despues la base ya no sabe
    // quien es y el repartidor seguiria contando 15 minutos.
    try {
      await Supabase.instance.client.rpc('driver_set_presence', params: {'p_online': false});
    } catch (_) {}
    await _dataSource.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> sendPasswordReset(String email) async {
    await _dataSource.sendPasswordResetEmail(email);
  }

  Future<void> toggleStatus() async {
    final current = state.value;
    if (current == null) return;

    final newStatus =
        current.status == DriverStatus.available ? 'offline' : 'available';
    await _dataSource.updateDriverStatus(newStatus);

    final updated = await _dataSource.getCurrentDriver();
    state = AsyncValue.data(updated);
  }
}
