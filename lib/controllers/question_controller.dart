import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quiz_app/Statics.dart';
import 'package:quiz_app/ad_helper.dart';
import 'package:quiz_app/models/Firebase_Methods.dart';
import 'package:quiz_app/models/Questions.dart';
import 'package:quiz_app/screens/score/score_screen.dart';
import 'package:audioplayers/audioplayers.dart';

import '../screens/quiz/quiz_screen.dart';
// We use get package for our state management

class QuestionController extends GetxController
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

  // List<Question> _questionsOnline = sample_data
  //     .map(
  //       (question) => Question(
  //           id: question['id'],
  //           question: question['question'],
  //           options: question['options'],
  //           answer: question['answer_index']),
  //     )
  //     .toList();

  List<Question> _questions = Statics.questions as List<Question>;

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

    _animationController = AnimationController(
        duration: Duration(seconds: Statics.levelTimer), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        // update like setState
        update();
      });

    // start our animation
    // Once 60s is completed go to the next qn
    _animationController.forward().whenComplete(nextQuestion);
    _pageController = PageController();
    super.onInit();
  }

  // // called just before the Controller is deleted from memory
  @override
  void onClose() {
    super.onClose();
    _animationController.dispose();
    _pageController.dispose();
  }

  void checkAns(Question question, int selectedIndex) async {
    // because once user press any option then it will run
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
    } else {
      _audioCache.play('Wrong.wav');
    }

    // It will stop the counter
    _animationController.stop();

    update();

    // Once user select an ans after 3s it will go to the next qn
    Future.delayed(Duration(seconds: 1), () {
      nextQuestion();
    });
  }

  void stopAnimation() {
    _animationController.stop();
    // update();
  }

  void resetAnimation() {
    // update();
  }
  void forwardAnimation() {
    _animationController.forward();
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
      // Get package provide us simple way to naviigate another page
      if (Statics.level == Statics.currentLevel + 1 &&
          Statics.currentLevel + 1 < 21) {
        await fire.setLevel().whenComplete(() async {
          Statics.points += _numOfCorrectAns * 5;

          Statics.myScore = _numOfCorrectAns * 5;
          await fire.setPoints().whenComplete(() {
            Get.to(ScoreScreen());
          });
        });
      } else {
        Statics.points += _numOfCorrectAns * 5;

        Statics.myScore = _numOfCorrectAns * 5;
        await fire.setPoints().whenComplete(() async {
          // Get.to(ScoreScreen());
          // Get.offAll(ScoreScreen());
          await fire.setWins();
          Navigator.of(Statics.context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => ScoreScreen(),
              ),
              (route) => false);
        });
      }
    }
  }

  void updateTheQnNum(int index) {
    _questionNumber.value = index + 1;
  }
}
