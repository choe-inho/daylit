import 'dart:math';

import 'package:daylit/model/quest/Quest_Day_Model.dart';
import 'package:daylit/model/quest/Quest_Model.dart';
import 'package:daylit/util/Routine_Utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'App_State.dart';


class QuestCreateProvider extends ChangeNotifier{
  String _purpose = '';
  String _constraints = '';
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _autoEndDate = true;
  List<QuestDayModel> _quests = [];
  ///========= getter =========
  String get purpose => _purpose;
  String get constraints => _constraints;
  DateTime get endDate => _endDate;
  bool get autoEndDate => _autoEndDate;
  int get totalDate => _endDate.difference(DateTime.now()).inDays;
  List<QuestDayModel> get quests => _quests;

  ///========= setter =========
  setAutoEndDate(bool value){
    if(value != _autoEndDate){
      _autoEndDate = value;
      notifyListeners();
    }
  }

  setEndDate(DateTime date){
    if(date != _endDate){
      _endDate = date;
      notifyListeners();
    }
  }

  setPurpose(String value){
    if(value != _purpose){
      _purpose = value;
      notifyListeners();
    }
  }

  setConstraints(String value){
    if(_constraints != value){
      _constraints = value;
      notifyListeners();
    }
  }

  ///만들기 시작
  Future<QuestModel?> createQuest(String uid, BuildContext context) async{
    final sendData = {
      'id' : '$uid/',
      'action' : '최초생성',
      'language' : context.read<AppState>().language,
      'purpose' : _purpose,
      'constraints' : _constraints.isEmpty ? null : _constraints,
      'endDate' : _autoEndDate ? null : endDate.toIso8601String()
    };

   //여기서 ai한테 넘김
   await Future.delayed(const Duration(seconds: 5));

   ///테스트 모델
   final qid = '$uid/${DateTime.now().microsecondsSinceEpoch}';
   final quest = QuestModel(
       qid: qid,
       uid: uid,
       purpose: _purpose,
       constraints: _constraints,
       totalDays: _autoEndDate ? 30 : totalDate,
       totalCost: _autoEndDate ? 3000 : totalDate * 100,
       status: RoutineStatus.active,
       startDate: DateTime.now(),
       endDate: endDate,
       createdAt: DateTime.now(),
   );

    _quests = List.generate(_autoEndDate ? 30 : totalDate,(index) => QuestDayModel(
       qdid: index.toString(),
       qid: qid,
       date: DateTime.now().add(Duration(days: index)),
       dayNumber: index,
       mission: '아무거나',
       difficulty: MissionDifficulty.easy,
       estimatedMinutes: Random().nextInt(600),
       createdAt: DateTime.now()
   ));

    notifyListeners();
  }


  ///
}