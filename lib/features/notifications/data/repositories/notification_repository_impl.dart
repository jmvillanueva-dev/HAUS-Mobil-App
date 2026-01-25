import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

/// Implementación del repositorio de notificaciones
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource _remoteDatasource;

  NotificationRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final models = await _remoteDatasource.getNotifications();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications() {
    return _remoteDatasource.watchNotifications().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return _remoteDatasource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() {
    return _remoteDatasource.markAllAsRead();
  }

  @override
  Future<int> getUnreadCount() {
    return _remoteDatasource.getUnreadCount();
  }

  @override
  Future<void> deleteNotification(String notificationId) {
    return _remoteDatasource.deleteNotification(notificationId);
  }
}
