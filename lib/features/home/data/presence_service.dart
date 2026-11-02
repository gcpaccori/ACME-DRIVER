import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../../auth/domain/entities/driver_profile.dart';
import '../../auth/presentation/providers/auth_provider.dart';

/// Avisa a la base que el repartidor esta en turno.
///
/// Mientras el repartidor esta "En linea" (o con un pedido), cada 2 minutos
/// llama a `driver_set_presence(true, lat, lng)`. Con eso el sistema sabe
/// cuantos repartidores estan trabajando y calcula la alta demanda y el tiempo
/// de entrega que ve el cliente. Si la app se cierra, a los 15 minutos sin
/// latido el repartidor deja de contar solo.
class PresenceService {
  PresenceService(this._client);

  static const Duration intervalo = Duration(minutes: 2);

  final SupabaseClient _client;
  Timer? _timer;
  // Sube cada vez que se detiene: un latido "en linea" que seguia esperando la
  // posicion ve que cambio y no se manda, asi no pisa el "fuera de linea".
  int _generacion = 0;

  bool get activo => _timer != null;

  void iniciar() {
    if (_timer != null) return;
    _latido(true);
    _timer = Timer.periodic(intervalo, (_) => _latido(true));
  }

  Future<void> detener({bool avisar = true}) async {
    _generacion++;
    _timer?.cancel();
    _timer = null;
    if (avisar) await _latido(false);
  }

  Future<void> _latido(bool online) async {
    final generacion = _generacion;
    try {
      final pos = online ? await _posicion() : null;
      if (online && generacion != _generacion) return;
      await _client.rpc('driver_set_presence', params: {
        'p_online': online,
        'p_lat': pos?.latitude,
        'p_lng': pos?.longitude,
      });
    } catch (e) {
      // Sin red o sin la funcion en la base: se reintenta en el siguiente latido.
      debugPrint('driver_set_presence: $e');
    }
  }

  Future<Position?> _posicion() async {
    try {
      final permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied || permiso == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  void dispose() {
    _generacion++;
    _timer?.cancel();
    _timer = null;
  }
}

/// Arranca o para el latido segun el estado del repartidor. Se lee una vez en
/// la raiz de la app y sigue vivo mientras la app este abierta.
final presenceProvider = Provider<PresenceService>((ref) {
  final service = PresenceService(ref.watch(supabaseClientProvider));
  ref.onDispose(service.dispose);

  ref.listen(currentDriverProvider, (previous, next) {
    final driver = next.valueOrNull;
    final enTurno = driver != null &&
        (driver.status == DriverStatus.available || driver.status == DriverStatus.busy);
    if (enTurno) {
      service.iniciar();
    } else if (service.activo) {
      // Se puso "Fuera de linea" o cerro sesion.
      service.detener();
    }
  }, fireImmediately: true);

  return service;
});
