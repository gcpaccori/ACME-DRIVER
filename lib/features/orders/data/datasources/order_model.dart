import '../../domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.code,
    required super.storeId,
    required super.storeName,
    required super.storeAddress,
    required super.storeLat,
    required super.storeLng,
    required super.storePhone,
    required super.customerId,
    required super.customerName,
    required super.customerPhone,
    required super.deliveryAddress,
    required super.deliveryLat,
    required super.deliveryLng,
    required super.totalAmount,
    required super.deliveryFee,
    required super.status,
    super.driverId,
    super.notes,
    required super.createdAt,
    super.assignedAt,
    super.deliveredAt,
  });

  /// Construye el pedido desde la fila de orders (con merchants, merchant_branches
  /// y order_delivery_details embebidos). [offered] indica que el pedido llega como
  /// oferta pendiente de order_assignments.
  factory OrderModel.fromJson(
    Map<String, dynamic> json, {
    String? assignedAt,
    bool offered = false,
  }) {
    final merchant = _asMap(json['merchants']);
    final branch = _asMap(json['merchant_branches']);
    final branchAddress = _asMap(branch['addresses']);
    final delivery = _asMap(json['order_delivery_details']);
    final orderCode = json['order_code'];
    final deliveryReference = delivery['reference_snapshot'] as String?;
    final deliveryAddress = [
      delivery['address_snapshot'] as String?,
      if (deliveryReference != null && deliveryReference.isNotEmpty) 'Ref: $deliveryReference',
    ].whereType<String>().where((part) => part.isNotEmpty).join(' · ');

    return OrderModel(
      id: json['id'] as String,
      code: orderCode != null ? '#$orderCode' : '#000',
      storeId: json['branch_id'] as String? ?? '',
      storeName: merchant['trade_name'] as String? ?? branch['name'] as String? ?? 'Local',
      storeAddress: branchAddress['line1'] as String? ?? '',
      storeLat: (branch['lat'] as num?)?.toDouble() ?? 0.0,
      storeLng: (branch['lng'] as num?)?.toDouble() ?? 0.0,
      storePhone: branch['phone'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      customerName: delivery['recipient_name'] as String? ?? 'Cliente',
      customerPhone: delivery['recipient_phone'] as String? ?? '',
      deliveryAddress: deliveryAddress,
      deliveryLat: (delivery['lat'] as num?)?.toDouble() ?? 0.0,
      deliveryLng: (delivery['lng'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      status: offered
          ? OrderStatus.assigned
          : OrderStatusExtension.fromString(json['status'] as String? ?? 'assigned'),
      driverId: json['current_driver_id'] as String?,
      notes: json['special_instructions'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      assignedAt: assignedAt != null ? DateTime.parse(assignedAt) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at'] as String) : null,
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is List && value.isNotEmpty && value.first is Map) {
      return Map<String, dynamic>.from(value.first as Map);
    }
    return const {};
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'store_id': storeId,
      'store_name': storeName,
      'store_address': storeAddress,
      'store_lat': storeLat,
      'store_lng': storeLng,
      'store_phone': storePhone,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'delivery_address': deliveryAddress,
      'delivery_lat': deliveryLat,
      'delivery_lng': deliveryLng,
      'total_amount': totalAmount,
      'delivery_fee': deliveryFee,
      'status': status.value,
      'driver_id': driverId,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
