import 'package:flutter/material.dart';

/// Servicio singleton para navegación global desde cualquier parte de la app
/// Usado especialmente para navegar desde notificaciones locales
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  /// GlobalKey para el Navigator principal
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Obtener el contexto actual del navigator
  BuildContext? get context => navigatorKey.currentContext;

  /// Navegar a una ruta específica
  Future<T?>? navigateTo<T>(Widget page) {
    return navigatorKey.currentState?.push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Navegar y reemplazar la pantalla actual
  Future<T?>? navigateAndReplace<T>(Widget page) {
    return navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Volver atrás
  void goBack<T>([T? result]) {
    navigatorKey.currentState?.pop(result);
  }

  /// Navegar al chat por ID de conversación
  void navigateToChat({
    required String conversationId,
    String? listingTitle,
    String? otherUserName,
    String? listingId,
    String? listingImageUrl,
    double? listingPrice,
  }) {
    // Importamos dinámicamente para evitar dependencias circulares
    // La navegación se hace desde main.dart que tiene acceso a todo
    _pendingNavigation = _PendingNavigation(
      type: NavigationType.chat,
      data: {
        'conversationId': conversationId,
        'listingTitle': listingTitle,
        'otherUserName': otherUserName,
        'listingId': listingId,
        'listingImageUrl': listingImageUrl,
        'listingPrice': listingPrice,
      },
    );
    _notifyNavigationListeners();
  }

  /// Navegar a un listing por ID
  void navigateToListing(String listingId) {
    _pendingNavigation = _PendingNavigation(
      type: NavigationType.listing,
      data: {'listingId': listingId},
    );
    _notifyNavigationListeners();
  }

  // Sistema de listeners para navegación pendiente
  _PendingNavigation? _pendingNavigation;
  final List<VoidCallback> _navigationListeners = [];

  /// Obtener navegación pendiente y limpiarla
  _PendingNavigation? consumePendingNavigation() {
    final pending = _pendingNavigation;
    _pendingNavigation = null;
    return pending;
  }

  /// Agregar listener de navegación
  void addNavigationListener(VoidCallback listener) {
    _navigationListeners.add(listener);
  }

  /// Remover listener
  void removeNavigationListener(VoidCallback listener) {
    _navigationListeners.remove(listener);
  }

  void _notifyNavigationListeners() {
    for (final listener in _navigationListeners) {
      listener();
    }
  }
}

enum NavigationType { chat, listing }

class _PendingNavigation {
  final NavigationType type;
  final Map<String, dynamic> data;

  _PendingNavigation({required this.type, required this.data});
}
