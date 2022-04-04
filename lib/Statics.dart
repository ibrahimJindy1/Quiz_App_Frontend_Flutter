import 'dart:core';

import 'package:flutter/material.dart';
import 'package:quiz_app/models/Questions.dart';
import 'package:socket_io_client/socket_io_client.dart';

class Statics {
  static Socket socket;
  static dynamic context = '';
  static String username = '';
  static String email = '';
  static bool islogged = null;
  static int wins = 0;
  static int offlineWins = 0;
  static int loose = 0;
  static int offlineLoose = 0;
  static int points = 10;
  static int help = 3;
  static int level = 1;
  static int levelTimer = 15;
  static int levelDifiiculty = 1;
  static List<Question> questions = [];
  static String oppName = '';
  static int oppLevel = -1;
  static String roomId = '';
  static int oppScore = 0;
  static int myScore = 0;
  static int currentLevel = 1;
  static bool isAnswered = false;
  static clear() {
    username = '';
    email = '';
    islogged = false;
    wins = 0;
    offlineWins = 0;
    loose = 0;
    offlineLoose = 0;
    points = 10;
    help = 3;
    level = 1;
  }
}
