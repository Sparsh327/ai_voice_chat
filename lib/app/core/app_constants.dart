import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API Configuration
  static String get openAiApiKey =>
      dotenv.env['openAiApiKey'] ?? 'YOUR_OPENAI_API_KEY_HERE';

  static String get openAiApiUrl =>
      dotenv.env['openAiApiUrl'] ??
      'https://api.openai.com/v1/chat/completions';

  static String get openAiModel => dotenv.env['openAiModel'] ?? 'gpt-3.5-turbo';

  // Supabase Configuration
  static String get supabaseUrl =>
      dotenv.env['supabaseUrl'] ?? 'YOUR_SUPABASE_URL_HERE';

  static String get supabaseAnonKey =>
      dotenv.env['supabaseAnonKey'] ?? 'YOUR_SUPABASE_ANON_KEY_HERE';

  // App Settings
  static const int maxMessagesInHistory = 50;
  static const Duration apiTimeout = Duration(seconds: 30);

  // Voice Settings
  static const String ttsLanguage = 'en-US';
  static const double ttsSpeechRate = 0.5;
  static const double ttsVolume = 1.0;
  static const double ttsPitch = 1.0;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double messageBorderRadius = 20.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
