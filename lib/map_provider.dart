import 'package:flutter/material.dart';

class MapProvider extends ChangeNotifier {
  String instructions = '';
  double distance = 0;
  int idx = 0;
  int total_points = 0;
  bool loading = true;

  double time_left = 0;
  void setLoading() {
    loading = false;
  }

  void changeIndex(int i, int points) {
    idx = i;
    total_points = points;
    notifyListeners();
  }

  void setInstruction(String i, double t, double d) {
    instructions = i;
    distance = d;
    time_left = t;
    notifyListeners();
  }
}
