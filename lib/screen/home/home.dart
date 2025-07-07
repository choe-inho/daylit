import 'package:daylit/widget/daylitClassicLogo.dart';
import 'package:daylit/widget/daylitIconButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../util/daylitColors.dart';
import '../../widget/linearProgressWidget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState() {
    //위에 홈에서 필요한 단계적 처리 완료후
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          pinned: false,
          floating: true,
          snap: false,
          title: DayLitLogo.custom(fontSize: 30, showSun: false),
          centerTitle: false,
          actions: [
              DaylitIconButton(onPressed: (){}, iconData: LucideIcons.bell)
          ],
        ),
        //최상단에 오늘의 미션 진행도 표시
        SliverPadding(
          padding: EdgeInsetsGeometry.symmetric(vertical: 16.h, horizontal: 16.w),
          sliver: SliverToBoxAdapter(
            child: LinearProgressWidget(
              progress: 0.6,
              label: '이번 주 운동 목표',
              description: '4/7일 완료',
              leadingIcon: LucideIcons.activity,
              trailingIcon: LucideIcons.trophy,
            ),
          ),
        ),
        //광고/모임 피드 - 피드 형태가 좀 특 색있었으면 좋겠는데...
        /*SliverList.builder(
          itemCount: 2,
          itemBuilder: (BuildContext context, int index)=> DayLitFeed(),
        )*/
        SliverList.list(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 왼쪽 타임라인
                  Column(
                    children: [
                      // 시간 표시
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: DaylitColors.brandPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '오전 7:30',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: DaylitColors.brandPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      // 타임라인 점
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: DaylitColors.brandPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: DaylitColors.brandPrimary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      // 타임라인 선
                      Container(
                        width: 2.w,
                        height: 100.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              DaylitColors.brandPrimary,
                              DaylitColors.brandPrimary.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  // 오른쪽 콘텐츠
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(radius: 16.r),
                              SizedBox(width: 8.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('김데이', style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text('운동 미션 완료! 💪', style: TextStyle(fontSize: 12.sp)),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text('오늘도 30분 러닝 완주! 벌써 일주일째 성공 🔥'),
                          SizedBox(height: 8.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network('https://media.istockphoto.com/id/1419410282/de/foto/silent-wald-im-fr%C3%BChjahr-mit-sch%C3%B6nen-hellen-sonnenstrahlen.jpg?s=612x612&w=0&k=20&c=miHvD3R1qv_mis4Gp3bcuIzyJp7PlQXDBRK3yyjn1ww=', height: 120.h, width: double.infinity, fit: BoxFit.cover),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              height: 200.h,
              child: Stack(
                children: [
                  // 배경 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: Image.network('https://media.istockphoto.com/id/1317323736/ko/%EC%82%AC%EC%A7%84/%EB%82%98%EB%AC%B4-%EB%B0%A9%ED%96%A5%EC%9C%BC%EB%A1%9C-%ED%95%98%EB%8A%98%EB%A1%9C-%EB%B0%94%EB%9D%BC%EB%B3%B4%EB%8A%94-%EA%B2%BD%EC%B9%98.jpg?s=612x612&w=0&k=20&c=0xTghmMTXJ5ITCZ-LKTABbaPIK_1kWNf0FSFl_GL_7I=', fit: BoxFit.cover),
                    ),
                  ),
                  // 상단 진행도 바들
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    right: 12.w,
                    child: Row(
                      children: List.generate(4, (index) =>
                          Expanded(
                            child: Container(
                              height: 3.h,
                              margin: EdgeInsets.symmetric(horizontal: 1.w),
                              decoration: BoxDecoration(
                                color: index < 2 ? Colors.white : Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(1.5.r),
                              ),
                            ),
                          ),
                      ),
                    ),
                  ),
                  // 하단 정보
                  Positioned(
                    bottom: 16.h,
                    left: 16.w,
                    right: 16.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(radius: 16.r),
                            SizedBox(width: 8.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('이루틴', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text('3시간 전', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                              ],
                            ),
                            Spacer(),
                            Icon(LucideIcons.heart, color: Colors.white, size: 20.r),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '새벽 5시 기상 미션 7일차 성공! ☀️',
                          style: TextStyle(color: Colors.white, fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: DaylitColors.brandPrimary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 20.r),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('박미션', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                            Text('새로운 뱃지를 획득했어요!', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      Text('방금 전', style: TextStyle(color: Colors.grey[500], fontSize: 12.sp)),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // 뱃지 표시
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          DaylitColors.brandSecondary.withValues(alpha: 0.2),
                          DaylitColors.brandPrimary.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 60.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [DaylitColors.brandSecondary, DaylitColors.brandPrimary],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(LucideIcons.award, color: Colors.white, size: 30.r),
                        ),
                        SizedBox(height: 12.h),
                        Text('연속 7일 달성자', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                        Text('꾸준함의 힘을 보여주셨네요!', style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.heart, size: 16.r, color: Colors.grey[600]),
                          SizedBox(width: 4.w),
                          Text('24', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(LucideIcons.messageCircle, size: 16.r, color: Colors.grey[600]),
                          SizedBox(width: 4.w),
                          Text('축하해요!', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(LucideIcons.share, size: 16.r, color: Colors.grey[600]),
                          SizedBox(width: 4.w),
                          Text('공유', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: DaylitColors.brandPrimary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('이번 주 모임 현황', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: DaylitColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text('📈 +12%', style: TextStyle(color: DaylitColors.success, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // 여기에 간단한 차트 위젯 또는 진행도 바들
                  Container(
                    height: 100.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (index) {
                        double height = [0.3, 0.6, 0.8, 0.4, 0.9, 0.7, 1.0][index];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 8.w,
                              height: height * 80.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [DaylitColors.brandPrimary, DaylitColors.brandSecondary],
                                ),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(['월', '화', '수', '목', '금', '토', '일'][index],
                                style: TextStyle(fontSize: 10.sp, color: Colors.grey[600])),
                          ],
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text('팀원들이 이번 주 특히 열심히 하고 있어요! 🔥',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          DaylitColors.brandPrimary,
                          DaylitColors.brandSecondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.zap, color: Colors.white, size: 24.r),
                            SizedBox(width: 8.w),
                            Text('주간 도전', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text('3일 남음', style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Text('30일 연속 운동하기', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        Text('현재 127명이 도전 중!', style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('나의 진행도', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                                  SizedBox(height: 4.h),
                                  Text('12/30일', style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Container(
                              width: 60.w,
                              height: 60.w,
                              child: CircularProgressIndicator(
                                value: 12/30,
                                backgroundColor: Colors.white.withValues(alpha: 0.3),
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                                strokeWidth: 6,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 우상단 장식
                  Positioned(
                    top: -20.h,
                    right: -20.w,
                    child: Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        SliverPadding(padding: EdgeInsetsGeometry.only(bottom: 180))
      ],
    );
  }
}
