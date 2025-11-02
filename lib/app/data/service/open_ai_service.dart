import 'dart:convert';
import 'package:ai_voice_chat/app/core/app_constants.dart';
import 'package:http/http.dart' as http;

import '../models/message_model.dart';

class OpenAIService {
  final String _apiKey = AppConstants.openAiApiKey;
  final String _apiUrl = AppConstants.openAiApiUrl;
  final String _model = AppConstants.openAiModel;

  /// Send message to ChatGPT and get response
  /// Takes full conversation history for context
  Future<String> getChatResponse(List<Message> conversationHistory) async {
    try {
      // Convert messages to OpenAI format
      final messages =
          conversationHistory.map((msg) {
            return {'role': msg.role, 'content': msg.content};
          }).toList();

      // Prepare request body
      final requestBody = {
        'model': _model,
        'messages': messages,
        'temperature': 0.7, // Controls randomness (0-2)
        'max_tokens': 1000, // Maximum response length
      };

      // Make API request
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(AppConstants.apiTimeout);

      // Check response status
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract AI response
        final aiMessage = data['choices'][0]['message']['content'] as String;
        return aiMessage.trim();
      } else {
        // Handle errors
        final error = jsonDecode(response.body);
        throw Exception('OpenAI API Error: ${error['error']['message']}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
          'Request timeout. Please check your internet connection.',
        );
      }
      throw Exception('Failed to get AI response: $e');
    }
  }

  /// Send a single message (for quick testing)
  Future<String> sendMessage(String message) async {
    final messages = [
      Message(
        id: 'temp',
        conversationId: 'temp',
        role: 'user',
        content: message,
        createdAt: DateTime.now(),
      ),
    ];

    return await getChatResponse(messages);
  }

  /// Check if API key is configured
  bool isConfigured() {
    return _apiKey.isNotEmpty && _apiKey != 'YOUR_OPENAI_API_KEY_HERE';
  }

  /// Get token count estimate (rough estimation)
  int estimateTokens(List<Message> messages) {
    int totalChars = 0;
    for (var msg in messages) {
      totalChars += msg.content.length;
    }
    // Rough estimate: 1 token ≈ 4 characters
    return (totalChars / 4).ceil();
  }

  /// Trim conversation history if too long
  List<Message> trimConversationHistory(
    List<Message> messages, {
    int maxTokens = 3000,
  }) {
    // Keep recent messages that fit within token limit
    List<Message> trimmedMessages = [];
    int currentTokens = 0;

    // Start from most recent messages
    for (int i = messages.length - 1; i >= 0; i--) {
      final msg = messages[i];
      final msgTokens = (msg.content.length / 4).ceil();

      if (currentTokens + msgTokens > maxTokens) {
        break;
      }

      trimmedMessages.insert(0, msg);
      currentTokens += msgTokens;
    }

    return trimmedMessages;
  }
}
