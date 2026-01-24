import '../../domain/entities/conversation_entity.dart';

/// Modelo de datos para Conversación
/// Maneja la serialización/deserialización desde Supabase
class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.listingId,
    required super.userId,
    required super.hostId,
    super.lastMessageAt,
    required super.createdAt,
    super.listingTitle,
    super.listingImageUrl,
    super.otherUserName,
    super.otherUserAvatarUrl,
    super.lastMessageContent,
    super.unreadCount = 0,
  });

  /// Crea un ConversationModel desde JSON de Supabase
  /// Espera datos enriquecidos con JOINs a listings y profiles
  factory ConversationModel.fromJson(Map<String, dynamic> json,
      {String? currentUserId}) {
    // Determinar quién es el "otro" usuario en la conversación
    final userId = json['user_id'] as String;
    final hostId = json['host_id'] as String;
    final isCurrentUserHost = currentUserId == hostId;

    // Datos del listing (JOIN)
    final listing = json['listings'] as Map<String, dynamic>?;

    // Datos del otro usuario (JOIN) - puede venir como user_profile o host_profile
    final otherProfile = isCurrentUserHost
        ? json['user_profile'] as Map<String, dynamic>?
        : json['host_profile'] as Map<String, dynamic>?;

    // Construir nombre del otro usuario
    String? otherUserName;
    if (otherProfile != null) {
      final firstName = otherProfile['first_name'] as String?;
      final lastName = otherProfile['last_name'] as String?;
      if (firstName != null || lastName != null) {
        otherUserName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
      }
    }

    // Último mensaje (JOIN opcional)
    final lastMessage = json['last_message'] as Map<String, dynamic>?;

    return ConversationModel(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      userId: userId,
      hostId: hostId,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      listingTitle: listing?['title'] as String?,
      listingImageUrl:
          (listing?['image_urls'] as List<dynamic>?)?.isNotEmpty == true
              ? (listing!['image_urls'] as List<dynamic>).first as String
              : null,
      otherUserName: otherUserName,
      otherUserAvatarUrl: otherProfile?['avatar_url'] as String?,
      lastMessageContent: lastMessage?['content'] as String?,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  /// Convierte a JSON para enviar a Supabase (INSERT)
  Map<String, dynamic> toInsertJson() {
    return {
      'listing_id': listingId,
      'user_id': userId,
      'host_id': hostId,
    };
  }

  /// Crea una copia como entidad
  ConversationEntity toEntity() {
    return ConversationEntity(
      id: id,
      listingId: listingId,
      userId: userId,
      hostId: hostId,
      lastMessageAt: lastMessageAt,
      createdAt: createdAt,
      listingTitle: listingTitle,
      listingImageUrl: listingImageUrl,
      otherUserName: otherUserName,
      otherUserAvatarUrl: otherUserAvatarUrl,
      lastMessageContent: lastMessageContent,
      unreadCount: unreadCount,
    );
  }
}
