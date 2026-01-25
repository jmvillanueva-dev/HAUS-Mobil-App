import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/navigation_service.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../../../requests/presentation/pages/requests_page.dart';

/// Página de notificaciones del usuario
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late NotificationBloc _notificationBloc;

  @override
  void initState() {
    super.initState();
    _notificationBloc = GetIt.I<NotificationBloc>();
    _notificationBloc.add(const SubscribeToNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _notificationBloc,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundDark,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
          title: const Text(
            'Notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryDark,
            ),
          ),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoaded &&
                    state.notifications.isNotEmpty) {
                  return TextButton(
                    onPressed: () {
                      _notificationBloc.add(const MarkAllNotificationsAsRead());
                    },
                    child: const Text(
                      'Marcar como leídas',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              );
            }

            if (state is NotificationError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppTheme.textSecondaryDark,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar notificaciones',
                      style: TextStyle(
                        color: AppTheme.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        _notificationBloc.add(const LoadNotifications());
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return _buildEmptyState();
              }
              return _buildNotificationsList(state.notifications);
            }

            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 48,
                color: AppTheme.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin notificaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando recibas mensajes o actualizaciones,\naparecerán aquí',
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

  Widget _buildNotificationsList(List<NotificationEntity> notifications) {
    return RefreshIndicator(
      onRefresh: () async {
        _notificationBloc.add(const LoadNotifications());
      },
      color: AppTheme.primaryColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _NotificationItem(
            notification: notification,
            onTap: () => _handleNotificationTap(notification),
            onDismiss: () {
              _notificationBloc.add(DeleteNotification(notification.id));
            },
          );
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationEntity notification) {
    // Marcar como leída
    if (!notification.isRead) {
      _notificationBloc.add(MarkNotificationAsRead(notification.id));
    }

    final navigationService = GetIt.I<NavigationService>();

    // Navegar según el tipo
    switch (notification.type) {
      case NotificationType.chatMessage:
        final conversationId = notification.data?['conversationId'] as String?;
        if (conversationId != null) {
          final listingTitle = notification.data?['listingTitle'] as String?;
          // Para otros datos, si no están en la data de la notificación guardada,
          // se tendrán que recargar en la página de chat o pasar null.
          navigationService.navigateToChat(
            conversationId: conversationId,
            listingTitle: listingTitle ?? 'Chat',
            otherUserName: notification
                .title, // El título suele ser el nombre del remitente
          );
        }
        break;
      case NotificationType.statusChange:
        // Asumimos que estas notificaciones tienen un listingId
        final listingId = notification.data?['listingId'] as String?;
        if (listingId != null) {
          navigationService.navigateToListing(listingId);
        }
        break;
      case NotificationType.requestReceived:
        navigationService.navigateTo(const RequestsPage());
        break;
      case NotificationType.system:
      default:
        break;
    }
  }
}

/// Item individual de notificación
class _NotificationItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.red,
        ),
      ),
      child: Material(
        color: notification.isRead
            ? AppTheme.surfaceDark
            : AppTheme.surfaceDarkElevated,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: notification.isRead
                    ? AppTheme.borderDark
                    : AppTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono/Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getIconColor().withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: notification.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            notification.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildIcon(),
                          ),
                        )
                      : _buildIcon(),
                ),
                const SizedBox(width: 12),

                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                                color: AppTheme.textPrimaryDark,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondaryDark,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textTertiaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Center(
      child: Icon(
        _getIconData(),
        color: _getIconColor(),
        size: 24,
      ),
    );
  }

  IconData _getIconData() {
    switch (notification.type) {
      case NotificationType.chatMessage:
        return Icons.chat_bubble_rounded;
      case NotificationType.statusChange:
        return Icons.info_rounded;
      case NotificationType.requestReceived:
        return Icons.person_add_rounded;
      case NotificationType.system:
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case NotificationType.chatMessage:
        return AppTheme.primaryColor;
      case NotificationType.statusChange:
        return Colors.blue;
      case NotificationType.requestReceived:
        return AppTheme.primaryColor;
      case NotificationType.system:
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
