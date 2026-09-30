class AppConstants {
  AppConstants._();

  static const String appName = 'ACME-DRIVER';
  static const String appVersion = '1.0.0';

  // Supabase table names
  static const String profilesTable = 'profiles';
  static const String driversTable = 'drivers';
  static const String ordersTable = 'orders';
  static const String orderStatusHistoryTable = 'order_status_history';
  static const String orderAssignmentsTable = 'order_assignments';
  static const String driverLocationsTable = 'driver_locations';
  static const String notificationsTable = 'notifications';
  static const String settlementsTable = 'settlements';

  // Realtime channels
  static const String ordersChannel = 'orders_realtime';
  static const String driverLocationChannel = 'driver_location';

  // Location update interval in seconds
  static const int locationUpdateInterval = 10;

  // Pagination
  static const int pageSize = 20;
}
