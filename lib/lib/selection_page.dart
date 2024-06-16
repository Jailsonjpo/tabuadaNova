import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_model.dart';
import 'quiz_page.dart';

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