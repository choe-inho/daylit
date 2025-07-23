import 'package:daylit/provider/Router_Provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 앱 전체의 뒤로가기 동작을 관리하는 핸들러
///
/// RouterProvider와 연동하여 다음 기능들을 제공합니다:
/// - 페이지 히스토리 기반 뒤로가기
/// - 루트 페이지에서 더블 탭 앱 종료
/// - 로딩 중 뒤로가기 차단
class BackPressHandler extends StatelessWidget {
  const BackPressHandler({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final router = Provider.of<RouterProvider>(context);

    return PopScope(
      // canPop을 false로 설정하여 모든 뒤로가기를 직접 처리
      canPop: false,

      // 뒤로가기 버튼이 눌렸을 때 호출되는 콜백
      onPopInvokedWithResult: (didPop, result) {
        // 이미 pop이 처리되었으면 추가 처리하지 않음
        if (didPop) {
          return;
        }

        // RouterProvider의 뒤로가기 처리 로직 실행
        final shouldExit = router.handleBackPress();

        // true가 반환되면 시스템 뒤로가기 허용 (앱 종료)
        if (shouldExit) {
          _logInfo('App exit allowed');
          // Navigator.pop(context)를 호출하여 실제 뒤로가기 실행
          Navigator.of(context).pop();
        } else {
          _logInfo('Back press handled by router');
          // false면 RouterProvider가 자체적으로 처리했으므로 추가 작업 없음
        }
      },

      child: child,
    );
  }

  /// 디버그 로깅
  void _logInfo(String message) {
    debugPrint('🔙 [BackPressHandler] $message');
  }
}