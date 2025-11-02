import 'package:ai_voice_chat/app/data/service/test_openai.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home View')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                testOpenAI();
              },
              child: const Text('Chat'),
            ),
            Text('Welcome to the Home View!'),
          ],
        ),
      ),
    );
  }
}
