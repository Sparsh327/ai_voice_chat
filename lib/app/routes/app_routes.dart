import 'package:ai_voice_chat/app/modules/chat/view/chat_view.dart';
import 'package:ai_voice_chat/app/modules/chat/controller/chat_controller.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const String chat = '/chat';
}

class AppPages {
  static const String initial = AppRoutes.chat;

  static final routes = [
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ChatController>(() => ChatController());
      }),
    ),
  ];
}
