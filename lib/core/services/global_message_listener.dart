import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

/// Servicio singleton para escuchar mensajes globalmente y notificar al usuario
/// Escucha TODAS las conversaciones del usuario, no solo la abierta
class GlobalMessageListener {
  static final GlobalMessageListener _instance =
      GlobalMessageListener._internal();
  factory GlobalMessageListener() => _instance;
  GlobalMessageListener._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final NotificationService _notificationService = NotificationService();

  RealtimeChannel? _channel;
  bool _isListening = false;

  /// ID del usuario actual
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Iniciar el listener global de mensajes
  Future<void> startListening() async {
    if (_isListening) {
      debugPrint('GlobalMessageListener already listening');
      return;
    }

    final userId = _currentUserId;
    if (userId == null) {
      debugPrint('GlobalMessageListener: No user logged in');
      return;
    }

    await _notificationService.initialize();

    debugPrint('GlobalMessageListener: Starting for user $userId');

    // Escuchar TODOS los mensajes nuevos insertados
    // Luego filtramos solo los que pertenecen a nuestras conversaciones
    _channel = _supabase
        .channel('global_messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) => _handleNewMessage(payload, userId),
        )
        .subscribe();

    _isListening = true;
    debugPrint('GlobalMessageListener: Subscribed to messages');
  }

  /// Detener el listener
  Future<void> stopListening() async {
    if (!_isListening) return;

    await _channel?.unsubscribe();
    _channel = null;
    _isListening = false;
    debugPrint('GlobalMessageListener: Stopped');
  }

  /// Manejar un nuevo mensaje recibido
  Future<void> _handleNewMessage(
      PostgresChangePayload payload, String userId) async {
    try {
      final newRecord = payload.newRecord;
      if (newRecord.isEmpty) return;

      final senderId = newRecord['sender_id'] as String?;
      final conversationId = newRecord['conversation_id'] as String?;
      final messageId = newRecord['id'] as String?;
      final content = newRecord['content'] as String?;

      // Ignorar si es mi propio mensaje
      if (senderId == userId) {
        debugPrint('GlobalMessageListener: Ignoring own message');
        return;
      }

      // Verificar que el mensaje pertenece a una conversación del usuario
      final isMyConversation =
          await _checkIfMyConversation(conversationId, userId);
      if (!isMyConversation) {
        debugPrint('GlobalMessageListener: Message not for my conversations');
        return;
      }

      // Obtener el nombre del remitente
      final senderName = await _getSenderName(senderId);

      debugPrint(
          'GlobalMessageListener: New message from $senderName in $conversationId');

      // Mostrar notificación
      await _notificationService.showChatNotification(
        messageId: messageId ?? DateTime.now().toString(),
        conversationId: conversationId ?? '',
        senderName: senderName ?? 'Nuevo mensaje',
        messageContent: content ?? '',
      );
    } catch (e) {
      debugPrint('GlobalMessageListener error: $e');
    }
  }

  /// Verificar si una conversación pertenece al usuario
  Future<bool> _checkIfMyConversation(
      String? conversationId, String userId) async {
    if (conversationId == null) return false;

    try {
      final response = await _supabase
          .from('conversations')
          .select('id')
          .eq('id', conversationId)
          .or('user_id.eq.$userId,host_id.eq.$userId')
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Obtener el nombre del remitente
  Future<String?> _getSenderName(String? senderId) async {
    if (senderId == null) return null;

    try {
      final response = await _supabase
          .from('profiles')
          .select('first_name, last_name')
          .eq('id', senderId)
          .maybeSingle();

      if (response != null) {
        final firstName = response['first_name'] as String?;
        final lastName = response['last_name'] as String?;
        return '${firstName ?? ''} ${lastName ?? ''}'.trim();
      }
    } catch (e) {
      debugPrint('Error getting sender name: $e');
    }
    return null;
  }
}
