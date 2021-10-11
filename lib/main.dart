import 'package:flash_chat/screens/calculator.dart';
import 'package:flash_chat/screens/chatbot.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/screens/location.dart';
import 'package:flash_chat/screens/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      debugShowCheckedModeBanner: false,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ChatScreen.id: (context) => ChatScreen(),
        Profile.id: (context) => Profile(),
        Location.id: (context) => Location(),
        Calculator.id: (context) => Calculator(),
        ChatBot.id: (context) => ChatBot(),
      },
    );
  }
}
