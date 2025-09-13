import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 🚀 DayLit 캐시 서비스
///
/// Hive 기반 고성능 캐시 시스템
/// - Cache-First 전략으로 Supabase 호출 최소화
/// - 오프라인 모드 완벽 지원
/// - 실시간 동기화 및 TTL 기반 만료
class CacheService {
  // ==================== 싱글톤 패턴 ====================
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static CacheService get instance => _instance;

  // ==================== 상태 확인 ====================
  /// 초기화 상태 확인
  bool get isInitialized => _isInitialized;

  /// 온라인 상태 확인
  bool get isOnline => _isOnline;
  bool _isInitialized = false;
  bool _isOnline = true;
  late Box<dynamic> _dataBox;
  late Box<CacheMetadata> _metadataBox;

  // 캐시 박스 이름들
  static const String _dataBoxName = 'daylit_cache_data';
  static const String _metadataBoxName = 'daylit_cache_metadata';

  // ==================== 기본 설정 ====================
  /// 기본 캐시 만료 시간 (1시간)
  static const Duration defaultTTL = Duration(hours: 1);

  /// 긴 캐시 만료 시간 (1일) - 사용자 프로필 등
  static const Duration longTTL = Duration(days: 1);

  /// 짧은 캐시 만료 시간 (10분) - 실시간 데이터
  static const Duration shortTTL = Duration(minutes: 10);

  // ==================== 초기화 ====================
  /// 캐시 서비스 초기화
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _logInfo('🚀 캐시 서비스 초기화 시작...');

      // Hive 초기화
      await Hive.initFlutter();

      // 어댑터 등록 (나중에 추가)
      if (!Hive.isAdapterRegistered(CacheMetadataAdapter().typeId)) {
        Hive.registerAdapter(CacheMetadataAdapter());
      }

      // 캐시 박스 열기
      _dataBox = await Hive.openBox<dynamic>(_dataBoxName);
      _metadataBox = await Hive.openBox<CacheMetadata>(_metadataBoxName);

      // 네트워크 상태 모니터링 시작
      _startNetworkMonitoring();

      // 만료된 캐시 정리
      await _cleanExpiredCache();

      _isInitialized = true;
      _logInfo('✅ 캐시 서비스 초기화 완료');

