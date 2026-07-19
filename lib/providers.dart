import 'package:flutter/foundation.dart';


class DataChoosedProvider extends ChangeNotifier {

  List<String> _myData = <String>[];

  DataChoosedProvider(String typePage, List initData) {

    if (typePage == 'ManualMainPage') {
      if (initData.isNotEmpty) {
        _myData = List<String>.from(initData);
      }
    } else {
      if (initData.isNotEmpty) {
        if (initData.length == 2) {
          _myData = List<String>.from(initData[1]);
        }
      }
    }
  }

  Future<void> fetchData(int index, bool value) async {
    await fetchDataById(index.toString(), value);
  }

  Future<void> fetchDataById(String id, bool value) async {
    final List<String> data = List<String>.from(_myData);
    if (value) {
      if (!data.contains(id)) {
        data.add(id);
      }
    } else {
      data.remove(id);
    }
    updateData(data);
  }

  void replaceData(List<String> data) {
    _myData = List<String>.from(data);
  }

  void notify() {
    notifyListeners();
  }

  void updateData(List<String> data) {
    _myData = List<String>.from(data);
    notifyListeners();
  }

  void clearData() {
    _myData = [];
    notifyListeners();
  }

  void setAllChecking(int lengthList) {
    List<String> tempData = <String>[];
    for (final index in Iterable<int>.generate(lengthList)) {
      tempData.add(index.toString());
    }
    _myData = tempData;
    notifyListeners();
  }

  void setAllCheckingIds(List<String> ids) {
    final List<String> tempData = List<String>.from(_myData);
    for (final id in ids) {
      if (!tempData.contains(id)) {
        tempData.add(id);
      }
    }
    _myData = tempData;
    notifyListeners();
  }

  void unsetCheckingIds(List<String> ids) {
    final List<String> tempData = List<String>.from(_myData);
    tempData.removeWhere(ids.contains);
    _myData = tempData;
    notifyListeners();
  }

  void setAllUnchecking() {
    _myData = [];
    notifyListeners();
  }

  List<String> get myData => _myData;

}
