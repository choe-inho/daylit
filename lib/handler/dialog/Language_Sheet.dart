// lib/handler/dialog/Language_Sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../provider/App_State.dart';
import '../../util/Daylit_Colors.dart';

class LanguageSheet extends StatelessWidget {
  const LanguageSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);
    final l10n = AppLocalizations.of(context)!; // 추가

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
                        LucideIcons.languages,
                        size: 20.r,
                        color: DaylitColors.brandPrimary,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      l10n.languageTitle,
                      style: DaylitColors.heading3(color: colors.textPrimary).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // 언어 옵션들
                Consumer<AppState>(
                  builder: (context, appState, child) {
                    return Column(
                      children: [
                        _buildLanguageOption(
                          context: context,
                          colors: colors,
                          appState: appState,
                          languageCode: 'ko',
                          flag: '🇰🇷',
                          title: '한국어',
                          subtitle: 'Korean',
                        ),

                        SizedBox(height: 12.h),

                        _buildLanguageOption(
                          context: context,
                          colors: colors,
                          appState: appState,
                          languageCode: 'en',
                          flag: '🇺🇸',
                          title: 'English',
                          subtitle: '영어',
                        ),

                      /*  SizedBox(height: 12.h),
                        _buildLanguageOption(
                          context: context,
                          colors: colors,
                          appState: appState,
                          languageCode: 'ja',
                          flag: '🇯🇵',
                          title: '日本語',
                          subtitle: '일본어',
                        ),

                        SizedBox(height: 12.h),

                        _buildLanguageOption(
                          context: context,
                          colors: colors,
                          appState: appState,
                          languageCode: 'zh',
                          flag: '🇨🇳',
                          title: '中文',
                          subtitle: '중국어',
                        ),*/
                      ],
                    );
                  },
                ),

                SizedBox(height: 24.h),

                // 완료 버튼
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

  Widget _buildLanguageOption({
    required BuildContext context,
    required dynamic colors,
    required AppState appState,
    required String languageCode,
    required String flag,
    required String title,
    required String subtitle,
  }) {
    final isSelected = appState.language == languageCode;

    return InkWell(
      onTap: () async {
        if (!isSelected) {
          await appState.changeLanguage(languageCode);
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
            // 국기 아이콘
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: isSelected
                    ? DaylitColors.brandPrimary.withValues(alpha: 0.1)
                    : colors.textSecondary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isSelected
                      ? DaylitColors.brandPrimary.withValues(alpha: 0.3)
                      : colors.border.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Text(
                  flag,
                  style: TextStyle(fontSize: 20.sp),
                ),
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