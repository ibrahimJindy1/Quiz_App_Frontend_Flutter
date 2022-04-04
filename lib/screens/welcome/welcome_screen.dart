import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:quiz_app/Statics.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/internetChecker.dart';
import 'package:quiz_app/models/Firebase_Methods.dart';
import 'package:quiz_app/models/PlayerSharedPrefs.dart';
import 'package:quiz_app/screens/MainMenu/MainMenuPage.dart';
import 'package:quiz_app/screens/quiz/quiz_screen.dart';
import 'package:quiz_app/screens/welcome/testPage.dart';
import 'package:quiz_app/utils/SizeConfig.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  FirebaseInit fire = new FirebaseInit();

  TextEditingController Email = new TextEditingController();

  TextEditingController Password = new TextEditingController();
  bool loading = false;
  bool loading1 = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkInternet().checkConnection(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    checkInternet().listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            SvgPicture.asset(
              "assets/icons/bg.svg",
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
            ),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Spacer(flex: 2), //2/6
                    Text(
                      "مرحباً بكم في تحدي الكشاف",
                      style: Theme.of(context).textTheme.headline4.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                        "اذا كانت هذه المرة الأولى لدخولك للعبة فأضغط إنشاء حساب جديد"),
                    Spacer(), // 1/6
                    // 1/6
                    TextField(
                      controller: Email,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF1C2341),
                        hintText: "الايميل",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(SizeConfig.w(12))),
                        ),
                      ),
                    ),
                    Spacer(), // 1/6
                    TextField(
                      controller: Password,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF1C2341),
                        hintText: "كلمة السر",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(SizeConfig.w(12))),
                        ),
                      ),
                    ),
                    Spacer(),
                    loading == false
                        ? InkWell(
                            onTap: () async {
                              setState(() {
                                loading = true;
                              });
                              await fire
                                  .signIn(Email.text, Password.text)
                                  .then((value) {
                                if (value != null) {
                                  if (value == true) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MainMenuPage()),
                                      (Route<dynamic> route) => false,
                                    );
                                    setState(() {
                                      loading = false;
                                    });
                                  } else {
                                    setState(() {
                                      loading = false;
                                      _showToast(context,
                                          "في كلمة السر او الايميل يرجى اعادة المحاولة");
                                    });
                                  }
                                } else {
                                  setState(() {
                                    loading = true;
                                  });
                                }
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding:
                                  EdgeInsets.all(kDefaultPadding * 0.75), // 15
                              decoration: BoxDecoration(
                                gradient: kPrimaryGradient,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(SizeConfig.w(12))),
                              ),
                              child: Text(
                                "ابدأ",
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(color: Colors.black),
                              ),
                            ),
                          )
                        : CircularProgressIndicator(),
                    Spacer(),
                    InkWell(
                      onTap: () => Get.to(() => RegisterPage()),
                      child: Container(
                        width: SizeConfig.screenWidth / 2,
                        height: SizeConfig.screenHeight / 20,
                        alignment: Alignment.center,
                        // 15
                        decoration: BoxDecoration(
                          gradient: kPrimaryGradientHelp,
                          borderRadius: BorderRadius.all(
                              Radius.circular(SizeConfig.w(12))),
                        ),
                        child: Text(
                          "إنشاء حساب جديد",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: SizeConfig.w(12),
                          ),
                        ),
                      ),
                    ),

                    Spacer(flex: 2), // it will take 2/6 spaces
                  ],
                ),
              ),
            ),
            // ,
          ],
        ),
      ),
    );
  }

  void _showToast(BuildContext context, String ss) {
    final scaffold = ScaffoldMessenger.of(context);

    scaffold.showSnackBar(
      SnackBar(
        content: Text('خطأ ' + ss),
      ),
    );
  }
}
