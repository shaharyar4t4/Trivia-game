import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'ResultScreen.dart';
import 'HomeScreen.dart';

class QuizScreen extends StatefulWidget {
  final String categoryUrl;
  final int timerDuration;
  final Function(int) onScoreUpdate;
  final String userName;
  final int highScore;

  QuizScreen({
    required this.categoryUrl,
    required this.timerDuration,
    required this.onScoreUpdate,
    required this.userName,
    required this.highScore,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _score = 0;
  int _currentQuestionIndex = 0;
  List<dynamic> _questions = [];
  bool _isAnswered = false;
  String _selectedAnswer = '';
  bool _isLoading = true;
  late int _timer;
  late Timer _countdownTimer;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  Future<void> _fetchQuestions() async {
    final response = await http.get(Uri.parse(widget.categoryUrl));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        _questions = data['results'];
        _isLoading = false;
        _startTimer();
      });
    } else {
      throw Exception('Failed to load questions');
    }
  }

  void _startTimer() {
    _timer = widget.timerDuration;
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timer > 0) {
          _timer--;
        } else {
          timer.cancel();
          _checkAnswer('');
        }
      });
    });
  }

  void _checkAnswer(String answer) {
    _countdownTimer.cancel();
    setState(() {
      _isAnswered = true;
      _selectedAnswer = answer;
      if (_questions[_currentQuestionIndex]['correct_answer'] == answer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _isAnswered = false;
      _selectedAnswer = '';
      _currentQuestionIndex++;
      if (_currentQuestionIndex >= _questions.length) {
        widget.onScoreUpdate(_score);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(score: _score, totalQuestions: _questions.length, userName: widget.userName),
          ),
        );
      } else {
        _startTimer();
      }
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Do you want to continue playing or logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(userName: widget.userName, finalScore: _score),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Trivia Game'),
          backgroundColor: Colors.yellow,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
        ),
        backgroundColor: Colors.grey[200],
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_currentQuestionIndex >= _questions.length) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz Completed'),
          backgroundColor: Colors.yellow,
        ),
        backgroundColor: Colors.grey[200],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You scored $_score/${_questions.length}',
                style: TextStyle(fontSize: 24, color: Colors.yellow[700]),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Trivia Game'),
          backgroundColor: Colors.yellow,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
        ),
        backgroundColor: Colors.grey[200],
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                Uri.decodeComponent(_questions[_currentQuestionIndex]['question']),
                style: TextStyle(fontSize: 20, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ...(_questions[_currentQuestionIndex]['incorrect_answers'] as List<dynamic>).map((option) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: _isAnswered ? null : () => _checkAnswer(option),
                      child: Text(Uri.decodeComponent(option)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAnswered ? Colors.grey : Colors.yellow[100],
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              }).toList(),
              ElevatedButton(
                onPressed: _isAnswered ? null : () => _checkAnswer(_questions[_currentQuestionIndex]['correct_answer']),
                child: Text(Uri.decodeComponent(_questions[_currentQuestionIndex]['correct_answer'])),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAnswered ? Colors.grey : Colors.yellow[100],
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_alarm_sharp, color: Colors.yellow),
                  SizedBox(width: 5),
                  Text(
                    'Time remaining: $_timer seconds',
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                ],
              ),
              if (_isAnswered)
                Column(
                  children: [
                    Text(
                      _selectedAnswer == _questions[_currentQuestionIndex]['correct_answer'] ? 'Correct!' : 'Wrong!',
                      style: TextStyle(
                        fontSize: 18,
                        color: _selectedAnswer == _questions[_currentQuestionIndex]['correct_answer'] ? Colors.green : Colors.red,
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _nextQuestion,
                      child: Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    }
  }
}
