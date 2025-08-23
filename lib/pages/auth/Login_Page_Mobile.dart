import 'package:daylit/handler/Dialog_Handler.dart';
import 'package:daylit/util/Daylit_Colors.dart';
import 'package:daylit/util/Daylit_Social.dart';
import 'package:daylit/widget/Daylit_Logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

class LoginPageMobile extends StatefulWidget {
  const LoginPageMobile({super.key});

  @override
  State<LoginPageMobile> createState() => _LoginPageMobileState();
}

class _LoginPageMobileState extends State<LoginPageMobile>
    with SingleTickerProviderStateMixin {

  // 로딩 상태 관리
  bool _isLoading = false;
  Social? _loadingSocial;

  // 애니메이션 컨트롤러
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    // 애니메이션 시작
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 소셜 로그인 처리
  Future<void> _handleSocialLogin(Social social) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _loadingSocial = social;
    });

    try {
      // TODO: 실제 소셜 로그인 로직 구현
      await Future.delayed(const Duration(seconds: 2));
      // 성공 시 홈으로 이동
      if (mounted) {
        context.go('/home');
      }

    } catch (e) {
      _showError('로그인에 실패했습니다. 다시 시도해 주세요.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingSocial = null;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DaylitColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // 상단 로고 및 브랜딩
          _buildHeaderSection(context),

          // 중간 소셜 로그인 버튼들
          Expanded(
            child: _buildSocialButtonsSection(),
          ),

          // 하단 약관 및 부가 정보
          _buildFooterSection(colors),
        ],
      ),
    );
  }

  /// 상단 헤더 섹션
  Widget _buildHeaderSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // 추가
    return Column(
      children: [
        SizedBox(height: 150.h,),
        // 로고
        DayLitLogo.medium(),

        SizedBox(height: 16.h),

        // 메인 메시지
        Text(
          l10n.loginTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: DaylitColors.of(context).textPrimary,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 8.h),

        // 서브 메시지
        Text(
          l10n.loginSubtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: DaylitColors.of(context).textSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 소셜 버튼 섹션
  Widget _buildSocialButtonsSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 소셜 버튼들
        ...Social.values.map((social) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _socialBtn(social, context),
        )),
      ],
    );
  }

  /// 하단 푸터 섹션
  Widget _buildFooterSection(dynamic colors) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        children: [
          // 구분선
          Container(
            height: 1,
            color: colors.divider,
            margin: EdgeInsets.symmetric(horizontal: 40.w),
          ),

          SizedBox(height: 20.h),

          // 약관 동의
          _buildTermsSection(colors),
        ],
      ),
    );
  }


  /// 약관 동의 섹션
  Widget _buildTermsSection(dynamic colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '계속 진행 시 ',
              style: TextStyle(
                fontSize: 11.sp,
                color: colors.textSecondary,
                fontFamily: 'pre',
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTermsLink('이용약관', colors),
                Text(
                  ' 및 ',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colors.textSecondary,
                    fontFamily: 'pre',
                  ),
                ),
                _buildTermsLink('개인정보처리방침', colors),
                Text(
                  '에',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colors.textSecondary,
                    fontFamily: 'pre',
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          '동의하는 것으로 간주됩니다.',
          style: TextStyle(
            fontSize: 11.sp,
            color: colors.textSecondary,
            fontFamily: 'pre',
          ),
        ),
      ],
    );
  }

  /// 약관 링크 위젯
  Widget _buildTermsLink(String text, dynamic colors) {
    return GestureDetector(
      onTap: () {
        // TODO: 약관 페이지로 이동
        _showTermsDialog(text);
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          color: DaylitColors.brandPrimary,
          fontFamily: 'pre',
          decoration: TextDecoration.underline,
          decorationColor: DaylitColors.brandPrimary,
        ),
      ),
    );
  }

  /// 약관 다이얼로그 (임시)
  void _showTermsDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('$title 내용이 여기에 표시됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 기존 소셜 버튼 (로딩 상태만 추가)
  Widget _socialBtn(Social social, BuildContext context) {
    final isLoading = _isLoading && _loadingSocial == social;
    final l10n = AppLocalizations.of(context)!; // 추가
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: isLoading ? null : () => _handleSocialLogin(social),
      child: Container(
        height: 45.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: social.mainColor,
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 0
            )
          ],
        ),
        padding: EdgeInsets.only(left: 8.w),
        child: Row(
          children: [
            Container(
              height: 33.r,
              width: 33.r,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: AssetImage(social.path),
                      fit: BoxFit.fill
                  )
              ),
            ),
            Expanded(
                child: Center(
                  child: isLoading
                      ? SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: social.onColor,
                    ),
                  )
                      : Text(
                    l10n.continueWith(getSocialDisplayName(social, l10n)),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: social.onColor,
                    ),
                  ),
                )
            )
          ],
        ),
      ),
    );
  }

  String getSocialDisplayName(Social social, l10n){
    switch (social){
      case Social.kakao : return l10n.kakao;
      case Social.google : return l10n.google;
      case Social.apple : return l10n.apple;
      case Social.discord : return l10n.discord;
    }
  }
}