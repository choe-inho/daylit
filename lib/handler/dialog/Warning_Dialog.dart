import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../../util/Daylit_Colors.dart';

class WarningDialog extends StatelessWidget {
  const WarningDialog({super.key, this.title, required this.subTitle});
  final String? title;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ! 사용 (BottomSheet에서는 안전)
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
                // 아이콘과 제목
                Row(
                  children: [
                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: DaylitColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        LucideIcons.triangleAlert,
                        size: 20.r,
                        color: DaylitColors.error,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      title ?? '경고',
                      style: DaylitColors.heading3(color: colors.textPrimary).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // 내용
                Text(
                  subTitle,
                  style: DaylitColors.bodyLarge(color: colors.textPrimary),
                ),

                SizedBox(height: 24.h),

                // 확인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DaylitColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      l10n.done,
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
}