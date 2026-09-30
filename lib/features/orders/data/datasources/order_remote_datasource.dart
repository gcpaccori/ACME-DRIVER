import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../datasources/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getAvailableOrders();
  Future<OrderModel?> getActiveOrder(String driverId);
  Future<List<OrderModel>> getOrderHistory(String driverId);
  Future<OrderModel> acceptOrder(String orderId, String driverId);
  Future<OrderModel> updateOrderStatus(String orderId, String status);
  Stream<List<OrderModel>> watchAvailableOrders();
}

/// Lee los pedidos con el mismo esquema que usa el panel web:
/// el negocio ofrece el pedido creando una fila en order_assignments y el
/// repartidor lo acepta y avanza sus estados con las funciones de la base
/// (driver_accept_assignment, driver_advance_order_status).
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final SupabaseClient _client;

  OrderRemoteDataSourceImpl(this._client);

  static const String _orderSelect = 'id, order_code, status, branch_id, customer_id, current_driver_id, '
      'total, delivery_fee, special_instructions, created_at, delivered_at, '
      'merchants(trade_name), '
      'merchant_branches(name, phone, lat, lng, addresses(line1, reference)), '
      'order_delivery_details(address_snapshot, reference_snapshot, lat, lng, recipient_name, recipient_phone)';

  String? get _currentUserId => _client.auth.currentUser?.id;

  Future<OrderModel> _fetchOrder(String orderId) async {
    final data = await _client
        .from(AppConstants.ordersTable)
        .select(_orderSelect)
        .eq('id', orderId)
        .single();
    return OrderModel.fromJson(data);
  }

  @override
  Future<List<OrderModel>> getAvailableOrders() async {
    final driverId = _currentUserId;
    if (driverId == null) return [];

    try {
      final data = await _client
          .from(AppConstants.orderAssignmentsTable)
          .select('id, assigned_at, orders($_orderSelect)')
          .eq('driver_id', driverId)
          .eq('status', 'assigned')
          .order('assigned_at', ascending: false);

      return (data as List)
          .where((row) => row['orders'] != null)
          .map((row) => OrderModel.fromJson(
                Map<String, dynamic>.from(row['orders'] as Map),
                assignedAt: row['assigned_at'] as String?,
                offered: true,
              ))
          .toList();
    } catch (e) {
      throw OrderException('No se pudieron cargar los pedidos: $e');
    }
  }

  @override
  Future<OrderModel?> getActiveOrder(String driverId) async {
    try {
      final data = await _client
          .from(AppConstants.ordersTable)
          .select(_orderSelect)
          .eq('current_driver_id', driverId)
          .inFilter('status', ['driver_accepted', 'picked_up', 'on_the_way'])
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data == null) return null;
      return OrderModel.fromJson(data);
    } catch (e) {
      throw OrderException('No se pudo cargar el pedido activo: $e');
    }
  }

  @override
  Future<List<OrderModel>> getOrderHistory(String driverId) async {
    try {
      final data = await _client
          .from(AppConstants.ordersTable)
          .select(_orderSelect)
          .eq('current_driver_id', driverId)
          .inFilter('status', ['delivered', 'cancelled', 'failed'])
          .order('created_at', ascending: false)
          .limit(AppConstants.pageSize);

      return (data as List).map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<OrderModel> acceptOrder(String orderId, String driverId) async {
    try {
      final assignment = await _client
          .from(AppConstants.orderAssignmentsTable)
          .select('id')
          .eq('order_id', orderId)
          .eq('driver_id', driverId)
          .eq('status', 'assigned')
          .order('assigned_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (assignment == null) {
        throw const OrderException('Este pedido ya no está asignado a ti.');
      }

      await _client.rpc('driver_accept_assignment', params: {
        'p_assignment_id': assignment['id'],
      });

      return _fetchOrder(orderId);
    } on OrderException {
      rethrow;
    } catch (e) {
      throw OrderException('No se pudo aceptar el pedido: $e');
    }
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    try {
      await _client.rpc('driver_advance_order_status', params: {
        'p_order_id': orderId,
        'p_to_status': status,
      });

      return _fetchOrder(orderId);
    } catch (e) {
      throw OrderException('Error al actualizar estado: $e');
    }
  }

  @override
  Stream<List<OrderModel>> watchAvailableOrders() {
    final driverId = _currentUserId;
    if (driverId == null) return Stream.value(const []);

    // Cada cambio en las ofertas del repartidor recarga la lista completa.
    return _client
        .from(AppConstants.orderAssignmentsTable)
        .stream(primaryKey: ['id'])
        .eq('driver_id', driverId)
        .asyncMap((_) => getAvailableOrders());
  }
}
