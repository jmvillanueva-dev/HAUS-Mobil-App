import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/conversation_tile.dart';
import 'chat_page.dart';

/// Página que muestra la lista de conversaciones del usuario
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = GetIt.I<ChatBloc>();
    // Cargar conversaciones y suscribirse a cambios en tiempo real
    _chatBloc.add(const LoadConversations());
    _chatBloc.add(const SubscribeToConversations());
  }

  @override
  void dispose() {
    _chatBloc.add(const UnsubscribeFromConversations());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: const _ChatListView(),
    );
  }
}

class _ChatListView extends StatelessWidget {
  const _ChatListView();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ChatBloc>().add(const LoadConversations());
        // Esperar un poco para dar feedback visual
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppTheme.primaryColor,
      backgroundColor: AppTheme.surfaceDark,
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ConversationsLoading) {
            return _buildLoading();
          }

          if (state is ConversationsError) {
            return _buildError(context, state.message);
          }

          if (state is ConversationsLoaded) {
            if (state.conversations.isEmpty) {
              return _buildEmpty();
            }
            return _buildList(context, state);
          }

          // Estado inicial - cargar conversaciones
          return _buildLoading();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppTheme.textSecondaryDark,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: AppTheme.textSecondaryDark,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                context.read<ChatBloc>().add(const LoadConversations());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.2),
                    AppTheme.primaryColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: AppTheme.primaryColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin conversaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contacta a un anfitrión desde\nel detalle de una publicación',
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

  Widget _buildList(BuildContext context, ConversationsLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.conversations.length,
      itemBuilder: (context, index) {
        final conversation = state.conversations[index];
        return ConversationTile(
          conversation: conversation,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  conversationId: conversation.id,
                  listingId: conversation.listingId,
                  listingTitle: conversation.listingTitle,
                  listingImageUrl: conversation.listingImageUrl,
                  otherUserName: conversation.otherUserName,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
