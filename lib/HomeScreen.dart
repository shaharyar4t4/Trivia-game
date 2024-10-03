import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'QuizScreen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final int? finalScore;

  HomeScreen({required this.userName, this.finalScore});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, String> categories = {
    'Cartoon': 'https://opentdb.com/api.php?amount=10&category=32&difficulty=easy&type=multiple&encode=url3986',
    'Video Game': 'https://opentdb.com/api.php?amount=10&category=15&difficulty=easy&type=multiple&encode=url3986',
    'Board Game': 'https://opentdb.com/api.php?amount=10&category=16&difficulty=easy&type=multiple&encode=url3986',
    'Music': 'https://opentdb.com/api.php?amount=10&category=12&difficulty=easy&type=multiple&encode=url3986',
    'Film': 'https://opentdb.com/api.php?amount=10&category=11&difficulty=easy&type=multiple&encode=url3986',
    'Vehicle': 'https://opentdb.com/api.php?amount=10&category=28&difficulty=easy&type=multiple&encode=url3986',
    'Mythology': 'https://opentdb.com/api.php?amount=10&category=20&difficulty=easy&type=multiple&encode=url3986',
    'Books': 'https://opentdb.com/api.php?amount=10&category=10&difficulty=easy&type=multiple&encode=url3986'
  };

  String _selectedCategory = 'Cartoon';
  int _highScore = 0;
  int _selectedTimer = 15;

// database working

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final response = await http.get(Uri.parse('http://localhost/get_high_score.php?username=${widget.userName}'));
    if (response.statusCode == 200) {
      setState(() {
        _highScore = int.parse(response.body);
      });
    }
  }

  Future<void> _saveHighScore(int score) async {
    final response = await http.post(
      Uri.parse('http://localhost/save_user.php'),
      body: {
        'username': widget.userName,
        'high_score': score.toString(),
      },
    );
    if (response.statusCode == 200) {
      print('High score saved successfully');
    } else {
      print('Failed to save high score');
    }
  }
// home page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/icon.png', height: 40),
            SizedBox(width: 10),
            Text('Trivia Game'),
          ],
        ),
        backgroundColor: Colors.yellow,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Settings functionality can be added here
            },
          )
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome, ${widget.userName}!',
                style: TextStyle(fontSize: 24, color: Colors.yellow[700]),
              ),
              if (widget.finalScore != null)
                Text(
                  'Your last score: ${widget.finalScore}',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedCategory,
                items: categories.keys.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                icon: Icon(Icons.arrow_drop_down_circle, color: Colors.yellow),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.black, fontSize: 18),
                underline: Container(
                  height: 2,
                  color: Colors.yellow,
                ),
              ),
              SizedBox(height: 20),
              DropdownButton<int>(
                value: _selectedTimer,
                items: [15, 30, 60].map((int seconds) {
                  return DropdownMenuItem<int>(
                    value: seconds,
                    child: Text('$seconds seconds'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedTimer = newValue!;
                  });
                },
                icon: Icon(Icons.timer, color: Colors.yellow),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.black, fontSize: 18),
                underline: Container(
                  height: 2,
                  color: Colors.yellow,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.play_arrow),
                label: Text('Start Game'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuizScreen(
                      categoryUrl: categories[_selectedCategory]!,
                      timerDuration: _selectedTimer,
                      onScoreUpdate: (score) {
                        if (score > _highScore) {
                          setState(() {
                            _highScore = score;
                          });
                          _saveHighScore(score);
                        }
                      },
                      userName: widget.userName,
                      highScore: _highScore,
                    )),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 20),
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Instructions: Answer the questions within the given time to score points!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              Text(
                'High Score: $_highScore',
                style: TextStyle(fontSize: 18, color: Colors.yellow[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
