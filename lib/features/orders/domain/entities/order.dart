import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final String id;
  final String code;
  final String storeId;
  final String storeName;
  final String storeAddress;
  final double storeLat;
  final double storeLng;
  final String storePhone;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final double deliveryLat;
  final double deliveryLng;
  final double totalAmount;
  final double deliveryFee;
  final OrderStatus status;
  final String? driverId;
  final String? notes;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? deliveredAt;

  const Order({
    required this.id,
    required this.code,
    required this.storeId,
    required this.storeName,
    required this.storeAddress,
    required this.storeLat,
    required this.storeLng,
    required this.storePhone,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.deliveryLat,
    required this.deliveryLng,
    required this.totalAmount,
    required this.deliveryFee,
    required this.status,
    this.driverId,
    this.notes,
    required this.createdAt,
    this.assignedAt,
    this.deliveredAt,
  });

  Order copyWith({OrderStatus? status, String? driverId}) {
    return Order(
      id: id,
      code: code,
      storeId: storeId,
      storeName: storeName,
      storeAddress: storeAddress,
      storeLat: storeLat,
      storeLng: storeLng,
      storePhone: storePhone,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryAddress: deliveryAddress,
      deliveryLat: deliveryLat,
      deliveryLng: deliveryLng,
      totalAmount: totalAmount,
      deliveryFee: deliveryFee,
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      notes: notes,
      createdAt: createdAt,
      assignedAt: assignedAt,
      deliveredAt: deliveredAt,
    );
  }

  @override
  List<Object?> get props => [id, status, driverId];
}

enum OrderStatus { assigned, accepted, pickedUp, onTheWay, delivered, cancelled }

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.assigned:
        return 'Asignado';
      case OrderStatus.accepted:
        return 'Aceptado';
      case OrderStatus.pickedUp:
        return 'Recogido';
      case OrderStatus.onTheWay:
        return 'En camino';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  String get value {
    switch (this) {
      case OrderStatus.assigned:
        return 'assigned';
      case OrderStatus.accepted:
        return 'driver_accepted';
      case OrderStatus.pickedUp:
        return 'picked_up';
      case OrderStatus.onTheWay:
        return 'on_the_way';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus fromString(String value) {
    switch (value) {
      case 'assigned':
        return OrderStatus.assigned;
      case 'driver_accepted':
      case 'accepted':
        return OrderStatus.accepted;
      case 'picked_up':
        return OrderStatus.pickedUp;
      case 'on_the_way':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'failed':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.assigned;
    }
  }

  /// Returns the next valid status in the flow
  OrderStatus? get next {
    switch (this) {
      case OrderStatus.assigned:
        return OrderStatus.accepted;
      case OrderStatus.accepted:
        return OrderStatus.pickedUp;
      case OrderStatus.pickedUp:
        return OrderStatus.onTheWay;
      case OrderStatus.onTheWay:
        return OrderStatus.delivered;
      default:
        return null;
    }
  }
}
