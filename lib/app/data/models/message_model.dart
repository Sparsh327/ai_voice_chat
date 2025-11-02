class Message {
  final String id;
  final String conversationId;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime createdAt;
  final bool audioPlayed;

  Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.audioPlayed = false,
  });

  // From JSON (Supabase response)
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversation_id'],
      role: json['role'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      audioPlayed: json['audio_played'] ?? false,
    );
  }

  // To JSON (for Supabase insert)
  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'role': role,
      'content': content,
      'audio_played': audioPlayed,
    };
  }

  // Check if message is from user
  bool get isUser => role == 'user';

  // Check if message is from AI
  bool get isAssistant => role == 'assistant';

  // Copy with method for updating
  Message copyWith({
    String? id,
    String? conversationId,
    String? role,
    String? content,
    DateTime? createdAt,
    bool? audioPlayed,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      audioPlayed: audioPlayed ?? this.audioPlayed,
    );
  }
}
