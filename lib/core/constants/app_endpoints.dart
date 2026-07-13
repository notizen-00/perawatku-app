class AppEndpoints {
  AppEndpoints._();

  static const String patientLogin = '/api/patient/login';
  static const String patientRegister = '/api/patient/register';
  static const String patientNurses = '/api/patient/nurses';
  static const String patientDoctors = '/api/patient/doctors';
  static const String patientServices = '/api/patient/services';
  static const String patientConsultations = '/api/patient/consultations';
  static const String patientOrders = '/api/patient/orders';
  static const String patientMembers = '/api/patient/members';
  static const String patientServiceBookings = '/api/patient/service-bookings';
  static const String patientServiceBookingServices =
      '/api/patient/service-bookings/services';
  static const String patientServiceBookingCheckPromoCode =
      '/api/patient/service-bookings/check-promo-code';
  static const String broadcastingAuth = '/api/broadcasting/auth';
  static const String sharedNotifications = '/api/shared/notifications';
  static const String sharedNotificationUnreadCount =
      '/api/shared/notifications/unread-count';
  static const String sharedNotificationReadAll =
      '/api/shared/notifications/read-all';
}
