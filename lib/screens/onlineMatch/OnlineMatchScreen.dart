import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quiz_app/Statics.dart';
import 'package:quiz_app/internetChecker.dart';
import 'package:quiz_app/screens/quiz/components/LevelInitBody.dart';
import 'package:quiz_app/utils/SizeConfig.dart';
import 'package:socket_io_client/socket_io_client.dart';

class OnlineMatch extends StatefulWidget {
  const OnlineMatch({Key key}) : super(key: key);

  @override
  _OnlineMatchState createState() => _OnlineMatchState();
}

class _OnlineMatchState extends State<OnlineMatch> {
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
    // Statics.socket.on('startMatch', (data) => null);
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                Statics.oppName + "  " + Statics.oppLevel.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.w(34),
                ),
              ),
              BodyOnline(),
              Text(
                Statics.username + "  " + Statics.level.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.w(34),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
