/// 지갑 모델 (릿 토큰 시스템)
class WalletModel {
  final String wid;              // 지갑 ID
  final String userId;           // 사용자 ID
  final int litBalance;          // 릿 잔액
  final int bonusLit;            // 보너스 릿
  final int totalSpent;          // 총 사용한 릿
  final int totalCharged;        // 총 충전한 릿
  final DateTime? lastUsedAt;    // 마지막 사용일
  final DateTime? lastChargedAt; // 마지막 충전일
  final WalletStatus status;     // 지갑 상태
  final DateTime createdAt;      // 생성일
  final DateTime updatedAt;      // 업데이트일

  WalletModel({
    required this.wid,
    required this.userId,
    required this.litBalance,
    required this.bonusLit,
    required this.totalSpent,
    required this.totalCharged,
    this.lastUsedAt,
    this.lastChargedAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // 새 사용자용 기본 지갑 생성
  factory WalletModel.createDefault(String userId) {
    final now = DateTime.now();
    return WalletModel(
      wid: 'wallet_$userId',
      userId: userId,
      litBalance: 0,
      bonusLit: 50,          // 신규 가입 보너스 50릿
      totalSpent: 0,
      totalCharged: 0,
      status: WalletStatus.active,
      createdAt: now,
      updatedAt: now,
    );
  }

  // JSON에서 생성
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      wid: json['wid'] ?? '',
      userId: json['user_id'] ?? '',
      litBalance: json['lit_balance'] ?? 0,
      bonusLit: json['bonus_lit'] ?? 0,
      totalSpent: json['total_spent'] ?? 0,
      totalCharged: json['total_charged'] ?? 0,
      lastUsedAt: json['last_used_at'] != null
          ? DateTime.tryParse(json['last_used_at'])
          : null,
      lastChargedAt: json['last_charged_at'] != null
          ? DateTime.tryParse(json['last_charged_at'])
          : null,
      status: toWalletStatus(json['status']),
      createdAt: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']) ?? DateTime.now(),
    );
  }

