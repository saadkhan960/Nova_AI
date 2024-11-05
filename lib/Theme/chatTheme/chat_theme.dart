import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:nova_ai/Utils/Colors/app_colors.dart';
import 'package:nova_ai/Utils/Helper/helper_function.dart';

class CustomChatTheme {
  final BuildContext context;
  final bool dark;

  CustomChatTheme(this.context) : dark = HelperFunction.isDarkMode(context);

  ChatTheme get customChatTheme {
    return DefaultChatTheme(
      primaryColor: dark ? AppColors.primary : AppColors.primaryLight,
      secondaryColor: dark
          ? AppColors.secondUserChatColorDark
          : AppColors.secondUserChatColorLight,
      receivedMessageLinkTitleTextStyle: const TextStyle(color: Colors.blue),
      backgroundColor:
          dark ? AppColors.backgroundDark : AppColors.backgroundLight,
      inputBackgroundColor: AppColors.foregroundDark,
      receivedMessageBodyTextStyle: TextStyle(
          color: dark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500),
      sentMessageBodyTextStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    );
  }
}
