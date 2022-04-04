import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:quiz_app/Statics.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/internetChecker.dart';
import 'package:quiz_app/models/Firebase_Methods.dart';
import 'package:quiz_app/models/PlayerSharedPrefs.dart';
import 'package:quiz_app/models/Questions.dart';
import 'package:quiz_app/screens/MainMenu/PlayerWaiting.dart';
import 'package:quiz_app/screens/quiz/LevelInit.dart';
import 'package:quiz_app/screens/quiz/quiz_screen.dart';
import 'package:quiz_app/screens/welcome/welcome_screen.dart';
import 'package:quiz_app/utils/SizeConfig.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quiz_app/ad_helper.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({Key key}) : super(key: key);

  @override
  _MainMenuPageState createState() => _MainMenuPageState();
}

RewardedAd _rewardedAd;

// TODO: Add _isRewardedAdReady
bool _isRewardedAdReady = false;
// TODO: Add _bannerAd
BannerAd _bannerAd;

// TODO: Add _isBannerAdReady
bool _isBannerAdReady = false;

findMatch(BuildContext context) async {
  Statics.isAnswered = false;
  Statics.oppScore = 0;
  Statics.questions.clear();
  var rng = new Random();
  int r = rng.nextInt(Statics.level);
  if (Statics.level != 1)
    while (r == 0) {
      r = rng.nextInt(Statics.level);
    }
  else {
    r = 1;
  }
  await fire.getQuestions(r, deff).then((value) {
    // List<dynamic> s = value
    //     .map(
    //       (question) => Question(
    //         id: question['id'] as int,
    //         question: question['question'].toString(),
    //         options: question['options'],
    //         answer: int.parse(question['answer_index'].toString().trim()),
    //       ),
    //     )
    //     .toList();
    // if (s.length >= 10) {
    //   for (int i = 0; i < 10; i++) {
    //     Statics.questions.add(s[i]);
    //   }
    // } else {
    //   for (Question item in s) {
    //     Statics.questions.add(item);
    //   }
    // }

    if (value != null) {
      if (!Statics.socket.connected) {
        Statics.socket.connect();
      }
      Statics.socket.on('startMatch', (data) {
        Statics.oppName = data['username'];
        Statics.oppLevel = data['level'];
        Statics.roomId = data['roomId'];
        // Statics.questions = data['questions'];
        Statics.oppScore = 0;
        Statics.myScore = 0;
        print(data['roomId']);
        Statics.questions.clear();
        List<dynamic> s = data['questions']
            .map(
              (question) => Question(
                id: question['id'] as int,
                question: question['question'].toString(),
                options: question['options'],
                answer: int.parse(question['answer_index'].toString().trim()),
              ),
            )
            .toList();
        if (s.length >= 10) {
          for (int i = 0; i < 10; i++) {
            Statics.questions.add(s[i]);
          }
        } else {
          for (Question item in s) {
            Statics.questions.add(item);
          }
        }
        Get.reset();
        Get.to(InitScreen());
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => WaitingScreen()),
        //   (Route<dynamic> route) => false,
        // );
      });
      Statics.socket.emit('findGame', {
        "username": Statics.username,
        "level": Statics.level,
        "questions": value
      });

      Statics.socket.on('waitForPlayer', (data) {
        Statics.roomId = data['roomId'];
        Get.reset();
        Get.to(WaitingScreen());
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => WaitingScreen()),
        //   (Route<dynamic> route) => false,
        // );
      });
    }
  });
}

List<String> countries = [
  'جغرافيا',
  'علوم',
  'تاريخ',
  'فكر',
  'أدب',
  'فن',
  'حاليات',
  'منوعات',
];
int deff = 1;
int timer = 15;
Future<String> u;
List<dynamic> w;
signOut() {
  FlutterSession().remove('username');
  FlutterSession().remove('email');
  FlutterSession().remove('points');
  FlutterSession().remove('level');
  FlutterSession().remove('wins');
  FlutterSession().remove('offlineWIns');
  FlutterSession().remove('offlineLoose');
  FlutterSession().remove('help');
  FlutterSession().set('logged', false);
  Statics.clear();
  Get.offAll(WelcomeScreen());
}

