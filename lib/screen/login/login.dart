import 'package:daylit/router/routerManager.dart';
import 'package:daylit/widget/daylitClassicLogo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import '../../util/daylitColors.dart';
import '../../util/daylitLoading.dart';
import '../../util/deviceUtils.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _loadingProvider;

  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: ResponsiveBuilder(
              builder: (context, deviceType) {
                return deviceType == DeviceType.tablet
                    ? _buildTabletLayout(colors)
                    : _buildMobileLayout(colors);
              },
            ),
          ),
          // 로딩 중일 때 DaylitLoading 오버레이
          if (_isLoading)
            DaylitLoading.overlay(
              style: LoadingStyle.brandLogo,
              dismissible: false,
            ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(dynamic colors) {
    return Container(
      height: 1.sh,
      decoration: BoxDecoration(
        gradient: colors.backgroundGradient,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(colors),
                  SizedBox(height: 8.h),
                  _buildWelcomeText(colors),
                ],
              ),
            ),
            _buildDivider(colors),
            SizedBox(height: 20.h),
            // 하단 이용약관 섹션
            _buildSocialLogin(colors),
            SizedBox(height: 40.h),
            _buildTermsSection(colors),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(dynamic colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: colors.backgroundGradient,
      ),
      child: Row(
        children: [
          // 왼쪽 브랜딩 영역
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: colors.primaryGradient,
              ),
              child: Padding(
                padding: EdgeInsets.all(60.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.wb_sunny_rounded,
                      size: 80.r,
                      color: Colors.white,
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Daylit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'pre',
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '매일의 루틴을 밝게 만들어주는\n당신의 하루 동반자',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'pre',
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 오른쪽 로그인 폼
          Expanded(
            flex: 1,
            child: Container(
              color: colors.surface,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(60.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 40.h),
                      _buildWelcomeText(colors, isTablet: true),
                      SizedBox(height: 40.h),
                      _buildSocialLogin(colors, isTablet: true),
                      SizedBox(height: 40.h),
                      _buildTermsSection(colors, isTablet: true),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(dynamic colors) {
    return Row(
      children: [
        Expanded(child: Divider(color: colors.divider)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            '간편 로그인',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12.sp,
              fontFamily: 'pre',
            ),
          ),
        ),
        Expanded(child: Divider(color: colors.divider)),
      ],
    );
  }

  Widget _buildLogo(dynamic colors) {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            gradient: colors.primaryGradient,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(40.r),
              bottomRight: Radius.circular(40.r),
              topLeft: Radius.circular(8.r),
              bottomLeft: Radius.circular(8.r),
            ),
            boxShadow: [
              BoxShadow(
                color: DaylitColors.brandPrimary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Image.asset(
            'assets/app/icon-white.png',
            height: 40.r,
            width: 40.r,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 16.h),
        DayLitLogo.medium(),
      ],
    );
  }

  Widget _buildWelcomeText(dynamic colors, {bool isTablet = false}) {
    return Text(
      '건강한 루틴으로 새로운 하루를 시작하세요',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: isTablet ? 16.sp : 14.sp,
        color: colors.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSocialLogin(dynamic colors, {bool isTablet = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSocialButton(
          colors,
          icon: 'assets/social/google.png',
          social: 'google',
          isTablet: isTablet,
        ),
        _buildSocialButton(
          colors,
          icon: 'assets/social/apple.png',
          social: 'apple',
          isTablet: isTablet,
        ),
        _buildSocialButton(
          colors,
          icon: 'assets/social/kakao.png',
          social: 'kakao',
          isTablet: isTablet,
        ),
        _buildSocialButton(
          colors,
          icon: 'assets/social/discord.png',
          social: 'discord',
          isTablet: isTablet,
        ),
      ],
    );
  }

  Widget _buildSocialButton(
      dynamic colors, {
        required String icon,
        required String social,
        bool isTablet = false,
      }) {
    return InkWell(
      onTap: ()=> _handleSocialLogin(social),
      customBorder: const CircleBorder(),
      child: Container(
        height: isTablet ? 56.h : 48.h,
        width: isTablet ? 56.h : 48.h,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              spreadRadius: 0,
              color: Theme.of(context).shadowColor,
            )
          ],
          image: DecorationImage(
            image: AssetImage(icon),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  //소셜로그인 처리 함수
  void _handleSocialLogin(String social) async{
    setState(() {
      _isLoading = true;
    });

    try {
      // 소셜 로그인 API 호출 (실제로는 여기서 각 소셜 로그인 SDK 사용)
      await Future.delayed(const Duration(seconds: 2)); // 임시 딜레이

      // 로그인 성공 시 상태 업데이트 후 홈으로 이동
      RouterManager.instance.setLoggedIn(true); // 👈 이 부분이 핵심!

      // setLoggedIn(true) 내부에서 자동으로 홈으로 이동하므로 별도 goHome() 불필요

    } catch (e) {
      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인에 실패했습니다: ${e.toString()}'),
            backgroundColor: DaylitColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  //서비스 이용약관 및 개인정보 처리방침 미리보기
  Widget _buildTermsSection(dynamic colors, {bool isTablet = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : 12.w),
      child: Column(
        children: [
          // 구분선
          Container(
            width: double.infinity,
            height: 1,
            color: colors.divider.withValues(alpha: 0.5),
            margin: EdgeInsets.only(bottom: 16.h),
          ),

          // 이용약관 텍스트
          Text.rich(
            TextSpan(
              text: '로그인 시 ',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: isTablet ? 12.sp : 11.sp,
                fontFamily: 'pre',
                height: 1.4,
              ),
              children: [
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => _showTermsDialog('이용약관'),
                    child: Text(
                      '이용약관',
                      style: TextStyle(
                        color: DaylitColors.brandPrimary,
                        fontSize: isTablet ? 12.sp : 11.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'pre',
                        decoration: TextDecoration.underline,
                        decorationColor: DaylitColors.brandPrimary,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: '과 '),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => _showTermsDialog('개인정보 처리방침'),
                    child: Text(
                      '개인정보 처리방침',
                      style: TextStyle(
                        color: DaylitColors.brandPrimary,
                        fontSize: isTablet ? 12.sp : 11.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'pre',
                        decoration: TextDecoration.underline,
                        decorationColor: DaylitColors.brandPrimary,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: '에 동의하게 됩니다.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 12.h),

          // 추가 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.copyright,
                size: isTablet ? 14.r : 12.r,
                color: colors.textHint,
              ),
              SizedBox(width: 4.w),
              Text(
                '${DateTime.now().year} iconoding. All rights reserved.',
                style: TextStyle(
                  color: colors.textHint,
                  fontSize: isTablet ? 10.sp : 9.sp,
                  fontFamily: 'pre',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final colors = DaylitColors.of(context);

        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'pre',
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300.h,
            child: SingleChildScrollView(
              child: Text(
                _getTermsContent(title),
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14.sp,
                  fontFamily: 'pre',
                  height: 1.5,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '확인',
                style: TextStyle(
                  color: DaylitColors.brandPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'pre',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getTermsContent(String title) {
    if (title == '서비스 이용약관') {
      return '''제1조 (목적)
본 약관은 Daylit(이하 "회사")이 제공하는 서비스의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (정의)
1. "서비스"란 회사가 제공하는 루틴 관리 및 관련 서비스를 의미합니다.
2. "이용자"란 본 약관에 따라 회사가 제공하는 서비스를 받는 회원 및 비회원을 의미합니다.
3. "회원"이란 회사에 개인정보를 제공하여 회원등록을 한 자로서, 회사의 정보를 지속적으로 제공받으며 회사가 제공하는 서비스를 계속적으로 이용할 수 있는 자를 의미합니다.

제3조 (약관의 효력 및 변경)
1. 본 약관은 서비스를 이용하고자 하는 모든 이용자에 대하여 그 효력을 발생합니다.
2. 회사는 관련 법령을 위배하지 않는 범위에서 본 약관을 변경할 수 있습니다.

제4조 (서비스의 제공)
1. 회사는 다음과 같은 서비스를 제공합니다:
   - 개인 루틴 관리 서비스
   - 습관 형성 및 추적 서비스
   - 커뮤니티 서비스
   - 기타 회사가 정하는 서비스

제5조 (서비스 이용)
1. 이용자는 본 약관에 동의함으로써 서비스를 이용할 수 있습니다.
2. 이용자는 서비스를 이용함에 있어 관련 법령과 본 약관을 준수해야 합니다.

※ 전체 약관은 설정 > 법적 고지에서 확인하실 수 있습니다.''';
    } else {
      return '''제1조 (개인정보의 처리목적)
Daylit(이하 "회사")은 다음의 목적을 위하여 개인정보를 처리합니다:

1. 회원가입 및 관리
   - 회원 식별, 회원자격 유지·관리
   - 서비스 부정이용 방지, 만 14세 미만 아동의 개인정보 처리시 법정대리인의 동의여부 확인

2. 서비스 제공
   - 루틴 관리 서비스 제공
   - 개인 맞춤형 콘텐츠 제공
   - 서비스 이용기록과 접속빈도 분석

3. 마케팅 및 광고에의 활용
   - 이벤트 및 광고성 정보 제공 및 참여기회 제공
   - 인구통계학적 특성에 따른 서비스 제공 및 광고 게재

제2조 (개인정보의 처리 및 보유기간)
1. 회사는 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집시에 동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.

2. 각각의 개인정보 처리 및 보유 기간은 다음과 같습니다:
   - 회원가입 및 관리: 회원탈퇴시까지
   - 서비스 제공: 서비스 종료시까지

제3조 (처리하는 개인정보의 항목)
1. 회사는 다음의 개인정보 항목을 처리하고 있습니다:
   - 필수항목: 이메일, 닉네임
   - 선택항목: 프로필 사진, 생년월일

제4조 (개인정보의 제3자 제공)
회사는 개인정보를 제1조(개인정보의 처리목적)에서 명시한 범위 내에서만 처리하며, 정보주체의 동의, 법률의 특별한 규정 등 개인정보 보호법 제17조 및 제18조에 해당하는 경우에만 개인정보를 제3자에게 제공합니다.

※ 전체 개인정보 처리방침은 설정 > 개인정보 처리방침에서 확인하실 수 있습니다.''';
    }
  }
}