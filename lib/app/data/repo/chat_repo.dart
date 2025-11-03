import 'package:ai_voice_chat/app/data/service/device_service.dart';
import 'package:ai_voice_chat/app/data/service/open_ai_service.dart';
import 'package:ai_voice_chat/app/data/service/speech_service.dart';
import 'package:ai_voice_chat/app/data/service/supabase_service.dart';
import 'package:ai_voice_chat/app/data/service/tts_service.dart';

import '../models/conversation_model.dart';
import '../models/message_model.dart';

import 'package:uuid/uuid.dart';

class ChatRepository {
  final SupabaseService _supabaseService = SupabaseService();
  final OpenAIService _openAiService = OpenAIService();
  final SpeechService _speechService = SpeechService();
  final TtsService _ttsService = TtsService();

  String? _deviceId;

  // ==================== INITIALIZATION ====================

  /// Initialize repository and services
  Future<void> initialize() async {
    _deviceId = await DeviceService.getDeviceId();
    await _speechService.initialize();
    await _ttsService.initialize();
  }

  /// Get device ID
  Future<String> getDeviceId() async {
    _deviceId ??= await DeviceService.getDeviceId();
    return _deviceId!;
  }

  // ==================== CONVERSATIONS ====================

  /// Get all conversations
  Future<List<Conversation>> getConversations() async {
    final deviceId = await getDeviceId();
    return await _supabaseService.getConversations(deviceId);
  }

  /// Create new conversation
  Future<Conversation> createConversation({String? title}) async {
    final deviceId = await getDeviceId();
    return await _supabaseService.createConversation(
      deviceId,
      title ?? 'New Chat',
    );
  }

  /// Update conversation title
  Future<void> updateConversationTitle(
    String conversationId,
    String title,
  ) async {
    await _supabaseService.updateConversationTitle(conversationId, title);
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    await _supabaseService.deleteConversation(conversationId);
  }

  /// Archive conversation
  Future<void> archiveConversation(String conversationId) async {
    await _supabaseService.archiveConversation(conversationId);
  }

  // ==================== MESSAGES ====================

  /// Get messages for a conversation
  Future<List<Message>> getMessages(String conversationId) async {
    return await _supabaseService.getMessages(conversationId);
  }

  /// Send user message and get AI response
  Future<Message> sendMessage({
    required String conversationId,
    required String userMessage,
    required List<Message> conversationHistory,
  }) async {
    // 1. Save user message
    final userMsg = Message(
      id: const Uuid().v4(),
      conversationId: conversationId,
      role: 'user',
      content: userMessage,
      createdAt: DateTime.now(),
    );
    await _supabaseService.createMessage(userMsg);

    // 2. Add user message to history
    final updatedHistory = [...conversationHistory, userMsg];

    // 3. Get AI response
    final aiResponse = await _openAiService.getChatResponse(updatedHistory);

    // 4. Save AI message
    final aiMsg = Message(
      id: const Uuid().v4(),
      conversationId: conversationId,
      role: 'assistant',
      content: aiResponse,
      createdAt: DateTime.now(),
    );
    await _supabaseService.createMessage(aiMsg);

    return aiMsg;
  }

  /// Update message
  Future<void> updateMessage(
    String messageId,
    Map<String, dynamic> updates,
  ) async {
    await _supabaseService.updateMessage(messageId, updates);
  }

  // ==================== VOICE SERVICES ====================

  /// Start listening for voice input
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onPartialResult,
  }) async {
    await _speechService.startListening(
      onResult: onResult,
      onPartialResult: onPartialResult,
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    await _speechService.stopListening();
  }

  /// Check if listening
  bool get isListening => _speechService.isListening;

  /// Speak text
  Future<void> speak(
    String text, {
    Function()? onStart,
    Function()? onComplete,
    Function(String)? onError,
  }) async {
    await _ttsService.speak(
      text,
      onStart: onStart,
      onComplete: onComplete,
      onError: onError,
    );
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _ttsService.stop();
  }

  /// Check if speaking
  bool get isSpeaking => _ttsService.isSpeaking;

  /// Pause speaking
  Future<void> pauseSpeaking() async {
    await _ttsService.pause();
  }

  bool get isTtsPaused => _ttsService.isPaused;

  /// Resume speaking
  Future<void> resumeSpeaking() async {
    await _ttsService.resume();
  }

  // ==================== UTILITIES ====================

  /// Check if OpenAI is configured
  bool isOpenAIConfigured() {
    return _openAiService.isConfigured();
  }

  /// Generate conversation title from first message
  String generateTitle(String firstMessage) {
    if (firstMessage.length <= 30) {
      return firstMessage;
    }
    return '${firstMessage.substring(0, 30)}...';
  }

  /// Dispose resources
  void dispose() {
    _speechService.dispose();
    _ttsService.dispose();
  }
}
