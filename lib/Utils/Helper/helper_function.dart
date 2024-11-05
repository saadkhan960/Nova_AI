import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nova_ai/Utils/Colors/app_colors.dart';

class HelperFunction {
  static bool isDarkMode(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  static Future<void> copyToClipboardAndShowSnackbar({
    required String text,
    required BuildContext context,
    int duration = 1,
  }) async {
    // Copy the text to clipboard
    await Clipboard.setData(ClipboardData(text: text));

    // Show the snackbar
    showSnackbar(
      text: 'Text copied to clipboard!',
      context: Get.context!,
      color: AppColors.primary,
      duration: duration,
    );
  }

  static void showSnackbar({
    required String text,
    required BuildContext context,
    required Color color,
    int duration = 2,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        duration: Duration(seconds: duration),
        content: Center(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.white),
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: color,
        margin: const EdgeInsets.only(
          bottom: 80,
          left: 20,
          right: 20,
        ),
      ),
    );
  }

  static void simpleAnimationNavigation(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeIn;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  static void mostStrictAnimationNavigation(
      BuildContext context, Widget screen) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeIn;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(
            curve: curve,
          ));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (Route<dynamic> route) => false,
    );
  }

  static void showCustomDialog({
    required BuildContext context,
    required String titleText,
    String? contentText,
    String deleteButtonText = "Delete",
    String cancelButtonText = "Cancle",
    required VoidCallback onDelete,
    VoidCallback? onCancle,
  }) {
    final dark = HelperFunction.isDarkMode(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              dark ? AppColors.backgroundDark : AppColors.backgroundLight,
          title: Center(
            child: Text(
              titleText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: contentText != null
              ? Text(
                  contentText,
                  textAlign: TextAlign.center,
                )
              : null,
          actions: [
            // Delete button
            TextButton(
              onPressed: onDelete,
              child: Text(
                deleteButtonText,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            // Cancel button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: onCancle,
              child: Text(cancelButtonText),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceAround,
        );
      },
    );
  }
}
