import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import '../../util/daylitColors.dart';
import '../../util/deviceUtils.dart';
import '../../router/routerManager.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isObscure = true;
  bool _isConfirmObscure = true;
  bool _isLoading = false;
  bool _agreeTerms = false;
  bool _agreePrivacy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, deviceType) {
            return deviceType == DeviceType.tablet
                ? _buildTabletLayout(colors)
                : _buildMobileLayout(colors);
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(dynamic colors) {
    return SingleChildScrollView(
      child: Container(
        height: 1.sh,
        decoration: BoxDecoration(
          gradient: colors.backgroundGradient,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              _buildHeader(colors),
              SizedBox(height: 30.h),
              _buildWelcomeText(colors),
              SizedBox(height: 30.h),
              _buildRegisterForm(colors),
              SizedBox(height: 20.h),
              _buildAgreementSection(colors),
              SizedBox(height: 20.h),
              _buildRegisterButton(colors),
              const Spacer(),
              _buildLoginPrompt(colors),
              SizedBox(height: 30.h),
            ],
          ),
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
                      '새로운 하루를 시작해보세요\n건강한 루틴으로 더 나은 일상을',
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
          // 오른쪽 회원가입 폼
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
                      SizedBox(height: 20.h),
                      _buildWelcomeText(colors, isTablet: true),
                      SizedBox(height: 30.h),
                      _buildRegisterForm(colors, isTablet: true),
                      SizedBox(height: 20.h),
                      _buildAgreementSection(colors, isTablet: true),
                      SizedBox(height: 24.h),
                      _buildRegisterButton(colors, isTablet: true),
                      SizedBox(height: 30.h),
                      _buildLoginPrompt(colors, isTablet: true),
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

  Widget _buildHeader(dynamic colors) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            context.routerManager.navigateTo(AppRoutes.login);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: colors.textPrimary,
            size: 20.r,
          ),
        ),
        const Spacer(),
        Text(
          '회원가입',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'pre',
          ),
        ),
        const Spacer(),
        SizedBox(width: 40.w), // 균형을 위한 공간
      ],
    );
  }

  Widget _buildWelcomeText(dynamic colors, {bool isTablet = false}) {
    return Column(
      crossAxisAlignment: isTablet ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          '환영합니다!',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: isTablet ? 28.sp : 24.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'pre',
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '계정을 만들어 시작해보세요',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: isTablet ? 16.sp : 14.sp,
            fontWeight: FontWeight.w400,
            fontFamily: 'pre',
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(dynamic colors, {bool isTablet = false}) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildNameField(colors, isTablet: isTablet),
          SizedBox(height: 16.h),
          _buildEmailField(colors, isTablet: isTablet),
          SizedBox(height: 16.h),
          _buildPasswordField(colors, isTablet: isTablet),
          SizedBox(height: 16.h),
          _buildConfirmPasswordField(colors, isTablet: isTablet),
        ],
      ),
    );
  }

  Widget _buildNameField(dynamic colors, {bool isTablet = false}) {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: isTablet ? 16.sp : 14.sp,
        fontFamily: 'pre',
      ),
      decoration: InputDecoration(
        labelText: '이름',
        labelStyle: TextStyle(
          color: colors.textSecondary,
          fontSize: isTablet ? 16.sp : 14.sp,
          fontFamily: 'pre',
        ),
        prefixIcon: Icon(
          Icons.person_outline,
          color: colors.textSecondary,
          size: isTablet ? 24.r : 20.r,
        ),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: DaylitColors.brandPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: DaylitColors.error),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '이름을 입력해주세요';
        }
        if (value.length < 2) {
          return '이름은 2자 이상이어야 합니다';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(dynamic colors, {bool isTablet = false}) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: isTablet ? 16.sp : 14.sp,
        fontFamily: 'pre',
      ),
      decoration: InputDecoration(
        labelText: '이메일',
        labelStyle: TextStyle(
          color: colors.textSecondary,
          fontSize: isTablet ? 16.sp : 14.sp,
          fontFamily: 'pre',
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: colors.textSecondary,
          size: isTablet ? 24.r : 20.r,
        ),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: DaylitColors.brandPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: DaylitColors.error),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '이메일을 입력해주세요';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return '올바른 이메일 형식을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(dynamic colors, {bool isTablet = false}) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _isObscure,
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: isTablet ? 16.sp : 14.sp,
        fontFamily: 'pre',
      ),
      decoration: InputDecoration(
        labelText: '비밀번호',
        labelStyle: TextStyle(
          color: colors.textSecondary,
          fontSize: isTablet ? 16.sp : 14.sp,
          fontFamily: 'pre',
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: colors.textSecondary,
          size: isTablet ? 24.r : 20.r,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscure ? Icons.visibility_off : Icons.visibility,
            color: colors.textSecondary,
            size: isTablet ? 24.r : 20.r,
          ),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: DaylitColors.brandPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: DaylitColors.error),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '비밀번호를 입력해주세요';
        }
        if (value.length < 8) {
          return '비밀번호는 8자 이상이어야 합니다';
        }
        if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
          return '비밀번호는 영문과 숫자를 포함해야 합니다';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField(dynamic colors, {bool isTablet = false}) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _isConfirmObscure,
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: isTablet ? 16.sp : 14.sp,
        fontFamily: 'pre',
      ),
      decoration: InputDecoration(
        labelText: '비밀번호 확인',
        labelStyle: TextStyle(
          color: colors.textSecondary,
          fontSize: isTablet ? 16.sp : 14.sp,
          fontFamily: 'pre',
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: colors.textSecondary,
          size: isTablet ? 24.r : 20.r,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmObscure ? Icons.visibility_off : Icons.visibility,
            color: colors.textSecondary,
            size: isTablet ? 24.r : 20.r,
          ),
          onPressed: () {
            setState(() {
              _isConfirmObscure = !_isConfirmObscure;
            });
          },
        ),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: DaylitColors.brandPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: DaylitColors.error),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '비밀번호 확인을 입력해주세요';
        }
        if (value != _passwordController.text) {
          return '비밀번호가 일치하지 않습니다';
        }
        return null;
      },
    );
  }

  Widget _buildAgreementSection(dynamic colors, {bool isTablet = false}) {
    return Column(
      children: [
        _buildAgreementItem(
          colors,
          value: _agreeTerms,
          title: '서비스 이용약관 동의',
          required: true,
          onChanged: (value) {
            setState(() {
              _agreeTerms = value ?? false;
            });
          },
          onTap: () {
            // 이용약관 상세 페이지로 이동
          },
          isTablet: isTablet,
        ),
        SizedBox(height: 8.h),
        _buildAgreementItem(
          colors,
          value: _agreePrivacy,
          title: '개인정보 처리방침 동의',
          required: true,
          onChanged: (value) {
            setState(() {
              _agreePrivacy = value ?? false;
            });
          },
          onTap: () {
            // 개인정보 처리방침 상세 페이지로 이동
          },
          isTablet: isTablet,
        ),
      ],
    );
  }

  Widget _buildAgreementItem(
      dynamic colors, {
        required bool value,
        required String title,
        required bool required,
        required void Function(bool?) onChanged,
        required VoidCallback onTap,
        bool isTablet = false,
      }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: DaylitColors.brandPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Text.rich(
              TextSpan(
                children: [
                  if (required)
                    TextSpan(
                      text: '[필수] ',
                      style: TextStyle(
                        color: DaylitColors.error,
                        fontSize: isTablet ? 14.sp : 12.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'pre',
                      ),
                    ),
                  TextSpan(
                    text: title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: isTablet ? 14.sp : 12.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'pre',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          color: colors.textSecondary,
          size: isTablet ? 16.r : 14.r,
        ),
      ],
    );
  }

  Widget _buildRegisterButton(dynamic colors, {bool isTablet = false}) {
    final isEnabled = _agreeTerms && _agreePrivacy;

    return Container(
      width: double.infinity,
      height: isTablet ? 56.h : 48.h,
      decoration: BoxDecoration(
        gradient: isEnabled ? colors.primaryGradient : null,
        color: isEnabled ? null : colors.disabled,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: isEnabled ? [
          BoxShadow(
            color: DaylitColors.brandPrimary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: (isEnabled && !_isLoading) ? _handleRegister : null,
          child: Center(
            child: _isLoading
                ? SizedBox(
              width: 20.r,
              height: 20.r,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              '회원가입',
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 18.sp : 16.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'pre',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(dynamic colors, {bool isTablet = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '이미 계정이 있으신가요? ',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: isTablet ? 14.sp : 12.sp,
            fontFamily: 'pre',
          ),
        ),
        TextButton(
          onPressed: () {
            context.routerManager.navigateTo(AppRoutes.login);
          },
          child: Text(
            '로그인',
            style: TextStyle(
              color: DaylitColors.brandPrimary,
              fontSize: isTablet ? 14.sp : 12.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'pre',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeTerms || !_agreePrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('필수 약관에 동의해주세요'),
          backgroundColor: DaylitColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 회원가입 API 호출 로직
      await Future.delayed(const Duration(seconds: 2)); // 임시 딜레이

      // 회원가입 성공 시 로그인 페이지로 이동
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입이 완료되었습니다. 로그인해주세요.'),
            backgroundColor: DaylitColors.success,
          ),
        );
        context.routerManager.navigateTo(AppRoutes.login);
      }
    } catch (e) {
      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입에 실패했습니다: ${e.toString()}'),
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
}