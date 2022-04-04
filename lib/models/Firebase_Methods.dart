import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:quiz_app/Statics.dart';
import 'package:quiz_app/models/PlayerSharedPrefs.dart';
import 'package:quiz_app/models/Questions.dart';
import 'package:week_of_year/week_of_year.dart';

class FirebaseInit {
  FirebaseFirestore _firestore;
  FirebaseApp _firebaseApp;
  FirebaseInit() {
    InitializeFirebase();
  }

  Future InitializeFirebase() async {
    _firebaseApp = await Firebase.initializeApp().then((value) {
      _firestore = FirebaseFirestore.instance;
      _firestore.settings = Settings(
        sslEnabled: false,
        persistenceEnabled: false,
      );
    });
  }

  Future<bool> userExists(String email) async =>
      (await _firestore.doc("users/$email").get()).exists;

  Future getQuestions(int level, int defficulty) async {
    String def = '';
    List<dynamic> map;
    if (defficulty == 1) {
      def = 'easy';
    } else if (defficulty == 2) {
      def = 'medium';
    } else if (defficulty == 3) {
      def = 'hard';
    }
    await _firestore
        .doc('Levels/$level')
        .collection('$def')
        .get()
        .then((querySnapshot) {
      map = querySnapshot.docs.map((e) => e.data()).toList();

      // for (var doc in value.docs) {
      //   map.add(new Question(
      //       id: doc.data()["id"],
      //       answer: doc.data()["answer_index"],
      //       options: doc.data()["options"] as List<dynamic>,
      //       question: doc.data()["question"]));
      // }
    });
    return map;
  }

  Future<List<dynamic>> loadLeaderboard() async {
    List<dynamic> r;
    await InitializeFirebase();
    await _firestore.collection('users').get().then((querySnapshot) {
      r = querySnapshot.docs
          .where((element) =>
              (element.data()['lastWin'] as Timestamp).toDate().year ==
                  Timestamp.now().toDate().year &&
              (element.data()['lastWin'] as Timestamp).toDate().month ==
                  Timestamp.now().toDate().month &&
              (element.data()['lastWin'] as Timestamp).toDate().day ==
                  Timestamp.now().toDate().day)
          .map((e) => e.data())
          .toList();
      r.sort((m1, m2) => (m2['points'] as int).compareTo(m1['points'] as int));
      print(r);
    });
    return r;
  }

  Future<List<dynamic>> loadLeaderboardWeekly() async {
    List<dynamic> r;
    await _firestore.collection('users').get().then((querySnapshot) {
      r = querySnapshot.docs
          .where((element) =>
              (element.data()['lastWin'] as Timestamp).toDate().year ==
                  Timestamp.now().toDate().year &&
              (element.data()['lastWin'] as Timestamp).toDate().month ==
                  Timestamp.now().toDate().month &&
              (element.data()['lastWin'] as Timestamp).toDate().weekOfYear ==
                  Timestamp.now().toDate().weekOfYear)
          .map((e) => e.data())
          .toList();
      r.sort((m1, m2) => (m2['points'] as int).compareTo(m1['points'] as int));
      print(Timestamp.now().toDate().weekOfYear.toString());
      print(r);
    });
    return r;
  }

  Future<String> loadData() async {
    String user;
    await FlutterSession().get('username').then((value) {
      Statics.username = value.toString();
      user = value.toString();
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
    return user;
  }

  Future<bool> signIn(String email, String password) async {
    bool b = false;
    try {
      var document = _firestore.doc('users/$email').snapshots();

      await document.first.then((value) async {
        if (value.exists) {
          if (value.data()['password'] == password) {
            await FlutterSession()
                .set('username', value.data()['username'].toString())
                .then((value) {
              Statics.username = value.toString();
            });

            await FlutterSession()
                .set('email', value.data()['email'].toString())
                .then((value) {
              Statics.email = value.toString();
            });
            await FlutterSession().set('logged', true).then((value) {
              Statics.islogged = value as bool;
            });
            ;
            await FlutterSession()
                .set('wins', value.data()['wins'])
                .then((value) {
              Statics.wins = value as int;
            });
            await FlutterSession()
                .set('offlineWins', value.data()['offlineWins'])
                .then((value) {
              Statics.offlineLoose = value as int;
            });
            await FlutterSession()
                .set('help', value.data()['help'])
                .then((value) {
              Statics.help = value as int;
            });
            await FlutterSession()
                .set('level', value.data()['level'])
                .then((value) {
              Statics.level = value as int;
            });
            await FlutterSession()
                .set('points', value.data()['points'])
                .then((value) {
              Statics.points = value as int;
            });
            // FlutterSession().set('loose', value.data()['loose']);
            await FlutterSession()
                .set('offlineLoose', value.data()['offlineLoose'])
                .then((value) {
              Statics.offlineLoose = value as int;
            });
            b = true;
            return true;
          } else {
            b = false;
            return false;
          }
        } else {
          b = false;
          return false;
        }
      });
    } catch (e) {}
    return b;
  }

  Future<void> setHelp() async {
    CollectionReference users = _firestore.collection('users');
    await users.doc(Statics.email).update({"help": Statics.help});
    await FlutterSession().set('help', Statics.help);
  }

  Future<void> setLevel() async {
    CollectionReference users = _firestore.collection('users');
    await users.doc(Statics.email).update({"level": Statics.level + 1});
    await FlutterSession().set('level', Statics.level + 1);
  }

  Future<void> setWins() async {
    CollectionReference users = _firestore.collection('users');
    await users
        .doc(Statics.email)
        .update({"wins": Statics.wins, "lastWin": DateTime.now()});
    await FlutterSession().set('wins', Statics.wins);
  }

  Future<void> setPoints() async {
    CollectionReference users = _firestore.collection('users');
    await users.doc(Statics.email).update({"points": Statics.points});
    await FlutterSession().set('points', Statics.points);
  }

  Future<String> Register(
      String username, String Email, String Password) async {
    await userExists(Email).then((value) {
      if (value) {
        print('Exists');
        return 'error Email is exists';
      } else {
        CollectionReference users = _firestore.collection('users');
        // Call the user's CollectionReference to add a new user
        users
            .doc(Email)
            .set({
              'username': username, // John Doe
              'email': Email, // Stokes and Sons
              'password': Password, // 42}
              'points': 10,
              'wins': 0,
              'offlineWins': 0,
              'loose': 0,
              'offlineLoose': 0,
              'help': 3,
              'level': 1,
              'lastWin': null
            })
            .then((value) => print("User Added"))
            .catchError((error) {
              return "error in adding";
            });
        return '';
      }
    });
    return '';
  }
}
