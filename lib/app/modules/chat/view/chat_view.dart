import 'package:ai_voice_chat/app/core/theme/theme.dart';
import 'package:ai_voice_chat/app/modules/chat/controller/chat_controller.dart';
import 'package:ai_voice_chat/app/modules/chat/widgets/chat_input.dart';
import 'package:ai_voice_chat/app/modules/chat/widgets/drawer_widget.dart';
import 'package:ai_voice_chat/app/modules/chat/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: AppTheme.darkBackground,

      // App Bar
      appBar: _buildAppBar(),

      // Drawer (Conversation List)
      drawer: const ConversationDrawer(),

      // Body (Chat Messages)
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Obx(() {
          if (controller.isLoading.value && controller.messages.isEmpty) {
            return _buildLoadingState();
          }

          if (controller.currentConversation.value == null) {
            return _buildEmptyState();
          }

          return _buildChatContent();
        }),
      ),
    );
  }

  // ==================== APP BAR ====================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.darkBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppTheme.textPrimary),
        onPressed: controller.openDrawer,
      ),
      title: Obx(() {
        final conversation = controller.currentConversation.value;
        return Text(
          conversation?.title ?? 'AI Chat',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        );
      }),
      actions: [
        // New Chat Button
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
          onPressed: controller.createNewConversation,
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppTheme.primaryPurple.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== CHAT CONTENT ====================

  Widget _buildChatContent() {
    return Column(
      children: [
        // Messages List
        Expanded(
          child: Obx(() {
            if (controller.messages.isEmpty) {
              return _buildWelcomeMessage();
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final reversedList = controller.messages.reversed.toList();
                final message = reversedList[index];
                return MessageBubble(message: message);
              },
            );
          }),
        ),

        // Loading Indicator (when AI is typing)
        Obx(() {
          if (controller.isSendingMessage.value) {
            return _buildTypingIndicator();
          }
          return const SizedBox.shrink();
        }),

        // Input Field
        const ChatInput(),
      ],
    );
  }

  // ==================== STATES ====================

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Loading...',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No conversation selected',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a new chat to get started',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.createNewConversation,
            icon: const Icon(Icons.add),
            label: const Text('New Chat'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI Icon
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.5),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // Welcome Text
            const Text(
              'Hello! 👋',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'I\'m your AI assistant',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 18),
            ),
            const SizedBox(height: 14),

            // Suggestions
            const Text(
              'You can:',
              style: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
            ),
            const SizedBox(height: 16),

            _buildSuggestionChip('Type your message'),
            const SizedBox(height: 8),
            _buildSuggestionChip('Use voice input 🎤'),
            const SizedBox(height: 8),
            _buildSuggestionChip('Listen to responses 🔊'),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppTheme.lightPurple,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: AppTheme.messageBoxDecoration,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
                const SizedBox(width: 8),
                const Text(
                  'AI is thinking...',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = (value - delay).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, -10 * animValue),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.lightPurple.withValues(alpha: animValue),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        // Loop animation
      },
    );
  }
}
