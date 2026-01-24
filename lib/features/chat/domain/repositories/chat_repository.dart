import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

/// Repositorio abstracto para el sistema de chat
/// Define las operaciones disponibles para gestionar conversaciones y mensajes
abstract class ChatRepository {
  /// Obtiene la lista de conversaciones del usuario actual
  /// Incluye datos enriquecidos: info del listing, otro usuario, último mensaje
  Future<Either<Failure, List<ConversationEntity>>> getConversations();

  /// Obtiene una conversación específica por ID
  Future<Either<Failure, ConversationEntity>> getConversation(
      String conversationId);

  /// Obtiene los mensajes de una conversación
  Future<Either<Failure, List<MessageEntity>>> getMessages(
      String conversationId);

  /// Stream de mensajes para actualizaciones en tiempo real
  /// Usa Supabase Realtime para recibir nuevos mensajes
  Stream<List<MessageEntity>> watchMessages(String conversationId);

  /// Envía un nuevo mensaje en una conversación
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String content,
  });

  /// Obtiene una conversación existente o crea una nueva
  /// Usado cuando el usuario toca "Contactar al anfitrión"
  Future<Either<Failure, ConversationEntity>> getOrCreateConversation({
    required String listingId,
    required String hostId,
  });

  /// Marca todos los mensajes de una conversación como leídos
  Future<Either<Failure, void>> markMessagesAsRead(String conversationId);

  /// Obtiene el conteo total de mensajes no leídos
  Future<Either<Failure, int>> getUnreadCount();
}
