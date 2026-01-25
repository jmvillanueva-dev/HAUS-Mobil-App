import 'package:equatable/equatable.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';

/// Estados del ChatBloc
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ChatInitial extends ChatState {
  const ChatInitial();
}

// ====== Estados de Conversaciones ======

/// Cargando lista de conversaciones
class ConversationsLoading extends ChatState {
  const ConversationsLoading();
}

/// Conversaciones cargadas exitosamente
class ConversationsLoaded extends ChatState {
  final List<ConversationEntity> conversations;

  const ConversationsLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

/// Error al cargar conversaciones
class ConversationsError extends ChatState {
  final String message;

  const ConversationsError(this.message);

  @override
  List<Object?> get props => [message];
}

// ====== Estados de Mensajes ======

/// Cargando mensajes de una conversación
class MessagesLoading extends ChatState {
  const MessagesLoading();
}

/// Mensajes cargados exitosamente
class MessagesLoaded extends ChatState {
  final List<MessageEntity> messages;
  final ConversationEntity? conversation;

  const MessagesLoaded({
    required this.messages,
    this.conversation,
  });

  @override
  List<Object?> get props => [messages, conversation];
}

/// Error al cargar mensajes
class MessagesError extends ChatState {
  final String message;

  const MessagesError(this.message);

  @override
  List<Object?> get props => [message];
}

// ====== Estados de Envío de Mensaje ======

/// Enviando mensaje
class MessageSending extends ChatState {
  final List<MessageEntity> currentMessages;

  const MessageSending(this.currentMessages);

  @override
  List<Object?> get props => [currentMessages];
}

/// Mensaje enviado exitosamente
class MessageSent extends ChatState {
  final MessageEntity message;
  final List<MessageEntity> currentMessages;

  const MessageSent(this.message, this.currentMessages);

  @override
  List<Object?> get props => [message, currentMessages];
}

/// Error al enviar mensaje
class MessageSendError extends ChatState {
  final String message;
  final List<MessageEntity> currentMessages;

  const MessageSendError(this.message, this.currentMessages);

  @override
  List<Object?> get props => [message, currentMessages];
}

// ====== Estados de Creación de Conversación ======

/// Creando/obteniendo conversación
class ConversationCreating extends ChatState {
  const ConversationCreating();
}

/// Conversación creada/obtenida exitosamente
class ConversationCreated extends ChatState {
  final ConversationEntity conversation;

  const ConversationCreated(this.conversation);

  @override
  List<Object?> get props => [conversation];
}

/// Error al crear conversación
class ConversationCreateError extends ChatState {
  final String message;

  const ConversationCreateError(this.message);

  @override
  List<Object?> get props => [message];
}
