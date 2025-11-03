import 'package:ai_voice_chat/app/core/theme/theme.dart';
import 'package:ai_voice_chat/app/modules/chat/controller/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../../../data/models/message_model.dart';

class MessageBubble extends GetView<ChatController> {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar (left side)
          if (!isUser) ...[
            _buildAvatar(isUser: false),
            const SizedBox(width: 12),
          ],

          // Message Content
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Message Bubble
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient:
                        isUser
                            ? AppTheme.primaryGradient
                            : AppTheme.messageGradient,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isUser
                                ? AppTheme.primaryPurple.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message Content
                      _buildMessageContent(),

                      // Action Buttons
                      const SizedBox(height: 12),
                      _buildActionButtons(),
                    ],
                  ),
                ),

                // Timestamp
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.createdAt),
                  style: const TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // User Avatar (right side)
          if (isUser) ...[
            const SizedBox(width: 12),
            _buildAvatar(isUser: true),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient:
            isUser
                ? AppTheme.primaryGradient
                : const LinearGradient(
                  colors: [AppTheme.deepPurple, AppTheme.lightPurple],
                ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildMessageContent() {
    final hasCode = _hasCodeBlock(message.content);

    if (hasCode && !message.isUser) {
      // Render with markdown for code blocks
      return MarkdownWidget(
        data: message.content,
        shrinkWrap: true,
        selectable: true,
        config: MarkdownConfig(
          configs: [
            // Pre/Code block config
            PreConfig(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Color(0xFF98C379),
              ),
            ),
            // Inline code config
            CodeConfig(
              style: const TextStyle(
                backgroundColor: Colors.black38,
                color: Color(0xFF98C379),
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
            // Paragraph config
            PConfig(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            // Heading configs
            H1Config(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            H2Config(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            H3Config(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // List config
            // UlConfig(
            //   marker: '•',
            //   style: const TextStyle(
            //     color: AppTheme.lightPurple,
            //     fontSize: 15,
            //   ),
            // ),
            // OlConfig(
            //   style: const TextStyle(
            //     color: AppTheme.lightPurple,
            //     fontSize: 15,
            //   ),
            // ),
          ],
        ),
      );
    } else {
      // Regular selectable text
      return SelectableText(
        message.content,
        style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
      );
    }
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Copy Button
        if (!message.isUser) _buildCopyButton(),

        // TTS Button (only for AI)
        if (!message.isUser) _buildTTSButton(),

        // Copy Code Button (if message has code)
        if (_hasCodeBlock(message.content) && !message.isUser)
          _buildCopyCodeButton(),
      ],
    );
  }

  Widget _buildCopyButton() {
    return _buildActionButton(
      icon: Icons.copy_rounded,
      label: 'Copy',
      onTap: _copyToClipboard,
    );
  }

  Widget _buildCopyCodeButton() {
    return _buildActionButton(
      icon: Icons.code,
      label: 'Copy Code',
      onTap: _copyCodeToClipboard,
      color: AppTheme.lightPurple,
    );
  }

  Widget _buildTTSButton() {
    return Obx(() {
      final isPlaying = controller.playingMessageId.value == message.id;

      return _buildActionButton(
        icon:
            isPlaying
                ? Icons.stop_circle
                : (message.audioPlayed ? Icons.replay : Icons.volume_up),
        label: isPlaying ? 'Stop' : (message.audioPlayed ? 'Replay' : 'Play'),
        onTap: () => controller.playMessageAudio(message),
        color: isPlaying ? Colors.redAccent : null,
        backgroundColor: isPlaying ? Colors.red.withValues(alpha: 0.25) : null,
        borderColor: isPlaying ? Colors.red.withValues(alpha: 0.6) : null,
      );
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor ?? Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color ?? Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color ?? Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: message.content));
    Get.snackbar(
      'Copied!',
      'Message copied to clipboard',
      backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _copyCodeToClipboard() {
    final codeBlocks = _extractCodeBlocks(message.content);
    final allCode = codeBlocks.join('\n\n');

    if (allCode.isEmpty) {
      Get.snackbar(
        'No Code',
        'No code blocks found in message',
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: allCode));
    Get.snackbar(
      'Code Copied!',
      '${codeBlocks.length} code block(s) copied',
      backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  bool _hasCodeBlock(String text) {
    return text.contains('```');
  }

  List<String> _extractCodeBlocks(String text) {
    final codeBlocks = <String>[];
    final regex = RegExp(r'```[\w]*\n([\s\S]*?)```');
    final matches = regex.allMatches(text);

    for (final match in matches) {
      final code = match.group(1);
      if (code != null && code.trim().isNotEmpty) {
        codeBlocks.add(code.trim());
      }
    }

    return codeBlocks;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else {
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$month/$day $hour:$minute';
    }
  }
}
