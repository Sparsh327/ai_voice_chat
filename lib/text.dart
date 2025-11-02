// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class VoiceWaveDemo extends StatefulWidget {
//   const VoiceWaveDemo({super.key});

//   @override
//   _VoiceWaveDemoState createState() => _VoiceWaveDemoState();
// }

// class _VoiceWaveDemoState extends State<VoiceWaveDemo>
//     with SingleTickerProviderStateMixin {
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   bool _isListening = false;
//   double _soundLevel = 0.0;
//   String _text = '';

//   Future<void> _listen() async {
//     if (!_isListening) {
//       bool available = await _speech.initialize(
//         onStatus: (val) => print('onStatus: $val'),
//         onError: (val) => print('onError: $val'),
//       );
//       if (available) {
//         setState(() => _isListening = true);
//         _speech.listen(
//           onResult: (result) {
//             setState(() => _text = result.recognizedWords);
//           },
//           listenMode: stt.ListenMode.confirmation,
//           onSoundLevelChange: (level) {
//             setState(() {
//               _soundLevel = level; // 👈 mic loudness changes here
//             });
//           },
//         );
//       }
//     } else {
//       setState(() => _isListening = false);
//       _speech.stop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double scaledLevel = (_soundLevel / 50).clamp(0.0, 1.0);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Voice Waveform Demo')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // 🔊 Animated circle for sound level
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 10),
//               width: 100 + scaledLevel * 100,
//               height: 100 + scaledLevel * 100,
//               decoration: BoxDecoration(
//                 color: Colors.blueAccent.withOpacity(0.6),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.mic, color: Colors.white, size: 50),
//             ),
//             const SizedBox(height: 40),
//             // Text(
//             //   _isListening ? "Listening... ($_soundLevel)" : "Tap mic to start",
//             //   style: const TextStyle(fontSize: 20),
//             // ),
//             const SizedBox(height: 20),
//             Text(
//               _text,
//               style: const TextStyle(fontSize: 18),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _listen,
//         child: Icon(_isListening ? Icons.stop : Icons.mic),
//       ),
//     );
//   }
// }
