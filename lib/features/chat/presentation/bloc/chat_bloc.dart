import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

/// BLoC para gestionar el estado del chat
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;

  StreamSubscription<List<MessageEntity>>? _messagesSubscription;
  List<MessageEntity> _currentMessages = [];

  ChatBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(const ChatInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<LoadMessages>(_onLoadMessages);
    on<SubscribeToMessages>(_onSubscribeToMessages);
    on<UnsubscribeFromMessages>(_onUnsubscribeFromMessages);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<SendMessage>(_onSendMessage);
    on<CreateConversation>(_onCreateConversation);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
  }

  /// Cargar lista de conversaciones
  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ConversationsLoading());

    final result = await _chatRepository.getConversations();

    result.fold(
      (failure) {
        developer.log('Error loading conversations: ${failure.message}',
            name: 'ChatBloc');
        emit(ConversationsError(failure.message));
      },
      (conversations) {
        developer.log('Loaded ${conversations.length} conversations',
            name: 'ChatBloc');
        emit(ConversationsLoaded(conversations));
      },
    );
  }

  /// Cargar mensajes de una conversación (una vez)
  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(const MessagesLoading());

    final result = await _chatRepository.getMessages(event.conversationId);

    result.fold(
      (failure) {
        developer.log('Error loading messages: ${failure.message}',
            name: 'ChatBloc');
        emit(MessagesError(failure.message));
      },
      (messages) {
        _currentMessages = messages;
        developer.log('Loaded ${messages.length} messages', name: 'ChatBloc');
        emit(MessagesLoaded(messages: messages));
      },
    );
  }

  /// Suscribirse a mensajes en tiempo real
  Future<void> _onSubscribeToMessages(
    SubscribeToMessages event,
    Emitter<ChatState> emit,
  ) async {
    // Cancelar suscripción anterior si existe
    await _messagesSubscription?.cancel();

    emit(const MessagesLoading());

    developer.log('Subscribing to messages: ${event.conversationId}',
        name: 'ChatBloc');

    _messagesSubscription =
        _chatRepository.watchMessages(event.conversationId).listen(
      (messages) {
        developer.log('Realtime update: ${messages.length} messages',
            name: 'ChatBloc');
        add(MessagesUpdated(messages));
      },
      onError: (error) {
        developer.log('Realtime error: $error', name: 'ChatBloc');
        add(MessagesUpdated(const []));
      },
    );
  }

  /// Cancelar suscripción a mensajes
  Future<void> _onUnsubscribeFromMessages(
    UnsubscribeFromMessages event,
    Emitter<ChatState> emit,
  ) async {
    developer.log('Unsubscribing from messages', name: 'ChatBloc');
    await _messagesSubscription?.cancel();
    _messagesSubscription = null;
  }

  /// Mensajes actualizados desde Realtime
  void _onMessagesUpdated(
    MessagesUpdated event,
    Emitter<ChatState> emit,
  ) {
    final messages = event.messages.cast<MessageEntity>();
    _currentMessages = messages;
    emit(MessagesLoaded(messages: messages));
  }

  /// Enviar mensaje
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (event.content.trim().isEmpty) return;

    emit(MessageSending(_currentMessages));

    final result = await _chatRepository.sendMessage(
      conversationId: event.conversationId,
      content: event.content,
    );

    result.fold(
      (failure) {
        developer.log('Error sending message: ${failure.message}',
            name: 'ChatBloc');
        emit(MessageSendError(failure.message, _currentMessages));
        // Volver al estado de mensajes cargados
        emit(MessagesLoaded(messages: _currentMessages));
      },
      (message) {
        developer.log('Message sent: ${message.id}', name: 'ChatBloc');
        // El mensaje llegará por Realtime, pero emitimos para feedback inmediato
        emit(MessageSent(message));
        // Nota: No actualizamos _currentMessages aquí porque
        // llegará automáticamente por el stream de Realtime
      },
    );
  }

  /// Crear o obtener conversación existente
  Future<void> _onCreateConversation(
    CreateConversation event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ConversationCreating());

    final result = await _chatRepository.getOrCreateConversation(
      listingId: event.listingId,
      hostId: event.hostId,
    );

    result.fold(
      (failure) {
        developer.log('Error creating conversation: ${failure.message}',
            name: 'ChatBloc');
        emit(ConversationCreateError(failure.message));
      },
      (conversation) {
        developer.log('Conversation ready: ${conversation.id}',
            name: 'ChatBloc');
        emit(ConversationCreated(conversation));
      },
    );
  }

  /// Marcar mensajes como leídos
  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsRead event,
    Emitter<ChatState> emit,
  ) async {
    await _chatRepository.markMessagesAsRead(event.conversationId);
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
