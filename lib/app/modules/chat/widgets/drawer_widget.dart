import 'package:ai_voice_chat/app/core/theme/theme.dart';
import 'package:ai_voice_chat/app/modules/chat/controller/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ConversationDrawer extends GetView<ChatController> {
  const ConversationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.darkBackground,
      child: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // New Chat Button
            _buildNewChatButton(),

            const Divider(color: AppTheme.surfaceColor, height: 1),

            // Conversations List
            Expanded(
              child: Obx(() {
                if (controller.conversations.isEmpty) {
                  return _buildEmptyList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: controller.conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = controller.conversations[index];
                    final isSelected =
                        controller.currentConversation.value?.id ==
                        conversation.id;

                    return _buildConversationTile(conversation, isSelected);
                  },
                );
              }),
            ),

            const Divider(color: AppTheme.surfaceColor, height: 1),

            // Footer (Settings, Login - Future)
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your conversations',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewChatButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: controller.createNewConversation,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'New Chat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationTile(conversation, bool isSelected) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await Get.dialog<bool>(
              AlertDialog(
                backgroundColor: AppTheme.cardBackground,
                title: const Text(
                  'Delete Chat?',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                content: const Text(
                  'This conversation will be permanently deleted.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) {
        controller.deleteConversation(conversation.id);
      },
      child: InkWell(
        onTap: () => controller.selectConversation(conversation),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppTheme.primaryPurple.withValues(alpha: 0.2)
                    : AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected ? null : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Title and Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.title,
                      style: TextStyle(
                        color:
                            isSelected
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(conversation.updatedAt),
                      style: const TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyList() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: AppTheme.textTertiary,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Start a new chat to begin',
              style: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Settings (Future)
        ListTile(
          leading: const Icon(Icons.settings, color: AppTheme.textSecondary),
          title: const Text(
            'Settings',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          onTap: () {
            Get.back();
            Get.snackbar('Settings', 'Coming soon!');
          },
        ),

        // Login (Future Bonus)
        Obx(() {
          if (controller.isLoggedIn.value) {
            return ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.textSecondary),
              title: Text(
                'Logout (${controller.userEmail.value})',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              onTap: controller.logout,
            );
          } else {
            return ListTile(
              leading: const Icon(Icons.login, color: AppTheme.primaryPurple),
              title: const Text(
                'Login / Sign Up',
                style: TextStyle(color: AppTheme.primaryPurple),
              ),
              onTap: controller.showLoginDialog,
            );
          }
        }),

        const SizedBox(height: 8),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
