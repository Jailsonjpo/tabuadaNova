import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_model.dart';
import 'quiz_page.dart';
import 'selection_page.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<Map<String, dynamic>> wrongQuestions;

  ResultPage({required this.score, required this.totalQuestions, required this.wrongQuestions});

  @override
  Widget build(BuildContext context) {
    final quizModel = Provider.of<QuizModel>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SelectionPage()),
              (route) => false,
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Resultado'),
          centerTitle: true, // Centraliza o título na app bar
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SelectionPage()),
                    (route) => false,
              );
            },
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
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SelectionPage()),
                          (route) => false,
                    );
                  },
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
