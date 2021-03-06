import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quiz_app/Statics.dart';
import 'package:quiz_app/ad_helper.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/controllers/question_controller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quiz_app/controllers/question_controller_online.dart';
import 'package:quiz_app/internetChecker.dart';
import 'package:quiz_app/screens/MainMenu/MainMenuPage.dart';
import 'package:quiz_app/utils/SizeConfig.dart';

class ScoreScreenOnline extends StatefulWidget {
  @override
  _ScoreScreenOnlineState createState() => _ScoreScreenOnlineState();
}

// InterstitialAd _interstitialAd;

// TODO: Add _isInterstitialAdReady
bool _isInterstitialAdReady = false;
// void _loadInterstitialAd() async {
//   InterstitialAd.load(
//     adUnitId: AdHelper.interstitialAdUnitId,
//     request: AdRequest(),
//     adLoadCallback: InterstitialAdLoadCallback(
//       onAdLoaded: (ad) {
//         _interstitialAd = ad;

//         ad.fullScreenContentCallback = FullScreenContentCallback(
//           onAdDismissedFullScreenContent: (ad) {
//             // _moveToHome();
//           },
//         );

//         _isInterstitialAdReady = true;
//       },
//       onAdFailedToLoad: (err) {
//         print('Failed to load an interstitial ad: ${err.message}');
//         _isInterstitialAdReady = false;
//       },
//     ),
//   );
// }

class _ScoreScreenOnlineState extends State<ScoreScreenOnline> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _loadInterstitialAd();
    checkInternet().checkConnection(context);
  }

  @override
  void dispose() {
    // TODO: Dispose an InterstitialAd object
    // _interstitialAd.dispose();
    checkInternet().listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        alignment: AlignmentDirectional.center,
        children: [
          SvgPicture.asset("assets/icons/bg.svg", fit: BoxFit.fill),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 1.2 * textScale,
                    height: MediaQuery.of(context).size.height / 2 * textScale,
                    decoration: BoxDecoration(
                      color: Colors.indigo[800],
                      borderRadius: BorderRadius.circular(SizeConfig.w(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 9,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.2 * textScale,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(SizeConfig.w(20)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/trophy-cup.svg",
                          height:
                              MediaQuery.of(context).size.width / 3 * textScale,
                          width:
                              MediaQuery.of(context).size.width / 3 * textScale,
                        ),
                        Statics.oppScore > Statics.myScore
                            ? Text(
                                '?????? ????????',
                                style: TextStyle(
                                  fontSize: SizeConfig.w(40),
                                ),
                              )
                            : Statics.oppScore < Statics.myScore
                                ? Text(
                                    '?????? ??????',
                                    style: TextStyle(
                                      fontSize: SizeConfig.w(40),
                                    ),
                                  )
                                : Text(
                                    '??????????',
                                    style: TextStyle(
                                      fontSize: SizeConfig.w(40),
                                    ),
                                  ),
                        SizedBox(
                          height: MediaQuery.of(context).size.width /
                              3.3 *
                              textScale,
                        ),
                        Text(
                          '??????????????',
                          style: TextStyle(color: Colors.white),
                        ),
                        Container(
                          height:
                              MediaQuery.of(context).size.width / 8 * textScale,
                          width:
                              MediaQuery.of(context).size.width / 3 * textScale,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius:
                                BorderRadius.circular(SizeConfig.w(20)),
                          ),
                          child: Center(
                            child: Statics.oppScore > Statics.myScore
                                ? Text('-10')
                                : Statics.oppScore < Statics.myScore
                                    ? Text('+10')
                                    : Text('0'),
                          ),
                        ),
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.width / 6 * textScale,
                        ),
                        Container(
                          height:
                              MediaQuery.of(context).size.width / 6 * textScale,
                          width:
                              MediaQuery.of(context).size.width / 3 * textScale,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius:
                                BorderRadius.circular(SizeConfig.w(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 9,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () {
                              // if (_isInterstitialAdReady) {
                              //   _interstitialAd?.show();
                              //   // Get.to(MainMenuPage());
                              //   Navigator.pushAndRemoveUntil(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => MainMenuPage()),
                              //     (Route<dynamic> route) => false,
                              //   );
                              // } else {
                              //   // _moveToHome();
                              Get.reset();
                              // Get.to(() => MainMenuPage());

                              // }
                              // Navigator.of(context).pushAndRemoveUntil(
                              //     MaterialPageRoute(
                              //         builder: (context) => MainMenuPage()),
                              //     (Route<dynamic> route) => false);
                              Get.offAll(MainMenuPage());
                            },
                            child: Text(
                              '????????????????',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
