import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:quiz_app/controllers/question_controller_online.dart';
// import 'package:get/get.dart';
// import 'package:quiz_app/controllers/question_controller_online.dart';
import 'package:quiz_app/screens/quiz/components/LevelInitBody.dart';
import 'package:quiz_app/utils/SizeConfig.dart';

class InitScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    QuestionControllerOnline _controller = Get.put(QuestionControllerOnline());
    DateTime timeBackPressed = DateTime.now();
    return WillPopScope(
      onWillPop: () async {
        final difference = DateTime.now().difference(timeBackPressed);
        final isExitWarning = difference >= Duration(seconds: 2);
        timeBackPressed = DateTime.now();
        if (isExitWarning) {
          final message = 'اضغط مرة أخرى للخروج';
          Fluttertoast.showToast(msg: message, fontSize: SizeConfig.w(18));
          return false;
        } else {
          Fluttertoast.cancel();
          return true;
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: BodyOnline(),
      ),
    );
  }
}
