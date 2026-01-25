import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/message_entity.dart';

/// Widget burbuja de mensaje
class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool showTime;
  final bool showSenderName;

  /// Nombre del otro usuario (fallback cuando senderName no está disponible)
  final String? otherUserName;

  const MessageBubble({
    super.key,
    required this.message,
    this.showTime = true,
    this.showSenderName = true,
    this.otherUserName,
  });

  @override
  Widget build(BuildContext context) {
    // Nombre a mostrar: usar senderName si existe, sino otherUserName
    final displayName = message.senderName ?? otherUserName;

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: message.isMine ? 60 : 0,
          right: message.isMine ? 0 : 60,
        ),
        child: Column(
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Nombre del remitente (solo para mensajes recibidos)
            if (!message.isMine && showSenderName && displayName != null)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),

            // Burbuja del mensaje
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isMine
                    ? AppTheme.primaryColor
                    : AppTheme.surfaceDark,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isMine ? 18 : 4),
                  bottomRight: Radius.circular(message.isMine ? 4 : 18),
                ),
                border: message.isMine
                    ? null
                    : Border.all(color: AppTheme.borderDark),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  color:
                      message.isMine ? Colors.white : AppTheme.textPrimaryDark,
                  height: 1.3,
                ),
              ),
            ),

            // Hora del mensaje y estado de lectura
            if (showTime)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiaryDark,
                      ),
                    ),
                    if (message.isMine) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                        size: 14,
                        color: message.isRead
                            ? AppTheme.primaryColor
                            : AppTheme.textTertiaryDark,
                      ),
                      if (message.isRead) ...[
                        const SizedBox(width: 2),
                        Text(
                          'Leído',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