goToQuetion(int index, BuildContext context) async {
  Statics.myScore = 0;
  Statics.currentLevel = index;
  Statics.questions.clear();

  await fire.getQuestions(index + 1, deff).then((value) {
    List<dynamic> s = value
        .map(
          (question) => Question(
            id: int.parse(question['id'].toString().trim()),
            question: question['question'].toString(),
            options: question['options'],
            answer: int.parse(question['answer_index'].toString().trim()),
          ),
        )
        .toList();
    var rng = new Random();
    while (Statics.questions.length < 15) {
      int n = rng.nextInt(s.length);
      Statics.questions.add(s[n]);
      s.removeAt(n);
    }
    // for (Question item in s) {
    //   Statics.questions.add(item);
    // }

    if (Statics.questions != null && Statics.questions.length > 0) {
      // Get.testMode = true;
      // Get.reset(clearRouteBindings: false, clearFactory: false);
      Statics.context = context;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(),
        ),
      );
    }
  });
}

FirebaseInit fire = new FirebaseInit();
int _currentIndex = 0;

class _MainMenuPageState extends State<MainMenuPage> {
  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                _isRewardedAdReady = false;
              });
              _loadRewardedAd();
            },
          );

          setState(() {
            _isRewardedAdReady = true;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded ad: ${err.message}');
          setState(() {
            _isRewardedAdReady = false;
          });
        },
      ),
    );
  }

  loadLeaderboard() {
    fire.loadLeaderboard();
  }

  final _scrollController = ScrollController(keepScrollOffset: true);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _loadRewardedAd();
    u = fire.loadData();
    checkInternet().checkConnection(context);
    if (Statics.socket == null || !Statics.socket.connected) {
      Statics.socket = io(
          url,
          OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
              // disable auto-connection
              .setExtraHeaders({'foo': 'bar'}) // optional
              .build());
    }

    // MobileAds.instance.initialize();
    // if (_bannerAd != null) {
    //   _bannerAd.dispose();
    //   _bannerAd = null;
    //   MobileAds.instance.initialize();
    // }
    // if (_bannerAd == null) {
    //   _bannerAd = BannerAd(
    //     adUnitId: AdHelper.bannerAdUnitId,
    //     request: AdRequest(),
    //     size: AdSize.banner,
    //     listener: BannerAdListener(
    //       onAdLoaded: (_) {
    //         setState(() {
    //           _isBannerAdReady = true;
    //         });
    //       },
    //       onAdFailedToLoad: (ad, err) {
    //         print('Failed to load a banner ad: ${err.message}');
    //         _isBannerAdReady = false;
    //         ad.dispose();
    //       },
    //     ),
    //   );

    //   _bannerAd.load();
    // }

    // IO.Socket socket = IO.io('http://192.168.43.39:3000');
    // socket.onConnect((_) {
    //   print('connect');
    //   socket.emit('msg', 'test');
    // });
    fire.loadLeaderboard().then((value) => {w = value});
  }

  bool _showLeaderboard = false;
  Future<void> showLeaderboard() async {
    w = await fire.loadLeaderboard();
    setState(() {
      _showLeaderboard = !_showLeaderboard;
    });
  }

  Future<void> switchLeaderboard(int ind) async {
    if (ind == 0) {
      w = await fire.loadLeaderboard();
    } else {
      w = await fire.loadLeaderboardWeekly();
    }
    setState(() {
      _currentIndex = ind;
    });
  }

  @override
  void dispose() {
    // TODO: Dispose a BannerAd object
    checkInternet().listener.cancel();
    _bannerAd.dispose();
    _rewardedAd.dispose();
    super.dispose();
  }

  Widget bannerAdWidget() {
    return StatefulBuilder(
      builder: (context, setState) => Container(
        child: _isBannerAdReady
            ? Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: _bannerAd.size.width.toDouble(),
                  height: _bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              )
            : SizedBox(
                width: 0,
                height: 0,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.reset();
    final textScale = MediaQuery.of(context).textScaleFactor;
    DateTime timeBackPressed = DateTime.now();

    // Statics.socket.onConnect((data) {
    //   print("connected");
    // });
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
        // appBar: AppBar(
        //   actions: [
        //     // TextButton.icon(
        //     //   onPressed: () => {signOut()},
        //     //   icon: Icon(Icons.arrow_back),
        //     //   label: Text('تسجيل خروج'),
        //     // ),
        //   ],
        //   title: Text('تحدي كشافنا'),
        //   backgroundColor: Color(0xff292842).withAlpha(200),
        //   centerTitle: true,
        //   foregroundColor: Colors.transparent,
        //   elevation: 50,
        // ),
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SvgPicture.asset(
              "assets/icons/bg.svg",
              fit: BoxFit.fill,
              width: double.infinity,
            ),
            FutureBuilder<String>(
                future: u,
                builder: (context, username) {
                  if (username.hasData) {
                    return SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: kDefaultPadding,
                        ),
                        child: Column(
                          children: [
                            // if (_isBannerAdReady)
                            //   Align(
                            //     alignment: Alignment.topCenter,
                            //     child: Container(
                            //       width: _bannerAd.size.width.toDouble(),
                            //       height: _bannerAd.size.height.toDouble(),
                            //       child: AdWidget(ad: _bannerAd),
                            //     ),
                            //   ),

                            Expanded(
                              flex: 2,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "الاسم: " + Statics.username,
                                          style: TextStyle(
                                            color: Colors.cyanAccent,
                                            fontSize: SizeConfig.w(18),
                                          ),
                                        ),
                                        Text("   "),
                                        Text(
                                          "النقاط: " +
                                              Statics.points.toString(),
                                          style: TextStyle(
                                            color: Colors.yellowAccent,
                                            fontSize: SizeConfig.w(18),
                                          ),
                                        ),
                                        Text("   "),
                                        Text(
                                          "المستوى: " +
                                              Statics.level.toString(),
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: SizeConfig.w(18),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              flex: MediaQuery.of(context).size.width <= 480
                                  ? 10
                                  : MediaQuery.of(context).size.width <= 720
                                      ? 8
                                      : 6,
                              child: Scrollbar(
                                controller: _scrollController,
                                isAlwaysShown: true,
                                child: ListView.builder(
                                    controller: _scrollController,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: countries.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(9.0),
                                        child: GestureDetector(
                                          onTap: () =>
                                              {goToQuetion(index, context)},
                                          child: Container(
                                            width: SizeConfig.screenWidth / 1.2,
                                            height: SizeConfig.screenWidth / 2,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      SizeConfig.w(50)),
                                              color: Color(0xff483c73)
                                                  .withAlpha(200),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  spreadRadius: 0.1,
                                                  blurRadius: 9,
                                                  offset: Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text('المستوى: ${index + 1}'),
                                                Text('${countries[index]}'),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Statics.level >= index + 1
                                                        ? Icon(
                                                            Icons
                                                                .lock_open_rounded,
                                                            color: Colors.green,
                                                          )
                                                        : Icon(
                                                            Icons
                                                                .lock_outline_rounded,
                                                            color: Colors.red,
                                                          ),
                                                    Statics.level >= index + 1
                                                        ? SvgPicture.asset(
                                                            "assets/icons/playGreenButton.svg",
                                                            height: SizeConfig
                                                                    .screenWidth /
                                                                8 *
                                                                textScale,
                                                            width: SizeConfig
                                                                    .screenWidth /
                                                                8 *
                                                                textScale,
                                                          )
                                                        : SvgPicture.asset(
                                                            "assets/icons/playGreenButton.svg",
                                                            height: SizeConfig
                                                                    .screenWidth /
                                                                8 *
                                                                textScale,
                                                            width: SizeConfig
                                                                    .screenWidth /
                                                                8 *
                                                                textScale,
                                                            color: Colors.red,
                                                          ),
                                                  ],
                                                ),
                                                Row()
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                            Spacer(
                              flex: 1,
                            ),
                            GestureDetector(
                              onTap: () {
                                findMatch(context);
                              },
                              child: Container(
                                width: SizeConfig.screenWidth / 2 * textScale,
                                height: SizeConfig.screenWidth / 7 * textScale,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(SizeConfig.w(50)),
                                  color: Color(0xffffd12b).withAlpha(200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 9,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text('تحدي أونلاين'),
                                ),
                              ),
                            ),
                            Spacer(
                              flex: 1,
                            ),
                            GestureDetector(
                              onTap: () {
                                showLeaderboard();
                              },
                              child: Container(
                                width: SizeConfig.screenWidth / 2 * textScale,
                                height: SizeConfig.screenWidth / 7 * textScale,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  // color: Color(0xffffd12b).withAlpha(200),
                                  gradient: kPrimaryGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 9,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text('المتصدرين'),
                                ),
                              ),
                            ),
                            Spacer(
                              flex: 1,
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (_isRewardedAdReady) {
                                  // Navigator.pop(context);
                                  _rewardedAd.show(
                                    onUserEarnedReward:
                                        (RewardedAd, RewardItem) async {
                                      Statics.help++;
                                      await fire.setHelp();
                                    },
                                  );
                                } else {
                                  _loadRewardedAd();
                                }
                              },
                              child: Container(
                                width: SizeConfig.screenWidth / 2 * textScale,
                                height: SizeConfig.screenWidth / 7 * textScale,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  // color: Color(0xffffd12b).withAlpha(200),
                                  gradient: kPrimaryGradientHelp,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 9,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'احصل على مساعدات' +
                                        "\n " +
                                        Statics.help.toString(),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            Spacer(
                              flex: 3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('اختر الصعوبة: '),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      deff = 1;
                                      Statics.levelDifiiculty = deff;
                                    });
                                  },
                                  child: Text(
                                    'سهل',
                                    style: TextStyle(
                                        color: deff == 1
                                            ? Colors.green
                                            : Colors.white),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      deff = 2;
                                      Statics.levelDifiiculty = deff;
                                    });
                                  },
                                  child: Text(
                                    'وسط',
                                    style: TextStyle(
                                        color: deff == 2
                                            ? Colors.yellow
                                            : Colors.white),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      deff = 3;
                                      Statics.levelDifiiculty = deff;
                                    });
                                  },
                                  child: Text(
                                    'صعب',
                                    style: TextStyle(
                                        color: deff == 3
                                            ? Colors.red
                                            : Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            Spacer(
                              flex: 1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('اختر المؤقت: '),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      timer = 15;
                                      Statics.levelTimer = 15;
                                    });
                                  },
                                  child: Text(
                                    '15 s',
                                    style: TextStyle(
                                        color: timer == 15
                                            ? Colors.green
                                            : Colors.white),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      timer = 30;
                                      Statics.levelTimer = 30;
                                    });
                                  },
                                  child: Text(
                                    '30 s',
                                    style: TextStyle(
                                        color: timer == 30
                                            ? Colors.yellow
                                            : Colors.white),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      timer = 60;
                                      Statics.levelTimer = 60;
                                    });
                                  },
                                  child: Text(
                                    '60 s',
                                    style: TextStyle(
                                        color: timer == 60
                                            ? Colors.red
                                            : Colors.white),
                                  ),
                                ),
                              ],
                            ),

                            bannerAdWidget(),
                          ],
                        ),
                      ),
                    );
                  } else if (username.hasError) {
                    return CircularProgressIndicator();
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
            Visibility(
              visible: _showLeaderboard,
              child: Scaffold(
                bottomNavigationBar: BottomNavigationBar(
                  onTap: switchLeaderboard,
                  currentIndex: _currentIndex,
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(Icons.view_day_rounded), label: 'يومياً'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.weekend_rounded), label: 'أسبوعياً'),
                  ],
                ),
                body: Container(
                  padding: EdgeInsets.only(top: 20),
                  width: double.infinity,
                  height: SizeConfig.screenHeight / 1.1,
                  // color: Colors.white,
                  decoration: BoxDecoration(
                    gradient: kPrimaryGradientLeaderboard,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: showLeaderboard,
                              child: Icon(Icons.close))
                        ],
                      ),
                      Container(
                        color: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'الاسم',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: SizeConfig.w(24)),
                            ),
                            Text(
                              'النقاط',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: SizeConfig.w(24)),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder(builder: (context, rows) {
                        return Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: w.length >= 10 ? 10 : w.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      w[index]['username'],
                                      style: TextStyle(
                                          color: index == 0
                                              ? Colors.yellowAccent
                                              : index == 1
                                                  ? Colors.grey[300]
                                                  : index == 2
                                                      ? Colors.brown
                                                      : Colors.white,
                                          fontSize: 24),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      w[index]['points'].toString(),
                                      style: TextStyle(
                                          color: index == 0
                                              ? Colors.yellowAccent
                                              : index == 1
                                                  ? Colors.grey[300]
                                                  : index == 2
                                                      ? Colors.brown
                                                      : Colors.white,
                                          fontSize: SizeConfig.w(24)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }),
                      // ListView.builder(
                      //   shrinkWrap: true,
                      //   itemCount: w.length >= 10 ? 10 : w.length,
                      //   itemBuilder: (BuildContext context, int index) {
                      //     return Padding(
                      //       padding: const EdgeInsets.all(16.0),
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //         children: [
                      //           Text(
                      //             w[index]['username'],
                      //             style: TextStyle(
                      //                 color: index == 0
                      //                     ? Colors.yellowAccent
                      //                     : index == 1
                      //                         ? Colors.grey[300]
                      //                         : index == 2
                      //                             ? Colors.brown
                      //                             : Colors.white,
                      //                 fontSize: 24),
                      //             textAlign: TextAlign.center,
                      //           ),
                      //           Text(
                      //             w[index]['points'].toString(),
                      //             style: TextStyle(
                      //                 color: index == 0
                      //                     ? Colors.yellowAccent
                      //                     : index == 1
                      //                         ? Colors.grey[300]
                      //                         : index == 2
                      //                             ? Colors.brown
                      //                             : Colors.white,
                      //                 fontSize: 24),
                      //             textAlign: TextAlign.center,
                      //           ),
                      //         ],
                      //       ),
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
