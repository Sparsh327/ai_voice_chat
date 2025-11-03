// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Request microphone permission
      final permission = await Permission.microphone.request();

      if (!permission.isGranted) {
        throw Exception('Microphone permission denied');
      }

      // Initialize speech to text
      _isInitialized = await _speechToText.initialize(
        onError: (error) => log('Speech error: $error'),
        onStatus: (status) => log('Speech status: $status'),
      );

      return _isInitialized;
    } catch (e) {
      throw Exception('Failed to initialize speech recognition: $e');
    }
  }

  /// Start listening to user speech
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onPartialResult,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        throw Exception('Speech recognition not initialized');
      }
    }

    if (_isListening) {
      await stopListening();
    }

    try {
      _isListening = true;

      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            // Final result - user stopped speaking
            onResult(result.recognizedWords);
          } else {
            // Partial result - still speaking
            onPartialResult?.call(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30), // Max listening time
        pauseFor: const Duration(seconds: 3), // Auto-stop after pause
        partialResults: true, // Get results while speaking
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    } catch (e) {
      _isListening = false;
      throw Exception('Failed to start listening: $e');
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speechToText.cancel();
      _isListening = false;
    }
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Check if speech recognition is available
  bool get isAvailable => _isInitialized;

  /// Get available locales
  Future<List<String>> getAvailableLocales() async {
    if (!_isInitialized) await initialize();

    final locales = await _speechToText.locales();
    return locales.map((locale) => locale.localeId).toList();
  }

  /// Dispose resources
  void dispose() {
    _speechToText.stop();
    _isListening = false;
  }
}
