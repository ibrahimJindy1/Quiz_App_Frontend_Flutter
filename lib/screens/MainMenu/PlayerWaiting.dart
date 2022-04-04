import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:quiz_app/Statics.dart';
import 'package:quiz_app/internetChecker.dart';
import 'package:quiz_app/screens/MainMenu/MainMenuPage.dart';
import 'package:quiz_app/utils/SizeConfig.dart';

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({Key key}) : super(key: key);

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          SvgPicture.asset(
            "assets/icons/bg.svg",
            fit: BoxFit.fill,
            width: double.infinity,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'بإنتظار لاعب...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.w(34),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 10,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 9,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: TextButton(
                    onPressed: () {
                      Statics.socket.emit(
                          'Waitingdisconnect', {'roomId': Statics.roomId});
                      Get.offAll(MainMenuPage());
                    },
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                          color: Colors.white, fontSize: SizeConfig.w(38)),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
