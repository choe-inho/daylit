import 'dart:ui';

enum Social {
  kakao('kakao'),
  google('google'),
  apple('apple'),
  discord('discord');

  const Social(this.value);
  final String value;

  String get path {
    switch (this) {
      case Social.kakao:
        return 'assets/social/kakao.png';
      case Social.google:
        return 'assets/social/google.png';
      case Social.apple:
        return 'assets/social/apple.png';
      case Social.discord:
        return 'assets/social/discord.png';
    }
  }

  String get displayName {
    switch (this) {
      case Social.kakao:
        return '카카오';
      case Social.google:
        return '구글';
      case Social.apple:
        return '애플';
      case Social.discord:
        return '디스코드';
    }
  }

  Color get mainColor{
    switch (this) {
      case Social.kakao:
        return Color(0xffffea3a);
      case Social.google:
        return Color(0xffffffff);
      case Social.apple:
        return Color(0xff000000);
      case Social.discord:
        return Color(0xff5865fe);
    }
  }

  Color get onColor{
    switch (this) {
      case Social.kakao:
        return Color(0xff000000);
      case Social.google:
        return Color(0xff000000);
      case Social.apple:
        return Color(0xffffffff);
      case Social.discord:
        return Color(0xffffffff);
    }
  }
}