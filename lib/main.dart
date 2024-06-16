import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuizModel(),
      child: MaterialApp(
        title: 'Tabuada App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 20.0, fontStyle: FontStyle.italic),
            bodyText2: TextStyle(fontSize: 18.0),
          ),
        ),
        home: SelectionPage(),
      ),
    );
  }
}

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

class SelectionPage extends StatefulWidget {
  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  int _selectedQuestions = 10;

  void _startQuiz(BuildContext context, int multiplier, {bool random = false}) {
    final quizModel = Provider.of<QuizModel>(context, listen: false);
    quizModel.setMultiplier(multiplier, random: random);
    quizModel.setTotalQuestions(_selectedQuestions);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escolha a Tabuada e Questões'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selecione a Tabuada:',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                alignment: WrapAlignment.center,
                children: List.generate(9, (index) {
                  int table = index + 2;
                  return ElevatedButton(
                    onPressed: () => _startQuiz(context, table),
                    child: Text('Tabuada do $table'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  );
                }),
              ),
              ElevatedButton(
                onPressed: () => _startQuiz(context, 2, random: true),
                child: Text('Tabuada Aleatória'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.purpleAccent,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Número de Questões:',
                style: Theme.of(context).textTheme.headline6,
              ),
              Slider(
                value: _selectedQuestions.toDouble(),
                min: 5,
                max: 20,
                divisions: 15,
                label: '$_selectedQuestions questões',
                onChanged: (value) {
                  setState(() {
                    _selectedQuestions = value.toInt();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quizModel = Provider.of<QuizModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tabuada App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Questão ${quizModel.questionNumber} de ${quizModel._totalQuestions}',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 20),
              Text(
                'Quanto é ${quizModel.multiplier} x ${quizModel.multiplicand}?',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2,
                children: quizModel.options.map((option) {
                  return ElevatedButton(
                    onPressed: () {
                      quizModel.checkAnswer(option, context);
                    },
                    child: Text('$option'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.teal,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  );
                }).toList(),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tempo restante: ${quizModel.timeLeft}',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  Text(
                    'Pontuação: ${quizModel.score}',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<Map<String, dynamic>> wrongQuestions;

  ResultPage({required this.score, required this.totalQuestions, required this.wrongQuestions});

  void _navigateToSelectionPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SelectionPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizModel = Provider.of<QuizModel>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        _navigateToSelectionPage(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Resultado'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => _navigateToSelectionPage(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Você concluiu o quiz!',
                  style: Theme.of(context).textTheme.headline1,
                ),
                SizedBox(height: 20),
                Text(
                  'Pontuação: $score / $totalQuestions',
                  style: Theme.of(context).textTheme.headline1,
                ),
                SizedBox(height: 20),
                if (wrongQuestions.isNotEmpty) ...[
                  Text(
                    'Questões Erradas:',
                    style: TextStyle(fontSize: 24, color: Colors.red),
                  ),
                  SizedBox(height: 20),
                  ...wrongQuestions.map((question) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question['question'],
                        style: TextStyle(fontSize: 20, color: Colors.red),
                      ),
                      Text(
                        'Resposta errada: ${question['wrongAnswer']}',
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                      Text(
                        'Resposta correta: ${question['correctAnswer']}',
                        style: TextStyle(fontSize: 18, color: Colors.green),
                      ),
                      SizedBox(height: 10),
                    ],
                  )),
                ],
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _navigateToSelectionPage(context),
                  child: Text('Voltar à Seleção de Tabuada'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    quizModel.restartQuiz();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => QuizPage()),
                          (route) => false,
                    );
                  },
                  child: Text('Jogar Novamente'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
