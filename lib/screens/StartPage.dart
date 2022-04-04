import 'package:flutter/material.dart';
import 'package:quiz_app/Statics.dart';
import 'package:quiz_app/internetChecker.dart';
import 'package:quiz_app/models/PlayerSharedPrefs.dart';
import 'package:quiz_app/screens/MainMenu/MainMenuPage.dart';
import 'package:quiz_app/screens/welcome/welcome_screen.dart';
import 'package:quiz_app/utils/SizeConfig.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key key}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  Future<bool> b;

  Future<bool> islogged() async {
    bool c = false;
    await FlutterSession().get('username').then((value) {
      Statics.username = value.toString();
    });
    await FlutterSession().get('email').then((value) {
      Statics.email = value.toString();
    });
    await FlutterSession().get('wins').then((value) {
      Statics.wins = value as int;
    });
    await FlutterSession().get('offlineWins').then((value) {
      Statics.offlineWins = value as int;
    });
    await FlutterSession().get('points').then((value) {
      Statics.points = value as int;
    });
    await FlutterSession().get('level').then((value) {
      Statics.level = value as int;
    });
    await FlutterSession().get('help').then((value) {
      Statics.help = value as int;
    });

    await FlutterSession().get('offlineLoose').then((value) {
      Statics.offlineLoose = value as int;
    });
    await FlutterSession().get('logged').then((value) {
      Statics.islogged = value as bool;
      if (Statics.islogged == null) {
        Statics.islogged = false;
      }
    });
    if (Statics.islogged == null)
      c = false;
    else
      c = true;
    return c;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    b = islogged();
    checkInternet().checkConnection(context);
    String v;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    checkInternet().listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      child: FutureBuilder<bool>(
          future: b,
          initialData: false,
          builder: (context, bools) {
            if (bools.hasData && Statics.islogged != null) {
              if (Statics.islogged)
                return MainMenuPage();
              else
                return WelcomeScreen();
            } else if (!bools.hasError) {
              return Center(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(),
                    Center(
                      child: Text(
                        'تحميل...',
                        style: TextStyle(
                          fontSize: SizeConfig.w(36),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(),
                  Center(
                    child: Text(
                      'تحميل...',
                      style: TextStyle(
                        fontSize: SizeConfig.w(36),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
