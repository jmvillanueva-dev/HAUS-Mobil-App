import '../../domain/entities/notification_entity.dart';

/// Modelo de datos para Notificación
/// Maneja la serialización/deserialización desde Supabase
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.body,
    super.data,
    super.isRead = false,
    required super.createdAt,
    super.imageUrl,
  });

  /// Crea un NotificationModel desde JSON de Supabase
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: _parseNotificationType(json['type'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      imageUrl: json['image_url'] as String?,
    );
  }

  /// Parsea el tipo de notificación desde string
  static NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'chat_message':
        return NotificationType.chatMessage;
      case 'new_listing':
        return NotificationType.matchRequest; // Reutilizamos para listings
      case 'match_request':
        return NotificationType.matchRequest;
      case 'status_change':
        return NotificationType.statusChange;
      case 'system':
      default:
        return NotificationType.system;
    }
  }

  /// Convierte a JSON para operaciones de update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': _typeToString(type),
      'title': title,
      'body': body,
      'data': data,
      'is_read': isRead,
      'image_url': imageUrl,
    };
  }

  /// Convierte el tipo a string
  static String _typeToString(NotificationType type) {
    switch (type) {
      case NotificationType.chatMessage:
        return 'chat_message';
      case NotificationType.matchRequest:
        return 'new_listing';
      case NotificationType.statusChange:
        return 'status_change';
      case NotificationType.system:
        return 'system';
    }
  }

  /// Crea una copia como entidad
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      type: type,
      title: title,
      body: body,
      data: data,
      isRead: isRead,
      createdAt: createdAt,
      imageUrl: imageUrl,
    );
  }
}
