import 'package:shared_preferences/shared_preferences.dart';

/// Production Local Persistent Storage Service backed by Android/iOS SharedPreferences
/// with an in-memory fallback for headless unit tests.
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

  SharedPreferences? _prefs;
  final Map<String, Object> _memoryFallback = {};
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      _prefs = null;
    } finally {
      _initialized = true;
    }
  }

  Future<void> _setBool(String key, bool value) async {
    _memoryFallback[key] = value;
    await _prefs?.setBool(key, value);
  }

  Future<void> _setString(String key, String value) async {
    _memoryFallback[key] = value;
    await _prefs?.setString(key, value);
  }

  Future<void> _setInt(String key, int value) async {
    _memoryFallback[key] = value;
    await _prefs?.setInt(key, value);
  }

  Future<void> _remove(String key) async {
    _memoryFallback.remove(key);
    await _prefs?.remove(key);
  }

  bool? _getBool(String key) => _prefs?.getBool(key) ?? _memoryFallback[key] as bool?;
  String? _getString(String key) => _prefs?.getString(key) ?? _memoryFallback[key] as String?;
  int? _getInt(String key) => _prefs?.getInt(key) ?? _memoryFallback[key] as int?;

  // --- Auth & User Profile ---

  Future<void> saveUserSession({
    required String phone,
    required String name,
    String? clusterName,
  }) async {
    await _ensureInitialized();
    await _setBool(_keyIsAuthenticated, true);
    await _setString(_keyUserPhone, phone);
    await _setString(_keyUserName, name);
    if (clusterName != null) {
      await _setString(_keyClusterName, clusterName);
    }
  }

  Future<bool> isAuthenticated() async {
    await _ensureInitialized();
    return _getBool(_keyIsAuthenticated) ?? false;
  }

  Future<Map<String, String>> getUserSession() async {
    await _ensureInitialized();
    return {
      'phone': _getString(_keyUserPhone) ?? '',
      'name': _getString(_keyUserName) ?? 'Hungr Foodie',
      'clusterName': _getString(_keyClusterName) ?? 'Hostel Security Gate',
    };
  }

  Future<void> clearUserSession() async {
    await _ensureInitialized();
    await _remove(_keyIsAuthenticated);
    await _remove(_keyUserPhone);
    await _remove(_keyUserName);
    await _remove(_keyHasActivePass);
  }

  // --- Delivery Cluster ---

  Future<void> saveCluster({
    required String id,
    required String name,
    required String zone,
    required String landmark,
  }) async {
    await _ensureInitialized();
    await _setString(_keyClusterId, id);
    await _setString(_keyClusterName, name);
    await _setString(_keyClusterZone, zone);
    await _setString(_keyClusterLandmark, landmark);
  }

  Future<Map<String, String>?> getSavedCluster() async {
    await _ensureInitialized();
    final id = _getString(_keyClusterId);
    if (id == null) return null;
    return {
      'id': id,
      'name': _getString(_keyClusterName) ?? 'Sri Sai Boys Hostel Main Gate',
      'zone': _getString(_keyClusterZone) ?? 'Bypass Road, Khammam',
      'landmark': _getString(_keyClusterLandmark) ?? 'Near New Collectorate Arch',
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
    await _setBool(_keyHasActivePass, hasActivePass);
    await _setString(_keyPassTier, tier);
    await _setInt(_keyMealsRemaining, mealsRemaining);
    await _setInt(_keyTotalMeals, totalMeals);
    await _setString(_keyTomorrowCombo, tomorrowCombo);
  }

  Future<Map<String, dynamic>?> getSavedPassState() async {
    await _ensureInitialized();
    final hasPass = _getBool(_keyHasActivePass);
    if (hasPass == null) return null;
    return {
      'hasActivePass': hasPass,
      'tier': _getString(_keyPassTier) ?? 'routine7Day',
      'mealsRemaining': _getInt(_keyMealsRemaining) ?? 0,
      'totalMeals': _getInt(_keyTotalMeals) ?? 0,
      'tomorrowCombo': _getString(_keyTomorrowCombo) ?? 'A',
    };
  }

  // --- Referral ---

  Future<void> saveReferralState({
    required int count,
    required bool isClaimed,
  }) async {
    await _ensureInitialized();
    await _setInt(_keyReferralCount, count);
    await _setBool(_keyFreePassClaimed, isClaimed);
  }

  Future<Map<String, dynamic>> getReferralState() async {
    await _ensureInitialized();
    return {
      'count': _getInt(_keyReferralCount) ?? 0,
      'isClaimed': _getBool(_keyFreePassClaimed) ?? false,
    };
  }
}
