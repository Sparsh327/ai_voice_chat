import 'dart:developer';

import 'package:ai_voice_chat/app/data/service/open_ai_service.dart';
import 'package:ai_voice_chat/app/data/service/speech_service.dart';
import 'package:ai_voice_chat/app/data/service/tts_service.dart';

Future<void> testOpenAI() async {
  final openAI = OpenAIService();

  // Check if configured
  if (!openAI.isConfigured()) {
    log('❌ OpenAI API key not configured!');
    log('Add your API key to app_constants.dart');
    return;
  }

  log('✅ OpenAI configured');
  log('🤖 Testing ChatGPT...');

  try {
    // Test simple message
    final response = await openAI.sendMessage('Say hello in three sentence');
    log('✅ Response: $response');
  } catch (e) {
    log('❌ Error: $e');
  }
}

Future<void> testVoiceServices() async {
  log('🎤 Testing Voice Services...\n');

  // Test TTS
  log('🔊 Testing Text-to-Speech...');
  final tts = TtsService();
  await tts.initialize();
  await tts.speak('Hello! Text to speech is working perfectly.');
  log('✅ TTS working\n');

  // Wait for TTS to finish
  await Future.delayed(const Duration(seconds: 3));

  // Test Speech Recognition
  log('🎤 Testing Speech Recognition...');
  final speech = SpeechService();
  final initialized = await speech.initialize();

  if (initialized) {
    log('✅ Speech recognition available');
    log('Say something...');

    await speech.startListening(
      onResult: (text) {
        log('✅ You said: $text');
      },
      onPartialResult: (text) {
        log('👂 Listening: $text');
      },
    );

    // Listen for 5 seconds
    await Future.delayed(const Duration(seconds: 5));
    await speech.stopListening();
  } else {
    log('❌ Speech recognition not available');
  }
}
