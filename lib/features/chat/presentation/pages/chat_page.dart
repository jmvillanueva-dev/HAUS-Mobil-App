import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../listings/domain/entities/listing_entity.dart';
import '../../../listings/presentation/pages/listing_detail_page.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/listing_chat_header.dart';
import '../../../financial/domain/repositories/financial_repository.dart';
import '../../../financial/presentation/pages/my_rent_page.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../auth/domain/usecases/get_feature_access.dart';
import '../../../subscription/presentation/pages/subscription_page.dart';

/// Página de conversación individual
class ChatPage extends StatefulWidget {
  final String conversationId;
  final String? listingId;
  final String? listingTitle;
  final String? listingImageUrl;
  final double? listingPrice;
  final String? otherUserName;

  const ChatPage({
    super.key,
    required this.conversationId,
    this.listingId,
    this.listingTitle,
    this.listingImageUrl,
    this.listingPrice,
    this.otherUserName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatBloc _chatBloc;
  final ScrollController _scrollController = ScrollController();

  // Variables locales para datos del listing (pueden venir del widget o cargarse)
  String? _listingId;
  String? _listingTitle;
  String? _listingImageUrl;
  double? _listingPrice;

  @override
  void initState() {
    super.initState();

    // Inicializar data local
    _listingId = widget.listingId;
    _listingTitle = widget.listingTitle;
    _listingImageUrl = widget.listingImageUrl;
    _listingPrice = widget.listingPrice;

    _chatBloc = GetIt.I<ChatBloc>();
    // Suscribirse a mensajes en tiempo real
    _chatBloc.add(SubscribeToMessages(widget.conversationId));
    // Marcar mensajes como leídos
    _chatBloc.add(MarkMessagesAsRead(widget.conversationId));

    // Si faltan datos del listing, intentar cargarlos
    if (_listingTitle == null || _listingId == null) {
      _loadConversationDetails();
    }
  }

  Future<void> _loadConversationDetails() async {
    try {
      final supabase = GetIt.I<SupabaseClient>();
      // Obtener listings asociados a esta conversación
      final response = await supabase
          .from('conversations')
          .select('listings(id, title, price, image_urls)')
          .eq('id', widget.conversationId)
          .maybeSingle();

      if (response != null && response['listings'] != null && mounted) {
        final listing = response['listings'];
        setState(() {
          _listingId = listing['id'];
          _listingTitle = listing['title'];
          _listingPrice = (listing['price'] as num?)?.toDouble();

          final images = listing['image_urls'] as List?;
          if (images != null && images.isNotEmpty) {
            _listingImageUrl = images[0] as String;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading conversation details: $e');
    }
  }

  @override
  void dispose() {
    _chatBloc.add(const UnsubscribeFromMessages());
    _scrollController.dispose();
    super.dispose();
  }

  // Con reverse: true en el ListView, el scroll automáticamente
  // muestra los mensajes más recientes sin necesidad de scrollToBottom

  void _handleSendMessage(String content) {
    _chatBloc.add(SendMessage(
      conversationId: widget.conversationId,
      content: content,
    ));
  }

  Future<void> _navigateToRent() async {
    if (_listingId == null) return;

    try {
      // 1. Verificar suscripción del usuario actual
      final getCurrentUser = GetIt.I<GetCurrentUser>();
      final userResult = await getCurrentUser(NoParams());

      final user = userResult.fold((_) => null, (u) => u);

      if (user != null) {
        final getAccess = GetFeatureAccess();
        final isHost = user.id == (await _fetchListingOwnerId(_listingId!));

        if (isHost) {
          final canAccess = getAccess(
            tier: user.subscriptionTier,
            featureId: 'receive_payments',
          );

          if (!canAccess) {
            if (mounted) _showUpgradeDialog(context);
            return;
          }
        }
      }

      // Mostrar feedback visual
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Buscando contrato de renta...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      final repository = GetIt.I<FinancialRepository>();
      final contracts = await repository.getContracts();

      // Buscar contrato activo para este listing
      final contract = contracts.firstWhere(
        (c) => c.listingId == _listingId && c.status == 'active',
        orElse: () => throw Exception('No se encontró un contrato activo'),
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MyRentPage(contract: contract),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No tienes contrato activo para este listing'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<String?> _fetchListingOwnerId(String listingId) async {
    try {
      final supabase = GetIt.I<SupabaseClient>();
      final response = await supabase
          .from('listings')
          .select('user_id')
          .eq('id', listingId)
          .maybeSingle();
      return response?['user_id'] as String?;
    } catch (_) {
      return null;
    }
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title:
            const Text('Mejora tu Plan', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Para gestionar tus rentas y recibir pagos directamente en la app, necesitas un plan Pro o Business.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ver Planes'),
          ),
        ],
      ),
    );
  }

  /// Navegar al detalle del listing
  Future<void> _navigateToListingDetail() async {
    if (_listingId == null) return;

    try {
      // Obtener el listing desde Supabase
      final supabase = GetIt.I<SupabaseClient>();
      final response = await supabase
          .from('listings')
          .select()
          .eq('id', _listingId!)
          .maybeSingle();

      if (response != null && mounted) {
        final listing = ListingEntity(
          id: response['id'] as String,
          userId: response['user_id'] as String? ?? '',
          title: response['title'] as String,
          description: response['description'] as String? ?? '',
          price: (response['price'] as num).toDouble(),
          housingType: response['housing_type'] as String? ?? '',
          city: response['city'] as String? ?? '',
          neighborhood: response['neighborhood'] as String? ?? '',
          address: response['address'] as String? ?? '',
          latitude: response['latitude'] != null
              ? (response['latitude'] as num).toDouble()
              : null,
          longitude: response['longitude'] != null
              ? (response['longitude'] as num).toDouble()
              : null,
          amenities: List<String>.from(response['amenities'] ?? []),
          houseRules: List<String>.from(response['house_rules'] ?? []),
          imageUrls: List<String>.from(response['image_urls'] ?? []),
          createdAt: response['created_at'] != null
              ? DateTime.parse(response['created_at'] as String)
              : null,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailPage(listing: listing),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error navigating to listing: $e');
    }
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
            // Card del listing (si hay datos)
            ListingChatHeader(
              listingTitle: _listingTitle,
              listingImageUrl: _listingImageUrl,
              listingPrice: _listingPrice,
              onTap:
                  _listingId != null ? () => _navigateToListingDetail() : null,
            ),

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
      actions: [
        if (_listingId != null)
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded,
                color: AppTheme.primaryColor),
            tooltip: 'Mi Renta',
            onPressed: _navigateToRent,
          ),
      ],
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
        // Con reverse: true, no necesitamos hacer scroll manual
        // Los mensajes nuevos aparecen automáticamente al final

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

        // Usando reverse: true para que los mensajes nuevos aparezcan abajo
        // y el scroll automáticamente muestre el último mensaje
        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            // Invertir índice porque la lista está en reverse
            final reversedIndex = messages.length - 1 - index;
            return MessageBubble(
              message: messages[reversedIndex],
              showTime: true,
              otherUserName: widget.otherUserName,
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
    if (state is MessageSent) {
      return state.currentMessages;
    }
    if (state is MessageSendError) {
      return state.currentMessages;
    }
    return [];
  }

  Widget _buildEmptyChat() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),
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
