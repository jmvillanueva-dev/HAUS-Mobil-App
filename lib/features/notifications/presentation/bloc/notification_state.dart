import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

/// Estados del NotificationBloc
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Cargando notificaciones
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// Notificaciones cargadas
class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];

  /// Copia del estado con cambios
  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// Error al cargar notificaciones
class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
