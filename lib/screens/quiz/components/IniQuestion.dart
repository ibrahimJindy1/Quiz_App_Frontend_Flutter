import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_app/Statics.dart';
import 'package:quiz_app/controllers/question_controller_online.dart';
import 'package:quiz_app/models/Questions.dart';
import 'package:quiz_app/screens/quiz/components/LevelInitOption.dart';
import 'package:quiz_app/utils/SizeConfig.dart';

import '../../../constants.dart';

class QuestionCardOnline extends StatefulWidget {
  const QuestionCardOnline({
    Key key,
    // it means we have to pass this
    @required this.question,
  }) : super(key: key);

  final Question question;

  @override
  _QuestionCardOnlineState createState() => _QuestionCardOnlineState();
}

class _QuestionCardOnlineState extends State<QuestionCardOnline> {
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final swidth = MediaQuery.of(context).size.height;
    QuestionControllerOnline _controller = Get.put(QuestionControllerOnline());
    final textScale = MediaQuery.of(context).textScaleFactor;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: kDefaultPadding),
      padding: EdgeInsets.symmetric(
          horizontal: swidth <= 480
              ? kDefaultPadding / 2
              : swidth <= 720
                  ? kDefaultPadding / 1
                  : kDefaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Text(
            widget.question.question,
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: kBlackColor, fontSize: SizeConfig.w(16)),
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 80),
          ...List.generate(
            widget.question.options.length,
            (index) => OptionOnline(
              index: index,
              text: widget.question.options[index],
              press: () => _controller.checkAns(widget.question, index),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (!widget.question.options[0].toString().isEmpty &&
                  !widget.question.options[1].toString().isEmpty &&
                  !widget.question.options[2].toString().isEmpty &&
                  !widget.question.options[3].toString().isEmpty &&
                  Statics.help > 0)
                await _controller.TwoAnswersDelete(widget.question);

              setState(() {});
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 2 * textScale,
              height: MediaQuery.of(context).size.height / 30 * textScale,
              decoration: BoxDecoration(
                color: Statics.help > 0 ? Colors.green[600] : Colors.red[600],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 0.1,
                    blurRadius: 9,
                    offset: Offset(0, 6),
                  ),
                ],
                borderRadius: BorderRadius.circular(SizeConfig.w(12)),
              ),
              child: Center(
                child: Text(
                  'مساعدة  ${Statics.help}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
