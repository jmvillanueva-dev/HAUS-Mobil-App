import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

/// Implementación del repositorio de Chat
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations() async {
    try {
      final conversations = await _remoteDataSource.getConversations();
      return Right(conversations);
    } catch (e) {
      developer.log('Error getting conversations: $e', name: 'ChatRepository');
      return Left(
          ServerFailure('Error al cargar conversaciones: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> getConversation(
      String conversationId) async {
    try {
      final conversation =
          await _remoteDataSource.getConversation(conversationId);
      if (conversation == null) {
        return const Left(ServerFailure('Conversación no encontrada'));
      }
      return Right(conversation);
    } catch (e) {
      developer.log('Error getting conversation: $e', name: 'ChatRepository');
      return Left(
          ServerFailure('Error al cargar conversación: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(
      String conversationId) async {
    try {
      final messages = await _remoteDataSource.getMessages(conversationId);
      return Right(messages);
    } catch (e) {
      developer.log('Error getting messages: $e', name: 'ChatRepository');
      return Left(ServerFailure('Error al cargar mensajes: ${e.toString()}'));
    }
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String conversationId) {
    return _remoteDataSource.watchMessages(conversationId);
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      if (content.trim().isEmpty) {
        return const Left(ServerFailure('El mensaje no puede estar vacío'));
      }

      final message = await _remoteDataSource.sendMessage(
        conversationId: conversationId,
        content: content.trim(),
      );
      return Right(message);
    } catch (e) {
      developer.log('Error sending message: $e', name: 'ChatRepository');
      return Left(ServerFailure('Error al enviar mensaje: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> getOrCreateConversation({
    required String listingId,
    required String hostId,
  }) async {
    try {
      final conversation = await _remoteDataSource.getOrCreateConversation(
        listingId: listingId,
        hostId: hostId,
      );
      return Right(conversation);
    } catch (e) {
      developer.log('Error getting/creating conversation: $e',
          name: 'ChatRepository');
      return Left(
          ServerFailure('Error al iniciar conversación: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead(
      String conversationId) async {
    try {
      await _remoteDataSource.markMessagesAsRead(conversationId);
      return const Right(null);
    } catch (e) {
      developer.log('Error marking messages as read: $e',
          name: 'ChatRepository');
      return Left(ServerFailure('Error al marcar mensajes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      // Por ahora retornamos 0, se puede implementar con una query específica
      return const Right(0);
    } catch (e) {
      developer.log('Error getting unread count: $e', name: 'ChatRepository');
      return Left(ServerFailure(
          'Error al obtener mensajes no leídos: ${e.toString()}'));
    }
  }
}
