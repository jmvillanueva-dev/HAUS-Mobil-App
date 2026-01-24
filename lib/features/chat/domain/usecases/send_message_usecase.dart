import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

/// Parámetros para enviar un mensaje
class SendMessageParams extends Equatable {
  final String conversationId;
  final String content;

  const SendMessageParams({
    required this.conversationId,
    required this.content,
  });

  @override
  List<Object> get props => [conversationId, content];
}

/// Caso de uso para enviar un mensaje en una conversación
class SendMessageUseCase implements UseCase<MessageEntity, SendMessageParams> {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) {
    return repository.sendMessage(
      conversationId: params.conversationId,
      content: params.content,
    );
  }
}
