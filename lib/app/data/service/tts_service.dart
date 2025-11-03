import 'dart:developer';

import 'package:ai_voice_chat/app/core/app_constants.dart';
import 'package:flutter_tts/flutter_tts.dart';


class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isPaused = false;

  // Callbacks
  Function()? _onStart;
  Function()? _onComplete;
  Function(String)? _onError;

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
        log('🔊 TTS Started');
        _isSpeaking = true;
        _isPaused = false;
        _onStart?.call();
      });

      _flutterTts.setCompletionHandler(() {
        log('✅ TTS Completed');
        _isSpeaking = false;
        _isPaused = false;
        _onComplete?.call();
      });

      _flutterTts.setCancelHandler(() {
        log('❌ TTS Cancelled');
        _isSpeaking = false;
        _isPaused = false;
      });

      _flutterTts.setErrorHandler((msg) {
        log('❌ TTS Error: $msg');
        _isSpeaking = false;
        _isPaused = false;
        _onError?.call(msg);
      });

      _flutterTts.setPauseHandler(() {
        log('⏸️ TTS Paused');
        _isPaused = true;
      });

      _flutterTts.setContinueHandler(() {
        log('▶️ TTS Continued');
        _isPaused = false;
      });

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize TTS: $e');
    }
  }

  /// Speak text
  Future<void> speak(
    String text, {
    Function()? onStart,
    Function()? onComplete,
    Function(String)? onError,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Set callbacks
    _onStart = onStart;
    _onComplete = onComplete;
    _onError = onError;

    if (_isSpeaking) {
      await stop();
    }

    try {
      log(
        '🎤 Speaking: ${text.substring(0, text.length > 50 ? 50 : text.length)}...',
      );
      await _flutterTts.speak(text);
    } catch (e) {
      _isSpeaking = false;
      _isPaused = false;
      throw Exception('Failed to speak: $e');
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    log('⏹️ Stopping TTS');
    if (_isSpeaking || _isPaused) {
      await _flutterTts.stop();
      _isSpeaking = false;
      _isPaused = false;
    }
  }

  /// Pause speaking
  Future<void> pause() async {
    log('⏸️ Pausing TTS');
    if (_isSpeaking && !_isPaused) {
      await _flutterTts.pause();
      _isPaused = true;
    }
  }

  /// Resume speaking
  Future<void> resume() async {
    log('▶️ Resuming TTS');
    if (_isPaused) {
      // Note: flutter_tts doesn't have a resume method
      // We need to stop and restart
      _isPaused = false;
    }
  }

  /// Check if currently speaking
  bool get isSpeaking => _isSpeaking && !_isPaused;

  /// Check if paused
  bool get isPaused => _isPaused;

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
    log('🗑️ Disposing TTS');
    _flutterTts.stop();
    _isSpeaking = false;
    _isPaused = false;
  }
}
