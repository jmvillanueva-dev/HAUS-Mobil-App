import 'package:equatable/equatable.dart';

/// Entidad de Mensaje para el sistema de chat
/// Representa un mensaje individual dentro de una conversación
class MessageEntity extends Equatable {
  /// ID único del mensaje
  final String id;

  /// ID de la conversación a la que pertenece
  final String conversationId;

  /// ID del usuario que envió el mensaje
  final String senderId;

  /// Contenido del mensaje
  final String content;

  /// Indica si el mensaje fue leído por el receptor
  final bool isRead;

  /// Fecha de creación del mensaje
  final DateTime createdAt;

  /// Indica si el mensaje fue enviado por el usuario actual (campo computado)
  final bool isMine;

  // ---- Datos enriquecidos opcionales ----

  /// Nombre del remitente (para mostrar en UI)
  final String? senderName;

  /// Avatar del remitente
  final String? senderAvatarUrl;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.isRead = false,
    required this.createdAt,
    this.isMine = false,
    this.senderName,
    this.senderAvatarUrl,
  });

  /// Copia del objeto con campos modificados
  MessageEntity copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    bool? isRead,
    DateTime? createdAt,
    bool? isMine,
    String? senderName,
    String? senderAvatarUrl,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      isMine: isMine ?? this.isMine,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        content,
        isRead,
        createdAt,
      ];
}
