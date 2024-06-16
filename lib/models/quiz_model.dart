import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../lib/result_page.dart';

class QuizModel with ChangeNotifier {
  int _questionNumber = 1;
  int _score = 0;
  int _multiplier = 2;
  int _multiplicand = 0;
  int _totalQuestions = 10;
  List<int> _options = [];
  List<String> _askedQuestions = [];
  List<Map<String, dynamic>> _wrongQuestions = [];
  late int _correctAnswer;
  late Timer _timer;
  int _timeLeft = 10;
  bool _randomTable = false;

  int get questionNumber => _questionNumber;
  int get score => _score;
  List<int> get options => _options;
  int get timeLeft => _timeLeft;
  int get multiplier => _multiplier;
  int get multiplicand => _multiplicand;
  List<Map<String, dynamic>> get wrongQuestions => _wrongQuestions;

  QuizModel() {
    _generateQuestion();
  }

  void setMultiplier(int multiplier, {bool random = false}) {
    _multiplier = multiplier;
    _randomTable = random;
    _questionNumber = 1;
    _score = 0;
    _askedQuestions.clear();
    _wrongQuestions.clear();
    _generateQuestion();
    _startTimer();
    notifyListeners();
  }

  void setTotalQuestions(int totalQuestions) {
    _totalQuestions = totalQuestions;
  }

  void _generateQuestion() {
    var rng = Random();
    do {
      _multiplicand = rng.nextInt(10) + 1; // De 1 a 10
      if (_randomTable) {
        _multiplier = rng.nextInt(9) + 2; // De 2 a 10
      }
    } while (_askedQuestions.contains('$_multiplier x $_multiplicand'));

    _correctAnswer = _multiplicand * _multiplier;
    _askedQuestions.add('$_multiplier x $_multiplicand');

    _options = [_correctAnswer];
    while (_options.length < 4) {
      int option = _correctAnswer + rng.nextInt(10) - 5; // Opções próximas
      if (option != _correctAnswer && !_options.contains(option) && option > 0) {
        _options.add(option);
      }
    }
    _options.shuffle();
    notifyListeners();
  }

  void _startTimer() {
    _timeLeft = 10;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
      } else {
        _nextQuestion(context: null, timedOut: true);
      }
      notifyListeners();
    });
  }

  void _nextQuestion({BuildContext? context, bool timedOut = false}) {
    _timer.cancel();
    if (_questionNumber < _totalQuestions) {
      _questionNumber++;
      _generateQuestion();
      _startTimer();
    } else if (context != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ResultPage(
              score: _score,
              totalQuestions: _totalQuestions,
              wrongQuestions: _wrongQuestions,
            )),
      );
    }
  }

  void checkAnswer(int answer, BuildContext context) {
    if (answer != _correctAnswer) {
      _wrongQuestions.add({
        'question': '$_multiplier x $_multiplicand',
        'wrongAnswer': answer,
        'correctAnswer': _correctAnswer,
      });
    } else {
      _score++;
    }

    _nextQuestion(context: context);
  }

  void restartQuiz() {
    _questionNumber = 1;
    _score = 0;
    _askedQuestions.clear();
    _wrongQuestions.clear();
    _generateQuestion();
    _startTimer();
    notifyListeners();
  }

  void timeOutHandler(BuildContext context) {
    if (_questionNumber >= _totalQuestions) {
      _timer.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            score: _score,
            totalQuestions: _totalQuestions,
            wrongQuestions: _wrongQuestions,
          ),
        ),
      );
    } else {
      _nextQuestion(context: context, timedOut: true);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}