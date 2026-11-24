import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/storefront/domain/tiffin_shop_model.dart';

/// Production Firebase Service powering Authentication, Real-time Firestore sync,
/// and live catalog management for Hungr.
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  FirebaseAuth get auth => _auth ?? FirebaseAuth.instance;
  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  /// Safely initialize Firebase services
  Future<void> init() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _isInitialized = true;
      debugPrint('✅ [FirebaseService] Successfully connected to Firebase');
    } catch (e) {
      debugPrint('⚠️ [FirebaseService] Firebase init notice: $e');
      // Graceful fallback during offline development or test runs
      _isInitialized = false;
    }
  }

  // ==========================================
  // 1. PHONE AUTHENTICATION (OTP PIPELINE)
  // ==========================================

  /// Sends 6-digit SMS OTP using Firebase Phone Auth & Google Play Integrity
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String errorMessage) onError,
    void Function(PhoneAuthCredential credential)? onAutoVerified,
    int? resendToken,
  }) async {
    try {
      final authInstance = auth;
      await authInstance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('⚡ [PhoneAuth] Instant auto-verification on Android device');
          if (onAutoVerified != null) {
            onAutoVerified(credential);
          } else {
            await authInstance.signInWithCredential(credential);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ [PhoneAuth] Verification failed: ${e.code} - ${e.message}');
          String message = 'Phone verification failed. Please try again.';
          if (e.code == 'invalid-phone-number') {
            message = 'The provided phone number is not valid.';
          } else if (e.code == 'quota-exceeded') {
            message = 'SMS quota exceeded for today. Please try again later.';
          } else if (e.code == 'too-many-requests') {
            message = 'Too many requests. Please wait a few moments.';
          } else if (e.message != null && e.message!.isNotEmpty) {
            message = e.message!;
          }
          onError(message);
        },
        codeSent: (String verificationId, int? newResendToken) {
          debugPrint('📨 [PhoneAuth] OTP SMS dispatched. Verification ID: $verificationId');
          onCodeSent(verificationId, newResendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⏰ [PhoneAuth] Auto retrieval timed out for $verificationId');
        },
      );
    } catch (e) {
      debugPrint('❌ [PhoneAuth] Unexpected error: $e');
      onError('Unable to request OTP: $e');
    }
  }

  /// Verifies the 6-digit SMS code and establishes customer session
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
    required String userName,
    required String phoneNumber,
    String? dropGate,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      // Sync user profile to Firestore
      await syncUserProfile(
        uid: user.uid,
        name: userName,
        phone: phoneNumber,
        dropGate: dropGate ?? 'Khammam Gate',
      );
    }

    return userCredential;
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  /// Auth state stream
  Stream<User?> get authStateChanges {
    try {
      return auth.authStateChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Current logged-in user
  User? get currentUser {
    try {
      return auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  // ==========================================
  // 2. USER PROFILE SYNC
  // ==========================================

  Future<void> syncUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String dropGate,
  }) async {
    try {
      final docRef = firestore.collection('users').doc(uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set({
          'uid': uid,
          'name': name,
          'phoneNumber': phone,
          'clusterName': dropGate,
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.update({
          'name': name,
          'phoneNumber': phone,
          'clusterName': dropGate,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('⚠️ [FirebaseService] User profile sync notice: $e');
    }
  }

  // ==========================================
  // 3. REAL-TIME CATALOG & TIFFIN SHOPS
  // ==========================================

  /// Real-time stream of partner tiffin shops from Cloud Firestore
  /// Automatically falls back to standard shops if collection is empty
  Stream<List<TiffinShop>> streamTiffinShops() {
    try {
      return firestore
          .collection('tiffin_shops')
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          debugPrint('ℹ️ [Firestore] No remote shops found, serving standard catalog');
          return TiffinShop.standardShops;
        }
        return snapshot.docs.map((doc) {
          return TiffinShop.fromMap(doc.data(), docId: doc.id);
        }).toList();
      }).handleError((error) {
        debugPrint('⚠️ [Firestore stream error]: $error - returning standard catalog');
        return TiffinShop.standardShops;
      });
    } catch (e) {
      debugPrint('⚠️ [Firestore stream exception]: $e');
      return Stream.value(TiffinShop.standardShops);
    }
  }

  /// Stream of active promotional offers & banners
  Stream<List<Map<String, dynamic>>> streamOffers() {
    try {
      return firestore
          .collection('offers')
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList())
          .handleError((_) => <Map<String, dynamic>>[]);
    } catch (_) {
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  // ==========================================
  // 4. FCM PUSH NOTIFICATIONS & RETENTION
  // ==========================================

  /// Sync device FCM token to user document and global fcm_tokens collection
  Future<void> syncFcmToken(String token) async {
    try {
      final user = currentUser;
      if (user != null) {
        await firestore.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'fcmUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await firestore.collection('fcm_tokens').doc(token).set({
        'token': token,
        'userId': user?.uid,
        'phoneNumber': user?.phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
        'platform': 'android',
      }, SetOptions(merge: true));
      debugPrint('✅ [FCM] Token synced to Firestore successfully');
    } catch (e) {
      debugPrint('⚠️ [FCM sync notice]: $e');
    }
  }

  /// Records an active cart session to power Swiggy/Zomato style abandonment recovery nudges
  Future<void> trackAbandonedCart({
    required String phone,
    required Map<String, int> items,
    required int subtotal,
  }) async {
    try {
      if (items.isEmpty) {
        await clearAbandonedCart(phone);
        return;
      }
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      await firestore.collection('abandoned_carts').doc(cleanPhone).set({
        'phone': phone,
        'cleanPhone': cleanPhone,
        'userId': currentUser?.uid,
        'items': items,
        'subtotal': subtotal,
        'status': 'in_cart',
        'reminded': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('🛒 [Cart Tracked] Active cart session recorded in Firestore');
    } catch (e) {
      debugPrint('⚠️ [Cart track notice]: $e');
    }
  }

  /// Removes cart record upon successful order placement
  Future<void> clearAbandonedCart(String phone) async {
    try {
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      await firestore.collection('abandoned_carts').doc(cleanPhone).delete();
      debugPrint('🧹 [Cart Cleared] Abandoned cart record removed upon order');
    } catch (e) {
      debugPrint('⚠️ [Cart clear notice]: $e');
    }
  }

  // ==========================================
  // 5. LIVE ORDERS & MEAL TICKETS LEDGER
  // ==========================================

  /// Records live order and pass purchase to Cloud Firestore (zero dummy data)
  Future<String> recordOrder({
    required String userId,
    required String orderMode, // 'singleDay' or 'subscriptionPass'
    String? tier,
    int? days,
    required Map<String, int> itemQuantities,
    required int totalAmount,
    int discountAmount = 0,
    String? appliedCoupon,
    required String clusterName,
    required String bagToken,
    required String deliveryDate,
  }) async {
    try {
      final orderRef = firestore.collection('orders').doc();
      final orderData = {
        'orderId': orderRef.id,
        'userId': userId,
        'userUid': currentUser?.uid,
        'orderMode': orderMode,
        'tier': tier,
        'days': days,
        'items': itemQuantities,
        'totalAmount': totalAmount,
        'discountAmount': discountAmount,
        'appliedCoupon': appliedCoupon,
        'clusterName': clusterName,
        'bagToken': bagToken,
        'deliveryDate': deliveryDate,
        'status': 'CONFIRMED',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await orderRef.set(orderData);

      // If subscription pass, record into passes collection
      if (orderMode == 'subscriptionPass' && days != null) {
        final passRef = firestore.collection('passes').doc();
        await passRef.set({
          'passId': passRef.id,
          'orderId': orderRef.id,
          'userId': currentUser?.uid ?? userId,
          'tier': tier,
          'totalDays': days,
          'remainingDays': days,
          'clusterName': clusterName,
          'bagToken': bagToken,
          'status': 'ACTIVE',
          'startDate': deliveryDate,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Record tomorrow's morning meal ticket
      final ticketRef = firestore.collection('meal_tickets').doc();
      await ticketRef.set({
        'ticketId': ticketRef.id,
        'orderId': orderRef.id,
        'userId': currentUser?.uid ?? userId,
        'clusterName': clusterName,
        'bagToken': bagToken,
        'deliveryDate': deliveryDate,
        'comboSelection': 'A',
        'slot': 'MORNING_0730',
        'status': 'SCHEDULED',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('🎉 [Order Recorded] Live order ${orderRef.id} and ticket stored in Cloud Firestore');
      return orderRef.id;
    } catch (e) {
      debugPrint('⚠️ [Record order error]: $e');
      return 'local_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Real-time stream of user orders
  Stream<List<Map<String, dynamic>>> streamUserOrders(String userId) {
    try {
      return firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.data()).toList())
          .handleError((e) {
        debugPrint('⚠️ [Orders stream notice]: $e');
        return <Map<String, dynamic>>[];
      });
    } catch (e) {
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }
}
