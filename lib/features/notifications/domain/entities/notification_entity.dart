import 'package:equatable/equatable.dart';

/// Tipo de notificación
enum NotificationType {
  chatMessage,
  statusChange,
  system,
  requestReceived,
}

/// Entidad de Notificación para el sistema de notificaciones in-app
class NotificationEntity extends Equatable {
  /// ID único de la notificación
  final String id;

  /// Tipo de notificación
  final NotificationType type;

  /// Título de la notificación
  final String title;

  /// Cuerpo/contenido de la notificación
  final String body;

  /// Datos adicionales (ej: conversationId, listingId, etc.)
  final Map<String, dynamic>? data;

  /// Indica si la notificación fue leída
  final bool isRead;

  /// Fecha de creación
  final DateTime createdAt;

  /// Imagen/avatar opcional
  final String? imageUrl;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.imageUrl,
  });

  /// Copia del objeto con campos modificados
  NotificationEntity copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    String? imageUrl,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [id, type, title, body, isRead, createdAt];
}
