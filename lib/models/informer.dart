import 'package:flutter/widgets.dart';

class Notifylist with ChangeNotifier {
  bool isSort = false;
  int index = 0;

  void clickSort() {
    if (isSort) {
      isSort = false;
    } else {
      isSort = true;
    }
    notifyListeners();
  }

  void clickColor() {
    int i = 0;
    if (i == 0) {
      notifyListeners();
    }
  }

  void reloadDeck() {
    int index = 0;
    if (index == 0) {
      notifyListeners();
    }
  }

  void newindex() {
    int i = 0;
    if (i == 0) {
      notifyListeners();
    }
  }
}
