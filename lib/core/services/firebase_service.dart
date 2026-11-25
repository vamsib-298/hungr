import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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

  /// Delete user account & purge Firestore profile, carts, and tokens
  Future<void> deleteUserAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        try {
          await FirebaseFunctions.instance.httpsCallable('deleteMyAccountData').call();
        } catch (_) {
          await firestore.collection('users').doc(user.uid).delete();
        }
        await user.delete();
      }
    } catch (e) {
      debugPrint('⚠️ [FirebaseService] Delete account notice: $e');
      rethrow;
    }
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

  /// Sync device FCM token to user document and fcm_tokens collection (authenticated only)
  Future<void> syncFcmToken(String token) async {
    try {
      final user = currentUser;
      if (user == null) return;

      await firestore.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'fcmUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await firestore.collection('fcm_tokens').doc(token).set({
        'token': token,
        'userId': user.uid,
        'phoneNumber': user.phoneNumber,
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
  // 5. SERVER-VERIFIED PAYMENTS, ORDERS & TICKETS
  // ==========================================

  /// Calls Cloud Function `createOrderIntent` to compute server totals & create Razorpay order
  Future<Map<String, dynamic>> createOrderIntent({
    required String orderMode,
    String? tierKey,
    String? kitchenId,
    required Map<String, int> itemQuantities,
    String? appliedCoupon,
    required String clusterId,
    required String clusterName,
    required String deliverySlot,
    required String deliveryInstructions,
    required String paymentMethod,
    required String customerName,
    required String phoneNumber,
    bool autoRotatePassMenu = true,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable('createOrderIntent');
    final result = await callable.call({
      'orderMode': orderMode,
      'tierKey': tierKey,
      'kitchenId': kitchenId,
      'itemQuantities': itemQuantities,
      'appliedCoupon': appliedCoupon,
      'clusterId': clusterId,
      'clusterName': clusterName,
      'deliverySlot': deliverySlot,
      'deliveryInstructions': deliveryInstructions,
      'paymentMethod': paymentMethod,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'autoRotatePassMenu': autoRotatePassMenu,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }

  /// Calls Cloud Function `verifyAndCreateOrder` after Razorpay payment success
  Future<Map<String, dynamic>> verifyAndCreateOrder({
    required String intentId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable('verifyAndCreateOrder');
    final result = await callable.call({
      'intentId': intentId,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }

  /// Calls Cloud Function `skipMealTicket` enforcing 21:00 IST cutoff & pass ceiling
  Future<Map<String, dynamic>> callSkipMealTicket(String ticketId) async {
    final callable = FirebaseFunctions.instance.httpsCallable('skipMealTicket');
    final result = await callable.call({'ticketId': ticketId});
    return Map<String, dynamic>.from(result.data as Map);
  }

  /// Real-time stream of user orders (bounded to latest 30 for 100K DAU scale)
  Stream<List<Map<String, dynamic>>> streamUserOrders(String uid) {
    try {
      return firestore
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .limit(30)
          .snapshots()
          .map((snap) {
            final list = snap.docs.map((d) => d.data()).toList();
            list.sort((a, b) {
              final aMs = (a['createdAtMs'] as num?)?.toInt() ?? 0;
              final bMs = (b['createdAtMs'] as num?)?.toInt() ?? 0;
              return bMs.compareTo(aMs);
            });
            return list;
          })
          .handleError((e) {
            debugPrint('⚠️ [Orders stream notice]: $e');
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  /// Real-time stream of user meal tickets (bounded to 30)
  Stream<List<Map<String, dynamic>>> streamUserTickets(String uid) {
    try {
      return firestore
          .collection('meal_tickets')
          .where('userId', isEqualTo: uid)
          .limit(30)
          .snapshots()
          .map((snap) {
            final list = snap.docs.map((d) => d.data()).toList();
            list.sort((a, b) {
              final aIso = (a['deliveryDateIso'] as String?) ?? '';
              final bIso = (b['deliveryDateIso'] as String?) ?? '';
              return aIso.compareTo(bIso);
            });
            return list;
          })
          .handleError((e) {
            debugPrint('⚠️ [Tickets stream notice]: $e');
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  /// Real-time stream of user passes (bounded to 15)
  Stream<List<Map<String, dynamic>>> streamUserPasses(String uid) {
    try {
      return firestore
          .collection('passes')
          .where('userId', isEqualTo: uid)
          .limit(15)
          .snapshots()
          .map((snap) {
            final list = snap.docs.map((d) => d.data()).toList();
            list.sort((a, b) {
              final aMs = (a['createdAtMs'] as num?)?.toInt() ?? 0;
              final bMs = (b['createdAtMs'] as num?)?.toInt() ?? 0;
              return bMs.compareTo(aMs);
            });
            return list;
          })
          .handleError((e) {
            debugPrint('⚠️ [Passes stream notice]: $e');
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  /// Update ticket status (pause/resume) in Firestore
  Future<void> updateTicketStatus({
    required String ticketId,
    required String status, // 'SCHEDULED' or 'SKIPPED'
  }) async {
    try {
      await firestore.collection('meal_tickets').doc(ticketId).update({
        'status': status,
      });
    } catch (e) {
      debugPrint('⚠️ [Update ticket status notice]: $e');
    }
  }

  /// Update ticket combo selection in Firestore
  Future<void> updateTicketCombo({
    required String ticketId,
    required String comboSelection,
  }) async {
    try {
      await firestore.collection('meal_tickets').doc(ticketId).update({
        'comboSelection': comboSelection,
      });
    } catch (e) {
      debugPrint('⚠️ [Update ticket combo notice]: $e');
    }
  }

  /// Stream delivery clusters from Firestore (falls back cleanly if empty)
  Stream<List<Map<String, dynamic>>> streamClusters() {
    try {
      return firestore
          .collection('clusters')
          .snapshots()
          .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList())
          .handleError((_) => <Map<String, dynamic>>[]);
    } catch (_) {
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  /// Fetch real user referral data from Firestore
  Future<Map<String, dynamic>> fetchUserReferralData(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      final data = doc.data() ?? {};
      final code = data['referralCode'] as String? ??
          'HUNGR-${uid.substring(0, uid.length >= 4 ? 4 : uid.length).toUpperCase()}';
      if (data['referralCode'] == null) {
        await firestore.collection('users').doc(uid).set({
          'referralCode': code,
        }, SetOptions(merge: true));
      }
      return {
        'referralCode': code,
        'qualifiedOrderCount': (data['referralQualifiedCount'] as num?)?.toInt() ?? 0,
        'isRewardClaimed': data['referralRewardClaimed'] as bool? ?? false,
        'friends': (data['referredFriends'] as List<dynamic>?) ?? <dynamic>[],
      };
    } catch (_) {
      return {
        'referralCode': 'HUNGR-NEW',
        'qualifiedOrderCount': 0,
        'isRewardClaimed': false,
        'friends': <dynamic>[],
      };
    }
  }
}
