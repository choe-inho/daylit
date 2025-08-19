import 'package:daylit/handler/dialog/Confirm_Dialog.dart';
import 'package:daylit/handler/dialog/Content_Sheet.dart';
import 'package:flutter/material.dart';

class DialogHandler{
  DialogHandler._();

  //기본 적으로 사용되는 알림용 다이얼로그
  static  Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    IconData? icon,
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDestructive = true,
  }){
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
  }

  static Future<T?> showContentSheet<T>({
    required BuildContext context,
    required String title,
    required String? image,
    bool isDismissible = true,
    bool showHandle = true,
    String? subtitle,
  }){
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => ContentSheet(
        title: title,
        subtitle: subtitle,
        image: image,
        showHandle: showHandle,
      ),
    );
  }
}


