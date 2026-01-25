import '../../domain/entities/notification_entity.dart';

/// Repositorio abstracto para notificaciones
abstract class NotificationRepository {
  /// Obtener todas las notificaciones del usuario
  Future<List<NotificationEntity>> getNotifications();

  /// Stream de notificaciones en tiempo real
  Stream<List<NotificationEntity>> watchNotifications();

  /// Marcar una notificación como leída
  Future<void> markAsRead(String notificationId);

  /// Marcar todas las notificaciones como leídas
  Future<void> markAllAsRead();

  /// Obtener conteo de notificaciones no leídas
  Future<int> getUnreadCount();

  /// Eliminar una notificación
  Future<void> deleteNotification(String notificationId);
}
