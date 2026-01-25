import 'dart:async';
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

/// Datasource remoto para notificaciones
/// Maneja la comunicación con Supabase
abstract class NotificationRemoteDatasource {
  /// Obtener todas las notificaciones del usuario
  Future<List<NotificationModel>> getNotifications();

  /// Stream de notificaciones en tiempo real
  Stream<List<NotificationModel>> watchNotifications();

  /// Marcar una notificación como leída
  Future<void> markAsRead(String notificationId);

  /// Marcar todas las notificaciones como leídas
  Future<void> markAllAsRead();

  /// Obtener conteo de notificaciones no leídas
  Future<int> getUnreadCount();

  /// Eliminar una notificación
  Future<void> deleteNotification(String notificationId);
}

/// Implementación del datasource con Supabase
class NotificationRemoteDatasourceImpl implements NotificationRemoteDatasource {
  final SupabaseClient _supabase;
  StreamController<List<NotificationModel>>? _notificationsController;
  RealtimeChannel? _channel;

  NotificationRemoteDatasourceImpl(this._supabase);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    developer.log('Fetching notifications for user: $userId',
        name: 'Notifications');

    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(100);

    developer.log('Got ${response.length} notifications',
        name: 'Notifications');

    return (response as List<dynamic>)
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Stream<List<NotificationModel>> watchNotifications() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    _notificationsController?.close();
    _notificationsController =
        StreamController<List<NotificationModel>>.broadcast();

    // Cargar notificaciones iniciales
    _loadAndEmit();

    // Suscribirse a cambios en tiempo real
    _channel?.unsubscribe();
    _channel = _supabase
        .channel('user_notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            developer.log('Notification realtime update: ${payload.eventType}',
                name: 'Notifications');
            _loadAndEmit();
          },
        )
        .subscribe();

    return _notificationsController!.stream;
  }

  Future<void> _loadAndEmit() async {
    try {
      final notifications = await getNotifications();
      _notificationsController?.add(notifications);
    } catch (e) {
      developer.log('Error loading notifications: $e', name: 'Notifications');
      _notificationsController?.addError(e);
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);

    developer.log('Marked notification $notificationId as read',
        name: 'Notifications');
  }

  @override
  Future<void> markAllAsRead() async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);

    developer.log('Marked all notifications as read', name: 'Notifications');
  }

  @override
  Future<int> getUnreadCount() async {
    final userId = _currentUserId;
    if (userId == null) return 0;

    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .eq('is_read', false)
        .count(CountOption.exact);

    return response.count;
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _supabase.from('notifications').delete().eq('id', notificationId);

    developer.log('Deleted notification $notificationId',
        name: 'Notifications');
  }

  /// Limpiar recursos
  void dispose() {
    _channel?.unsubscribe();
    _notificationsController?.close();
  }
}
