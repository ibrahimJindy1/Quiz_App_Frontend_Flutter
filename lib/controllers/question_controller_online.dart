import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:quiz_app/Statics.dart';
import 'package:quiz_app/models/Firebase_Methods.dart';
import 'package:quiz_app/models/Questions.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:quiz_app/screens/score/score_screen_online.dart';
// We use get package for our state management

class QuestionControllerOnline extends GetxController
    with SingleGetTickerProviderMixin {
  FirebaseInit fire = new FirebaseInit();
  // Lets animated our progress bar
  final kUrl1 = 'assets/sounds/Correct.wav';
  final kUrl2 = 'assets/sounds/Wrong.wav';
  AnimationController _animationController;
  Animation _animation;
  // so that we can access our animation outside
  Animation get animation => this._animation;

  PageController _pageController;
  PageController get pageController => this._pageController;

  // List<Question> _questions = sample_data
  //     .map(
  //       (question) => Question(
  //           id: question['id'],
  //           question: question['question'],
  //           options: question['options'],
  //           answer: question['answer_index']),
  //     )
  //     .toList();

  List<Question> _questions = Statics.questions;

  // .map(
  //   (question) => Question(
  //       id: question['id'],
  //       question: question['question'],
  //       options: question['options'],
  //       answer: question['answer_index']),
  // )
  // .toList();

  List<Question> get questions => this._questions;

  bool _isAnswered = false;
  bool get isAnswered => this._isAnswered;

  int _correctAns;
  int get correctAns => this._correctAns;

  int _selectedAns;
  int get selectedAns => this._selectedAns;

  // for more about obs please check documentation
  RxInt _questionNumber = 1.obs;
  RxInt get questionNumber => this._questionNumber;

  int _numOfCorrectAns = 0;
  int get numOfCorrectAns => this._numOfCorrectAns;

  // called immediately after the widget is allocated memory
  @override
  void onInit() {
    // fire
    //     .getQuestions(Statics.level, Statics.levelDifiiculty)
    //     .then((value) => _questions = value);
    // Our animation duration is 60 s
    // so our plan is to fill the progress bar within 60s

    _animationController =
        AnimationController(duration: Duration(seconds: 10), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        // update like setState
        update();
      });

    // start our animation
    // Once 60s is completed go to the next qn
    _animationController.forward().whenComplete(nextQuestion);
    _pageController = PageController();
    Statics.oppScore = 0;
    Statics.myScore = 0;
    // Statics.socket.on('userAnswered', (data) {
    //   Statics.oppScore = data['correctAnswersCount'];
    //   Future.delayed(Duration(seconds: 1), () {
    //     nextQuestion();
    //   });
    // });
    super.onInit();
  }

  // // called just before the Controller is deleted from memory
  @override
  void onClose() {
    super.onClose();
    _animationController.dispose();
    _pageController.dispose();
  }

  Future<void> checkAns(Question question, int selectedIndex) async {
    // // because once user press any option then it will run

    _isAnswered = true;
    Statics.isAnswered = true;
    _correctAns = question.answer;
    _selectedAns = selectedIndex;

    AudioCache _audioCache = AudioCache(
      prefix: 'assets/sounds/',
      fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    );
    if (_correctAns == _selectedAns) {
      _audioCache.play('Correct.wav');

      _numOfCorrectAns++;
      Statics.myScore = _numOfCorrectAns;
      Statics.socket.emit('answer',
          {'correctAnswers': _numOfCorrectAns, "roomID": Statics.roomId});
    } else {
      _audioCache.play('Wrong.wav');
      Statics.socket.emit('answer',
          {'correctAnswers': _numOfCorrectAns, "roomID": Statics.roomId});
    }

    // It will stop the counter
    _animationController.stop();
    update();

    Future.delayed(Duration(seconds: 1), () {
      nextQuestion();
    });
    // Once user select an ans after 3s it will go to the next qn
  }

  Future<void> TwoAnswersDelete(Question question) async {
    Statics.help -= 1;
    await fire.setHelp();
    int cou = 2;
    int z = 0;
    int f = 0;
    var rng = new Random();
    for (int i = 0; i < cou; i++) {
      if (i == 0) {
        z = rng.nextInt(4);
        while (question.answer == z) {
          z = rng.nextInt(4);
        }
        question.options[z] = "";
      } else
        f = rng.nextInt(4);
      while (question.answer == f && f != z) {
        f = rng.nextInt(4);
      }
      question.options[f] = "";
    }
  }

  Future<void> nextQuestion() async {
    Statics.isAnswered = false;

    if (_questionNumber.value != _questions.length) {
      _isAnswered = false;
      _pageController.nextPage(
          duration: Duration(milliseconds: 250), curve: Curves.ease);

      // Reset the counter
      _animationController.reset();

      // Then start it again
      // Once timer is finish go to the next qn
      _animationController.forward().whenComplete(nextQuestion);
    } else {
      if (Statics.oppScore > _numOfCorrectAns) {
        Statics.points -= 10;
        Statics.wins -= 1;
      } else if (Statics.oppScore < _numOfCorrectAns) {
        Statics.points += 10;
        Statics.wins += 1;
      } else {
        Statics.points += 0;
        Statics.wins += 0;
      }
      await fire.setWins().whenComplete(() async {
        await fire.setPoints().whenComplete(() {
          offAllSocketEvents();

          Get.reset();
          // Get.to(ScoreScreenOnline());
          Get.offAll(ScoreScreenOnline());
        });
      });

      // Get package provide us simple way to naviigate another page

    }
  }

  void offAllSocketEvents() {
    Statics.socket.clearListeners();
  }

  void updateTheQnNum(int index) {
    _questionNumber.value = index + 1;
  }
}
