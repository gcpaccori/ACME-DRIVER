class AppStrings {
  AppStrings._();

  // Auth
  static const String login = 'Iniciar sesión';
  static const String logout = 'Cerrar sesión';
  static const String email = 'Correo electrónico';
  static const String password = 'Contraseña';
  static const String forgotPassword = '¿Olvidaste tu contraseña?';
  static const String recoverPassword = 'Recuperar contraseña';
  static const String loginError = 'Correo o contraseña incorrectos';
  static const String roleError = 'No tienes permiso para ingresar como repartidor';
  static const String internalEmailDomain = 'acmedidos.com';
  static const String internalEmailHint = 'nombre@acmedidos.com';
  static const String internalEmailError = 'Usa tu correo @acmedidos.com';
  static const String accountsCreatedByAcme =
      'Tu cuenta @acmedidos.com la crea ACME PEDIDOS.\nSi aún no la tienes, pídela a tu administrador.';

  // Home
  static const String hello = 'Hola,';
  static const String available = 'Disponible';
  static const String busy = 'Ocupado';
  static const String offline = 'Desconectado';
  static const String todaySummary = 'Resumen de hoy';
  static const String deliveries = 'Entregas';
  static const String earnings = 'Ganancias';

  // Orders
  static const String availableOrders = 'Pedidos disponibles';
  static const String activeOrder = 'Pedido activo';
  static const String acceptOrder = 'Aceptar pedido';
  static const String noOrders = 'No hay pedidos disponibles';

  // Order status
  static const String statusAssigned = 'Asignado';
  static const String statusAccepted = 'Aceptado';
  static const String statusPickedUp = 'Recogido';
  static const String statusOnTheWay = 'En camino';
  static const String statusDelivered = 'Entregado';
  static const String statusCancelled = 'Cancelado';

  // Navigation
  static const String navHome = 'Inicio';
  static const String navOrders = 'Pedidos';
  static const String navHistory = 'Historial';
  static const String navEarnings = 'Ganancias';
  static const String navProfile = 'Perfil';

  // Error messages
  static const String networkError = 'Sin conexión a internet';
  static const String genericError = 'Ocurrió un error inesperado';
  static const String tryAgain = 'Intentar de nuevo';

  // Misc
  static const String noData = 'Sin datos';
  static const String loading = 'Cargando...';
  static const String confirm = 'Confirmar';
  static const String cancel = 'Cancelar';
}
