import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // ==================== CONVERSATIONS ====================

  /// Get all conversations for a device
  Future<List<Conversation>> getConversations(String deviceId) async {
    try {
      final response = await _client
          .from('conversations')
          .select()
          .eq('user_id', deviceId)
          .eq('is_archived', false)
          .order('updated_at', ascending: false);

      return (response as List)
          .map((json) => Conversation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load conversations: $e');
    }
  }

  /// Create new conversation
  Future<Conversation> createConversation(String deviceId, String title) async {
    try {
      final response =
          await _client
              .from('conversations')
              .insert({'user_id': deviceId, 'title': title})
              .select()
              .single();

      return Conversation.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  /// Update conversation title
  Future<void> updateConversationTitle(
    String conversationId,
    String title,
  ) async {
    try {
      await _client
          .from('conversations')
          .update({
            'title': title,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', conversationId);
    } catch (e) {
      throw Exception('Failed to update conversation: $e');
    }
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _client.from('conversations').delete().eq('id', conversationId);
    } catch (e) {
      throw Exception('Failed to delete conversation: $e');
    }
  }

  /// Archive conversation
  Future<void> archiveConversation(String conversationId) async {
    try {
      await _client
          .from('conversations')
          .update({'is_archived': true})
          .eq('id', conversationId);
    } catch (e) {
      throw Exception('Failed to archive conversation: $e');
    }
  }

  // ==================== MESSAGES ====================

  /// Get all messages for a conversation
  Future<List<Message>> getMessages(String conversationId) async {
    try {
      final response = await _client
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return (response as List).map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  /// Create new message
  Future<Message> createMessage(Message message) async {
    try {
      final response =
          await _client
              .from('messages')
              .insert(message.toJson())
              .select()
              .single();

      return Message.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create message: $e');
    }
  }

  /// Update message (e.g., mark audio as played)
  Future<void> updateMessage(
    String messageId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _client.from('messages').update(updates).eq('id', messageId);
    } catch (e) {
      throw Exception('Failed to update message: $e');
    }
  }

  /// Delete all messages in a conversation
  Future<void> deleteMessages(String conversationId) async {
    try {
      await _client
          .from('messages')
          .delete()
          .eq('conversation_id', conversationId);
    } catch (e) {
      throw Exception('Failed to delete messages: $e');
    }
  }
}
