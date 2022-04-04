import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:quiz_app/Statics.dart';
import 'package:quiz_app/controllers/question_controller.dart';
import 'package:quiz_app/controllers/question_controller_online.dart';
import 'package:quiz_app/utils/SizeConfig.dart';

import '../../../constants.dart';

class OptionOnline extends StatelessWidget {
  const OptionOnline({
    Key key,
    this.text,
    this.index,
    this.press,
  }) : super(key: key);
  final String text;
  final int index;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    final TextScale = MediaQuery.of(context).textScaleFactor;
    final sWi = MediaQuery.of(context).size.height;
    return GetBuilder<QuestionControllerOnline>(
        init: QuestionControllerOnline(),
        builder: (qnController) {
          Color getTheRightColor() {
            if (qnController.isAnswered) {
              if (index == qnController.correctAns) {
                return kGreenColor;
              } else if (index == qnController.selectedAns &&
                  qnController.selectedAns != qnController.correctAns) {
                return kRedColor;
              }
            }

            return kGrayColor;
          }

          IconData getTheRightIcon() {
            return getTheRightColor() == kRedColor ? Icons.close : Icons.done;
          }

          return InkWell(
            onTap: Statics.isAnswered ? null : press,
            child: Container(
              margin: EdgeInsets.only(
                  top: sWi < 720 ? 1 : SizeConfig.w(kDefaultPadding)),
              padding: EdgeInsets.all(sWi <= 480
                  ? SizeConfig.w(kDefaultPadding) / 6
                  : sWi <= 560
                      ? SizeConfig.w(kDefaultPadding) / 3
                      : sWi <= 720
                          ? SizeConfig.w(kDefaultPadding) / 2
                          : SizeConfig.w(kDefaultPadding)),
              decoration: BoxDecoration(
                border: Border.all(color: getTheRightColor()),
                borderRadius: BorderRadius.circular(SizeConfig.w(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${index + 1}. $text",
                    style: TextStyle(
                        color: getTheRightColor(), fontSize: SizeConfig.w(14)),
                  ),
                  Container(
                    height: SizeConfig.w(15),
                    width: SizeConfig.w(15),
                    decoration: BoxDecoration(
                      color: getTheRightColor() == kGrayColor
                          ? Colors.transparent
                          : getTheRightColor(),
                      borderRadius: BorderRadius.circular(SizeConfig.w(50)),
                      border: Border.all(color: getTheRightColor()),
                    ),
                    child: getTheRightColor() == kGrayColor
                        ? null
                        : Icon(getTheRightIcon(), size: SizeConfig.w(12)),
                  )
                ],
              ),
            ),
          );
        });
  }
}
