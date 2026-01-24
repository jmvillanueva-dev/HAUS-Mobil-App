import '../../domain/entities/message_entity.dart';

/// Modelo de datos para Mensaje
/// Maneja la serialización/deserialización desde Supabase
class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.content,
    super.isRead = false,
    required super.createdAt,
    super.isMine = false,
    super.senderName,
    super.senderAvatarUrl,
  });

  /// Crea un MessageModel desde JSON de Supabase
  factory MessageModel.fromJson(Map<String, dynamic> json,
      {String? currentUserId}) {
    final senderId = json['sender_id'] as String;

    // Datos del remitente (JOIN opcional)
    final senderProfile = json['sender_profile'] as Map<String, dynamic>?;

    // Construir nombre del remitente
    String? senderName;
    if (senderProfile != null) {
      final firstName = senderProfile['first_name'] as String?;
      final lastName = senderProfile['last_name'] as String?;
      if (firstName != null || lastName != null) {
        senderName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
      }
    }

    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: senderId,
      content: json['content'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      isMine: currentUserId != null && senderId == currentUserId,
      senderName: senderName,
      senderAvatarUrl: senderProfile?['avatar_url'] as String?,
    );
  }

  /// Convierte a JSON para enviar a Supabase (INSERT)
  Map<String, dynamic> toInsertJson() {
    return {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
    };
  }

  /// Crea un modelo desde una entidad (útil para enviar mensajes)
  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      conversationId: entity.conversationId,
      senderId: entity.senderId,
      content: entity.content,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
      isMine: entity.isMine,
      senderName: entity.senderName,
      senderAvatarUrl: entity.senderAvatarUrl,
    );
  }

  /// Crea una copia como entidad
  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      isRead: isRead,
      createdAt: createdAt,
      isMine: isMine,
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
    );
  }
}
