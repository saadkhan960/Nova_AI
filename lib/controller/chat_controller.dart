import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nova_ai/Utils/Colors/app_colors.dart';
import 'package:nova_ai/Utils/Helper/helper_function.dart';
import 'package:nova_ai/Utils/internet%20Exceptions/connectivity_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ChatController extends GetxController {
  ChatController() {
    textController.addListener(() {
      isMessageEmpty.value = textController.text.isEmpty;
    });
  }
  // Reactive list of messages
  final RxList<types.Message> chatMessages = <types.Message>[].obs;
  final RxBool hasData = false.obs;
  final RxBool typing = false.obs;
  final picker = ImagePicker();
  final RxString photoPath = "".obs;
  Rx<Uint8List?> selectedImage = Rx<Uint8List?>(null);
  final TextEditingController textController = TextEditingController();
  RxBool isMessageEmpty = true.obs;
  final types.User user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );
  final types.User geminis = const types.User(
      id: '41526874-a484-4a239-be75-a22bf8d1f3ac',
      firstName: "Nova Ai",
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRaw6KCkx1KR4YMChRfQnjfQMouV5mxeT2x2Q&s');
  final gemini = Gemini.instance;
  final RxBool stratChatButtonSplash = false.obs;
  final RxBool isFirstMessageSent = true.obs;
  final RxBool typeMessage = false.obs;
  final RxBool typeMessagefirst = true.obs;
  ConnectivityService connectivityService = ConnectivityService(Get.context!);
  final RxBool novaTyping = false.obs;
  void toggleTypingState(bool isTyping) {
    typeMessage.value = isTyping;
  }

  void typingStateFirst(String value) {
    if (value == "") {
      typeMessagefirst.value = true;
    } else {
      typeMessagefirst.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    checkInternetConectivity();
  }

  void checkInternetConectivity() async {
    final bool isConnected = await connectivityService.checkConnectivity();
    if (!isConnected) {
      HelperFunction.showSnackbar(
          text: "No Internet Connection",
          context: Get.context!,
          color: Colors.red);
      return;
    }
  }

  // --------- WHEN USER CLICK ON SEND BUTTON FUNCTION----------------------
  Future<void> handleSendPressed(BuildContext context) async {
    if (!typing.value) {
      await addMessage();
    } else {
      HelperFunction.showSnackbar(
          duration: 1,
          text: "Wait for responce",
          context: context,
          color: AppColors.primary);
    }
  }

// ------------------MAIN SEND MESSAGE FUNCTION---------------------------------
  Future<void> addMessage() async {
    if (selectedImage.value == null && photoPath.value.isEmpty) {
      await multiTextMessageSend();
    } else {
      await textWithImageSend();
    }
  }

  // ------------------MESSAGE WITH IMAGE-----------------------------------------------------
  Future<void> textWithImageSend() async {
    final aiResponseMessageId = const Uuid().v4();
    final userText = textController.text.trim();
    try {
      bool isConnected = await connectivityService.checkConnectivity();
      if (!isConnected) {
        HelperFunction.showSnackbar(
            text: "No Internet Connection",
            context: Get.context!,
            color: Colors.red);
        textController.text = userText;
        typing.value = false;
        return;
      }

      final userRecivedImage = selectedImage.value;
      final showImage = photoPath.value;

      // Reset the input field and images for the next message
      textController.clear();
      selectedImage.value = null;
      photoPath.value = '';

      // Prepare and send the user's initial image and text messages
      final userImage = types.ImageMessage(
        author: user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        name: 'guess',
        size: 100,
        uri: showImage,
      );
      final userMessage = types.TextMessage(
        author: user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: userText,
      );
      typing.value = true;
      chatMessages.insert(0, userImage);
      chatMessages.insert(0, userMessage);

      await saveMessage(userImage);
      await saveMessage(userMessage);

      novaTyping.value = true;
      types.TextMessage? aiResponseMessage;

      final tokenCount = await gemini.countTokens(userText);

      if (tokenCount != null && tokenCount > 1200) {
        // Display an error if token count exceeds the allowed limit
        novaTyping.value = false;
        aiResponseMessage = types.TextMessage(
          author: geminis,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: aiResponseMessageId,
          text: 'Message exceeds the token limit. Please shorten your message.',
        );
        chatMessages.insert(0, aiResponseMessage);

        await saveMessage(types.TextMessage(
          author: geminis,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: 'Message exceeds the token limit. Please shorten your message.',
        ));
        textController.text = userText;
        typing.value = false;
        hasData.value = true;
        return; // Exit function without sending the message
      }
      // Accumulate the response text as it streams in
      StringBuffer responseBuffer = StringBuffer();

      // Stream response from Gemini
      final responseStream = gemini.streamGenerateContent(
        userText,
        images: [userRecivedImage!],
        generationConfig: GenerationConfig(
          stopSequences: [],
          temperature: 0.7,
          maxOutputTokens: 2500,
          topP: 0.9,
          topK: 50,
        ),
      );
      responseStream.listen(
        (candidate) {
          if (novaTyping.value) {
            novaTyping.value = false;
          }
          // Append each partial result to the response buffer
          responseBuffer.write(candidate.output?.trim() ?? '');

          // If aiResponseMessage is null, create it and add to chatMessages
          if (aiResponseMessage == null) {
            aiResponseMessage = types.TextMessage(
              author: geminis,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: aiResponseMessageId,
              text: responseBuffer.toString().trim(),
            );
            chatMessages.insert(0, aiResponseMessage!);
          } else {
            // Update the text of the existing AI response bubble
            final index =
                chatMessages.indexWhere((msg) => msg.id == aiResponseMessageId);
            if (index != -1) {
              chatMessages[index] =
                  (chatMessages[index] as types.TextMessage).copyWith(
                text: responseBuffer.toString().trim(),
              );
            }
          }
        },
        onDone: () async {
          novaTyping.value = false;
          if (!hasData.value) {
            hasData.value = true;
          }
          debugPrint("body: $chatMessages");
          typing.value = false;
          if (aiResponseMessage == null) {
            aiResponseMessage = types.TextMessage(
              author: geminis,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: aiResponseMessageId,
              text: "Server Error. Please Send message again.",
            );
            chatMessages.insert(0, aiResponseMessage!);
            return;
          }

          // Replace the placeholder with the final response text
          chatMessages.removeWhere((msg) => msg.id == aiResponseMessageId);
          final finalMessage = types.TextMessage(
            author: geminis,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: const Uuid().v4(),
            text: responseBuffer.toString().trim() == ""
                ? " Server Error. Please Send message again."
                : responseBuffer.toString().trim(),
          );
          chatMessages.insert(
            0,
            finalMessage,
          );
          await saveMessage(finalMessage);
          hasData.value = true;
        },
        onError: (error) async {
          novaTyping.value = false;
          // Handle errors and remove the typing indicator
          if (aiResponseMessage == null) {
            aiResponseMessage = types.TextMessage(
              author: geminis,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: aiResponseMessageId,
              text:
                  "Something went wrong or Network error. Please check your internet connection and try again.",
            );
            chatMessages.insert(0, aiResponseMessage!);
            return;
          }
          chatMessages.removeWhere((msg) => msg.id == aiResponseMessageId);
          final finalMessage = types.TextMessage(
            author: geminis,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: const Uuid().v4(),
            text:
                'Something went wrong or Network error. Please check your internet connection and try again.',
          );
          chatMessages.insert(0, finalMessage);
          await saveMessage(finalMessage);
          typing.value = false;
          hasData.value = true;
          debugPrint("Error: $error");
        },
      );
    } on GeminiException catch (e) {
      novaTyping.value = false;
      // Log or handle the exception details
      debugPrint(e.toString());

      // Remove typing indicator and show a network error message
      final finalMessage = types.TextMessage(
        author: geminis,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text:
            'Server Error. Please Send message again. Status Code: ${e.statusCode}',
      );
      chatMessages.insert(
        0,
        finalMessage,
      );
      await saveMessage(finalMessage);
      hasData.value = true;
      textController.text = userText;
      typing.value = false;
    } catch (e) {
      novaTyping.value = false;
      final finalMessage = types.TextMessage(
        author: geminis,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text:
            'Something went wrong or Network error. Pl ease check your internet connection and try again.',
      );
      chatMessages.insert(0, finalMessage);
      await saveMessage(finalMessage);
      hasData.value = true;
      textController.text = userText;
      typing.value = false;
      debugPrint("Error: $e");
    }
  }

// ------------------MESSAGE WITH TEXT-------------------------------------------------
  Future<void> multiTextMessageSend() async {
    //ai message id
    final aiResponseMessageId = const Uuid().v4();
    final userText = textController.text.trim();
    textController.clear();
    selectedImage.value = null;
    photoPath.value = '';
    try {
      bool isConnected = await connectivityService.checkConnectivity();
      if (!isConnected) {
        HelperFunction.showSnackbar(
            text: "No Internet Connection",
            context: Get.context!,
            color: Colors.red);
        textController.text = userText;
        typing.value = false;
        return;
      }
      //message that user send to ai
      final message = types.TextMessage(
        author: user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: userText,
      );
      typing.value = true;
      chatMessages.insert(0, message);

      await saveMessage(message);

      // Create a typing indicator message
      novaTyping.value = true;
      types.TextMessage? aiResponseMessage;

      final tokenCount = await gemini.countTokens(userText);
      if (tokenCount != null && tokenCount > 1200) {
        // Display an error if token count exceeds the allowed limit
        novaTyping.value = false;
        aiResponseMessage = types.TextMessage(
          author: geminis,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: aiResponseMessageId,
          text: 'Message exceeds the token limit. Please shorten your message.',
        );
        chatMessages.insert(0, aiResponseMessage);

        await saveMessage(types.TextMessage(
          author: geminis,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: 'Message exceeds the token limit. Please shorten your message.',
        ));
        hasData.value = true;
        textController.text = userText;
        typing.value = false;
        return; // Exit function without sending the message
      }

      // Map message history for multi-turn conversations with only text messages
      List<Content> messageHistory = chatMessages
          .whereType<types.TextMessage>() // Filter to only text messages first
          .toList()
          .reversed // Reverse to maintain chronological order
          .map((m) {
        final content = m.text;
        if (m.author == user) {
          return Content(parts: [Parts(text: content)], role: 'user');
        } else {
          return Content(parts: [Parts(text: content)], role: 'model');
        }
      }).toList();

      debugPrint("body: $messageHistory");
      // Accumulate the response text as it streams in
      StringBuffer responseBuffer = StringBuffer();
      final responseStream = gemini.streamChat(
        messageHistory,
        generationConfig: GenerationConfig(
          stopSequences: [],
          temperature: 0.7,
          maxOutputTokens: 2500, //token limit for longer responses
          topP: 0.9,
          topK: 50,
        ),
      );
      debugPrint("responce: $responseStream");

      // Listen to the stream and update the chat message in real-time
      responseStream.listen(
        (candidate) {
          novaTyping.value = false;
          // Append each partial result to the response buffer
          responseBuffer.write(candidate.output?.trim() ?? '');

          // If aiResponseMessage is null, create it and add to chatMessages
          if (aiResponseMessage == null) {
            aiResponseMessage = types.TextMessage(
              author: geminis,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: aiResponseMessageId,
              text: responseBuffer.toString().trim(),
            );
            chatMessages.insert(0, aiResponseMessage!);
          } else {
            // Update the text of the existing AI response bubble
            final index =
                chatMessages.indexWhere((msg) => msg.id == aiResponseMessageId);
            if (index != -1) {
              chatMessages[index] =
                  (chatMessages[index] as types.TextMessage).copyWith(
                text: responseBuffer.toString().trim(),
              );
            }
          }
        },
        onDone: () async {
          novaTyping.value = false;
          if (!hasData.value) {
            hasData.value = true;
          }
          debugPrint("body: $chatMessages");
          typing.value = false;
          if (aiResponseMessage == null) {
            aiResponseMessage = types.TextMessage(
              author: geminis,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: aiResponseMessageId,
              text: "Server Error. Please Send message again.",
            );
            chatMessages.insert(0, aiResponseMessage!);
            return;
          }

          // Replace the placeholder with the final response text
          chatMessages.removeWhere((msg) => msg.id == aiResponseMessageId);
          final finalMessage = types.TextMessage(
            author: geminis,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: const Uuid().v4(),
            text: responseBuffer.toString().trim() == ""
                ? " Server Error. Please Send message again."
                : responseBuffer.toString().trim(),
          );
          chatMessages.insert(
            0,
            finalMessage,
          );
          await saveMessage(finalMessage);
          hasData.value = true;
        },
        onError: (error) async {
          novaTyping.value = false;
          // Handle errors and remove the typing indicator
          if (aiResponseMessage == null) {
            aiResponseMessage = types.TextMessage(
              author: geminis,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: aiResponseMessageId,
              text:
                  "Something went wrong or Network error. Please check your internet connection and try again.",
            );
            chatMessages.insert(0, aiResponseMessage!);
            return;
          }
          chatMessages.removeWhere((msg) => msg.id == aiResponseMessageId);
          final finalMessage = types.TextMessage(
            author: geminis,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: const Uuid().v4(),
            text:
                'Something went wrong or Network error. Please check your internet connection and try again.',
          );
          chatMessages.insert(0, finalMessage);
          await saveMessage(finalMessage);
          hasData.value = true;
          typing.value = false;
          debugPrint("Error: $error");
        },
      );
    } on GeminiException catch (e) {
      novaTyping.value = false;
      // Log or handle the exception details
      debugPrint(e.toString());

      // Remove typing indicator and show a network error message
      final finalMessage = types.TextMessage(
        author: geminis,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text:
            'Server Error. Please Send message again. Status Code: ${e.statusCode}',
      );
      chatMessages.insert(
        0,
        finalMessage,
      );
      await saveMessage(finalMessage);
      hasData.value = true;
      textController.text = userText;
      typing.value = false;
    } catch (e) {
      novaTyping.value = false;
      final finalMessage = types.TextMessage(
        author: geminis,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text:
            'Something went wrong or Network error. Please check your internet connection and try again.',
      );
      chatMessages.insert(0, finalMessage);
      await saveMessage(finalMessage);
      hasData.value = true;
      textController.text = userText;
      typing.value = false;
      debugPrint("Error: $e");
    }
  }

// --------- USE FOR SAVE CONVERSATON--------------------------

  Future<void> saveMessage(types.Message message) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load existing messages from SharedPreferences
      List<String> jsonMessages = prefs.getStringList('chatMessages') ?? [];

      // Convert the new message to JSON format and add it to the list
      String jsonMessage;
      if (message is types.TextMessage) {
        jsonMessage = jsonEncode({'type': 'text', 'data': message.toJson()});
      } else if (message is types.ImageMessage) {
        jsonMessage = jsonEncode({'type': 'image', 'data': message.toJson()});
      } else {
        return; // Ignore unsupported message types
      }

      jsonMessages.add(jsonMessage); // Add the new message

      // Save the updated list back to SharedPreferences
      await prefs.setStringList('chatMessages', jsonMessages);
    } catch (e) {
      debugPrint("Error while saving $e");
    }
  }

// --------- USE FOR RETRIVE PRIVIOUS CONVERSATON--------------------------
  Future<void> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonMessages = prefs.getStringList('chatMessages') ?? [];
      hasData.value = jsonMessages.isNotEmpty;
      final List<types.Message> messages = jsonMessages
          .map((jsonMessage) {
            final decoded = jsonDecode(jsonMessage);
            if (decoded['type'] == 'text') {
              return types.TextMessage.fromJson(decoded['data']);
            } else if (decoded['type'] == 'image') {
              return types.ImageMessage.fromJson(decoded['data']);
            }
            return null;
          })
          .where((message) => message != null)
          .cast<types.Message>()
          .toList();

      // Reverse the messages list
      chatMessages.value = messages.reversed.toList();
    } catch (e) {
      debugPrint("Error while loading messages: $e");
    }
  }
// --------- USE FOR Delete All PRIVIOUS CONVERSATON--------------------------

  Future<void> clearMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chatMessages');
    hasData.value = false;
    isFirstMessageSent.value = true;
    typeMessage.value = false;
    typeMessagefirst.value = true;

    chatMessages.clear();
  }

  @override
  void onClose() {
    connectivityService.dispose();
    super.onClose();
  }
}
