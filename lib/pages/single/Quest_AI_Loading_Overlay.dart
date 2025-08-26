import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:math' as math;
import 'dart:async';
import '../../util/Daylit_Colors.dart';
import '../../provider/Quest_Create_Provider.dart';
import '../../util/Enhanced_Error_SnackBar.dart';

/// AI 퀘스트 생성 로딩 오버레이 페이지
class QuestAILoadingOverlay extends StatefulWidget {
  final String purpose;
  final int totalDays;

  const QuestAILoadingOverlay({
    super.key,
    required this.purpose,
    required this.totalDays,
  });

  /// 스태틱 메서드: 오버레이 표시
  static Future<QuestRequestResult?> show({
    required BuildContext context,
    required String purpose,
    required int totalDays,
  }) {
    return showGeneralDialog<QuestRequestResult>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return QuestAILoadingOverlay(
          purpose: purpose,
          totalDays: totalDays,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.7, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<QuestAILoadingOverlay> createState() => _QuestAILoadingOverlayState();
}

class _QuestAILoadingOverlayState extends State<QuestAILoadingOverlay> {
  // 상태 관리
  int _currentStep = 0;
  Timer? _stepTimer;
  Timer? _resultTimer;

  bool _isCompleted = false;

  // AI 생성 단계 메시지들
  final List<String> _stepMessages = [
    '회원님의 목표를 분석중이에요',
    '퀘스트를 생성하고있어요'
  ];

  @override
  void initState() {
    super.initState();
    _startAIGeneration();
  }

  void _startAIGeneration() {
    // 단계별 메시지 변경
    _stepTimer = Timer.periodic(const Duration(milliseconds: 1600), (timer) {
      if (_currentStep < _stepMessages.length - 1) {
        setState(() {
          _currentStep++;
        });
      }
    });

    // AI 생성 시뮬레이션 (3-8초 후 결과)
    final randomDelay = 3000 + math.Random().nextInt(5000); // 3-8초
    _resultTimer = Timer(Duration(milliseconds: randomDelay), () {
      _completeAIGeneration();
    });
  }

  Future<void> _completeAIGeneration() async {
    if (_isCompleted) return;

    _stepTimer?.cancel();
    _isCompleted = true;

    // 테스트용: 50% 확률로 성공/실패
    final isSuccess = math.Random().nextBool();

    if (isSuccess) {
      // 성공 애니메이션 후 성공 콜백
      setState(() {
        _currentStep = _stepMessages.length;
      });
    } else {
      // 실패 애니메이션 후 실패 콜백
      setState(() {
        _currentStep = -1; // 실패 상태
      });
    }
  }


  @override
  void dispose() {
    _stepTimer?.cancel();
    _resultTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        leading: Visibility(
            visible:  _currentStep == _stepMessages.length,
            child: IconButton(onPressed: (){
              Navigator.pop(context);
            }, icon: Icon(LucideIcons.chevronLeft, color: Theme.of(context).dividerColor), iconSize: 24.r)
        ) ,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.background.withValues(alpha: 0.95),
              colors.surface.withValues(alpha: 0.98),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 메인 로딩 컨테이너
                  _buildMainLoadingContainer(colors),
                  SizedBox(height: 48.h),
                  // 단계 메시지
                  _buildStepMessage(colors),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.only(bottom: 24.h, left: 16.w , right: 16.w),
              child: _currentStep == -1 ?
              GestureDetector(
                onTap: ()=> Navigator.pop(context),
                child: Container(
                  height: 46.h,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.error,
                        width: 2
                      )
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '뒤로가기',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ) : _currentStep == _stepMessages.length ?
              GestureDetector(
                onTap: ()=> Navigator.of(context).pop(QuestRequestResult.success),
                child: Container(
                  height: 46.h,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: DaylitColors.successGradient
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '결과확인',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color:const Color(0xffffffff),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ) :
              Container(),
            ),
          ],
        ),
      ),
    );
  }

  /// 메인 로딩 컨테이너
  Widget _buildMainLoadingContainer(dynamic colors) {
    if(_currentStep == -1){
      return Lottie.asset(_getLottieImage(), repeat: false, height: 180.r, width: 180.r, fit: BoxFit.cover);
    }else if(_currentStep >= _stepMessages.length){
      return Lottie.asset(_getLottieImage(), repeat: false, height: 180.r, width: 180.r, fit: BoxFit.cover);
    }else{
      return SizedBox(
          width: 180.r, height: 180.r,
          child: Lottie.asset(_getLottieImage(), reverse: true, height: 180.r, width: 180.r, fit: BoxFit.cover));
    }
  }

  /// 단계 메시지
  Widget _buildStepMessage(dynamic colors) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(_currentStep),
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          children: [
            // 메인 메시지
            Text(
              _getCurrentMessage(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: _currentStep == -1 ? DaylitColors.error : colors.textPrimary,
                fontFamily: 'pre',
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.h),

            // 서브 메시지
            Text(
              _getCurrentSubMessage(),
              style: TextStyle(
                fontSize: 14.sp,
                color: colors.textSecondary,
                fontFamily: 'pre',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 현재 단계 메시지 반환
  String _getCurrentMessage() {
    if (_currentStep == -1) {
      return 'AI 분석에 실패했어요';
    } else if (_currentStep >= _stepMessages.length) {
      return '퀘스트 생성이 완료되었어요!';
    } else {
      return _stepMessages[_currentStep];
    }
  }

  /// 현재 서브 메시지 반환
  String _getCurrentSubMessage() {
    if (_currentStep == -1) {
      return '목표를 다시 구체적으로 작성해주세요.\n더 자세한 정보가 있으면 더 좋은 결과를 만들 수 있어요.';
    } else if (_currentStep >= _stepMessages.length) {
      return '${widget.totalDays}일간의 맞춤 루틴이 준비되었습니다!';
    } else {
      String dot = '.';
      for(var i = 1; i <= _currentStep; i++){
        dot += '..';
      }
      return '잠시만 기다려주세요$dot';
    }
  }

  String _getLottieImage() {
    if (_currentStep == -1) {
      return 'assets/lottie/failed.json';
    } else if (_currentStep >= _stepMessages.length) {
      return 'assets/lottie/success.json';
    } else {
      return 'assets/lottie/ai.json';
    }
  }
}

/// Quest_Page_Mobile에서 완료 버튼 클릭 시 호출할 헬퍼 클래스
enum QuestRequestResult{
  error, //분석중 오류발생
  failed, //분석실패
  impossible, //불가능한 목표
  difficult, //도움이 어려운 목표
  isShort, //분석하기에는 너무 짧음
  success //분석완료
}

class QuestAIGenerationHelper {
  /// AI 퀘스트 생성 프로세스 시작
  static Future<QuestRequestResult?> startGeneration({
    required BuildContext context,
    required QuestCreateProvider provider,
  }) async {
    // 입력 값 검증
    if (provider.purpose.trim().isEmpty) {
      EnhancedErrorSnackBar.showError(context, '목표를 입력해주세요(최소 20자)');
      return QuestRequestResult.isShort;
    }

    if (provider.purpose.trim().length < 20) {
      EnhancedErrorSnackBar.showError(context, '목표를 더 세부적으로 입력해주세요(최소 20자)');
      return QuestRequestResult.isShort;
    }

    try {
      // AI 로딩 오버레이 표시
      final result = await QuestAILoadingOverlay.show(
        context: context,
        purpose: provider.purpose,
        totalDays: provider.totalDate,
      );

      return result;
    } catch (e) {
      debugPrint('❌ [QuestAIGenerationHelper] 퀘스트 생성 오류: $e');
      return QuestRequestResult.error;
    }
  }
}