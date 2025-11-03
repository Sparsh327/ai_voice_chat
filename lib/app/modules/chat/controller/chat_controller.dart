import 'dart:developer';

import 'package:ai_voice_chat/app/data/repo/chat_repo.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/conversation_model.dart';
import '../../../data/models/message_model.dart';

class ChatController extends GetxController {
  final ChatRepository _repository = ChatRepository();

  // ==================== STATE ====================

  // Conversations
  final conversations = <Conversation>[].obs;
  final currentConversation = Rx<Conversation?>(null);

  // Messages
  final messages = <Message>[].obs;

  // UI State
  final isLoading = false.obs;
  final isSendingMessage = false.obs;
  final isListening = false.obs;
  final isSpeaking = false.obs;

  // Input
  final messageController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Auth (for future bonus)
  final isLoggedIn = false.obs;
  final userEmail = ''.obs;

  // ==================== LIFECYCLE ====================

  @override
  void onInit() {
    super.onInit();
    // Add text field listener
    messageController.addListener(() {
      update(); // Rebuild widgets listening to this controller
    });
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      isLoading.value = true;

      // Initialize repository
      await _repository.initialize();

      // Load conversations
      await loadConversations();

      // Create or load first conversation
      if (conversations.isEmpty) {
        await createNewConversation();
      } else {
        await selectConversation(conversations.first);
      }
    } catch (e) {
      _showError('Initialization failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    _repository.dispose();
    super.onClose();
  }

  // ==================== CONVERSATIONS ====================

  /// Load all conversations
  Future<void> loadConversations() async {
    try {
      final convos = await _repository.getConversations();
      conversations.value = convos;
    } catch (e) {
      _showError('Failed to load conversations: $e');
    }
  }

  /// Create new conversation
  Future<void> createNewConversation() async {
    try {
      if (currentConversation.value != null && messages.isEmpty) {
        // Just close the drawer - user is already on an empty chat
        closeDrawer();
        return;
      }
      isLoading.value = true;

      final newConvo = await _repository.createConversation();
      conversations.insert(0, newConvo);
      await selectConversation(newConvo);

      // Close drawer
      closeDrawer();

      Get.snackbar(
        'New Chat',
        'Started a new conversation',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _showError('Failed to create conversation: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Select a conversation
  Future<void> selectConversation(Conversation conversation) async {
    try {
      isLoading.value = true;

      currentConversation.value = conversation;

      // Load messages for this conversation
      final msgs = await _repository.getMessages(conversation.id);
      messages.value = msgs;

      // Close drawer
      closeDrawer();
    } catch (e) {
      _showError('Failed to load conversation: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _repository.deleteConversation(conversationId);

      // Remove from list
      conversations.removeWhere((c) => c.id == conversationId);

      // If deleted current conversation, select another or create new
      if (currentConversation.value?.id == conversationId) {
        if (conversations.isNotEmpty) {
          await selectConversation(conversations.first);
        } else {
          await createNewConversation();
        }
      }

      Get.snackbar(
        'Deleted',
        'Conversation deleted',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _showError('Failed to delete conversation: $e');
    }
  }

  /// Update conversation title
  Future<void> updateConversationTitle(
    String conversationId,
    String title,
  ) async {
    try {
      await _repository.updateConversationTitle(conversationId, title);

      // Update local list
      final index = conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        conversations[index] = conversations[index].copyWith(title: title);
        conversations.refresh();
      }

      // Update current if needed
      if (currentConversation.value?.id == conversationId) {
        currentConversation.value = currentConversation.value?.copyWith(
          title: title,
        );
      }
    } catch (e) {
      _showError('Failed to update title: $e');
    }
  }

  // ==================== MESSAGES ====================

  /// Send text message
  Future<void> sendTextMessage() async {
    final text = messageController.text.trim();

    if (text.isEmpty) return;
    if (currentConversation.value == null) return;

    try {
      isSendingMessage.value = true;

      // Clear input immediately
      messageController.clear();

      // Add user message to UI
      final userMessage = Message(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: currentConversation.value!.id,
        role: 'user',
        content: text,
        createdAt: DateTime.now(),
      );
      messages.add(userMessage);

      // Scroll to bottom
      _scrollToBottom();

      // Send to backend and get AI response
      final aiMessage = await _repository.sendMessage(
        conversationId: currentConversation.value!.id,
        userMessage: text,
        conversationHistory: messages,
      );

      // Add AI message to UI
      messages.add(aiMessage);

      // Update conversation title if first message
      if (messages.length == 2) {
        final title = _repository.generateTitle(text);
        await updateConversationTitle(currentConversation.value!.id, title);
      }

      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      _showError('Failed to send message: $e');
    } finally {
      isSendingMessage.value = false;
    }
  }

  /// Send voice message
  Future<void> sendVoiceMessage(String voiceText) async {
    messageController.text = voiceText;
    await sendTextMessage();
  }

  // ==================== VOICE INPUT ====================

  /// Start listening for voice input
  Future<void> startVoiceInput() async {
    try {
      isListening.value = true;

      await _repository.startListening(
        onResult: (text) {
          // Final result
          isListening.value = false;
          if (text.isNotEmpty) {
            sendVoiceMessage(text);
          }
        },
        onPartialResult: (text) {
          // Show partial result in text field
          messageController.text = text;
        },
      );
    } catch (e) {
      isListening.value = false;
      _showError('Voice input failed: $e');
    }
  }

  /// Stop listening
  Future<void> stopVoiceInput() async {
    try {
      await _repository.stopListening();
      isListening.value = false;
    } catch (e) {
      _showError('Failed to stop listening: $e');
    }
  }

  /// Toggle voice input
  Future<void> toggleVoiceInput() async {
    if (isListening.value) {
      await stopVoiceInput();
    } else {
      await startVoiceInput();
    }
  }

  // ==================== TEXT-TO-SPEECH ====================
  // ==================== STATE (Add these to your existing state variables) ====================

  // Playing state
  final playingMessageId = Rx<String?>(null);

  // ==================== VOICE OUTPUT / TTS ====================

  /// Play message audio
  /// Play message audio
  Future<void> playMessageAudio(Message message) async {
    log('🎵 === Play Audio Requested ===');
    log('Message ID: ${message.id}');
    log('Current playing: ${playingMessageId.value}');

    try {
      // If already playing this message, stop it
      if (playingMessageId.value == message.id) {
        log('⏹️ Same message playing, stopping...');
        await stopAudio();
        return;
      }

      // If playing another message, stop it first
      if (playingMessageId.value != null) {
        log('⏹️ Stopping previous message: ${playingMessageId.value}');
        await _repository.stopSpeaking();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Set playing state BEFORE starting audio
      playingMessageId.value = message.id;
      isSpeaking.value = true;
      log('▶️ Set playing ID: ${playingMessageId.value}');

      // Mark audio as played immediately
      _repository.updateMessage(message.id, {'audio_played': true});

      // Update local message
      final index = messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        messages[index] = messages[index].copyWith(audioPlayed: true);
        messages.refresh();
      }

      // DON'T AWAIT - Start playing in background with callbacks
      _repository.speak(
        message.content,
        onStart: () {
          log('🔊 Audio actually started');
          playingMessageId.value = message.id;
          isSpeaking.value = true;
          update();
        },
        onComplete: () {
          log('✅ Audio completed naturally');
          if (playingMessageId.value == message.id) {
            playingMessageId.value = null;
            isSpeaking.value = false;
            update();
          }
        },
        onError: (error) {
          log('❌ Audio error: $error');
          playingMessageId.value = null;
          isSpeaking.value = false;
          update();
          _showError('Audio playback error: $error');
        },
      );

      // Force immediate UI update
      update();
    } catch (e) {
      log('❌ Exception in playMessageAudio: $e');
      playingMessageId.value = null;
      isSpeaking.value = false;
      update();
      _showError('Failed to play audio: $e');
    }
  }

  /// Stop audio playback
  Future<void> stopAudio() async {
    log('⏹️ Stop audio called');
    try {
      await _repository.stopSpeaking();
      playingMessageId.value = null;
      isSpeaking.value = false;
      update();
      log('✅ Audio stopped successfully');
    } catch (e) {
      log('❌ Error stopping audio: $e');
      _showError('Failed to stop audio: $e');
    }
  }

  /// Pause audio playback
  Future<void> pauseAudio() async {
    log('⏸️ Pause audio called');
    try {
      await _repository.pauseSpeaking();
      update();
    } catch (e) {
      log('❌ Error pausing audio: $e');
      _showError('Failed to pause audio: $e');
    }
  }

  /// Resume audio playback
  Future<void> resumeAudio() async {
    log('▶️ Resume audio called');
    try {
      await _repository.resumeSpeaking();
      update();
    } catch (e) {
      log('❌ Error resuming audio: $e');
      _showError('Failed to resume audio: $e');
    }
  }

  /// Check if message is currently playing
  bool isMessagePlaying(String messageId) {
    return playingMessageId.value == messageId;
  }

  // ==================== UI HELPERS ====================

  /// Open drawer
  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  /// Close drawer
  void closeDrawer() {
    if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
      scaffoldKey.currentState?.closeDrawer();
    }
  }

  /// Scroll to bottom of messages
  void _scrollToBottom() {
    // Will be implemented in view with ScrollController
  }

  /// Show error message
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ==================== AUTH (BONUS - FOR FUTURE) ====================

  /// Show login dialog
  void showLoginDialog() {
    // TODO: Implement login dialog
    Get.snackbar(
      'Login',
      'Login feature coming soon!',
      duration: const Duration(seconds: 2),
    );
  }

  /// Logout
  void logout() {
    isLoggedIn.value = false;
    userEmail.value = '';
    // TODO: Clear user-specific data
  }
}
