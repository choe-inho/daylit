import 'package:flutter/material.dart';

/// 브랜딩 영역의 배경 패턴을 그리는 CustomPainter
///
/// 분할 화면 레이아웃의 좌측 브랜딩 영역에 장식용 원형 패턴들을 그립니다.
/// 패턴의 색상과 투명도를 조절할 수 있습니다.
class BrandingPatternPainter extends CustomPainter {
  final Color patternColor;
  final double patternOpacity;

  const BrandingPatternPainter({
    required this.patternColor,
    required this.patternOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = patternColor.withValues(alpha: patternOpacity)
      ..style = PaintingStyle.fill;

    // 원형 패턴들의 위치와 크기 정의
    final circles = _generateCirclePattern(size);

    // 각 원을 그리기
    for (final circle in circles) {
      canvas.drawCircle(
        Offset(circle.x, circle.y),
        circle.radius,
        paint,
      );
    }
  }

  /// 원형 패턴 생성
  List<_CircleData> _generateCirclePattern(Size size) {
    return [
      // 좌상단 작은 원
      _CircleData(size.width * 0.1, size.height * 0.2, 60),

      // 우상단 작은 원
      _CircleData(size.width * 0.8, size.height * 0.1, 40),

      // 우중단 큰 원
      _CircleData(size.width * 0.9, size.height * 0.6, 80),

      // 좌하단 중간 원
      _CircleData(size.width * 0.2, size.height * 0.8, 50),

      // 중하단 작은 원
      _CircleData(size.width * 0.6, size.height * 0.9, 30),

      // 추가 장식용 원들 (선택적)
      _CircleData(size.width * 0.5, size.height * 0.15, 25),
      _CircleData(size.width * 0.15, size.height * 0.5, 35),
    ];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! BrandingPatternPainter) return true;

    return oldDelegate.patternColor != patternColor ||
        oldDelegate.patternOpacity != patternOpacity;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BrandingPatternPainter &&
        other.patternColor == patternColor &&
        other.patternOpacity == patternOpacity;
  }

  @override
  int get hashCode => Object.hash(patternColor, patternOpacity);
}

/// 원형 데이터 클래스
class _CircleData {
  final double x;       // X 좌표
  final double y;       // Y 좌표
  final double radius;  // 반지름

  const _CircleData(this.x, this.y, this.radius);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _CircleData &&
        other.x == x &&
        other.y == y &&
        other.radius == radius;
  }

  @override
  int get hashCode => Object.hash(x, y, radius);

  @override
  String toString() => '_CircleData(x: $x, y: $y, radius: $radius)';
}

/// 다양한 패턴 스타일을 제공하는 유틸리티 클래스
class BrandingPatternStyles {
  BrandingPatternStyles._();

  /// 기본 패턴 (원형들)
  static BrandingPatternPainter circles({
    Color color = Colors.white,
    double opacity = 0.1,
  }) {
    return BrandingPatternPainter(
      patternColor: color,
      patternOpacity: opacity,
    );
  }

  /// 강조 패턴 (더 진한 색상)
  static BrandingPatternPainter emphasized({
    Color color = Colors.white,
    double opacity = 0.15,
  }) {
    return BrandingPatternPainter(
      patternColor: color,
      patternOpacity: opacity,
    );
  }

  /// 미묘한 패턴 (매우 연한 색상)
  static BrandingPatternPainter subtle({
    Color color = Colors.white,
    double opacity = 0.05,
  }) {
    return BrandingPatternPainter(
      patternColor: color,
      patternOpacity: opacity,
    );
  }
}

/// 커스텀 패턴을 만들기 위한 추상 클래스
abstract class CustomBrandingPainter extends CustomPainter {
  final Color patternColor;
  final double patternOpacity;

  const CustomBrandingPainter({
    required this.patternColor,
    required this.patternOpacity,
  });

  /// 하위 클래스에서 구현해야 하는 패턴 그리기 메서드
  void paintPattern(Canvas canvas, Size size, Paint paint);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = patternColor.withValues(alpha: patternOpacity)
      ..style = PaintingStyle.fill;

    paintPattern(canvas, size, paint);
  }
}

/// 사각형 패턴 페인터 예시
class SquarePatternPainter extends CustomBrandingPainter {
  const SquarePatternPainter({
    required super.patternColor,
    required super.patternOpacity,
  });

  @override
  void paintPattern(Canvas canvas, Size size, Paint paint) {
    final squareSize = 40.0;
    final spacing = 80.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final rect = Rect.fromLTWH(x, y, squareSize, squareSize);
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! SquarePatternPainter) return true;

    return oldDelegate.patternColor != patternColor ||
        oldDelegate.patternOpacity != patternOpacity;
  }
}

// ==================== 사용 예시 주석 ====================
/*
BrandingPatternPainter 사용법:

1. 기본 사용법:
CustomPaint(
  painter: BrandingPatternPainter(
    patternColor: Colors.white,
    patternOpacity: 0.1,
  ),
)

2. 스타일 유틸리티 사용:
CustomPaint(
  painter: BrandingPatternStyles.circles(),
)

CustomPaint(
  painter: BrandingPatternStyles.emphasized(
    color: Colors.blue,
    opacity: 0.2,
  ),
)

3. 커스텀 패턴 만들기:
class DiamondPatternPainter extends CustomBrandingPainter {
  const DiamondPatternPainter({
    required super.patternColor,
    required super.patternOpacity,
  });

  @override
  void paintPattern(Canvas canvas, Size size, Paint paint) {
    // 다이아몬드 패턴 그리기 로직
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

4. ResponsiveLayoutConfig에서 사용:
ResponsiveLayoutConfig(
  showBrandingPattern: true,
  brandingPatternColor: Colors.white,
  brandingPatternOpacity: 0.1,
)

특징:
- 성능 최적화된 shouldRepaint 구현
- 다양한 패턴 스타일 지원
- 커스텀 패턴 확장 가능
- 색상과 투명도 조절 가능
*/