import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../util/Daylit_Colors.dart';
import 'dart:math' as math;

/// DayLit 브랜드에 맞는 로딩 위젯 클래스
/// 브랜드 "D" 로고와 체크마크 요소를 활용한 로딩 컴포넌트들을 제공
class DaylitLoading {
  DaylitLoading._();

  // ==================== 전체 화면 오버레이 로딩 ====================

  /// 전체 화면을 덮는 오버레이 로딩 (브랜드 "D" 로고 사용)
  static Widget overlay({
    String? message,
    String? subtitle,
    bool dismissible = false,
    Color? backgroundColor,
    LoadingStyle style = LoadingStyle.brandLogo,
  }) {
    return _OverlayLoading(
      message: message,
      subtitle: subtitle,
      dismissible: dismissible,
      backgroundColor: backgroundColor,
      style: style,
    );
  }

  /// 풀스크린 로딩 (브랜드 정체성 강화)
  static Widget fullScreen({
    String? message,
    String? subtitle,
    bool showBrandLogo = true,
  }) {
    return _FullScreenLoading(
      message: message,
      subtitle: subtitle,
      showBrandLogo: showBrandLogo,
    );
  }

  // ==================== 버튼 내부 로딩 ====================

  /// 버튼 내부에 들어갈 브랜드 체크마크 로딩
  static Widget button({
    Color? color,
    double? size,
    LoadingButtonStyle buttonStyle = LoadingButtonStyle.check,
  }) {
    return _ButtonLoading(
      color: color,
      size: size,
      buttonStyle: buttonStyle,
    );
  }

  // ==================== 인라인 로딩 ====================

  /// 페이지 내부에 인라인으로 표시되는 브랜드 로딩
  static Widget inline({
    String? message,
    LoadingSize size = LoadingSize.medium,
    Color? color,
    LoadingAnimation animation = LoadingAnimation.brandD,
  }) {
    return _InlineLoading(
      message: message,
      size: size,
      color: color,
      animation: animation,
    );
  }

  // ==================== 카드 형태 로딩 ====================

  /// 카드 형태의 브랜드 로딩
  static Widget card({
    String? title,
    String? message,
    LoadingSize size = LoadingSize.medium,
    bool showBrandIcon = true,
  }) {
    return _CardLoading(
      title: title,
      message: message,
      size: size,
      showBrandIcon: showBrandIcon,
    );
  }

  // ==================== 아이콘 대체 로딩 ====================

  /// 아이콘 자리에 들어갈 작은 브랜드 로딩
  static Widget icon({
    double? size,
    Color? color,
    LoadingAnimation animation = LoadingAnimation.miniCheck,
  }) {
    return _IconLoading(
      size: size,
      color: color,
      animation: animation,
    );
  }

  // ==================== 루틴 완료 애니메이션 ====================

  /// 루틴 완료 시 사용하는 브랜드 체크 애니메이션
  static Widget routineComplete({
    String? message,
    VoidCallback? onComplete,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    return _RoutineCompleteAnimation(
      message: message,
      onComplete: onComplete,
      duration: duration,
    );
  }

  // ==================== 브랜드 펄스 로딩 ====================

  /// 브랜드 "D" 로고가 펄스하는 로딩
  static Widget brandPulse({
    double? size,
    Color? color,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return _BrandPulseLoading(
      size: size,
      color: color,
      duration: duration,
    );
  }
}

// ==================== 로딩 스타일 및 애니메이션 열거형 ====================

enum LoadingStyle {
  minimal,      // 최소한의 스타일
  card,         // 카드 형태
  gradient,     // 그라데이션 배경
  glass,        // 글라스모피즘
  brandLogo,    // 브랜드 로고 중심
}

enum LoadingSize {
  small,        // 16.r
  medium,       // 24.r
  large,        // 32.r
  xlarge,       // 48.r
}

enum LoadingAnimation {
  brandD,       // 브랜드 "D" 애니메이션
  check,        // 체크마크 애니메이션
  miniCheck,    // 작은 체크마크
  pulse,        // 펄스 애니메이션
  rotate,       // 회전 애니메이션
}

enum LoadingButtonStyle {
  check,        // 체크마크 스타일
  spinner,      // 기본 스피너
  brandD,       // 브랜드 D
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
    this.style = LoadingStyle.brandLogo,
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
      case LoadingStyle.brandLogo:
        return _buildBrandLogoStyle(colors);
    }
  }

