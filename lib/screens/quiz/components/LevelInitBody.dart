import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_app/Statics.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/controllers/question_controller_online.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quiz_app/screens/quiz/components/IniQuestion.dart';
import 'package:quiz_app/screens/quiz/components/progressBarOnline.dart';
import 'package:quiz_app/utils/SizeConfig.dart';

class BodyOnline extends StatelessWidget {
  const BodyOnline({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // So that we have acccess our controller
    QuestionControllerOnline _questionController =
        Get.put(QuestionControllerOnline());
    Statics.socket.on('userAnswered', (data) {
      Statics.isAnswered = true;
      Statics.oppScore = data['correctAnswers'];
      _questionController.nextQuestion();
    });
    return Stack(
      children: [
        SvgPicture.asset(
          "assets/icons/bg.svg",
          fit: BoxFit.fill,
          width: double.infinity,
          height: double.infinity,
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                Statics.oppName + "  " + Statics.oppLevel.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.w(24),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: ProgressBarOnline(),
              ),
              SizedBox(height: kDefaultPadding),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: Obx(
                  () => Text.rich(
                    TextSpan(
                      text:
                          "السؤال ${_questionController.questionNumber.value}",
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          .copyWith(color: kSecondaryColor),
                      children: [
                        TextSpan(
                          text: "/${_questionController.questions.length}",
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(color: kSecondaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(thickness: 1.5),
              SizedBox(height: 1),
              Expanded(
                flex: 15,
                child: PageView.builder(
                  // Block swipe to next qn
                  physics: NeverScrollableScrollPhysics(),
                  controller: _questionController.pageController,
                  onPageChanged: _questionController.updateTheQnNum,
                  itemCount: _questionController.questions.length,
                  itemBuilder: (context, index) => QuestionCardOnline(
                      question: _questionController.questions[index]),
                ),
              ),
              Spacer(
                flex: 1,
              ),
              Text(
                Statics.username + "  " + Statics.level.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.w(24),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
