import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../util/daylitColors.dart';
import 'dart:math' as math;

/// DayLit 브랜드에 맞는 로딩 위젯 클래스
/// 다양한 상황에서 재사용 가능한 로딩 컴포넌트들을 제공
class DaylitLoading {
  DaylitLoading._();

  // ==================== 전체 화면 오버레이 로딩 ====================

  /// 전체 화면을 덮는 오버레이 로딩
  /// 페이지 전체 로딩이 필요할 때 사용
  static Widget overlay({
    String? message,
    String? subtitle,
    bool dismissible = false,
    Color? backgroundColor,
    LoadingStyle style = LoadingStyle.card,
  }) {
    return _OverlayLoading(
      message: message,
      subtitle: subtitle,
      dismissible: dismissible,
      backgroundColor: backgroundColor,
      style: style,
    );
  }

  /// 풀스크린 로딩 (화면 전체를 덮음)
  static Widget fullScreen({
    String? message,
    String? subtitle,
    bool showLogo = true,
  }) {
    return _FullScreenLoading(
      message: message,
      subtitle: subtitle,
      showLogo: showLogo,
    );
  }

  // ==================== 버튼 내부 로딩 ====================

  /// 버튼 내부에 들어갈 작은 로딩 인디케이터
  static Widget button({
    Color? color,
    double? size,
    double strokeWidth = 2.0,
  }) {
    return _ButtonLoading(
      color: color,
      size: size,
      strokeWidth: strokeWidth,
    );
  }

  // ==================== 인라인 로딩 ====================

  /// 페이지 내부에 인라인으로 표시되는 로딩
  static Widget inline({
    String? message,
    LoadingSize size = LoadingSize.medium,
    Color? color,
  }) {
    return _InlineLoading(
      message: message,
      size: size,
      color: color,
    );
  }

  // ==================== 카드 형태 로딩 ====================

  /// 카드 형태의 로딩 (다이얼로그나 컨테이너 내부에 사용)
  static Widget card({
    String? title,
    String? message,
    LoadingSize size = LoadingSize.medium,
    bool showIcon = true,
  }) {
    return _CardLoading(
      title: title,
      message: message,
      size: size,
      showIcon: showIcon,
    );
  }

  // ==================== 아이콘 대체 로딩 ====================

  /// 아이콘 자리에 들어갈 작은 로딩
  static Widget icon({
    double? size,
    Color? color,
  }) {
    return _IconLoading(
      size: size,
      color: color,
    );
  }

  // ==================== 커스텀 로딩 ====================

  /// 완전히 커스터마이징 가능한 로딩
  static Widget custom({
    required Widget child,
    Duration duration = const Duration(seconds: 1),
    Curve curve = Curves.easeInOut,
  }) {
    return _CustomLoading(
      child: child,
      duration: duration,
      curve: curve,
    );
  }
}

// ==================== 로딩 스타일 열거형 ====================

enum LoadingStyle {
  minimal,    // 최소한의 스타일
  card,       // 카드 형태
  gradient,   // 그라데이션 배경
  glass,      // 글라스모피즘
}

enum LoadingSize {
  small,      // 16.r
  medium,     // 24.r
  large,      // 32.r
  xlarge,     // 48.r
}

// ==================== 오버레이 로딩 구현 ====================

class _OverlayLoading extends StatelessWidget {
  final String? message;
  final String? subtitle;
  final bool dismissible;
  final Color? backgroundColor;
  final LoadingStyle style;

  const _OverlayLoading({
    this.message,
    this.subtitle,
    this.dismissible = false,
    this.backgroundColor,
    this.style = LoadingStyle.card,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return GestureDetector(
      onTap: dismissible ? () => Navigator.of(context).pop() : null,
      child: Container(
        color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: _buildLoadingContent(colors),
        ),
      ),
    );
  }

  Widget _buildLoadingContent(dynamic colors) {
    switch (style) {
      case LoadingStyle.minimal:
        return _buildMinimalStyle(colors);
      case LoadingStyle.card:
        return _buildCardStyle(colors);
      case LoadingStyle.gradient:
        return _buildGradientStyle(colors);
      case LoadingStyle.glass:
        return _buildGlassStyle(colors);
    }
  }

