import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

/// Página de conversación individual
class ChatPage extends StatefulWidget {
  final String conversationId;
  final String? listingTitle;
  final String? otherUserName;

  const ChatPage({
    super.key,
    required this.conversationId,
    this.listingTitle,
    this.otherUserName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatBloc _chatBloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _chatBloc = GetIt.I<ChatBloc>();
    // Suscribirse a mensajes en tiempo real
    _chatBloc.add(SubscribeToMessages(widget.conversationId));
    // Marcar mensajes como leídos
    _chatBloc.add(MarkMessagesAsRead(widget.conversationId));
  }

  @override
  void dispose() {
    _chatBloc.add(const UnsubscribeFromMessages());
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _handleSendMessage(String content) {
    _chatBloc.add(SendMessage(
      conversationId: widget.conversationId,
      content: content,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // Lista de mensajes
            Expanded(
              child: _buildMessagesList(),
            ),

            // Input de mensaje
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                final isSending = state is MessageSending;
                return ChatInput(
                  onSend: _handleSendMessage,
                  enabled: !isSending,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.backgroundDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
        style: IconButton.styleFrom(
          foregroundColor: Colors.white,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.otherUserName ?? 'Chat',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryDark,
            ),
          ),
          if (widget.listingTitle != null)
            Text(
              widget.listingTitle!,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryDark,
              ),
            ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppTheme.borderDark,
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        // Scroll al fondo cuando llegan nuevos mensajes
        if (state is MessagesLoaded || state is MessageSent) {
          _scrollToBottom();
        }

        // Mostrar error de envío
        if (state is MessageSendError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is MessagesLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
            ),
          );
        }

        if (state is MessagesError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: AppTheme.textSecondaryDark,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: AppTheme.textSecondaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Obtener mensajes del estado actual
        final messages = _getMessagesFromState(state);

        if (messages.isEmpty) {
          return _buildEmptyChat();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return MessageBubble(
              message: messages[index],
              showTime: true,
            );
          },
        );
      },
    );
  }

  List<dynamic> _getMessagesFromState(ChatState state) {
    if (state is MessagesLoaded) {
      return state.messages;
    }
    if (state is MessageSending) {
      return state.currentMessages;
    }
    if (state is MessageSendError) {
      return state.currentMessages;
    }
    return [];
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.waving_hand_rounded,
              size: 56,
              color: AppTheme.primaryColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Inicia la conversación!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Envía un mensaje para comenzar\na chatear con el anfitrión',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryDark,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
