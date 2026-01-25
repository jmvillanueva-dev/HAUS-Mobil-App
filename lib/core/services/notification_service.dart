import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'navigation_service.dart';

/// Servicio singleton para gestionar notificaciones locales
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Cache de IDs de mensajes ya notificados para evitar duplicados
  final Set<String> _notifiedMessageIds = {};

  // Control para saber si la app está en foreground
  bool _isAppInForeground = true;

  // ID del chat actualmente abierto (para no notificar mensajes de ese chat)
  String? _currentOpenChatId;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

    // Configuración para Android
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Inicializar plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Solicitar permisos en Android 13+
    await _requestPermissions();

    _initialized = true;
    debugPrint('✅ NotificationService initialized');
  }

  /// Solicita permisos de notificación
  Future<void> _requestPermissions() async {
    // Android 13+ requiere permisos explícitos
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // iOS siempre requiere permisos
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Maneja el tap en una notificación
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');

    if (response.payload == null) return;

    try {
      // Intentar parsear como payload antiguo 'type:id'
      if (!response.payload!.startsWith('{')) {
        final parts = response.payload!.split(':');
        if (parts.length >= 2) {
          final type = parts[0];
          final id = parts[1];

          if (type == 'chat') {
            final navigationService = GetIt.I<NavigationService>();
            navigationService.navigateToChat(conversationId: id);
          }
        }
        return;
      }

      // Parsear JSON payload
      final data = jsonDecode(response.payload!);
      final type = data['type'] as String?;

      final navigationService = GetIt.I<NavigationService>();

      if (type == 'chat') {
        navigationService.navigateToChat(
          conversationId: data['conversationId'],
          listingTitle: data['listingTitle'],
          otherUserName: data['senderName'],
          listingId: data['listingId'],
          listingImageUrl: data['listingImageUrl'],
          listingPrice: data['listingPrice'] != null
              ? (data['listingPrice'] as num).toDouble()
              : null,
        );
      } else if (type == 'listing') {
        final listingId = data['listingId'];
        if (listingId != null) {
          navigationService.navigateToListing(listingId);
        }
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  /// Establecer si la app está en foreground
  void setAppInForeground(bool inForeground) {
    _isAppInForeground = inForeground;
    debugPrint('App in foreground: $inForeground');
  }

  /// Establecer el chat actualmente abierto
  void setCurrentOpenChat(String? conversationId) {
    _currentOpenChatId = conversationId;
    debugPrint('Current open chat: $conversationId');
  }

  /// Mostrar notificación de nuevo mensaje de chat
  /// Retorna true si la notificación fue mostrada, false si fue omitida
  Future<bool> showChatNotification({
    required String messageId,
    required String conversationId,
    required String senderName,
    required String messageContent,
    String? listingTitle,
    String? listingId,
    String? listingImageUrl,
    double? listingPrice,
  }) async {
    // Evitar notificar si ya se notificó este mensaje
    if (_notifiedMessageIds.contains(messageId)) {
      debugPrint('Message $messageId already notified, skipping');
      return false;
    }

    // Evitar notificar si la app está en foreground y este chat está abierto
    if (_isAppInForeground && _currentOpenChatId == conversationId) {
      debugPrint('Chat $conversationId is open, skipping notification');
      return false;
    }

    // Marcar como notificado
    _notifiedMessageIds.add(messageId);

    // Limitar el tamaño del cache (máximo 500 IDs)
    if (_notifiedMessageIds.length > 500) {
      final toRemove = _notifiedMessageIds.take(100).toList();
      _notifiedMessageIds.removeAll(toRemove);
    }

    const androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Mensajes',
      channelDescription: 'Notificaciones de nuevos mensajes de chat',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Generar ID numérico único para la notificación
    final notificationId = messageId.hashCode;

    // Crear payload JSON rico
    final payloadMap = {
      'type': 'chat',
      'conversationId': conversationId,
      'senderName': senderName,
      'listingTitle': listingTitle,
      'listingId': listingId,
      'listingImageUrl': listingImageUrl,
      'listingPrice': listingPrice,
    };

    try {
      await _notifications.show(
        notificationId,
        '💬 $senderName',
        messageContent,
        details,
        payload: jsonEncode(payloadMap),
      );

      debugPrint('Notification shown for message $messageId from $senderName');
      return true;
    } catch (e) {
      debugPrint('Error showing chat notification: $e');
      return false;
    }
  }

  /// Limpiar el cache de IDs de mensajes notificados
  void clearNotifiedCache() {
    _notifiedMessageIds.clear();
  }

  /// Muestra una notificación de nueva solicitud (para refugios)
  Future<void> showNewRequestNotification({
    required String petName,
    required String adopterName,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'adoption_requests',
      'Solicitudes de Adopción',
      channelDescription: 'Notificaciones de nuevas solicitudes de adopción',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID único
      '🐾 Nueva Solicitud de Adopción',
      '$adopterName quiere adoptar a $petName',
      details,
      payload: 'adoption_request',
    );
  }

  /// Muestra una notificación de cambio de estado (para adoptantes)
  Future<void> showStatusChangeNotification({
    required String petName,
    required String status,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'adoption_status',
      'Estado de Solicitudes',
      channelDescription:
          'Notificaciones de cambios en el estado de solicitudes',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final emoji = status == 'aprobada' ? '✅' : '❌';
    final message = status == 'aprobada'
        ? 'Tu solicitud para adoptar a $petName fue aprobada'
        : 'Tu solicitud para adoptar a $petName fue rechazada';

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID único
      '$emoji Actualización de Solicitud',
      message,
      details,
      payload: 'status_change',
    );
  }

  /// Cancela todas las notificaciones
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
