import 'package:equatable/equatable.dart';

/// Eventos del ChatBloc
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar lista de conversaciones
class LoadConversations extends ChatEvent {
  const LoadConversations();
}

/// Suscribirse a conversaciones en tiempo real
class SubscribeToConversations extends ChatEvent {
  const SubscribeToConversations();
}

/// Cancelar suscripción a conversaciones
class UnsubscribeFromConversations extends ChatEvent {
  const UnsubscribeFromConversations();
}

/// Conversaciones actualizadas (desde Realtime)
class ConversationsUpdated extends ChatEvent {
  const ConversationsUpdated();
}

/// Cargar mensajes de una conversación específica
class LoadMessages extends ChatEvent {
  final String conversationId;

  const LoadMessages(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Suscribirse a mensajes en tiempo real
class SubscribeToMessages extends ChatEvent {
  final String conversationId;

  const SubscribeToMessages(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Cancelar suscripción a mensajes
class UnsubscribeFromMessages extends ChatEvent {
  const UnsubscribeFromMessages();
}

/// Mensajes actualizados (desde Realtime stream)
class MessagesUpdated extends ChatEvent {
  final List<dynamic> messages;

  const MessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// Enviar mensaje
class SendMessage extends ChatEvent {
  final String conversationId;
  final String content;

  const SendMessage({
    required this.conversationId,
    required this.content,
  });

  @override
  List<Object?> get props => [conversationId, content];
}

/// Crear o obtener conversación existente
class CreateConversation extends ChatEvent {
  final String listingId;
  final String hostId;

  const CreateConversation({
    required this.listingId,
    required this.hostId,
  });

  @override
  List<Object?> get props => [listingId, hostId];
}

/// Marcar mensajes como leídos
class MarkMessagesAsRead extends ChatEvent {
  final String conversationId;

  const MarkMessagesAsRead(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}
