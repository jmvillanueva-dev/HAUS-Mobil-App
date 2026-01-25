import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// BLoC para gestionar notificaciones
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  StreamSubscription<List<NotificationEntity>>? _subscription;
  List<NotificationEntity> _currentNotifications = [];

  NotificationBloc({required NotificationRepository repository})
      : _repository = repository,
        super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<SubscribeToNotifications>(_onSubscribeToNotifications);
    on<UnsubscribeFromNotifications>(_onUnsubscribeFromNotifications);
    on<NotificationsUpdated>(_onNotificationsUpdated);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<LoadUnreadCount>(_onLoadUnreadCount);
  }

  /// Cargar notificaciones
  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    try {
      final notifications = await _repository.getNotifications();
      final unreadCount = await _repository.getUnreadCount();

      _currentNotifications = notifications;

      developer.log(
          'Loaded ${notifications.length} notifications, $unreadCount unread',
          name: 'NotificationBloc');

      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      developer.log('Error loading notifications: $e',
          name: 'NotificationBloc');
      emit(NotificationError(e.toString()));
    }
  }

  /// Suscribirse a notificaciones en tiempo real
  Future<void> _onSubscribeToNotifications(
    SubscribeToNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    await _subscription?.cancel();

    developer.log('Subscribing to notifications', name: 'NotificationBloc');

    _subscription = _repository.watchNotifications().listen(
      (notifications) {
        add(NotificationsUpdated(notifications));
      },
      onError: (error) {
        developer.log('Notifications stream error: $error',
            name: 'NotificationBloc');
      },
    );
  }

  /// Cancelar suscripción
  Future<void> _onUnsubscribeFromNotifications(
    UnsubscribeFromNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    developer.log('Unsubscribing from notifications', name: 'NotificationBloc');
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Notificaciones actualizadas desde stream
  Future<void> _onNotificationsUpdated(
    NotificationsUpdated event,
    Emitter<NotificationState> emit,
  ) async {
    final notifications = event.notifications.cast<NotificationEntity>();
    final unreadCount = notifications.where((n) => !n.isRead).length;

    _currentNotifications = notifications;

    developer.log(
        'Notifications updated: ${notifications.length}, $unreadCount unread',
        name: 'NotificationBloc');

    emit(NotificationLoaded(
      notifications: notifications,
      unreadCount: unreadCount,
    ));
  }

  /// Marcar notificación como leída
  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markAsRead(event.notificationId);

      // Actualizar localmente
      _currentNotifications = _currentNotifications.map((n) {
        if (n.id == event.notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      final unreadCount = _currentNotifications.where((n) => !n.isRead).length;

      emit(NotificationLoaded(
        notifications: _currentNotifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      developer.log('Error marking notification as read: $e',
          name: 'NotificationBloc');
    }
  }

  /// Marcar todas como leídas
  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markAllAsRead();

      // Actualizar localmente
      _currentNotifications =
          _currentNotifications.map((n) => n.copyWith(isRead: true)).toList();

      emit(NotificationLoaded(
        notifications: _currentNotifications,
        unreadCount: 0,
      ));
    } catch (e) {
      developer.log('Error marking all as read: $e', name: 'NotificationBloc');
    }
  }

  /// Eliminar notificación
  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.deleteNotification(event.notificationId);

      // Actualizar localmente
      _currentNotifications = _currentNotifications
          .where((n) => n.id != event.notificationId)
          .toList();

      final unreadCount = _currentNotifications.where((n) => !n.isRead).length;

      emit(NotificationLoaded(
        notifications: _currentNotifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      developer.log('Error deleting notification: $e',
          name: 'NotificationBloc');
    }
  }

  /// Cargar conteo de no leídas
  Future<void> _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final count = await _repository.getUnreadCount();

      if (state is NotificationLoaded) {
        emit((state as NotificationLoaded).copyWith(unreadCount: count));
      }
    } catch (e) {
      developer.log('Error loading unread count: $e', name: 'NotificationBloc');
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
