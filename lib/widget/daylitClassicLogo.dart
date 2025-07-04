import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

class DayLitClassicLogo extends StatefulWidget {
  final double? fontSize;
  final bool showSun;
  final Duration animationDuration;

  const DayLitClassicLogo({
    super.key,
    this.fontSize,
    this.showSun = true,
    this.animationDuration = const Duration(seconds: 8),
  });

  @override
  State<DayLitClassicLogo> createState() => _DayLitClassicLogoState();
}

class _DayLitClassicLogoState extends State<DayLitClassicLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _glowController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // 회전 애니메이션 컨트롤러
    _rotationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // 글로우 애니메이션 컨트롤러
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // 회전 애니메이션 (0도 → 360도)
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // 글로우 애니메이션 (0.6 → 1.0)
    _glowAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // 애니메이션 시작
    _rotationController.repeat();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.fontSize ?? 60.sp;

    return SizedBox(
      width: fontSize * 3.5, // 적절한 너비 계산
      height: fontSize * 1.8, // 높이를 더 여유롭게 증가 (1.4 → 1.8)
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 메인 텍스트 (그라데이션)
          Positioned(
            bottom: fontSize * 0.1, // 아래쪽 여백 추가
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF87CEEB), // brandSecondary
                  Color(0xFF6BB6FF), // brandPrimary
                  Color(0xFF4A9EFF), // brandAccent
                ],
                stops: [0.0, 0.5, 1.0],
              ).createShader(bounds),
              child: Text(
                'DayLit',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'pre',
                  letterSpacing: fontSize * -0.02, // 반응형 letter spacing
                  color: Colors.white, // ShaderMask용 베이스 컬러
                  height: 1.2, // 줄간격을 여유롭게 (1.0 → 1.2)
                ),
              ),
            ),
          ),

          // 태양 (광선 + 중심부)
          if (widget.showSun)
            Positioned(
              top: fontSize * 0.05, // 위쪽 위치 조정 (-0.15 → 0.05)
              right: fontSize * -0.25,
              child: SizedBox(
                width: fontSize * 0.4,
                height: fontSize * 0.4,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 회전하는 태양 광선
                    AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: CustomPaint(
                            size: Size(fontSize * 0.4, fontSize * 0.4),
                            painter: SunRaysPainter(),
                          ),
                        );
                      },
                    ),

                    // 태양 중심부 (글로우 효과)
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: fontSize * 0.23,
                          height: fontSize * 0.23,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              center: Alignment(-0.3, -0.3), // 하이라이트 위치
                              radius: 1.0,
                              colors: [
                                Color(0xFFFFF9C4), // 밝은 중심
                                Color(0xFFFFED4E), // 중간 노랑
                                Color(0xFFFFD700), // 골드
                                Color(0xFFFFB300), // 어두운 골드
                              ],
                              stops: [0.0, 0.4, 0.8, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withValues(alpha: _glowAnimation.value * 0.8),
                                blurRadius: fontSize * 0.2 * _glowAnimation.value,
                                spreadRadius: fontSize * 0.02 * _glowAnimation.value,
                              ),
                              BoxShadow(
                                color: const Color(0xFFFFD700).withValues(alpha: _glowAnimation.value * 0.4),
                                blurRadius: fontSize * 0.4 * _glowAnimation.value,
                                spreadRadius: fontSize * 0.01 * _glowAnimation.value,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 태양 광선을 그리는 CustomPainter
class SunRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final innerRadius = size.width * 0.3;
    final outerRadius = size.width * 0.5;

    // 8방향 광선 그리기
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4); // 45도씩

      final startX = center.dx + innerRadius * math.cos(angle);
      final startY = center.dy + innerRadius * math.sin(angle);
      final endX = center.dx + outerRadius * math.cos(angle);
      final endY = center.dy + outerRadius * math.sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 다양한 크기의 로고 미리 정의된 위젯들
class DayLitLogo {
  // 대형 (스플래시, 메인)
  static Widget large({bool showSun = true}) => DayLitClassicLogo(
    fontSize: 60.sp,
    showSun: showSun,
  );

  // 중형 (헤더, 로그인)
  static Widget medium({bool showSun = true}) => DayLitClassicLogo(
    fontSize: 42.sp,
    showSun: showSun,
  );

  // 소형 (네비게이션, 버튼)
  static Widget small({bool showSun = true}) => DayLitClassicLogo(
    fontSize: 28.sp,
    showSun: showSun,
  );

  // 초소형 (아이콘)
  static Widget tiny({bool showSun = false}) => DayLitClassicLogo(
    fontSize: 18.sp,
    showSun: showSun,
  );

  // 커스텀 크기
  static Widget custom({
    required double fontSize,
    bool showSun = true,
    Duration? animationDuration,
  }) => DayLitClassicLogo(
    fontSize: fontSize,
    showSun: showSun,
    animationDuration: animationDuration ?? const Duration(seconds: 8),
  );
}
