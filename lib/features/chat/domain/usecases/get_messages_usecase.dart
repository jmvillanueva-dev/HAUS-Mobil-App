import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

/// Parámetros para obtener mensajes de una conversación
class GetMessagesParams extends Equatable {
  final String conversationId;

  const GetMessagesParams({required this.conversationId});

  @override
  List<Object> get props => [conversationId];
}

/// Caso de uso para obtener los mensajes de una conversación
class GetMessagesUseCase
    implements UseCase<List<MessageEntity>, GetMessagesParams> {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<MessageEntity>>> call(GetMessagesParams params) {
    return repository.getMessages(params.conversationId);
  }
}

/// Caso de uso para obtener un stream de mensajes en tiempo real
class WatchMessagesUseCase {
  final ChatRepository repository;

  WatchMessagesUseCase(this.repository);

  Stream<List<MessageEntity>> call(String conversationId) {
    return repository.watchMessages(conversationId);
  }
}
