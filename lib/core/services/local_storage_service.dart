import 'dart:convert';
import 'dart:io';

/// Local Persistent Storage Service
/// Persists authentication session, user profile, chosen delivery cluster,
/// and pass information across app launches using a robust, pure Dart JSON storage.
///
/// Requires ZERO third-party native Android plugins or Gradle dependencies.
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  static const String _keyIsAuthenticated = 'hungr_is_authenticated';
  static const String _keyUserName = 'hungr_user_name';
  static const String _keyUserPhone = 'hungr_user_phone';
  static const String _keyClusterId = 'hungr_cluster_id';
  static const String _keyClusterName = 'hungr_cluster_name';
  static const String _keyClusterZone = 'hungr_cluster_zone';
  static const String _keyClusterLandmark = 'hungr_cluster_landmark';
  static const String _keyHasActivePass = 'hungr_has_active_pass';
  static const String _keyPassTier = 'hungr_pass_tier';
  static const String _keyMealsRemaining = 'hungr_meals_remaining';
  static const String _keyTotalMeals = 'hungr_total_meals';
  static const String _keyTomorrowCombo = 'hungr_tomorrow_combo';
  static const String _keyReferralCount = 'hungr_referral_count';
  static const String _keyFreePassClaimed = 'hungr_free_pass_claimed';

  final Map<String, dynamic> _memoryCache = {};
  bool _isInitialized = false;
  File? _storeFile;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    try {
      _storeFile = _resolveStoreFile();
      if (_storeFile != null && await _storeFile!.exists()) {
        final content = await _storeFile!.readAsString();
        if (content.trim().isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is Map<String, dynamic>) {
            _memoryCache.addAll(decoded);
          }
        }
      }
    } catch (_) {
      // Graceful fallback to memoryCache if file system is inaccessible
    } finally {
      _isInitialized = true;
    }
  }

  File? _resolveStoreFile() {
    try {
      // On Android / Mobile, try internal app directory
      final baseDir = Directory.systemTemp.parent;
      final candidates = [
        Directory('${baseDir.path}/app_flutter'),
        Directory('${baseDir.path}/files'),
        Directory.systemTemp,
      ];

      for (final dir in candidates) {
        try {
          if (!dir.existsSync()) {
            dir.createSync(recursive: true);
          }
          final testFile = File('${dir.path}/hungr_local_store.json');
          return testFile;
        } catch (_) {
          continue;
        }
      }
    } catch (_) {}

    // Fallback to system temp
    try {
      return File('${Directory.systemTemp.path}/hungr_local_store.json');
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistToDisk() async {
    if (_storeFile == null) return;
    try {
      final jsonString = jsonEncode(_memoryCache);
      await _storeFile!.writeAsString(jsonString, flush: true);
    } catch (_) {
      // In-memory cache continues to serve reads seamlessly
    }
  }

  // --- Auth & User Profile ---

  Future<void> saveUserSession({
    required String phone,
    required String name,
    String? clusterName,
  }) async {
    await _ensureInitialized();
    _memoryCache[_keyIsAuthenticated] = true;
    _memoryCache[_keyUserPhone] = phone;
    _memoryCache[_keyUserName] = name;
    if (clusterName != null) {
      _memoryCache[_keyClusterName] = clusterName;
    }
    await _persistToDisk();
  }

  Future<bool> isAuthenticated() async {
    await _ensureInitialized();
    return _memoryCache[_keyIsAuthenticated] as bool? ?? false;
  }

  Future<Map<String, String>> getUserSession() async {
    await _ensureInitialized();
    return {
      'phone': (_memoryCache[_keyUserPhone] as String?) ?? '+91 98765 43210',
      'name': (_memoryCache[_keyUserName] as String?) ?? 'Vamsi Krishna',
      'clusterName': (_memoryCache[_keyClusterName] as String?) ?? 'Sri Sai Boys Hostel Gate',
    };
  }

  Future<void> clearUserSession() async {
    await _ensureInitialized();
    _memoryCache.remove(_keyIsAuthenticated);
    _memoryCache.remove(_keyUserPhone);
    _memoryCache.remove(_keyUserName);
    _memoryCache.remove(_keyHasActivePass);
    await _persistToDisk();
  }

  // --- Delivery Cluster ---

  Future<void> saveCluster({
    required String id,
    required String name,
    required String zone,
    required String landmark,
  }) async {
    await _ensureInitialized();
    _memoryCache[_keyClusterId] = id;
    _memoryCache[_keyClusterName] = name;
    _memoryCache[_keyClusterZone] = zone;
    _memoryCache[_keyClusterLandmark] = landmark;
    await _persistToDisk();
  }

  Future<Map<String, String>?> getSavedCluster() async {
    await _ensureInitialized();
    final id = _memoryCache[_keyClusterId] as String?;
    if (id == null) return null;
    return {
      'id': id,
      'name': (_memoryCache[_keyClusterName] as String?) ?? 'Sri Sai Boys Hostel Gate',
      'zone': (_memoryCache[_keyClusterZone] as String?) ?? 'Bypass Road, Khammam',
      'landmark': (_memoryCache[_keyClusterLandmark] as String?) ?? 'Near Bus Stand, Khammam',
    };
  }

  // --- Active Pass ---

  Future<void> savePassState({
    required bool hasActivePass,
    required String tier,
    required int mealsRemaining,
    required int totalMeals,
    required String tomorrowCombo,
  }) async {
    await _ensureInitialized();
    _memoryCache[_keyHasActivePass] = hasActivePass;
    _memoryCache[_keyPassTier] = tier;
    _memoryCache[_keyMealsRemaining] = mealsRemaining;
    _memoryCache[_keyTotalMeals] = totalMeals;
    _memoryCache[_keyTomorrowCombo] = tomorrowCombo;
    await _persistToDisk();
  }

  Future<Map<String, dynamic>?> getSavedPassState() async {
    await _ensureInitialized();
    if (!_memoryCache.containsKey(_keyHasActivePass)) return null;
    return {
      'hasActivePass': _memoryCache[_keyHasActivePass] as bool? ?? false,
      'tier': (_memoryCache[_keyPassTier] as String?) ?? 'routine7Day',
      'mealsRemaining': (_memoryCache[_keyMealsRemaining] as int?) ?? 5,
      'totalMeals': (_memoryCache[_keyTotalMeals] as int?) ?? 7,
      'tomorrowCombo': (_memoryCache[_keyTomorrowCombo] as String?) ?? 'A',
    };
  }

  // --- Viral Referral Loop ---

  Future<void> saveReferralState({
    required int count,
    required bool isClaimed,
  }) async {
    await _ensureInitialized();
    _memoryCache[_keyReferralCount] = count;
    _memoryCache[_keyFreePassClaimed] = isClaimed;
    await _persistToDisk();
  }

  Future<Map<String, dynamic>> getReferralState() async {
    await _ensureInitialized();
    return {
      'count': (_memoryCache[_keyReferralCount] as int?) ?? 3,
      'isClaimed': (_memoryCache[_keyFreePassClaimed] as bool?) ?? false,
    };
  }
}