  Widget _buildMinimalStyle(dynamic colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40.w,
          height: 40.w,
          child: CircularProgressIndicator(
            color: DaylitColors.brandPrimary,
            strokeWidth: 3,
          ),
        ),
        if (message != null) ...[
          SizedBox(height: 16.h),
          Text(
            message!,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'pre',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCardStyle(dynamic colors) {
    return Container(
      padding: EdgeInsets.all(24.w),
      margin: EdgeInsets.symmetric(horizontal: 48.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DaylitSpinner(size: 40.w),
          SizedBox(height: 16.h),
          if (message != null)
            Text(
              message!,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'pre',
              ),
              textAlign: TextAlign.center,
            ),
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle!,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12.sp,
                fontFamily: 'pre',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGradientStyle(dynamic colors) {
    return Container(
      padding: EdgeInsets.all(32.w),
      margin: EdgeInsets.symmetric(horizontal: 48.w),
      decoration: BoxDecoration(
        gradient: colors.primaryGradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: DaylitColors.brandPrimary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DaylitSpinner(size: 48.w, color: Colors.white),
          SizedBox(height: 20.h),
          if (message != null)
            Text(
              message!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'pre',
              ),
              textAlign: TextAlign.center,
            ),
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14.sp,
                fontFamily: 'pre',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGlassStyle(dynamic colors) {
    return Container(
      padding: EdgeInsets.all(28.w),
      margin: EdgeInsets.symmetric(horizontal: 48.w),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: DaylitColors.brandPrimary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DaylitSpinner(size: 44.w),
          SizedBox(height: 18.h),
          if (message != null)
            Text(
              message!,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'pre',
              ),
              textAlign: TextAlign.center,
            ),
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle!,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13.sp,
                fontFamily: 'pre',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ==================== 풀스크린 로딩 구현 ====================

class _FullScreenLoading extends StatelessWidget {
  final String? message;
  final String? subtitle;
  final bool showLogo;

  const _FullScreenLoading({
    this.message,
    this.subtitle,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: colors.primaryGradient,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showLogo) ...[
            Icon(
              Icons.wb_sunny_rounded,
              size: 80.w,
              color: Colors.white,
            ),
            SizedBox(height: 20.h),
            Text(
              'DayLit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'pre',
              ),
            ),
            SizedBox(height: 40.h),
          ],
          _DaylitSpinner(size: 48.w, color: Colors.white),
          SizedBox(height: 24.h),
          if (message != null)
            Text(
              message!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'pre',
              ),
              textAlign: TextAlign.center,
            ),
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14.sp,
                fontFamily: 'pre',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ==================== 버튼 로딩 구현 ====================

class _ButtonLoading extends StatelessWidget {
  final Color? color;
  final double? size;
  final double strokeWidth;

  const _ButtonLoading({
    this.color,
    this.size,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 20.r,
      height: size ?? 20.r,
      child: CircularProgressIndicator(
        color: color ?? Colors.white,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

// ==================== 인라인 로딩 구현 ====================

class _InlineLoading extends StatelessWidget {
  final String? message;
  final LoadingSize size;
  final Color? color;

  const _InlineLoading({
    this.message,
    this.size = LoadingSize.medium,
    this.color,
  });

  double get _size {
    switch (size) {
      case LoadingSize.small:
        return 16.r;
      case LoadingSize.medium:
        return 24.r;
      case LoadingSize.large:
        return 32.r;
      case LoadingSize.xlarge:
        return 48.r;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DaylitSpinner(
          size: _size,
          color: color ?? DaylitColors.brandPrimary,
        ),
        if (message != null) ...[
          SizedBox(height: 12.h),
          Text(
            message!,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14.sp,
              fontFamily: 'pre',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// ==================== 카드 로딩 구현 ====================

class _CardLoading extends StatelessWidget {
  final String? title;
  final String? message;
  final LoadingSize size;
  final bool showIcon;

  const _CardLoading({
    this.title,
    this.message,
    this.size = LoadingSize.medium,
    this.showIcon = true,
  });

  double get _size {
    switch (size) {
      case LoadingSize.small:
        return 24.r;
      case LoadingSize.medium:
        return 32.r;
      case LoadingSize.large:
        return 40.r;
      case LoadingSize.xlarge:
        return 56.r;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) _DaylitSpinner(size: _size),
          if (title != null) ...[
            if (showIcon) SizedBox(height: 16.h),
            Text(
              title!,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'pre',
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (message != null) ...[
            SizedBox(height: 8.h),
            Text(
              message!,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12.sp,
                fontFamily: 'pre',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ==================== 아이콘 로딩 구현 ====================

class _IconLoading extends StatelessWidget {
  final double? size;
  final Color? color;

  const _IconLoading({
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _DaylitSpinner(
      size: size ?? 20.r,
      color: color ?? DaylitColors.brandPrimary,
    );
  }
}

// ==================== 커스텀 로딩 구현 ====================

class _CustomLoading extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _CustomLoading({
    required this.child,
    this.duration = const Duration(seconds: 1),
    this.curve = Curves.easeInOut,
  });

  @override
  State<_CustomLoading> createState() => _CustomLoadingState();
}

class _CustomLoadingState extends State<_CustomLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2.0 * math.pi,
          child: widget.child,
        );
      },
    );
  }
}

// ==================== DayLit 브랜드 스피너 ====================

class _DaylitSpinner extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const _DaylitSpinner({
    required this.size,
    this.color,
    this.strokeWidth = 3.0,
  });

  @override
  State<_DaylitSpinner> createState() => _DaylitSpinnerState();
}

class _DaylitSpinnerState extends State<_DaylitSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _DaylitSpinnerPainter(
              progress: _animation.value,
              color: widget.color ?? DaylitColors.brandPrimary,
              strokeWidth: widget.strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

class _DaylitSpinnerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _DaylitSpinnerPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 배경 원
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 진행 호
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const sweepAngle = math.pi * 0.8;
    final startAngle = progress - sweepAngle / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}