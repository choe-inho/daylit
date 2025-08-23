// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'DayLit';

  @override
  String get home => '홈';

  @override
  String get settings => '설정';

  @override
  String get profile => '프로필';

  @override
  String get quest => '퀘스트';

  @override
  String get loginTitle => '당신의 목표를 함께 시작해요';

  @override
  String get loginSubtitle => '간편하게 로그인하고 더 나은 하루를 만들어보세요';

  @override
  String get kakao => '카카오';

  @override
  String get google => '구글';

  @override
  String get apple => '애플';

  @override
  String get discord => '디스코드';

  @override
  String continueWith(String provider) {
    return '$provider로 시작하기';
  }

  @override
  String get settingsAccountPayment => '계정 & 결제';

  @override
  String get settingsAppSettings => '앱 설정';

  @override
  String get settingsInfoPolicy => '정보 & 정책';

  @override
  String get settingsAccountManagement => '계정 관리';

  @override
  String get litCharge => '릿 충전';

  @override
  String get litChargeDesc => '릿을 충전하여 더 많은 기능을 이용하세요';

  @override
  String get language => '언어';

  @override
  String get colorMode => '색상 모드';

  @override
  String get notifications => '알림';

  @override
  String get termsOfService => '이용약관';

  @override
  String get privacyPolicy => '개인정보처리방침';

  @override
  String get usagePolicy => '이용정책';

  @override
  String get licenses => '라이선스';

  @override
  String get versionInfo => '버전 정보';

  @override
  String get logout => '로그아웃';

  @override
  String get colorModeTitle => '색상 모드';

  @override
  String get colorModeDesc => '앱의 색상 테마를 선택하세요';

  @override
  String get systemMode => '시스템 설정 따르기';

  @override
  String get systemModeDesc => '기기의 설정에 따라 자동으로 변경됩니다';

  @override
  String get lightMode => '라이트 모드';

  @override
  String get lightModeDesc => '밝은 테마로 고정됩니다';

  @override
  String get darkMode => '다크 모드';

  @override
  String get darkModeDesc => '어두운 테마로 고정됩니다';

  @override
  String get languageTitle => '언어 설정';

  @override
  String get languageDesc => '앱에서 사용할 언어를 선택하세요';

  @override
  String get languageChanged => '언어가 변경되었습니다';

  @override
  String get done => '완료';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get later => '나중에';

  @override
  String get update => '업데이트';

  @override
  String get loading => '로딩 중...';

  @override
  String get emptyQuestTitle => '어떤 목표를 세우고\n진행해볼까요?';

  @override
  String get newGoal => '새 목표';

  @override
  String get email => '이메일';

  @override
  String get gender => '성별';

  @override
  String get male => '남성';

  @override
  String get female => '여성';

  @override
  String get regDate => '가입일';

  @override
  String get none => '알수없음';
}