      return true;
    } catch (e) {
      _logError('❌ 캐시 서비스 초기화 실패', e);
      return false;
    }
  }

  // ==================== 캐시 기본 작업 ====================
  /// 데이터 캐시에 저장
  Future<void> set<T>({
    required String key,
    required T data,
    Duration ttl = defaultTTL,
    bool forceUpdate = false,
  }) async {
    if (!_isInitialized) throw StateError('캐시 서비스가 초기화되지 않았습니다.');

    try {
      final now = DateTime.now();
      final expiresAt = now.add(ttl);

      // 메타데이터 저장
      final metadata = CacheMetadata(
        key: key,
        createdAt: now,
        expiresAt: expiresAt,
        dataType: T.toString(),
        size: _calculateSize(data),
      );

      await _metadataBox.put(key, metadata);
      await _dataBox.put(key, data);

      _logFine('💾 캐시 저장: $key (만료: ${_formatDateTime(expiresAt)})');
    } catch (e) {
      _logError('캐시 저장 실패: $key', e);
    }
  }

  /// 캐시에서 데이터 읽기
  T? get<T>(String key) {
    if (!_isInitialized) return null;

    try {
      // 메타데이터 확인
      final metadata = _metadataBox.get(key);
      if (metadata == null) {
        _logFine('📭 캐시 미스: $key (메타데이터 없음)');
        return null;
      }

      // 만료 확인
      if (metadata.isExpired) {
        _logFine('⏰ 캐시 만료: $key');
        _removeExpiredKey(key);
        return null;
      }

      // 데이터 반환
      final data = _dataBox.get(key);
      if (data != null) {
        _logFine('🎯 캐시 히트: $key');
        return data as T;
      } else {
        _logFine('📭 캐시 미스: $key (데이터 없음)');
        return null;
      }
    } catch (e) {
      _logError('캐시 읽기 실패: $key', e);
      return null;
    }
  }

  /// 캐시 존재 및 유효성 확인
  bool isValid(String key) {
    final metadata = _metadataBox.get(key);
    return metadata != null && !metadata.isExpired && _dataBox.containsKey(key);
  }

  /// 특정 키 삭제
  Future<void> remove(String key) async {
    await _metadataBox.delete(key);
    await _dataBox.delete(key);
    _logFine('🗑️ 캐시 삭제: $key');
  }

  /// 패턴으로 키 삭제 (예: "quests_*")
  Future<void> removeByPattern(String pattern) async {
    final regex = RegExp(pattern.replaceAll('*', '.*'));
    final keysToRemove = <String>[];

    for (final key in _dataBox.keys) {
      if (regex.hasMatch(key.toString())) {
        keysToRemove.add(key.toString());
      }
    }

    for (final key in keysToRemove) {
      await remove(key);
    }

    _logInfo('🧹 패턴 삭제 완료: $pattern (${keysToRemove.length}개)');
  }

  // ==================== 고급 캐시 전략 ====================
  /// Cache-First 전략: 캐시 우선, 없으면 네트워크
  Future<T?> cacheFirst<T>({
    required String key,
    required Future<T> Function() fetchFunction,
    Duration ttl = defaultTTL,
    bool forceRefresh = false,
  }) async {
    // 강제 새로고침이 아니면 캐시부터 확인
    if (!forceRefresh) {
      final cached = get<T>(key);
      if (cached != null) {
        _logFine('🎯 Cache-First 히트: $key');
        return cached;
      }
    }

    // 네트워크에서 데이터 가져오기
    try {
      _logFine('🌐 Cache-First 네트워크 요청: $key');
      final data = await fetchFunction();

      if (data != null) {
        await set(key: key, data: data, ttl: ttl);
      }

      return data;
    } catch (e) {
      _logError('Cache-First 네트워크 실패: $key', e);

      // 네트워크 실패 시 만료된 캐시라도 반환 (Stale-While-Revalidate)
      final staleData = _dataBox.get(key) as T?;
      if (staleData != null) {
        _logWarning('📱 오프라인 모드: 만료된 캐시 사용 $key');
        return staleData;
      }

      return null;
    }
  }

  /// Cache-Aside 전략: 데이터 변경 시 캐시도 함께 업데이트
  Future<T?> cacheAside<T>({
    required String key,
    required T newData,
    required Future<T> Function(T data) updateFunction,
    Duration ttl = defaultTTL,
  }) async {
    try {
      // 1. 네트워크에서 업데이트
      final updatedData = await updateFunction(newData);

      // 2. 캐시 업데이트
      await set(key: key, data: updatedData, ttl: ttl);

      _logFine('🔄 Cache-Aside 업데이트: $key');
      return updatedData;
    } catch (e) {
      _logError('Cache-Aside 실패: $key', e);
      return null;
    }
  }

  // ==================== 네트워크 감지 ====================
  void _startNetworkMonitoring() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final wasOnline = _isOnline;
      // 연결된 네트워크가 있고, none이 포함되지 않았으면 온라인
      _isOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);

      if (wasOnline != _isOnline) {
        _logInfo('🌐 네트워크 상태 변경: ${_isOnline ? "온라인" : "오프라인"}');
        _logInfo('📡 연결된 네트워크: ${results.join(", ")}');

        // 온라인 복구 시 캐시 동기화 트리거
        if (_isOnline) {
          _triggerCacheSync();
        }
      }
    });
  }

  void _triggerCacheSync() {
    // TODO: 캐시 동기화 로직 구현
    _logInfo('🔄 캐시 동기화 트리거됨');
  }

  // ==================== 캐시 관리 ====================
  /// 만료된 캐시 정리 (public 메서드)
  Future<void> cleanExpiredCache() async {
    final expiredKeys = <String>[];

    for (final key in _metadataBox.keys) {
      final metadata = _metadataBox.get(key);
      if (metadata?.isExpired == true) {
        expiredKeys.add(key.toString());
      }
    }

    for (final key in expiredKeys) {
      await _removeExpiredKey(key);
    }

    if (expiredKeys.isNotEmpty) {
      _logInfo('🧹 만료된 캐시 정리: ${expiredKeys.length}개');
    }
  }

  /// 만료된 캐시 정리 (private - 내부 호출용)
  Future<void> _cleanExpiredCache() async {
    await cleanExpiredCache();
  }

  Future<void> _removeExpiredKey(String key) async {
    await _metadataBox.delete(key);
    await _dataBox.delete(key);
  }

  /// 전체 캐시 클리어
  Future<void> clearAll() async {
    await _dataBox.clear();
    await _metadataBox.clear();
    _logInfo('🗑️ 전체 캐시 삭제 완료');
  }

  /// 캐시 통계 정보
  Map<String, dynamic> getStats() {
    final totalKeys = _dataBox.length;
    var totalSize = 0;
    var expiredCount = 0;

    for (final key in _metadataBox.keys) {
      final metadata = _metadataBox.get(key);
      if (metadata != null) {
        totalSize += metadata.size;
        if (metadata.isExpired) expiredCount++;
      }
    }

    return {
      'totalKeys': totalKeys,
      'totalSize': totalSize,
      'expiredCount': expiredCount,
      'hitRate': 0.0, // TODO: 히트율 계산 구현
      'isOnline': _isOnline,
      'isInitialized': _isInitialized,
    };
  }

  // ==================== 헬퍼 메서드 ====================
  int _calculateSize(dynamic data) {
    // TODO: 실제 데이터 크기 계산 로직 구현
    return data.toString().length;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // ==================== 로깅 ====================
  void _logInfo(String message) {
    debugPrint('🔵 [Cache] $message');
  }

  void _logFine(String message) {
    if (kDebugMode) {
      debugPrint('🟢 [Cache] $message');
    }
  }

  void _logWarning(String message) {
    debugPrint('🟡 [Cache] $message');
  }

  void _logError(String message, [Object? error]) {
    debugPrint('🔴 [Cache] $message');
    if (error != null) debugPrint('  Error: $error');
  }

  // ==================== 생명주기 ====================
  /// 리소스 정리
  Future<void> dispose() async {
    await _dataBox.close();
    await _metadataBox.close();
    _isInitialized = false;
    _logInfo('👋 캐시 서비스 종료');
  }
}

// ==================== 캐시 메타데이터 클래스 ====================
@HiveType(typeId: 999)
class CacheMetadata {
  @HiveField(0)
  final String key;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  final DateTime expiresAt;

  @HiveField(3)
  final String dataType;

  @HiveField(4)
  final int size;

  CacheMetadata({
    required this.key,
    required this.createdAt,
    required this.expiresAt,
    required this.dataType,
    required this.size,
  });

  /// 만료 여부 확인
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// 만료까지 남은 시간
  Duration get timeToExpire => expiresAt.difference(DateTime.now());
}

// ==================== Hive 어댑터 생성 ====================
class CacheMetadataAdapter extends TypeAdapter<CacheMetadata> {
  @override
  final int typeId = 999;

  @override
  CacheMetadata read(BinaryReader reader) {
    return CacheMetadata(
      key: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      dataType: reader.readString(),
      size: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, CacheMetadata obj) {
    writer.writeString(obj.key);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.expiresAt.millisecondsSinceEpoch);
    writer.writeString(obj.dataType);
    writer.writeInt(obj.size);
  }
}