import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:quiz_app/controllers/question_controller.dart';
import 'package:quiz_app/utils/SizeConfig.dart';

import 'components/body.dart';

class QuizScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    QuestionController _controller = Get.put(QuestionController());
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
        appBar: AppBar(
          // Fluttter show the back button automatically
          backwardsCompatibility: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          // actions: [
          //   FlatButton(
          //       onPressed: _controller.nextQuestion, child: Text("Skip")),
          // ],
        ),
        body: Body(),
      ),
    );
  }
}
