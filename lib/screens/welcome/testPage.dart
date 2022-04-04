import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/internetChecker.dart';
import 'package:quiz_app/models/Firebase_Methods.dart';
import 'package:quiz_app/screens/quiz/quiz_screen.dart';
import 'package:quiz_app/screens/welcome/welcome_screen.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

class RegisterPage extends StatefulWidget {
  // IO.Socket socket = IO.io(
  //     'http://10.0.2.2:3000',
  //     IO.OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
  //         .setExtraHeaders({'foo': 'bar'}) // optional
  //         .build());

  // socketConncect() {
  //   socket.onConnect((data) {
  //     debugPrint('connect');
  //     // socket.on('connected', (data) => debugPrint(data));
  //     // socket.on('fromServer', (_) => debugPrint(_));
  //   });

  //   // socket.onDisconnect((_) => print('disconnect'));
  //   // socket.on('fromServer', (_) => debugPrint(_));
  //   // socket.onDisconnect((_) => debugPrint('disconnect'));
  // }

  // socketDisConncect() {
  //   socket.onDisconnect((data) {
  //     debugPrint('Discconnect');
  //     // socket.on('connected', (data) => debugPrint(data));
  //     socket.on('fromServer', (_) => debugPrint(_));
  //   });
  // }
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  FirebaseInit fire = new FirebaseInit();

  TextEditingController username = new TextEditingController();

  TextEditingController Email = new TextEditingController();

  TextEditingController Password = new TextEditingController();

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset("assets/icons/bg.svg", fit: BoxFit.fill),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FutureBuilder(
                  //     future: _initialization,
                  //     builder: (context, snapshot) {
                  //       // Check for errors
                  //       if (snapshot.hasError) {
                  //         debugPrint(snapshot.error);
                  //       }

                  //       // Once complete, show your application
                  //       if (snapshot.connectionState == ConnectionState.done) {
                  //         debugPrint("connected");
                  //       }
                  //       return Container(
                  //         width: 0,
                  //         height: 0,
                  //       );
                  //       // Otherwise, show something whilst waiting for initialization to complete
                  //     }),
                  Spacer(flex: 1), //2/6
                  Text(
                    "أهلا بك في لعبة كشاف السريان",
                    style: Theme.of(context).textTheme.headline4.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text("أدخل معلوماتك في الأسفل"),
                  Spacer(), // 1/6
                  TextField(
                    controller: username,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFF1C2341),
                      hintText: "اسم المستخدم",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  Spacer(), // 1/6
                  TextField(
                    controller: Email,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFF1C2341),
                      hintText: "الايميل",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  Spacer(), // 1/6
                  TextField(
                    controller: Password,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFF1C2341),
                      hintText: "كلمة المرور",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  Spacer(
                    flex: 4,
                  ),
                  InkWell(
                    onTap: () {
                      if (username.text.isEmpty ||
                          Email.text.isEmpty ||
                          Password.text.isEmpty) {
                        _showToast(context);
                      } else {
                        fire.Register(username.text, Email.text, Password.text)
                            .then((value) {
                          if (value.contains('خطأ')) {
                            _showToast(context);
                          } else {
                            Get.to(() => WelcomeScreen());
                          }
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(kDefaultPadding * 0.75), // 15
                      decoration: BoxDecoration(
                        gradient: kPrimaryGradient,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Text(
                        "تسجيل",
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                  Spacer(flex: 4), // it will take 2/6 spaces
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('خطأ '),
      ),
    );
  }
}
