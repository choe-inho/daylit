enum Social {
  kakao('kakao'),
  google('google'),
  apple('apple'),
  discord('discord');

  const Social(this.value);
  final String value;

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
}