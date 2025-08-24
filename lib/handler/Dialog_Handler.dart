import 'package:daylit/handler/dialog/Confirm_Dialog.dart';
import 'package:daylit/handler/dialog/Content_Sheet.dart';
import 'package:daylit/handler/dialog/Warning_Dialog.dart';
import 'package:daylit/l10n/app_localizations.dart';
import 'package:daylit/util/Daylit_Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'dialog/ColorMode_Sheet.dart';
import 'dialog/Language_Sheet.dart';
import 'dialog/Update_Sheet.dart';

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

  /// 업데이트 시트 표시
  static Future<bool?> showUpdateSheet({
    required BuildContext context,
    required UpdateInfo updateInfo,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: !updateInfo.isForceUpdate,
      enableDrag: !updateInfo.isForceUpdate,
      backgroundColor: Colors.transparent,
      builder: (context) => UpdateSheet(updateInfo: updateInfo),
    );
  }

  /// 색상 모드 선택 시트 표시
  static Future<void> showColorModeSheet({
    required BuildContext context,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ColorModeSheet(),
    );
  }

  /// 언어 선택 시트 표시
  static Future<void> showLanguageSheet({
    required BuildContext context,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSheet(),
    );
  }

// DialogHandler에 추가
  static Future<void> showWarning({
    required BuildContext context,
    String? title,
    required String message,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WarningDialog(
        title: title,
        subTitle: message,
      ),
    );
  }
}


