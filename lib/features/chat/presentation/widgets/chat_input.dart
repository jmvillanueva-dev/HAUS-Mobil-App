import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget de input para escribir mensajes
class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool enabled;

  const ChatInput({
    super.key,
    required this.onSend,
    this.enabled = true,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleSend() {
    if (!widget.enabled || !_hasText) return;

    final text = _controller.text.trim();
    _controller.clear();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(
          top: BorderSide(color: AppTheme.borderDark),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Campo de texto
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    color: AppTheme.textPrimaryDark,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    hintStyle: TextStyle(
                      color: AppTheme.textTertiaryDark,
                      fontSize: 15,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Botón enviar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _hasText && widget.enabled
                    ? AppTheme.primaryColor
                    : AppTheme.surfaceDark,
                shape: BoxShape.circle,
                border: _hasText && widget.enabled
                    ? null
                    : Border.all(color: AppTheme.borderDark),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _hasText && widget.enabled ? _handleSend : null,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.send_rounded,
                      size: 22,
                      color: _hasText && widget.enabled
                          ? Colors.white
                          : AppTheme.textTertiaryDark,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
