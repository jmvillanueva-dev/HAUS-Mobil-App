import 'package:equatable/equatable.dart';

/// Eventos del NotificationBloc
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar notificaciones
class LoadNotifications extends NotificationEvent {
  const LoadNotifications();
}

/// Suscribirse a notificaciones en tiempo real
class SubscribeToNotifications extends NotificationEvent {
  const SubscribeToNotifications();
}

/// Cancelar suscripción
class UnsubscribeFromNotifications extends NotificationEvent {
  const UnsubscribeFromNotifications();
}

/// Notificaciones actualizadas (desde realtime)
class NotificationsUpdated extends NotificationEvent {
  final List<dynamic> notifications;

  const NotificationsUpdated(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

/// Marcar notificación como leída
class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Marcar todas como leídas
class MarkAllNotificationsAsRead extends NotificationEvent {
  const MarkAllNotificationsAsRead();
}

/// Eliminar notificación
class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Cargar conteo de no leídas
class LoadUnreadCount extends NotificationEvent {
  const LoadUnreadCount();
}
