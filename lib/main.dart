import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:nova_ai/Utils/Const/constant.dart';
import 'package:nova_ai/my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  Gemini.init(apiKey: Constant.GEMINIE_KEY);
  runApp(const MyApp());
}

// Developed by Muhammad Saad Khan
// LinkedIn: /saadkhan960
// GitHub: /saadkhan960