  Widget _buildBrandLogoStyle(dynamic colors) {
    return Container(
      padding: EdgeInsets.all(32.w),
      margin: EdgeInsets.symmetric(horizontal: 48.w),
      decoration: BoxDecoration(
        gradient: colors.backgroundGradient,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: DaylitColors.brandPrimary.withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BrandDSpinner(size: 56.w),
          if(message != null || subtitle != null)
            SizedBox(height: 24.h),
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

  Widget _buildMinimalStyle(dynamic colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BrandDSpinner(size: 40.w, color: Colors.white),
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
          _BrandDSpinner(size: 40.w),
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
          _BrandDSpinner(size: 48.w, color: Colors.white),
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
          _BrandDSpinner(size: 44.w),
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
  final bool showBrandLogo;

  const _FullScreenLoading({
    this.message,
    this.subtitle,
    this.showBrandLogo = true,
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
          if (showBrandLogo) ...[
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/app/icon-white.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'DayLit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'pre',
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 48.h),
          ],
          _BrandDSpinner(size: 56.w, color: Colors.white),
          SizedBox(height: 24.h),
          if (message != null)
            Text(
              message!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
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
                fontSize: 16.sp,
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
  final LoadingButtonStyle buttonStyle;

  const _ButtonLoading({
    this.color,
    this.size,
    this.buttonStyle = LoadingButtonStyle.check,
  });

  @override
  Widget build(BuildContext context) {
    final loadingSize = size ?? 20.r;
    final loadingColor = color ?? Colors.white;

    switch (buttonStyle) {
      case LoadingButtonStyle.check:
        return _CheckSpinner(size: loadingSize, color: loadingColor);
      case LoadingButtonStyle.brandD:
        return Container(
          width: loadingSize,
          height: loadingSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: loadingSize,
                height: loadingSize,
                child: CircularProgressIndicator(
                  strokeWidth: loadingSize * 0.15,
                  valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
                  backgroundColor: loadingColor.withValues(alpha: 0.3),
                ),
              ),
              Container(
                width: loadingSize * 0.5,
                height: loadingSize * 0.5,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/app/icon-white.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      case LoadingButtonStyle.spinner:
        return SizedBox(
          width: loadingSize,
          height: loadingSize,
          child: CircularProgressIndicator(
            color: loadingColor,
            strokeWidth: 2.5, // 기본보다 조금 더 굵게
          ),
        );
    }
  }
}

// ==================== 인라인 로딩 구현 ====================

class _InlineLoading extends StatelessWidget {
  final String? message;
  final LoadingSize size;
  final Color? color;
  final LoadingAnimation animation;

  const _InlineLoading({
    this.message,
    this.size = LoadingSize.medium,
    this.color,
    this.animation = LoadingAnimation.brandD,
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
    final loadingColor = color ?? DaylitColors.brandPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAnimationWidget(loadingColor),
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

  Widget _buildAnimationWidget(Color color) {
    switch (animation) {
      case LoadingAnimation.brandD:
        return _BrandDSpinner(size: _size, color: color);
      case LoadingAnimation.check:
        return _CheckSpinner(size: _size, color: color);
      case LoadingAnimation.miniCheck:
        return _MiniCheckSpinner(size: _size, color: color);
      case LoadingAnimation.pulse:
        return _BrandPulseLoading(size: _size, color: color);
      case LoadingAnimation.rotate:
      // 기본 회전 인디케이터 (더 명확하게)
        return SizedBox(
          width: _size,
          height: _size,
          child: CircularProgressIndicator(
            color: color,
            strokeWidth: _size * 0.1, // 크기에 비례한 굵기
          ),
        );
    }
  }
}

// ==================== 카드 로딩 구현 ====================

class _CardLoading extends StatelessWidget {
  final String? title;
  final String? message;
  final LoadingSize size;
  final bool showBrandIcon;

  const _CardLoading({
    this.title,
    this.message,
    this.size = LoadingSize.medium,
    this.showBrandIcon = true,
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
        boxShadow: [
          BoxShadow(
            color: DaylitColors.brandPrimary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBrandIcon) _BrandDSpinner(size: _size),
          if (title != null) ...[
            if (showBrandIcon) SizedBox(height: 16.h),
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
  final LoadingAnimation animation;

  const _IconLoading({
    this.size,
    this.color,
    this.animation = LoadingAnimation.miniCheck,
  });

  @override
  Widget build(BuildContext context) {
    final loadingSize = size ?? 20.r;
    final loadingColor = color ?? DaylitColors.brandPrimary;

    switch (animation) {
      case LoadingAnimation.brandD:
        return _BrandDSpinner(size: loadingSize, color: loadingColor);
      case LoadingAnimation.check:
        return _CheckSpinner(size: loadingSize, color: loadingColor);
      case LoadingAnimation.miniCheck:
        return _MiniCheckSpinner(size: loadingSize, color: loadingColor);
      case LoadingAnimation.pulse:
        return _BrandPulseLoading(size: loadingSize, color: loadingColor);
      case LoadingAnimation.rotate:
      // 간단하고 명확한 회전 인디케이터
        return SizedBox(
          width: loadingSize,
          height: loadingSize,
          child: CircularProgressIndicator(
            color: loadingColor,
            strokeWidth: loadingSize * 0.12, // 적절한 굵기
          ),
        );
    }
  }
}

// ==================== 루틴 완료 애니메이션 ====================

class _RoutineCompleteAnimation extends StatefulWidget {
  final String? message;
  final VoidCallback? onComplete;
  final Duration duration;

  const _RoutineCompleteAnimation({
    this.message,
    this.onComplete,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<_RoutineCompleteAnimation> createState() => _RoutineCompleteAnimationState();
}

class _RoutineCompleteAnimationState extends State<_RoutineCompleteAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: colors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DaylitColors.brandPrimary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 48.r,
                  ),
                  if (widget.message != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      widget.message!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'pre',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== 브랜드 펄스 로딩 ====================

class _BrandPulseLoading extends StatefulWidget {
  final double? size;
  final Color? color;
  final Duration duration;

  const _BrandPulseLoading({
    this.size,
    this.color,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<_BrandPulseLoading> createState() => _BrandPulseLoadingState();
}

class _BrandPulseLoadingState extends State<_BrandPulseLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.size ?? 32.r,
            height: widget.size ?? 32.r,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/app/icon-white.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== 브랜드 "D" 스피너 ====================

class _BrandDSpinner extends StatefulWidget {
  final double size;
  final Color? color;

  const _BrandDSpinner({
    required this.size,
    this.color,
  });

  @override
  State<_BrandDSpinner> createState() => _BrandDSpinnerState();
}

class _BrandDSpinnerState extends State<_BrandDSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 외부 인디케이터 (더 굵고 명확하게)
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  strokeWidth: widget.size * 0.08, // 더 굵게
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.color ?? DaylitColors.brandPrimary,
                  ),
                  backgroundColor: (widget.color ?? DaylitColors.brandPrimary).withValues(alpha: 0.2),
                ),
              ),
              // 브랜드 로고 이미지 (펄스 효과)
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: widget.size * 0.5,
                  height: widget.size * 0.5,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/app/icon-primary.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ==================== 브랜드 "D" 로고 ====================

class _BrandDLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const _BrandDLogo({
    required this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/app/icon-white.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

// ==================== 체크 스피너 ====================

class _CheckSpinner extends StatefulWidget {
  final double size;
  final Color color;

  const _CheckSpinner({
    required this.size,
    required this.color,
  });

  @override
  State<_CheckSpinner> createState() => _CheckSpinnerState();
}

class _CheckSpinnerState extends State<_CheckSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 외부 인디케이터
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              strokeWidth: widget.size * 0.1,
              valueColor: AlwaysStoppedAnimation<Color>(widget.color),
              backgroundColor: widget.color.withValues(alpha: 0.2),
            ),
          ),
          // 중앙 체크 아이콘
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (math.sin(_controller.value * 2 * math.pi) * 0.1),
                child: Icon(
                  Icons.check,
                  color: widget.color,
                  size: widget.size * 0.5,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==================== 미니 체크 스피너 ====================

class _MiniCheckSpinner extends StatefulWidget {
  final double size;
  final Color color;

  const _MiniCheckSpinner({
    required this.size,
    required this.color,
  });

  @override
  State<_MiniCheckSpinner> createState() => _MiniCheckSpinnerState();
}

class _MiniCheckSpinnerState extends State<_MiniCheckSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (math.sin(_controller.value * 2 * math.pi) * 0.2),
            child: Container(
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: widget.size * 0.6,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== 커스텀 페인터들 ====================

class _BrandDProgressPainter extends CustomPainter {
  final Color color;
  final double progress;

  _BrandDProgressPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.05
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;

    // 진행 호 (상단에서 시작)
    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}