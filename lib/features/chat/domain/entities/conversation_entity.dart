import 'package:equatable/equatable.dart';

/// Entidad de Conversación para el sistema de chat
/// Representa una conversación entre un usuario buscador y un anfitrión sobre un listing específico
class ConversationEntity extends Equatable {
  /// ID único de la conversación
  final String id;

  /// ID del listing asociado a la conversación
  final String listingId;

  /// ID del usuario que busca habitación (inicia la conversación)
  final String userId;

  /// ID del anfitrión/dueño del listing
  final String hostId;

  /// Timestamp del último mensaje
  final DateTime? lastMessageAt;

  /// Fecha de creación de la conversación
  final DateTime createdAt;

  // ---- Datos enriquecidos (de JOINs) ----

  /// Título del listing para mostrar en la UI
  final String? listingTitle;

  /// URL de la primera imagen del listing
  final String? listingImageUrl;

  /// Nombre del otro usuario en la conversación
  final String? otherUserName;

  /// Avatar del otro usuario
  final String? otherUserAvatarUrl;

  /// Contenido del último mensaje (preview)
  final String? lastMessageContent;

  /// Cantidad de mensajes no leídos
  final int unreadCount;

  const ConversationEntity({
    required this.id,
    required this.listingId,
    required this.userId,
    required this.hostId,
    this.lastMessageAt,
    required this.createdAt,
    this.listingTitle,
    this.listingImageUrl,
    this.otherUserName,
    this.otherUserAvatarUrl,
    this.lastMessageContent,
    this.unreadCount = 0,
  });

  /// Copia del objeto con campos modificados
  ConversationEntity copyWith({
    String? id,
    String? listingId,
    String? userId,
    String? hostId,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    String? listingTitle,
    String? listingImageUrl,
    String? otherUserName,
    String? otherUserAvatarUrl,
    String? lastMessageContent,
    int? unreadCount,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      userId: userId ?? this.userId,
      hostId: hostId ?? this.hostId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      listingTitle: listingTitle ?? this.listingTitle,
      listingImageUrl: listingImageUrl ?? this.listingImageUrl,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserAvatarUrl: otherUserAvatarUrl ?? this.otherUserAvatarUrl,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        listingId,
        userId,
        hostId,
        lastMessageAt,
        createdAt,
        unreadCount,
      ];
}
