// lib/handler/dialog/Update_Sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../util/Daylit_Colors.dart';

class UpdateSheet extends StatelessWidget {
  const UpdateSheet({
    super.key,
    required this.updateInfo,
  });

  final UpdateInfo updateInfo;

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12.h,
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
              children: [
                // 업데이트 아이콘
                Container(
                  width: 60.r,
                  height: 60.r,
                  decoration: BoxDecoration(
                    gradient: DaylitColors.brandGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: DaylitColors.brandPrimary.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    color: Colors.white,
                    size: 30.r,
                  ),
                ),

                SizedBox(height: 20.h),

                // 타이틀
                Text(
                  updateInfo.isForceUpdate ? '필수 업데이트' : '업데이트 알림',
                  style: DaylitColors.heading2(color: colors.textPrimary).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8.h),

                // 버전 정보
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: DaylitColors.brandPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${updateInfo.currentVersion} → ${updateInfo.latestVersion}',
                    style: DaylitColors.bodyMedium(color: DaylitColors.brandPrimary).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // 업데이트 메시지
                if (updateInfo.updateMessage.isNotEmpty) ...[
                  Text(
                    updateInfo.updateMessage,
                    style: DaylitColors.bodyLarge(color: colors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                ],

                // 변경사항
                if (updateInfo.changelog.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '업데이트 내용',
                          style: DaylitColors.bodyLarge(color: colors.textPrimary).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        ...updateInfo.changelog.map((item) => Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6.r,
                                height: 6.r,
                                margin: EdgeInsets.only(top: 6.h, right: 12.w),
                                decoration: BoxDecoration(
                                  color: DaylitColors.brandPrimary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item,
                                  style: DaylitColors.bodyMedium(color: colors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],

                // 버튼들
                Column(
                  children: [
                    // 업데이트 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () => _launchStore(context, updateInfo),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: updateInfo.isForceUpdate
                              ? DaylitColors.error
                              : DaylitColors.brandPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          updateInfo.isForceUpdate ? '지금 업데이트' : '업데이트',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'pre',
                          ),
                        ),
                      ),
                    ),

                    // 나중에 버튼 (선택적 업데이트인 경우만)
                    if (!updateInfo.isForceUpdate) ...[
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: colors.textSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            '나중에',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'pre',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchStore(BuildContext context, UpdateInfo updateInfo) async {
    try {
      // TODO: 실제 스토어 URL로 교체
      final storeUrl = updateInfo.storeUrl;

      if (await canLaunchUrl(Uri.parse(storeUrl))) {
        await launchUrl(
          Uri.parse(storeUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showError(context, '스토어를 열 수 없습니다.');
      }
    } catch (e) {
      _showError(context, '업데이트를 시작할 수 없습니다.');
    }

    if (updateInfo.isForceUpdate) {
      // 강제 업데이트인 경우 앱 종료
      // SystemNavigator.pop();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DaylitColors.error,
      ),
    );
  }
}

/// 업데이트 정보 모델
class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final bool isForceUpdate;
  final String updateMessage;
  final List<String> changelog;
  final String storeUrl;

  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.isForceUpdate,
    required this.updateMessage,
    required this.changelog,
    this.storeUrl = '',
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      currentVersion: json['current_version'] ?? '',
      latestVersion: json['latest_version'] ?? '',
      isForceUpdate: json['is_force_update'] ?? false,
      updateMessage: json['update_message'] ?? '',
      changelog: List<String>.from(json['changelog'] ?? []),
      storeUrl: json['store_url'] ?? '',
    );
  }
}