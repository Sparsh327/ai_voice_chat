import 'dart:developer';

import 'package:ai_voice_chat/app/core/theme/theme.dart';
import 'package:ai_voice_chat/app/modules/chat/controller/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
                GestureDetector(
                  onLongPress: () => _copyToClipboard(context),
                  child: Container(
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
                                  ? AppTheme.primaryPurple.withValues(
                                    alpha: 0.3,
                                  )
                                  : Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Message Text
                        SelectableText(
                          message.content,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),

                        // TTS Button (only for AI messages)
                        if (!isUser) ...[
                          const SizedBox(height: 12),
                          _buildTTSButton(),
                        ],
                      ],
                    ),
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

  Widget _buildTTSButton() {
    return Obx(() {
      // ← Changed from GetBuilder to Obx
      final isPlaying = controller.playingMessageId.value == message.id;

      log('🎨 Building TTS button for ${message.id}');
      log('   isPlaying: $isPlaying');
      log('   playingMessageId: ${controller.playingMessageId.value}');

      return InkWell(
        onTap: () {
          log('👆 TTS button tapped for ${message.id}');
          controller.playMessageAudio(message);
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                isPlaying
                    ? Colors.red.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isPlaying
                      ? Colors.red.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPlaying
                    ? Icons.stop_circle
                    : (message.audioPlayed ? Icons.replay : Icons.volume_up),
                color: isPlaying ? Colors.redAccent : Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                isPlaying
                    ? 'Stop'
                    : (message.audioPlayed ? 'Play Again' : 'Play Audio'),
                style: TextStyle(
                  color: isPlaying ? Colors.redAccent : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message copied to clipboard'),
        backgroundColor: AppTheme.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today - show time only
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else {
      // Other days - show date and time
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$month/$day $hour:$minute';
    }
  }
}
