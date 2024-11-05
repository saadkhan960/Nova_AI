import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:nova_ai/Theme/theme_data.dart';
import 'package:nova_ai/view/Chat/chat_page.dart';
import 'package:nova_ai/view/splash%20screen/splash_screen.dart';
import 'package:nova_ai/view/splash%20screen/splash_services/splash_services.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Future<bool> firstTimeCheck() async {
    return await SplashServices().checkFirstTime();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nova Ai',
      theme: CustomThemeData.lightTheme,
      darkTheme: CustomThemeData.darkTheme,
      themeMode: ThemeMode.system,
      home: FutureBuilder<bool>(
        future: firstTimeCheck(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (snapshot.hasData) {
            if (data == true) {
              return const SplashScreen();
            } else {
              return const ChatPage();
            }
          } else {
            return const SplashScreen();
          }
        },
      ),
    );
  }
}