  // JSON으로 변환
  Map<String, dynamic> toMap() {
    return {
      'wid': wid,
      'user_id': userId,
      'lit_balance': litBalance,
      'bonus_lit': bonusLit,
      'total_spent': totalSpent,
      'total_charged': totalCharged,
      'last_used_at': lastUsedAt?.toIso8601String(),
      'last_charged_at': lastChargedAt?.toIso8601String(),
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // CopyWith
  WalletModel copyWith({
    String? wid,
    String? userId,
    int? litBalance,
    int? bonusLit,
    int? totalSpent,
    int? totalCharged,
    DateTime? lastUsedAt,
    DateTime? lastChargedAt,
    WalletStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      wid: wid ?? this.wid,
      userId: userId ?? this.userId,
      litBalance: litBalance ?? this.litBalance,
      bonusLit: bonusLit ?? this.bonusLit,
      totalSpent: totalSpent ?? this.totalSpent,
      totalCharged: totalCharged ?? this.totalCharged,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      lastChargedAt: lastChargedAt ?? this.lastChargedAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 릿 사용 (보너스 릿 먼저 사용)
  WalletModel useLit(int amount) {
    if (!canUseLit(amount)) {
      throw Exception('릿이 부족합니다. 필요: ${amount}릿, 보유: ${totalLit}릿');
    }

    int remainingAmount = amount;
    int newBonusLit = bonusLit;
    int newLitBalance = litBalance;

    // 1. 보너스 릿부터 사용
    if (remainingAmount > 0 && newBonusLit > 0) {
      final useFromBonus = remainingAmount > newBonusLit ? newBonusLit : remainingAmount;
      newBonusLit -= useFromBonus;
      remainingAmount -= useFromBonus;
    }

    // 2. 일반 릿 사용
    if (remainingAmount > 0) {
      newLitBalance -= remainingAmount;
    }

    return copyWith(
      litBalance: newLitBalance,
      bonusLit: newBonusLit,
      totalSpent: totalSpent + amount,
      lastUsedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // 릿 충전
  WalletModel chargeLit(int amount, {int bonusAmount = 0}) {
    return copyWith(
      litBalance: litBalance + amount,
      bonusLit: bonusLit + bonusAmount,
      totalCharged: totalCharged + amount,
      lastChargedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // 보너스 릿 지급
  WalletModel addBonusLit(int amount) {
    return copyWith(
      bonusLit: bonusLit + amount,
      updatedAt: DateTime.now(),
    );
  }

  // 유틸리티 메서드들
  int get totalLit => litBalance + bonusLit;
  bool get hasLit => totalLit > 0;
  bool get isActive => status == WalletStatus.active;
  bool canUseLit(int amount) => hasLit && totalLit >= amount && isActive;

  // 릿을 원화로 변환 (10릿 = 100원)
  int get totalValueInWon => totalLit * 10;
  int get balanceValueInWon => litBalance * 10;
  int get bonusValueInWon => bonusLit * 10;

  // 루틴 생성 가능 여부 체크
  bool canCreateRoutine(int days) {
    final requiredLit = days * 10; // 하루당 10릿
    return canUseLit(requiredLit);
  }

  // 충전 추천 금액 계산
  int getRecommendedChargeAmount(int neededLit) {
    final shortage = neededLit - totalLit;
    if (shortage <= 0) return 0;

    // 10릿 단위로 올림
    return ((shortage / 10).ceil()) * 10;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WalletModel && other.wid == wid;
  }

  @override
  int get hashCode => wid.hashCode;

  @override
  String toString() {
    return 'WalletModel{wid: $wid, userId: $userId, totalLit: $totalLit, status: $status}';
  }

  // static 변환 함수
  static WalletStatus toWalletStatus(String? status) {
    switch (status) {
      case 'active':
        return WalletStatus.active;
      case 'suspended':
        return WalletStatus.suspended;
      case 'closed':
        return WalletStatus.closed;
      default:
        return WalletStatus.active;
    }
  }
}

// 지갑 상태
enum WalletStatus {
  active('active'),       // 활성
  suspended('suspended'), // 정지
  closed('closed');       // 폐쇄

  const WalletStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case WalletStatus.active:
        return '활성';
      case WalletStatus.suspended:
        return '정지';
      case WalletStatus.closed:
        return '폐쇄';
    }
  }
}

// 릿 패키지 모델 (충전 상품)
class LitPackageModel {
  final String pid;           // 패키지 ID
  final String name;          // 패키지 이름
  final int litAmount;        // 릿 수량
  final int bonusLit;         // 보너스 릿
  final int priceWon;         // 가격 (원)
  final PackageType type;     // 패키지 타입
  final bool isPopular;       // 인기 상품
  final bool isEvent;         // 이벤트 상품
  final DateTime? eventEndDate; // 이벤트 종료일

  LitPackageModel({
    required this.pid,
    required this.name,
    required this.litAmount,
    this.bonusLit = 0,
    required this.priceWon,
    required this.type,
    this.isPopular = false,
    this.isEvent = false,
    this.eventEndDate,
  });

  // 기본 패키지들
  static List<LitPackageModel> getDefaultPackages() {
    return [
      // 기본 패키지
      LitPackageModel(
        pid: 'basic_100',
        name: '스타터 100릿',
        litAmount: 100,
        priceWon: 1000,
        type: PackageType.basic,
      ),

      // 인기 패키지 (10% 보너스)
      LitPackageModel(
        pid: 'popular_500',
        name: '인기 500릿',
        litAmount: 500,
        bonusLit: 50, // 10% 보너스
        priceWon: 5000,
        type: PackageType.popular,
        isPopular: true,
      ),

      // 프리미엄 패키지 (20% 보너스)
      LitPackageModel(
        pid: 'premium_1000',
        name: '프리미엄 1000릿',
        litAmount: 1000,
        bonusLit: 200, // 20% 보너스
        priceWon: 10000,
        type: PackageType.premium,
      ),

      // 메가 패키지 (30% 보너스)
      LitPackageModel(
        pid: 'mega_3000',
        name: '메가 3000릿',
        litAmount: 3000,
        bonusLit: 900, // 30% 보너스
        priceWon: 30000,
        type: PackageType.mega,
      ),
    ];
  }

  // JSON 변환
  factory LitPackageModel.fromJson(Map<String, dynamic> json) {
    return LitPackageModel(
      pid: json['pid'] ?? '',
      name: json['name'] ?? '',
      litAmount: json['lit_amount'] ?? 0,
      bonusLit: json['bonus_lit'] ?? 0,
      priceWon: json['price_won'] ?? 0,
      type: toPackageType(json['type']),
      isPopular: json['is_popular'] ?? false,
      isEvent: json['is_event'] ?? false,
      eventEndDate: json['event_end_date'] != null
          ? DateTime.tryParse(json['event_end_date'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pid': pid,
      'name': name,
      'lit_amount': litAmount,
      'bonus_lit': bonusLit,
      'price_won': priceWon,
      'type': type.value,
      'is_popular': isPopular,
      'is_event': isEvent,
      'event_end_date': eventEndDate?.toIso8601String(),
    };
  }

  // 유틸리티
  int get totalLit => litAmount + bonusLit;
  double get litPerWon => totalLit / priceWon; // 원당 릿 개수
  double get bonusRate => litAmount > 0 ? (bonusLit / litAmount * 100) : 0; // 보너스 비율
  bool get isEventActive => eventEndDate?.isAfter(DateTime.now()) ?? false;

  static PackageType toPackageType(String? type) {
    switch (type) {
      case 'basic': return PackageType.basic;
      case 'popular': return PackageType.popular;
      case 'premium': return PackageType.premium;
      case 'mega': return PackageType.mega;
      default: return PackageType.basic;
    }
  }
}

// 패키지 타입
enum PackageType {
  basic('basic'),
  popular('popular'),
  premium('premium'),
  mega('mega');

  const PackageType(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case PackageType.basic: return '기본';
      case PackageType.popular: return '인기';
      case PackageType.premium: return '프리미엄';
      case PackageType.mega: return '메가';
    }
  }
}

// 사용 예시
class WalletUsageExample {
  static void demonstrateWallet() {
    // 1. 새 지갑 생성
    final wallet = WalletModel.createDefault('user123');
    print('💳 새 지갑 생성: 보너스 ${wallet.bonusLit}릿 지급!');

    // 2. 릿 충전
    final chargedWallet = wallet.chargeLit(1000, bonusAmount: 100);
    print('💰 충전 완료: ${chargedWallet.totalLit}릿 (${chargedWallet.totalValueInWon}원 상당)');

    // 3. 30일 루틴 생성 가능 여부 확인
    final canCreate30Days = chargedWallet.canCreateRoutine(30);
    print('📅 30일 루틴 생성 가능: $canCreate30Days');

    if (canCreate30Days) {
      // 4. 30일 루틴 생성 (300릿 사용)
      final usedWallet = chargedWallet.useLit(300);
      print('🎯 30일 루틴 생성! 남은 릿: ${usedWallet.totalLit}릿');
    } else {
      // 5. 부족한 릿 충전 추천
      final needed = chargedWallet.getRecommendedChargeAmount(300);
      print('❌ 릿 부족! ${needed}릿 충전을 추천합니다.');
    }

    // 6. 패키지 정보 확인
    final packages = LitPackageModel.getDefaultPackages();
    print('\n🛒 충전 패키지:');
    for (final package in packages) {
      print('  - ${package.name}: ${package.totalLit}릿 (${package.priceWon}원)');
      if (package.bonusLit > 0) {
        print('    보너스: ${package.bonusLit}릿 (${package.bonusRate.round()}%)');
      }
    }
  }
}

// 실행
void main() {
  WalletUsageExample.demonstrateWallet();
}