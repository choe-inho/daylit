import 'package:daylit/model/quest/Quest_Model.dart';
import 'package:flutter/material.dart';

class QuestCreateProvider extends ChangeNotifier{
  String _purpose = '';
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _autoEndDate = true;

  ///========= getter =========
  String get purpose => _purpose;
  DateTime get endDate => _endDate;
  bool get autoEndDate => _autoEndDate;


  int get totalDate => _endDate.difference(DateTime.now()).inDays;
  ///========= setter =========

  setAutoEndDate(bool value){
    if(value != _autoEndDate){
      _autoEndDate = value;
      notifyListeners();
    }
  }

}