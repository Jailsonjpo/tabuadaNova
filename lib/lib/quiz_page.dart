import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/quiz_model.dart';
//import '../models/quiz_model.dart';

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
                'Questão ${quizModel.questionNumber}',
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
