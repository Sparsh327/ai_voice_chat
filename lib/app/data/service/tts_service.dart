import 'package:ai_voice_chat/app/core/app_constants.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  /// Initialize Text-to-Speech
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set language
      await _flutterTts.setLanguage(AppConstants.ttsLanguage);

      // Set speech rate (speed)
      await _flutterTts.setSpeechRate(AppConstants.ttsSpeechRate);

      // Set volume
      await _flutterTts.setVolume(AppConstants.ttsVolume);

      // Set pitch
      await _flutterTts.setPitch(AppConstants.ttsPitch);

      // Setup callbacks
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        print('TTS Error: $msg');
      });

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize TTS: $e');
    }
  }

  /// Speak text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isSpeaking) {
      await stop();
    }

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      throw Exception('Failed to speak: $e');
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
    }
  }

  /// Pause speaking
  Future<void> pause() async {
    if (_isSpeaking) {
      await _flutterTts.pause();
    }
  }

  /// Check if currently speaking
  bool get isSpeaking => _isSpeaking;

  /// Set speech rate (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  /// Set volume (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume);
  }

  /// Set pitch (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

  /// Set language
  Future<void> setLanguage(String language) async {
    await _flutterTts.setLanguage(language);
  }

  /// Get available languages
  Future<List<String>> getAvailableLanguages() async {
    final languages = await _flutterTts.getLanguages;
    return languages.cast<String>();
  }

  /// Get available voices
  Future<List<Map>> getAvailableVoices() async {
    final voices = await _flutterTts.getVoices;
    return voices.cast<Map>();
  }

  /// Dispose resources
  void dispose() {
    _flutterTts.stop();
    _isSpeaking = false;
  }
}
