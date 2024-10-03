import 'package:flutter/material.dart';
import 'UserNameScreen.dart';
import 'HomeScreen.dart';
import 'QuizScreen.dart';
import 'ResultScreen.dart';

void main() {
  runApp(TriviaGameApp());
}

class TriviaGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: UserNameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
