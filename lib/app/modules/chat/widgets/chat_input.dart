import 'package:ai_voice_chat/app/core/theme/theme.dart';
import 'package:ai_voice_chat/app/modules/chat/controller/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatInput extends GetView<ChatController> {
  const ChatInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Voice Input Button

            // Text Input Field
            Expanded(child: _buildTextField()),
            const SizedBox(width: 12),
            _buildVoiceButton(),
            const SizedBox(width: 12),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return Obx(() {
      final isListening = controller.isListening.value;

      return GestureDetector(
        onTap: controller.toggleVoiceInput,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient:
                isListening
                    ? const LinearGradient(
                      colors: [Colors.red, Colors.redAccent],
                    )
                    : AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:
                    isListening
                        ? Colors.red.withValues(alpha: 0.5)
                        : AppTheme.primaryPurple.withValues(alpha: 0.5),
                blurRadius: isListening ? 20 : 10,
                spreadRadius: isListening ? 2 : 1,
              ),
            ],
          ),
          child: Icon(
            isListening ? Icons.stop : Icons.mic,
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    });
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller.messageController,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Type a message...',
          hintStyle: TextStyle(
            color: AppTheme.textTertiary.withValues(alpha: 0.7),
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          isDense: true,
        ),
        maxLines: null,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => controller.sendTextMessage(),
      ),
    );
  }

  Widget _buildSendButton() {
    return Obx(() {
      final isSending = controller.isSendingMessage.value;
      // final hasText = controller.messageController.text.isNotEmpty;

      return GestureDetector(
        onTap: isSending ? null : controller.sendTextMessage,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient:
                isSending
                    ? LinearGradient(
                      colors: [
                        AppTheme.primaryPurple.withValues(alpha: 0.5),
                        AppTheme.deepPurple.withValues(alpha: 0.5),
                      ],
                    )
                    : AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPurple.withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child:
              isSending
                  ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Icon(Icons.send, color: Colors.white, size: 22),
        ),
      );
    });
  }
}
