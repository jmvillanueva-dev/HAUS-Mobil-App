import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/conversation_entity.dart';
import '../repositories/chat_repository.dart';

/// Parámetros para obtener o crear una conversación
class GetOrCreateConversationParams extends Equatable {
  final String listingId;
  final String hostId;

  const GetOrCreateConversationParams({
    required this.listingId,
    required this.hostId,
  });

  @override
  List<Object> get props => [listingId, hostId];
}

/// Caso de uso para obtener una conversación existente o crear una nueva
/// Usado cuando el usuario toca "Contactar al anfitrión"
class GetOrCreateConversationUseCase
    implements UseCase<ConversationEntity, GetOrCreateConversationParams> {
  final ChatRepository repository;

  GetOrCreateConversationUseCase(this.repository);

  @override
  Future<Either<Failure, ConversationEntity>> call(
      GetOrCreateConversationParams params) {
    return repository.getOrCreateConversation(
      listingId: params.listingId,
      hostId: params.hostId,
    );
  }
}
