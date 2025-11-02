import 'package:ai_voice_chat/app/modules/chat/chat_view.dart';
import 'package:ai_voice_chat/app/modules/home/home_view.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const String home = '/home';
  static const String chat = '/chat';
}

class AppPages {
  static const String initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      // binding: BindingsBuilder(() {
      //   Get.lazyPut<HomeController>(() => HomeController());
      // }),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatView(),
      // binding: BindingsBuilder(() {
      //   Get.lazyPut<ChatController>(() => ChatController());
      // }),
    ),
  ];
}
