import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../util/Daylit_Colors.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({super.key, required this.title, required this.message, required this.confirmText, required this.cancelText, required this.isDestructive, this.icon});
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsetsGeometry.symmetric(vertical: 44.r, horizontal: 12.r),
      padding: EdgeInsetsGeometry.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          if(icon != null)...[
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: (isDestructive ? DaylitColors.error : DaylitColors.brandPrimary)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDestructive ? DaylitColors.error : DaylitColors.brandPrimary,
                size: 28.r,
              ),
            ),
            SizedBox(height: 20.h),
          ]
          else ...[
            SizedBox(height: 20.h),
          ],

          // 타이틀
          Text(
            title,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              fontFamily: 'pre',
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 12.h),

          // 메시지
          Text(
            message,
            style: TextStyle(
              fontSize: 15.sp,
              color: colors.textSecondary,
              fontFamily: 'pre',
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 32.h),
          // 버튼들 (가로 배치)
          Row(
            children: [
              // 취소 버튼
              Expanded(
                child: SizedBox(
                  height: 45.h,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: colors.surface,
                      foregroundColor: colors.textSecondary,
                      side: BorderSide(color: colors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      cancelText,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'pre',
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // 확인 버튼
              Expanded(
                child: SizedBox(
                  height: 45.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDestructive ? DaylitColors.error : DaylitColors.brandPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'pre',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
