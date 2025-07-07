import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../util/daylitColors.dart';

class LinearProgressWidget extends StatefulWidget {
  final double progress; // 0.0 ~ 1.0
  final String? label;
  final String? description;
  final double height;
  final Color? progressColor;
  final Color? backgroundColor;
  final bool showPercentage;
  final bool animateOnBuild;
  final Duration animationDuration;
  final BorderRadius? borderRadius;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const LinearProgressWidget({
    super.key,
    required this.progress,
    this.label,
    this.description,
    this.height = 8,
    this.progressColor,
    this.backgroundColor,
    this.showPercentage = true,
    this.animateOnBuild = true,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.borderRadius,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  State<LinearProgressWidget> createState() => _LinearProgressWidgetState();
}

class _LinearProgressWidgetState extends State<LinearProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animateOnBuild) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 라벨과 퍼센티지
        if (widget.label != null || widget.showPercentage)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.label != null)
                Row(
                  children: [
                    if (widget.leadingIcon != null) ...[
                      Icon(
                        widget.leadingIcon,
                        size: 16.r,
                        color: colors.textSecondary,
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Text(
                      widget.label!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                        fontFamily: 'pre',
                      ),
                    ),
                  ],
                ),
              if (widget.showPercentage)
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Text(
                          '${(_animation.value * 100).round()}%',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: widget.progressColor ?? DaylitColors.brandPrimary,
                            fontFamily: 'pre',
                          ),
                        );
                      },
                    ),
                    if (widget.trailingIcon != null) ...[
                      SizedBox(width: 6.w),
                      Icon(
                        widget.trailingIcon,
                        size: 16.r,
                        color: widget.progressColor ?? DaylitColors.brandPrimary,
                      ),
                    ],
                  ],
                ),
            ],
          ),

        if (widget.label != null || widget.showPercentage)
          SizedBox(height: 8.h),

        // 진행도 바
        Container(
          height: widget.height.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.backgroundColor ??
                (widget.progressColor ?? DaylitColors.brandPrimary).withValues(alpha: 0.1),
            borderRadius: widget.borderRadius ?? BorderRadius.circular((widget.height / 2).r),
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _animation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.progressColor ?? DaylitColors.brandPrimary,
                        (widget.progressColor ?? DaylitColors.brandPrimary).withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: widget.borderRadius ?? BorderRadius.circular((widget.height / 2).r),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.progressColor ?? DaylitColors.brandPrimary).withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 설명
        if (widget.description != null) ...[
          SizedBox(height: 6.h),
          Text(
            widget.description!,
            style: TextStyle(
              fontSize: 12.sp,
              color: colors.textSecondary,
              fontFamily: 'pre',
            ),
          ),
        ],
      ],
    );
  }
}