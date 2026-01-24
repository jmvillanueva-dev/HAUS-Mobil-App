import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/conversation_entity.dart';

/// Widget tile para mostrar una conversación en la lista
class ConversationTile extends StatelessWidget {
  final ConversationEntity conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Imagen del listing
                _buildListingImage(),
                const SizedBox(width: 12),

                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título del listing
                      Text(
                        conversation.listingTitle ?? 'Sin título',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Nombre del otro usuario
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: AppTheme.textSecondaryDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            conversation.otherUserName ?? 'Usuario',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Último mensaje
                      if (conversation.lastMessageContent != null)
                        Text(
                          conversation.lastMessageContent!,
                          style: TextStyle(
                            fontSize: 13,
                            color: conversation.unreadCount > 0
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textSecondaryDark,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Timestamp y badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Tiempo del último mensaje
                    Text(
                      _formatTime(conversation.lastMessageAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Badge de no leídos
                    if (conversation.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          conversation.unreadCount.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListingImage() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: conversation.listingImageUrl != null
            ? Image.network(
                conversation.listingImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.surfaceDark,
      child: Icon(
        Icons.home_rounded,
        size: 28,
        color: AppTheme.textTertiaryDark,
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }
}
