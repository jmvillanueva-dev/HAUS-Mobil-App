import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

/// Servicio singleton para escuchar notificaciones globalmente y notificar al usuario
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

  /// Iniciar el listener global de notificaciones
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

    // Escuchar tabla de notificaciones
    _channel = _supabase
        .channel('global_notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) => _handleNewNotification(payload),
        )
        .subscribe();

    _isListening = true;
    debugPrint('GlobalMessageListener: Subscribed to notifications');
  }

  /// Detener el listener
  Future<void> stopListening() async {
    if (!_isListening) return;

    await _channel?.unsubscribe();
    _channel = null;
    _isListening = false;
    debugPrint('GlobalMessageListener: Stopped');
  }

  /// Manejar una nueva notificación recibida
  Future<void> _handleNewNotification(PostgresChangePayload payload) async {
    try {
      final newRecord = payload.newRecord;
      if (newRecord.isEmpty) return;

      final type = newRecord['type'] as String?;
      final title = newRecord['title'] as String?;
      final body = newRecord['body'] as String?;
      final data = newRecord['data'] as Map<String, dynamic>?;

      debugPrint('GlobalMessageListener: New notification of type $type');

      if (type == 'chat_message') {
        // Para mensajes de chat, usamos el método específico que maneja lógica extra
        await _notificationService.showChatNotification(
          messageId: data?['messageId'] ?? DateTime.now().toString(),
          conversationId: data?['conversationId'] ?? '',
          senderName: title ?? 'Nuevo mensaje',
          messageContent: body ?? '',
          listingTitle: data?['listingTitle'],
          listingId: data?['listingId'],
          listingPrice: (data?['listingPrice'] as num?)?.toDouble(),
          listingImageUrl: data?['listingImage'],
        );
      } else if (type == 'match_request') {
        // Notificación de Like/Solicitud
        await _notificationService.showNewRequestNotification(
          petName: 'tu perfil', // Adaptado para contexto de roomies
          adopterName: body?.split(' quiere').first ?? 'Alguien',
        );
      } else if (type == 'new_match') {
        // Notificación de Match
        await _notificationService.showStatusChangeNotification(
          petName: 'tu perfil', // Adaptado
          status:
              'aprobada', // Reusamos lógica de "aprobada" para mostrar check verde
        );
      }
    } catch (e) {
      debugPrint('GlobalMessageListener error: $e');
    }
  }
}
