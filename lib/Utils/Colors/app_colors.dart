import 'package:flutter/material.dart';

class AppColors {
  // Primary color based on the logo
  static const primary = Color(0xff134d37); // Deep teal/green
  static const primaryLight = Color(0xff66c6a6);

  // Button and icon colors
  static const sendButton =
      Color(0xff64fcc9); // Lighter teal-green for send button
  static const sendButtonLight =
      Color(0xff1dab61); // Lighter teal-green for send button
  static const galleryIcon = Color(0xff96a1a5); // Muted greenish-gray for icons

  // Background colors matching the green theme
  static const backgroundDark =
      Color(0xFF081317); // Dark teal for dark mode background
  static const backgroundLight =
      Color(0xfff0fff6); // Light teal for light mode background

  // Foreground colors for text and main elements
  static const foregroundDark =
      Color(0xff1f2c34); // Darker foreground for dark mode
  static const foregroundLight = Color.fromARGB(
      255, 90, 119, 138); // Muted greenish-teal for light mode foreground

  // Chat bubble colors for second user's messages
  static const secondUserChatColorDark =
      Color(0xff1f2c34); // Dark teal/green for dark mode chat
  static const secondUserChatColorLight = Color.fromARGB(
      255, 228, 233, 230); // Light teal/green for light mode chat

  // Secondary colors for additional UI elements
  static const secondaryDark =
      Color(0xff1c3a34); // Dark complementary color for accents
  static const secondaryLight =
      Color(0xffd1e8e4); // Light complementary color for accents

  // Text colors
  static const textDark = Color(0xffe0e0e0); // Light text for dark backgrounds
  static const textLight = Color(0xff303030); // Dark text for light backgrounds

  // General colors
  static const white = Color(0xffffffff);
  static const black = Color(0xff000000);
}
