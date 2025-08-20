// lib/handler/dialog/ColorMode_Sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../provider/App_State.dart';
import '../../util/Daylit_Colors.dart';

class ColorModeSheet extends StatelessWidget {
  const ColorModeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들 바
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h),
            decoration: BoxDecoration(
              color: colors.textHint.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Row(
                  children: [
                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: DaylitColors.brandPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        LucideIcons.palette,
                        size: 20.r,
                        color: DaylitColors.brandPrimary,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      '색상 모드',
                      style: DaylitColors.heading3(color: colors.textPrimary).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // 색상 모드 옵션들
                Consumer<AppState>(
                  builder: (context, appState, child) {
                    return Column(
                      children: [
                        _buildColorModeOption(
                          context: context,
                          colors: colors,
                          appState: appState,
                          mode: 'system',
                          icon: LucideIcons.smartphone,
                          title: '시스템 설정 따르기',
                          subtitle: '기기의 설정을 따릅니다',
                        ),

                        SizedBox(height: 12.h),

                        _buildColorModeOption(
                          context: context,
                          colors: colors,
                          appState: appState,
                          mode: 'light',
                          icon: LucideIcons.sun,
                          title: '라이트 모드',
                          subtitle: '밝은 테마로 고정됩니다',
                        ),

                        SizedBox(height: 12.h),

                        _buildColorModeOption(
                          context: context,
                          colors: colors,
                          appState: appState,
                          mode: 'dark',
                          icon: LucideIcons.moon,
                          title: '다크 모드',
                          subtitle: '어두운 테마로 고정됩니다',
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: 24.h),

                // 닫기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DaylitColors.brandPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      '완료',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'pre',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorModeOption({
    required BuildContext context,
    required dynamic colors,
    required AppState appState,
    required String mode,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = appState.colorMode == mode;

    return InkWell(
      onTap: () async {
        if (!isSelected) {
          await appState.changeColorMode(mode, context);
        }
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? DaylitColors.brandPrimary.withValues(alpha: 0.1)
              : colors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? DaylitColors.brandPrimary
                : colors.border.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: isSelected
                    ? DaylitColors.brandPrimary
                    : colors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: 20.r,
                color: isSelected
                    ? Colors.white
                    : colors.textSecondary,
              ),
            ),

            SizedBox(width: 16.w),

            // 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DaylitColors.bodyLarge(
                      color: isSelected
                          ? DaylitColors.brandPrimary
                          : colors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: DaylitColors.bodySmall(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 체크 아이콘
            if (isSelected) ...[
              SizedBox(width: 8.w),
              Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  color: DaylitColors.brandPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.check,
                  size: 14.r,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}