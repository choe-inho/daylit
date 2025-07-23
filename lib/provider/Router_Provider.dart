import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RouterProvider extends ChangeNotifier{
  //뒤로가기 시간
  final Duration _backPressTimeout = const Duration(seconds: 2);

  //path히스토리관리
  List<String> get history => _history;
  List<String> _history = [];

  // 히스토리에 경로 추가
  void _addToHistory(String path) {
    // 같은 경로 연속 방문 방지
    if (state.historyStack.isNotEmpty && state.historyStack.last == path) {
      return;
    }

    final newHistory = List<String>.from(state.historyStack)..add(path);

    // 최대 개수 초과 시 가장 오래된 것 제거
    if (newHistory.length > state.maxHistorySize) {
      newHistory.removeAt(0);
    }

    state = state.copyWith(historyStack: newHistory);
    _printHistory(); // 디버그용
  }
  void backPress(){
    //마지막 이라면 나가기 시도
    if(_history.length == 1){
      if(_canExit && _exitTimer != null){ //터치 두번 실행
        if(Platform.isAndroid){
          SystemNavigator.pop();
        }else{
          exit(0);
        }
      }else{
        _canExit = true;
        _exitTimer = Timer.periodic(const Duration(seconds: 2), (_){
          _canExit = false;
          _exitTimer?.cancel();
        });
      }
    }
  }
}