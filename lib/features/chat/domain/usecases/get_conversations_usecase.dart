import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/conversation_entity.dart';
import '../repositories/chat_repository.dart';

/// Caso de uso para obtener la lista de conversaciones del usuario
class GetConversationsUseCase
    implements UseCase<List<ConversationEntity>, NoParams> {
  final ChatRepository repository;

  GetConversationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ConversationEntity>>> call(NoParams params) {
    return repository.getConversations();
  }
}
